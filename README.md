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

### 그룹권한 설정
![image](/page1.png)
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
    <td align="center"><strong>김소리</strong></td>
    <td align="center"><strong>고우석</strong></td>
    <td align="center"><strong>강수민</strong></td>
    <td align="center"><strong>문지해</strong></td>
    <td align="center"><strong>정유진</strong></td>
  </tr>
  <tr>
    <td align="center"><b>Backend</b></td>
    <td align="center"><b>Backend</b></td>
    <td align="center"><b>Frontend</b></td>
    <td align="center"><b>Frontend</b></td>
    <td align="center"><b>Backend</b></td>
  </tr>
  <tr>
    <td align="center"><a href="https://github.com/Kim-So-Ri" target='_blank'>Kim-So-Ri</a></td>
    <td align="center"><a href="https://github.com/자신의username작성해주세요" target='_blank'>github</a></td>
    <td align="center"><a href="https://github.com/자신의username작성해주세요" target='_blank'>github</a></td>
    <td align="center"><a href="https://github.com/wlgo1234" target='_blank'>wlgo1234</a></td>
    <td align="center"><a href="https://github.com/pongyujin" target='_blank'>pongyujin</a></td>
  </tr>
</table>

## 🤾‍♂️ 트러블슈팅
  
* AI API 실행 했을 때 10번 중 1번은 서버 오류로 값이 전달 되지 않았다.<br>

![image](https://github.com/user-attachments/assets/7e10b3f5-26e4-4831-849f-7003195a815a)
-> for문과 if문을 걸어서 값이 없을 경우 2초 쉬고 다시 실행하는 로직 생성

<br>
<br>

*  톰캣 서버가 패키지들의 경로들을 찾지 못해서 서버가 열리지 않았다<br>
->프로젝트 삭제 후 깃허브에 있는 파일 다시 가져옴 Maven Update Clean 작업 후 가능해졌다!!!



