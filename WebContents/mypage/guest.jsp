<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*,java.util.*,my.util.*,my.dao.*,my.model.*" %>
<%@ include file="/inc/loginCheck.jsp" %>
<%@ include file="/inc/header.jsp" %>
<%--
	투숙객 관리 : 함께 묵는 사람(가족, 친구 ...)을 등록해 두면
	결제 화면에서 골라서 투숙객 이름과 연락처를 바로 채울 수 있다.
--%>
<%
	Connection conn = ConnectionProvider.getConnection();
	List<Guest> guestList = null;
	try {
		guestList = new GuestDao().selectByUser(conn, loginId);
	} finally {
		JdbcUtil.close(conn);
	}
%>
<c:set var="guestList" value="<%= guestList %>"/>
<div class="container">
	<h2 class="page-title">투숙객 관리</h2>
	<div class="tabs">
		<a href="myPage.jsp">예약 · 리뷰</a>
		<a href="coupon.jsp">쿠폰함</a>
		<a class="on" href="guest.jsp">투숙객</a>
		<a href="../qna/qnaList.jsp">1:1 문의</a>
		<a href="../member/memberUpdateForm.jsp">회원 정보 수정</a>
	</div>

	<div class="box">
		<h3>투숙객 등록</h3>
		<p class="muted" style="margin-top:-6px;">자주 함께 묵는 분을 등록해 두면 예약할 때 골라서 바로 불러올 수 있습니다. (최대 10명)</p>
		<form action="guestSave.jsp" method="post" class="guest-form" onsubmit="return checkForm(this)">
			<input type="text" name="name" placeholder="이름" maxlength="50">
			<input type="text" name="phone" placeholder="연락처 010-0000-0000" maxlength="20">
			<select name="relation">
				<option>가족</option><option>배우자</option><option>친구</option><option>동료</option><option>기타</option>
			</select>
			<input type="submit" class="btn btn-gold" value="등록">
		</form>
	</div>

	<div class="box">
		<h3>등록한 투숙객 (${guestList.size()}명)</h3>
		<table class="list">
			<tr><th>이름</th><th>연락처</th><th>관계</th><th>관리</th></tr>
			<c:if test="${empty guestList}">
				<tr><td colspan="4">등록한 투숙객이 없습니다.</td></tr>
			</c:if>
			<c:forEach var="g" items="${guestList}">
				<tr>
					<td><c:out value="${g.name}"/></td>
					<td><c:out value="${g.phone}"/></td>
					<td>${g.relation}</td>
					<td><a class="btn btn-small btn-red" href="guestDelete.jsp?guestId=${g.guestId}" onclick="return confirm('삭제하시겠습니까?')">삭제</a></td>
				</tr>
			</c:forEach>
		</table>
	</div>
</div>
<script>
	function checkForm(f) {
		if (f.name.value.trim() == "" || f.phone.value.trim() == "") {
			alert("이름과 연락처를 입력하세요.");
			return false;
		}
		return true;
	}
</script>
<%@ include file="/inc/footer.jsp" %>
