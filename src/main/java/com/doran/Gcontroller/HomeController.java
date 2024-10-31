package com.doran.Gcontroller;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Controller
public class HomeController {
	// Client ID를 환경 변수에서 가져옵니다.
	@Value("${GOOGLE_CLIENT_ID}")
	private String googleClientId;

	@Value("${KAKAO_CLIENT_ID}")
	private String kakaoClientId;

	@Value("${NAVER_CLIENT_ID}")
	private String naverClientId;

	// 기본 홈 페이지
	@RequestMapping("/")
	public String main() {
		return "home";
	}

	// 통계 페이지로 이동 (권한 확인 불필요)
	@GetMapping("/statistics")
	public String showStatisticsPage(@RequestParam String siCode, Model model) {
		// siCode를 전달하여 통계 페이지에서 사용할 수 있도록 설정
		model.addAttribute("siCode", siCode);

		return "ShipStatistics"; // ShipStatistics.jsp로 이동
	}

	// 메인 페이지 이동
	@GetMapping("/main")
	public String showMainPage(Model model) {

		return "Main";

	}

	// 메인 페이지 이동
	@GetMapping("/main2")
	public String showMainPage2(Model model) {

		// OAuth 로그인에 필요한 Client ID를 모델에 추가하여 JSP로 전달
		model.addAttribute("googleClientId", googleClientId);
		model.addAttribute("kakaoClientId", kakaoClientId);
		model.addAttribute("naverClientId", naverClientId);
		
		System.out.println("googleCientID" + googleClientId);
		System.out.println("kakaoClientId" + kakaoClientId);
		System.out.println("naverClientId" + naverClientId);

		return "Main2";

	}
	
	// 메인 페이지 이동
	@GetMapping("/main3")
	public String showMainPage3(Model model) {

		return "Main3";

	}

	// Manager 관리자 페이지 추가
	@GetMapping("/manager")
	public String showManagerPage() {
		return "Manager";
	}

	// motorControlTest.jsp 이동 (수동제어 테스트용입니당)
	@GetMapping("/motorControlTest")
	public String motorControlTestPage() {
		return "motorControlTest";
	}
}
