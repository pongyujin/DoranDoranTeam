select * from member;


INSERT INTO member (memId, memPw, memNick, memEmail, memPhone)
VALUES ('joy', '1234', '조이', 'joy@gmail.com', '010-1234-5678');
INSERT INTO ship (siCode, memId, siName, siDocs, siCert, sailStatus)
VALUES ('oliviaship01', 'sohui', 'olivia Voyager', 'Registration', '1', '0');
INSERT INTO shipGroup (siCode, memId, authNum, comment)
VALUES('oliviaship01', 'ningning', 3, 'ningning')

INSERT INTO authority (authNum, authName, authDesc) VALUES
(0, 'ADMIN', '모든 권한을 가진 관리자'),
(1, 'VIEWER', '보기 권한'),
(2, 'CONTROLLER', '제어 권한'),
(3, 'EDITOR', '콘텐츠 편집 권한')

ALTER TABLE sail
ADD COLUMN startSail VARCHAR(100) NOT NULL COMMENT '출발 항해 정보',
ADD COLUMN endSail VARCHAR(100) NOT NULL COMMENT '목적지 항해 정보';























---------------------------------------------------------------------------------

CREATE TABLE member
(
    `memId`     VARCHAR(50)     NOT NULL    COMMENT '회원 아이디', 
    `memPw`     VARCHAR(100)    NOT NULL    COMMENT '회원 비밀번호', 
    `memNick`   VARCHAR(30)     NOT NULL    COMMENT '회원 닉네임', 
    `memEmail`  VARCHAR(50)     NOT NULL    COMMENT '회원 이메일', 
    `memPhone`  VARCHAR(20)     NOT NULL    COMMENT '회원 전화번호', 
    `joinedAt`  TIMESTAMP       NOT NULL    DEFAULT CURRENT_TIMESTAMP COMMENT '회원 가입일자', 
    PRIMARY KEY (memId)
);

ALTER TABLE member COMMENT '회원정보';

CREATE UNIQUE INDEX UQ_member_1
    ON member(memNick, memEmail, memPhone);

---------------------------------------------------------------------------------    

CREATE TABLE ship
(
    `siCode`      VARCHAR(100)     NOT NULL    COMMENT '선박 코드', 
    `memId`       VARCHAR(50)      NOT NULL    COMMENT '회원 아이디', 
    `siName`      VARCHAR(100)     NOT NULL    COMMENT '선박 명', 
    `siDocs`      VARCHAR(1000)    NOT NULL    COMMENT '선박 증빙서류', 
    `siCert`      CHAR(1)          NOT NULL    COMMENT '선박 인증여부', 
    `sailStatus`  CHAR(1)          NOT NULL    COMMENT '운항 상태', 
    PRIMARY KEY (siCode)
);

-- 테이블 Comment 설정 SQL - ship
ALTER TABLE ship COMMENT '선박정보';

-- Foreign Key 설정 SQL - ship(memId) -> member(memId)
ALTER TABLE ship
    ADD CONSTRAINT FK_ship_memId_member_memId FOREIGN KEY (memId)
        REFERENCES member (memId) ON DELETE RESTRICT ON UPDATE RESTRICT;
---------------------------------------------------------------------------------

-- sail Table Create SQL
-- 테이블 생성 SQL - sail
CREATE TABLE sail
(
    `sailNum`    INT UNSIGNED       NOT NULL    AUTO_INCREMENT COMMENT '항해 번호', 
    `siCode`     VARCHAR(100)       NOT NULL    COMMENT '선박 코드', 
    `createdAT`  TIMESTAMP          NOT NULL    DEFAULT CURRENT_TIMESTAMP COMMENT '등록 일자', 
    `startLat`   DECIMAL(17, 14)    NOT NULL    COMMENT '출발지 위도', 
    `startLng`   DECIMAL(17, 14)    NOT NULL    COMMENT '출발지 경도', 
    `endLat`     DECIMAL(17, 14)    NOT NULL    COMMENT '목적지 위도', 
    `endLng`     DECIMAL(17, 14)    NOT NULL    COMMENT '목적지 경도', 
    `comment`    TEXT               NULL        COMMENT '코멘트', 
    PRIMARY KEY (sailNum)
);
        
-- 테이블 Comment 설정 SQL - sail
ALTER TABLE sail COMMENT '항해 정보 테이블';

-- Foreign Key 설정 SQL - sail(siCode) -> ship(siCode)
ALTER TABLE sail
    ADD CONSTRAINT FK_sail_siCode_ship_siCode FOREIGN KEY (siCode)
        REFERENCES ship (siCode) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE waypoint 
DROP FOREIGN KEY FK_waypoint_sailNum_sail_sailNum;

ALTER TABLE gps 
DROP FOREIGN KEY FK_gps_sailNum_sail_sailNum;

ALTER TABLE camera 
DROP FOREIGN KEY FK_camera_sailNum_sail_sailNum;

ALTER TABLE lidar 
DROP FOREIGN KEY FK_lidar_sailNum_sail_sailNum;

ALTER TABLE weather 
DROP FOREIGN KEY FK_weather_sailNum_sail_sailNum;

        
-- 1. sailNum의 자동 증가 속성 제거 (ALTER COLUMN 사용)
ALTER TABLE sail 
MODIFY COLUMN sailNum INT UNSIGNED NOT NULL COMMENT '항해 번호';

-- 2. 기존의 기본 키 삭제
ALTER TABLE sail 
DROP PRIMARY KEY;

ALTER TABLE sail 
ADD PRIMARY KEY (siCode, sailNum);

-- 3. siCode에 따라 자동증가 트리거 (super 권한없어서 실행못시킴)
CREATE TRIGGER before_insert_sail
BEFORE INSERT ON sail
FOR EACH ROW
BEGIN
    SET NEW.sailNum = COALESCE((SELECT MAX(sailNum) FROM sail WHERE siCode = NEW.siCode), 0) + 1;
END;

-- sail 테이블에 인덱스 추가
ALTER TABLE sail
ADD INDEX idx_sailNum (sailNum);

INSERT INTO sail (siCode, sailNum, startLat, startLng, endLat, endLng, comment) VALUES ('ship123', COALESCE((SELECT MAX(sailNum) FROM sail WHERE siCode \= 'ship123'), 0) + 1, 34.123456, 126.123456, 35.123456, 127.123456, '항해 코멘트');
        
--------------------------------------------------------------------------------
-- authority Table Create SQL
-- 테이블 생성 SQL - authority
CREATE TABLE authority
(
    `authNum`   INT UNSIGNED    NOT NULL    COMMENT '권한 번호', 
    `authName`  VARCHAR(50)     NOT NULL    COMMENT '권한 이름', 
    `authDesc`  TEXT            NOT NULL    COMMENT '권한 설명', 
    PRIMARY KEY (authNum)
);

ALTER TABLE authority COMMENT '권한 설명 테이블';

-------------------------------------------------------------------------------
-- waypoint Table Create SQL
-- 테이블 생성 SQL - waypoint
CREATE TABLE waypoint
(
    `statNum`      INT UNSIGNED       NOT NULL    AUTO_INCREMENT COMMENT '상태 번호', 
    `siCode`       VARCHAR(100)       NOT NULL    COMMENT '선박 코드', 
    `wayPoint`     INT UNSIGNED       NOT NULL    COMMENT '경유지 번호', 
    `statDest`     VARCHAR(100)       NOT NULL    COMMENT '지점 명', 
    `statLat`      DECIMAL(17, 14)    NOT NULL    COMMENT '지점 위도', 
    `statLng`      DECIMAL(17, 14)    NOT NULL    COMMENT '지점 경도', 
    `statRoute`    VARCHAR(1000)      NOT NULL    COMMENT '이동 경로', 
    `statBattery`  VARCHAR(50)        NOT NULL    COMMENT '배터리  상태', 
    `createdAt`    TIMESTAMP          NOT NULL    DEFAULT CURRENT_TIMESTAMP COMMENT '등록 날짜', 
    `sailNum`      INT UNSIGNED       NOT NULL    COMMENT '항해 번호', 
    PRIMARY KEY (statNum)
);

-- 테이블 Comment 설정 SQL - waypoint
ALTER TABLE waypoint COMMENT '선박 경로 (경유지)';

-- Foreign Key 설정 SQL - waypoint(siCode) -> ship(siCode)
ALTER TABLE waypoint
    ADD CONSTRAINT FK_waypoint_siCode_ship_siCode FOREIGN KEY (siCode)
        REFERENCES ship (siCode) ON DELETE RESTRICT ON UPDATE RESTRICT;
        
        -- Foreign Key 설정 SQL - waypoint(sailNum) -> sail(sailNum)
ALTER TABLE waypoint
    ADD CONSTRAINT FK_waypoint_sailNum_sail_sailNum FOREIGN KEY (sailNum)
        REFERENCES sail (sailNum) ON DELETE RESTRICT ON UPDATE RESTRICT;
-------------------------------------------------------------------------------

-- gps Table Create SQL
-- 테이블 생성 SQL - gps
CREATE TABLE gps
(
    `gpsNum`    INT UNSIGNED       NOT NULL    AUTO_INCREMENT COMMENT 'GPS 번호', 
    `siCode`    VARCHAR(100)       NOT NULL    COMMENT '선박 코드', 
    `gpsLat`    DECIMAL(17, 14)    NOT NULL    COMMENT '위도', 
    `gpsLng`    DECIMAL(17, 14)    NOT NULL    COMMENT '경도', 
    `gpsSpeed`  DECIMAL(10, 1)     NOT NULL    COMMENT '속도', 
    `gpsDir`    VARCHAR(50)        NOT NULL    COMMENT '방위', 
    `gpsTime`   TIMESTAMP          NOT NULL    DEFAULT CURRENT_TIMESTAMP COMMENT '등록 시간', 
    `sailNum`   INT UNSIGNED       NOT NULL    COMMENT '항해 번호', 
    PRIMARY KEY (gpsNum)
);

-- 테이블 Comment 설정 SQL - gps
ALTER TABLE gps COMMENT 'GPS 정보';

-- Foreign Key 설정 SQL - gps(siCode) -> ship(siCode)
ALTER TABLE gps
    ADD CONSTRAINT FK_gps_siCode_ship_siCode FOREIGN KEY (siCode)
        REFERENCES ship (siCode) ON DELETE RESTRICT ON UPDATE RESTRICT;
        
ALTER TABLE gps
    ADD CONSTRAINT FK_gps_sailNum_sail_sailNum FOREIGN KEY (sailNum)
        REFERENCES sail (sailNum) ON DELETE RESTRICT ON UPDATE RESTRICT;

---------------------------------------------------------------------------------
-- camera Table Create SQL
-- 테이블 생성 SQL - camera
CREATE TABLE camera
(
    `imgNum`     INT UNSIGNED     NOT NULL    AUTO_INCREMENT COMMENT '이미지 번호', 
    `siCode`     VARCHAR(100)     NOT NULL    COMMENT '선박 코드', 
    `obsName`    VARCHAR(100)     NOT NULL    COMMENT '장애물 명', 
    `obsImg`     VARCHAR(1000)    NOT NULL    COMMENT '장애물 이미지', 
    `createdAt`  TIMESTAMP        NOT NULL    DEFAULT CURRENT_TIMESTAMP COMMENT '등록 일자', 
    `sailNum`    INT UNSIGNED     NOT NULL    COMMENT '항해 번호', 
    PRIMARY KEY (imgNum)
);
        
-- 테이블 Comment 설정 SQL - camera
ALTER TABLE camera COMMENT '카메라정보';

-- Foreign Key 설정 SQL - camera(siCode) -> ship(siCode)
ALTER TABLE camera
    ADD CONSTRAINT FK_camera_siCode_ship_siCode FOREIGN KEY (siCode)
        REFERENCES ship (siCode) ON DELETE RESTRICT ON UPDATE RESTRICT;

        -- Foreign Key 설정 SQL - camera(sailNum) -> sail(sailNum)
ALTER TABLE camera
    ADD CONSTRAINT FK_camera_sailNum_sail_sailNum FOREIGN KEY (sailNum)
        REFERENCES sail (sailNum) ON DELETE RESTRICT ON UPDATE RESTRICT;

------------------------------------------------------------------------------
-- lidar Table Create SQL
-- 테이블 생성 SQL - lidar
CREATE TABLE lidar
(
    `lidNum`     INT UNSIGNED    NOT NULL    AUTO_INCREMENT COMMENT '라이다 번호', 
    `siCode`     VARCHAR(100)    NOT NULL    COMMENT '선박 코드', 
    `obsName`    VARCHAR(100)    NOT NULL    COMMENT '장애물 이름', 
    `obsDist`    INT             NOT NULL    COMMENT '장애물과의 거리', 
    `createdAt`  TIMESTAMP       NOT NULL    DEFAULT CURRENT_TIMESTAMP COMMENT '등록 시간', 
    `sailNum`    INT UNSIGNED    NOT NULL    COMMENT '항해 번호', 
     PRIMARY KEY (lidNum)
);

-- 테이블 Comment 설정 SQL - lidar
ALTER TABLE lidar COMMENT '라이다';

-- Foreign Key 설정 SQL - lidar(siCode) -> ship(siCode)
ALTER TABLE lidar
    ADD CONSTRAINT FK_lidar_siCode_ship_siCode FOREIGN KEY (siCode)
        REFERENCES ship (siCode) ON DELETE RESTRICT ON UPDATE RESTRICT;

-- Foreign Key 설정 SQL - lidar(sailNum) -> sail(sailNum)
ALTER TABLE lidar
    ADD CONSTRAINT FK_lidar_sailNum_sail_sailNum FOREIGN KEY (sailNum)
        REFERENCES sail (sailNum) ON DELETE RESTRICT ON UPDATE RESTRICT;
------------------------------------------------------------------------------
-- weather Table Create SQL
-- 테이블 생성 SQL - weather
CREATE TABLE weather
(
    `wNum`         INT UNSIGNED    NOT NULL    AUTO_INCREMENT COMMENT '기상 번호', 
    `wDate`        DATE            NOT NULL    COMMENT '기상 날짜', 
    `wTime`        TIME            NOT NULL    COMMENT '기상 시간', 
    `wTemp`        DECIMAL(4,1)    NOT NULL    COMMENT '기온', 
    `wWindSpeed`   DECIMAL(4,1)    NOT NULL    COMMENT '풍속', 
    `wWaveHeight`  DECIMAL(4,1)    NOT NULL    COMMENT '파고', 
    `wSeaTemp`     DECIMAL(4,1)    NOT NULL    COMMENT '수온', 
    `wRegion`      VARCHAR(50)     NOT NULL    COMMENT '기상 지역', 
    `sailNum`      INT UNSIGNED    NOT NULL    COMMENT '항해 번호', 
    `siCode`       VARCHAR(100)    NOT NULL    COMMENT '선박 코드', 
     PRIMARY KEY (wNum)
);

-- 테이블 Comment 설정 SQL - weather
ALTER TABLE weather COMMENT '기상정보';

-- Foreign Key 설정 SQL - weather(sailNum) -> sail(sailNum)
ALTER TABLE weather
    ADD CONSTRAINT FK_weather_sailNum_sail_sailNum FOREIGN KEY (sailNum)
        REFERENCES sail (sailNum) ON DELETE RESTRICT ON UPDATE RESTRICT;

-- Foreign Key 설정 SQL - weather(siCode) -> ship(siCode)
ALTER TABLE weather
    ADD CONSTRAINT FK_weather_siCode_ship_siCode FOREIGN KEY (siCode)
        REFERENCES ship (siCode) ON DELETE RESTRICT ON UPDATE RESTRICT;
------------------------------------------------------------------------------
-- group Table Create SQL
-- 테이블 생성 SQL - group
CREATE TABLE shipGroup
(
    `grpNum`     INT UNSIGNED    NOT NULL    AUTO_INCREMENT COMMENT '그룹 번호',
    `siCode`     VARCHAR(100)    NOT NULL    COMMENT '선박 코드',
    `memId`      VARCHAR(50)     NOT NULL    COMMENT '초대인 아이디',
    `createdAT`  TIMESTAMP       NOT NULL    DEFAULT CURRENT_TIMESTAMP COMMENT '등록 일자',
    `authNum`    INT UNSIGNED    NOT NULL    COMMENT '권한 번호',
    `comment`    TEXT            NULL        COMMENT '초대인 설명',
     PRIMARY KEY (grpNum)
);
        
-- 테이블 Comment 설정 SQL - group
ALTER TABLE shipGroup COMMENT '그룹 만드는 테이블';

-- Foreign Key 설정 SQL - group(siCode) -> ship(siCode)
ALTER TABLE shipGroup
    ADD CONSTRAINT FK_shipGroup_siCode_ship_siCode FOREIGN KEY (siCode)
        REFERENCES ship (siCode) ON DELETE RESTRICT ON UPDATE RESTRICT;

-- Foreign Key 설정 SQL - group(memId) -> member(memId)
ALTER TABLE shipGroup
    ADD CONSTRAINT FK_shipGroup_memId_member_memId FOREIGN KEY (memId)
        REFERENCES member (memId) ON DELETE RESTRICT ON UPDATE RESTRICT;
        
-- Foreign Key 설정 SQL - group(authNum) -> authority(authNum)
ALTER TABLE shipGroup
    ADD CONSTRAINT FK_shipGroup_authNum_authority_authNum FOREIGN KEY (authNum)
        REFERENCES authority (authNum) ON DELETE RESTRICT ON UPDATE RESTRICT;
        

