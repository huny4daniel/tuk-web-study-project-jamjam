<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*,java.util.*,my.util.*,my.dao.*,my.model.*" %>
<%@ include file="/inc/loginCheck.jsp" %>
<%-- 결제수단 등록 처리 (아이디는 폼이 아니라 세션 값) : 첫 번째 카드는 자동으로 기본 카드가 된다 --%>
<%
	request.setCharacterEncoding("utf-8");
	String loginId = (String) session.getAttribute("LOGIN");
	String company = request.getParameter("cardCompany");
	String last4 = request.getParameter("last4");
	String cardName = request.getParameter("cardName") == null ? "" : request.getParameter("cardName").trim();
	if (cardName.length() > 30) cardName = cardName.substring(0, 30);
	String msg = "카드를 등록했습니다.";

	Connection conn = ConnectionProvider.getConnection();
	try {
		PayCardDao dao = new PayCardDao();
		List<PayCard> cardList = dao.selectByUser(conn, loginId);
		boolean exists = false;   // 같은 카드사 + 끝 4자리로 이미 등록돼 있나?
		for (PayCard c : cardList) {
			if (c.getCardCompany().equals(company) && c.getLast4().equals(last4)) exists = true;
		}

		if (!Arrays.asList(PayCard.COMPANIES).contains(company)) {
			msg = "카드사를 선택하세요.";
		} else if (last4 == null || !last4.matches("[0-9]{4}")) {
			msg = "카드번호 끝 4자리를 숫자로 입력하세요.";
		} else if (exists) {
			msg = "이미 등록한 카드입니다.";
		} else if (cardList.size() >= 5) {
			msg = "카드는 5장까지 등록할 수 있습니다.";
		} else {
			PayCard card = new PayCard();
			card.setUserId(loginId);
			card.setCardCompany(company);
			card.setCardName(cardName.equals("") ? company : cardName);   // 별칭이 없으면 카드사 이름
			card.setLast4(last4);
			card.setDefaultCard(cardList.size() == 0);
			dao.insert(conn, card);
		}
	} finally {
		JdbcUtil.close(conn);
	}
%>
<script>
	alert("<%= msg %>");
	location.href = "card.jsp";
</script>
