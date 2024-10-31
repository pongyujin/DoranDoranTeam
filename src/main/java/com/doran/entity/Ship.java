package com.doran.entity;

import org.springframework.web.multipart.MultipartFile;

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
public class Ship {
	
    private String siCode; // 선박 코드
    private String memId; // 소유주 아이디
    private String siName; // 선박 이름
    private MultipartFile siDocsFile; // 선박 증빙서류
    private String siDocs; // 선박 증빙서류 이름
    private char siCert; // 인증 여부
    private char sailStatus; // 운항 상태
    private String shipId;
    private String ownerId; // 선박 소유자 정보
    private String filePath; // 파일 경로
    private String siCertReason; //승인 거절 이유
}
