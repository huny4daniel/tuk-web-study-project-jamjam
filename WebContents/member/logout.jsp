<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
	// 세션을 통째로 없애면 LOGIN, NAME 값이 모두 사라진다
	session.invalidate();
	response.sendRedirect("../index.jsp");
%>
