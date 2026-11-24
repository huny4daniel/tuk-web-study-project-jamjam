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

	// 내 위치 (findMyPos 로 미리 받아 둔다. 모르면 null)
	var myLat = null;
	var myLng = null;
	var posWaiting = false;   // 위치를 물어보고 아직 답을 기다리는 중인지

	// 페이지가 열릴 때 미리 현재 위치를 물어본다 (오시는 길 location.jsp 에서 부름)
	//   예전에는 버튼을 누른 뒤에 물어봤는데, 그러면
	//   ① 위치 권한 질문이 새로 연 빈 창 뒤(원래 탭)에 숨어서 답을 못 하고 빈 페이지가 계속 남거나
	//   ② PC 는 위치 찾는 데 몇 초씩 걸려서 그동안 빈 페이지로 기다려야 했다
	//   maximumAge : 10분 안에 찾은 위치가 있으면 다시 찾지 않고 그 값을 바로 씀
	function findMyPos() {
		if (!navigator.geolocation) {
			return;
		}
		posWaiting = true;
		navigator.geolocation.getCurrentPosition(function (pos) {
			myLat = pos.coords.latitude;
			myLng = pos.coords.longitude;
			posWaiting = false;
		}, function () {
			posWaiting = false;   // 거절하거나 실패 → 도착지만 정해진 길찾기로
		}, { timeout: 8000, maximumAge: 600000 });
	}

	// 카카오맵 길찾기를 새 창으로 연다
	function openRoute(by) {
		// 위치를 이미 알거나(허용) 모르는 게 확정됐으면(거절·실패) 바로 카카오맵으로
		if (!posWaiting) {
			window.open(routeUrl(by, myLat, myLng), "_blank");
			return;
		}
		// 아직 위치를 찾는 중 : 팝업 차단을 피하려고 클릭하자마자 빈 창부터 열고,
		// 0.1초마다 확인하다가 위치가 오면 바로, 최대 3초가 지나면 도착지만 넣은 길찾기로 보낸다
		var win = window.open("about:blank", "_blank");
		var count = 0;
		var timer = setInterval(function () {
			count++;
			if (!posWaiting || count >= 30) {
				clearInterval(timer);
				if (win) {
					win.location.href = routeUrl(by, myLat, myLng);
				}
			}
		}, 100);
	}
</script>
