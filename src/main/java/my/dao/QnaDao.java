package my.dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

import my.model.Qna;
import my.util.JdbcUtil;

// qna 테이블 담당 DAO
public class QnaDao {

	private List<Qna> selectBySql(Connection conn, String sql, String param) throws SQLException {
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		List<Qna> list = new ArrayList<Qna>();
		try {
			pstmt = conn.prepareStatement(sql);
			if (param != null) {
				pstmt.setString(1, param);
			}
			rs = pstmt.executeQuery();
			while (rs.next()) {
				Qna qna = new Qna();
				qna.setQnaId(rs.getInt("qnaId"));
				qna.setUserId(rs.getString("userId"));
				qna.setTitle(rs.getString("title"));
				qna.setContent(rs.getString("content"));
				qna.setAnswer(rs.getString("answer"));
				qna.setRegDate(rs.getTimestamp("regDate"));
				qna.setAnswerDate(rs.getTimestamp("answerDate"));
				list.add(qna);
			}
		} finally {
			JdbcUtil.close(rs);
			JdbcUtil.close(pstmt);
		}
		return list;
	}

	public void insert(Connection conn, Qna qna) throws SQLException {
		PreparedStatement pstmt = null;
		try {
			pstmt = conn.prepareStatement(
					"insert into qna (userId, title, content, regDate) values (?, ?, ?, now())");
			pstmt.setString(1, qna.getUserId());
			pstmt.setString(2, qna.getTitle());
			pstmt.setString(3, qna.getContent());
			pstmt.executeUpdate();
		} finally {
			JdbcUtil.close(pstmt);
		}
	}

	// 이용자 : 내 문의 목록
	public List<Qna> selectByUser(Connection conn, String userId) throws SQLException {
		return selectBySql(conn, "select * from qna where userId = ? order by regDate desc", userId);
	}

	// 관리자 : 전체 문의 (최근 순)
	public List<Qna> selectAll(Connection conn) throws SQLException {
		return selectBySql(conn, "select * from qna order by qnaId desc", null);
	}

	// 관리자 대시보드 : 답변 대기 문의 수
	public int countUnanswered(Connection conn) throws SQLException {
		return selectBySql(conn, "select * from qna where answer is null", null).size();
	}

	// 관리자 : 답변 등록/수정
	public void updateAnswer(Connection conn, int qnaId, String answer) throws SQLException {
		PreparedStatement pstmt = null;
		try {
			pstmt = conn.prepareStatement("update qna set answer = ?, answerDate = now() where qnaId = ?");
			pstmt.setString(1, answer);
			pstmt.setInt(2, qnaId);
			pstmt.executeUpdate();
		} finally {
			JdbcUtil.close(pstmt);
		}
	}
}
