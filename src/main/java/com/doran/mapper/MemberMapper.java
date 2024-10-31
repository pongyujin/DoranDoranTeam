package com.doran.mapper;

import org.apache.ibatis.annotations.Mapper;

import com.doran.entity.Member;

@Mapper
public interface MemberMapper {

	// 1. 회원가입
	public int memberJoin(Member member);
	// 2. 로그인
	public Member memberLogin(Member member);
	// 3. 아이디 중복 체크
	public Member registerCheck(String memID);
	// 4. 회원 정보 수정
	public int memberUpdate(Member member);
	
	// 정유진 작성 
	// 5. 구글로그인 DB저장
	public void googleMemberJoin(Member member);
	// 6. 구글로그인할때 DB에 저장된 값 있나 확인
	public Member googleMemberCheck(String memEmail);
	
}
