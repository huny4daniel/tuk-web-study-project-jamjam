package my.dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

import my.model.Coupon;
import my.model.MemberCoupon;
import my.util.JdbcUtil;

// member_coupon 테이블 담당 DAO (회원 쿠폰함)
public class MemberCouponDao {

	private MemberCoupon makeMemberCoupon(ResultSet rs) throws SQLException {
		MemberCoupon mc = new MemberCoupon();
		mc.setMcId(rs.getInt("mcId"));
		mc.setUserId(rs.getString("userId"));
		mc.setCouponCode(rs.getString("couponCode"));
		mc.setCouponName(rs.getString("couponName"));
		mc.setDiscountRate(rs.getInt("discountRate"));
		mc.setStartDate(rs.getString("startDate"));
		mc.setEndDate(rs.getString("endDate"));
		mc.setUsed(rs.getInt("used") == 1);
		mc.setUsedResId(rs.getInt("usedResId"));
		mc.setIssueDate(rs.getTimestamp("issueDate"));
		return mc;
	}

	// 목록 조회 공통 (ReservationDao.selectList 와 같은 방식)
	private List<MemberCoupon> selectList(Connection conn, String sql, String param) throws SQLException {
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		List<MemberCoupon> list = new ArrayList<MemberCoupon>();
		try {
			pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, param);
			rs = pstmt.executeQuery();
			while (rs.next()) {
				list.add(makeMemberCoupon(rs));
			}
		} finally {
			JdbcUtil.close(rs);
			JdbcUtil.close(pstmt);
		}
		return list;
	}

	// 쿠폰함 : 내 쿠폰 전부 (안 쓴 것 → 지금 쓸 수 있는 것 → 기간 끝나는 순)
	//   (endDate < curdate()) 는 기간이 지났으면 1 → 뒤로, (startDate > curdate()) 는 아직 시작 전이면 1 → 지금 쓸 수 있는 쿠폰 뒤로
	public List<MemberCoupon> selectByUser(Connection conn, String userId) throws SQLException {
		return selectList(conn, "select * from member_coupon where userId = ? order by used, (endDate < curdate()), (startDate > curdate()), endDate", userId);
	}

	// 결제 화면 : 지금 쓸 수 있는 내 쿠폰 (안 썼고 오늘이 사용 기간 안)
	public List<MemberCoupon> selectUsable(Connection conn, String userId) throws SQLException {
		return selectList(conn,
				"select * from member_coupon where userId = ? and used = 0 and curdate() between startDate and endDate"
				+ " order by discountRate desc", userId);
	}

	public MemberCoupon selectById(Connection conn, int mcId) throws SQLException {
		List<MemberCoupon> list = selectList(conn, "select * from member_coupon where mcId = ?", String.valueOf(mcId));
		return list.size() == 0 ? null : list.get(0);
	}

	// 이 회원이 이 쿠폰을 이미 받았나? (같은 쿠폰은 한 장만)
	public boolean hasCoupon(Connection conn, String userId, String couponCode) throws SQLException {
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		try {
			pstmt = conn.prepareStatement("select mcId from member_coupon where userId = ? and couponCode = ?");
			pstmt.setString(1, userId);
			pstmt.setString(2, couponCode);
			rs = pstmt.executeQuery();
			return rs.next();
		} finally {
			JdbcUtil.close(rs);
			JdbcUtil.close(pstmt);
		}
	}

	// ★ 쿠폰 발급 : 쿠폰 정보를 복사해서 쿠폰함에 넣는다. 이미 있으면 넣지 않고 false
	public boolean issue(Connection conn, String userId, Coupon coupon) throws SQLException {
		if (hasCoupon(conn, userId, coupon.getCouponCode())) {
			return false;
		}
		PreparedStatement pstmt = null;
		try {
			pstmt = conn.prepareStatement(
					"insert into member_coupon (userId, couponCode, couponName, discountRate, startDate, endDate, used, issueDate)"
					+ " values (?, ?, ?, ?, ?, ?, 0, now())");
			pstmt.setString(1, userId);
			pstmt.setString(2, coupon.getCouponCode());
			pstmt.setString(3, coupon.getCouponName());
			pstmt.setInt(4, coupon.getDiscountRate());
			pstmt.setString(5, coupon.getStartDate());
			pstmt.setString(6, coupon.getEndDate());
			pstmt.executeUpdate();
			return true;
		} finally {
			JdbcUtil.close(pstmt);
		}
	}

	// 예약에 쿠폰을 썼다고 표시
	public void markUsed(Connection conn, int mcId, int resId) throws SQLException {
		PreparedStatement pstmt = null;
		try {
			pstmt = conn.prepareStatement("update member_coupon set used = 1, usedResId = ? where mcId = ?");
			pstmt.setInt(1, resId);
			pstmt.setInt(2, mcId);
			pstmt.executeUpdate();
		} finally {
			JdbcUtil.close(pstmt);
		}
	}

	// 예약을 취소하면 그 예약에 썼던 쿠폰을 다시 쓸 수 있게 돌려준다
	public void restoreByRes(Connection conn, int resId) throws SQLException {
		PreparedStatement pstmt = null;
		try {
			pstmt = conn.prepareStatement("update member_coupon set used = 0, usedResId = 0 where usedResId = ?");
			pstmt.setInt(1, resId);
			pstmt.executeUpdate();
		} finally {
			JdbcUtil.close(pstmt);
		}
	}

	// 관리자 쿠폰 목록 : 이 쿠폰을 받은 회원 수
	public int countByCode(Connection conn, String couponCode) throws SQLException {
		return selectList(conn, "select * from member_coupon where couponCode = ?", couponCode).size();
	}
}
