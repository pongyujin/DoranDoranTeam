package com.doran.Hcontroller;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import java.util.Iterator;

@Controller
public class HwLidarController {

    @RequestMapping(value = "/receiveClusters", method = RequestMethod.POST)
    public @ResponseBody String receiveClusters(@RequestBody String jsonData) {
        try {
            // JSON 데이터를 배열로 파싱
            ObjectMapper objectMapper = new ObjectMapper();
            JsonNode rootArray = objectMapper.readTree(jsonData);

            if (!rootArray.isArray()) {
                return "Error: Expected JSON array";
            }

            // 각 클러스터 데이터를 순회하며 출력
            System.out.println("Received clusters:");
            for (JsonNode clusterNode : rootArray) {
                float center_x = clusterNode.get("center_x").floatValue();
                float center_y = clusterNode.get("center_y").floatValue();
                float distance = clusterNode.get("distance").floatValue();
                float angle = clusterNode.get("angle").floatValue();
                int points = clusterNode.get("points").intValue();

                System.out.println("Cluster:");
                System.out.println("center_x: " + center_x);
                System.out.println("center_y: " + center_y);
                System.out.println("distance: " + distance);
                System.out.println("angle: " + angle);
                System.out.println("points: " + points);
            }

            return "Data received successfully";
        } catch (Exception e) {
            e.printStackTrace();
            return "Error processing data";
        }
    }
}
