<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<% response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate"); %>
<% response.setHeader("Pragma", "no-cache"); %>
<% response.setDateHeader("Expires", 0); %>
<!DOCTYPE html>
<html>
<head>
    <style>
        /* CSS 변수 정의 */
        :root {
            --black: #09090c;
            --grey: #a4b2bc;
            --white: #fff;
            --background: rgba(137, 171, 245, 0.37);
        }

        /* 기본 스타일 초기화 */
        *,
        *::before,
        *::after {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            background-color: var(--background);
            font-family: 'Poppins', sans-serif;
            /* 스크롤바 스타일 */
            scrollbar-width: thin;
            scrollbar-color: var(--black) var(--background);
        }

        /* 웹킷 기반 브라우저용 스크롤바 스타일 */
        body::-webkit-scrollbar {
            width: 10px;
        }

        body::-webkit-scrollbar-track {
            background: var(--background);
        }

        body::-webkit-scrollbar-thumb {
            background-color: var(--black);
            border-radius: 5px;
            border: 2px solid var(--background);
        }

        .header {
            position: fixed;
            width: 100%;
            top: 0;
            z-index: 1000;
            display: flex;
            align-items: center;
            background-color: var(--black);
            padding: 0.5rem;
        }

        /* 햄버거 버튼 스타일 */
        .hamburger-button {
            background: transparent; /* 배경 완전히 제거 */
            border: none;
            padding: 0;
            margin: 0;
            cursor: pointer;
            position: relative;
            margin-left: auto; /* 오른쪽 정렬 */
            margin-right: 20px; /* 오른쪽에서 20px 떨어지도록 설정 */
            width: 30px; /* 아이콘 크기에 맞게 조정 */
            height: 24px; /* 아이콘 크기에 맞게 조정 */
            display: flex;
            flex-direction: column;
            justify-content: space-between; /* 막대 사이 간격 균등하게 */
        }

        /* 햄버거 아이콘의 선 */
        .hamburger-button::before,
        .hamburger-button::after,
        .hamburger-button div {
            content: "";
            background-color: var(--white);
            height: 2px;
            width: 100%;
            display: block;
            transition: all 0.3s ease;
        }

        /* 중간 막대 추가 */
        .hamburger-button div {
            background-color: var(--white);
        }

        /* 버튼이 클릭되었을 때 X자로 변환 */
        .hamburger-button.clicked::before {
            transform: translateY(11px) rotate(45deg); /* 위치 및 회전 조정 */
        }

        .hamburger-button.clicked::after {
            transform: translateY(-11px) rotate(-45deg); /* 위치 및 회전 조정 */
        }

        .hamburger-button.clicked div {
            opacity: 0; /* 중간 막대 숨기기 */
        }

        /* 사이드바 스타일 */
        .sidebar {
            background-color: rgba(39, 53, 63, 0.95); /* 배경색 진하게 변경 */
            width: 3.5rem;
            position: fixed;
            /* top을 조정하여 사이드바를 위로 올리고, 햄버거 아이콘 아래에 여백을 둠 */
            top: 80px; /* 원하는 만큼 값 조정 */
            right: 15px; /* 오른쪽에서 18px 떨어지도록 설정하여 스크롤바와 간격 확보 */
            /* transform: translateY(-50%); */ /* 세로 중앙 정렬 제거 */
            overflow: hidden;
            transition: width 0.5s ease;
            z-index: 999;
            border-radius: 10px 0 0 10px; /* 왼쪽 모서리를 둥글게 */
        }

        .sidebar.expanded {
            width: 12rem;
        }

        /* 메뉴 아이템 컨테이너 */
        .menu-items {
            list-style: none;
            padding: 1rem 0;
        }

        .menu-items li {
            display: flex;
            align-items: center;
            padding: 1rem;
            color: var(--white);
            cursor: pointer;
            position: relative; /* border-left를 위해 상대 위치 지정 */
        }

        /* 메뉴 아이템 호버 시 왼쪽 끝부분만 흰색으로 변경 */
        .menu-items li:hover {
            border-left: 4px solid var(--white);
        }

        .menu-items li img {
            width: 1.2rem;
            height: auto;
            filter: invert(92%) sepia(4%) saturate(1033%) hue-rotate(169deg)
                brightness(78%) contrast(85%);
        }

        .menu-items li span {
            margin-left: 1.5rem;
            overflow: hidden;
            white-space: nowrap;
            transition: all 0.3s ease;
            opacity: 0;
            width: 0;
        }

        .sidebar.expanded .menu-items li span {
            opacity: 1;
            width: auto;
        }

        /* 로그인 및 회원가입 링크 스타일 */
        .login-join {
            margin-left: auto;
            display: flex;
        }

        .login-join a {
            color: var(--white);
            text-decoration: none;
            font-size: 20px;
            font-weight: bold;
            margin-right: 1rem;
        }
    </style>
</head>
<body>

<%
    Object user = session.getAttribute("user");
    System.out.println("세션 유저: " + user);
%>

<div class="header">
    <%
    if (user != null) {
    %>
        <!-- 로그인된 상태: 햄버거 메뉴 표시 -->
        <button id="hamburgerMenu" class="hamburger-button">
            <!-- 중간 막대 추가 -->
            <div></div>
        </button>
    <%
    } else {
    %>
        <!-- 비로그인 상태: Join 및 Login 버튼 표시 -->
        <div class="login-join">
            <a href="#" id="openJoinModal">Join</a>
            <a href="#" id="openLoginModal">Login</a>
        </div>
    <%
    }
    %>
</div>

<%
if (user != null) {
%>
<!-- 사이드바 시작 -->
<div class="sidebar" id="sidebar">
    <ul class="menu-items">
        <li id="openShipRegisterModal">
            <img src="<%=request.getContextPath()%>/resources/img/ship.png" alt="선박 등록" class="menu-icon">
            <span>선박 등록</span>
        </li>
        <li id="openShipListModal">
            <img src="<%=request.getContextPath()%>/resources/img/list.png" alt="선박 리스트" class="menu-icon">
            <span>선박 리스트</span>
        </li>
        <li id="openEditModal">
            <img src="<%=request.getContextPath()%>/resources/img/user.png" alt="회원정보 수정" class="menu-icon">
            <span>회원정보 수정</span>
        </li>
        <li onclick="location.href='<%=request.getContextPath()%>/logout'">
            <img src="<%=request.getContextPath()%>/resources/img/logout.png" alt="로그아웃" class="menu-icon">
            <span>로그아웃</span>
        </li>
        <!-- 관리자 전용 메뉴 -->
        <c:if test="${user.memId eq 'admin'}">
            <li onclick="location.href='<%=request.getContextPath()%>/manager'">
                <img src="<%=request.getContextPath()%>/resources/img/admin.png" alt="관리자 전용" class="menu-icon">
                <span>관리자 전용</span>
            </li>
        </c:if>
    </ul>
</div>
<!-- 사이드바 끝 -->
<%
}
%>

<script>
    // 사이드바 토글 기능
    document.getElementById("hamburgerMenu")?.addEventListener("click", function(e) {
        e.preventDefault();
        var sidebar = document.getElementById("sidebar");
        var hamburgerButton = document.getElementById("hamburgerMenu");
        sidebar.classList.toggle("expanded"); // 사이드바 확장/축소 토글
        hamburgerButton.classList.toggle("clicked"); // 햄버거 버튼 애니메이션 토글
    });

    // 사이드바 외부 클릭 시 사이드바 닫기
    document.addEventListener('click', function(event) {
        var isClickInside = document.getElementById('sidebar').contains(event.target) || document.getElementById('hamburgerMenu').contains(event.target);
        if (!isClickInside) {
            document.getElementById('sidebar').classList.remove('expanded');
            document.getElementById('hamburgerMenu').classList.remove('clicked');
        }
    });

    // 메뉴 아이템 클릭 이벤트
    document.getElementById("openShipRegisterModal")?.addEventListener("click", function(e) {
        e.preventDefault();
        closeAllModals(); // 모든 모달 닫기
        document.getElementById("shipRegisterModal").style.display = "block"; // 선박 등록 모달 열기
    });

    document.getElementById("openShipListModal")?.addEventListener("click", function(e) {
        e.preventDefault();
        closeAllModals(); // 모든 모달 닫기
        document.getElementById("listModal").style.display = "block"; // 선박 리스트 모달 열기
        loadShipList(); // 선박 리스트 로드 함수 호출
    });

    document.getElementById("openEditModal")?.addEventListener("click", function(e) {
        e.preventDefault();
        closeAllModals(); // 모든 모달 닫기
        document.getElementById("editModal").style.display = "block"; // 회원정보 수정 모달 열기
    });

    // 모든 모달 닫기 함수
    function closeAllModals() {
        document.getElementById("shipRegisterModal").style.display = "none";
        document.getElementById("editModal").style.display = "none";
        document.getElementById("listModal").style.display = "none";
        document.getElementById("groupInfoModal").style.display = "none";
        // 추가적인 모달이 있다면 여기에 추가
    }

    // 모달 닫기 버튼 이벤트
    document.getElementById("closeShipRegisterModal")?.addEventListener("click", function() {
        closeAllModals();
    });

    document.getElementById("closeEditModal")?.addEventListener("click", function() {
        closeAllModals();
    });

    // 그룹 정보 모달 닫기 시 선박 리스트 모달 다시 열기
    document.getElementById("closeGroupInfoModal")?.addEventListener("click", function() {
        closeAllModals();
        document.getElementById("listModal").style.display = "block";
    });
</script>

<%
    Boolean openShipRegisterModal = (Boolean) session.getAttribute("openShipRegisterModal");
    if (openShipRegisterModal != null && openShipRegisterModal) {
        // 선박 등록 모달을 열라는 신호가 있으면
        session.removeAttribute("openShipRegisterModal");
%>
        <script>
            closeAllModals();
            document.getElementById("shipRegisterModal").style.display = "block";
        </script>
<%
    }
%>

</body>
</html>
