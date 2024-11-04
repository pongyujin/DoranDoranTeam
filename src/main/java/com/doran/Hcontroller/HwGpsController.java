package com.doran.Hcontroller;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Async;
import org.springframework.scheduling.annotation.EnableAsync;
import org.springframework.scheduling.annotation.EnableScheduling;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;

import com.doran.entity.Gps;
import com.doran.entity.Sail;
import com.doran.mapper.GpsMapper;

@Controller
@EnableScheduling // 스케줄링 기능 활성화
@EnableAsync
public class HwGpsController {

	@Autowired
	private GpsMapper gpsMapper;

	// 전역 변수로 GPS 데이터를 저장할 수 있는 맵 (ConcurrentHashMap사용 HashMap대신)
	private Map<String, Object> latestGpsData = new ConcurrentHashMap<>();

	// 현재 항해 정보 저장하는 전역 변수
	private Sail currentSail = null;

	// 1. 하드웨어에서 gps 정보 받아오기
	@RequestMapping(value = "/gps-data", method = RequestMethod.POST)
	@ResponseBody
	public void receiveGpsData(@RequestBody Map<String, Object> data) {

		// GPS 데이터를 최신 상태로 저장
		latestGpsData.putAll(data);

	}

	// 2. gps 정보 db 저장(항해 시작 시)
	@PostMapping("/insertGps")
	@Async
	public @ResponseBody void insertGps() {

		if (currentSail != null) {

			double latitude = (double) latestGpsData.getOrDefault("latitude", 0.0);
			double longitude = (double) latestGpsData.getOrDefault("longitude", 0.0);
			double speed = (double) latestGpsData.getOrDefault("speed", 0.0);
			double heading = (double) latestGpsData.getOrDefault("heading", 0.0);

			Gps gps = new Gps();
			gps.setSiCode(currentSail.getSiCode());
			gps.setGpsLat(latitude);
			gps.setGpsLng(longitude);
			gps.setGpsSpeed(speed);
			gps.setGpsDir(heading);
			gps.setSailNum(currentSail.getSailNum());

			int cnt = gpsMapper.insertGps(gps);
			System.out.println(gps);
		}else {
			System.out.println("gps 데이터 저장을 종료합니다.");
		}
	}

	// 3. 스케줄링 메서드(insertGps 메서드가 1분에 한번씩 실행되도록 설정)
	@Scheduled(fixedRate = 60000)
	public void scheduleInsertGps() {

		if (currentSail != null) {
			insertGps();
		}
	}

	// 4. 항해 시작 시 세션에서 nowSail 데이터 가져와 설정
	public void gpsStartSail(HttpSession session) {
		this.currentSail = (Sail) session.getAttribute("nowSail");
	}
}
