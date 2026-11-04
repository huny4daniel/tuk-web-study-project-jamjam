<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/inc/header.jsp" %>
<div class="container">
	<div class="box form-box">
		<h2 class="page-title">회원가입</h2>
		<!-- 가입하기를 누르면 checkForm() 으로 먼저 검사하고, 통과하면 join.jsp 로 전송 -->
		<form name="fr" action="join.jsp" method="post" onsubmit="return checkForm(this)">
			<p>
				<label>아이디</label>
				<span class="row">
					<input type="text" name="userId" id="userId">
					<input type="button" class="btn btn-gray" value="중복확인" onclick="openIdCheck()">
				</span>
			</p>
			<p><label>비밀번호</label><input type="password" name="password"></p>
			<p><label>비밀번호 확인</label><input type="password" name="password2"></p>
			<p><label>이름</label><input type="text" name="name"></p>
			<p><label>전화번호</label><input type="text" name="phone" placeholder="010-0000-0000"></p>
			<p><label>이메일</label><input type="email" name="email"></p>
			<input type="submit" class="btn btn-gold btn-block" value="가입하기">
		</form>
	</div>
</div>
<script>
	// 수업 때 만든 아이디 중복확인 팝업과 같은 방식
	function openIdCheck() {
		var id = document.fr.userId.value;
		if (id == "") {
			alert("아이디를 입력하세요.");
			return;
		}
		window.open("joinIdCheck.jsp?userId=" + encodeURIComponent(id), "idCheck", "width=400,height=220");
	}
	function checkForm(f) {
		if (f.userId.value == "" || f.password.value == "" || f.name.value == "") {
			alert("아이디, 비밀번호, 이름은 꼭 입력해야 합니다.");
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
