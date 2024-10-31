package com.doran.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;

import com.doran.entity.Weather;

@Mapper
public interface WeatherMapper {

	// 1. 현재 시각 기상 정보 저장
	public void insertWeather(Weather weather);
	// 2. 선박코드와 항해번호로 기상정보 불러오기
	public List<Weather> weatherList(Weather weather);

}
