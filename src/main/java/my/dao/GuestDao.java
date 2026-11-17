package my.dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

import my.model.Guest;
import my.util.JdbcUtil;

// guest 테이블 담당 DAO (회원별 등록 투숙객)
public class GuestDao {

	// 내 투숙객 목록 (등록한 순)
	public List<Guest> selectByUser(Connection conn, String userId) throws SQLException {
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		List<Guest> list = new ArrayList<Guest>();
		try {
			pstmt = conn.prepareStatement("select * from guest where userId = ? order by guestId");
			pstmt.setString(1, userId);
			rs = pstmt.executeQuery();
			while (rs.next()) {
				Guest guest = new Guest();
				guest.setGuestId(rs.getInt("guestId"));
				guest.setUserId(rs.getString("userId"));
				guest.setName(rs.getString("name"));
				guest.setPhone(rs.getString("phone"));
				guest.setRelation(rs.getString("relation"));
				list.add(guest);
			}
		} finally {
			JdbcUtil.close(rs);
			JdbcUtil.close(pstmt);
		}
		return list;
	}

	// 같은 이름 + 연락처로 이미 등록돼 있나? (결제 화면에서 저장할 때 중복 방지)
	public boolean exists(Connection conn, String userId, String name, String phone) throws SQLException {
		for (Guest g : selectByUser(conn, userId)) {
			if (g.getName().equals(name) && g.getPhone().equals(phone)) {
				return true;
			}
		}
		return false;
	}

	public void insert(Connection conn, Guest guest) throws SQLException {
		PreparedStatement pstmt = null;
		try {
			pstmt = conn.prepareStatement("insert into guest (userId, name, phone, relation) values (?, ?, ?, ?)");
			pstmt.setString(1, guest.getUserId());
			pstmt.setString(2, guest.getName());
			pstmt.setString(3, guest.getPhone());
			pstmt.setString(4, guest.getRelation());
			pstmt.executeUpdate();
		} finally {
			JdbcUtil.close(pstmt);
		}
	}

	// 본인이 등록한 투숙객만 지운다 (where 에 userId 도 같이 넣어서 남의 것은 못 지움)
	public void delete(Connection conn, int guestId, String userId) throws SQLException {
		PreparedStatement pstmt = null;
		try {
			pstmt = conn.prepareStatement("delete from guest where guestId = ? and userId = ?");
			pstmt.setInt(1, guestId);
			pstmt.setString(2, userId);
			pstmt.executeUpdate();
		} finally {
			JdbcUtil.close(pstmt);
		}
	}

	// 회원 탈퇴 : 등록한 투숙객(개인정보)도 함께 지운다
	public void deleteByUser(Connection conn, String userId) throws SQLException {
		PreparedStatement pstmt = null;
		try {
			pstmt = conn.prepareStatement("delete from guest where userId = ?");
			pstmt.setString(1, userId);
			pstmt.executeUpdate();
		} finally {
			JdbcUtil.close(pstmt);
		}
	}
}
