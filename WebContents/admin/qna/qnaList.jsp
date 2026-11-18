<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*,java.util.*,my.util.*,my.dao.*,my.model.*" %>
<%@ include file="/inc/adminHeader.jsp" %>
<%
	Connection conn = ConnectionProvider.getConnection();
	List<Qna> qnaList = null;
	try {
		qnaList = new QnaDao().selectAll(conn);
	} finally {
		JdbcUtil.close(conn);
	}
%>
<c:set var="qnaList" value="<%= qnaList %>"/>

<h2 class="page-title">문의 답변</h2>
<div class="qna-list">
	<c:if test="${empty qnaList}"><p class="muted">문의가 없습니다.</p></c:if>
	<c:forEach var="qna" items="${qnaList}">
		<div class="qna-item">
			<c:if test="${empty qna.answer}"><span class="badge badge-red">답변 대기</span></c:if>
				<c:if test="${not empty qna.answer}"><span class="badge badge-green">답변 완료</span></c:if>
			<b><c:out value="${qna.title}"/></b>
			<span class="muted"> · ${qna.userId} · <fmt:formatDate value="${qna.regDate}" pattern="yyyy-MM-dd HH:mm"/></span>
			<div class="pre"><c:out value="${qna.content}"/></div>

			<%-- 문의마다 답변 폼이 하나씩 (이미 답변했으면 내용이 채워져 있어 수정 가능) --%>
			<form action="qnaAnswer.jsp" method="post" style="margin-top:8px;">
				<input type="hidden" name="qnaId" value="${qna.qnaId}">
				<textarea name="answer" style="height:70px;" placeholder="답변을 입력하세요"><c:out value="${qna.answer}"/></textarea>
				<input type="submit" class="btn btn-small" value="${empty qna.answer ? '답변 등록' : '답변 수정'}">
			</form>
		</div>
	</c:forEach>
</div>
<%@ include file="/inc/adminFooter.jsp" %>
