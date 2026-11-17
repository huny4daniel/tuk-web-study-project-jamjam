<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*,my.util.*,my.dao.*,my.model.*" %>
<%@ include file="/inc/loginCheck.jsp" %>
<%--
	회원 탈퇴 처리
	① 비밀번호 확인 → ② 이용 예정 예약이 없는지 다시 확인 → ③ 회원 삭제 → ④ 세션 끊고 메인으로
	아이디는 폼이 아니라 세션 값을 쓴다 (다른 사람을 탈퇴시킬 수 없게)
--%>
<%
	request.setCharacterEncoding("utf-8");
	String loginId = (String) session.getAttribute("LOGIN");
	String password = request.getParameter("password");
	String error = null;

	Connection conn = ConnectionProvider.getConnection();
	try {
		MemberDao memberDao = new MemberDao();
		if (memberDao.login(conn, loginId, password) == null) {
			error = "비밀번호가 틀렸습니다.";
		} else if (!"1".equals(request.getParameter("agree"))) {
			error = "탈퇴 안내를 확인하고 동의해 주세요.";
		} else if (new ReservationDao().countActiveByUser(conn, loginId) > 0) {
			error = "이용 예정인 예약이 있어 탈퇴할 수 없습니다. 예약을 먼저 취소해 주세요.";
		} else {
			memberDao.delete(conn, loginId);
		}
	} finally {
		JdbcUtil.close(conn);
	}

	if (error == null) {
		session.invalidate();   // 로그인 정보도 지운다
	}
%>
<script>
<% if (error == null) { %>
	alert("탈퇴가 완료되었습니다. 그동안 호텔 잠잠을 이용해 주셔서 감사합니다.");
	location.href = "../index.jsp";
<% } else { %>
	alert("<%= error %>");
	history.go(-1);
<% } %>
</script>
