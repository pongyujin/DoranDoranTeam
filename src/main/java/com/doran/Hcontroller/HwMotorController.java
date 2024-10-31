package com.doran.Hcontroller;

import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.Map;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HwMotorController {

	private int speed = 0; // 속도 값을 서버 측에서 관리

	// 모터 속도를 설정하는 메서드
	public static void setMotorSpeed(int speed) {
		try {
			// 라즈베리파이의 IP와 Flask 서버 포트에 맞게 URL 설정
			String targetUrl = "http://192.168.219.47:5000/set_speed";

			// URL 객체 생성 (요청을 보낼 대상 URL)
			URL url = new URL(targetUrl);
			// URL 연결을 HttpURLConnection으로 열기
			HttpURLConnection connection = (HttpURLConnection) url.openConnection();

			// HTTP 요청 설정 (POST 요청 사용)
			connection.setRequestMethod("POST");
			connection.setRequestProperty("Content-Type", "application/json");
			connection.setDoOutput(true);

			// JSON 형식의 데이터 생성
			String jsonInputString = "{\"speed\": " + speed + "}";

			// 요청 본문에 JSON 데이터를 전송
			try (OutputStream os = connection.getOutputStream()) {
				byte[] input = jsonInputString.getBytes(StandardCharsets.UTF_8);
				os.write(input, 0, input.length);
			}

			int responseCode = connection.getResponseCode();
			System.out.println("Response Code: " + responseCode);

			connection.disconnect();
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	// 클라이언트로부터 AJAX 요청을 받아 속도 값을 설정하는 메서드
	@PostMapping("/updateSpeed")
	public ResponseEntity<Map<String, Object>> updateSpeed(@RequestBody Map<String, Integer> request) {
		Map<String, Object> responseMap = new HashMap<>();

		if (request.containsKey("speed")) {
			speed = request.get("speed");
			setMotorSpeed(speed);

			// 현재 속도를 JSON으로 반환
			responseMap.put("status", "success");
			responseMap.put("speed", speed);
		} else {
			responseMap.put("status", "error");
			responseMap.put("message", "speed가 필요합니다.");
			return ResponseEntity.badRequest().body(responseMap);
		}

		return ResponseEntity.ok(responseMap);
	}
}
