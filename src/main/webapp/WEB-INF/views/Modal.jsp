<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<%@ page pageEncoding="UTF-8"%>
<!-- Google Fonts 로드 -->
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Arial&display=swap"
	rel="stylesheet">
<script
	src="https://ajax.googleapis.com/ajax/libs/jquery/3.7.1/jquery.min.js"></script>
<script
	src="https://maxcdn.bootstrapcdn.com/bootstrap/3.4.1/js/bootstrap.min.js"></script>

<!-- SweetAlert2 CSS -->
<link rel="stylesheet"
	href="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.min.css">

<!-- SweetAlert2 JS -->
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

<!-- 스타일 및 스크립트 파일 로드 -->
<link rel="stylesheet"
	href="<%=request.getContextPath()%>/resources/css/modal2.css">
<script src="<%=request.getContextPath()%>/resources/js/modal2.js"></script>

<script type="text/javascript">
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

    $(document).ready(function() {
        // Ship registration 모달 열기
        $('#openShipRegisterModal').on('click', function() {
            $('#shipRegisterModal').show(); // 모달 열기
            smoothScrollTo(600, 500); // 스크롤 이동
        });

        // 선박 리스트 모달 열기
        $('#openListModal').on('click', function() {
            $('#listModal').show(); // 모달 열기
            smoothScrollTo(600, 500); // 스크롤 이동
        });

        // Edit 모달 열기
        $('#openEditModal').on('click', function() {
            $('#editModal').show(); // 모달 열기
            smoothScrollTo(600, 500); // 스크롤 이동
        });
    });
</script>


<script type="text/javascript">
	
	// 알림창 값 가져오고 띄우는 함수
	$(document).ready(function() {
		const msgType = "${msgType}";
		const msg = "${msg}";
		const msgDetail = "${msgDetail}";

		if (msgType && msg) {
			Swal.fire({
				icon : msgType === 'success' ? 'success' : 'error',
				title : msg + (msgType === 'success' ? ' 성공' : ' 실패'),
				text : msgDetail,
				confirmButtonText : '확인'
			});
		}
	});

	// 현재 비밀번호를 세션에서 가져온 값으로 설정
	const currentPassword = "${sessionScope.user.memPw}"; // 세션의 현재 비밀번호

	// 비밀번호 검사
	function validateForm() {
		var pwCheckValue = $("#pwCheck").val();

		// 현재 비밀번호 확인
		if (pwCheckValue !== currentPassword) {
			alert("기존 비밀번호를 올바르게 작성해주세요.");
			return false; // 폼 제출 방지
		}

		return true; // 폼 제출 허용
	}
	
    var contextPath = '<%=request.getContextPath()%>';
	

	// 그룹 정보 모달 열기 함수
	function openGroupInfo(siCode) {
		document.getElementById("listModal").style.display = "none"; // 선박 리스트 모달 닫기
		document.getElementById("groupInfoModal").style.display = "block"; // 그룹 정보 모달 열기
		loadGroupInfo(siCode); // 그룹 리스트 로드 함수 호출
	}

	$(document).ready(function() {
		// 항해 리스트 모달 닫기 기능
		document.getElementById('closeSailListModal').onclick = function() {
			document.getElementById('sailListModal').style.display = 'none'; // 항해 리스트 모달 닫기
			document.getElementById('listModal').style.display = 'block'; // 선박 리스트 모달 다시 표시
		};

		// 선박 리스트 모달 닫기 기능
		document.getElementById('closeShipListModal').onclick = function() {
			document.getElementById('listModal').style.display = 'none'; // 선박 리스트 모달 닫기
		};
	});
</script>
</head>

<body>
	<!-- Join 모달 -->
	<div id="joinModal" class="modal">
		<!-- 모달 헤더 -->
		<div class="modal-header" id="joinModalHeader">
			<span class="close" id="closeJoinModal">&times;</span>
			<h2>Join</h2>
		</div>
		<!-- 모달 콘텐츠 -->
		<div class="modal-content">
			<form action="memberJoin" method="post">
				<!-- 불필요한 숨겨진 필드를 제거합니다 -->
				<!-- <input type="hidden" id="memPwJoin" name="memPw" value=""> -->
				<div style="position: relative;">
					<input type="text" id="memIdJoin" name="memId" placeholder="ID"
						autocomplete="username">
					<button type="button" id="checkDuplicate" class="duplicate-btn"
						onclick="registerCheck()" style="padding: 5px;">중복체크</button>
				</div>
				<!-- 나머지 폼 필드들 -->
				<input type="password" id="memPw" name="memPw"
					placeholder="Password" autocomplete="new-password"
					onkeyup="passwordCheck();"> <input type="password"
					id="memPw2" name="memPw2" placeholder="Password Check"
					autocomplete="new-password" onkeyup="passwordCheck();"> <span
					class="passMessage"></span> <input type="text" id="memNickJoin"
					name="memNick" placeholder="Nickname"> <input type="email"
					id="memEmailJoin" name="memEmail" placeholder="Email"
					autocomplete="email"> <input type="text" id="memPhoneJoin"
					name="memPhone" placeholder="Phone Number">
				<button type="submit" class="join-button">Join</button>
			</form>
		</div>
		<!-- 리사이즈 핸들 -->
		<div class="resize-handle"></div>
	</div>


	<!-- Login 모달 -->
	<div id="loginModal" class="modal">
		<!-- 모달 헤더 -->
		<div class="modal-header" id="loginModalHeader">
			<span class="close" id="closeLoginModal">&times;</span>
			<h2>Login</h2>
		</div>
		<!-- 모달 콘텐츠 -->
		<div class="modal-content">
			<form action="memberLogin" method="post">
				<input type="text" id="memIdLogin" name="memId" placeholder="ID"
					autocomplete="username"> <input type="password"
					id="memPwLogin" name="memPw" placeholder="Password"
					autocomplete="current-password">
				<button type="submit" class="join-button">Login</button>
			</form>
			<div class="social-login">
				<!-- 소셜 로그인 버튼들 -->
				<!-- Google Login -->
				<a
					href="https://accounts.google.com/o/oauth2/v2/auth?client_id=${googleClientId}&redirect_uri=http://localhost:8085/controller/main2/oauthcallback&response_type=code&scope=email profile&state=google"
					class="social-btn google"> <img
					src="<%=request.getContextPath()%>/resources/img/google_logo.png"
					alt="Google" />
				</a>
				<!-- Kakao Login -->
				<a
					href="https://kauth.kakao.com/oauth/authorize?client_id=${kakaoClientId}&redirect_uri=http://localhost:8085/controller/main2/oauthcallback&response_type=code&state=kakao"
					class="social-btn kakao"> <img
					src="<%=request.getContextPath()%>/resources/img/kakao_logo.png"
					alt="Kakao" />
				</a>
				<!-- Naver Login -->
				<a
					href="https://nid.naver.com/oauth2.0/authorize?client_id=${naverClientId}&redirect_uri=http://localhost:8085/controller/main2/oauthcallback&response_type=code&state=naver"
					class="social-btn naver"> <img
					src="<%=request.getContextPath()%>/resources/img/naver_logo.png"
					alt="Naver" />
				</a>
			</div>
		</div>
		<!-- 리사이즈 핸들 -->
		<div class="resize-handle"></div>
	</div>

	<!-- 선박 등록 모달 -->
	<div id="shipRegisterModal" class="modal" style="display: none;">
		<!-- 모달 헤더 -->
		<div class="modal-header" id="shipRegisterModalHeader">
			<span class="close" id="closeShipRegisterModal">&times;</span>
			<h2>Ship registration</h2>
		</div>
		<!-- 모달 콘텐츠 -->
		<div class="modal-content">
			<form action="shipRegister" method="post"
				enctype="multipart/form-data">
				<!-- Ship ID는 readonly 속성을 추가 -->
				<input type="text" id="siCode" name="siCode" placeholder="Ship ID"
					pattern="[A-Za-z0-9]+" required title="영문자와 숫자만 입력 가능"
					maxlength="20">

				<!-- Ship Name 필드 -->
				<input type="text" id="siName" name="siName" placeholder="Ship Name"
					maxlength="30">

				<!-- 파일 선택 -->
				<label for="siDocsFile" class="custom-file-upload"
					style="margin-top: 10px;">파일 선택</label> <input id="siDocsFile"
					type="file" name="siDocsFile" style="display: none;"> <span
					id="fileName" style="color: white; margin-left: 10px;">파일이
					선택되지 않았습니다</span>

				<!-- 파일 선택 시 파일 이름 표시 -->
				<script>
					$(document)
							.ready(
									function() {
										$("#siDocsFile")
												.change(
														function() {
															var fileName = this.files[0] ? this.files[0].name
																	: "파일이 선택되지 않았습니다";
															$("#fileName")
																	.text(
																			fileName); // 파일 이름을 span에 표시
														});
									});
				</script>

				<!-- submit 버튼 텍스트 변경 가능 -->
				<button type="submit" class="register-button">Registration</button>
			</form>
		</div>
		<!-- 리사이즈 핸들 -->
		<div class="resize-handle"></div>
	</div>

	<!-- 회원정보 수정 모달 -->
	<div id="editModal" class="modal">
		<!-- 모달 헤더 -->
		<div class="modal-header" id="editModalHeader">
			<span class="close" id="closeEditModal">&times;</span>
			<h2>Edit</h2>
		</div>
		<!-- 모달 콘텐츠 -->
		<div class="modal-content">
			<form action="memberUpdate" method="post"
				onsubmit="return validateForm();">
				<input type="text" id="memId" name="memId"
					value="${sessionScope.user.memId}" required readonly> <input
					type="password" id="pwCheck" name="pwCheck"
					placeholder="Current Password" required> <input
					type="password" id="memPw" name="memPw" placeholder="New Password"
					required onkeyup="passwordCheck();"> <input type="password"
					id="memPw2" name="memPw2" placeholder="Confirm New Password"
					required onkeyup="passwordCheck();"> <span
					class="passMessage"></span> <input type="text" id="memNick"
					name="memNick" value="${sessionScope.user.memNick}" required>
				<input type="email" id="memEmail" name="memEmail"
					value="${sessionScope.user.memEmail}" required> <input
					type="text" id="memPhone" name="memPhone"
					value="${sessionScope.user.memPhone}" required>
				<button type="submit" class="join-button edit-button">Edit</button>

			</form>
		</div>
		<!-- 리사이즈 핸들 -->
		<div class="resize-handle"></div>
	</div>

	<!-- 선박 리스트 모달 -->
	<div id="listModal" class="modal" style="width: 500px;">
		<!-- 모달 헤더 -->
		<div class="modal-header" id="listModalHeader">
			<span class="close" id="closeShipListModal">&times;</span>
			<!-- 제목과 벨 아이콘을 감싸는 컨테이너 -->
			<div class="title-container">
				<div class="notification-box" id="alertIcon" style="display: none;">
					<span class="notification-count">0</span>
					<div class="notification-bell">
						<span class="bell-top"></span> <span class="bell-middle"></span> <span
							class="bell-bottom"></span> <span class="bell-rad"></span>
					</div>
				</div>
				<h2 class="ship-list-title">선박 리스트</h2>
			</div>
		</div>
		<!-- 모달 콘텐츠 -->
		<div class="modal-content">
			<!-- 선박 리스트 표시 부분 -->
			<ul id="shipList">
				<!-- AJAX로 받아온 선박 리스트가 표시됩니다. -->
			</ul>
		</div>
		<!-- 리사이즈 핸들 -->
		<div class="resize-handle"></div>
	</div>

	<!-- 선박 등록 거절 모달 -->
	<div id="rejectModal" class="modal" style="display: none;">
		<!-- 모달 헤더 -->
		<div class="modal-header" id="rejectModalHeader">
			<span class="close" id="closeRejectModal">&times;</span>
			<h2 class="ship-list-title" id="rejectModalH">선박 등록 거절</h2>
		</div>
		<!-- 모달 콘텐츠 -->
		<div class="modal-content">
			<p id="rejectModalP">선박 등록이 거절된 사유를 확인하세요.</p>
			<!-- 거절 사유 목록 -->
			<ul id="rejectReasonList">
				<!-- 서버에서 거절 사유를 받아와 표시 -->
			</ul>
		</div>
		<!-- 리사이즈 핸들 -->
		<div class="resize-handle"></div>
	</div>

	<!-- 그룹 정보 모달 -->
	<div id="groupInfoModal" class="modal">
		<!-- 모달 헤더 -->
		<div class="modal-header" id="groupInfoModalHeader">
			<span class="close" id="closeGroupInfoModal">&times;</span>
			<h2>그룹 정보</h2>
		</div>
		<!-- 모달 콘텐츠 -->
		<div class="modal-content">
			<!-- 초대 섹션 -->
			<div class="invite-section">
				<input type="text" placeholder="Email or ID" id="invitememID">
				<select>
					<option value="1">VIEWER</option>
					<option value="2">CONTROLLER</option>
					<option value="3">EDITOR</option>
					<option value="0">ADMIN</option>
				</select>
				<button onclick="inviteMember()">초대</button>
			</div>
			<!-- 사용자 리스트 -->
			<ul class="user-list">
				<!-- AJAX로 받아온 그룹 멤버 리스트가 이곳에 추가됩니다. -->
			</ul>
		</div>
		<!-- 리사이즈 핸들 -->
		<div class="resize-handle"></div>
	</div>

	<!-- 항해 리스트 모달 -->
	<div id="sailListModal" class="modal">
		<!-- 모달 헤더 -->
		<div class="modal-header" id="sailListModalHeader">
			<span class="close" id="closeSailListModal">&times;</span>
			<h2>
				항해 리스트 - <span id="sailListSiCode"></span>
			</h2>
		</div>
		<!-- 모달 콘텐츠 -->
		<div class="modal-content">
			<ul id="sailList">
				<!-- AJAX로 받아온 항해 리스트가 이곳에 표시됩니다. -->
			</ul>
			<!-- 모달 안에 페이징 버튼 컨테이너를 추가하여 모달을 벗어나지 않도록 함 -->
			<div id="paginationContainer" class="pagination-container"></div>
		</div>
		<!-- 리사이즈 핸들 -->
		<div class="resize-handle"></div>
	</div>
</body>
</html>
