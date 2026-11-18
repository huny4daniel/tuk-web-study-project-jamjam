<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*,java.util.*,my.util.*,my.model.*,my.ai.*" %>
<%@ include file="/inc/adminHeader.jsp" %>
<%--
	관리자 AI 도우미 : 우리말 요청 → AI 가 SQL 작성 → 관리자가 확인 → 실행 (2단계)
	  step=make : 요청을 AI 에게 보내 SQL 과 설명을 받아 화면에 보여준다 (아직 실행 안 함)
	  step=run  : 관리자가 확인(수정)한 SQL 을 안전 검사 후 실행
	실행 기록은 세션("AI_LOG")에 최근 10개까지 남긴다.
	(수업 movieollama.jsp 처럼 폼 POST → Java 클래스 → 결과 출력 방식)
--%>
<%
	request.setCharacterEncoding("utf-8");
	String step = request.getParameter("step");
	String ask = request.getParameter("ask");      // 관리자 요청
	String sql = request.getParameter("sql");      // 실행할 SQL
	String explain = request.getParameter("explain");
	String error = null;
	SqlResult result = null;
	AdminAi ai = new AdminAi();

	List<SqlResult> aiLog = (List<SqlResult>) session.getAttribute("AI_LOG");
	if (aiLog == null) {
		aiLog = new ArrayList<SqlResult>();
		session.setAttribute("AI_LOG", aiLog);
	}

	if ("make".equals(step) && ask != null && !ask.trim().equals("")) {
		try {
			String[] made = ai.makeSql(ask.trim());
			sql = made[0];
			explain = made[1];
			String warn = ai.checkSql(sql);
			if (warn != null) {
				error = "AI 가 만든 SQL 이 안전 검사를 통과하지 못했습니다 : " + warn + " (SQL 을 고치거나 요청을 바꿔 보세요)";
			}
		} catch (Exception e) {
			application.log("관리자 AI SQL 생성 실패", e);
			error = "AI 서버에 연결할 수 없거나 답을 해석하지 못했습니다. Ollama(localhost:11435)가 켜져 있는지 확인하세요. 아래에 SQL 을 직접 써서 실행할 수도 있습니다.";
		}
	} else if ("run".equals(step)) {
		error = ai.checkSql(sql);
		if (error == null) {
			Connection conn = ConnectionProvider.getConnection();
			try {
				result = ai.execute(conn, sql);
				aiLog.add(0, result);   // 최근 것이 위로
				if (aiLog.size() > 10) {
					aiLog.remove(10);
				}
			} catch (SQLException e) {
				error = "SQL 실행 오류 : " + e.getMessage();
			} finally {
				JdbcUtil.close(conn);
			}
		}
	}
%>
<c:set var="result" value="<%= result %>"/>
<c:set var="aiLog" value="<%= aiLog %>"/>
<c:set var="sql" value="<%= sql %>"/>
<c:set var="explain" value="<%= explain %>"/>
<c:set var="error" value="<%= error %>"/>

<h2 class="page-title">AI 도우미</h2>
<p class="muted">하고 싶은 일을 우리말로 적으면 AI 가 SQL 을 만들어 줍니다. 내용을 확인한 뒤 [실행]을 눌러야 DB 에 반영됩니다.</p>

<div class="box" style="margin-top:24px;">
	<div class="part">
	<h4 class="sub-title">① 요청하기</h4>
	<form method="post" action="aiConsole.jsp" onsubmit="this.mk.disabled=true; this.mk.value='SQL 만드는 중...';">
		<input type="hidden" name="step" value="make">
		<textarea name="ask" rows="2" maxlength="500" placeholder="예) 이번 달에 체크인하는 예약을 보여줘"><c:out value="${param.ask}"/></textarea>
		<div class="chips" style="margin-top:10px;">
			<button type="button" onclick="setAsk(this)">오늘 이후 체크인하는 예약을 체크인 순으로 보여줘</button>
			<button type="button" onclick="setAsk(this)">답변하지 않은 문의를 보여줘</button>
			<button type="button" onclick="setAsk(this)">WINTER20 쿠폰 할인율을 25로 바꿔줘</button>
			<button type="button" onclick="setAsk(this)">오션뷰 객실의 할인율을 모두 20으로 바꿔줘</button>
			<button type="button" onclick="setAsk(this)">객실별 예약 수와 평균 평점을 보여줘</button>
		</div>
		<input type="submit" name="mk" class="btn btn-gold" value="SQL 만들기">
	</form>
	</div>

	<c:if test="${not empty error}">
		<p class="warn"><c:out value="${error}"/></p>
	</c:if>

	<div class="part">
	<h4 class="sub-title">② 확인하고 실행하기</h4>
	<c:if test="${not empty explain}"><p>AI 설명 : <b><c:out value="${explain}"/></b></p></c:if>
	<form method="post" action="aiConsole.jsp" onsubmit="return confirmRun(this)">
		<input type="hidden" name="step" value="run">
		<input type="hidden" name="ask" value="<c:out value='${param.ask}'/>">
		<input type="hidden" name="explain" value="<c:out value='${explain}'/>">
		<textarea name="sql" rows="4" class="sql" placeholder="select roomType, price from room where viewType = '오션뷰'"><c:out value="${sql}"/></textarea>
		<p class="muted">
			안전 규칙 : select · insert · update · delete 한 문장만 / update · delete 는 where 필수 / 한 번에 20행 넘게 바뀌면 자동 취소 /
			비밀번호·사진 컬럼 사용 불가. 예약 수·평점 같은 통계 컬럼은 직접 바꾸면 실제 기록과 달라질 수 있습니다.
		</p>
		<input type="submit" class="btn btn-gold" value="실행">
	</form>
	</div>
</div>

<c:if test="${result != null}">
	<section class="group" style="margin-top:56px;">
		<div class="group-head"><h3>실행 결과</h3><span class="desc"><c:out value="${result.message}"/></span></div>
		<c:if test="${result.select}">
			<div class="table-scroll">
				<table class="list">
					<tr><c:forEach var="col" items="${result.columns}"><th><c:out value="${col}"/></th></c:forEach></tr>
					<c:forEach var="row" items="${result.rows}">
						<tr><c:forEach var="v" items="${row}"><td><c:out value="${v}"/></td></c:forEach></tr>
					</c:forEach>
				</table>
			</div>
		</c:if>
	</section>
</c:if>

<section class="group" style="margin-top:56px;">
	<div class="group-head"><h3>최근 실행 기록</h3></div>
	<c:if test="${empty aiLog}"><p class="muted">아직 실행한 SQL 이 없습니다.</p></c:if>
	<c:forEach var="log" items="${aiLog}">
		<div class="ai-log"><code><c:out value="${log.sql}"/></code><span class="muted"><c:out value="${log.message}"/></span></div>
	</c:forEach>
</section>

<script>
	function setAsk(btn) {
		document.querySelector("textarea[name=ask]").value = btn.textContent;
	}
	function confirmRun(f) {
		var s = f.sql.value.trim().toLowerCase();
		if (s == "") {
			alert("SQL 을 입력하세요.");
			return false;
		}
		if (s.indexOf("select") != 0) {
			return confirm("DB 내용이 바뀝니다. 실행하시겠습니까?\n\n" + f.sql.value);
		}
		return true;
	}
</script>
<%@ include file="/inc/adminFooter.jsp" %>
