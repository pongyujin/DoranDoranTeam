package com.doran.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;

import com.doran.entity.Gps;

@Mapper
public interface GpsMapper {

	public List<Gps> getGps(int sailNum);
	// 2. gps 정보 실시간 저장(항해 시작 시)
	public int insertGps(Gps gps);
	

}
