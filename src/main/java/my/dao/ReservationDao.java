package my.dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

import my.model.Reservation;
import my.util.JdbcUtil;

// reservation 테이블 담당 DAO
public class ReservationDao {

	// ResultSet 한 줄 -> Reservation 객체
	private Reservation makeReservation(ResultSet rs) throws SQLException {
		Reservation res = new Reservation();
		res.setResId(rs.getInt("resId"));
		res.setUserId(rs.getString("userId"));
		res.setRoomId(rs.getInt("roomId"));
		res.setRoomType(rs.getString("roomType"));
		res.setRoomNo(rs.getString("roomNo"));
		res.setCheckIn(rs.getString("checkIn"));
		res.setCheckOut(rs.getString("checkOut"));
		res.setGuests(rs.getInt("guests"));
		res.setTotalPrice(rs.getInt("totalPrice"));
		res.setCouponCode(rs.getString("couponCode"));
		res.setPayMethod(rs.getString("payMethod"));
		res.setPayDetail(rs.getString("payDetail"));
		res.setRequestNote(rs.getString("requestNote"));
		res.setStatus(rs.getString("status"));
		res.setReviewed(rs.getInt("reviewed") == 1);
		res.setResDate(rs.getTimestamp("resDate"));
		return res;
	}

	public void insert(Connection conn, Reservation res) throws SQLException {
		PreparedStatement pstmt = null;
		try {
			pstmt = conn.prepareStatement(
					"insert into reservation (userId, roomId, roomType, roomNo, checkIn, checkOut, guests,"
					+ " totalPrice, couponCode, payMethod, payDetail, requestNote, status, reviewed, resDate)"
					+ " values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, '예약완료', 0, now())");
			pstmt.setString(1, res.getUserId());
			pstmt.setInt(2, res.getRoomId());
			pstmt.setString(3, res.getRoomType());
			pstmt.setString(4, res.getRoomNo());
			pstmt.setString(5, res.getCheckIn());
			pstmt.setString(6, res.getCheckOut());
			pstmt.setInt(7, res.getGuests());
			pstmt.setInt(8, res.getTotalPrice());
			pstmt.setString(9, res.getCouponCode());
			pstmt.setString(10, res.getPayMethod());
			pstmt.setString(11, res.getPayDetail());
			pstmt.setString(12, res.getRequestNote());
			pstmt.executeUpdate();
		} finally {
			JdbcUtil.close(pstmt);
		}
	}

	// ★ 중복 예약 방지 : 같은 객실에 기간이 겹치는 '예약완료' 건이 몇 개인지
	// 겹치는 조건 : 기존 체크인 < 새 체크아웃  그리고  기존 체크아웃 > 새 체크인
	// 예) 기존 10일~12일, 새 12일~13일 -> 12 > 12 가 거짓이므로 안 겹침(12일 체크아웃 후 체크인 가능)
	public int countOverlap(Connection conn, int roomId, String checkIn, String checkOut) throws SQLException {
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		try {
			pstmt = conn.prepareStatement(
					"select count(*) from reservation"
					+ " where roomId = ? and status = '예약완료' and checkIn < ? and checkOut > ?");
			pstmt.setInt(1, roomId);
			pstmt.setString(2, checkOut);
			pstmt.setString(3, checkIn);
			rs = pstmt.executeQuery();
			rs.next();
			return rs.getInt(1);
		} finally {
			JdbcUtil.close(rs);
			JdbcUtil.close(pstmt);
		}
	}

	// 예약 목록 조회 공통 : SQL 과 ? 에 넣을 값 2개(두 번째가 필요 없으면 null)를 받아서 리스트로
	//   (QnaDao.selectBySql 과 같은 방식)
	private List<Reservation> selectList(Connection conn, String sql, String param1, String param2) throws SQLException {
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		List<Reservation> list = new ArrayList<Reservation>();
		try {
			pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, param1);
			if (param2 != null) {
				pstmt.setString(2, param2);
			}
			rs = pstmt.executeQuery();
			while (rs.next()) {
				list.add(makeReservation(rs));
			}
		} finally {
			JdbcUtil.close(rs);
			JdbcUtil.close(pstmt);
		}
		return list;
	}

	// ★ SOLD OUT 표시용 : 검색한 기간과 겹치는 '예약완료' 예약 전부 (모든 객실)
	//   겹치는 조건은 countOverlap 과 같다. roomList.jsp 에서 객실마다 마감 기간을 붙이는 데 쓴다.
	public List<Reservation> selectOverlap(Connection conn, String checkIn, String checkOut) throws SQLException {
		return selectList(conn,
				"select * from reservation where status = '예약완료' and checkIn < ? and checkOut > ? order by checkIn",
				checkOut, checkIn);
	}

	// ★ 달력 표시용 : 한 객실의 앞으로 남은 '예약완료' 예약 (체크아웃이 오늘 이후)
	public List<Reservation> selectBookedByRoom(Connection conn, int roomId) throws SQLException {
		return selectList(conn,
				"select * from reservation where roomId = ? and status = '예약완료' and checkOut > curdate() order by checkIn",
				String.valueOf(roomId), null);
	}

	public Reservation selectById(Connection conn, int resId) throws SQLException {
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		Reservation res = null;
		try {
			pstmt = conn.prepareStatement("select * from reservation where resId = ?");
			pstmt.setInt(1, resId);
			rs = pstmt.executeQuery();
			if (rs.next()) {
				res = makeReservation(rs);
			}
		} finally {
			JdbcUtil.close(rs);
			JdbcUtil.close(pstmt);
		}
		return res;
	}

	// 방금 예약한 건 : 그 회원의 예약 중 예약번호가 가장 큰 것 (예약 직후 확인서로 보내려고)
	public Reservation selectLatestByUser(Connection conn, String userId) throws SQLException {
		List<Reservation> list = selectList(conn,
				"select * from reservation where userId = ? order by resId desc limit 1", userId, null);
		return list.size() == 0 ? null : list.get(0);
	}

	// 마이페이지 : 내 예약 목록 (최근 체크인 순)
	public List<Reservation> selectByUser(Connection conn, String userId) throws SQLException {
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		List<Reservation> list = new ArrayList<Reservation>();
		try {
			pstmt = conn.prepareStatement("select * from reservation where userId = ? order by checkIn desc");
			pstmt.setString(1, userId);
			rs = pstmt.executeQuery();
			while (rs.next()) {
				list.add(makeReservation(rs));
			}
		} finally {
			JdbcUtil.close(rs);
			JdbcUtil.close(pstmt);
		}
		return list;
	}

	// 관리자 : 전체 예약 목록 (status 가 비어 있으면 전체, 있으면 그 상태만)
	public List<Reservation> selectAll(Connection conn, String status) throws SQLException {
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		List<Reservation> list = new ArrayList<Reservation>();
		try {
			if (status == null || status.equals("")) {
				pstmt = conn.prepareStatement("select * from reservation order by checkIn desc");
			} else {
				pstmt = conn.prepareStatement("select * from reservation where status = ? order by checkIn desc");
				pstmt.setString(1, status);
			}
			rs = pstmt.executeQuery();
			while (rs.next()) {
				list.add(makeReservation(rs));
			}
		} finally {
			JdbcUtil.close(rs);
			JdbcUtil.close(pstmt);
		}
		return list;
	}

	// 관리자 대시보드 : 오늘 체크인하는 예약
	public List<Reservation> selectTodayCheckIn(Connection conn) throws SQLException {
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		List<Reservation> list = new ArrayList<Reservation>();
		try {
			pstmt = conn.prepareStatement(
					"select * from reservation where status = '예약완료' and checkIn = curdate() order by roomNo");
			rs = pstmt.executeQuery();
			while (rs.next()) {
				list.add(makeReservation(rs));
			}
		} finally {
			JdbcUtil.close(rs);
			JdbcUtil.close(pstmt);
		}
		return list;
	}

	// 관리자 대시보드 : 앞으로 투숙 예정인 예약 수
	public int countUpcoming(Connection conn) throws SQLException {
		Statement stmt = null;
		ResultSet rs = null;
		try {
			stmt = conn.createStatement();
			rs = stmt.executeQuery("select count(*) from reservation where status = '예약완료' and checkOut > curdate()");
			rs.next();
			return rs.getInt(1);
		} finally {
			JdbcUtil.close(rs);
			JdbcUtil.close(stmt);
		}
	}

	// 객실 삭제 전에 확인 : 그 객실에 아직 끝나지 않은 예약이 몇 개인지
	public int countActiveByRoom(Connection conn, int roomId) throws SQLException {
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		try {
			pstmt = conn.prepareStatement(
					"select count(*) from reservation where roomId = ? and status = '예약완료' and checkOut > curdate()");
			pstmt.setInt(1, roomId);
			rs = pstmt.executeQuery();
			rs.next();
			return rs.getInt(1);
		} finally {
			JdbcUtil.close(rs);
			JdbcUtil.close(pstmt);
		}
	}

	// 회원 탈퇴 전에 확인 : 그 회원의 아직 끝나지 않은 예약이 몇 개인지
	public int countActiveByUser(Connection conn, String userId) throws SQLException {
		return selectList(conn,
				"select * from reservation where userId = ? and status = '예약완료' and checkOut > curdate()",
				userId, null).size();
	}

	// 예약 상태 변경 (취소 등)
	public void updateStatus(Connection conn, int resId, String status) throws SQLException {
		PreparedStatement pstmt = null;
		try {
			pstmt = conn.prepareStatement("update reservation set status = ? where resId = ?");
			pstmt.setString(1, status);
			pstmt.setInt(2, resId);
			pstmt.executeUpdate();
		} finally {
			JdbcUtil.close(pstmt);
		}
	}

	// 리뷰를 쓰면 reviewed = 1 로 표시 (같은 예약에 리뷰를 두 번 못 쓰게)
	public void updateReviewed(Connection conn, int resId) throws SQLException {
		PreparedStatement pstmt = null;
		try {
			pstmt = conn.prepareStatement("update reservation set reviewed = 1 where resId = ?");
			pstmt.setInt(1, resId);
			pstmt.executeUpdate();
		} finally {
			JdbcUtil.close(pstmt);
		}
	}
}
