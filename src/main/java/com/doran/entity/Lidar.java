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
public class Lidar {
	
	private int lidNum; // 라이다 번호
	private String siCode; // 선박 코드
	private String obsName; // 장애물 이름
	private int obsDist; // 장애물과의 거리
	private String createdAt; // 등록 시간
	private int sailNum; // 항해 번호
}
