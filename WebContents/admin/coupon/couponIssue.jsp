<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*,java.util.*,my.util.*,my.dao.*,my.model.*" %>
<%@ include file="/inc/adminCheck.jsp" %>
<%--
	관리자 쿠폰 지급 처리 (쿠폰 관리 화면의 [지급])
	아이디를 비우면 관리자를 뺀 모든 회원에게, 적으면 그 회원에게만 지급. 이미 가진 회원은 건너뜀.
--%>
<%
	request.setCharacterEncoding("utf-8");
	String couponCode = request.getParameter("couponCode");
	String userId = request.getParameter("userId") == null ? "" : request.getParameter("userId").trim();
	String msg;

	Connection conn = ConnectionProvider.getConnection();
	try {
		Coupon coupon = null;
		for (Coupon c : new CouponDao().selectAll(conn)) {
			if (c.getCouponCode().equals(couponCode)) {
				coupon = c;
			}
		}
		MemberCouponDao mcDao = new MemberCouponDao();
		MemberDao memberDao = new MemberDao();
		if (coupon == null) {
			msg = "없는 쿠폰입니다.";
		} else if (!userId.equals("")) {
			if (memberDao.selectById(conn, userId) == null || userId.equals("admin")) {
				msg = "없는 회원 아이디입니다.";
			} else if (mcDao.issue(conn, userId, coupon)) {
				msg = userId + " 님에게 쿠폰을 지급했습니다.";
			} else {
				msg = userId + " 님은 이미 이 쿠폰을 가지고 있습니다.";
			}
		} else {
			int count = 0;
			for (Member m : memberDao.selectAll(conn)) {
				if (!m.getUserId().equals("admin") && mcDao.issue(conn, m.getUserId(), coupon)) {
					count++;
				}
			}
			msg = "회원 " + count + "명에게 쿠폰을 지급했습니다. (이미 가진 회원 제외)";
		}
	} finally {
		JdbcUtil.close(conn);
	}
%>
<script>
	alert("<%= msg %>");
	location.href = "couponList.jsp";
</script>
