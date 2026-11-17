<%@ page pageEncoding="UTF-8" %>
<%--
	카카오 지도 SDK + 호텔 위치 (오시는 길 location.jsp, 주변 즐길거리 tour.jsp 에서 include)
	- 키는 수업 예제(pharmacy.jsp, restaurant-map.jsp)에서 쓰던 카카오 JavaScript 키 그대로
	- 호텔 위치(위도/경도)를 여기 한 곳에만 적어 두고 두 페이지에서 같이 쓴다
	- libraries=services : 장소 검색 기능까지 같이 불러옴 (수업 pharmacy.jsp 와 같음)
--%>
<script src="https://dapi.kakao.com/v2/maps/sdk.js?appkey=6ee560a86c1b43a4626c134569c436be&libraries=services"></script>
<script>
	var HOTEL_NAME = "호텔 잠잠";
	var HOTEL_LAT = 37.3693;    // 위도 (배곧한울공원 앞, 가상 위치)
	var HOTEL_LNG = 126.7236;   // 경도

	// 카카오 지도가 정상적으로 불러와졌는지 (키·도메인 설정이 틀리면 false)
	function kakaoReady() {
		return window.kakao && kakao.maps && kakao.maps.Map;
	}

	// 카카오맵 길찾기 주소 만들기
	//   by : car(자동차) / traffic(대중교통) / walk(도보)
	//   from 위치를 모르면 도착지만 넣은 주소(link/to)를 쓴다 → 카카오맵에서 출발지를 직접 입력
	function routeUrl(by, fromLat, fromLng) {
		var to = encodeURIComponent(HOTEL_NAME) + "," + HOTEL_LAT + "," + HOTEL_LNG;
		if (fromLat == null) {
			return "https://map.kakao.com/link/to/" + to;
		}
		return "https://map.kakao.com/link/by/" + by + "/" + encodeURIComponent("내 위치") + ","
				+ fromLat + "," + fromLng + "/" + to;
	}

	// 브라우저에게 현재 위치를 물어본 뒤 카카오맵 길찾기를 새 창으로 연다
	// (위치 권한을 거절하거나 실패하면 도착지만 정해진 길찾기 화면으로)
	function openRoute(by) {
		// 팝업 차단을 피하려고 클릭하자마자 빈 창부터 열어 두고, 위치를 알면 주소를 넣는다
		var win = window.open("about:blank", "_blank");
		if (!navigator.geolocation) {
			win.location.href = routeUrl(by, null, null);
			return;
		}
		navigator.geolocation.getCurrentPosition(function (pos) {
			win.location.href = routeUrl(by, pos.coords.latitude, pos.coords.longitude);
		}, function () {
			win.location.href = routeUrl(by, null, null);
		}, { timeout: 10000 });
	}
</script>
