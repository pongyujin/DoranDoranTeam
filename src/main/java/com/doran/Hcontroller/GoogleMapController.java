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
		
		String coordinateData = "위도: 34.757175, 경도: 126.234669\r\n"
				+ "위도: 34.746755, 경도: 126.239021\r\n"
				+ "위도: 34.735659, 경도: 126.245097\r\n"
				+ "위도: 34.724563, 경도: 126.251174\r\n"
				+ "위도: 34.713467, 경도: 126.251174\r\n"
				+ "위도: 34.702370, 경도: 126.251174\r\n"
				+ "위도: 34.691274, 경도: 126.245097\r\n"
				+ "위도: 34.680178, 경도: 126.239021\r\n"
				+ "위도: 34.669082, 경도: 126.232944\r\n"
				+ "위도: 34.657986, 경도: 126.226868\r\n"
				+ "위도: 34.646890, 경도: 126.220791\r\n"
				+ "위도: 34.635794, 경도: 126.214715\r\n"
				+ "위도: 34.624698, 경도: 126.208638\r\n"
				+ "위도: 34.613602, 경도: 126.202562\r\n"
				+ "위도: 34.602506, 경도: 126.196485\r\n"
				+ "위도: 34.602506, 경도: 126.190409\r\n"
				+ "위도: 34.591410, 경도: 126.184332\r\n"
				+ "위도: 34.580313, 경도: 126.178256\r\n"
				+ "위도: 34.569217, 경도: 126.172179\r\n"
				+ "위도: 34.558121, 경도: 126.166102\r\n"
				+ "위도: 34.547025, 경도: 126.160026\r\n"
				+ "위도: 34.535929, 경도: 126.153949\r\n"
				+ "위도: 34.524833, 경도: 126.147873\r\n"
				+ "위도: 34.513737, 경도: 126.141796\r\n"
				+ "위도: 34.502641, 경도: 126.135720\r\n"
				+ "위도: 34.491545, 경도: 126.129643\r\n"
				+ "위도: 34.491545, 경도: 126.123567\r\n"
				+ "위도: 34.491545, 경도: 126.117490\r\n"
				+ "위도: 34.491545, 경도: 126.111414\r\n"
				+ "위도: 34.480449, 경도: 126.105337\r\n"
				+ "위도: 34.469353, 경도: 126.099261\r\n"
				+ "위도: 34.458256, 경도: 126.093184\r\n"
				+ "위도: 34.447160, 경도: 126.087108\r\n"
				+ "위도: 34.436064, 경도: 126.087108\r\n"
				+ "위도: 34.424968, 경도: 126.087108\r\n"
				+ "위도: 34.413872, 경도: 126.087108\r\n"
				+ "위도: 34.402776, 경도: 126.087108\r\n"
				+ "위도: 34.391680, 경도: 126.093184\r\n"
				+ "위도: 34.380584, 경도: 126.099261\r\n"
				+ "위도: 34.369488, 경도: 126.105337\r\n"
				+ "위도: 34.358392, 경도: 126.111414\r\n"
				+ "위도: 34.347296, 경도: 126.117490\r\n"
				+ "위도: 34.336199, 경도: 126.123567\r\n"
				+ "위도: 34.325103, 경도: 126.129643\r\n"
				+ "위도: 34.314007, 경도: 126.135720\r\n"
				+ "위도: 34.302911, 경도: 126.141796\r\n"
				+ "위도: 34.291815, 경도: 126.147873\r\n"
				+ "위도: 34.280719, 경도: 126.153949\r\n"
				+ "위도: 34.269623, 경도: 126.160026\r\n"
				+ "위도: 34.258527, 경도: 126.166102\r\n"
				+ "위도: 34.247431, 경도: 126.172179\r\n"
				+ "위도: 34.236335, 경도: 126.178256\r\n"
				+ "위도: 34.225239, 경도: 126.184332\r\n"
				+ "위도: 34.214142, 경도: 126.190409\r\n"
				+ "위도: 34.203046, 경도: 126.196485\r\n"
				+ "위도: 34.191950, 경도: 126.202562\r\n"
				+ "위도: 34.180854, 경도: 126.208638\r\n"
				+ "위도: 34.169758, 경도: 126.214715\r\n"
				+ "위도: 34.158662, 경도: 126.220791\r\n"
				+ "위도: 34.147566, 경도: 126.226868\r\n"
				+ "위도: 34.136470, 경도: 126.232944\r\n"
				+ "위도: 34.125374, 경도: 126.239021\r\n"
				+ "위도: 34.114278, 경도: 126.245097\r\n"
				+ "위도: 34.103182, 경도: 126.251174\r\n"
				+ "위도: 34.092086, 경도: 126.257250\r\n"
				+ "위도: 34.080989, 경도: 126.263327\r\n"
				+ "위도: 34.069893, 경도: 126.269403\r\n"
				+ "위도: 34.058797, 경도: 126.275480\r\n"
				+ "위도: 34.047701, 경도: 126.281556\r\n"
				+ "위도: 34.036605, 경도: 126.287633\r\n"
				+ "위도: 34.025509, 경도: 126.293710\r\n"
				+ "위도: 34.014413, 경도: 126.299786\r\n"
				+ "위도: 34.003317, 경도: 126.305863\r\n"
				+ "위도: 33.992221, 경도: 126.311939\r\n"
				+ "위도: 33.981125, 경도: 126.305863\r\n"
				+ "위도: 33.970029, 경도: 126.305863\r\n"
				+ "위도: 33.958932, 경도: 126.305863\r\n"
				+ "위도: 33.947836, 경도: 126.305863\r\n"
				+ "위도: 33.936740, 경도: 126.305863\r\n"
				+ "위도: 33.925644, 경도: 126.311939\r\n"
				+ "위도: 33.914548, 경도: 126.318016\r\n"
				+ "위도: 33.903452, 경도: 126.324092\r\n"
				+ "위도: 33.892356, 경도: 126.330169\r\n"
				+ "위도: 33.881260, 경도: 126.336245\r\n"
				+ "위도: 33.870164, 경도: 126.342322\r\n"
				+ "위도: 33.859068, 경도: 126.348398\r\n"
				+ "위도: 33.847972, 경도: 126.354475\r\n"
				+ "위도: 33.836875, 경도: 126.360551\r\n"
				+ "위도: 33.825779, 경도: 126.366628\r\n"
				+ "위도: 33.814683, 경도: 126.372704\r\n"
				+ "위도: 33.803587, 경도: 126.378781\r\n"
				+ "위도: 33.792491, 경도: 126.384857\r\n"
				+ "위도: 33.781395, 경도: 126.390934\r\n"
				+ "위도: 33.770299, 경도: 126.397011\r\n"
				+ "위도: 33.759203, 경도: 126.403087\r\n"
				+ "위도: 33.748107, 경도: 126.409164\r\n"
				+ "위도: 33.737011, 경도: 126.415240\r\n"
				+ "위도: 33.725915, 경도: 126.421317\r\n"
				+ "위도: 33.714818, 경도: 126.427393\r\n"
				+ "위도: 33.703722, 경도: 126.433470\r\n"
				+ "위도: 33.692626, 경도: 126.439546\r\n"
				+ "위도: 33.681530, 경도: 126.445623\r\n"
				+ "위도: 33.670434, 경도: 126.445623\r\n"
				+ "위도: 33.659338, 경도: 126.445623\r\n"
				+ "위도: 33.648242, 경도: 126.445623\r\n"
				+ "위도: 33.637146, 경도: 126.445623\r\n"
				+ "위도: 33.626050, 경도: 126.445623\r\n"
				+ "위도: 33.614954, 경도: 126.445623\r\n"
				+ "위도: 33.603858, 경도: 126.445623\r\n"
				+ "위도: 33.592761, 경도: 126.445623\r\n"
				+ "위도: 33.581665, 경도: 126.445623\r\n"
				+ "위도: 33.570569, 경도: 126.445623\r\n"
				+ "위도: 33.559473, 경도: 126.445623\r\n"
				+ "위도: 33.548377, 경도: 126.445623";

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

        String url = "http://0.0.0.0:5000/aStarConnection";

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
