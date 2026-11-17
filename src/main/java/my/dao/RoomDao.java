package my.dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

import my.model.Room;
import my.model.RoomListView;
import my.model.RoomSearch;
import my.util.JdbcUtil;

// room 테이블 담당 DAO
public class RoomDao {

	// 한 페이지에 보여줄 객실 수
	private static final int ROOM_COUNT_PER_PAGE = 6;

	// 사진(photo)은 크기가 커서 목록에서는 빼고 가져온다. 사진은 selectPhoto() 로 따로.
	private static final String COLUMNS =
			"roomId, roomType, roomNo, roomSize, price, discountRate, capacity, baseGuests, extraPrice, bedCount, breakfast, pet,"
			+ " amenities, description, avgRating, reviewCount, resCount";

	// ResultSet 한 줄 -> Room 객체 (여러 메서드에서 같이 쓰려고 따로 뺌)
	private Room makeRoom(ResultSet rs) throws SQLException {
		Room room = new Room();
		room.setRoomId(rs.getInt("roomId"));
		room.setRoomType(rs.getString("roomType"));
		room.setRoomNo(rs.getString("roomNo"));
		room.setRoomSize(rs.getInt("roomSize"));
		room.setPrice(rs.getInt("price"));
		room.setDiscountRate(rs.getInt("discountRate"));
		room.setCapacity(rs.getInt("capacity"));
		room.setBaseGuests(rs.getInt("baseGuests"));
		room.setExtraPrice(rs.getInt("extraPrice"));
		room.setBedCount(rs.getInt("bedCount"));
		room.setBreakfast(rs.getInt("breakfast"));
		room.setPet(rs.getInt("pet"));
		room.setAmenities(rs.getString("amenities"));
		room.setDescription(rs.getString("description"));
		room.setAvgRating(rs.getDouble("avgRating"));
		room.setReviewCount(rs.getInt("reviewCount"));
		room.setResCount(rs.getInt("resCount"));
		return room;
	}

	// ------------------------------------------------------------
	// ★ 검색 조건 where 절 (? 7개, 순서 고정)
	//   조건을 안 골랐을 때도 항상 참이 되는 값을 넣어서 SQL 하나로 처리한다.
	//     인원      capacity  >= ?   (안 고르면 1)
	//     침대 수   bedCount  >= ?   (안 고르면 0 -> 항상 참)
	//     조식      breakfast >= ?   (체크하면 1 -> 조식 있는 객실만, 안 하면 0 -> 전부)
	//     반려동물  pet       >= ?   (위와 같음)
	//     편의시설  amenities like ? ('%욕조%', 안 고르면 '%%' -> 전부)
	//     날짜      [예약 가능한 객실만] 을 체크했을 때만 그 기간에 예약이 있는 객실을 not in 으로 제외
	//               (체크 안 하면 예약된 객실도 목록에 나오고 화면에서 SOLD OUT 으로 표시)
	//               겹치는 조건 : 기존 체크인 < 새 체크아웃 그리고 기존 체크아웃 > 새 체크인
	// ------------------------------------------------------------
	private static final String WHERE =
			" where capacity >= ? and bedCount >= ? and breakfast >= ? and pet >= ? and amenities like ?"
			+ " and roomId not in (select roomId from reservation"
			+ " where status = '예약완료' and checkIn < ? and checkOut > ?)";

	// 위 WHERE 의 ? 7개에 순서대로 값 넣기
	private void setSearch(PreparedStatement pstmt, RoomSearch search) throws SQLException {
		pstmt.setInt(1, RoomSearch.has(search.getGuests()) ? Integer.parseInt(search.getGuests()) : 1);
		pstmt.setInt(2, RoomSearch.has(search.getBedCount()) ? Integer.parseInt(search.getBedCount()) : 0);
		pstmt.setInt(3, "1".equals(search.getBreakfast()) ? 1 : 0);
		pstmt.setInt(4, "1".equals(search.getPet()) ? 1 : 0);
		pstmt.setString(5, "%" + (search.getAmenity() == null ? "" : search.getAmenity()) + "%");
		if (search.isDateSelected() && "1".equals(search.getAvailable())) {
			pstmt.setString(6, search.getCheckOut());
			pstmt.setString(7, search.getCheckIn());
		} else {
			// 날짜를 안 넣었으면 절대 겹칠 수 없는 날짜를 넣어서 제외되는 객실이 없게 함
			pstmt.setString(6, "1000-01-01");
			pstmt.setString(7, "9999-12-31");
		}
	}

	// 정렬 기준 -> order by 절
	// 사용자가 보낸 값을 SQL 에 그대로 붙이면 위험하므로 정해진 값만 골라서 쓴다.
	private String makeOrderBy(String sort) {
		if ("price".equals(sort))      return " order by (price * (100 - discountRate) / 100) asc";
		if ("priceDesc".equals(sort))  return " order by (price * (100 - discountRate) / 100) desc";
		if ("rating".equals(sort))     return " order by avgRating desc, reviewCount desc";
		if ("popular".equals(sort))    return " order by resCount desc";
		return " order by roomId asc";
	}

	// 조건에 맞는 객실 수
	public int selectCount(Connection conn, RoomSearch search) throws SQLException {
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		try {
			pstmt = conn.prepareStatement("select count(*) from room" + WHERE);
			setSearch(pstmt, search);
			rs = pstmt.executeQuery();
			rs.next();
			return rs.getInt(1);
		} finally {
			JdbcUtil.close(rs);
			JdbcUtil.close(pstmt);
		}
	}

	// 조건에 맞는 객실 중 offset 번째부터 count 개 (수업 selectListLimit 과 같은 limit ?, ?)
	public List<Room> selectList(Connection conn, RoomSearch search, int offset, int count) throws SQLException {
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		List<Room> roomList = new ArrayList<Room>();
		try {
			pstmt = conn.prepareStatement("select " + COLUMNS + " from room" + WHERE
					+ makeOrderBy(search.getSort()) + " limit ?, ?");
			setSearch(pstmt, search);
			pstmt.setInt(8, offset);
			pstmt.setInt(9, count);
			rs = pstmt.executeQuery();
			while (rs.next()) {
				roomList.add(makeRoom(rs));
			}
		} finally {
			JdbcUtil.close(rs);
			JdbcUtil.close(pstmt);
		}
		return roomList;
	}

	// 객실 목록 한 페이지 (수업 MovieDao.getMovieList 와 같은 흐름)
	public RoomListView getRoomList(Connection conn, RoomSearch search, int pageNumber) throws SQLException {
		int totalCount = selectCount(conn, search);
		List<Room> roomList = new ArrayList<Room>();
		int currentPageNumber = pageNumber;

		if (totalCount > 0) {
			int firstRow = (pageNumber - 1) * ROOM_COUNT_PER_PAGE;
			roomList = selectList(conn, search, firstRow, ROOM_COUNT_PER_PAGE);
		} else {
			currentPageNumber = 0;
		}
		return new RoomListView(roomList, totalCount, currentPageNumber, ROOM_COUNT_PER_PAGE);
	}

	// 메인 화면용 인기 객실 n개
	public List<Room> selectPopular(Connection conn, int n) throws SQLException {
		RoomSearch search = new RoomSearch();
		search.setSort("popular");
		return selectList(conn, search, 0, n);
	}

	// 관리자 객실 목록용 (조건 없이 전부)
	public List<Room> selectAll(Connection conn) throws SQLException {
		return selectList(conn, new RoomSearch(), 0, 1000);
	}

	public Room selectById(Connection conn, int roomId) throws SQLException {
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		Room room = null;
		try {
			pstmt = conn.prepareStatement("select " + COLUMNS + " from room where roomId = ?");
			pstmt.setInt(1, roomId);
			rs = pstmt.executeQuery();
			if (rs.next()) {
				room = makeRoom(rs);
			}
		} finally {
			JdbcUtil.close(rs);
			JdbcUtil.close(pstmt);
		}
		return room;
	}

	public void insert(Connection conn, Room room) throws SQLException {
		PreparedStatement pstmt = null;
		try {
			pstmt = conn.prepareStatement(
					"insert into room (roomType, roomNo, price, discountRate, capacity, bedCount,"
					+ " breakfast, pet, amenities, description, photo, photoType, baseGuests, extraPrice, roomSize)"
					+ " values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
			pstmt.setString(1, room.getRoomType());
			pstmt.setString(2, room.getRoomNo());
			pstmt.setInt(3, room.getPrice());
			pstmt.setInt(4, room.getDiscountRate());
			pstmt.setInt(5, room.getCapacity());
			pstmt.setInt(6, room.getBedCount());
			pstmt.setInt(7, room.getBreakfast());
			pstmt.setInt(8, room.getPet());
			pstmt.setString(9, room.getAmenities());
			pstmt.setString(10, room.getDescription());
			pstmt.setBytes(11, room.getPhotoData());   // 사진 파일 내용(byte 배열)을 그대로 저장
			pstmt.setString(12, room.getPhotoType());
			pstmt.setInt(13, room.getBaseGuests());
			pstmt.setInt(14, room.getExtraPrice());
			pstmt.setInt(15, room.getRoomSize());
			pstmt.executeUpdate();
		} finally {
			JdbcUtil.close(pstmt);
		}
	}

	// 사진을 뺀 나머지 정보 수정
	public void update(Connection conn, Room room) throws SQLException {
		PreparedStatement pstmt = null;
		try {
			pstmt = conn.prepareStatement(
					"update room set roomType=?, roomNo=?, price=?, discountRate=?, capacity=?, bedCount=?,"
					+ " breakfast=?, pet=?, amenities=?, description=?, baseGuests=?, extraPrice=?, roomSize=? where roomId=?");
			pstmt.setString(1, room.getRoomType());
			pstmt.setString(2, room.getRoomNo());
			pstmt.setInt(3, room.getPrice());
			pstmt.setInt(4, room.getDiscountRate());
			pstmt.setInt(5, room.getCapacity());
			pstmt.setInt(6, room.getBedCount());
			pstmt.setInt(7, room.getBreakfast());
			pstmt.setInt(8, room.getPet());
			pstmt.setString(9, room.getAmenities());
			pstmt.setString(10, room.getDescription());
			pstmt.setInt(11, room.getBaseGuests());
			pstmt.setInt(12, room.getExtraPrice());
			pstmt.setInt(13, room.getRoomSize());
			pstmt.setInt(14, room.getRoomId());
			pstmt.executeUpdate();
		} finally {
			JdbcUtil.close(pstmt);
		}
	}

	// 사진만 수정 (새 사진을 올린 경우에만 호출)
	public void updatePhoto(Connection conn, Room room) throws SQLException {
		PreparedStatement pstmt = null;
		try {
			pstmt = conn.prepareStatement("update room set photo=?, photoType=? where roomId=?");
			pstmt.setBytes(1, room.getPhotoData());
			pstmt.setString(2, room.getPhotoType());
			pstmt.setInt(3, room.getRoomId());
			pstmt.executeUpdate();
		} finally {
			JdbcUtil.close(pstmt);
		}
	}

	// ★ 예약 수 +1 / -1 (수업 MovieDao.updateFreq 와 같은 방식) : 인기순 정렬에 사용
	//   예약하면 updateResCount(conn, roomId, 1), 취소하면 updateResCount(conn, roomId, -1)
	public void updateResCount(Connection conn, int roomId, int change) throws SQLException {
		PreparedStatement pstmt = null;
		try {
			pstmt = conn.prepareStatement("update room set resCount = resCount + ? where roomId = ?");
			pstmt.setInt(1, change);
			pstmt.setInt(2, roomId);
			pstmt.executeUpdate();
		} finally {
			JdbcUtil.close(pstmt);
		}
	}

	// ★ 리뷰 평점 반영 : 새 평균 = (기존 평균 x 기존 개수 + 새 평점) / (기존 개수 + 1)
	public void addRating(Connection conn, int roomId, int rating) throws SQLException {
		Room room = selectById(conn, roomId);
		int count = room.getReviewCount() + 1;
		double avg = (room.getAvgRating() * room.getReviewCount() + rating) / count;
		updateRating(conn, roomId, avg, count);
	}

	// 리뷰 삭제 시 평점 빼기 : 새 평균 = (기존 평균 x 기존 개수 - 지운 평점) / (기존 개수 - 1)
	public void removeRating(Connection conn, int roomId, int rating) throws SQLException {
		Room room = selectById(conn, roomId);
		int count = room.getReviewCount() - 1;
		double avg = 0;
		if (count > 0) {
			avg = (room.getAvgRating() * room.getReviewCount() - rating) / count;
		}
		updateRating(conn, roomId, avg, count);
	}

	private void updateRating(Connection conn, int roomId, double avgRating, int reviewCount) throws SQLException {
		PreparedStatement pstmt = null;
		try {
			pstmt = conn.prepareStatement("update room set avgRating = ?, reviewCount = ? where roomId = ?");
			pstmt.setDouble(1, avgRating);
			pstmt.setInt(2, reviewCount);
			pstmt.setInt(3, roomId);
			pstmt.executeUpdate();
		} finally {
			JdbcUtil.close(pstmt);
		}
	}

	// 객실 사진만 가져오기 (room/photo.jsp 에서 사용). 사진이 없으면 null
	public Room selectPhoto(Connection conn, int roomId) throws SQLException {
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		Room room = null;
		try {
			pstmt = conn.prepareStatement("select photo, photoType from room where roomId = ? and photo is not null");
			pstmt.setInt(1, roomId);
			rs = pstmt.executeQuery();
			if (rs.next()) {
				room = new Room();
				room.setPhotoData(rs.getBytes("photo"));
				room.setPhotoType(rs.getString("photoType"));
			}
		} finally {
			JdbcUtil.close(rs);
			JdbcUtil.close(pstmt);
		}
		return room;
	}

	public void deleteById(Connection conn, int roomId) throws SQLException {
		PreparedStatement pstmt = null;
		try {
			pstmt = conn.prepareStatement("delete from room where roomId = ?");
			pstmt.setInt(1, roomId);
			pstmt.executeUpdate();
		} finally {
			JdbcUtil.close(pstmt);
		}
	}
}
