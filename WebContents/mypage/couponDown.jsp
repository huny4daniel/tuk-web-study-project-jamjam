<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*,my.util.*,my.dao.*,my.model.*" %>
<%@ include file="/inc/loginCheck.jsp" %>
<%--
	쿠폰 받기 처리 (쿠폰함의 [받기] 버튼)
	다운로드형이고 기간이 끝나지 않은 쿠폰만, 한 사람이 한 장만 받을 수 있다 (서버에서 다시 검사)
--%>
<%
	String loginId = (String) session.getAttribute("LOGIN");
	String couponCode = request.getParameter("couponCode");
	String msg = "쿠폰을 받았습니다. 결제 화면에서 쓸 수 있습니다.";

	Connection conn = ConnectionProvider.getConnection();
	try {
		Coupon coupon = null;
		for (Coupon c : new CouponDao().selectByIssueType(conn, "다운로드")) {
			if (c.getCouponCode().equals(couponCode)) {
				coupon = c;
			}
		}
		if (coupon == null) {
			msg = "받을 수 없는 쿠폰입니다.";
		} else if (!new MemberCouponDao().issue(conn, loginId, coupon)) {
			msg = "이미 받은 쿠폰입니다.";
		}
	} finally {
		JdbcUtil.close(conn);
	}
%>
<script>
	alert("<%= msg %>");
	location.href = "coupon.jsp";
</script>
