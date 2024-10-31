package com.doran.Mcontroller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.doran.entity.Weather;
import com.doran.mapper.WeatherMapper;

@RequestMapping("/weather")
@RestController
public class DbWeatherController {

	@Autowired
	private WeatherMapper weatherMapper;

	// 1. db에서 기상 정보 모두 불러오기(항해 번호, 선박 코드)
	@RequestMapping("/all")
	public List<Weather> weatherList(Weather weather) {
		
		List<Weather> weatherList = weatherMapper.weatherList(weather);
		return weatherList;
	}

}