<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*,java.util.*,my.util.*,my.dao.*,my.model.*" %>
<%@ include file="/inc/adminHeader.jsp" %>
<%
	Connection conn = ConnectionProvider.getConnection();
	List<Review> reviewList = null;
	try {
		reviewList = new ReviewDao().selectAll(conn);
	} finally {
		JdbcUtil.close(conn);
	}
%>
<c:set var="reviewList" value="<%= reviewList %>"/>

<h2 class="page-title">리뷰 관리</h2>
<table class="list">
	<tr><th>번호</th><th>객실</th><th>작성자</th><th>평점</th><th>내용</th><th>작성일</th><th>관리</th></tr>
	<c:if test="${empty reviewList}">
		<tr><td colspan="7">리뷰가 없습니다.</td></tr>
	</c:if>
	<c:forEach var="review" items="${reviewList}">
		<tr>
			<td>${review.reviewId}</td>
			<td>${review.roomType}</td>
			<td>${review.userId}</td>
			<td class="stars"><c:forEach begin="1" end="${review.rating}">★</c:forEach></td>
			<td class="left pre"><c:out value="${review.content}"/></td>
			<td><fmt:formatDate value="${review.regDate}" pattern="yyyy-MM-dd"/></td>
			<td>
				<a class="btn btn-small btn-red" href="reviewDelete.jsp?reviewId=${review.reviewId}"
				   onclick="return confirm('이 리뷰를 삭제하시겠습니까?')">삭제</a>
			</td>
		</tr>
	</c:forEach>
</table>
<%@ include file="/inc/adminFooter.jsp" %>
