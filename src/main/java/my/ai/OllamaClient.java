package my.ai;

import java.io.IOException;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.time.Duration;

import com.google.gson.JsonObject;
import com.google.gson.JsonParser;

// Ollama(로컬 AI 서버)에 질문을 보내고 답을 받는 클래스
// ※ 수업 pro0928 의 my/ai/OllamaClient.java 와 같은 코드 (주소, 모델도 수업과 같음)
//    챗봇(HotelChatbot), 관리자 AI(AdminAi), 영어 번역(Translator)이 모두 이 클래스를 쓴다.
//
// 동작 : {"model": 모델, "prompt": 질문, "stream": false} 를 JSON 으로 POST
//        → 응답 JSON 의 "response" 값이 AI 의 답
public class OllamaClient {

	// 수업 환경의 Ollama 주소와 모델 (다른 PC 에서 쓰려면 여기만 바꾸면 됨)
	private static final String API_URL = "http://localhost:11435/api/generate";
	private static final String MODEL = "gemma3:12b";

	private final HttpClient client = HttpClient.newBuilder()
			.connectTimeout(Duration.ofSeconds(10))
			.build();

	public String ask(String prompt) throws IOException, InterruptedException {
		// 보낼 JSON 만들기 (gson 사용, 수업과 같음)
		JsonObject body = new JsonObject();
		body.addProperty("model", MODEL);
		body.addProperty("prompt", prompt);
		body.addProperty("stream", false);   // 답을 한 번에 받기

		HttpRequest request = HttpRequest.newBuilder()
				.uri(URI.create(API_URL))
				.timeout(Duration.ofSeconds(180))
				.header("Content-Type", "application/json")
				.POST(HttpRequest.BodyPublishers.ofString(body.toString(), StandardCharsets.UTF_8))
				.build();

		HttpResponse<String> response = client.send(request,
				HttpResponse.BodyHandlers.ofString(StandardCharsets.UTF_8));

		if (response.statusCode() != 200) {
			throw new IOException("Ollama 오류: HTTP " + response.statusCode());
		}

		JsonObject result = JsonParser.parseString(response.body()).getAsJsonObject();
		if (!result.has("response") || result.get("response").isJsonNull()) {
			throw new IOException("Ollama 응답에 답변이 없습니다.");
		}
		return result.get("response").getAsString();
	}
}
