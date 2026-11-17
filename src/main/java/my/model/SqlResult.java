package my.model;

import java.util.ArrayList;
import java.util.List;

// 관리자 AI 화면에서 SQL 을 실행한 결과
//   select 이면 columns(컬럼 이름)와 rows(행마다 글자 목록)
//   insert / update / delete 이면 updateCount(바뀐 행 수)
// Serializable : 세션(실행 기록)에 넣는 객체라서, 서버를 다시 켤 때 톰캣이 세션을 저장했다가 되살릴 수 있게 함
public class SqlResult implements java.io.Serializable {
	private String sql;
	private boolean select;
	private List<String> columns = new ArrayList<String>();
	private List<List<String>> rows = new ArrayList<List<String>>();
	private int updateCount;
	private String message;   // 결과 안내 또는 오류 메시지

	public String getSql() {
		return sql;
	}
	public void setSql(String sql) {
		this.sql = sql;
	}
	public boolean isSelect() {
		return select;
	}
	public void setSelect(boolean select) {
		this.select = select;
	}
	public List<String> getColumns() {
		return columns;
	}
	public List<List<String>> getRows() {
		return rows;
	}
	public int getUpdateCount() {
		return updateCount;
	}
	public void setUpdateCount(int updateCount) {
		this.updateCount = updateCount;
	}
	public String getMessage() {
		return message;
	}
	public void setMessage(String message) {
		this.message = message;
	}
}
