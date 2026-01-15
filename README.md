# 📎 무인 선박 원격 제어 웹 플랫폼 (팀명: 도란도란팀)

## 👀 서비스 소개
* 서비스명: 무인 선박 원격 제어 웹 플랫폼
* 서비스설명: Raspberry Pi 기반 IoT 선박 제어 시스템
<br>

## 📅 프로젝트 기간
2024.09.24 ~ 2022.11.06 (6주)
<br>

## ⭐ 주요 기능
* 영양제 추천
* 검색
* 게시판
* 마이페이지
<br>

## ⛏ 기술스택

[![stackticon](https://firebasestorage.googleapis.com/v0/b/stackticon-81399.appspot.com/o/images%2F1768445267862?alt=media&token=1889d83c-e216-491c-a96f-09f0339ba95f)](https://github.com/msdio/stackticon)

<br>

## ⚙ 시스템 아키텍처(구조)
![image](/system-architecture.png)
<br>

## 📌 SW유스케이스
![image](/service-flow.png)
<br>


## 📌 ER다이어그램
![image](/er-diagram.png)

<br>

## 🖥 화면 구성

### 메인화면
<img src="./mainpage.gif" width="700"/>
<br>

### 시현영상
![image](/vidio.mp4)
다운로드하셔서 시청하셔야합니다!
<br>

### 선박모형 제어부/센서부/추진부
![image](/boatpage.png)
<br>

### 선박 카메라/라이다 장애물 인식
![image](/boat2.png)
<br>

### 관제화면 선박정보확인/실시간영상/실시간데이터
![image](/page4.gif)
<br>

### 관제화면 항해시작
![image](/page_1.gif)
<br>

### 관제화면 자동수동모드/flask서버배포
![image](/page_2.gif)
<br>

### 회원가입/비밀번호 해시 저장
![image](/page2.png)
<br>

### 선박DB를 통한 통계페이지
![image](/page3.png)
<br>



## 👨‍👩‍👦‍👦 팀원 역할
<table>
  <tr>
    <td align="center"><img src="https://item.kakaocdn.net/do/fd49574de6581aa2a91d82ff6adb6c0115b3f4e3c2033bfd702a321ec6eda72c" width="100" height="100"/></td>
    <td align="center"><img src="https://mb.ntdtv.kr/assets/uploads/2019/01/Screen-Shot-2019-01-08-at-4.31.55-PM-e1546932545978.png" width="100" height="100"/></td>
    <td align="center"><img src="https://mblogthumb-phinf.pstatic.net/20160127_177/krazymouse_1453865104404DjQIi_PNG/%C4%AB%C4%AB%BF%C0%C7%C1%B7%BB%C1%EE_%B6%F3%C0%CC%BE%F0.png?type=w2" width="100" height="100"/></td>
    <td align="center"><img src="https://i.pinimg.com/236x/ed/bb/53/edbb53d4f6dd710431c1140551404af9.jpg" width="100" height="100"/></td>
    <td align="center"><img src="https://pbs.twimg.com/media/B-n6uPYUUAAZSUx.png" width="100" height="100"/></td>
  </tr>
  <tr>
    <td align="center"><strong>정유진</strong></td>
    <td align="center"><strong>고우석</strong></td>
    <td align="center"><strong>허재혁</strong></td>
    <td align="center"><strong>문지해</strong></td>
    <td align="center"><strong>박소희</strong></td>
  </tr>
  <tr>
    <td align="center"><b>PM,Backend,Fronted</b></td>
    <td align="center"><b>Embedded Engineer,Modeling</b></td>
    <td align="center"><b>Backend,Embedded Engineer</b></td>
    <td align="center"><b>Frontend</b></td>
    <td align="center"><b>Backend,Modeling</b></td>
  </tr>
  <tr>
    <td align="center"><a href="https://github.com/pongyujin" target='_blank'>pongyujin</a></td>
    <td align="center"><a href="https://github.com/자신의username작성해주세요" target='_blank'>github</a></td>
    <td align="center"><a href="https://github.com/자신의username작성해주세요" target='_blank'>github</a></td>
    <td align="center"><a href="https://github.com/wlgo1234" target='_blank'>wlgo1234</a></td>
    <td align="center"><a href="https://github.com/olilvado" target='_blank'>olilvado</a></td>
  </tr>
</table>

## 🤾‍♂️ 트러블슈팅
  
* 라즈베리파이의 성능 제약으로 YOLO모델 실행불가.<br>
![image](/page_3.png)

-> Flask서버를 구축하여 HTTP기반 실시간 영상 스트리밍

<br>
<br>

* 이미지 파일 저장의 정확도,빈번한이미지 저장,중복저장,덮어쓰기 문제<br>
![image](/page_4.png)
-> 정확도 기반 필터링(70%이상), 시간간격제한(5초간격), 중복방지, 고유한파일이름(현재날짜,시간명)

* A* 알고리즘 경유점 설정의 경유점을 추가하면서 다음 경유점으로 가지 못하는 문제.<br>
![image](/page_5.png)
-> 경유점과의 거리간격을 500m로 확대
