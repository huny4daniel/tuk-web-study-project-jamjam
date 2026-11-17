<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*,my.util.*,my.dao.*,my.model.*" %>
<%@ include file="/inc/adminCheck.jsp" %>
<%-- 자주 묻는 질문 등록 / 수정 처리 (faqId 가 0 이면 등록, 아니면 수정 : roomSave.jsp 와 같은 방식) --%>
<% request.setCharacterEncoding("utf-8"); %>
<jsp:useBean id="faq" class="my.model.Faq"/>
<jsp:setProperty name="faq" property="*"/>
<%
	Connection conn = ConnectionProvider.getConnection();
	try {
		FaqDao dao = new FaqDao();
		if (faq.getFaqId() == 0) {
			dao.insert(conn, faq);
		} else {
			dao.update(conn, faq);
		}
	} finally {
		JdbcUtil.close(conn);
	}
%>
<script>
	alert("저장되었습니다.");
	location.href = "faqList.jsp";
</script>
