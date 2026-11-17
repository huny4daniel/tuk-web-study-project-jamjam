# 호텔 잠잠 (HOTEL JAMJAM) - 단일 호텔 공식 예약 사이트

웹프로그래밍응용 텀프로젝트 / 팀 잠 좀 자자

중개 플랫폼이 아니라 **호텔 하나가 직접 운영하는 공식 예약 사이트**입니다.
역할은 **관리자(호텔, 아이디 admin)** 와 **이용자(일반 회원)** 둘이고, 화면도 따로 나뉩니다.

---

## 1. 실행 방법

1. **DB 만들기** : HeidiSQL로 접속(root / 12345)해서 아래 중 하나를 열고 전체 실행(F9)
   - `db/hotel.sql` : 테이블 6개 + 샘플 데이터(테스트 계정, 객실, 사진) → **개발·발표용은 이것**
   - `db/hotel_schema.sql` : 테이블 구조만 (데이터 없음) → 빈 DB가 필요한 다른 서버용
   - 둘 다 `hotel` 데이터베이스를 새로 만듭니다 (이미 있으면 지우고 다시 만듦)
2. **이클립스로 가져오기** : File → Import → General → Existing Projects into Workspace → `hotel` 폴더 선택
3. **실행** : 프로젝트 우클릭 → Run As → Run on Server (Tomcat v9.0)
4. 브라우저 주소 : `http://localhost:8080/hotel/`

| 테스트 계정 | 아이디 / 비밀번호 | 비고 |
|---|---|---|
| 관리자 | admin / 1234 | 로그인하면 관리자 화면으로 이동 |
| 이용자 | user1 / 1234 | 지난 숙박(리뷰 작성 가능), 앞으로의 예약이 들어 있음 |
| 이용자 | user2 / 1234 | |

쿠폰 : `WELCOME10`(사용 가능), `WINTER20`(12월부터), `EXPIRED5`(만료, 오류 확인용)

---

## 2. 구조 (수업 pro0928 프로젝트와 같은 방식)

```
hotel/
├─ db/hotel.sql                  DB 테이블 + 샘플 데이터 (샘플 객실 사진 포함)
├─ db/hotel_schema.sql           DB 구조만 (빈 테이블)
├─ db/sample-photos/             샘플 사진 원본 (참고용, 이미 hotel.sql 안에 들어 있음)
├─ src/main/java/
│   ├─ pool.jocl                 DB 접속 정보 (수업과 동일, DB 이름만 hotel)
│   └─ my/
│       ├─ util/                 ConnectionProvider, DBCPInit, JdbcUtil  (수업 파일 그대로)
│       ├─ model/                테이블 한 줄을 담는 클래스 (Member, Room, Reservation ...)
│       └─ dao/                  SQL 을 실행하는 클래스 (MemberDao, RoomDao ...)
└─ WebContents/
    ├─ css/style.css             전체 디자인 (파일 하나)
    ├─ inc/                      공통 조각 (include 해서 씀)
    │   ├─ header.jsp / footer.jsp            이용자 화면 위/아래
    │   ├─ adminHeader.jsp / adminFooter.jsp  관리자 화면 위/아래 (왼쪽 메뉴 레이아웃)
    │   ├─ loginCheck.jsp / adminCheck.jsp    로그인/관리자 검사
    │   ├─ roomCard.jsp                       객실 카드 한 장
    │   └─ kakaoMap.jsp                       카카오 지도 SDK + 호텔 좌표 + 길찾기 함수
    ├─ index.jsp                 메인
    ├─ member/                   회원가입, 아이디 중복확인, 로그인/로그아웃, 정보 수정
    ├─ room/                     객실 목록(검색·필터·정렬·페이징), 객실 상세
    ├─ reserve/                  예약 처리, 예약 취소
    ├─ mypage/                   마이페이지 (내 예약, 내 리뷰)
    ├─ review/                   리뷰 쓰기 폼 / 등록 처리
    ├─ qna/                      1:1 문의 목록·작성 / 등록 처리
    ├─ info/                     오시는 길, 주변 즐길거리
    ├─ admin/                    관리자 화면 (기능별 하위 폴더)
    │   ├─ index.jsp             대시보드
    │   ├─ room/                 객실 등록·수정·삭제
    │   ├─ reservation/          예약 현황, 예약 취소
    │   ├─ coupon/               할인 쿠폰
    │   ├─ qna/                  1:1 문의 답변
    │   ├─ review/               리뷰 관리
    │   └─ member/               회원 목록
    └─ images/                   메인 배경, 기본 그림(사진 없는 객실용)
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
| room | 객실 | roomType, roomNo, price, discountRate(객실 할인율), capacity, bedCount, breakfast, pet, amenities, photo(LONGBLOB), photoType, **avgRating, reviewCount, resCount**(수업 freq 처럼 update 로 갱신) |
| reservation | 예약 | roomId, **roomType, roomNo**(예약할 때 같이 저장 → join 불필요), userId, checkIn, checkOut, totalPrice, couponCode, payMethod, status('예약완료'/'취소'), **reviewed**(리뷰 썼으면 1) |
| review | 리뷰 | resId(예약 1건당 1개), roomId, roomType, rating(1~5), content |
| coupon | 쿠폰 | couponCode, discountRate, startDate ~ endDate |
| qna | 1:1 문의 | title, content, answer(NULL 이면 답변 대기) |

---

## 4. 계획서 기능 ↔ 파일

| 계획서 항목 | 어디서 | 핵심 원리 |
|---|---|---|
| 1) 회원 관리 | member/*, inc/loginCheck.jsp, inc/adminCheck.jsp | 로그인 성공 시 `session.setAttribute("LOGIN", 아이디)`. 아이디가 admin 이면 관리자 |
| 2) 객실 관리 | admin/room/roomList, roomForm, roomSave, roomDelete | 등록·수정 폼 하나를 같이 씀. 사진은 cos.jar 로 받아 byte 배열로 읽어서 **DB에 저장** |
| 객실 사진 출력 | room/photo.jsp, RoomDao.selectPhoto() | `<img src=".../room/photo.jsp?roomId=3">` → DB 의 사진 바이트를 이미지로 그대로 내보냄 |
| 3) 객실 조회·검색 | room/roomList.jsp, RoomDao.WHERE / setSearch() | ? 7개짜리 고정 SQL 하나. 조건을 안 고르면 항상 참이 되는 값을 넣음 (예: `breakfast >= 0`). 날짜를 넣으면 그 기간에 예약된 객실은 `not in` 으로 뺌 |
| 페이징 | RoomDao.getRoomList(), RoomListView | 수업 catalogPaging 과 같은 `limit ?, ?` 방식 |
| 4) 정렬 | RoomDao.makeOrderBy() | 가격 / 평점 / 인기(예약 수) 컬럼으로 order by. 예약 수는 `updateResCount()`(수업 updateFreq 와 같음), 평점은 `addRating()` 으로 갱신 |
| 5) 예약 + 중복 방지 | reserve/reserve.jsp, ReservationDao.countOverlap() | 겹치는 조건 : `기존 체크인 < 새 체크아웃 AND 기존 체크아웃 > 새 체크인`. 같은 날 체크아웃·체크인은 허용 |
| 예약 취소 | reserve/cancel.jsp (이용자), admin/reservation/resCancel.jsp (관리자) | 이용자는 체크인 전까지만 취소 가능 |
| 6) 할인 | 객실 할인율(room.discountRate) + 기간 쿠폰(coupon) | 금액 = 객실 할인가 × 박 수 × (100 − 쿠폰 할인율) / 100 |
| 7) 리뷰 | review/reviewForm.jsp, reviewWrite.jsp | 체크아웃이 지난 '예약완료' 예약에만, 1건당 1번(reviewed 컬럼). 리뷰 저장 → reviewed=1 → 객실 평균 갱신 |
| 예약 상태 표시 | Reservation.java 의 getStatusLabel(), isCancelable(), isReviewable() | 상태 계산은 Java if 문으로, JSP 에서는 `${res.statusLabel}`, `<c:if test="${res.cancelable}">` 만 씀 |
| 8) 마이페이지 | mypage/myPage.jsp, member/memberUpdateForm.jsp | 내 예약(상태별 버튼), 내 리뷰, 정보 수정 |
| 9) 관리자 페이지 | admin/*/ (기능별 폴더) | 대시보드, 예약 현황, 쿠폰, 문의 답변, 리뷰 관리, 회원 목록 |
| 추가) 교통편 | info/location.jsp, inc/kakaoMap.jsp | 카카오 지도에 호텔 위치 표시. 교통편을 누르면 브라우저 현재 위치(geolocation)를 출발지로 카카오맵 길찾기(`map.kakao.com/link/by/...`)를 새 창으로 엶 |
| 추가) 주변 체험 | info/tour.jsp | 관광지 / 체험 / 맛집 소개 |
| 추가) 상세 필터 | room/roomList.jsp 왼쪽 | 조식, 반려동물, 침대 수, 편의시설, 결제 방법(예약할 때 선택) |

---

## 5. 알아둘 점

- **한글 처리** : POST 를 받는 처리 페이지 맨 위에 `request.setCharacterEncoding("utf-8")`
- **include 변수** : header.jsp 가 `ctx`, `loginId`, `loginName` 변수를 만들기 때문에 header 를 include 한 페이지에서 같은 이름의 변수를 또 만들면 안 됩니다.
- **사진은 DB에 저장** : 객실 사진은 파일이 아니라 room 테이블의 photo(LONGBLOB) 컬럼에 들어갑니다.
  그래서 서버를 Clean 하거나 다른 팀원 PC에서 실행해도 hotel.sql 만 실행하면 사진이 그대로 나옵니다.
  지금 들어 있는 사진은 임시 그림이니 관리자 화면 [객실 관리 > 수정]에서 실제 호텔 사진으로 바꾸세요.
  (MySQL 기본 설정상 한 번에 보낼 수 있는 크기 제한이 있으니 사진은 수 MB 이하로 올리는 것이 좋습니다.)
- **사진을 바꾼 뒤 팀원과 공유하려면** : HeidiSQL 에서 hotel DB 를 우클릭 → [데이터베이스를 SQL로 내보내기] 로 덤프해서 넘기면 됩니다.
- **메인 배경** : `images/hero.svg` 를 원하는 사진으로 바꾸고 style.css 의 `.hero` 경로만 고치면 됩니다.
- **디자인 수정** : 색과 글꼴은 `css/style.css` 맨 위 `:root` 변수만 바꾸면 전체에 적용됩니다. JSP 는 드림위버에서 열어 HTML 부분을 편집할 수 있습니다.
- 비밀번호를 평문으로 저장합니다. 수업 예제 수준이므로 실제 서비스라면 암호화가 필요합니다.
