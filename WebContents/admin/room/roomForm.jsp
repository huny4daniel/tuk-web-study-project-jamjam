<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*,my.util.*,my.dao.*,my.model.*" %>
<%@ include file="/inc/adminHeader.jsp" %>
<%--
	객실 등록 / 수정 공용 폼
	  roomForm.jsp            -> 빈 폼 (등록)
	  roomForm.jsp?roomId=3   -> 3번 객실 정보가 채워진 폼 (수정)
--%>
<%
	String roomIdStr = request.getParameter("roomId");
	Room room = new Room();      // 등록일 때는 빈 객체
	if (roomIdStr != null) {
		Connection conn = ConnectionProvider.getConnection();
		try {
			room = new RoomDao().selectById(conn, Integer.parseInt(roomIdStr));
		} finally {
			JdbcUtil.close(conn);
		}
	}
%>
<c:set var="room" value="<%= room %>"/>
<c:set var="isEdit" value="<%= roomIdStr != null %>"/>

<h2 class="page-title">${isEdit ? '객실 수정' : '새 객실 등록'}</h2>
<div class="box" style="max-width:800px;">
	<%-- 사진 파일을 보내려면 enctype="multipart/form-data" 가 꼭 필요 (수업 movieuploadform 과 같음) --%>
	<form action="roomSave.jsp" method="post" enctype="multipart/form-data" onsubmit="return checkForm(this)">
		<input type="hidden" name="roomId" value="${room.roomId}">
		<table class="form">
			<tr><th>객실 유형</th><td><input type="text" name="roomType" value="${room.roomType}" placeholder="예) 디럭스 오션뷰"></td></tr>
			<tr><th>호실</th><td><input type="text" name="roomNo" value="${room.roomNo}" placeholder="예) 502호"></td></tr>
			<tr><th>객실 크기 (평)</th><td><input type="number" name="roomSize" min="1" value="${isEdit ? room.roomSize : ''}" placeholder="예) 12"></td></tr>
			<tr><th>1박 정가 (원)</th><td><input type="number" name="price" value="${isEdit ? room.price : ''}"></td></tr>
			<tr><th>객실 할인율 (%)</th><td><input type="number" name="discountRate" min="0" max="90" value="${room.discountRate}"> <span class="muted">0이면 할인 없음</span></td></tr>
			<tr><th>최대 인원</th><td><input type="number" name="capacity" min="1" value="${isEdit ? room.capacity : 2}"></td></tr>
			<tr><th>기준 인원</th><td><input type="number" name="baseGuests" min="1" value="${isEdit ? room.baseGuests : 2}"> <span class="muted">이 인원까지는 기본 요금</span></td></tr>
			<tr><th>1인 추가 요금 (원)</th><td><input type="number" name="extraPrice" min="0" step="1000" value="${isEdit ? room.extraPrice : 20000}"> <span class="muted">기준 인원을 넘는 1명당 1박 요금, 0이면 추가 요금 없음</span></td></tr>
			<tr><th>침대 수</th><td><input type="number" name="bedCount" min="1" value="${isEdit ? room.bedCount : 1}"></td></tr>
			<tr><th>옵션</th>
				<td>
					<label><input type="checkbox" name="breakfast" value="1" ${room.breakfast == 1 ? 'checked' : ''}> 조식 포함</label>&nbsp;&nbsp;
					<label><input type="checkbox" name="pet" value="1" ${room.pet == 1 ? 'checked' : ''}> 반려동물 동반 가능</label>
				</td>
			</tr>
			<tr><th>전망</th>
				<td>
					<select name="viewType">
						<option ${room.viewType == '오션뷰' ? 'selected' : ''}>오션뷰</option>
						<option ${room.viewType == '시티뷰' ? 'selected' : ''}>시티뷰</option>
						<option ${room.viewType == '파크뷰' ? 'selected' : ''}>파크뷰</option>
					</select>
				</td>
			</tr>
			<tr><th>편의시설</th><td><input type="text" name="amenities" class="full" value="${room.amenities}" placeholder="쉼표로 구분 예) WiFi,TV,욕조,거실"></td></tr>
			<tr><th>객실 설명</th><td><textarea name="description"><c:out value="${room.description}"/></textarea></td></tr>
			<tr><th>사진</th>
				<td>
					<c:if test="${isEdit}">
						<img src="<%= ctx %>/room/photo.jsp?roomId=${room.roomId}" width="160" style="border-radius:4px;"><br>
						<span class="muted">새 파일을 고르지 않으면 지금 사진이 그대로 유지됩니다.</span><br>
					</c:if>
					<input type="file" name="photo" accept="image/*"><br>
					<span class="muted">사진을 올리지 않으면 객실 유형·전망에 맞는 기본 사진(images/rooms)이 자동으로 나옵니다.</span>
					<c:if test="${isEdit}">
						<br><label><input type="checkbox" name="photoReset" value="1"> 올린 사진을 지우고 기본 사진 쓰기</label>
					</c:if>
				</td>
			</tr>
		</table>
		<p style="margin-top:20px;">
			<input type="submit" class="btn btn-gold" value="${isEdit ? '수정 완료' : '등록하기'}">
			<a class="btn btn-gray" href="roomList.jsp">취소</a>
		</p>
	</form>
</div>
<script>
	function checkForm(f) {
		if (f.roomType.value == "" || f.roomNo.value == "" || f.price.value == "" || f.roomSize.value == "") {
			alert("객실 유형, 호실, 크기, 가격은 꼭 입력해야 합니다.");
			return false;
		}
		return true;
	}
</script>
<%@ include file="/inc/adminFooter.jsp" %>
