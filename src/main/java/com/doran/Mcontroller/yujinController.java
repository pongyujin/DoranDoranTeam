package com.doran.Mcontroller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.doran.entity.Sail;
import com.doran.mapper.SailMapper;

@Controller
public class yujinController {

	@Autowired
	private SailMapper sailMapper;

	
	// 항해리스트 뽑는 
	@GetMapping("/sailList")
	@ResponseBody // JSON 형식으로 반환을 보장하기 위해 추가
	public List<Sail> ALLsailList(@RequestParam String siCode) {
		Sail sail = new Sail();
		sail.setSiCode(siCode);

		List<Sail> sailList = sailMapper.sailList(sail);
		System.out.println("yujinController : " + sailList);
		return sailList;
	}

}
