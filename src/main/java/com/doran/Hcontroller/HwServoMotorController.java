package com.doran.Hcontroller;

import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.Map;

import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HwServoMotorController {

    private int degree = 90; // 서보 모터의 기본 각도

    // 서보 모터의 각도를 설정하는 메서드
    public static void setServoMotorDegree(int degree) {
        try {
            String targetUrl = "http://192.168.219.47:5001/set_degree";
            URL url = new URL(targetUrl);
            HttpURLConnection connection = (HttpURLConnection) url.openConnection();
            connection.setRequestMethod("POST");
            connection.setRequestProperty("Content-Type", "application/json");
            connection.setDoOutput(true);

            String jsonInputString = "{\"degree\": " + degree + "}";
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

    // AJAX 요청을 받아 각도 값을 설정하는 메서드
    @PostMapping("/updateServoDegree")
    public Map<String, Object> updateServoDegree(@RequestBody Map<String, Integer> request) {
        if (request.containsKey("degree")) {
            degree = request.get("degree");
            setServoMotorDegree(degree); 
        }

        return Map.of("status", "success", "degree", degree);
    }
}
