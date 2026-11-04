<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*,my.util.*,my.dao.*,my.model.*" %>
<%@ include file="/inc/loginCheck.jsp" %>
<%-- 회원 정보 수정 처리 --%>
<% request.setCharacterEncoding("utf-8"); %>
<jsp:useBean id="member" class="my.model.Member"/>
<jsp:setProperty name="member" property="*"/>
<%
	// 아이디는 폼에서 받지 않고 세션 값으로 정한다 (다른 사람 정보를 못 바꾸게)
	member.setUserId((String) session.getAttribute("LOGIN"));

	Connection conn = ConnectionProvider.getConnection();
	try {
		new MemberDao().update(conn, member);
	} finally {
		JdbcUtil.close(conn);
	}
	session.setAttribute("NAME", member.getName());   // 바뀐 이름을 헤더에 반영
%>
<script>
	alert("회원 정보가 수정되었습니다.");
	location.href = "../mypage/myPage.jsp";
</script>
