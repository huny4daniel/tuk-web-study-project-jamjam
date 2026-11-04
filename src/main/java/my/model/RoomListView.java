package my.model;

import java.util.List;

// 페이징 처리된 객실 목록 한 페이지 분량 (수업 MovieListView 와 같은 구조)
public class RoomListView {
	private List<Room> roomList;     // 현재 페이지에 보여줄 객실들
	private int roomTotalCount;      // 조건에 맞는 전체 객실 수
	private int currentPageNumber;   // 현재 페이지 번호
	private int roomCountPerPage;    // 한 페이지에 보여줄 객실 수
	private int pageTotalCount;      // 전체 페이지 수

	public RoomListView(List<Room> roomList, int roomTotalCount,
			int currentPageNumber, int roomCountPerPage) {
		this.roomList = roomList;
		this.roomTotalCount = roomTotalCount;
		this.currentPageNumber = currentPageNumber;
		this.roomCountPerPage = roomCountPerPage;
		calculatePageTotalCount();
	}

	private void calculatePageTotalCount() {
		if (roomTotalCount == 0) {
			pageTotalCount = 0;
		}
		else {
			pageTotalCount = roomTotalCount / roomCountPerPage;
			if (roomTotalCount % roomCountPerPage > 0) {
				pageTotalCount++;
			}
		}
	}

	public List<Room> getRoomList() {
		return roomList;
	}
	public int getRoomTotalCount() {
		return roomTotalCount;
	}
	public int getCurrentPageNumber() {
		return currentPageNumber;
	}
	public int getRoomCountPerPage() {
		return roomCountPerPage;
	}
	public int getPageTotalCount() {
		return pageTotalCount;
	}
}
