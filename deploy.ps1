# ============================================================
#  호텔 잠잠 로컬 배포 스크립트 (deploy.bat 을 더블클릭하면 이 파일이 실행된다)
#  0) Tomcat 경로 묻기  1) WebContents 복사  2) 자바 컴파일
#  3) hotel.war 생성  4) 실행 중인 Tomcat 종료  5) webapps 에 war 복사 후 Tomcat 시작
#
#  - 필요한 것 : Tomcat 9 (zip 판), Java 17 이상. JDK 가 없어도 된다.
#    컴파일은 Tomcat 안에 들어 있는 이클립스 컴파일러(lib\ecj-*.jar)로 한다.
#  - 입력한 Tomcat 경로는 deploy.local.txt 에 저장돼 다음부터 기본값으로 나온다 (git 에 안 올라감).
# ============================================================

$ErrorActionPreference = 'Stop'
$App   = 'hotel'
$Port  = 8080
$Root  = $PSScriptRoot
$Local = Join-Path $Root 'deploy.local.txt'
$Out   = Join-Path $Root 'build\deploy'
$Stage = Join-Path $Out $App
$War   = Join-Path $Out "$App.war"

function Fail($msg) {
    Write-Host "[오류] $msg" -ForegroundColor Red
    Write-Host '배포를 중단했습니다.'
    exit 1
}

function Test-PortBusy {
    [bool](Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction SilentlyContinue)
}

# ---- 0. Tomcat 경로 ----
# 기본값 : 지난번 입력 > CATALINA_HOME 환경 변수 > 자주 쓰는 위치에서 찾기
$tomcat = $null
if (Test-Path $Local) { $tomcat = (Get-Content $Local -Encoding UTF8 | Select-Object -First 1) }
if (-not $tomcat -and $env:CATALINA_HOME) { $tomcat = $env:CATALINA_HOME }
if (-not $tomcat) {
    $guess = @('C:\', 'D:\', $env:USERPROFILE, "$env:USERPROFILE\Downloads", "$env:USERPROFILE\Desktop", 'C:\DevTools\Server\Tomcat') |
        Where-Object { Test-Path $_ } |
        ForEach-Object { Get-ChildItem $_ -Directory -Filter 'apache-tomcat-9*' -ErrorAction SilentlyContinue } |
        Where-Object { Test-Path (Join-Path $_.FullName 'bin\startup.bat') } |
        Select-Object -Last 1
    if ($guess) { $tomcat = $guess.FullName }
}

while ($true) {
    Write-Host ''
    Write-Host 'Tomcat 9 폴더 경로를 입력하세요. (bin, lib, webapps 가 들어 있는 폴더 / 이 창에 폴더를 끌어다 놓아도 됨)'
    if ($tomcat) { Write-Host "  그냥 Enter : $tomcat" -ForegroundColor Cyan }
    $input1 = (Read-Host '경로').Trim().Trim('"').TrimEnd('\')
    if ($input1) { $tomcat = $input1 }
    if (-not $tomcat) { continue }
    if (Test-Path (Join-Path $tomcat 'bin\startup.bat')) { break }
    Write-Host "[오류] $tomcat\bin\startup.bat 이 없습니다. Tomcat zip 을 푼 폴더를 입력하세요." -ForegroundColor Red
    $tomcat = $null
}
$notes = Join-Path $tomcat 'RELEASE-NOTES'
if (-not ((Test-Path $notes) -and (Select-String -Path $notes -Pattern 'Apache Tomcat Version 9\.' -Quiet))) {
    Write-Host '[주의] Tomcat 9 가 아닌 것 같습니다. 수업 환경은 Tomcat 9 입니다.' -ForegroundColor Yellow
}
Set-Content -Path $Local -Value $tomcat -Encoding UTF8   # 다음 실행 때 기본값

# ---- Java 찾기 : JAVA_HOME > JRE_HOME > PATH 의 java ----
$java = $null
foreach ($h in @($env:JAVA_HOME, $env:JRE_HOME)) {
    if (-not $java -and $h -and (Test-Path "$h\bin\java.exe")) { $java = "$h\bin\java.exe" }
}
if (-not $java) {
    $cmd = Get-Command java -ErrorAction SilentlyContinue
    if ($cmd) { $java = $cmd.Source }
}
if (-not $java) { Fail 'Java 를 찾을 수 없습니다. Java 17 이상을 설치하세요.' }
# java 가 실제로 설치된 폴더(java.home)를 알아내서 Tomcat 실행용 JRE_HOME 으로 넘긴다
$props = & cmd /c "`"$java`" -XshowSettings:properties -version 2>&1"
$javaHome = (($props | Select-String 'java\.home = ') -split ' = ', 2)[1].Trim()

# Tomcat 의 startup.bat / shutdown.bat 이 이 경로들을 쓰게 한다 (이 창 안에서만 적용)
$env:CATALINA_HOME = $tomcat
$env:CATALINA_BASE = $null
$env:JRE_HOME      = $javaHome
$env:JAVA_HOME     = $null

Write-Host ''
Write-Host "Tomcat : $tomcat"
Write-Host "Java   : $javaHome"

# ---- 1. 작업 폴더 준비 : WebContents 를 통째로 복사 ----
Write-Host ''
Write-Host '[1/5] WebContents 복사'
if (Test-Path $Out) { Remove-Item $Out -Recurse -Force }
New-Item -ItemType Directory -Path $Stage -Force | Out-Null
Copy-Item (Join-Path $Root 'WebContents\*') $Stage -Recurse -Force

# ---- 2. 자바 컴파일 : Tomcat 에 들어 있는 ecj 컴파일러 사용 (JDK 없이도 됨) ----
Write-Host '[2/5] 자바 컴파일'
$classes = Join-Path $Stage 'WEB-INF\classes'
New-Item -ItemType Directory -Path $classes -Force | Out-Null
$ecj = Get-ChildItem (Join-Path $tomcat 'lib') -Filter 'ecj-*.jar' | Select-Object -Last 1
if (-not $ecj) { Fail "$tomcat\lib 에 ecj-*.jar 가 없습니다." }
# 컴파일할 때 필요한 jar : Tomcat 의 servlet/jsp api + 프로젝트 WEB-INF\lib 의 jar 전부
$cp = @("$tomcat\lib\servlet-api.jar", "$tomcat\lib\jsp-api.jar") +
      (Get-ChildItem (Join-Path $Root 'WebContents\WEB-INF\lib') -Filter '*.jar' | ForEach-Object { $_.FullName })
# src\main\java 폴더를 주면 그 안의 .java 를 모두 컴파일한다. Java 11 문법 기준 (17 이상에서 그대로 실행됨)
& $java -cp $ecj.FullName org.eclipse.jdt.internal.compiler.batch.Main `
    -11 -encoding UTF-8 -nowarn -cp ($cp -join ';') -d $classes (Join-Path $Root 'src\main\java')
if ($LASTEXITCODE -ne 0) { Fail '컴파일 실패 (위 오류 메시지 확인)' }
# 자바가 아닌 파일(pool.jocl 등)도 classes 로 복사
$src = Join-Path $Root 'src\main\java'
Get-ChildItem $src -Recurse -File | Where-Object { $_.Extension -ne '.java' } | ForEach-Object {
    $dest = Join-Path $classes $_.FullName.Substring($src.Length + 1)
    New-Item -ItemType Directory -Path (Split-Path $dest) -Force | Out-Null
    Copy-Item $_.FullName $dest -Force
}

# ---- 3. war 만들기 : war 는 zip 형식이라 윈도우 기본 tar 로 묶는다 ----
Write-Host "[3/5] $App.war 생성"
$items = Get-ChildItem $Stage | ForEach-Object { $_.Name }
& "$env:SystemRoot\System32\tar.exe" --format zip -cf $War -C $Stage @items
if ($LASTEXITCODE -ne 0) { Fail 'war 생성 실패' }

# ---- 4. 실행 중인 Tomcat 종료 ----
Write-Host '[4/5] Tomcat 종료'
if (Test-PortBusy) {
    & cmd /c "`"$tomcat\bin\shutdown.bat`" >nul 2>&1"
    # 최대 20초 동안 포트가 비기를 기다림
    for ($i = 0; $i -lt 20 -and (Test-PortBusy); $i++) { Start-Sleep -Seconds 1 }
    if (Test-PortBusy) { Fail "$Port 포트를 다른 프로그램이 쓰고 있습니다. 이클립스 서버 등을 먼저 끄고 다시 실행하세요." }
}

# ---- 5. 이전 배포 지우고 war 복사 후 Tomcat 시작 ----
Write-Host '[5/5] 배포 후 Tomcat 시작'
foreach ($old in @("webapps\$App", "webapps\$App.war", "work\Catalina\localhost\$App")) {
    # work 폴더는 예전 JSP 컴파일 결과. 남지 않게 같이 지운다
    $p = Join-Path $tomcat $old
    if (Test-Path $p) { Remove-Item $p -Recurse -Force }
}
Copy-Item $War (Join-Path $tomcat 'webapps') -Force
# startup.bat 이 새 창에서 Tomcat 을 띄운다
Start-Process -FilePath (Join-Path $tomcat 'bin\startup.bat') -WorkingDirectory (Join-Path $tomcat 'bin') -WindowStyle Hidden

Write-Host ''
Write-Host "배포 완료 : http://localhost:$Port/$App/" -ForegroundColor Green
Write-Host '(Tomcat 이 war 를 풀고 뜨기까지 몇 초 걸립니다. 끌 때는 Tomcat 창을 닫으면 됩니다)'
Write-Host 'MySQL(hotel DB)이 켜져 있어야 화면이 제대로 나옵니다.'
