package my.dao;

import java.sql.*;

import my.util.JdbcUtil;

// translation 테이블 담당 DAO : 한 번 번역한 문장을 저장해 두는 캐시
//   같은 문장은 AI 에게 다시 묻지 않고 여기서 바로 꺼낸다 (AI 번역은 몇 초씩 걸리기 때문)
public class TranslationDao {

	// 한글 문장 -> 저장된 영어 번역, 없으면 null
	public String selectEn(Connection conn, String ko) throws SQLException {
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		try {
			pstmt = conn.prepareStatement("select en from translation where ko = ?");
			pstmt.setString(1, ko);
			rs = pstmt.executeQuery();
			if (rs.next()) {
				return rs.getString("en");
			}
			return null;
		} finally {
			JdbcUtil.close(rs);
			JdbcUtil.close(pstmt);
		}
	}

	public void insert(Connection conn, String ko, String en) throws SQLException {
		PreparedStatement pstmt = null;
		try {
			// 두 사람이 동시에 같은 문장을 번역해도 오류가 나지 않게 이미 있으면 덮어씀
			pstmt = conn.prepareStatement("replace into translation (ko, en) values (?, ?)");
			pstmt.setString(1, ko);
			pstmt.setString(2, en);
			pstmt.executeUpdate();
		} finally {
			JdbcUtil.close(pstmt);
		}
	}
}
