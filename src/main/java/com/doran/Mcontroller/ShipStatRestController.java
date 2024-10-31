package com.doran.Mcontroller;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import com.doran.entity.Camera;
import com.doran.entity.Gps;
import com.doran.entity.Weather;
import com.doran.mapper.CameraMapper;
import com.doran.mapper.GpsMapper;
import com.doran.mapper.WeatherMapper;

@RequestMapping("/statistics")
@RestController
public class ShipStatRestController {

	@Autowired
	private GpsMapper gpsmapper;

	@Autowired
	private WeatherMapper weathermapper;

	@Autowired
	private CameraMapper cameraMapper;

	// GPS데이터와 날씨데이터 가져와서 지도랑 그래프 그리는 메서드
	@GetMapping("/{siCode}/{sailNum}")
	@CrossOrigin(origins = "http://localhost:8085") // CORS 문제 해결을 위해 추가
	public Map<String, Object> getShipStat(@PathVariable("siCode") String siCode,
			@PathVariable("sailNum") int sailNum) {
		System.out.println(siCode);
		System.out.println(sailNum);

		// GPS 데이터 조회
		List<Gps> gpsList = gpsmapper.getGps(sailNum);
		System.out.println("gpsList : " + gpsList);

		// 날씨+배터리 정보 조회
		List<Weather> weatherList = weathermapper.weatherList(new Weather(siCode, sailNum));
		System.out.println("weatherList : " + weatherList);

		// 결과를 Map으로 반환
		Map<String, Object> response = new HashMap<>();
		response.put("gpsList", gpsList);
		response.put("weatherList", weatherList);

		return response;
	}
	// 10-30 정유진이 주석처리함
	// 원래 통계페이지에서 사진을 업로드해서 정유진컴퓨터 C드라이브에 원본 이미지 데이터를 저장해서
	// ip주소로 접근하여 내 서버에서 다른사람들이 이미지를 가져가서 보여주는 형식으로 했는데
	// 이젠 원본데이터 넣기로함
	
	// 이미지 업로드하는 메서드
	/*
	 * @PostMapping("/upload/image")
	 * 
	 * @CrossOrigin(origins = "http://localhost:8085") // CORS 문제 해결을 위해 추가 public
	 * ResponseEntity<String> uploadImage(@RequestParam("file") MultipartFile
	 * imageFile) { if (!imageFile.isEmpty()) { try { // 파일명 UTF-8로 인코딩 String
	 * originalFileName = imageFile.getOriginalFilename(); if (originalFileName !=
	 * null) { originalFileName = new
	 * String(originalFileName.getBytes("ISO-8859-1"), "UTF-8"); }
	 * 
	 * // 파일명에 UUID 추가하여 저장 (한글 문제 해결) String fileExtension = ""; if
	 * (originalFileName != null && originalFileName.contains(".")) { fileExtension
	 * = originalFileName.substring(originalFileName.lastIndexOf(".")); } String
	 * fileName = UUID.randomUUID().toString() + "_" + originalFileName;
	 * 
	 * System.out.println("[INFO] 업로드된 파일: " + fileName);
	 * 
	 * // 파일 저장 디렉토리 설정 (고정된 경로 사용) String uploadDir = "C:/uploads"; // 고정된 디렉토리 경로
	 * File directory = new File(uploadDir); if (!directory.exists()) {
	 * directory.mkdirs(); // 디렉토리가 없으면 생성
	 * System.out.println("[INFO] 업로드 디렉토리가 존재하지 않아 생성되었습니다: " + uploadDir); }
	 * 
	 * Path uploadPath = Paths.get(uploadDir + "/" + fileName);
	 * 
	 * long startTime = System.currentTimeMillis(); // 파일 저장
	 * Files.copy(imageFile.getInputStream(), uploadPath,
	 * StandardCopyOption.REPLACE_EXISTING); long endTime =
	 * System.currentTimeMillis(); System.out.println("[INFO] 파일 저장 완료. 파일 저장 시간: "
	 * + (endTime - startTime) + "ms"); System.out.println("[INFO] 파일 저장 경로: " +
	 * uploadPath);
	 * 
	 * // Camera 객체 생성 및 데이터 설정 Camera camera = new Camera();
	 * camera.setSiCode("oliviaship01"); camera.setObsName("장애물 이름");
	 * camera.setObsImg("/uploads/" + fileName); // 이미지 경로 설정 (톰캣에서 접근 가능한 경로)
	 * camera.setSailNum(1);
	 * 
	 * // CameraMapper를 통해 데이터베이스에 삽입 int cnt = cameraMapper.cameraInsert(camera);
	 * System.out.println("[INFO] CameraMapper 성공: " + cnt);
	 * 
	 * // 클라이언트가 접근 가능한 URL 반환 String accessibleUrl = "/uploads/" + fileName;
	 * 
	 * return ResponseEntity.ok("파일 업로드 성공: " + accessibleUrl);
	 * 
	 * } catch (IOException e) { return
	 * ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("파일 업로드 실패: " +
	 * e.getMessage()); } } else { return
	 * ResponseEntity.status(HttpStatus.BAD_REQUEST).body("업로드된 파일이 없습니다."); } }
	 */

	@GetMapping("/getImage")
	@CrossOrigin(origins = "http://localhost:8085") // CORS 문제 해결을 위해 추가
	public ResponseEntity<List<Camera>> getImage(@RequestParam("siCode") String siCode,
	                                             @RequestParam("sailNum") int sailNum) {

	    System.out.println("getImage의 siCode : " + siCode);
	    System.out.println("getImage의 sailNum : " + sailNum);

	    Camera cameraParam = new Camera();
	    cameraParam.setSiCode(siCode);
	    cameraParam.setSailNum(sailNum);

	    System.out.println("카메라의 siCode : " + cameraParam.getSiCode());
	    System.out.println("카메라의 sailNum : " + cameraParam.getSailNum());

	    // CameraMapper를 통해 siCode와 sailNum으로 Camera 객체 리스트 가져오기
	    List<Camera> cameras = cameraMapper.getImage(cameraParam);
	    
	    System.out.println();

	    if (cameras != null && !cameras.isEmpty()) {
	        return ResponseEntity.ok(cameras);
	    } else {
	        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(null);
	    }
	}

}
