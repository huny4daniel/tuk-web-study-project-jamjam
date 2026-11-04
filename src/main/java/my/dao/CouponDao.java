package my.dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

import my.model.Coupon;
import my.util.JdbcUtil;

// coupon 테이블 담당 DAO
public class CouponDao {

	private Coupon makeCoupon(ResultSet rs) throws SQLException {
		Coupon coupon = new Coupon();
		coupon.setCouponCode(rs.getString("couponCode"));
		coupon.setCouponName(rs.getString("couponName"));
		coupon.setDiscountRate(rs.getInt("discountRate"));
		coupon.setStartDate(rs.getString("startDate"));
		coupon.setEndDate(rs.getString("endDate"));
		return coupon;
	}

	public List<Coupon> selectAll(Connection conn) throws SQLException {
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		List<Coupon> list = new ArrayList<Coupon>();
		try {
			pstmt = conn.prepareStatement("select * from coupon order by endDate desc");
			rs = pstmt.executeQuery();
			while (rs.next()) {
				list.add(makeCoupon(rs));
			}
		} finally {
			JdbcUtil.close(rs);
			JdbcUtil.close(pstmt);
		}
		return list;
	}

	// ★ 오늘 사용할 수 있는 쿠폰이면 쿠폰 정보, 없거나 기간이 아니면 null
	public Coupon selectValid(Connection conn, String couponCode) throws SQLException {
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		Coupon coupon = null;
		try {
			pstmt = conn.prepareStatement(
					"select * from coupon where couponCode = ? and curdate() between startDate and endDate");
			pstmt.setString(1, couponCode);
			rs = pstmt.executeQuery();
			if (rs.next()) {
				coupon = makeCoupon(rs);
			}
		} finally {
			JdbcUtil.close(rs);
			JdbcUtil.close(pstmt);
		}
		return coupon;
	}

	public void insert(Connection conn, Coupon coupon) throws SQLException {
		PreparedStatement pstmt = null;
		try {
			pstmt = conn.prepareStatement("insert into coupon values (?, ?, ?, ?, ?)");
			pstmt.setString(1, coupon.getCouponCode());
			pstmt.setString(2, coupon.getCouponName());
			pstmt.setInt(3, coupon.getDiscountRate());
			pstmt.setString(4, coupon.getStartDate());
			pstmt.setString(5, coupon.getEndDate());
			pstmt.executeUpdate();
		} finally {
			JdbcUtil.close(pstmt);
		}
	}

	public void deleteByCode(Connection conn, String couponCode) throws SQLException {
		PreparedStatement pstmt = null;
		try {
			pstmt = conn.prepareStatement("delete from coupon where couponCode = ?");
			pstmt.setString(1, couponCode);
			pstmt.executeUpdate();
		} finally {
			JdbcUtil.close(pstmt);
		}
	}
}
