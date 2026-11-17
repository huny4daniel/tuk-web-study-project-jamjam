<%@ page pageEncoding="UTF-8" %>
<%--
	영어 화면 번역 스크립트 (언어가 영어일 때 footer.jsp 에서 include)
	① 화면에 보이는 한글 글자(본문 글자, 버튼 글자, 입력칸 안내, 그림 설명)를 모은다
	② 같은 문장은 한 번만, 40개씩 묶어서 lang/translate.jsp 로 보낸다 (fetch)
	③ 받은 영어로 글자를 바꾼다
	서버는 번역 캐시(DB)를 먼저 보고, 처음 보는 문장만 Ollama 로 번역한다.
	이 탭에서 이미 번역한 문장은 sessionStorage 에 기억해서 다음 페이지에서는 바로 바꾼다.
	※ 수업 범위 밖의 자바스크립트(fetch, TreeWalker)를 쓰지만, JSP 를 고치지 않고 모든 화면을 번역하려면 필요해서 쓴다.
--%>
<script>
(function () {
	var HANGUL = /[가-힣]/;   // 한글이 들어 있는 글자만 번역
	var url = "${pageContext.request.contextPath}/lang/translate.jsp";
	var items = [];   // { el: 바꿀 대상, attr: 속성 이름(글자면 null), key: 번역할 한글, pre/post: 앞뒤 공백 }

	document.documentElement.lang = "en";

	// ① 본문 글자 모으기 (script, style, 입력 중인 textarea 는 건너뜀)
	var walker = document.createTreeWalker(document.body, NodeFilter.SHOW_TEXT, {
		acceptNode: function (node) {
			var p = node.parentNode.nodeName;
			if (p == "SCRIPT" || p == "STYLE" || p == "TEXTAREA") return NodeFilter.FILTER_REJECT;
			return HANGUL.test(node.nodeValue) ? NodeFilter.FILTER_ACCEPT : NodeFilter.FILTER_REJECT;
		}
	});
	while (walker.nextNode()) {
		var v = walker.currentNode.nodeValue;
		items.push({ el: walker.currentNode, attr: null, key: v.replace(/\s+/g, " ").trim(),
				pre: /^\s/.test(v) ? " " : "", post: /\s$/.test(v) ? " " : "" });
	}
	// 버튼 글자, 입력칸 안내 글, 그림 설명, 말풍선
	var els = document.querySelectorAll("[placeholder], [title], img[alt], input[type=submit], input[type=button]");
	for (var i = 0; i < els.length; i++) {
		var names = ["placeholder", "title", "alt", "value"];
		for (var j = 0; j < names.length; j++) {
			var a = els[i].getAttribute(names[j]);
			if (a && HANGUL.test(a) && !(names[j] == "value" && els[i].type != "submit" && els[i].type != "button")) {
				items.push({ el: els[i], attr: names[j], key: a.replace(/\s+/g, " ").trim(), pre: "", post: "" });
			}
		}
	}
	if (HANGUL.test(document.title)) {
		items.push({ el: null, attr: "title", key: document.title, pre: "", post: "" });
	}

	// 이 탭에서 전에 번역해 둔 문장
	var memory = {};
	try { memory = JSON.parse(sessionStorage.getItem("JAMJAM_EN") || "{}"); } catch (e) { memory = {}; }

	// 숫자만 다른 문구(가격, 평수, 호실, 인원)는 AI 에게 묻지 않고 규칙으로 바로 바꾼다
	var RULES = [
		[/^([\d,]+)원(~?)$/, "KRW $1$2"],
		[/^([\d,]+)원 결제하기$/, "Pay KRW $1"],
		[/^(\d+)평 \((\d+)㎡\)$/, "$1 pyeong ($2㎡)"],
		[/^(\d+)평 · (\d+)㎡$/, "$1 pyeong · $2㎡"],
		[/^(\d+)평$/, "$1 pyeong"],
		[/^ROOM (\d+)호$/, "ROOM $1"],
		[/^(\d+)호$/, "Room $1"],
		[/^기준 (\d+)인 \(최대 (\d+)인\) · 침대 (\d+)개 ·$/, "Standard $1 · Max $2 guests · $3 bed(s) ·"],
		[/^기준 (\d+)인 \/ 최대 (\d+)인$/, "Standard $1 / Max $2 guests"],
		[/^(\d+)개$/, "$1"],
		[/^(\d+)명$/, "$1 guests"],
		[/^(\d+)박$/, "$1 night(s)"],
		[/^최대 (\d+)인$/, "Max $1 guests"],
		[/^인원 \(최대 (\d+)명\)$/, "Guests (max $1)"],
		[/^\/ 1박 \(기준 (\d+)인\)$/, "/ night (for $1)"],
		[/^기준 인원 초과 시 1인당 1박 \+([\d,]+)원$/, "+KRW $1 per extra guest per night"],
		[/^(\d+)% 할인$/, "$1% off"],
		[/^\((\d+)\)$/, "($1)"],
		[/^· 리뷰 (\d+)개 · 누적 예약 (\d+)건$/, "· $1 reviews · $2 bookings"],
		[/^투숙객 리뷰 \((\d+)\)$/, "Guest Reviews ($1)"],
		[/^1박 × (\d+)박$/, "Per night × $1 nights"],
		[/^인원 추가 \((\d+)명\)$/, "Extra guests ($1)"],
		[/^([+−])([\d,]+)원$/, "$1KRW $2"],
		[/^쿠폰 할인 \((\d+)%\)$/, "Coupon discount ($1%)"],
		[/^정가 ([\d,]+)원에서 (\d+)% 할인$/, "$2% off the list price of KRW $1"],
		[/^\(기준 (\d+)명 \/ 최대 (\d+)명\)$/, "(standard $1 / max $2 guests)"],
		[/^(\d+)건$/, "$1"],
		[/^· 예약일 (.+)$/, "· Booked $1"],
		[/^· 가입일 (.+)$/, "· Joined $1"],
		[/^(\S+ ~ \S+) 숙박$/, "Stay $1"],
		[/^· 쿠폰 (\S+) 적용$/, "· Coupon $1 applied"],
		[/^쿠폰 (\S+)$/, "Coupon $1"],
		[/^(\S+) (\d+)호$/, "$1 Room $2"],
		[/^(.+) 예약 마감$/, "Booked $1"],
		[/^쿠폰 \(내 쿠폰함 (\d+)장\)$/, "Coupons (you have $1)"],
		[/^기준 (\d+)인 \(최대 (\d+)인\) · 침대 (\d+)개 ·$/, "Standard $1 · Max $2 guests · $3 bed(s) ·"],
		[/^기준 (\d+)인 \(최대 (\d+)인\) · 온돌 \(요\) ·$/, "Standard $1 · Max $2 guests · Ondol floor bedding ·"],
		[/^침대 (\d+)개$/, "$1 bed(s)"],
		[/^(.+) · 침대 (\d+)개$/, "$1 · $2 bed(s)"]
	];
	for (var i = 0; i < items.length; i++) {
		var key = items[i].key;
		if (memory[key]) continue;
		for (var r = 0; r < RULES.length; r++) {
			if (RULES[r][0].test(key)) {
				memory[key] = key.replace(RULES[r][0], RULES[r][1]);
				break;
			}
		}
	}

	function apply() {
		for (var i = 0; i < items.length; i++) {
			var it = items[i];
			var en = memory[it.key];
			if (!en) continue;
			if (it.el == null) document.title = en;
			else if (it.attr == null) it.el.nodeValue = it.pre + en + it.post;
			else it.el.setAttribute(it.attr, en);
		}
	}
	apply();

	// ② 아직 모르는 문장만 40개씩 서버로
	var todo = [];
	for (var i = 0; i < items.length; i++) {
		if (!memory[items[i].key] && todo.indexOf(items[i].key) < 0) todo.push(items[i].key);
	}
	if (todo.length == 0) return;
	document.documentElement.classList.add("translating");

	var left = 0;
	for (var start = 0; start < todo.length; start += 40) {
		var batch = todo.slice(start, start + 40);
		var body = new URLSearchParams();
		for (var k = 0; k < batch.length; k++) body.append("t", batch[k]);
		left++;
		(function (batch) {
			fetch(url, { method: "POST", body: body })
				.then(function (res) { return res.json(); })
				.then(function (enList) {
					// ③ 받은 번역을 기억하고 화면에 반영 (한글 그대로 돌아온 것은 번역 실패)
					for (var k = 0; k < batch.length; k++) {
						if (enList[k] && enList[k] != batch[k]) memory[batch[k]] = enList[k];
					}
					try { sessionStorage.setItem("JAMJAM_EN", JSON.stringify(memory)); } catch (e) {}
					apply();
				})
				.catch(function () {})
				.then(function () {
					left--;
					if (left == 0) document.documentElement.classList.remove("translating");
				});
		})(batch);
	}
})();
</script>
