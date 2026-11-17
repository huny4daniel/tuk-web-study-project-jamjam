<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/inc/header.jsp" %>
<%@ include file="/inc/kakaoMap.jsp" %>
<%-- 오시는 길 (DB 없이 보여주기만 하는 정적 페이지) --%>
<div class="container">
	<span class="eyebrow">LOCATION</span>
	<h2 class="page-title">오시는 길</h2>
	<p class="page-sub">아래 교통편을 누르면 지금 계신 곳에서 호텔까지 카카오맵 길찾기가 열립니다.</p>

	<!-- 카카오 지도가 그려질 자리. 카카오 지도를 못 불러오면 안에 있는 구글 지도가 그대로 보인다 -->
	<div id="map" class="map">
		<iframe class="map" src="https://maps.google.com/maps?q=%EB%B0%B0%EA%B3%A7%ED%95%9C%EC%9A%B8%EA%B3%B5%EC%9B%90&z=15&output=embed" loading="lazy"></iframe>
	</div>

	<div class="box route-box">
		<div>
			<h3>호텔 잠잠</h3>
			경기도 시흥시 배곧동 (가상 주소) · 대표전화 031-000-0000<br>
			<span class="muted">체크인 15:00 / 체크아웃 11:00</span>
		</div>
		<div class="route-btns">
			<button type="button" class="btn btn-gold" onclick="openRoute('traffic')">대중교통 길찾기</button>
			<button type="button" class="btn btn-line" onclick="openRoute('car')">자동차 길찾기</button>
			<button type="button" class="btn btn-line" onclick="openRoute('walk')">도보 길찾기</button>
		</div>
	</div>

	<!-- 교통편 카드 : 누르면 그 이동수단으로 길찾기 -->
	<div class="info-grid">
		<a class="item route" href="javascript:openRoute('traffic')">
			<div class="tag">SUBWAY</div>
			<h3>지하철</h3>
			수인분당선 <b>오이도역</b> 하차 → 2번 출구에서 택시 약 10분<br>
			4호선 <b>정왕역</b> 하차 → 버스 환승 약 20분
			<span class="go">내 위치에서 대중교통 길찾기 →</span>
		</a>
		<a class="item route" href="javascript:openRoute('traffic')">
			<div class="tag">BUS</div>
			<h3>버스</h3>
			배곧신도시 방면 시내버스 이용 → <b>배곧한울공원</b> 정류장 하차 후 도보 5분<br>
			<span class="muted">(노선 정보는 예시입니다)</span>
			<span class="go">내 위치에서 대중교통 길찾기 →</span>
		</a>
		<a class="item route" href="javascript:openRoute('car')">
			<div class="tag">CAR</div>
			<h3>자가용</h3>
			서해안고속도로 / 수도권제1순환선 이용 → 배곧신도시 방면<br>
			<b>투숙객 지하 주차장 무료</b> (1객실 1대)
			<span class="go">내 위치에서 자동차 길찾기 →</span>
		</a>
	</div>
	<p class="muted" style="margin-top:14px;">※ 브라우저가 위치 권한을 물으면 [허용]을 눌러 주세요. 거절하면 카카오맵에서 출발지를 직접 입력할 수 있습니다.</p>
</div>

<script>
	// 카카오 지도에 호텔 위치 표시 (수업 restaurant-map.jsp 와 같은 방식)
	if (kakaoReady()) {
		var mapBox = document.getElementById("map");
		mapBox.innerHTML = "";   // 대신 보여주던 구글 지도 지우기
		var hotelPos = new kakao.maps.LatLng(HOTEL_LAT, HOTEL_LNG);
		var map = new kakao.maps.Map(mapBox, { center: hotelPos, level: 4 });
		var marker = new kakao.maps.Marker({ map: map, position: hotelPos, title: HOTEL_NAME });
		new kakao.maps.InfoWindow({ content: '<div class="map-label">' + HOTEL_NAME + '</div>' }).open(map, marker);
	}
</script>
<%@ include file="/inc/footer.jsp" %>
