package com.doran.Hcontroller;

import org.springframework.web.bind.annotation.*;
import org.json.JSONObject;

@RestController
@RequestMapping("/controller")
public class HwBatteryController {

    @PostMapping("/receive_voltage")
    public String receiveVoltage(@RequestBody String jsonData) {
        try {
            // JSON 파싱
            JSONObject json = new JSONObject(jsonData);
            double voltage = json.getDouble("voltage");

            // 전압 데이터 출력
            System.out.println("Received voltage: " + voltage + " V");
            return "Voltage received successfully";

        } catch (Exception e) {
            e.printStackTrace();
            return "Error processing voltage data";
        }
    }
}
