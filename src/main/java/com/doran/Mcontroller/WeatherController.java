package com.doran.Mcontroller;

import java.time.Duration;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;

import javax.annotation.PostConstruct;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Async;
import org.springframework.scheduling.annotation.EnableScheduling;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.client.RestTemplate;

import com.doran.entity.Weather;
import com.doran.mapper.WeatherMapper;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

@RestController
@EnableScheduling // 스케줄링 기능 활성화
public class WeatherController {

	@Autowired
	private WeatherMapper weatherMapper;
	@Autowired
	private RestTemplate restTemplate;

	private final String serviceKey = "bvd0WcsuRPzcUhhu82GPw==";

	// 현재 날짜 불러오기
	DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyyMMdd");
	String currentDate = LocalDate.now().format(formatter);
	// - 하이픈이 들어간 현재 날짜 포매팅
	DateTimeFormatter barformatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
	String barcurrentDate = LocalDate.now().format(barformatter);

	// 현재 시간 가져오기
	DateTimeFormatter timeFormatter = DateTimeFormatter.ofPattern("HH:mm:00");
	String currentTime = LocalTime.now().format(timeFormatter);

	// 메서드 실행 시 초기값 세팅
    @PostConstruct
    public void init() {
        updateDateTime(); // 초기화 시에도 현재 날짜와 시간 세팅
    }
	
	// 날짜와 시간 갱신 메서드
	private void updateDateTime() {
		currentDate = LocalDate.now().format(formatter);
		barcurrentDate = LocalDate.now().format(barformatter);
		currentTime = LocalTime.now().format(timeFormatter);
	}

	// Weather 객체를 필드로 추가
	private Weather currentWeather;

	// main. 현재 기상 정보 db 저장----------------------------------------------------
	@PostMapping("/weather")
	@Async
	public void weather(Weather weather) {
		
		this.currentWeather = weather;

		currentWeather.setWDate(currentDate);
		currentWeather.setWTime(currentTime);
		currentWeather.setWTemp(tideObsAirTemp());
		currentWeather.setStatBattery("80");
		currentWeather.setWWindSpeed(tideObsWind());
		currentWeather.setWWaveHeight(obsWaveHight());
		currentWeather.setWSeaTemp(tideObsTemp());
		currentWeather.setWRegion("DT_0007");
		System.out.println(weather);

		weatherMapper.insertWeather(currentWeather);
	}

	private boolean sailingStarted = false; // 항해 시작 여부를 저장하는 변수
	
	// main-1. 항해 시작 메서드
	public void startSail() {

		sailingStarted = true;
		if (sailingStarted) {
			System.out.println("항해가 시작되었습니다.");
		} else {
			System.out.println("항해가 중단되었습니다.");
		}
	}

	// main-2. 항해 종료 메서드
	public void endSail() {

		sailingStarted = false;
		if (sailingStarted) {
			System.out.println("항해가 시작되었습니다.");
		} else {
			System.out.println("항해가 중단되었습니다.");
		}
	}

	// main-3. 스케줄링 메서드(weather 메서드가 1분에 한번씩 실행되도록 설정)
	@Scheduled(fixedRate = 60000)
	public void scheduleWeatherUpdate() {

		if (sailingStarted) {
			updateDateTime(); // 현재 날짜와 시간 갱신
			if (currentWeather != null) { 
				// currentWeather가 null이 아닐 경우에만 실행
                weather(currentWeather);
            }
		}
	}

	// 0. json 파싱 포맷(차이가 작은 시간)------------------------------------------------
	public String weatherParsing2(String response, String what) {

		// 현재 시간 가져오기
		LocalDateTime currentTime = LocalDateTime.now().withSecond(0); // 초는 00으로 맞춤

		// JSON 파싱
		ObjectMapper objectMapper = new ObjectMapper();
		try {
			JsonNode jsonNode = objectMapper.readTree(response);
			JsonNode dataNode = jsonNode.path("result").path("data");

			String whatResult = null;
			String RecordTime = null;
			long smallestDifference = Long.MAX_VALUE;

			// 날짜 포맷터 설정
			DateTimeFormatter recordTimeFormatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

			for (JsonNode node : dataNode) {
				// record_time을 LocalDateTime으로 변환
				String recordTimeString = node.path("record_time").asText();
				LocalDateTime recordTime = LocalDateTime.parse(recordTimeString, recordTimeFormatter);

				// 현재 시간과 record_time 간의 차이 계산
				long difference = Math.abs(Duration.between(currentTime, recordTime).toMinutes());

				// 차이가 더 작으면 해당 데이터를 저장
				if (difference < smallestDifference) {
					smallestDifference = difference;
					whatResult = node.path(what).asText();
					RecordTime = recordTimeString;
				}
			}

			// 결과 반환
			if (whatResult != null && RecordTime != null) {
				return whatResult;
			} else {
				return "No matching data found.";
			}

		} catch (Exception e) {
			e.printStackTrace();
			return "Error while parsing the response.";
		}
	}

	// --------------------------------------------------------------------------------------------------
	// 1. 조위 (완)
	@GetMapping("/tideObs")
	public String tideObs() {

		String url = String.format(
				"http://www.khoa.go.kr/api/oceangrid/tideObs/search.do?ServiceKey=%s&ObsCode=%s&Date=%s&ResultType=json",
				this.serviceKey, "DT_0007", this.currentDate);

		// API 요청
		String response = restTemplate.getForObject(url, String.class);
		String result = weatherParsing2(response, "tide_level");

		return result;
	}

	// 2. 파고 (완 - 형식다름)
	@GetMapping("/obsWaveHight")
	public String obsWaveHight() {

		String url = String.format(
				"http://www.khoa.go.kr/api/oceangrid/obsWaveHight/search.do?ServiceKey=%s&ObsCode=%s&Date=%s&ResultType=json",
				this.serviceKey, "DT_0042", this.currentDate);

		// API 요청
		String response = restTemplate.getForObject(url, String.class);

		// 현재 시간 가져오기
		LocalDateTime currentTime = LocalDateTime.now().withSecond(0); // 초는 00으로 맞춤

		// 원하는 형식으로 현재 시간을 포맷
		DateTimeFormatter currentFormatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");
		String formattedCurrentTime = currentTime.format(currentFormatter);

		// JSON 파싱
		ObjectMapper objectMapper = new ObjectMapper();
		try {
			JsonNode jsonNode = objectMapper.readTree(response);
			JsonNode dataNode = jsonNode.path("result").path("data");

			String waveHeight = null;
			String RecordTime = null;
			long smallestDifference = Long.MAX_VALUE;

			// 날짜 포맷터 설정
			DateTimeFormatter recordTimeFormatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");

			for (JsonNode node : dataNode) {
				// record_time을 LocalDateTime으로 변환
				String recordTimeString = node.path("record_time").asText();
				LocalDateTime recordTime = LocalDateTime.parse(recordTimeString, recordTimeFormatter);
				LocalDateTime CurrentTime = LocalDateTime.parse(formattedCurrentTime, recordTimeFormatter);

				// 현재 시간과 record_time 간의 차이 계산
				long difference = Math.abs(Duration.between(CurrentTime, recordTime).toMinutes());

				// 차이가 더 작으면 해당 데이터를 저장
				if (difference < smallestDifference) {
					smallestDifference = difference;
					waveHeight = node.path("wave_height").asText();
					RecordTime = recordTimeString;
				}
			}

			// 결과 반환
			if (waveHeight != null && RecordTime != null) {
				return waveHeight;
			} else {
				return "No matching data found.";
			}

		} catch (Exception e) {
			e.printStackTrace();
			return "Error while parsing the response.";
		}
	}

	// 3. 조류 (보류 - 형식다름)(dto에 없음)
	@GetMapping("/fcTidalCurrent")
	public String fcTidalCurrent() {

		String url = String.format(
				"http://www.khoa.go.kr/api/oceangrid/fcTidalCurrent/search.do?ServiceKey=%s&ObsCode=%s&Date=%s&ResultType=json",
				this.serviceKey, "01MP-2", this.currentDate);

		// API 요청
		String response = restTemplate.getForObject(url, String.class);

		return response;
	}

	// 4. 수온 (완)
	@GetMapping("/tideObsTemp")
	public String tideObsTemp() {

		String url = String.format(
				"http://www.khoa.go.kr/api/oceangrid/tideObsTemp/search.do?ServiceKey=%s&ObsCode=%s&Date=%s&ResultType=json",
				this.serviceKey, "DT_0007", this.currentDate);

		// API 요청
		String response = restTemplate.getForObject(url, String.class);
		String result = weatherParsing2(response, "water_temp");

		return result;
	}

	// 5. 기온 (완)
	@GetMapping("/tideObsAirTemp")
	public String tideObsAirTemp() {

		String url = String.format(
				"http://www.khoa.go.kr/api/oceangrid/tideObsAirTemp/search.do?ServiceKey=%s&ObsCode=%s&Date=%s&ResultType=json",
				this.serviceKey, "DT_0007", this.currentDate);

		// API 요청
		String response = restTemplate.getForObject(url, String.class);
		String result = weatherParsing2(response, "air_temp");
		
		return result;
	}

	// 6. 기압 (완 - 3분 단위)
	@GetMapping("/tideObsAirPres")
	public String tideObsAirPres() {

		String url = String.format(
				"http://www.khoa.go.kr/api/oceangrid/tideObsAirPres/search.do?ServiceKey=%s&ObsCode=%s&Date=%s&ResultType=json",
				this.serviceKey, "DT_0007", this.currentDate);

		// API 요청
		String response = restTemplate.getForObject(url, String.class);
		String result = weatherParsing2(response, "air_pres");

		return result;
	}

	// 7. 풍향/풍속 (완 - 형식다름)
	@GetMapping("/tideObsWind")
	public String tideObsWind() {

		String url = String.format(
				"http://www.khoa.go.kr/api/oceangrid/tideObsWind/search.do?ServiceKey=%s&ObsCode=%s&Date=%s&ResultType=json",
				this.serviceKey, "DT_0007", this.currentDate);

		// API 요청
		String response = restTemplate.getForObject(url, String.class);

		// JSON 파싱
		ObjectMapper objectMapper = new ObjectMapper();
		try {
			JsonNode jsonNode = objectMapper.readTree(response);
			JsonNode dataNode = jsonNode.path("result").path("data");

			String windDir = null;
			String windSpeed = null;
			String recordTimeResult = null;
			long smallestDifference = Long.MAX_VALUE;

			// 현재 시간 가져오기
			LocalDateTime currentTime = LocalDateTime.now().withSecond(0); // 초는 0으로 맞춤

			// 날짜 포맷터 설정
			DateTimeFormatter recordTimeFormatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

			for (JsonNode node : dataNode) {
				// record_time을 LocalDateTime으로 변환
				String recordTimeString = node.path("record_time").asText();
				LocalDateTime recordTime = LocalDateTime.parse(recordTimeString, recordTimeFormatter);

				// 현재 시간과 record_time 간의 차이 계산
				long difference = Math.abs(Duration.between(currentTime, recordTime).toMinutes());

				// 차이가 더 작으면 해당 데이터를 저장
				if (difference < smallestDifference) {
					smallestDifference = difference;
					windDir = node.path("wind_dir").asText();
					windSpeed = node.path("wind_speed").asText();
					recordTimeResult = recordTimeString;
				}
			}

			if (windDir != null && windSpeed != null && recordTimeResult != null) {
				return windSpeed;
			} else {
				return "No matching data found.";
			}
		} catch (Exception e) {
			e.printStackTrace();
		}

		return response;
	}

	// 8. 해무 (미완 - 필요가 잇나)
	@GetMapping("/seafogReal")
	public String seafogReal() {

		String url = String.format(
				"http://www.khoa.go.kr/api/oceangrid/seafogReal/search.do?ServiceKey=%s&ObsCode=%s&Date=%s&ResultType=json",
				this.serviceKey, "SF_0007", this.currentDate);

		// API 요청
		String response = restTemplate.getForObject(url, String.class);
		return response;
	}

}