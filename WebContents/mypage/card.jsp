<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*,java.util.*,my.util.*,my.dao.*,my.model.*" %>
<%@ include file="/inc/loginCheck.jsp" %>
<%@ include file="/inc/header.jsp" %>
<%--
	결제수단 관리 : 카드를 등록해 두면 결제 화면에서 골라서 바로 결제할 수 있다. (기본 카드가 먼저 선택됨)
	※ 모의 결제 : 카드번호 전체는 받지 않고 끝 4자리만 받는다.
--%>
<%
	Connection conn = ConnectionProvider.getConnection();
	List<PayCard> cardList = null;
	try {
		cardList = new PayCardDao().selectByUser(conn, loginId);
	} finally {
		JdbcUtil.close(conn);
	}
%>
<c:set var="cardList" value="<%= cardList %>"/>
<c:set var="companies" value="<%= PayCard.COMPANIES %>"/>
<div class="container">
	<h2 class="page-title">결제수단 관리</h2>
	<div class="tabs">
		<a href="myPage.jsp">예약 · 리뷰</a>
		<a href="coupon.jsp">쿠폰함</a>
		<a href="guest.jsp">투숙객</a>
		<a class="on" href="card.jsp">결제수단</a>
		<a href="../qna/qnaList.jsp">1:1 문의</a>
		<a href="../member/memberUpdateForm.jsp">회원 정보 수정</a>
	</div>

	<div class="box">
		<h3>카드 등록</h3>
		<p class="muted" style="margin-top:-10px;">카드를 등록해 두면 결제 화면에서 골라 바로 결제할 수 있습니다. (최대 5장)</p>
		<form action="cardSave.jsp" method="post" class="guest-form" onsubmit="return checkForm(this)">
			<select name="cardCompany">
				<c:forEach var="company" items="${companies}"><option>${company}</option></c:forEach>
			</select>
			<input type="text" name="last4" placeholder="카드번호 끝 4자리" maxlength="4" inputmode="numeric" autocomplete="off">
			<input type="text" name="cardName" placeholder="별칭 (선택)" maxlength="30">
			<input type="submit" class="btn btn-gold" value="등록">
		</form>
		<p class="muted">※ 수업용 모의 결제라서 카드번호 전체, 유효기간, CVC 는 받지 않습니다.</p>
	</div>

	<section class="group" style="margin-top:56px;">
		<div class="group-head"><h3>등록한 카드<span class="count">${cardList.size()}장</span></h3></div>
		<table class="list">
			<tr><th>카드</th><th>별칭</th><th>기본 카드</th><th>관리</th></tr>
			<c:if test="${empty cardList}">
				<tr><td colspan="4">등록한 카드가 없습니다.</td></tr>
			</c:if>
			<c:forEach var="pc" items="${cardList}">
				<tr>
					<td><c:out value="${pc.label}"/></td>
					<td><c:out value="${pc.cardName}"/></td>
					<td>
						<c:choose>
							<c:when test="${pc.defaultCard}"><b>기본</b></c:when>
							<c:otherwise><a class="btn btn-small btn-line" href="cardDefault.jsp?cardId=${pc.cardId}">기본으로 지정</a></c:otherwise>
						</c:choose>
					</td>
					<td><a class="btn btn-small btn-red" href="cardDelete.jsp?cardId=${pc.cardId}" onclick="return confirm('삭제하시겠습니까?')">삭제</a></td>
				</tr>
			</c:forEach>
		</table>
	</section>
</div>
<script>
	function checkForm(f) {
		if (!/^[0-9]{4}$/.test(f.last4.value)) {
			alert("카드번호 끝 4자리를 숫자로 입력하세요.");
			return false;
		}
		return true;
	}
</script>
<%@ include file="/inc/footer.jsp" %>
