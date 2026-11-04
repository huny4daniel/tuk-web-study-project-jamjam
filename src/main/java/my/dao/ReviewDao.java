package my.dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

import my.model.Review;
import my.util.JdbcUtil;

// review 테이블 담당 DAO
public class ReviewDao {

	private Review makeReview(ResultSet rs) throws SQLException {
		Review review = new Review();
		review.setReviewId(rs.getInt("reviewId"));
		review.setResId(rs.getInt("resId"));
		review.setUserId(rs.getString("userId"));
		review.setRoomId(rs.getInt("roomId"));
		review.setRoomType(rs.getString("roomType"));
		review.setRating(rs.getInt("rating"));
		review.setContent(rs.getString("content"));
		review.setRegDate(rs.getTimestamp("regDate"));
		return review;
	}

	public void insert(Connection conn, Review review) throws SQLException {
		PreparedStatement pstmt = null;
		try {
			pstmt = conn.prepareStatement(
					"insert into review (resId, userId, roomId, roomType, rating, content, regDate)"
					+ " values (?, ?, ?, ?, ?, ?, now())");
			pstmt.setInt(1, review.getResId());
			pstmt.setString(2, review.getUserId());
			pstmt.setInt(3, review.getRoomId());
			pstmt.setString(4, review.getRoomType());
			pstmt.setInt(5, review.getRating());
			pstmt.setString(6, review.getContent());
			pstmt.executeUpdate();
		} finally {
			JdbcUtil.close(pstmt);
		}
	}

	public Review selectById(Connection conn, int reviewId) throws SQLException {
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		Review review = null;
		try {
			pstmt = conn.prepareStatement("select * from review where reviewId = ?");
			pstmt.setInt(1, reviewId);
			rs = pstmt.executeQuery();
			if (rs.next()) {
				review = makeReview(rs);
			}
		} finally {
			JdbcUtil.close(rs);
			JdbcUtil.close(pstmt);
		}
		return review;
	}

	// 목록 조회 공통 : where 뒤에 붙일 컬럼 이름과 값을 받아서 최근 순으로
	//   예) selectList(conn, "roomId", 3)  -> 3번 객실의 리뷰
	//   column 은 코드에서 정해서 넣는 값이므로 그대로 붙여도 안전 (수업 selectLike 의 target 과 같은 방식)
	private List<Review> selectList(Connection conn, String column, String value) throws SQLException {
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		List<Review> list = new ArrayList<Review>();
		try {
			if (column == null) {
				pstmt = conn.prepareStatement("select * from review order by regDate desc");
			} else {
				pstmt = conn.prepareStatement("select * from review where " + column + " = ? order by regDate desc");
				pstmt.setString(1, value);
			}
			rs = pstmt.executeQuery();
			while (rs.next()) {
				list.add(makeReview(rs));
			}
		} finally {
			JdbcUtil.close(rs);
			JdbcUtil.close(pstmt);
		}
		return list;
	}

	// 객실 상세 화면 : 그 객실의 리뷰
	public List<Review> selectByRoom(Connection conn, int roomId) throws SQLException {
		return selectList(conn, "roomId", String.valueOf(roomId));
	}

	// 마이페이지 : 내가 쓴 리뷰
	public List<Review> selectByUser(Connection conn, String userId) throws SQLException {
		return selectList(conn, "userId", userId);
	}

	// 관리자 : 전체 리뷰
	public List<Review> selectAll(Connection conn) throws SQLException {
		return selectList(conn, null, null);
	}

	public void deleteById(Connection conn, int reviewId) throws SQLException {
		PreparedStatement pstmt = null;
		try {
			pstmt = conn.prepareStatement("delete from review where reviewId = ?");
			pstmt.setInt(1, reviewId);
			pstmt.executeUpdate();
		} finally {
			JdbcUtil.close(pstmt);
		}
	}
}
