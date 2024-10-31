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
public class Sail {
	
    private int sailNum; // 항해 번호
    private String siCode; // 선박 코드
    private String createdAt; // 등록 날짜
    private String startSail;
    private String endSail;
    private double startLat;
    private double startLng;
    private double endLat;
    private double endLng;
    private String comment;
}