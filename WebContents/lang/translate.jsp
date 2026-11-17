<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true"%>
<%@ page import="java.sql.*,java.util.*,my.util.*,my.dao.*,my.ai.*,com.google.gson.JsonArray" %>
<%--
	영어 번역 처리 (화면 없이 JSON 만 돌려줌) : inc/translate.jsp 의 스크립트가 fetch 로 부른다
	받는 값 : t=한글문장1&t=한글문장2 ...  (같은 이름으로 여러 개 → getParameterValues)
	돌려주는 값 : ["English 1", "English 2", ...]  (받은 순서 그대로, 번역 못 하면 원래 한글 그대로)
	순서 : ① 번역 캐시(translation 테이블)에서 찾기 → ② 없는 것만 모아 Ollama 로 한 번에 번역 → ③ 캐시에 저장
	※ JSON 응답과 fetch 는 수업 범위 밖이지만, 화면을 새로 고치지 않고 글자만 바꾸려면 필요해서 쓴다.
--%>
<%
	request.setCharacterEncoding("utf-8");
	String[] koArr = request.getParameterValues("t");
	if (koArr == null) {
		koArr = new String[0];
	}

	String[] enArr = new String[koArr.length];
	List<String> missKo = new ArrayList<String>();     // 캐시에 없어서 AI 에게 물어볼 문장
	List<Integer> missIndex = new ArrayList<Integer>(); // 그 문장이 몇 번째였는지

	Connection conn = ConnectionProvider.getConnection();
	try {
		TranslationDao dao = new TranslationDao();
		for (int i = 0; i < koArr.length && i < 60; i++) {   // 한 번에 최대 60문장
			String ko = koArr[i];
			enArr[i] = ko;   // 기본값 : 번역 못 하면 한글 그대로
			if (ko == null || ko.length() > 700) {
				continue;
			}
			String cached = dao.selectEn(conn, ko);
			if (cached != null) {
				enArr[i] = cached;
			} else if (!missKo.contains(ko)) {
				missKo.add(ko);
				missIndex.add(i);
			}
		}

		if (missKo.size() > 0) {
			try {
				List<String> translated = new Translator().translate(missKo);
				for (int k = 0; k < missKo.size(); k++) {
					dao.insert(conn, missKo.get(k), translated.get(k));
				}
				// 같은 문장이 여러 번 나왔을 수도 있으니 다시 한 번 캐시에서 채운다
				for (int i = 0; i < koArr.length && i < 60; i++) {
					String cached = dao.selectEn(conn, koArr[i]);
					if (cached != null) {
						enArr[i] = cached;
					}
				}
			} catch (Exception e) {
				application.log("영어 번역 실패 (Ollama 연결 확인) : " + e.getMessage());
			}
		}
	} finally {
		JdbcUtil.close(conn);
	}

	JsonArray result = new JsonArray();
	for (int i = 0; i < enArr.length; i++) {
		result.add(enArr[i] == null ? "" : enArr[i]);
	}
	out.print(result.toString());
%>
