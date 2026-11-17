<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*,java.util.*,my.util.*,my.dao.*,my.model.*" %>
<%@ include file="/inc/adminHeader.jsp" %>
<%--
	자주 묻는 질문 관리 : 위에는 등록/수정 폼, 아래에는 목록
	faqList.jsp            -> 빈 폼 (새 질문 등록)
	faqList.jsp?faqId=3    -> 3번 질문이 채워진 폼 (수정)  (객실 roomForm.jsp 와 같은 방식)
--%>
<%
	String faqIdStr = request.getParameter("faqId");
	Faq editFaq = new Faq();   // 등록일 때는 빈 객체
	List<Faq> faqList = null;
	Connection conn = ConnectionProvider.getConnection();
	try {
		FaqDao dao = new FaqDao();
		faqList = dao.selectList(conn, null);
		if (faqIdStr != null) {
			editFaq = dao.selectById(conn, Integer.parseInt(faqIdStr));
		}
	} finally {
		JdbcUtil.close(conn);
	}
%>
<c:set var="faqList" value="<%= faqList %>"/>
<c:set var="editFaq" value="<%= editFaq %>"/>
<c:set var="isEdit" value="<%= faqIdStr != null %>"/>

<h2 class="page-title">자주 묻는 질문 관리</h2>
<p class="muted">여기 등록한 질문은 이용자 [자주 묻는 질문] 화면과 AI 상담 챗봇의 답변 근거로 쓰입니다.</p>

<div class="box">
	<h3>${isEdit ? '질문 수정' : '새 질문 등록'}</h3>
	<form action="faqSave.jsp" method="post" onsubmit="return checkForm(this)">
		<input type="hidden" name="faqId" value="${editFaq.faqId}">
		<table class="form">
			<tr><th>분류</th>
				<td>
					<select name="category">
						<option ${editFaq.category == '예약·결제' ? 'selected' : ''}>예약·결제</option>
						<option ${editFaq.category == '객실' ? 'selected' : ''}>객실</option>
						<option ${editFaq.category == '시설·서비스' ? 'selected' : ''}>시설·서비스</option>
						<option ${editFaq.category == '회원' ? 'selected' : ''}>회원</option>
					</select>
				</td>
			</tr>
			<tr><th>질문</th><td><input type="text" name="question" class="full" value="<c:out value='${editFaq.question}'/>"></td></tr>
			<tr><th>답변</th><td><textarea name="answer"><c:out value="${editFaq.answer}"/></textarea></td></tr>
		</table>
		<p style="margin-top:16px;">
			<input type="submit" class="btn btn-gold" value="${isEdit ? '수정 완료' : '등록'}">
			<c:if test="${isEdit}"><a class="btn btn-gray" href="faqList.jsp">취소</a></c:if>
		</p>
	</form>
</div>

<table class="list">
	<tr><th>번호</th><th>분류</th><th>질문</th><th>관리</th></tr>
	<c:if test="${empty faqList}">
		<tr><td colspan="4">등록된 질문이 없습니다.</td></tr>
	</c:if>
	<c:forEach var="faq" items="${faqList}">
		<tr>
			<td>${faq.faqId}</td>
			<td>${faq.category}</td>
			<td class="left"><b><c:out value="${faq.question}"/></b><br><span class="muted"><c:out value="${faq.answer}"/></span></td>
			<td style="white-space:nowrap;">
				<a class="btn btn-small btn-line" href="faqList.jsp?faqId=${faq.faqId}">수정</a>
				<a class="btn btn-small btn-red" href="faqDelete.jsp?faqId=${faq.faqId}" onclick="return confirm('이 질문을 삭제하시겠습니까?')">삭제</a>
			</td>
		</tr>
	</c:forEach>
</table>
<script>
	function checkForm(f) {
		if (f.question.value.trim() == "" || f.answer.value.trim() == "") {
			alert("질문과 답변을 입력하세요.");
			return false;
		}
		return true;
	}
</script>
<%@ include file="/inc/adminFooter.jsp" %>
