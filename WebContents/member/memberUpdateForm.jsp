<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*,my.util.*,my.dao.*,my.model.*" %>
<%@ include file="/inc/loginCheck.jsp" %>
<%@ include file="/inc/header.jsp" %>
<%
	Connection conn = ConnectionProvider.getConnection();
	Member member = null;
	try {
		member = new MemberDao().selectById(conn, loginId);
	} finally {
		JdbcUtil.close(conn);
	}
%>
<c:set var="member" value="<%= member %>"/>
<div class="container">
	<div class="box form-box">
		<h2 class="page-title">회원 정보 수정</h2>
		<form action="memberUpdate.jsp" method="post" onsubmit="return checkForm(this)">
			<p><label>아이디</label><input type="text" value="${member.userId}" disabled></p>
			<p><label>새 비밀번호</label><input type="password" name="password" value="${member.password}"></p>
			<p><label>새 비밀번호 확인</label><input type="password" name="password2" value="${member.password}"></p>
			<p><label>이름</label><input type="text" name="name" value="<c:out value='${member.name}'/>"></p>
			<p><label>전화번호</label><input type="text" name="phone" value="<c:out value='${member.phone}'/>"></p>
			<p><label>이메일</label><input type="email" name="email" value="<c:out value='${member.email}'/>"></p>
			<input type="submit" class="btn btn-gold btn-block" value="수정하기">
		</form>
		<p style="text-align:right; margin:16px 0 0 0;"><a class="muted" href="withdrawForm.jsp">회원 탈퇴</a></p>
	</div>
</div>
<script>
	function checkForm(f) {
		if (f.password.value == "" || f.name.value == "") {
			alert("비밀번호와 이름은 꼭 입력해야 합니다.");
			return false;
		}
		if (f.password.value != f.password2.value) {
			alert("비밀번호 확인이 일치하지 않습니다.");
			return false;
		}
		return true;
	}
</script>
<%@ include file="/inc/footer.jsp" %>
