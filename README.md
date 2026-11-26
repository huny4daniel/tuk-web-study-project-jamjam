# 호텔 잠잠 (HOTEL JAMJAM) - 단일 호텔 공식 예약 사이트

웹프로그래밍응용 텀프로젝트 / 팀 잠 좀 자자

중개 플랫폼이 아니라 **호텔 하나가 직접 운영하는 공식 예약 사이트**입니다.
역할은 **관리자(호텔, 아이디 admin)** 와 **이용자(일반 회원)** 둘이고, 화면도 따로 나뉩니다.

---

## 1. 실행 방법

1. **DB 만들기** : HeidiSQL로 접속(root / 12345)해서 아래 중 하나를 열고 전체 실행(F9)
   - `db/hotel.sql` : 객실 50실·15종(2~10층) + 테이블 11개 + 샘플 데이터(테스트 계정, 객실 등) → **개발·발표용은 이것**
   - `db/hotel_schema.sql` : 테이블 구조만 (데이터 없음) → 빈 DB가 필요한 다른 서버용
   - 둘 다 `hotel` 데이터베이스를 새로 만듭니다 (이미 있으면 지우고 다시 만듦)
2. **이클립스로 가져오기** : File → Import → General → Existing Projects into Workspace → `hotel` 폴더 선택
3. **실행** : 프로젝트 우클릭 → Run As → Run on Server (Tomcat v9.0)
4. 브라우저 주소 : `http://localhost:8080/hotel/`

**이클립스 없이 배포 (`deploy.bat`)** : 프로젝트 폴더의 `deploy.bat` 을 더블클릭하면
Tomcat 경로 입력 → 자바 컴파일 → `hotel.war` 생성 → 실행 중인 Tomcat 종료 → `webapps` 에 war 복사 → Tomcat 시작 까지 한 번에 합니다.
- 필요한 것 : Tomcat 9 (zip 을 푼 폴더), Java 17 이상. JDK 는 없어도 됩니다 (Tomcat 에 들어 있는 컴파일러 `lib/ecj-*.jar` 로 컴파일).
- 처음 실행하면 Tomcat 폴더 경로를 묻습니다 (창에 폴더를 끌어다 놓아도 됨). 입력한 경로는 `deploy.local.txt` 에 저장돼 다음부터는 Enter 만 누르면 됩니다 (git 에 안 올라감).
- Java 는 `JAVA_HOME` → `JRE_HOME` → PATH 의 `java` 순서로 자동으로 찾습니다.
- 실제 작업은 `deploy.ps1` 이 하고, `deploy.bat` 은 그것을 실행하는 껍데기입니다 (한글이 든 bat 파일은 cmd 가 잘못 읽는 문제가 있어서).
- 이클립스에서 같은 8080 포트로 서버를 띄워 놓았다면 먼저 끄고 실행하세요. MySQL(hotel DB)도 켜져 있어야 합니다.
- 작업 파일은 `build/deploy/` 에 생깁니다 (git 에 올라가지 않음).

| 테스트 계정 | 아이디 / 비밀번호 | 비고 |
|---|---|---|
| 관리자 | admin / 1234 | 관리자 화면만 사용 (이용자 화면에 들어가면 관리자 대시보드로 이동) |
| 이용자 | user1 / 1234 | 지난 숙박(리뷰 작성 가능), 앞으로의 예약이 들어 있음 |
| 이용자 | user2 / 1234 | |

쿠폰(디지털 쿠폰함) : user1 은 `WELCOME10`(사용 가능)·`WINTER20`(12월부터)·`EXPIRED5`(만료), 쿠폰함에서 `OCEAN15` 를 받을 수 있음

---

## 2. 구조 (수업 pro0928 프로젝트와 같은 방식)

```
hotel/
├─ db/hotel.sql                  DB 테이블 + 샘플 데이터 (객실 사진은 비워 둠 → 기본 사진 사용)
├─ db/hotel_schema.sql           DB 구조만 (빈 테이블)
├─ db/breakfast.sql              쓰고 있는 DB 에 조식 추가 기능만 추가
├─ db/pay_card.sql               쓰고 있는 DB 에 결제수단 기능만 추가
├─ src/main/java/
│   ├─ pool.jocl                 DB 접속 정보 (수업과 동일, DB 이름만 hotel)
│   └─ my/
│       ├─ util/                 ConnectionProvider, DBCPInit, JdbcUtil  (수업 파일 그대로)
│       ├─ model/                테이블 한 줄을 담는 클래스 (Member, Room, Reservation ...)
│       ├─ ai/                   Ollama AI 연결 (수업 OllamaClient 와 같은 방식)
│       └─ dao/                  SQL 을 실행하는 클래스 (MemberDao, RoomDao ...)
└─ WebContents/
    ├─ css/style.css             전체 디자인 (파일 하나)
    ├─ inc/                      공통 조각 (include 해서 씀)
    │   ├─ header.jsp / footer.jsp            이용자 화면 위/아래
    │   ├─ adminHeader.jsp / adminFooter.jsp  관리자 화면 위/아래 (왼쪽 메뉴 레이아웃)
    │   ├─ loginCheck.jsp / adminCheck.jsp    로그인/관리자 검사
    │   ├─ roomCard.jsp                       객실 카드 한 장
    │   ├─ kakaoMap.jsp                       카카오 지도 SDK + 호텔 좌표 + 길찾기 함수
    │   ├─ reserveCheck.jsp                   예약 검사 + 금액 계산 (결제 화면과 예약 처리가 같이 씀)
    │   └─ translate.jsp                      영어 화면 번역 스크립트
    ├─ index.jsp                 메인
    ├─ member/                   회원가입, 아이디 중복확인, 로그인/로그아웃, 정보 수정, 회원 탈퇴
    ├─ room/                     객실 목록(검색·필터·정렬·페이징), 객실 상세
    ├─ reserve/                  결제 화면(payForm), 예약 처리, 예약 확인서(resDetail), 예약 취소
    ├─ mypage/                   마이페이지 (내 예약, 내 리뷰, 쿠폰함, 투숙객, 결제수단)
    ├─ review/                   리뷰 쓰기 폼 / 등록 처리
    ├─ qna/                      1:1 문의 목록·작성 / 등록 처리
    ├─ info/                     오시는 길, 주변 즐길거리
    ├─ chat/                     AI 상담 챗봇
    ├─ faq/                      자주 묻는 질문
    ├─ lang/                     언어 바꾸기, 영어 번역 처리(JSON)
    ├─ admin/                    관리자 화면 (기능별 하위 폴더)
    │   ├─ index.jsp             대시보드
    │   ├─ room/                 객실 등록·수정·삭제
    │   ├─ reservation/          예약 현황, 예약 취소
    │   ├─ coupon/               할인 쿠폰
    │   ├─ qna/                  1:1 문의 답변
    │   ├─ faq/                  자주 묻는 질문 등록·수정·삭제
    │   ├─ ai/                   AI 도우미 (요청 → SQL 작성 → 확인 후 실행)
    │   ├─ review/               리뷰 관리
    │   └─ member/               회원 목록
    └─ images/                   메인 배경, 기본 그림(noimage.svg)
        └─ rooms/                객실 유형-전망별 기본 사진 (예 : deluxe-city.png)
```

이용자 폴더(room, reserve, review, qna, member)와 관리자 폴더(admin/room, admin/reservation, admin/review, admin/qna, admin/member)는 같은 기능끼리 이름을 맞춰 두었습니다.

**모든 페이지는 같은 흐름**으로 되어 있습니다 (Model 1 방식, 수업과 동일).

```
JSP (화면)  ──>  DAO (SQL 실행)  ──>  MySQL
   ↑                │
   └── Model 객체 ──┘  (DB 결과를 담아서 돌려줌)
```

```jsp
<%
    Connection conn = ConnectionProvider.getConnection();   // ① 연결 얻기
    try {
        list = new RoomDao().selectAll(conn);                 // ② DAO 로 DB 작업
    } finally {
        JdbcUtil.close(conn);                                 // ③ 연결은 JSP 에서 마지막에 한 번만 닫기
    }
%>
<c:set var="list" value="<%= list %>"/>                       <%-- ④ JSTL 로 화면에 출력 --%>
<c:forEach var="room" items="${list}"> ${room.roomType} </c:forEach>
```

- **화면 페이지** (xxxList.jsp, xxxForm.jsp) : DB에서 읽어 와서 보여줌
- **처리 페이지** (join.jsp, reserve.jsp, cancel.jsp ...) : 화면 없이 DB만 바꾸고 `alert` 띄운 뒤 이동 (수업 login.jsp 방식)
- 수업과 다른 점 하나 : DAO 안에서 Connection 을 닫지 않습니다. 한 페이지에서 DAO 를 여러 번 불러도 같은 연결을 쓰기 위해서입니다.

---

## 3. 테이블

| 테이블 | 내용 | 핵심 컬럼 |
|---|---|---|
| member | 회원 | userId (admin 이면 관리자) |
| room | 객실 | roomType, roomNo, roomSize(평, 화면에는 ㎡ 도 같이 표시), viewType(전망 : 오션뷰/시티뷰/파크뷰), price, discountRate(객실 할인율), capacity(최대 인원), baseGuests(기준 인원), extraPrice(1인 추가 요금), bedCount, breakfast, pet, amenities, photo(LONGBLOB), photoType, **avgRating, reviewCount, resCount**(수업 freq 처럼 update 로 갱신) |
| reservation | 예약 | roomId, **roomType, roomNo**(예약할 때 같이 저장 → join 불필요), userId, checkIn, checkOut, totalPrice, couponCode, payMethod, payDetail(카드사·할부, 입금자명 등), requestNote(고객 요청사항), guestName·guestPhone(실제 투숙객), status('예약완료'/'취소'), **reviewed**(리뷰 썼으면 1) |
| review | 리뷰 | resId(예약 1건당 1개), roomId, roomType, rating(1~5), content |
| coupon | 쿠폰 종류 | couponCode, couponName, discountRate, startDate ~ endDate, issueType(가입축하/다운로드/관리자지급) |
| member_coupon | 회원 쿠폰함 (디지털 쿠폰) | userId, couponCode + 받을 때 복사한 couponName·discountRate·기간(join 불필요), used, usedResId |
| guest | 회원이 등록한 투숙객 | userId(등록한 회원), name, phone, relation(가족/배우자/친구/동료/기타) |
| pay_card | 회원이 등록한 결제수단 (모의) | userId(등록한 회원), cardCompany, cardName(별칭), last4(끝 4자리만), isDefault(기본 카드) |
| qna | 1:1 문의 | title, content, answer(NULL 이면 답변 대기) |
| faq | 자주 묻는 질문 | category(예약·결제/객실/시설·서비스/회원), question, answer |
| translation | 영어 번역 캐시 | ko(화면 한글 문장, PK), en(영어). 메뉴·버튼 등 기본 문구는 미리 넣어 두고, 나머지는 처음 볼 때 Ollama 가 번역해서 추가 |

---

## 4. 계획서 기능 ↔ 파일

| 계획서 항목 | 어디서 | 핵심 원리 |
|---|---|---|
| 1) 회원 관리 | member/*, inc/loginCheck.jsp, inc/adminCheck.jsp | 로그인 성공 시 `session.setAttribute("LOGIN", 아이디)`. 아이디가 admin 이면 관리자. 관리자는 header.jsp·loginCheck.jsp 에서 관리자 대시보드로 보내서 이용자 화면을 쓰지 않음 |
| 2) 객실 관리 | admin/room/roomList, roomForm, roomSave, roomDelete | 등록·수정 폼 하나를 같이 씀. 사진은 cos.jar 로 받아 byte 배열로 읽어서 **DB에 저장** |
| 객실 사진 출력 | room/photo.jsp, RoomDao.selectPhoto(), Room.getTypeImage()/getViewImage() | `<img src=".../room/photo.jsp?roomId=3">` → 관리자가 올린 사진이 DB 에 있으면 그 바이트를 그대로 내보내고, 없으면 유형·전망에 맞는 `images/rooms/유형-전망.png` 로 보냄(그 전망 그림이 없으면 같은 유형 다른 전망, 모르는 유형이면 noimage.svg) |
| 3) 객실 조회·검색 | room/roomList.jsp, RoomDao.WHERE / setSearch() | ? 10개짜리 고정 SQL 하나. 조건을 안 고르면 항상 참이 되는 값을 넣음 (예: `breakfast >= 0`). 날짜를 넣으면 그 기간에 예약된 객실은 `not in` 으로 뺌 |
| SOLD OUT 표시 | room/roomList.jsp, inc/roomCard.jsp, ReservationDao.selectOverlap(), Room.addBooked() | 날짜를 넣으면 그 기간과 겹치는 예약을 읽어 JSP for 문으로 같은 객실에 예약 기간을 붙임 → 카드에 SOLD OUT + 마감 기간. [예약 가능한 객실만] 을 체크하면 기존처럼 `not in` 으로 숨김 |
| 예약 현황 달력 | room/roomDetail.jsp, ReservationDao.selectBookedByRoom() | 객실의 앞으로의 예약을 JS 배열로 넘겨 두 달 달력을 그림. 예약된 밤은 줄 긋기, 날짜를 누르면 체크인 → 체크아웃 순서로 예약 폼에 들어감 |
| 페이징 | RoomDao.getRoomList(), RoomListView | 수업 catalogPaging 과 같은 `limit ?, ?` 방식 |
| 뷰(전망) 추천 | index.jsp 의 VIEW GUIDE, RoomDao.selectBestByView() | 전망별 설명·추천 시간대와 그 전망에서 평점이 가장 높은 객실을 추천. 객실 목록 필터에 전망(viewType like ?, 안 고르면 '%') 추가 |
| 4) 정렬 | RoomDao.makeOrderBy() | 가격 / 평점 / 인기(예약 수) 컬럼으로 order by. 예약 수는 `updateResCount()`(수업 updateFreq 와 같음), 평점은 `addRating()` 으로 갱신 |
| 5) 예약 + 중복 방지 | reserve/payForm.jsp → reserve.jsp → resDetail.jsp, inc/reserveCheck.jsp, ReservationDao.countOverlap() | 결제 화면과 처리 페이지가 같은 검사·금액 계산 조각(reserveCheck)을 include → 화면 금액과 저장 금액이 항상 같고, 처리 페이지에서 한 번 더 검사. 모의 결제(카드사·할부 / 계좌이체 입금자 / 현장결제)와 취소 규정 동의.  겹치는 조건 : `기존 체크인 < 새 체크아웃 AND 기존 체크아웃 > 새 체크인`. 같은 날 체크아웃·체크인은 허용 |
| 예약 취소 | reserve/cancel.jsp (이용자), admin/reservation/resCancel.jsp (관리자) | 이용자는 체크인 전까지만 취소 가능 |
| 디지털 쿠폰 | mypage/coupon.jsp(쿠폰함·받기), couponDown.jsp, admin/coupon/couponIssue.jsp, MemberCouponDao, inc/reserveCheck.jsp | 쿠폰 번호 입력 대신 쿠폰함에서 고름. 가입 시 자동 지급 / 쿠폰함에서 다운로드 / 관리자 지급(개인·전체). 결제 시 본인·미사용·기간 재검사 → 예약하면 used=1, 예약 취소하면 쿠폰 반환 |
| 투숙객 등록 | mypage/guest.jsp(+guestSave, guestDelete), reserve/payForm.jsp, GuestDao | 마이페이지에 투숙객을 등록(최대 10명) → 결제 화면에서 본인/등록 투숙객/직접 입력을 고르면 이름·연락처가 채워짐. 직접 입력한 투숙객은 [저장] 체크 시 목록에 추가. 예약에 투숙객 이름·연락처 저장, 확인서와 관리자 화면에 표시. 회원 탈퇴 시 함께 삭제 |
| 조식 추가 | reserve/payForm.jsp [추가 옵션], inc/reserveCheck.jsp, Room.BREAKFAST_PRICE, admin/index.jsp | 조식 미포함 객실은 결제 화면에서 조식 인원(0~투숙 인원)을 골라 1인 1박 20,000원에 추가. 금액은 reserveCheck 에서 계산(쿠폰은 객실 요금에만 적용)해 reservation.breakfastCount / breakfastPrice 에 저장. 확인서·마이페이지·관리자 예약 목록에 표시, 대시보드에 오늘 아침 조식 인원. 기존 DB 에는 db/breakfast.sql 실행 |
| 결제 카드 등록 | mypage/card.jsp(+cardSave, cardDefault, cardDelete), reserve/payForm.jsp, reserve.jsp, PayCardDao | 마이페이지에 카드를 등록(최대 5장, 첫 카드는 자동으로 기본) → 결제 화면에서 등록 카드(기본 카드가 먼저 선택됨)를 골라 [결제하기]. 본인 카드인지 서버에서 확인. [다른 카드]는 카드사와 카드 번호를 직접 입력. 모의 결제라 카드 번호는 끝 4자리만 서버로 보내고 저장. 회원 탈퇴 시 함께 삭제. 기존 DB 에는 db/pay_card.sql 실행 |
| 고객 요청사항 | reserve/payForm.jsp, reserve.jsp, resDetail.jsp, admin/index.jsp, admin/reservation/reservationList.jsp | 결제 화면에서 자주 쓰는 요청 버튼 + 직접 입력 → reservation.requestNote 에 저장, 확인서와 관리자 화면(대시보드 오늘 체크인, 예약 관리)에 표시 |
| 6) 할인 | 객실 할인율(room.discountRate) + 디지털 쿠폰(coupon → member_coupon) | 금액 = 1박 요금 × 박 수 × (100 − 쿠폰 할인율) / 100 |
| 인원별 요금 | Room.getNightPrice(), reserve/reserve.jsp, roomDetail.jsp 의 nightPrice() | 1박 요금 = 객실 할인가 + (인원 − 기준 인원, 0 미만이면 0) × 1인 추가 요금 |
| 7) 리뷰 | review/reviewForm.jsp, reviewWrite.jsp | 체크아웃이 지난 '예약완료' 예약에만, 1건당 1번(reviewed 컬럼). 리뷰 저장 → reviewed=1 → 객실 평균 갱신 |
| 예약 상태 표시 | Reservation.java 의 getStatusLabel(), isCancelable(), isReviewable() | 상태 계산은 Java if 문으로, JSP 에서는 `${res.statusLabel}`, `<c:if test="${res.cancelable}">` 만 씀 |
| 회원 탈퇴 | member/withdrawForm.jsp → withdraw.jsp, MemberDao.delete(), ReservationDao.countActiveByUser() | 비밀번호 재확인 + 동의. 이용 예정 예약이 있으면 탈퇴 불가. 회원 정보만 삭제하고 예약·리뷰·문의 기록은 남김 |
| 자주 묻는 질문 | faq/faqList.jsp, admin/faq/*, FaqDao | 분류 탭(category like ?, 안 고르면 '%') + details/summary 로 펼치기. 관리자가 등록·수정·삭제, 챗봇 프롬프트에도 들어감 |
| AI 상담 챗봇 | chat/chatbot.jsp, my/ai/HotelChatbot.java, my/ai/OllamaClient.java | 수업 OllamaClient 그대로(gson, localhost:11435, gemma3:12b). 호텔 안내 + DB 객실 목록 + 최근 대화 6줄 + 질문을 프롬프트로 보냄. 대화는 세션(CHAT)에 저장, Ollama 가 꺼져 있으면 1:1 문의 안내 |
| 관리자 AI 도우미 | admin/ai/aiConsole.jsp, my/ai/AdminAi.java | 우리말 요청 → AI 가 테이블 구조를 보고 SQL 한 문장 + 설명 작성(실행 안 함) → 관리자가 확인·수정 후 [실행]. 실행 전 checkSql() 로 select/insert/update/delete 한 문장만, where 없는 update/delete·drop 등·password/photo 컬럼·pay_card 테이블·select * 차단, 20행 넘게 바뀌면 rollback. 실행 기록은 세션(AI_LOG) |
| 영어 화면 | header.jsp 의 KO/EN, lang/setLang.jsp, inc/translate.jsp, lang/translate.jsp, my/ai/Translator.java | 세션 LANG=en 이면 footer 에서 번역 스크립트 실행 → 화면의 한글을 모아 40개씩 서버로 → 번역 캐시(DB) 확인 → 없는 것만 Ollama 로 한 번에(JSON 배열) 번역해 저장. 가격·평수·호실 같은 숫자 문구는 스크립트 규칙으로 바로 변환. 챗봇은 영어로 답함. (자바스크립트 alert 문구와 관리자 화면은 번역하지 않음) |
| 8) 마이페이지 | mypage/myPage.jsp, member/memberUpdateForm.jsp | 내 예약(상태별 버튼), 내 리뷰, 정보 수정 |
| 9) 관리자 페이지 | admin/*/ (기능별 폴더) | 대시보드, 예약 현황, 쿠폰, 문의 답변, 리뷰 관리, 회원 목록 |
| 추가) 교통편 | info/location.jsp, inc/kakaoMap.jsp | 카카오 지도에 호텔 위치 표시. 교통편을 누르면 브라우저 현재 위치(geolocation)를 출발지로 카카오맵 길찾기(`map.kakao.com/link/by/...`)를 새 창으로 엶 |
| 추가) 주변 체험 | info/tour.jsp | 관광지 / 체험 / 맛집 소개. 카드의 data-lat/data-lng 로 카카오 지도에 마커(수업 restaurant-map.jsp 방식), 카드를 누르면 그 위치로 이동, 탭으로 분류별 마커만 표시 |
| 추가) 상세 필터 | room/roomList.jsp 왼쪽 | 조식, 반려동물, 침대 수, 전망, 편의시설(욕조·주방·테라스·스파욕조·온돌·복층·안마의자·빔프로젝터 ...), 1박 요금(할인가 기준 양쪽 손잡이 슬라이더 + 가격대 버튼 5개, 양 끝은 조건 없음, 최소 > 최대면 서로 바꿈), 정렬, 결제 방법(예약할 때 선택) |
| 객실 종류·옵션 | db/hotel.sql, Room.getBedLabel() | 15종(스탠다드 ~ 로열 스위트, 한실 온돌, 복층 로프트, 스파 스위트 등). 같은 종류도 객실마다 조식 포함(+15,000원)·반려동물 허용·전망이 다를 수 있음. 침대가 없는 온돌 객실은 "온돌 (요)" 로 표시 |

---

## 5. 알아둘 점

- **한글 처리** : POST 를 받는 처리 페이지 맨 위에 `request.setCharacterEncoding("utf-8")`
- **include 변수** : header.jsp 가 `ctx`, `loginId`, `loginName` 변수를 만들기 때문에 header 를 include 한 페이지에서 같은 이름의 변수를 또 만들면 안 됩니다.
- **객실 사진 = 기본 사진 + 관리자가 올린 사진** : 사진을 올리지 않은 객실은 `images/rooms/유형-전망.png` 가 자동으로 나옵니다.
  (객실 유형 → 파일 이름 대응은 Room.getTypeImage(). 새 객실 유형을 만들면 여기에 한 줄, images/rooms 에 그림을 추가)
  관리자 화면 [객실 관리 > 수정]에서 사진을 올리면 room 테이블의 photo(LONGBLOB) 컬럼에 저장되고 그 객실은 올린 사진이 우선합니다.
  올린 사진은 DB 에 있으므로 서버를 Clean 하거나 다른 PC 에서 실행해도 그대로 나오고, [올린 사진을 지우고 기본 사진 쓰기]로 되돌릴 수 있습니다.
  (MySQL 기본 설정상 한 번에 보낼 수 있는 크기 제한이 있으니 사진은 수 MB 이하로 올리는 것이 좋습니다.)
- **사진을 바꾼 뒤 팀원과 공유하려면** : HeidiSQL 에서 hotel DB 를 우클릭 → [데이터베이스를 SQL로 내보내기] 로 덤프해서 넘기면 됩니다.
- **메인 배경** : `images/hero.svg` 를 원하는 사진으로 바꾸고 style.css 의 `.hero` 경로만 고치면 됩니다.
- **디자인 수정** : 색과 글꼴은 `css/style.css` 맨 위 `:root` 변수만 바꾸면 전체에 적용됩니다. JSP 는 드림위버에서 열어 HTML 부분을 편집할 수 있습니다.
- **AI 기능** : 수업과 같은 Ollama 서버(`http://localhost:11435`, 모델 `gemma3:12b`)가 켜져 있어야 답이 나옵니다. 주소·모델은 `my/ai/OllamaClient.java` 맨 위 두 줄만 바꾸면 됩니다. 꺼져 있으면 화면에 연결 실패 안내가 나옵니다.
  - **학교 Ollama 서버 접속 (`ollama.bat`)** : 더블클릭 → 학교 서버 계정(stud08, stud12 등 각자 학번 계정) 입력 → 새로 뜨는 SSH 창에 비밀번호 입력하면 SSH 터널(36443→6443)과 `kubectl port-forward svc/ollama 11435:11434` 가 차례로 열립니다. 창을 켜 둔 동안 연결이 유지되고, 닫으면 둘 다 끊깁니다. 입력한 계정은 `ollama.local.txt` 에 저장돼 다음부터 엔터만 치면 됩니다. (ssh, kubectl, 수업 kubeconfig 필요)
- 비밀번호를 평문으로 저장합니다. 수업 예제 수준이므로 실제 서비스라면 암호화가 필요합니다.
