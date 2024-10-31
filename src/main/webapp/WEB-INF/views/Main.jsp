<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<%@ include file="Modal.jsp"%>
<%@ include file="Header.jsp" %>
<!DOCTYPE html>
<html>
<head>
<title>선박 메인 화면</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Roboto+Slab&display=swap" rel="stylesheet">

<style>
/* 기본 스타일 설정 */
body, html {
    margin: 0;
    padding: 0;
    height: 100%;
    overflow-x: hidden;
    font-family: 'Roboto Slab', serif;
}

.wrapper, .content {
    position: relative;
    width: 100%;
    z-index: 1;
}

.content {
    overflow-x: hidden;
}

.content .section {
    width: 100%;
    height: 100vh;
}

/* 배경 이미지 */
.content .section.hero {
    position: relative;
    width: 100vw;
    height: 200vh;
    background-image: linear-gradient(to bottom, rgba(4, 27, 35, 0) 0%, rgba(4, 27, 35, 0.5) 50%, rgba(4, 27, 35, 1) 100%), 
        url('<%=request.getContextPath()%>/resources/img/선박.jpg');
    background-size: cover;
    background-position: center; 
    background-repeat: no-repeat;
    z-index: 1; /* 배경은 낮은 z-index */
}





.image-container {
    width: 100%;
    height: 100vh;
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    z-index: 2;
    perspective: 500px;
    overflow: hidden;
}


.image-container img {
    width: 100%;
    height: 100%;
    object-fit: cover;
    object-position: center center;
    transition: transform 0.3s ease;
}

.header {
    position: fixed;
    top: 0;
    right: 0;
    width: 100%;
    height: 50px;
    display: flex;
    justify-content: flex-end;
    align-items: center;
    z-index: 1000;
    background-color: rgba(0, 0, 0, 0); /* 헤더를 투명하게 설정 */
}

.header a {
    color: white;
    margin-left: 20px;
    text-decoration: none;
    font-size: 18px;
    padding: 0 10px;
    position: relative;
    padding-top: 10px;
}

.header a:not(:first-child)::before {
    content: '';
    position: absolute;
    left: -10px;
    top: 10px;
    bottom: 0;
    width: 1px;
    background-color: white;
}

.header a:first-child {
    border-left: none;
}

.header a:hover {
    text-decoration: underline;
}

/* 햄버거 메뉴 리스트 스타일 */
.menu {
    display: none;
    position: absolute;
    top: 50px;
    right: 10px; /* right 값을 조정하여 위치 설정 */
    background-color: rgba(255, 255, 255, 0.9); /* 메뉴 배경에 약간의 투명도 */
    box-shadow: 0px 8px 16px rgba(0, 0, 0, 0.2);
    border-radius: 5px;
    width: 200px; /* 메뉴의 너비를 충분히 설정 */
    z-index: 1001; /* 헤더보다 앞에 나오도록 설정 */
    overflow: visible; /* 메뉴가 화면 밖으로 나가는 것을 방지 */
}

.menu a {
    color: black;
    padding: 12px 16px;
    text-decoration: none;
    display: block;
    font-size: 14px;
}

.menu a:hover {
    background-color: #ddd;
}
.main-content {
    position: absolute;
    top: -30vh;
    width: 100vw;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    z-index: 3;
    padding-top: 200vh;
    padding-bottom: 100vh;
    /* 배경을 항상 설정하고, 투명도를 변경하여 전환 */
    background: linear-gradient(
        to bottom,
        rgba(4, 27, 35, 1) 0%, rgba(4, 27, 35, 0.98) 15%, rgba(4, 27, 35, 0.95) 30%, 
        rgba(4, 27, 35, 0.9) 50%, rgba(4, 27, 35, 0.85) 70%, rgba(4, 27, 35, 0.8) 100%
    );
    opacity: 0; /* 초기 투명도 설정 */
    transition: opacity 0.5s ease; /* 부드러운 전환 */
}






/* 사진 애니메이션 스타일 */
.photo-grid {

    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 0px; /* 모든 사진 간격을 최소화 */
    justify-items: center;
    justify-content: center; /* 그리드 내부 요소들을 중앙에 밀착 */
    width: 1400px;
    grid-row-gap: 90px; 
    opacity: 0;
    transform: translateY(50px);
    transition: opacity 0.5s ease, transform 0.5s ease;
    margin-top: -150px; /* 음수 값으로 설정하여 사진들을 위로 올림 */
}

.photo-item { 
    width: 360px;
    height: 350px;
    background-color: #ccc;
    position: relative;
    cursor: pointer;
    border-radius: 10px;
}

.photo-item img {
    width: 100%;
    height: 100%;
    object-fit: cover;
    border-radius: 10px;
    transition: transform 0.3s ease, filter 0.3s ease;
}

.photo-item img:hover {
    transform: scale(1.05);
    filter: brightness(1.1);
}

.photo-title {
    margin-top: 8px;
    color: white;
    text-align: center;
    font-size: 18px;
    font-weight: bold;
}

.photo-description {
    display: none;
    color: white;
    text-align: center;
    margin-top: 5px;
    font-size: 14px;
}

.photo-description.active {
    display: block;
}

</style>

</head>
<body>

<div class="wrapper">
    <!-- 이미지 컨테이너 -->
    <div class="image-container">
        <img src="<%= request.getContextPath() %>/resources/img/main.png" alt="main image">

    </div>
    
    <!-- 내용 컨테이너 -->
    <div class="content">
        <section class="section hero"></section>
        <section class="section gradient-purple"></section>
        <section class="section gradient-blue"></section>
    </div>
</div>



<!-- 사진 그리드 섹션 -->
<div class="background-image"></div>
<div class="scroll-section"></div>
<div class="main-content">
    <h1>자율 운항 선박 시스템</h1>
  <div class="photo-grid">
    <div class="photo-item" onclick="showDescription('description1')">
        <img src="<%=request.getContextPath()%>/resources/img/실시간카메라.png" alt="실시간 카메라">
        <div class="photo-title">실시간 카메라</div>
        <div id="description1" class="photo-description">실시간 카메라 화면입니다.</div>
    </div>
    <div class="photo-item" onclick="showDescription('description2')">
        <img src="<%=request.getContextPath()%>/resources/img/라이다.png" alt="라이다">
        <div class="photo-title">라이다</div>
        <div id="description2" class="photo-description">현재 경로를 실시간으로 보여줍니다.</div>
    </div>
    <div class="photo-item" onclick="showDescription('description3')">
        <img src="<%=request.getContextPath()%>/resources/img/실시간경로.png" alt="관제화면">
        <div class="photo-title">실시간 경로</div>
        <div id="description3" class="photo-description">현재 경로를 실시간으로 확인할 수 있습니다.</div>
    </div>
    <div class="photo-item" onclick="showDescription('description4')">
        <img src="<%=request.getContextPath()%>/resources/img/통계페이지.png" alt="통계 페이지">
        <div class="photo-title">통계 페이지</div>
        <div id="description4" class="photo-description">선박 운행에 대한 통계를 제공합니다.</div>
    </div>
    <div class="photo-item" onclick="showDescription('description5')">
        <img src="<%=request.getContextPath()%>/resources/img/관제화면.png" alt="관제 화면">
        <div class="photo-title">관제 화면</div>
        <div id="description5" class="photo-description">무인선박을 실시간으로 관제 할 수 있습니다.</div>
    </div>
    <div class="photo-item" onclick="showDescription('description6')">
        <img src="<%=request.getContextPath()%>/resources/img/보안.png" alt="보안 시스템">
        <div class="photo-title">보안 시스템</div>
        <div id="description6" class="photo-description">보안 정보를 실시간으로 모니터링합니다.</div>
    </div>
</div>


<script src="https://cdnjs.cloudflare.com/ajax/libs/gsap/3.9.1/gsap.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/gsap/3.9.1/ScrollTrigger.min.js"></script>

<script>
// GSAP 애니메이션 설정
gsap.registerPlugin(ScrollTrigger);

window.addEventListener("load", () => {
    gsap.timeline({
        scrollTrigger: {
            trigger: ".wrapper",
            start: "top top",
            end: "+=150%",
            pin: true,
            scrub: true
        }
    })
    .to(".image-container img", {
        scale: 2,
        z: 350,
        transformOrigin: "center center",
        ease: "power1.inOut"
    })
    .to(
        ".section.hero",
        {
            scale: 1.1,
            transformOrigin: "center center",
            ease: "power1.inOut"
        },
        "<"
    );

    // 사진 그리드가 나타나는 애니메이션
    gsap.to(".photo-grid", {
        scrollTrigger: {
            trigger: ".photo-grid",
            start: "top 80%",
            toggleActions: "play none none reset"
        },
        opacity: 1,
        transform: "translateY(0)"
    });
});

//JavaScript로 스크롤 위치에 따라 opacity 조정
window.addEventListener('scroll', function () {
    const mainContent = document.querySelector('.main-content');
    const scrollPosition = window.scrollY;

    // 스크롤 위치에 따라 opacity 값을 점진적으로 증가
    if (scrollPosition > 100) {
        const opacityValue = Math.min((scrollPosition - 100) / 300, 1);
        mainContent.style.opacity = opacityValue;
    } else {
        mainContent.style.opacity = 0; // 스크롤이 100px 이하일 때는 완전 투명
    }
});
function smoothScrollTo(position, duration) {
    const start = window.pageYOffset;
    const distance = position - start;
    let startTime = null;

   

    function animation(currentTime) {
        if (startTime === null) startTime = currentTime;
        const timeElapsed = currentTime - startTime;
        const run = easeInOutQuad(timeElapsed, start, distance, duration);
        window.scrollTo(0, run);
        if (timeElapsed < duration) requestAnimationFrame(animation);
    }

    function easeInOutQuad(t, b, c, d) {
        t /= d / 2;
        if (t < 1) return c / 2 * t * t + b;
        t--;
        return -c / 2 * (t * (t - 2) - 1) + b;
    }

    requestAnimationFrame(animation);
}

// 모달 열기 함수에도 `console.log` 추가
document.getElementById("openJoinModal").addEventListener("click", function(e) {
    e.preventDefault();
    document.getElementById("joinModal").style.display = "block"; 
    document.getElementById("loginModal").style.display = "none"; 
    document.getElementById("openJoinModal").style.display = "none"; 
    document.getElementById("openLoginModal").style.display = "block"; 
    
    // 스크롤 위치 확인
    smoothScrollTo(600, 500);
});

// Login 모달 열기
document.getElementById("openLoginModal").addEventListener("click", function(e) {
    e.preventDefault();
    document.getElementById("loginModal").style.display = "block"; // Login 모달 열기
    document.getElementById("joinModal").style.display = "none"; // Join 모달 닫기
    document.getElementById("openLoginModal").style.display = "none"; // Login 버튼 숨기기
    document.getElementById("openJoinModal").style.display = "block"; // Join 버튼 보이기
    
    // 스크롤 위치를 부드럽게 600으로 이동 (0.5초 동안)
    smoothScrollTo(600, 500);
});

// Join 모달 닫기
document.getElementById("closeJoinModal").addEventListener("click", function() {
    document.getElementById("joinModal").style.display = "none"; // Join 모달 닫기
    document.getElementById("openJoinModal").style.display = "block"; // Join 버튼 복원
    document.getElementById("openLoginModal").style.display = "block"; // Login 버튼 복원
    
    // 스크롤 위치를 부드럽게 600으로 이동 (0.5초 동안)
    smoothScrollTo(600, 500);
});

// Login 모달 닫기
document.getElementById("closeLoginModal").addEventListener("click", function() {
    document.getElementById("loginModal").style.display = "none"; // Login 모달 닫기
    document.getElementById("openJoinModal").style.display = "block"; // Join 버튼 복원
    document.getElementById("openLoginModal").style.display = "block"; // Login 버튼 복원
    
    // 스크롤 위치를 부드럽게 600으로 이동 (0.5초 동안)
    smoothScrollTo(600, 500);
});

// 햄버거 메뉴 클릭 시 메뉴 리스트 토글
document.getElementById("hamburgerMenu")?.addEventListener("click", function(e) {
    e.preventDefault();
    console.log("햄버거 메뉴 클릭");
    var menu = document.getElementById("menu");
    menu.style.display = (menu.style.display === "block") ? "none" : "block";
});

// Login 모달 닫기
document.getElementById("closeLoginModal").addEventListener("click", function() {
    document.getElementById("loginModal").style.display = "none"; // Login 모달 닫기
    document.getElementById("openJoinModal").style.display = "block"; // Join 버튼 복원
    document.getElementById("openLoginModal").style.display = "block"; // Login 버튼 복원
});
    
function showDescription(descriptionId) {
    // 모든 설명을 숨기기
    document.querySelectorAll('.photo-description').forEach(function(description) {
        description.classList.remove('active');
    });

    // 선택된 설명만 활성화
    document.getElementById(descriptionId).classList.add('active');
}

</script>  

<%
Boolean openLoginModal = (Boolean) session.getAttribute("openLoginModal");
if (openLoginModal != null && openLoginModal) {
    session.removeAttribute("openLoginModal");
%>
<script>
    document.getElementById("loginModal").style.display = "block"; 
    document.getElementById("joinModal").style.display = "none"; 
    document.getElementById("openLoginModal").style.display = "none"; 
    document.getElementById("openJoinModal").style.display = "block"; 
</script>
<%
}
%>

<%
Boolean openJoinModal = (Boolean) session.getAttribute("openJoinModal");
if (openJoinModal != null && openJoinModal) {
    session.removeAttribute("openJoinModal");
%>
<script>
    document.getElementById("joinModal").style.display = "block"; 
    document.getElementById("loginModal").style.display = "none"; 
    document.getElementById("openJoinModal").style.display = "none"; 
    document.getElementById("openLoginModal").style.display = "block"; 
</script>
<%
}
%>


</body>
</html>
