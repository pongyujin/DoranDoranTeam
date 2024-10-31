package com.doran.mapper;

import org.apache.ibatis.annotations.Mapper;

import com.doran.entity.Waypoint;

@Mapper
public interface WaypointMapper {

	// 1. db에 경유지 저장(insert)
	public void waypointInsert(Waypoint waypoint);

}
