package com.doran.Hcontroller;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import com.doran.entity.Camera;
import com.doran.mapper.CameraMapper;
import com.fasterxml.jackson.databind.ObjectMapper;

@RestController
@RequestMapping("/receive-data")
public class HwCameraController {
	// 일단 DB저장 안하고있음
	// 여기서 매퍼 가져와야할듯

	@Autowired
	private CameraMapper cameraMapper;

	// 멀티파트 데이터를 수신하여 처리
	@PostMapping(consumes = "multipart/form-data")
	public ResponseEntity<String> receiveData(@RequestParam("json") String jsonData,
			@RequestParam("image") MultipartFile imageFile) {
		try {
			// JSON 데이터를 파싱하여 감지 객체 리스트로 변환
			ObjectMapper objectMapper = new ObjectMapper();
			List<Map<String, Object>> detections = objectMapper.readValue(jsonData, List.class);
			System.out.println("HWCameraController detections : " + detections);

			// 이미지 파일이 존재하는지 확인 후 처리
			if (imageFile != null && !imageFile.isEmpty()) {
				byte[] imageBytes = imageFile.getBytes(); // 이미지 파일 바이트 데이터

				// 각 감지된 객체에 대해 데이터베이스에 저장
				for (Map<String, Object> detection : detections) {
					String className = (String) detection.get("className"); // 감지된 객체의 클래스 이름
					if (className != null && !className.isEmpty()) {
						// 일단 넣어보기
						Camera camera = new Camera();
						camera.setSiCode("7"); // siCode 값을 7로 설정
						camera.setSailNum(1); // sailNum 값을 1로 설정
						camera.setObsName(className);
						camera.setObsImg(imageBytes); // 이미지 바이트 데이터를 설정

						// 현재 날짜를 설정 (createdAt은 NOW()로 자동 설정됨)
						int cnt = cameraMapper.cameraInsert(camera); // DB에 저장
						if(cnt>0) {
							System.out.println("HWCameraController DB 저장 성공" + className);
						}else {
							System.out.println("HWCameraController DB 저장 실패!!!!!");
						}
					}
				}
			}
			return ResponseEntity.ok("Data and image saved successfully in the database");
		} catch (Exception e) {
			e.printStackTrace();
			return ResponseEntity.status(500).body("Failed to process the request");
		}
	}

	// 이미지 파일을 DB에서 불러와 반환하는 엔드포인트 추가
	@GetMapping("/image/{imgNum}")
	public ResponseEntity<byte[]> getImage(@PathVariable int imgNum) {
		try {
			// imgNum에 해당하는 Camera 객체를 DB에서 조회
			Camera camera = cameraMapper.selectCameraByImgNum(imgNum);

			if (camera != null && camera.getObsImg() != null) {
				// 이미지 데이터를 byte 배열로 가져오기
				byte[] imageBytes = camera.getObsImg();

				// Http 헤더 설정 (이미지 형식 지정)
				HttpHeaders headers = new HttpHeaders();
				headers.setContentType(MediaType.IMAGE_JPEG);

				// ResponseEntity를 통해 이미지 데이터를 반환
				return new ResponseEntity<>(imageBytes, headers, HttpStatus.OK);
			} else {
				return ResponseEntity.status(HttpStatus.NOT_FOUND).body(null);
			}
		} catch (Exception e) {
			e.printStackTrace();
			return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(null);
		}
	}

}
