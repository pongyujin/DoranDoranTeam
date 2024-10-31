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
public class Gps {
	
    private int gpsNum; // GPS 번호
    private String siCode; // 선박 코드
    private double gpsLat; // 위도
    private double gpsLng; // 경도
    private double gpsSpeed; // 속도
    private double gpsDir; // 방향
    private String gpsTime; // 등록 시간
    private int sailNum; // 항해 번호
}
