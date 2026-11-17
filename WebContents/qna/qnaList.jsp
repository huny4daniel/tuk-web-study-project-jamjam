<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*,java.util.*,my.util.*,my.dao.*,my.model.*" %>
<%@ include file="/inc/loginCheck.jsp" %>
<%@ include file="/inc/header.jsp" %>
<%
	// 1:1 문의 : 위에는 문의 작성 폼, 아래에는 내가 쓴 문의와 답변
	Connection conn = ConnectionProvider.getConnection();
	List<Qna> qnaList = null;
	try {
		qnaList = new QnaDao().selectByUser(conn, loginId);
	} finally {
		JdbcUtil.close(conn);
	}
%>
<c:set var="qnaList" value="<%= qnaList %>"/>

<div class="container">
	<h2 class="page-title">1:1 문의</h2>
	<div class="tabs">
		<a href="../mypage/myPage.jsp">예약 · 리뷰</a>
		<a class="on" href="qnaList.jsp">1:1 문의</a>
		<a href="../member/memberUpdateForm.jsp">회원 정보 수정</a>
	</div>

	<div class="box">
		<h3>문의하기</h3>
		<form action="qnaWrite.jsp" method="post" onsubmit="return checkForm(this)">
			<p><input type="text" name="title" class="full" placeholder="제목"></p>
			<p><textarea name="content" placeholder="궁금한 점을 남겨 주시면 호텔에서 답변해 드립니다."></textarea></p>
			<input type="submit" class="btn btn-gold" value="문의 등록">
		</form>
	</div>

	<div class="box">
		<h3>내 문의 내역</h3>
		<c:if test="${empty qnaList}">
			<p class="muted">문의 내역이 없습니다.</p>
		</c:if>
		<c:forEach var="qna" items="${qnaList}">
			<div class="qna-item">
				<c:if test="${empty qna.answer}"><span class="badge">답변 대기</span></c:if>
				<c:if test="${not empty qna.answer}"><span class="badge badge-green">답변 완료</span></c:if>
				<b><c:out value="${qna.title}"/></b>
				<span class="muted"> · <fmt:formatDate value="${qna.regDate}" pattern="yyyy-MM-dd HH:mm"/></span>
				<div class="pre"><c:out value="${qna.content}"/></div>
				<c:if test="${not empty qna.answer}">
					<div class="answer">
						<b>호텔 답변</b> <span class="muted"><fmt:formatDate value="${qna.answerDate}" pattern="yyyy-MM-dd HH:mm"/></span>
						<div class="pre"><c:out value="${qna.answer}"/></div>
					</div>
				</c:if>
			</div>
		</c:forEach>
	</div>
</div>
<script>
	function checkForm(f) {
		if (f.title.value.trim() == "" || f.content.value.trim() == "") {
			alert("제목과 내용을 입력하세요.");
			return false;
		}
		return true;
	}
</script>
<%@ include file="/inc/footer.jsp" %>
