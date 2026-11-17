package my.dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

import my.model.Member;
import my.util.JdbcUtil;

// member 테이블 담당 DAO
// ※ 이 프로젝트의 모든 DAO 는 Connection 을 받아서 쓰기만 하고 닫지 않는다.
//    Connection 은 JSP 에서 finally { JdbcUtil.close(conn); } 로 한 번만 닫는다.
//    (한 페이지에서 DAO 메서드를 여러 번 호출해도 같은 연결을 계속 쓸 수 있게 하려고)
public class MemberDao {

	public void insert(Connection conn, Member member) throws SQLException {
		PreparedStatement pstmt = null;
		try {
			pstmt = conn.prepareStatement(
					"insert into member (userId, password, name, phone, email, registerTime)"
					+ " values (?, ?, ?, ?, ?, now())");
			pstmt.setString(1, member.getUserId());
			pstmt.setString(2, member.getPassword());
			pstmt.setString(3, member.getName());
			pstmt.setString(4, member.getPhone());
			pstmt.setString(5, member.getEmail());
			pstmt.executeUpdate();
		} finally {
			JdbcUtil.close(pstmt);
		}
	}

	// 이미 있는 아이디면 true
	public boolean idCheck(Connection conn, String userId) throws SQLException {
		return selectById(conn, userId) != null;
	}

	public Member selectById(Connection conn, String userId) throws SQLException {
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		Member member = null;
		try {
			pstmt = conn.prepareStatement("select * from member where userId = ?");
			pstmt.setString(1, userId);
			rs = pstmt.executeQuery();
			if (rs.next()) {
				member = new Member();
				member.setUserId(rs.getString("userId"));
				member.setPassword(rs.getString("password"));
				member.setName(rs.getString("name"));
				member.setPhone(rs.getString("phone"));
				member.setEmail(rs.getString("email"));
				member.setRegisterTime(rs.getTimestamp("registerTime"));
			}
		} finally {
			JdbcUtil.close(rs);
			JdbcUtil.close(pstmt);
		}
		return member;
	}

	// 아이디/비밀번호가 맞으면 회원 정보, 틀리면 null
	public Member login(Connection conn, String userId, String password) throws SQLException {
		Member member = selectById(conn, userId);
		if (member != null && member.getPassword().equals(password)) {
			return member;
		}
		return null;
	}

	// 관리자 : 전체 회원 목록
	public List<Member> selectAll(Connection conn) throws SQLException {
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		List<Member> list = new ArrayList<Member>();
		try {
			pstmt = conn.prepareStatement("select * from member order by registerTime desc");
			rs = pstmt.executeQuery();
			while (rs.next()) {
				Member member = new Member();
				member.setUserId(rs.getString("userId"));
				member.setName(rs.getString("name"));
				member.setPhone(rs.getString("phone"));
				member.setEmail(rs.getString("email"));
				member.setRegisterTime(rs.getTimestamp("registerTime"));
				list.add(member);
			}
		} finally {
			JdbcUtil.close(rs);
			JdbcUtil.close(pstmt);
		}
		return list;
	}

	// 회원 탈퇴 : 회원 정보만 지운다 (예약, 리뷰, 문의 기록은 남김)
	public void delete(Connection conn, String userId) throws SQLException {
		PreparedStatement pstmt = null;
		try {
			pstmt = conn.prepareStatement("delete from member where userId = ?");
			pstmt.setString(1, userId);
			pstmt.executeUpdate();
		} finally {
			JdbcUtil.close(pstmt);
		}
	}

	public void update(Connection conn, Member member) throws SQLException {
		PreparedStatement pstmt = null;
		try {
			pstmt = conn.prepareStatement(
					"update member set password=?, name=?, phone=?, email=? where userId=?");
			pstmt.setString(1, member.getPassword());
			pstmt.setString(2, member.getName());
			pstmt.setString(3, member.getPhone());
			pstmt.setString(4, member.getEmail());
			pstmt.setString(5, member.getUserId());
			pstmt.executeUpdate();
		} finally {
			JdbcUtil.close(pstmt);
		}
	}
}
