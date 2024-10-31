package com.doran.Mcontroller;

import java.io.File;
import java.io.IOException;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.doran.entity.Member;
import com.doran.entity.Sail;
import com.doran.entity.Ship;
import com.doran.mapper.ShipGroupMapper;
import com.doran.mapper.ShipMapper;

// 선박 정보 등록 및 선박 정보 반환
@Controller
public class ShipController {

    @Autowired
    private ShipMapper shipMapper;
    @Autowired
    private ShipGroupMapper shipGroupMapper;

    // 1. 선박 전체 리스트 불러오기
    @RequestMapping("/shipList")
    public @ResponseBody List<Ship> shipList(HttpSession session) {
        Member login = (Member) session.getAttribute("user");
        List<Ship> shipList = shipMapper.shipList(login.getMemId());
        System.out.println("ShipController : " + shipList);
        return shipList;
    }

    // 승인 대기 중인 모든 선박 리스트 가져오기
    @GetMapping("/AllShipList")
    public @ResponseBody List<Ship> AllShipList() {
        List<Ship> shipList = shipMapper.getAllShips();
        System.out.println("ShipController : " + shipList);
        return shipList;
    }

    // 2. 선박 등록 신청
    @PostMapping("/shipRegister")
    public String application(Ship ship, RedirectAttributes rttr, HttpSession session) throws IllegalStateException, IOException {
        Member user = (Member)session.getAttribute("user");
        ship.setMemId(user.getMemId());
        ship.setSiCert('0');
        ship.setSailStatus('0');

        // 파일 저장
        if (!ship.getSiDocsFile().isEmpty()) {
            String fileName = ship.getSiDocsFile().getOriginalFilename();
            File destinationFile = new File("src/main/resources/siDocsFile/" + fileName);
            ship.getSiDocsFile().transferTo(destinationFile);
            ship.setSiDocs("src/main/resources/siDocsFile/" + fileName);
        }

        int cnt = shipMapper.application(ship);
        shipGroupMapper.shipRegister(ship);

        if (cnt > 0) {
            rttr.addFlashAttribute("msgType", "성공");
            rttr.addFlashAttribute("msg", "선박 등록을 신청했습니다. 관리자 승인을 기다려주세요");
        } else {
            rttr.addFlashAttribute("msgType", "실패");
            rttr.addFlashAttribute("msg", "선박 등록을 실패했습니다. 다시 시도해주세요");
            session.setAttribute("openShipRegisterModal", true);
        }
        return "redirect:/main";
    }

    // 3. 선박 재신청
    @PostMapping("/shipReapply")
    public String updateShipApplication(Ship ship, RedirectAttributes rttr, HttpSession session) throws IllegalStateException, IOException {
        Member user = (Member) session.getAttribute("user");
        ship.setMemId(user.getMemId());
        ship.setSiCert('0');
        ship.setSailStatus('0');
        System.out.println("재신청 선박 정보: " + ship);

        // 파일이 업로드되었는지 확인
        if (!ship.getSiDocsFile().isEmpty()) {
            String fileName = ship.getSiDocsFile().getOriginalFilename();
            File destinationFile = new File("src/main/resources/siDocsFile/" + fileName);
            ship.getSiDocsFile().transferTo(destinationFile);
            ship.setSiDocs("src/main/resources/siDocsFile/" + fileName);
        }

        int cnt = shipMapper.updateApplication(ship);
        if (cnt > 0) {
            rttr.addFlashAttribute("msgType", "성공");
            rttr.addFlashAttribute("msg", "선박 재신청이 완료되었습니다. 관리자 승인을 기다려주세요.");
        } else {
            rttr.addFlashAttribute("msgType", "실패");
            rttr.addFlashAttribute("msg", "선박 재신청에 실패했습니다. 다시 시도해주세요.");
            session.setAttribute("openShipRegisterModal", true);
        }
        return "redirect:/main";
    }

    // 4. 선박 등록 승인
    @PutMapping("/update")
    public ResponseEntity<String> approveShip(@RequestParam String siCode, @RequestParam String memId) {
        Ship ship = new Ship();
        ship.setSiCode(siCode);
        ship.setMemId(memId);
        ship.setSiCert('1');
        shipMapper.approveShip(ship);
        System.out.println("승인 처리된 siCode: " + siCode + ", memId: " + memId);
        return ResponseEntity.ok("승인되었습니다.");
    }

    // 선박 거절
    @PutMapping("/reject")
    public ResponseEntity<?> rejectShip(@RequestBody Map<String, Object> requestData) {
        String siCode = (String) requestData.get("siCode");
        String memId = (String) requestData.get("memId");
        String siCert = (String) requestData.get("siCert");
        String siCertReason = (String) requestData.get("siCertReason");

        shipMapper.rejectShip(siCode, memId, siCert, siCertReason);
        System.out.println("거절된 이유: " + siCertReason);
        return ResponseEntity.ok().build();
    }

    // 5. 선박 세션 저장
    @PostMapping("/setShipSession")
    public @ResponseBody void sailStatus(@RequestBody Ship ship, HttpSession session) {
        Member user = (Member)session.getAttribute("user");
        ship.setMemId(user.getMemId());
        ship = getShip(ship);
        session.setMaxInactiveInterval(3600);
        session.setAttribute("nowShip", ship);
    }

    // 6. 선박 운항 시작
    @PutMapping("/startStatus")
    public void startStatus(Sail sail, HttpSession session) {
        Member user = (Member)session.getAttribute("user");
        Ship ship = new Ship();
        ship.setMemId(user.getMemId());
        ship.setSiCode(sail.getSiCode());
        ship.setSailStatus('1');
        shipMapper.sailStatus(ship);
        session.setMaxInactiveInterval(3600);
        session.setAttribute("nowShip", ship);
        System.out.println("운항 시작된 선박: " + ship);
    }

    // 7. 선박 운항 종료
    @PutMapping("/endStatus")
    public void endStatus(Sail sail, HttpSession session) {
        Ship ship = (Ship)session.getAttribute("nowShip");
        ship.setSailStatus('0');
        shipMapper.sailStatus(ship);
        //session.removeAttribute("nowShip");
        System.out.println("운항 종료된 선박: " + ship);
    }

    // 8. 특정 선박 정보 가져오기
    public Ship getShip(Ship ship) {
        return shipMapper.getShip(ship);
    }

    // 9. 현재 세션에서 운항 상태 불러오기
    @GetMapping("/getSailStatus")
    public ResponseEntity<Map<String, Object>> getSailStatus(HttpSession session) {
        Ship nowShip = (Ship) session.getAttribute("nowShip");
        if (nowShip != null) {
            Map<String, Object> response = new HashMap<>();
            response.put("sailStatus", nowShip.getSailStatus());
            return ResponseEntity.ok(response);
        }
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Collections.singletonMap("error", "Ship not found"));
    }
}
