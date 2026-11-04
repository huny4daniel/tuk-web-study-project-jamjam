<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*,my.util.*,my.dao.*,my.model.*" %>
<%@ include file="/inc/adminCheck.jsp" %>
<%-- 쿠폰 등록 처리 --%>
<% request.setCharacterEncoding("utf-8"); %>
<jsp:useBean id="coupon" class="my.model.Coupon"/>
<jsp:setProperty name="coupon" property="*"/>
<%
	coupon.setCouponCode(coupon.getCouponCode().trim().toUpperCase());   // 쿠폰 번호는 대문자로 통일
	String msg = "쿠폰이 등록되었습니다.";

	Connection conn = ConnectionProvider.getConnection();
	try {
		if (coupon.getStartDate().compareTo(coupon.getEndDate()) > 0) {
			msg = "종료일이 시작일보다 빠릅니다.";
		} else {
			new CouponDao().insert(conn, coupon);
		}
	} catch (SQLException e) {
		msg = "이미 있는 쿠폰 번호입니다.";    // 기본키(couponCode) 중복
	} finally {
		JdbcUtil.close(conn);
	}
%>
<script>
	alert("<%= msg %>");
	location.href = "couponList.jsp";
</script>
