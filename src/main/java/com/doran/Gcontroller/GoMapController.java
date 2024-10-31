package com.doran.Gcontroller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
public class GoMapController {

	// Controller.jsp 이동
	@RequestMapping("/map2")
	public String showController() {
		return "Controller";
	}

	// Controller2.jsp 이동 (허재혁 작업중)
	@RequestMapping("/map3")
	public String showController2() {
		return "Controller2";
	}

	// Controller2.jsp 이동 (지해님 디자인)
	@RequestMapping("/map4")
	public String showController3() {
		return "Controller3";
	}

	// Controller4.jsp 이동 (a* 연동)
	@RequestMapping("/Controller4")
	public String showController4() {
		return "Controller4";
	}

	// videoModal.jsp 이동
	@RequestMapping("/videoModal")
	public String showVideoModal() {
		return "videoModal";
	}

	// waypoint.jsp 이동
	@RequestMapping("/waypoint")
	public String waypoint() {
		return "waypoint";
	}

	// designation.jsp 이동
	@RequestMapping("/designation")
	public String designation() {
		return "designation";
	}
}
