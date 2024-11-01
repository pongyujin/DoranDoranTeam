package com.doran.Hcontroller;

import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.doran.Mcontroller.WeatherController;
import com.doran.entity.Gps;
import com.doran.entity.Ship;

@Controller
public class InfoPanelController {
	
	@Autowired
	private WeatherController weatherController;
	
	// 1. infoTitle에 따라 정보받아오는 함수 실행
	@GetMapping(value = "/getInfo", produces = "application/json;charset=UTF-8")
	@ResponseBody
	public String getInfo(@RequestParam String infoTitle, HttpSession session) {

		String result = "";

		switch (infoTitle) {
		case "선박 정보":
			result = shipInfo(session);
			break;
		case "온도":
			result = temperature();
			break;
		case "배터리":
			result = battery();
			break;
		case "통신 상태":
			result = signalStatus();
			break;
		case "속도":
			result = velocity();
			break;
		case "남은 시간":
			result = remainTime();
			break;
		case "남은 거리":
			result = remainDistance();
			break;
		case "현재 위치":
			result = getLatestGpsLocation();
			break;
		case "방위":
			result = direction();
			break;
		case "주변 장애물 탐지":
			result = obstacle();
			break;
		default:
			result = "Invalid request"; // 유효하지 않은 경우 처리
			break;
		}
		return result;
	}

	// 1. 전역 변수로 GPS 데이터를 저장할 수 있는 맵
	// private Map<String, Object> latestGpsData = new HashMap<>();
	
	// ------------------------------------------------------------------------//	

	// 2. 선박 정보
	public String shipInfo(HttpSession session) {
		
		Ship ship = (Ship)session.getAttribute("nowShip");

		if(ship!=null) {
			String shipInfo= "선박 코드 [ " + ship.getSiCode() + " ]";
			return shipInfo;
		}else {
			return "현재 선박 정보가 없습니다";
		}
		
	}

	// 3. 온도
	public String temperature() {
		
		String temperature = weatherController.tideObsAirTemp()+"°C 입니다";
		return temperature;
	}

	// 4. 배터리
	public String battery() {
		
		String battery = "배터리 잔량 " + 80 + "%";
		return battery;
	}

	// 5. 통신 상태
	public String signalStatus() {
		
		String signalStatus = "통신 상태 " + "양호";
		return signalStatus;
	}

	// 6. 속도
	public String velocity() {
		
		Gps nowGps = hwGpsController.getGps();
		
		double speed = nowGps.getGpsSpeed();

        return speed + " km/h";
	}

	// 7. 남은 시간
	public String remainTime() {
		
		String remainTime = "남은 시간 " + 2 + "시간";
		return remainTime;
	}

	// 8. 남은 거리
	public String remainDistance() {
		
		String remainDistance = "남은 거리 " + 10 + "km";
		return remainDistance;
	}
	
//	@RequestMapping(value = "/gps-data", method = RequestMethod.POST)
//    @ResponseBody
//    public String receiveGpsData(@RequestBody Map<String, Object> data) {
//		
//		// GPS 데이터를 최신 상태로 저장
//        latestGpsData.putAll(data);
//        
//        // 개별 값 출력
//        double latitude = (double) data.get("latitude"); // 위도
//        double longitude = (double) data.get("longitude"); // 경도
//        double speed = (double) data.get("speed"); // 속도
//        double heading = (double) data.get("heading"); // 북쪽기준 방위각
//        String time = (String) data.get("time"); // 시간
//
//        String location = "위도: " + latitude + ", 경도: " + longitude;
//
//        return location;
//    }
	
	@Autowired
	private HwGpsController hwGpsController;
	
	// 9. 최신 GPS 데이터를 반환하는 메서드(현재 위도 경도)
    public String getLatestGpsLocation() {
    	
        Gps nowGps = hwGpsController.getGps();

        double latitude = nowGps.getGpsLat();
        double longitude = nowGps.getGpsLng();

        return "위도: " + latitude + ", 경도: " + longitude;
    }

	// 10. 방위
	public String direction() {
		
		Gps nowGps = hwGpsController.getGps();
		
		double heading = nowGps.getGpsDir();
		String direction = "방위각 " + heading;
		return direction;
	}

	// 11. 주변 장애물 탐지
	public String obstacle() {

		String obstacle = "장애물 없음";
		return obstacle;
	}

}
