package com.doran.Mcontroller;

import java.util.List;

import javax.servlet.RequestDispatcher;
import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.doran.entity.Member;
import com.doran.entity.Ship;
import com.doran.mapper.MemberMapper;
import com.doran.mapper.ShipMapper;

@Controller
public class MemberController {

	@Autowired
	private MemberMapper memberMapper;

	// 1. 회원가입
	@PostMapping("/memberJoin")
	public String memberJoin(Member member, RedirectAttributes rttr, HttpSession session) {

		System.out.println(member);

		if (member.getMemId() == null || member.getMemId().equals("") || member.getMemPw() == null
				|| member.getMemPw().equals("") || member.getMemNick() == null || member.getMemNick().equals("")
				|| member.getMemEmail() == null || member.getMemEmail().equals("") || member.getMemPhone() == null
				|| member.getMemPhone().equals("")) {

			// 회원가입 실패
			rttr.addFlashAttribute("msgType", "error");
			rttr.addFlashAttribute("msg", "회원가입");
			rttr.addFlashAttribute("msgDetail", "모든 항목을 기입해주세요");
			session.setAttribute("openJoinModal", true);

		} else {

			int cnt = memberMapper.memberJoin(member);

			if (cnt > 0) {

				rttr.addFlashAttribute("msgType", "success");
				rttr.addFlashAttribute("msg", "회원가입");
				rttr.addFlashAttribute("msgDetail", "회원가입에 성공했습니다");
				session.setAttribute("user", member); // 세션에 유저 저장
			} else {

				rttr.addFlashAttribute("msgType", "error");
				rttr.addFlashAttribute("msg", "회원가입");
				rttr.addFlashAttribute("msgDetail", "회원가입에 실패했습니다");
			}
		}
		return "redirect:/main2";
	}

	// 2. 로그인
	@PostMapping("/memberLogin")
	public String memberLogin(Member member, RedirectAttributes rttr, HttpSession session) {

		System.out.println(member);
		Member user = memberMapper.memberLogin(member);
		System.out.println(user);

		if (user == null) {

			rttr.addFlashAttribute("msgType", "error");
			rttr.addFlashAttribute("msg", "로그인");
			rttr.addFlashAttribute("msgDetail", "아이디와 비밀번호를 확인해주세요");
			session.setAttribute("openLoginModal", true);

			return "redirect:/main2"; // main으로 이동

		} else {

			// 로그인 성공
			rttr.addFlashAttribute("msgType", "success");
			rttr.addFlashAttribute("msg", "로그인");
			rttr.addFlashAttribute("msgDetail", user.getMemNick() + "님, 환영합니다!");
			// 로그인 정보 세션 저장
			session.setAttribute("user", user);
			System.out.println("세션에 저장된 사용자: " + session.getAttribute("user"));

			return "redirect:/main2";
		}

	}

	// 3. 아이디 중복 확인
	@GetMapping("/registerCheck")
	public @ResponseBody int registerCheck(@RequestParam("memId") String memId) {

		Member member = memberMapper.registerCheck(memId);
		if (member != null || memId.equals("")) {
			return 0;
		} else {
			return 1;
		}
	}

	// 4. 로그아웃
	@GetMapping("/logout")
	public String logout(HttpSession session, RedirectAttributes rttr) {

		session.invalidate();
		
		rttr.addFlashAttribute("msgType", "success");
		rttr.addFlashAttribute("msg", "로그아웃");
		rttr.addFlashAttribute("msgDetail", "잘가요...  😭 😭 😭 😭");
		
		return "redirect:/main2";

	}

	// 5. 회원 정보 수정
	@PostMapping("/memberUpdate")
	public String memberUpdate(Member member, RedirectAttributes rttr, HttpSession session) {

		int cnt = memberMapper.memberUpdate(member);

		if (cnt > 0) {

			rttr.addFlashAttribute("msgType", "success");
			rttr.addFlashAttribute("msg", "회원 정보 수정");
			rttr.addFlashAttribute("msgDetail", "회원 정보 수정을 성공했습니다");
			// 세션 생성 시 타임아웃 설정(1시간)
			session.setMaxInactiveInterval(3600);
			session.setAttribute("user", member);

		} else {

			rttr.addFlashAttribute("msgType", "error");
			rttr.addFlashAttribute("msg", "회원 정보 수정");
			rttr.addFlashAttribute("msgDetail", "회원 정보 수정을 실패했습니다. 다시 시도해주세요");
		}

		return "redirect:/main2";
	}

	@Autowired
	private ShipMapper shipMapper; // ShipMapper 주입

	// 6. 관리자 페이지 접근
	@GetMapping("/managerPage")
	public String managerPage(HttpSession session, Model model, RedirectAttributes rttr) {
		Member user = (Member) session.getAttribute("user");

		if (user != null && "admin".equals(user.getMemId())) {
			// 세션에서 관리자 확인 후 선박 목록을 가져옴
			List<Ship> shipList = shipMapper.shipList(user.getMemId());

			// 모델에 shipList를 추가하여 JSP로 전달
			model.addAttribute("shipList", shipList);
			return "Manager"; // Manager.jsp로 이동
		} else {
			rttr.addFlashAttribute("msgType", "error");
			rttr.addFlashAttribute("msg", "관리자 접근");
			rttr.addFlashAttribute("msgDetail", "관리자만 접근할 수 있습니다.");
			return "redirect:/main2";
		}
	}
}
