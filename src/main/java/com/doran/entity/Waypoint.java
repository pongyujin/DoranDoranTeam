package com.doran.entity;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
@ToString
public class Waypoint {

	private int statNum; // 상태 번호
	private String siCode; // 선박 코드
	private int wayPoint; // 경유지 번호	
	private String statDest; // 지점 명
	private double statLat; // 지점 위도
	private double statLng; // 지점 경도
	private String statRoute; // 이동 경로
	private String statBattery;// 배터리 상태
	private String createdAt; // 등록 시간
	private int sailNum; // 항해 번호
}
