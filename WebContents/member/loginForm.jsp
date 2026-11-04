<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/inc/header.jsp" %>
<div class="container">
	<div class="box form-box">
		<h2 class="page-title">로그인</h2>
		<form action="login.jsp" method="post">
			<p><label>아이디</label><input type="text" name="userId"></p>
			<p><label>비밀번호</label><input type="password" name="password"></p>
			<input type="submit" class="btn btn-gold btn-block" value="로그인">
		</form>
		<p class="muted" style="margin-top:15px;">
			아직 회원이 아니신가요? <a href="joinForm.jsp"><b>회원가입</b></a><br>
			테스트 계정 : 이용자 user1 / 1234, 관리자 admin / 1234
		</p>
	</div>
</div>
<%@ include file="/inc/footer.jsp" %>
