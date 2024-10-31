package com.doran.Mcontroller;

import javax.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.doran.entity.Member;
import com.doran.mapper.MemberMapper;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

@Controller
public class OAuthLoginController {

    @Autowired
    private MemberMapper memberMapper;

    @Value("${GOOGLE_CLIENT_ID}")
    private String googleClientId;

    @Value("${GOOGLE_CLIENT_SECRET}")
    private String googleClientSecret;

    @Value("${GOOGLE_REDIRECT_URI}")
    private String googleRedirectUri;

    @Value("${KAKAO_CLIENT_ID}")
    private String kakaoClientId;

    @Value("${KAKAO_REDIRECT_URI}")
    private String kakaoRedirectUri;

    @Value("${NAVER_CLIENT_ID}")
    private String naverClientId;

    @Value("${NAVER_CLIENT_SECRET}")
    private String naverClientSecret;

    @Value("${NAVER_REDIRECT_URI}")
    private String naverRedirectUri;

    // Google, Kakao, Naver의 로그인 콜백 처리
    @GetMapping("/main2/oauthcallback")
    public String oauthCallback(@RequestParam("code") String code, 
                                @RequestParam("state") String platform,
                                RedirectAttributes rttr, HttpSession session) {
        System.out.println("OAuth Callback triggered for platform: " + platform);

        try {
            String tokenUrl = "";
            String redirectUri = "";
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(org.springframework.http.MediaType.APPLICATION_FORM_URLENCODED);
            String body = "";

            // 플랫폼에 따른 토큰 요청 URL 및 파라미터 설정
            switch (platform.toLowerCase()) {
                case "google":
                    tokenUrl = "https://oauth2.googleapis.com/token";
                    redirectUri = googleRedirectUri;
                    body = "grant_type=authorization_code&client_id=" + googleClientId + 
                           "&client_secret=" + googleClientSecret + 
                           "&redirect_uri=" + redirectUri + "&code=" + code;
                    break;
                case "kakao":
                    tokenUrl = "https://kauth.kakao.com/oauth/token";
                    redirectUri = kakaoRedirectUri;
                    body = "grant_type=authorization_code&client_id=" + kakaoClientId + 
                           "&redirect_uri=" + redirectUri + "&code=" + code;
                    break;
                case "naver":
                    tokenUrl = "https://nid.naver.com/oauth2.0/token";
                    redirectUri = naverRedirectUri;
                    body = "grant_type=authorization_code&client_id=" + naverClientId + 
                           "&client_secret=" + naverClientSecret + 
                           "&redirect_uri=" + redirectUri + "&code=" + code;
                    break;
                default:
                    throw new IllegalArgumentException("Invalid platform: " + platform);
            }

            HttpEntity<String> request = new HttpEntity<>(body, headers);
            RestTemplate restTemplate = new RestTemplate();
            ResponseEntity<String> response = restTemplate.postForEntity(tokenUrl, request, String.class);

            // 응답에서 access_token 파싱
            String accessToken = parseAccessToken(response.getBody());

            // access_token으로 사용자 정보 가져오기
            Member member = fetchUserInfo(accessToken, platform);

            // DB에 사용자 정보 확인 및 저장
            Member existingMember = memberMapper.googleMemberCheck(member.getMemEmail());

            if (existingMember == null) {
                memberMapper.googleMemberJoin(member);
                rttr.addFlashAttribute("msgType", "success");
                rttr.addFlashAttribute("msg", "로그인 및 회원가입");
                rttr.addFlashAttribute("msgDetail", platform + " 로그인 및 회원가입이 완료되었습니다.");
            } else {
            	rttr.addFlashAttribute("msgType", "success");
                rttr.addFlashAttribute("msg", "로그인");
                rttr.addFlashAttribute("msgDetail", platform + " 로그인 성공!");
            }

            // 세션에 MEMBER 객체 저장
            session.setAttribute("user", member);

            return "redirect:/main2";

        } catch (Exception e) {
            e.printStackTrace();
            rttr.addFlashAttribute("msgType", "error");
            rttr.addFlashAttribute("msg", "로그인");
            rttr.addFlashAttribute("msgDetail", platform + " 로그인 처리 중 오류가 발생했습니다.");
            return "redirect:/error";
        }
    }

    private String parseAccessToken(String body) {
        try {
            ObjectMapper mapper = new ObjectMapper();
            JsonNode node = mapper.readTree(body);
            return node.get("access_token").asText();
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    private Member fetchUserInfo(String accessToken, String platform) throws Exception {
        String userInfoUrl = "";
        HttpHeaders headers = new HttpHeaders();
        headers.add("Authorization", "Bearer " + accessToken);
        RestTemplate restTemplate = new RestTemplate();
        HttpEntity<String> entity = new HttpEntity<>(headers);

        switch (platform.toLowerCase()) {
            case "google":
                userInfoUrl = "https://www.googleapis.com/oauth2/v2/userinfo";
                break;
            case "kakao":
                userInfoUrl = "https://kapi.kakao.com/v2/user/me";
                break;
            case "naver":
                userInfoUrl = "https://openapi.naver.com/v1/nid/me";
                break;
        }

        ResponseEntity<String> userInfoResponse = restTemplate.exchange(userInfoUrl, HttpMethod.GET, entity, String.class);
        ObjectMapper mapper = new ObjectMapper();
        JsonNode userInfoNode = mapper.readTree(userInfoResponse.getBody());

        Member member = new Member();
        
        System.out.println(userInfoNode);

        // 플랫폼별 사용자 정보 매핑
        switch (platform.toLowerCase()) {
            case "google":
                member.setMemId(userInfoNode.get("id").asText());
                member.setMemNick("GoogleUser");  // Google 사용자 닉네임 설정
                member.setMemEmail(userInfoNode.get("email").asText());
                member.setMemPw(userInfoNode.get("id").asText());
                member.setMemPhone("01012341234");
                break;
            case "kakao":
                member.setMemId(userInfoNode.get("id").asText());
                member.setMemNick(userInfoNode.path("properties").path("nickname").asText("KakaoUser"));
                member.setMemEmail(userInfoNode.path("kakao_account").path("email").asText("unknown"));
                member.setMemPw(userInfoNode.get("id").asText());
                member.setMemPhone("01012341234");
                break;
            case "naver":
                JsonNode responseNode = userInfoNode.path("response");
                member.setMemId(responseNode.get("id").asText());
                member.setMemNick(responseNode.path("nickname").asText("NaverUser"));
                member.setMemEmail(responseNode.path("email").asText("unknown"));
                member.setMemPw(responseNode.get("id").asText());
                member.setMemPhone("01012341234");
                break;
        }

        return member;
    }
}
