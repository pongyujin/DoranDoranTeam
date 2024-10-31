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
public class ShipGroup {
	
    private int grpNum; // 그룹 번호
    private String siCode; // 선박 코드
    private String memId; // 초대인 아이디
    private String createdAt; // 등록 날짜
    private int authNum; // 권한 번호
    private String comment; // 코멘트
}
