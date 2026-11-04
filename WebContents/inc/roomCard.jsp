<%@ page pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%--
	객실 카드 한 장 (메인 index.jsp 와 객실 목록 roomList.jsp 에서 같이 씀)
	<c:forEach var="room" ...> 안에서 include 하면 ${room} 을 그대로 쓸 수 있다.
	(조각 파일이라 ctx 변수 대신 ${pageContext.request.contextPath} 로 /hotel 같은 주소 앞부분을 씀)
	상세 페이지로 갈 때 검색한 날짜/인원(param)도 같이 넘겨서 예약 폼에 미리 채워지게 함
--%>
<div class="card">
	<a href="${pageContext.request.contextPath}/room/roomDetail.jsp?roomId=${room.roomId}&checkIn=${param.checkIn}&checkOut=${param.checkOut}&guests=${param.guests}">
		<div class="photo"><img src="${pageContext.request.contextPath}/room/photo.jsp?roomId=${room.roomId}" alt="${room.roomType}"></div>
		<div class="body">
			<div class="type">ROOM ${room.roomNo}</div>
			<div class="name">${room.roomType}</div>
			<div class="info">
				최대 ${room.capacity}인 · 침대 ${room.bedCount}개 ·
				<c:if test="${room.reviewCount == 0}"><span class="new">NEW</span></c:if>
				<c:if test="${room.reviewCount > 0}"><span class="stars">★</span> <fmt:formatNumber value="${room.avgRating}" pattern="0.0"/> <span class="muted">(${room.reviewCount})</span></c:if>
			</div>
			<div class="tags">
				<c:if test="${room.breakfast == 1}"><span class="badge badge-gold">조식 포함</span></c:if>
				<c:if test="${room.pet == 1}"><span class="badge badge-green">반려동물</span></c:if>
				<c:if test="${room.resCount >= 2}"><span class="badge badge-red">인기</span></c:if>
			</div>
			<div class="price">
				<c:if test="${room.discountRate > 0}">
					<span class="origin"><fmt:formatNumber value="${room.price}" pattern="#,###"/>원</span>
					<span class="rate">${room.discountRate}%</span>
				</c:if>
				<span class="sale"><fmt:formatNumber value="${room.salePrice}" pattern="#,###"/>원</span>
				<span class="unit">/ 1박</span>
			</div>
		</div>
	</a>
</div>
