<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*,my.util.*,my.dao.*" %>
<%@ include file="/inc/loginCheck.jsp" %>
<%@ include file="/inc/header.jsp" %>
<%-- 회원 탈퇴 화면 : 안내를 보여주고 비밀번호를 한 번 더 받는다 --%>
<%
	// 앞으로 남은 예약이 있으면 탈퇴 버튼 대신 안내만 보여준다 (처리 페이지에서도 다시 검사)
	int activeCount = 0;
	Connection conn = ConnectionProvider.getConnection();
	try {
		activeCount = new ReservationDao().countActiveByUser(conn, loginId);
	} finally {
		JdbcUtil.close(conn);
	}
%>
<c:set var="activeCount" value="<%= activeCount %>"/>
<div class="container">
	<div class="box form-box">
		<span class="eyebrow">LEAVE</span>
		<h2 class="page-title">회원 탈퇴</h2>
		<ul class="notice">
			<li>탈퇴하면 같은 아이디로 다시 로그인할 수 없고, 회원 정보와 등록한 투숙객·결제수단은 바로 삭제됩니다.</li>
			<li>지난 예약 내역과 작성한 리뷰, 문의는 호텔 운영 기록으로 남습니다.</li>
			<li>이용 예정인 예약이 있으면 먼저 마이페이지에서 취소해야 탈퇴할 수 있습니다.</li>
		</ul>

		<c:if test="${activeCount > 0}">
			<p class="warn">이용 예정인 예약이 <b>${activeCount}건</b> 있어 탈퇴할 수 없습니다.</p>
			<a class="btn btn-gold btn-block" href="<%= ctx %>/mypage/myPage.jsp">내 예약 보러 가기</a>
		</c:if>

		<c:if test="${activeCount == 0}">
			<form action="withdraw.jsp" method="post" onsubmit="return checkForm(this)">
				<p><label>비밀번호 확인</label><input type="password" name="password"></p>
				<p><label><input type="checkbox" name="agree" value="1"> 위 내용을 확인했으며 탈퇴에 동의합니다.</label></p>
				<input type="submit" class="btn btn-red btn-block" value="탈퇴하기">
			</form>
		</c:if>
		<p style="text-align:center; margin-top:12px;"><a class="muted" href="memberUpdateForm.jsp">돌아가기</a></p>
	</div>
</div>
<script>
	function checkForm(f) {
		if (f.password.value == "") {
			alert("비밀번호를 입력하세요.");
			return false;
		}
		if (!f.agree.checked) {
			alert("탈퇴 안내를 확인하고 동의해 주세요.");
			return false;
		}
		return confirm("정말 탈퇴하시겠습니까? 되돌릴 수 없습니다.");
	}
</script>
<%@ include file="/inc/footer.jsp" %>
