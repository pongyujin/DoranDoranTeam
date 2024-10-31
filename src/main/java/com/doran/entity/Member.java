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
public class Member {
	
    private String memId; // 회원 아이디
    private String memPw; // 회원 비밀번호
    private String memNick; // 회원 닉네임
    private String memEmail; // 회원 이메일
    private String memPhone; // 회원 전화번호
    private String joinedAt; // 가입일
}
