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
public class Authority {
	
    private int authNum; // 권한 번호
    private String authName; // 권한 이름
    private String authDesc; // 권한 설명
}
