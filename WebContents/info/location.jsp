<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/inc/header.jsp" %>
<%-- 오시는 길 (DB 없이 보여주기만 하는 정적 페이지) --%>
<div class="container">
	<h2 class="page-title">오시는 길</h2>

	<!-- 구글 지도 퍼가기 : q= 뒤의 검색어 위치를 보여준다 (API 키 필요 없음) -->
	<iframe class="map" src="https://maps.google.com/maps?q=%EB%B0%B0%EA%B3%A7%ED%95%9C%EC%9A%B8%EA%B3%B5%EC%9B%90&z=15&output=embed" loading="lazy"></iframe>

	<div class="box" style="margin-top:20px;">
		<h3>호텔 잠잠</h3>
		경기도 시흥시 배곧동 (가상 주소) · 대표전화 031-000-0000<br>
		<span class="muted">체크인 15:00 / 체크아웃 11:00</span>
	</div>

	<div class="info-grid">
		<div class="item">
			<div class="tag">SUBWAY</div>
			<h3>지하철</h3>
			수인분당선 <b>오이도역</b> 하차 → 2번 출구에서 택시 약 10분<br>
			4호선 <b>정왕역</b> 하차 → 버스 환승 약 20분
		</div>
		<div class="item">
			<div class="tag">BUS</div>
			<h3>버스</h3>
			배곧신도시 방면 시내버스 이용 → <b>배곧한울공원</b> 정류장 하차 후 도보 5분<br>
			<span class="muted">(노선 정보는 예시입니다)</span>
		</div>
		<div class="item">
			<div class="tag">CAR</div>
			<h3>자가용</h3>
			서해안고속도로 / 수도권제1순환선 이용 → 배곧신도시 방면<br>
			<b>투숙객 지하 주차장 무료</b> (1객실 1대)
		</div>
	</div>
</div>
<%@ include file="/inc/footer.jsp" %>
