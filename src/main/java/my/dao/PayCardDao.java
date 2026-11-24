package my.dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

import my.model.PayCard;
import my.util.JdbcUtil;

// pay_card 테이블 담당 DAO (회원별 등록 카드)
public class PayCardDao {

	// 내 카드 목록 (기본 카드가 맨 위, 나머지는 등록한 순)
	public List<PayCard> selectByUser(Connection conn, String userId) throws SQLException {
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		List<PayCard> list = new ArrayList<PayCard>();
		try {
			pstmt = conn.prepareStatement("select * from pay_card where userId = ? order by isDefault desc, cardId");
			pstmt.setString(1, userId);
			rs = pstmt.executeQuery();
			while (rs.next()) {
				PayCard card = new PayCard();
				card.setCardId(rs.getInt("cardId"));
				card.setUserId(rs.getString("userId"));
				card.setCardCompany(rs.getString("cardCompany"));
				card.setCardName(rs.getString("cardName"));
				card.setLast4(rs.getString("last4"));
				card.setDefaultCard(rs.getInt("isDefault") == 1);
				list.add(card);
			}
		} finally {
			JdbcUtil.close(rs);
			JdbcUtil.close(pstmt);
		}
		return list;
	}

	// 내 카드 한 장 : 없거나 남의 카드면 null
	public PayCard selectMine(Connection conn, int cardId, String userId) throws SQLException {
		for (PayCard card : selectByUser(conn, userId)) {
			if (card.getCardId() == cardId) {
				return card;
			}
		}
		return null;
	}

	public void insert(Connection conn, PayCard card) throws SQLException {
		PreparedStatement pstmt = null;
		try {
			pstmt = conn.prepareStatement("insert into pay_card (userId, cardCompany, cardName, last4, isDefault) values (?, ?, ?, ?, ?)");
			pstmt.setString(1, card.getUserId());
			pstmt.setString(2, card.getCardCompany());
			pstmt.setString(3, card.getCardName());
			pstmt.setString(4, card.getLast4());
			pstmt.setInt(5, card.isDefaultCard() ? 1 : 0);
			pstmt.executeUpdate();
		} finally {
			JdbcUtil.close(pstmt);
		}
	}

	// 기본 카드 바꾸기 : 고른 카드만 1, 내 나머지 카드는 0 (내 카드인지 selectMine 으로 먼저 확인할 것)
	public void updateDefault(Connection conn, int cardId, String userId) throws SQLException {
		PreparedStatement pstmt = null;
		try {
			pstmt = conn.prepareStatement("update pay_card set isDefault = if(cardId = ?, 1, 0) where userId = ?");
			pstmt.setInt(1, cardId);
			pstmt.setString(2, userId);
			pstmt.executeUpdate();
		} finally {
			JdbcUtil.close(pstmt);
		}
	}

	// 본인이 등록한 카드만 지운다 (where 에 userId 도 같이 넣어서 남의 것은 못 지움)
	public void delete(Connection conn, int cardId, String userId) throws SQLException {
		PreparedStatement pstmt = null;
		try {
			pstmt = conn.prepareStatement("delete from pay_card where cardId = ? and userId = ?");
			pstmt.setInt(1, cardId);
			pstmt.setString(2, userId);
			pstmt.executeUpdate();
		} finally {
			JdbcUtil.close(pstmt);
		}
	}

	// 회원 탈퇴 : 등록한 카드도 함께 지운다
	public void deleteByUser(Connection conn, String userId) throws SQLException {
		PreparedStatement pstmt = null;
		try {
			pstmt = conn.prepareStatement("delete from pay_card where userId = ?");
			pstmt.setString(1, userId);
			pstmt.executeUpdate();
		} finally {
			JdbcUtil.close(pstmt);
		}
	}
}
