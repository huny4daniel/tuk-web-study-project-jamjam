<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/inc/header.jsp" %>
<%-- 주변 즐길거리 (정적 페이지) : 내용은 자유롭게 바꿔서 쓰면 됨 --%>
<div class="container">
	<h2 class="page-title">주변 즐길거리</h2>
	<div class="tabs">
		<a href="#sight">관광지</a>
		<a href="#activity">체험</a>
		<a href="#food">맛집</a>
	</div>

	<h3 id="sight">관광지</h3>
	<div class="info-grid" style="margin-bottom:30px;">
		<div class="item"><div class="tag">차로 10분</div><h3>오이도 빨강등대</h3>서해 바다와 노을을 한눈에 볼 수 있는 오이도의 대표 명소입니다.</div>
		<div class="item"><div class="tag">도보 5분</div><h3>배곧한울공원</h3>바다를 따라 이어진 산책로와 해수체험장이 있는 공원입니다.</div>
		<div class="item"><div class="tag">차로 20분</div><h3>시흥갯골생태공원</h3>내만 갯골과 염전의 흔적을 볼 수 있는 생태공원입니다.</div>
	</div>

	<h3 id="activity">체험</h3>
	<div class="info-grid" style="margin-bottom:30px;">
		<div class="item"><div class="tag">여름 시즌</div><h3>해수 체험장</h3>배곧한울공원의 해수풀에서 아이와 함께 물놀이를 즐길 수 있습니다.</div>
		<div class="item"><div class="tag">사전 예약</div><h3>갯벌 체험</h3>물때에 맞춰 조개 캐기 등 갯벌 체험 프로그램에 참여할 수 있습니다.</div>
		<div class="item"><div class="tag">상시</div><h3>자전거 대여</h3>호텔 프런트에서 자전거를 빌려 해안 산책로를 달려 보세요.</div>
	</div>

	<h3 id="food">맛집</h3>
	<div class="info-grid">
		<div class="item"><div class="tag">해산물</div><h3>오이도 조개구이 거리</h3>바다를 보며 조개구이와 칼국수를 즐길 수 있습니다.</div>
		<div class="item"><div class="tag">회</div><h3>월곶포구</h3>포구에서 바로 들어온 신선한 회를 맛볼 수 있습니다.</div>
		<div class="item"><div class="tag">카페</div><h3>배곧 해안 카페거리</h3>노을이 예쁜 오션뷰 카페들이 모여 있습니다.</div>
	</div>
</div>
<%@ include file="/inc/footer.jsp" %>
