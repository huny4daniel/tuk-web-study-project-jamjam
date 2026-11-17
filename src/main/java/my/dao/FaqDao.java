package my.dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

import my.model.Faq;
import my.util.JdbcUtil;

// faq 테이블 담당 DAO
public class FaqDao {

	private Faq makeFaq(ResultSet rs) throws SQLException {
		Faq faq = new Faq();
		faq.setFaqId(rs.getInt("faqId"));
		faq.setCategory(rs.getString("category"));
		faq.setQuestion(rs.getString("question"));
		faq.setAnswer(rs.getString("answer"));
		return faq;
	}

	// 분류별 목록 : category 가 비어 있으면 전체
	//   (객실 검색과 같은 "항상 참" 방식 : 분류를 안 고르면 like '%' 로 전부 나옴)
	public List<Faq> selectList(Connection conn, String category) throws SQLException {
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		List<Faq> list = new ArrayList<Faq>();
		try {
			pstmt = conn.prepareStatement("select * from faq where category like ? order by category, faqId");
			pstmt.setString(1, (category == null || category.equals("")) ? "%" : category);
			rs = pstmt.executeQuery();
			while (rs.next()) {
				list.add(makeFaq(rs));
			}
		} finally {
			JdbcUtil.close(rs);
			JdbcUtil.close(pstmt);
		}
		return list;
	}

	public Faq selectById(Connection conn, int faqId) throws SQLException {
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		Faq faq = null;
		try {
			pstmt = conn.prepareStatement("select * from faq where faqId = ?");
			pstmt.setInt(1, faqId);
			rs = pstmt.executeQuery();
			if (rs.next()) {
				faq = makeFaq(rs);
			}
		} finally {
			JdbcUtil.close(rs);
			JdbcUtil.close(pstmt);
		}
		return faq;
	}

	public void insert(Connection conn, Faq faq) throws SQLException {
		PreparedStatement pstmt = null;
		try {
			pstmt = conn.prepareStatement("insert into faq (category, question, answer) values (?, ?, ?)");
			pstmt.setString(1, faq.getCategory());
			pstmt.setString(2, faq.getQuestion());
			pstmt.setString(3, faq.getAnswer());
			pstmt.executeUpdate();
		} finally {
			JdbcUtil.close(pstmt);
		}
	}

	public void update(Connection conn, Faq faq) throws SQLException {
		PreparedStatement pstmt = null;
		try {
			pstmt = conn.prepareStatement("update faq set category = ?, question = ?, answer = ? where faqId = ?");
			pstmt.setString(1, faq.getCategory());
			pstmt.setString(2, faq.getQuestion());
			pstmt.setString(3, faq.getAnswer());
			pstmt.setInt(4, faq.getFaqId());
			pstmt.executeUpdate();
		} finally {
			JdbcUtil.close(pstmt);
		}
	}

	public void deleteById(Connection conn, int faqId) throws SQLException {
		PreparedStatement pstmt = null;
		try {
			pstmt = conn.prepareStatement("delete from faq where faqId = ?");
			pstmt.setInt(1, faqId);
			pstmt.executeUpdate();
		} finally {
			JdbcUtil.close(pstmt);
		}
	}
}
