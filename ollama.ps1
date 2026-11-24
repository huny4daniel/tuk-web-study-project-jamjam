# ============================================================
#  학교 Ollama 서버 접속 스크립트 (ollama.bat 을 더블클릭하면 이 파일이 실행된다)
#  1) 학번 계정(stud08, stud12 ...) 묻기
#  2) 새 창에서 SSH 터널 열기 : 내 PC 36443 -> 학교 서버 6443 (쿠버네티스 API)
#  3) 이 창에서 kubectl port-forward : 내 PC 11435 -> ollama 서비스 11434
#  → OllamaClient.java 가 쓰는 http://localhost:11435 로 바로 접속된다.
#
#  - 필요한 것 : ssh (윈도우 기본 OpenSSH), kubectl + 수업에서 받은 kubeconfig (~\.kube\config)
#  - 입력한 계정은 ollama.local.txt 에 저장돼 다음부터 기본값으로 나온다 (git 에 안 올라감).
#  - 끝낼 때는 이 창에서 Ctrl+C 또는 창 닫기. SSH 터널 창도 같이 닫힌다.
# ============================================================

$ErrorActionPreference = 'Stop'
$SshHost    = '220.149.119.234'
$TunnelPort = 36443   # 내 PC 쪽 쿠버네티스 API 포트 (kubeconfig 의 server: https://localhost:36443)
$RemotePort = 6443
$OllamaPort = 11435   # 내 PC 쪽 Ollama 포트 (OllamaClient.java 의 API_URL)
$Local      = Join-Path $PSScriptRoot 'ollama.local.txt'

function Fail($msg) {
    Write-Host "[오류] $msg" -ForegroundColor Red
    exit 1
}

function Test-PortBusy($port) {
    [bool](Get-NetTCPConnection -LocalPort $port -State Listen -ErrorAction SilentlyContinue)
}

# ---- 0. 필요한 프로그램 확인 ----
if (-not (Get-Command ssh -ErrorAction SilentlyContinue)) {
    Fail 'ssh 가 없습니다. 설정 > 시스템 > 선택적 기능 에서 "OpenSSH 클라이언트" 를 추가하세요.'
}
if (-not (Get-Command kubectl -ErrorAction SilentlyContinue)) {
    Fail 'kubectl 이 없습니다. kubectl 을 설치하고 PATH 에 넣으세요.'
}

# ---- 1. 계정 입력 (엔터만 치면 지난번 값) ----
$saved = ''
if (Test-Path $Local) { $saved = (Get-Content $Local -Raw).Trim() }

if ($saved) {
    $user = Read-Host "학교 서버 계정 (엔터 = $saved)"
    if (-not $user) { $user = $saved }
} else {
    $user = Read-Host '학교 서버 계정 (예 : stud08)'
}
$user = $user.Trim()
if ($user -notmatch '^[A-Za-z0-9_.-]+$') { Fail "계정 이름이 올바르지 않습니다 : '$user'" }
Set-Content -Path $Local -Value $user -Encoding ascii

if (Test-PortBusy $OllamaPort) {
    Write-Host "포트 $OllamaPort 가 이미 열려 있습니다. 이미 접속된 상태일 수 있습니다." -ForegroundColor Yellow
    Write-Host "확인 : http://localhost:$OllamaPort/api/tags"
    exit 0
}

# ---- 2. SSH 터널 (비밀번호는 새로 뜨는 창에 입력) ----
$ssh = $null
if (Test-PortBusy $TunnelPort) {
    Write-Host "포트 $TunnelPort 터널이 이미 열려 있어 SSH 단계는 건너뜁니다."
} else {
    Write-Host "SSH 터널을 엽니다 : $user@$SshHost  (새 창에 비밀번호를 입력하세요)" -ForegroundColor Cyan
    # -N : 셸 없이 터널만 유지, ExitOnForwardFailure : 포트 연결 실패 시 바로 종료,
    # ServerAliveInterval : 오래 켜 둬도 끊기지 않게 30초마다 신호를 보낸다
    $sshArgs = @('-N', '-L', "${TunnelPort}:localhost:${RemotePort}",
                 '-o', 'ExitOnForwardFailure=yes', '-o', 'ServerAliveInterval=30',
                 "$user@$SshHost")
    $ssh = Start-Process ssh -ArgumentList $sshArgs -PassThru

    # 비밀번호를 입력해 터널이 열릴 때까지 기다린다 (최대 3분)
    $waited = 0
    while (-not (Test-PortBusy $TunnelPort)) {
        if ($ssh.HasExited) { Fail 'SSH 접속에 실패했습니다. 계정·비밀번호를 확인하세요.' }
        if ($waited -ge 180) { $ssh.Kill(); Fail 'SSH 터널이 3분 안에 열리지 않았습니다.' }
        Start-Sleep -Seconds 1
        $waited++
    }
    Write-Host 'SSH 터널 연결 완료.' -ForegroundColor Green
}

# ---- 3. kubectl port-forward ----
# kubeconfig 에 계정과 같은 이름의 context 가 있으면 그것을 쓰고, 없으면 현재 context 를 쓴다
$ctxArgs = @()
$contexts = kubectl config get-contexts -o name 2>$null
if ($contexts -contains $user) { $ctxArgs = @('--context', $user) }

Write-Host ''
Write-Host "Ollama 연결 : http://localhost:$OllamaPort  (끝내려면 Ctrl+C 또는 창 닫기)" -ForegroundColor Green
Write-Host ''
try {
    # 파드가 재시작되는 등으로 port-forward 가 끊기면 터널이 살아 있는 동안 다시 연결한다
    while ($true) {
        kubectl @ctxArgs -n default port-forward svc/ollama "${OllamaPort}:11434"
        if ($ssh -and $ssh.HasExited) { Fail 'SSH 터널이 끊겼습니다. 다시 실행하세요.' }
        Write-Host 'port-forward 가 끊겼습니다. 3초 뒤 다시 연결합니다...' -ForegroundColor Yellow
        Start-Sleep -Seconds 3
    }
} finally {
    # 이 스크립트가 연 SSH 터널만 닫는다
    if ($ssh -and -not $ssh.HasExited) { $ssh.Kill() }
}
