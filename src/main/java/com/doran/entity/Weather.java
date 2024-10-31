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
public class Weather {

	private int wNum; // 기상 번호
	private String wDate; // 기상일
	private String wTime; // 기상 시간
	private String wTemp; // 온도
	private String wWindSpeed; // 풍속
	private String wWaveHeight; // 파고
	private String wSeaTemp; // 해수 온도
	private String statBattery; // 배터리상태
	private String wRegion; // 기상 지역
	private int sailNum;
	private String siCode;

	// mapper에 넣기위한(유진)
	// 새로운 생성자 추가
	public Weather(String siCode, int sailNum) {
		this.siCode = siCode;
		this.sailNum = sailNum;
	}

}
