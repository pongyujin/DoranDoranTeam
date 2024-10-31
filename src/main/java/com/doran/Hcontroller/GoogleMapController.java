package com.doran.Hcontroller;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.client.RestTemplate;

import com.doran.Mcontroller.SailController;
import com.doran.entity.Coordinate;
import com.doran.hardware.aStartService;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

// 구글 api로 지도 및 경로를 표시하는 controller
@RestController
public class GoogleMapController {

	private final String apiKey = "AIzaSyDtt1tmfQ-lTeQaCimRBn2PQPTlCLRO6Pg";
	private final String placeKey = "AIzaSyAW9QwdMPgIykOFaLdCX5ZJTQOED8FVLfg";

	private final aStartService aStartService;
	
	@Autowired
    public GoogleMapController(aStartService pythonService) {
        this.aStartService = pythonService;
    }

	// 1. 구글 마커 표시 api
	@GetMapping("/marker")
	public String getLocationInfo(@RequestParam double latitude, @RequestParam double longitude) {
		RestTemplate restTemplate = new RestTemplate();

		String url = String.format("https://maps.googleapis.com/maps/api/geocode/json?latlng=%s,%s&language=ko&key=%s",
				latitude, longitude, apiKey);

		String response = restTemplate.getForObject(url, String.class);
		return response; // JSON 응답을 반환합니다.
	}

	// 2. a* 경로 좌표 리스트 변환(문자열 정보를 api에 쓸 수 있는 json 형태로)
	@RequestMapping("/flightPlanCoordinates")
	public List<Coordinate> flightPlanCoordinates(@RequestBody String waypoints) {

		try { // 경유지 좌표 python 코드에 맞게 파싱
	        ObjectMapper objectMapper = new ObjectMapper();

	        List<Coordinate> waypointCoordinates = objectMapper.readValue(waypoints, new TypeReference<List<Coordinate>>(){});

		    StringBuilder waypointBuild = new StringBuilder("[");
		    for (int i = 0; i < waypointCoordinates.size(); i++) {
		        Coordinate coordinate = waypointCoordinates.get(i);
		        waypointBuild.append("(").append(coordinate.getLat()).append(", ").append(coordinate.getLng()).append(")");

		        // 마지막 요소 뒤에는 쉼표를 추가하지 않음
		        if (i < waypointCoordinates.size() - 1) {
		        	waypointBuild.append(", ");
		        }
		    }
		    waypointBuild.append("]");
		    
		    waypoints = waypointBuild.toString();

		} catch (IOException e) {
			
			e.printStackTrace();
		}
		
		String coordinateData = "위도: 34.500000, 경도: 128.730000\r\n" + "위도: 34.503015, 경도: 128.722764\r\n"
				+ "위도: 34.508543, 경도: 128.717588\r\n" + "위도: 34.514070, 경도: 128.712412\r\n"
				+ "위도: 34.519598, 경도: 128.707236\r\n" + "위도: 34.525126, 경도: 128.702060\r\n"
				+ "위도: 34.530653, 경도: 128.702060\r\n" + "위도: 34.536181, 경도: 128.702060\r\n"
				+ "위도: 34.541709, 경도: 128.702060\r\n" + "위도: 34.547236, 경도: 128.702060\r\n"
				+ "위도: 34.552764, 경도: 128.702060\r\n" + "위도: 34.558291, 경도: 128.702060\r\n"
				+ "위도: 34.563819, 경도: 128.702060\r\n" + "위도: 34.569347, 경도: 128.702060\r\n"
				+ "위도: 34.574874, 경도: 128.702060\r\n" + "위도: 34.580402, 경도: 128.702060\r\n"
				+ "위도: 34.585930, 경도: 128.702060\r\n" + "위도: 34.591457, 경도: 128.702060\r\n"
				+ "위도: 34.596985, 경도: 128.702060\r\n" + "위도: 34.602513, 경도: 128.702060\r\n"
				+ "위도: 34.607985, 경도: 128.710016\r\n" + "위도: 34.614002, 경도: 128.716287\r\n"
				+ "위도: 34.620020, 경도: 128.722558\r\n" + "위도: 34.626037, 경도: 128.728829\r\n"
				+ "위도: 34.632055, 경도: 128.735100\r\n" + "위도: 34.638072, 경도: 128.741371\r\n"
				+ "위도: 34.644090, 경도: 128.747642\r\n" + "위도: 34.650107, 경도: 128.753913\r\n"
				+ "위도: 34.656125, 경도: 128.760184\r\n" + "위도: 34.662142, 경도: 128.766455\r\n"
				+ "위도: 34.668160, 경도: 128.772726\r\n" + "위도: 34.674177, 경도: 128.778997\r\n"
				+ "위도: 34.680195, 경도: 128.785268\r\n" + "위도: 34.686212, 경도: 128.791539\r\n"
				+ "위도: 34.692230, 경도: 128.797810\r\n" + "위도: 34.698248, 경도: 128.804081\r\n"
				+ "위도: 34.704265, 경도: 128.810353\r\n" + "위도: 34.710283, 경도: 128.816624\r\n"
				+ "위도: 34.716300, 경도: 128.822895\r\n" + "위도: 34.722318, 경도: 128.829166\r\n"
				+ "위도: 34.728335, 경도: 128.835437\r\n" + "위도: 34.734353, 경도: 128.841708\r\n"
				+ "위도: 34.740370, 경도: 128.847979\r\n" + "위도: 34.746388, 경도: 128.854250\r\n"
				+ "위도: 34.752405, 경도: 128.860521\r\n" + "위도: 34.758423, 경도: 128.866792\r\n"
				+ "위도: 34.764440, 경도: 128.873063\r\n" + "위도: 34.770458, 경도: 128.879334\r\n"
				+ "위도: 34.776475, 경도: 128.885605\r\n" + "위도: 34.782493, 경도: 128.891876\r\n"
				+ "위도: 34.788510, 경도: 128.898147\r\n" + "위도: 34.794528, 경도: 128.904418\r\n"
				+ "위도: 34.800545, 경도: 128.910689\r\n" + "위도: 34.800545, 경도: 128.916960\r\n"
				+ "위도: 34.800545, 경도: 128.923231\r\n" + "위도: 34.800545, 경도: 128.929503\r\n"
				+ "위도: 34.800545, 경도: 128.935774\r\n" + "위도: 34.800545, 경도: 128.942045\r\n"
				+ "위도: 34.800545, 경도: 128.948316\r\n" + "위도: 34.806984, 경도: 128.942596\r\n"
				+ "위도: 34.814117, 경도: 128.937328\r\n" + "위도: 34.821250, 경도: 128.932060\r\n"
				+ "위도: 34.828383, 경도: 128.926792\r\n" + "위도: 34.835516, 경도: 128.921524\r\n"
				+ "위도: 34.842649, 경도: 128.916256\r\n" + "위도: 34.849782, 경도: 128.910988\r\n"
				+ "위도: 34.856915, 경도: 128.905720\r\n" + "위도: 34.864048, 경도: 128.900452\r\n"
				+ "위도: 34.871180, 경도: 128.895184\r\n" + "위도: 34.878313, 경도: 128.889916\r\n"
				+ "위도: 34.885446, 경도: 128.884648\r\n" + "위도: 34.892579, 경도: 128.879381\r\n"
				+ "위도: 34.899712, 경도: 128.874113\r\n" + "위도: 34.906845, 경도: 128.879381\r\n"
				+ "위도: 34.913978, 경도: 128.884648\r\n" + "위도: 34.921111, 경도: 128.889916\r\n"
				+ "위도: 34.928244, 경도: 128.895184\r\n" + "위도: 34.935377, 경도: 128.900452\r\n"
				+ "위도: 34.942510, 경도: 128.900452\r\n" + "위도: 34.949643, 경도: 128.900452\r\n"
				+ "위도: 34.956776, 경도: 128.900452\r\n" + "위도: 34.963909, 경도: 128.900452\r\n"
				+ "위도: 34.971042, 경도: 128.900452\r\n" + "위도: 34.978175, 경도: 128.900452\r\n"
				+ "위도: 34.985307, 경도: 128.900452\r\n" + "위도: 34.992440, 경도: 128.900452\r\n"
				+ "위도: 34.999573, 경도: 128.900452\r\n" + "위도: 35.006706, 경도: 128.900452\r\n"
				+ "위도: 35.013839, 경도: 128.900452\r\n" + "위도: 35.020972, 경도: 128.900452\r\n"
				+ "위도: 35.028105, 경도: 128.900452\r\n" + "위도: 35.035238, 경도: 128.900452\r\n"
				+ "위도: 35.042371, 경도: 128.900452\r\n" + "위도: 35.049504, 경도: 128.900452\r\n"
				+ "위도: 35.056637, 경도: 128.900452\r\n" + "위도: 35.063770, 경도: 128.900452\r\n"
				+ "위도: 35.070903, 경도: 128.900452\r\n" + "위도: 35.078036, 경도: 128.900452\r\n"
				+ "위도: 35.085169, 경도: 128.900452\r\n" + "위도: 35.092302, 경도: 128.900452\r\n"
				+ "위도: 35.099434, 경도: 128.900452\r\n" + "위도: 35.106567, 경도: 128.900452\r\n"
				+ "위도: 35.113700, 경도: 128.900452\r\n" + "위도: 35.120833, 경도: 128.900452\r\n"
				+ "위도: 35.127966, 경도: 128.900452\r\n" + "위도: 35.135099, 경도: 128.900452\r\n"
				+ "위도: 35.142232, 경도: 128.900452\r\n" + "위도: 35.149365, 경도: 128.900452\r\n"
				+ "위도: 35.156498, 경도: 128.900452\r\n" + "위도: 35.163631, 경도: 128.900452\r\n"
				+ "위도: 35.170764, 경도: 128.900452\r\n" + "위도: 35.177897, 경도: 128.900452\r\n"
				+ "위도: 35.185030, 경도: 128.900452\r\n" + "위도: 35.192163, 경도: 128.900452\r\n"
				+ "위도: 35.199296, 경도: 128.900452\r\n" + "위도: 35.206429, 경도: 128.900452\r\n"
				+ "위도: 35.213561, 경도: 128.900452\r\n" + "위도: 35.220694, 경도: 128.900452";

		// 변환된 좌표를 저장할 리스트
		List<Coordinate> flightPlanCoordinates = new ArrayList<>();

		// 정규 표현식 패턴 (위도와 경도를 추출하는 패턴)
		Pattern pattern = Pattern.compile("위도: ([\\d.]+), 경도: ([\\d.]+)");

		// 줄바꿈으로 데이터를 분리 (줄 단위로 나누기)
		String[] lines = coordinateData.split("\\r?\\n");

		// 데이터를 변환하는 반복문
		for (String data : lines) {
			Matcher matcher = pattern.matcher(data);

			if (matcher.find()) {
				double lat = Double.parseDouble(matcher.group(1)); // 위도 추출
				double lng = Double.parseDouble(matcher.group(2)); // 경도 추출

				// 변환된 좌표 객체를 리스트에 추가
				flightPlanCoordinates.add(new Coordinate(lat, lng));
			}
		}
		return flightPlanCoordinates;
	}

	@Autowired
	private RestTemplate restTemplate;
	
	// 3. a* 알고리즘 값 반환 메서드
	@PostMapping("/aStarConnection")
    public String processPythonData(@RequestBody String waypoints) throws IOException {
		
		try { // 경유지 좌표 python 코드에 맞게 파싱
	        ObjectMapper objectMapper = new ObjectMapper();
	        List<Coordinate> waypointCoordinates = objectMapper.readValue(waypoints, new TypeReference<List<Coordinate>>(){});

		    StringBuilder waypointBuild = new StringBuilder("[");
		    for (int i = 0; i < waypointCoordinates.size(); i++) {
		        Coordinate coordinate = waypointCoordinates.get(i);
		        waypointBuild.append("[").append(coordinate.getLat()).append(", ").append(coordinate.getLng()).append("]");

		        if (i < waypointCoordinates.size() - 1) {
		        	waypointBuild.append(", ");
		        }
		    }
		    waypointBuild.append("]");
		    
		    waypoints = waypointBuild.toString();
		    
			/*
			 * waypoints =
			 * "[[34.7765735, 126.3835188],[34.779772, 126.369231],[34.792125, 126.350674],[34.756450, 126.341209],[34.756450, 126.341209],"
			 * +"[34.671165, 126.222919],[34.587658, 126.241543],[34.584740, 126.184369],[34.498761, 126.059236],[34.497668, 125.916866],[34.497668, 125.916866]]"
			 * ;
			 */
		} catch (IOException e) {
			
			e.printStackTrace();
		}

        String url = "http://192.168.219.109:5000/aStarConnection";

        // 요청 헤더 설정
        HttpHeaders headers = new HttpHeaders();
        headers.set("Content-Type", "application/json");
        // 요청 본문 생성
        Map<String, String> requestBody = new HashMap<>();
        requestBody.put("waypoints", waypoints);
        // HTTP 엔티티 생성
        HttpEntity<Map<String, String>> requestEntity = new HttpEntity<>(requestBody, headers);

        // Flask API에 POST 요청 보내기
        ResponseEntity<String> responseEntity = restTemplate.exchange(url, HttpMethod.POST, requestEntity, String.class);

        // 응답 데이터 parsing
        String responseBody = responseEntity.getBody();
        ObjectMapper objectMapper = new ObjectMapper();
        try {
            JsonNode jsonNode = objectMapper.readTree(responseBody);
            System.out.println("a* 알고리즘 경로 결과 : "+jsonNode.toString());
            return jsonNode.toString();
        } catch (JsonProcessingException e) {
            e.printStackTrace();
            return "{\"error\":\"Failed to parse JSON response\"}";
        }
    }
	
	@Autowired
	private SailController sailController;
	
	// 4. 출발지,  목적지 지오코딩 후 반환
	@PostMapping("/firstGeocode")
    public List<Coordinate> firstGeocode(@RequestBody String address) {
		
		List<Coordinate> coordinates = null;
		try {
			double[] latLng = sailController.geocode(address);
			try {
				ObjectMapper objectMapper = new ObjectMapper();
				String destination = "[{\"lat\": " + latLng[0] + ", \"lng\": " + latLng[1] + "}]";
				coordinates = objectMapper.readValue(destination, new TypeReference<List<Coordinate>>() {});
			} catch (IOException e) {
				e.printStackTrace();
			}

		} catch (UnsupportedEncodingException e) {
			
			e.printStackTrace();
		}
		
		return coordinates;
	}
	
//	@GetMapping("/aStarConnection")
//    @ResponseBody
//    public String processPythonData(@RequestParam("waypoints") String waypoints) {
//		
//		waypoints = "[[34.6,128.7],[34.8,128.7],[34.8,128.95],[35,128.85]]";
//		String result = aStartService.executePythonScript(waypoints);
//		System.out.println("result : "+result);
//        return result;
//    }
}
