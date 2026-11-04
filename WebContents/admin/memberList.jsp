<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*,java.util.*,my.util.*,my.dao.*,my.model.*" %>
<%@ include file="/inc/adminHeader.jsp" %>
<%
	Connection conn = ConnectionProvider.getConnection();
	List<Member> memberList = null;
	try {
		memberList = new MemberDao().selectAll(conn);
	} finally {
		JdbcUtil.close(conn);
	}
%>
<c:set var="memberList" value="<%= memberList %>"/>

<h2 class="page-title">회원 목록</h2>
<table class="list">
	<tr><th>아이디</th><th>이름</th><th>전화번호</th><th>이메일</th><th>가입일</th><th>구분</th></tr>
	<c:forEach var="m" items="${memberList}">
		<tr>
			<td>${m.userId}</td>
			<td><c:out value="${m.name}"/></td>
			<td><c:out value="${m.phone}"/></td>
			<td><c:out value="${m.email}"/></td>
			<td><fmt:formatDate value="${m.registerTime}" pattern="yyyy-MM-dd"/></td>
			<td>${m.userId == 'admin' ? '<span class="badge badge-gold">관리자</span>' : '이용자'}</td>
		</tr>
	</c:forEach>
</table>
<%@ include file="/inc/adminFooter.jsp" %>
