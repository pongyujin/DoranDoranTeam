package com.doran.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;

import com.doran.entity.Ship;
import com.doran.entity.ShipGroup;

@Mapper
public interface ShipGroupMapper {

	// 1. 그룹 멤버 리스트 전체 불러오기
	public List<ShipGroup> groupList(String siCode);
	// 2. 그룹 초대
	public int invite(ShipGroup shipGroup);
	// 3. 권한 수정
	public void update(ShipGroup shipGroup);
	// 4. 권한 확인
	public ShipGroup authCheck(ShipGroup shipGroup);
	// 5. 회원 삭제
	public void delete(ShipGroup shipGroup);
	// 6. 최초 선박 등록
	public int shipRegister(Ship ship);
	
	// 중복 사용자 초대 불가하게
	public ShipGroup findMemberInGroup(ShipGroup shipGroup);
	
}
