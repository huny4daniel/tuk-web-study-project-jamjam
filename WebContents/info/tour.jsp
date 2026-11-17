<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/inc/header.jsp" %>
<%@ include file="/inc/kakaoMap.jsp" %>
<%--
	주변 즐길거리 (정적 페이지) : 내용은 자유롭게 바꿔서 쓰면 됨
	각 카드의 data-lat(위도), data-lng(경도) 값으로 위쪽 지도에 마커를 찍는다.
	(수업 restaurant-map.jsp 에서 article 의 data-lat/data-lng 로 마커를 찍던 방식과 같음)
	장소를 추가하려면 카드 하나를 복사해서 이름, 설명, 좌표만 바꾸면 된다.
	※ 좌표는 대략적인 위치입니다.
--%>
<div class="container">
	<span class="eyebrow">AROUND</span>
	<h2 class="page-title">주변 즐길거리</h2>
	<p class="page-sub">카드를 누르면 지도에서 위치를 보여드립니다. 지도의 마커를 눌러도 이름이 나옵니다.</p>

	<div class="tabs" id="tourTabs">
		<a class="on" href="javascript:showGroup('all')" data-group="all">전체</a>
		<a href="javascript:showGroup('sight')" data-group="sight">관광지</a>
		<a href="javascript:showGroup('activity')" data-group="activity">체험</a>
		<a href="javascript:showGroup('food')" data-group="food">맛집</a>
	</div>

	<div id="map" class="map tour-map"><p class="muted" style="padding:20px;">지도를 불러오는 중입니다...</p></div>

	<h3 class="tour-head" data-group="sight">관광지</h3>
	<div class="info-grid tour-list" data-group="sight">
		<a class="item place" href="#map" data-lat="37.3456" data-lng="126.6874"><div class="tag">차로 10분</div><h3>오이도 빨강등대</h3>서해 바다와 노을을 한눈에 볼 수 있는 오이도의 대표 명소입니다.</a>
		<a class="item place" href="#map" data-lat="37.3736" data-lng="126.7177"><div class="tag">도보 5분</div><h3>배곧한울공원</h3>바다를 따라 이어진 산책로와 해수체험장이 있는 공원입니다.</a>
		<a class="item place" href="#map" data-lat="37.3893" data-lng="126.7795"><div class="tag">차로 20분</div><h3>시흥갯골생태공원</h3>내만 갯골과 염전의 흔적을 볼 수 있는 생태공원입니다.</a>
	</div>

	<h3 class="tour-head" data-group="activity">체험</h3>
	<div class="info-grid tour-list" data-group="activity">
		<a class="item place" href="#map" data-lat="37.3752" data-lng="126.7158"><div class="tag">여름 시즌</div><h3>해수 체험장</h3>배곧한울공원의 해수풀에서 아이와 함께 물놀이를 즐길 수 있습니다.</a>
		<a class="item place" href="#map" data-lat="37.3420" data-lng="126.6850"><div class="tag">사전 예약</div><h3>갯벌 체험</h3>물때에 맞춰 조개 캐기 등 갯벌 체험 프로그램에 참여할 수 있습니다.</a>
		<a class="item place" href="#map" data-lat="37.3697" data-lng="126.7228"><div class="tag">상시</div><h3>자전거 대여</h3>호텔 프런트에서 자전거를 빌려 해안 산책로를 달려 보세요.</a>
	</div>

	<h3 class="tour-head" data-group="food">맛집</h3>
	<div class="info-grid tour-list" data-group="food">
		<a class="item place" href="#map" data-lat="37.3440" data-lng="126.6890"><div class="tag">해산물</div><h3>오이도 조개구이 거리</h3>바다를 보며 조개구이와 칼국수를 즐길 수 있습니다.</a>
		<a class="item place" href="#map" data-lat="37.3905" data-lng="126.7410"><div class="tag">회</div><h3>월곶포구</h3>포구에서 바로 들어온 신선한 회를 맛볼 수 있습니다.</a>
		<a class="item place" href="#map" data-lat="37.3655" data-lng="126.7185"><div class="tag">카페</div><h3>배곧 해안 카페거리</h3>노을이 예쁜 오션뷰 카페들이 모여 있습니다.</a>
	</div>
</div>

<script>
	var places = document.querySelectorAll(".place");   // 장소 카드 전부
	var map = null;
	var popup = null;
	var markers = [];   // places 와 같은 순서로 마커를 담아 둔다

	if (kakaoReady()) {
		var hotelPos = new kakao.maps.LatLng(HOTEL_LAT, HOTEL_LNG);
		map = new kakao.maps.Map(document.getElementById("map"), { center: hotelPos, level: 7 });
		popup = new kakao.maps.InfoWindow({ removable: true });

		// 호텔 위치는 별 모양 마커로 따로 표시 (카카오 기본 제공 이미지)
		var starImage = new kakao.maps.MarkerImage(
				"https://t1.daumcdn.net/localimg/localimages/07/mapapidoc/markerStar.png", new kakao.maps.Size(24, 35));
		var hotelMarker = new kakao.maps.Marker({ map: map, position: hotelPos, title: HOTEL_NAME, image: starImage });
		kakao.maps.event.addListener(hotelMarker, "click", function () { openPopup(hotelMarker, HOTEL_NAME, "숙소"); });

		// 카드마다 마커 하나씩
		var bounds = new kakao.maps.LatLngBounds();
		bounds.extend(hotelPos);
		for (var i = 0; i < places.length; i++) {
			var card = places[i];
			var pos = new kakao.maps.LatLng(Number(card.dataset.lat), Number(card.dataset.lng));
			var marker = new kakao.maps.Marker({ map: map, position: pos, title: card.querySelector("h3").textContent });
			markers.push(marker);
			bounds.extend(pos);
			addMarkerClick(marker, card);
		}
		map.setBounds(bounds);   // 모든 마커가 한 화면에 보이게
	} else {
		document.getElementById("map").innerHTML =
			'<p class="muted" style="padding:20px;">카카오 지도를 불러오지 못했습니다. 인터넷 연결이나 지도 키 설정을 확인하세요.</p>';
	}

	// 마커를 누르면 그 장소 이름 말풍선 (for 문 안에서 바로 함수를 만들면 마지막 카드만 기억해서 따로 뺌)
	function addMarkerClick(marker, card) {
		kakao.maps.event.addListener(marker, "click", function () {
			openPopup(marker, card.querySelector("h3").textContent, card.querySelector(".tag").textContent);
		});
	}

	function openPopup(marker, name, tag) {
		popup.close();
		popup.setContent('<div class="map-label"><b>' + name + '</b> · ' + tag + '</div>');
		popup.open(map, marker);
	}

	// 카드를 누르면 지도를 그 장소로 옮기고 말풍선 열기
	for (var i = 0; i < places.length; i++) {
		places[i].addEventListener("click", function () {
			if (map == null) return;
			var idx = Array.prototype.indexOf.call(places, this);
			map.setLevel(4);
			map.panTo(markers[idx].getPosition());
			openPopup(markers[idx], this.querySelector("h3").textContent, this.querySelector(".tag").textContent);
		});
	}

	// 탭 : 고른 분류의 카드와 마커만 보이기
	function showGroup(group) {
		var tabs = document.querySelectorAll("#tourTabs a");
		for (var i = 0; i < tabs.length; i++) {
			tabs[i].className = (tabs[i].dataset.group == group) ? "on" : "";
		}
		var blocks = document.querySelectorAll(".tour-head, .tour-list");
		for (var i = 0; i < blocks.length; i++) {
			blocks[i].style.display = (group == "all" || blocks[i].dataset.group == group) ? "" : "none";
		}
		if (map == null) return;
		popup.close();
		for (var i = 0; i < places.length; i++) {
			var g = places[i].parentNode.dataset.group;
			markers[i].setMap(group == "all" || g == group ? map : null);
		}
	}
</script>
<%@ include file="/inc/footer.jsp" %>
