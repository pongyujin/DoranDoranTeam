package com.doran.Mcontroller;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.UnsupportedEncodingException;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.List;

import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.EnableAsync;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import org.springframework.web.util.UriComponentsBuilder;

import com.doran.Hcontroller.HwGpsController;
import com.doran.Mcontroller.WeatherController;
import com.doran.entity.Member;
import com.doran.entity.Sail;
import com.doran.entity.ShipGroup;
import com.doran.entity.Weather;
import com.doran.mapper.SailMapper;
import com.doran.mapper.ShipGroupMapper;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

// 항해 정보 최초 등록
@RequestMapping("/sail")
@Controller
@EnableAsync
public class SailController {

	@Autowired
	private SailMapper sailMapper;
	@Autowired
	private ShipGroupMapper shipGroupMapper;
	@Autowired
	private ShipController shipController;
	@Autowired
	private HwGpsController hwGpsController;

	private final String apiKey = "AIzaSyDtt1tmfQ-lTeQaCimRBn2PQPTlCLRO6Pg";
	private final String placeKey = "AIzaSyAW9QwdMPgIykOFaLdCX5ZJTQOED8FVLfg";
	
	@Autowired
	private WeatherController weatherController;
	
	private boolean sailingStarted = false; // 항해 시작 여부를 저장하는 변수
	
	// 0. 항해 정보 최초 생성 (Db 저장)
	@PostMapping("/insert")
	public String sailInsert(Sail sail, RedirectAttributes rttr, HttpSession session) {

		try {

			Member user = (Member)session.getAttribute("user");
			
			// 0. 권한 확인
			ShipGroup shipGroup = new ShipGroup();
			shipGroup.setSiCode(sail.getSiCode());
			shipGroup.setMemId(user.getMemId());
			shipGroup = shipGroupMapper.authCheck(shipGroup);
			
			if(shipGroup == null) {
				
				rttr.addFlashAttribute("msgType", "실패");
				rttr.addFlashAttribute("msg", "선박 관제 권한이 없습니다.");
				System.out.println("선박 회원이 아닙니다");
	        	return "redirect:/main";
	        	
			}else if(shipGroup.getAuthNum()!=0 && shipGroup.getAuthNum()!=2 && shipGroup.getAuthNum()!=3) {
	            
	        	rttr.addFlashAttribute("msgType", "실패");
				rttr.addFlashAttribute("msg", "선박 관제 권한이 없습니다.");
				System.out.println("선박 관제 권한이 없습니다 : "+shipGroup.getAuthNum());
	        	return "redirect:/map2"; 
	        }

			// a. 출발지 목적지 geocoding(좌표계산)
			sail = coordinates(sail);
			
			// b. 항해 최초 생성 정보 db 저장
			int sailNum = sailMapper.getSailNum(sail);
			sail.setSailNum(sailNum);
			sailMapper.insert(sail);
			// 항해 정보 세션 저장
			// 세션 생성 시 타임아웃 설정(1시간)
			session.setMaxInactiveInterval(3600);
			session.setAttribute("nowSail", sail);

			// c. 항해 시작 메서드 실행(+운항 상태 변경)
			startSail(session);
			
			// d. Weather 데이터를 설정하여 weather 메서드 호출
			Weather weather = new Weather();
			weather.setSailNum(sail.getSailNum());
			weather.setSiCode(sail.getSiCode());
	        weatherController.weather(weather);
	        
	        // e. gps 데이터 db 저장
	        hwGpsController.gpsStartSail(session);
	        hwGpsController.insertGps();
			
		} catch (UnsupportedEncodingException e) {
			e.printStackTrace();
		}
		rttr.addFlashAttribute("msgType", "성공");
		return "redirect:/map2";
	}
	
	// 1. 항해 코멘트 수정
	@PutMapping("/comment")
	public void comment(Sail sail) {

		sailMapper.comment(sail);
	}

	// 2. 항해 상세내용 보기
	@GetMapping("/content")
	public Sail sailContent(Sail sail) {

		Sail result = sailMapper.content(sail);
		return result;
	}

	// 3. 항해 삭제하기
	@DeleteMapping("/delete")
	public void sailDelete(Sail sail) {

		sailMapper.delete(sail);
	}

	// 4. 전체 항해 리스트 불러오기(선박코드로 전체 항해 정보 불러오기)
	@RequestMapping("/all")
	public List<Sail> sailList(Sail sail) {

		List<Sail> sailList = sailMapper.sailList(sail);
		return sailList;
	}

	// 5. 항해 시작/종료 메서드
	@GetMapping("/startSail")
	public void startSail(HttpSession session) {

		sailingStarted = true;
		weatherController.startSail(); // (WeatherController에서)
		Sail sail = (Sail)session.getAttribute("nowSail");
		shipController.startStatus(sail, session);
	}

	@GetMapping("/endSail")
	public @ResponseBody void endSail(HttpSession session) {

		sailingStarted = false;
		weatherController.endSail(); // weathereController 항해 중단 알림
		Sail sail = (Sail)session.getAttribute("nowSail");
		session.removeAttribute("waypoints"); // 경유지 세션 삭제
		session.removeAttribute("nowSail"); // 항해 세션 삭제
		shipController.endStatus(sail, session);
	}
	
	// -------------------------------------------------------------(api 메서드)-------------------
	// 1. 출발지, 도착지 좌표 값 반환 메서드
	@RequestMapping("/coordinates")
	public Sail coordinates(Sail sail) throws UnsupportedEncodingException {

		// 주소를 URL 인코딩
		String startSail = new String(sail.getStartSail().getBytes("ISO-8859-1"), "UTF-8");
		String endSail = new String(sail.getEndSail().getBytes("ISO-8859-1"), "UTF-8");
		
		double[] startCoordinates = geocode(startSail);
		double[] endCoordinates = geocode(endSail);

		sail.setStartSail(startSail);
		sail.setEndSail(endSail);
		sail.setStartLat(startCoordinates[0]);
		sail.setStartLng(startCoordinates[1]);
		sail.setEndLat(endCoordinates[0]);
		sail.setEndLng(endCoordinates[1]);
		System.out.println(sail);
		return sail;
	}

	// 2. geocoding api
	public double[] geocode(String address) throws UnsupportedEncodingException {

		String GEOCODING_API_URL = "https://maps.googleapis.com/maps/api/geocode/json";
		String placeId = placeId(address); // 주소로 장소 ID 반환받기

		// Geocoding API 호출 URL 생성 ("ChIJq8zBMx67czUREGThCetMcGI")
		String url = UriComponentsBuilder.fromHttpUrl(GEOCODING_API_URL).queryParam("place_id", placeId)
				.queryParam("key", apiKey).toUriString();

		RestTemplate restTemplate = new RestTemplate();
		String jsonResponse = restTemplate.getForObject(url, String.class); // JSON 문자열로 응답 받기

		// JSON 파싱
		try {
			ObjectMapper objectMapper = new ObjectMapper();
			JsonNode rootNode = objectMapper.readTree(jsonResponse);
			String status = rootNode.path("status").asText();

			// status가 OK인지 확인
			if ("OK".equals(status)) {
				JsonNode location = rootNode.path("results").get(0).path("geometry").path("location");
				double lat = location.path("lat").asDouble();
				double lng = location.path("lng").asDouble();
				
				return new double[] { lat, lng };// 위도와 경도를 배열로 반환
			} else {
				// 오류 처리 (api 검색 결과가 없는 경우)
				return null;
			}
		} catch (Exception e) {
			e.printStackTrace();
			return null;
		}
	}

	// 3. 구글 장소 ID 반환 메서드
	public String placeId(String address) throws UnsupportedEncodingException {
		
		// Places API 호출 URL 생성
		String apiUrl = UriComponentsBuilder
				.fromHttpUrl("https://maps.googleapis.com/maps/api/place/findplacefromtext/json")
				.queryParam("input", address).queryParam("inputtype", "textquery").queryParam("language", "ko")
				.queryParam("region", "KR").queryParam("fields", "place_id").queryParam("key", placeKey).toUriString();

		StringBuilder jsonResponse = new StringBuilder();

		try {
			URL url = new URL(apiUrl);
			HttpURLConnection conn = (HttpURLConnection) url.openConnection();
			conn.setRequestMethod("GET");
			conn.setRequestProperty("Accept", "application/json");

			// 응답 코드 확인
			int responseCode = conn.getResponseCode();
			if (responseCode == HttpURLConnection.HTTP_OK) { // 성공적인 응답
				BufferedReader in = new BufferedReader(new InputStreamReader(conn.getInputStream()));
				String inputLine;
				while ((inputLine = in.readLine()) != null) {
					jsonResponse.append(inputLine);
				}
				in.close();
			} else {
				
				return "Error: " + responseCode;
			}
		} catch (IOException e) {
			e.printStackTrace();
			return "error"; // 오류 발생 시 반환 값
		}

		// JSON 파싱
		try {
			ObjectMapper objectMapper = new ObjectMapper();
			JsonNode rootNode = objectMapper.readTree(jsonResponse.toString());
			String status = rootNode.path("status").asText();

			// status가 OK인지 확인
			if ("OK".equals(status)) {
				JsonNode candidates = rootNode.path("candidates");
				if (candidates.isArray() && candidates.size() > 0) {
					String placeId = candidates.get(0).path("place_id").asText();
					return placeId; // 장소 ID 반환
				} else {
					return "NO_RESULTS"; // 장소가 없을 경우
				}
			} else {
				return status; // 필요한 경우 적절한 반환 값 설정
			}
		} catch (Exception e) {
			e.printStackTrace(); // 오류 로그 출력
			return "error"; // 오류 발생 시 반환 값
		}
	}
}
