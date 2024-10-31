package com.doran.entity;

public class Coordinate {
	private double lat;
	private double lng;

	// 기본 생성자 (필수)
    public Coordinate() {}
	
	// 생성자
	public Coordinate(double lat, double lng) {
		this.lat = lat;
		this.lng = lng;
	}

	// Getter, Setter
	public double getLat() {
		return lat;
	}

	public void setLat(double lat) {
		this.lat = lat;
	}

	public double getLng() {
		return lng;
	}

	public void setLng(double lng) {
		this.lng = lng;
	}
}
