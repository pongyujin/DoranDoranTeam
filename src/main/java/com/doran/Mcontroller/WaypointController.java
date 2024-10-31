package com.doran.Mcontroller;

import java.util.List;

import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.doran.entity.Coordinate;
import com.doran.entity.Sail;
import com.doran.entity.Waypoint;
import com.doran.mapper.WaypointMapper;
import com.google.gson.Gson;

@RestController
public class WaypointController {

	@Autowired
	private WaypointMapper waypointMapper;
	
	// 1. 경유지 정보 db 저장
	@PostMapping("/saveWaypoint")
	public void saveWaypoint(@RequestBody List<Coordinate> waypoints, HttpSession session) {
		
		waypointSession(waypoints, session);
		Sail nowSail = (Sail)session.getAttribute("nowSail");
		int index = 1;
		
		for(Coordinate wp : waypoints) {
			
			Waypoint waypoint = new Waypoint();
			waypoint.setSiCode(nowSail.getSiCode());
			waypoint.setWayPoint(index);
			waypoint.setStatDest(nowSail.getSiCode()+"*"+nowSail.getSailNum());
			waypoint.setStatLat(wp.getLat());
			waypoint.setStatLng(wp.getLng());
			waypoint.setStatRoute("이동 경로");
			waypoint.setStatBattery("80");
			waypoint.setSailNum(nowSail.getSailNum());
			
			waypointMapper.waypointInsert(waypoint);
			index++;
		}
		System.out.println("경유지 저장 완료");
	}
	
	// 2. 경유지 세션 저장(json 형태 변환)
	@RequestMapping("/waypointSession")
	public void waypointSession(@RequestBody List<Coordinate> waypoints, HttpSession session) {
		
		Gson gson = new Gson();
		String waypointsJson = gson.toJson(waypoints);
		System.out.println("waypoints 세션 저장 : "+waypointsJson);
		session.setAttribute("waypoints", waypointsJson);
	}
}
