<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<%@ page import="com.doran.entity.Ship"%>
<!DOCTYPE html>
<html>
<head>
<title>Controller</title>
<meta charset="UTF-8">
<script
	src="https://ajax.googleapis.com/ajax/libs/jquery/3.7.1/jquery.min.js"></script>
<!-- jQuery -->
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<!-- bootstrap -->
<link rel="stylesheet"
	href="https://maxcdn.bootstrapcdn.com/bootstrap/3.4.1/css/bootstrap.min.css">
<script
	src="https://maxcdn.bootstrapcdn.com/bootstrap/3.4.1/js/bootstrap.min.js"></script>

<!-- Google Maps API - Spring에서 전달된 API 키 사용 -->
<script src="https://cdn.jsdelivr.net/npm/axios/dist/axios.min.js"></script>

<script
	src="https://maps.googleapis.com/maps/api/js?key=AIzaSyDtt1tmfQ-lTeQaCimRBn2PQPTlCLRO6Pg"></script>
<!-- Tailwind CSS CDN -->
<script src="https://cdn.tailwindcss.com"></script>

<!-- Google Fonts -->
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link
	href="https://fonts.googleapis.com/css2?family=Outfit:wght@100;200;300;400;500;600;700;800;900&display=swap"
	rel="stylesheet">
<link rel="stylesheet"
	href="${pageContext.request.contextPath}/resources/css/map.css">

<!-- Include a required theme -->
<link rel="stylesheet"
	href="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.min.css">
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<style type="text/css">
#controlPanel {
	display: none; /* 처음에 숨기기 */
}

.control-panel {
	position: absolute; /* 지도 위에 고정 */
	z-index: 100; /* 지도보다 높은 값으로 설정 */
	top: 50%; /* 화면 세로 중앙으로 이동 */
	left: 50%; /* 화면 가로 중앙으로 이동 */
	transform: translate(-100%, -14%); /* 왼쪽으로 더 이동 */
	width: auto;
	background-color: transparent;
	display: flex;
	justify-content: center;
	align-items: center; /* 컨텐츠 세로 중앙 정렬 */
	pointer-events: none; /* 버튼이 아닌 지도 상의 클릭 허용 */
}

.arrow-buttons {
	position: relative; /* 부모 안에서 상대 위치 */
	width: 300px;
	height: 300px;
	display: flex;
	justify-content: center;
	align-items: center;
	pointer-events: auto; /* 버튼 클릭 허용 */
}

/* 각 방향 버튼의 기본 스타일입니다. 버튼 크기와 색상, 모양을 지정합니다. */
.control-button {
	position: absolute; /* 각 버튼을 arrow-buttons 안에서 절대 위치로 배치합니다. */
	width: 150px; /* 버튼 너비를 70px로 설정합니다. */
	pointer-events: auto; /* 버튼 클릭 허용 */
	height: 150px; /* 버튼 높이를 70px로 설정합니다. */
	background-color: transparent; /* 배경 투명하게 설정 */
	border: none; /* 버튼의 기본 테두리를 제거합니다. */
	border-radius: 10px; /* 버튼 모서리를 10px 반경으로 둥글게 처리합니다. */
	cursor: pointer; /* 버튼 위에 마우스를 올리면 포인터 모양이 나타나도록 설정합니다. */
}

/* 위쪽 버튼을 배치하는 클래스입니다. */
.up-btn {
	top: 0; /* 컨테이너의 위쪽에 위치시킵니다. */
	left: 50%; /* 수평 중앙에 위치하도록 합니다. */
	transform: translate(-50%, -50%); /* 버튼을 -50%씩 이동하여 정확한 중앙에 배치합니다. */
}

/* 아래쪽 버튼을 배치하는 클래스입니다. */
.down-btn {
	bottom: 0; /* 컨테이너의 아래쪽에 위치시킵니다. */
	left: 50%; /* 수평 중앙에 위치하도록 합니다. */
	transform: translate(-50%, 50%) rotate(180deg);
	/* 버튼을 수평 중앙으로 이동하고 180도 회전시킵니다. */
}

/* 왼쪽 버튼을 배치하는 클래스입니다. */
.left-btn {
	left: 0; /* 컨테이너의 왼쪽에 위치시킵니다. */
	top: 50%; /* 수직 중앙에 위치하도록 합니다. */
	transform: translate(-50%, -50%) rotate(-90deg);
	/* 버튼을 수직 중앙으로 이동하고 -90도 회전시킵니다. */
}

/* 오른쪽 버튼을 배치하는 클래스입니다. */
.right-btn {
	right: 0; /* 컨테이너의 오른쪽에 위치시킵니다. */
	top: 50%; /* 수직 중앙에 위치하도록 합니다. */
	transform: translate(45%, -50%) rotate(90deg);
	/* 버튼을 수직 중앙으로 이동하고 90도 회전시킵니다. */
}

.stop-btn {
	position: absolute; /* 부모 요소를 기준으로 절대 위치를 설정합니다. */
	top: 50%; /* 화면의 세로 중앙으로 배치합니다. */
	left: 50%; /* 화면의 가로 중앙으로 배치합니다. */
	transform: translate(-50%, -50%); /* 요소의 중심이 정확히 중앙에 오도록 조정합니다. */
}

/* 각 버튼 안에 들어갈 이미지를 설정하는 스타일입니다. */
.control-button img {
	width: 100%; /* 이미지 너비를 버튼 크기에 맞춥니다. */
	height: 100%; /* 이미지 높이를 버튼 크기에 맞춥니다. */
	object-fit: cover; /* 이미지 크기 조정 방식으로 cover를 사용하여 버튼에 꽉 차게 만듭니다. */
}

.status-overlay {
	position: absolute;
	z-index: 1000;
	right: 55px;
	bottom: 10px; /* 약간 내림 */
	width: 150px;
	height: 150px; /* 높이를 자동으로 설정하여 내용에 맞춤 */
	background-color: rgba(255, 255, 255, 0.85); /* 투명한 배경 */
	padding: 10px;
	border-radius: 8px;
	display: flex;
	justify-content: center;
	align-items: center;
	transform: translateY(20px);
}

.status-btn {
	display: flex;
	flex-direction: column; /* 버튼을 세로로 나열 */
	gap: 6px; /* 버튼 간 간격 설정 */
	width: 100%; /* 부모 컨테이너에 맞춰서 너비 설정 */
	margin-top: 0; /* 컨테이너 내에서 상단에 위치 */
}
/* 상태 표시 오버레이 */
.ship-status-overlay {
	position: absolute;
	top: 10px; /* 지도 오른쪽 상단에 위치 */
	right: 10px;
	display: flex;
	align-items: center;
	background-color: transparent;
	padding: 10px;
	border-radius: 8px;
	box-shadow: none;
	z-index: 1000000000;
}

.status-light {
	display: inline-block;
	width: 1.5rem;
	height: 1.5rem;
	border-radius: 50%;
	margin-right: 10px;
}

/* 빨간불: 정박 중 */
.status-light.red {
	background-color: #f00;
	box-shadow: rgba(0, 0, 0, 0.2) 0 -1px 7px 1px, inset #441313 0 -1px 9px,
		rgba(255, 0, 0, 0.5) 0 2px 12px;
}

/* 초록불: 운항 중 */
.status-light.green {
	background-color: #abff00;
	box-shadow: rgba(0, 0, 0, 0.2) 0 -1px 7px 1px, inset #304701 0 -1px 9px,
		#89ff00 0 2px 12px;
}
/* 상태 텍스트 */
#statusText {
	font-size: 1.5rem;
	font-weight: bold;
	color: white;
}

/* 속도 조절 패널 스타일 */
.speed-control-wrapper {
	display: flex;
	flex-direction: column;
	align-items: center;
	justify-content: center;
	font-family: 'Work Sans', sans-serif;
	text-align: center;
}

.speed-control-wrapper h1, .speed-control-wrapper h3 {
	margin: 0;
	color: #999;
	font-weight: 500;
}

.speed-control-wrapper h4 {
	margin: 0;
	color: #999;
	font-weight: 500;
}

.speed-control-wrapper h4:after {
	content: "km/h";
	padding-left: 1px;
}

/* 슬라이더 스타일 */
.speed-control-wrapper input[type="range"] {
	outline: 0;
	border: 0;
	border-radius: 500px;
	width: 400px;
	max-width: 100%;
	margin: 24px 0 16px;
	transition: box-shadow 0.2s ease-in-out;
}

/* Chrome 전용 스타일 */
@media screen and (-webkit-min-device-pixel-ratio:0) {
	.speed-control-wrapper input[type="range"] {
		overflow: hidden;
		height: 40px;
		-webkit-appearance: none;
		background-color: #ddd;
	}
	.speed-control-wrapper input[type="range"]::-webkit-slider-runnable-track
		{
		height: 40px;
		-webkit-appearance: none;
		color: #444;
		transition: box-shadow 0.2s ease-in-out;
	}
	.speed-control-wrapper input[type="range"]::-webkit-slider-thumb {
		width: 40px;
		-webkit-appearance: none;
		height: 40px;
		cursor: ew-resize;
		background: #fff;
		box-shadow: -340px 0 0 320px #1597ff, inset 0 0 0 40px #1597ff;
		border-radius: 50%;
		transition: box-shadow 0.2s ease-in-out;
		position: relative;
	}
	.speed-control-wrapper input[type="range"]:active::-webkit-slider-thumb
		{
		background: #fff;
		box-shadow: -340px 0 0 320px #1597ff, inset 0 0 0 3px #1597ff;
	}
}

/* Firefox 전용 스타일 */
.speed-control-wrapper input[type="range"]::-moz-range-progress {
	background-color: #43e5f7;
}

.speed-control-wrapper input[type="range"]::-moz-range-track {
	background-color: #9a905d;
}

/* IE 전용 스타일 */
.speed-control-wrapper input[type="range"]::-ms-fill-lower {
	background-color: #43e5f7;
}

.speed-control-wrapper input[type="range"]::-ms-fill-upper {
	background-color: #9a905d;
}

/* 슬라이더 값 표시 영역 스타일 */
#h4-container {
	width: 400px;
	max-width: 100%;
	padding: 0 20px;
	box-sizing: border-box;
	position: relative;
}

#h4-subcontainer {
	width: 100%;
	position: relative;
}

#h4-subcontainer h4 {
	display: flex;
	align-items: center;
	justify-content: center;
	position: absolute;
	top: 0;
	width: 40px;
	height: 40px;
	color: #fff !important;
	font-size: 12px;
	transform-origin: center -10px;
	transform: translateX(-50%);
	transition: margin-top 0.15s ease-in-out, opacity 0.15s ease-in-out;
}

#h4-subcontainer h4 span {
	position: absolute;
	width: 100%;
	height: 100%;
	top: 0;
	left: 0;
	background-color: #1597ff;
	border-radius: 0 50% 50% 50%;
	transform: rotate(45deg);
	z-index: -1;
}

/* 슬라이더가 활성화되지 않았을 때 값 표시 숨김 */
.speed-control-wrapper input[type="range"]:not(:active)+#h4-container h4
	{
	opacity: 0;
	margin-top: -50px;
	pointer-events: none;
}

/* 속도 설정 버튼 스타일 */
.speed-control {
	margin-top: 20px;
}

.speed-control button {
	padding: 10px 20px;
	background-color: #1597ff;
	border: none;
	border-radius: 5px;
	color: #fff;
	font-size: 16px;
	cursor: pointer;
}

.speed-control button:hover {
	background-color: #0f7cd0;
}

.custom-btn {
	width: 130px;
	height: 40px;
	color: #fff;
	border-radius: 5px;
	padding: 10px 25px;
	font-family: 'Lato', sans-serif;
	font-weight: 500;
	background: transparent;
	cursor: pointer;
	transition: all 0.3s ease;
	position: relative;
	display: inline-block;
	box-shadow: inset 2px 2px 2px 0px rgba(255, 255, 255, 0.5), 7px 7px 20px
		0px rgba(0, 0, 0, 0.1), 4px 4px 5px 0px rgba(0, 0, 0, 0.1);
	outline: none;
}

.autoSift-btn, .custom-btn {
	width: 100%; /* 버튼 너비를 status-btn에 맞춰서 전체 너비로 설정 */
	padding: 10px;
	font-family: 'Lato', sans-serif;
	font-weight: 500;
	color: #fff;
	border-radius: 5px;
	cursor: pointer;
	transition: all 0.3s ease;
	margin: 0; /* 개별 버튼 상단 여백 제거 */
}
/* 1 */
/* 2 */
.btn-1 {
	background: #76FF76; /* 밝은 라임 그린 */
	background: linear-gradient(0deg, #76FF76 0%, #4CAF50 100%);
	/* 밝은 라임 그린 그라데이션 */
	border: none;
}

.btn-2 {
	background: #ff0000;
	background: linear-gradient(0deg, #ff0000 0%, #cc0000 100%);
	/* 빨간색 그라데이션 */
	border: none;
}

.btn-1::before, .btn-2::before {
	height: 0%;
	width: 6px;
}

.btn-1:hover, .btn-2:hover {
	box-shadow: 4px 4px 6px 0 rgba(255, 255, 255, 0.5), -4px -4px 6px 0
		rgba(116, 125, 136, 0.5), inset -4px -4px 6px 0
		rgba(255, 255, 255, 0.2), inset 4px 4px 6px 0 rgba(0, 0, 0, 0.4);
}
</style>
</head>
<body>
	<div id="app">

		<div id="map"></div>

		<!-- 실시간 비디오 모달 -->
		<div id="videoModal"
			class="videoModal w-[80%] max-w-screen-md rounded-3xl bg-neutral-50 text-center antialiased px-5 md:px-20 py-10 shadow-2xl shadow-zinc-900 relative top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2"
			style="padding: 10px 30px;">

			<h3 class="text-2xl lg:text-3xl font-bold text-neutral-900 my-4">
				Camera view</h3>

			<button class="video-close-btn" @click="closeVideoModal">✖</button>
			<img id="cameraVideo" src="http://192.168.0.17:8080/video_feed"
				alt="Video Feed" @error="videoError" />

			<button type="button" id="reset" disabled
				class="px-8 py-4 mt-8 rounded-2xl text-neutral-50 bg-violet-800 hover:bg-violet-600 active:bg-violet-900 disabled:bg-neutral-900 disabled:cursor-not-allowed transition-colors"
				style="margin: 16px 0px 0px">Reset the position</button>

			<svg viewBox="0 0 16 16" xmlns="http://www.w3.org/2000/svg"
				class="w-[16px] h-[16px] absolute right-6 top-6">
					<path d="m2 2 12 12m0-12-12 12" class="stroke-2 stroke-current" /></svg>
		</div>

		<!-- 항해 시작 설정 모달 -->
		<div class="modal-overlay" id="sailModal" style="display: none;"
			@click="closeSailModal2">
			<div
				class="sailModal w-[80%] max-w-screen-md rounded-3xl bg-neutral-50 text-center antialiased px-5 md:px-20 py-10 shadow-2xl shadow-zinc-900 relative top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2"
				style="padding: 10px 30px;">

				<h3 class="text-2xl lg:text-3xl font-bold text-neutral-900 my-4"
					style="margin: 25px 0px;">Sail Start</h3>

				<div class="sailContainer form-floating mb-3">

					<form id="sailForm" action="sail/insert" method="post">
						<table class="table table-bordered" style="text-align: center;">
							<tr>
								<td style="vertical-align: middle; width: 110px;">선박 코드</td>
								<td><input type="text" name="siCode" id="siCode"
									value="${sessionScope.nowShip.siCode }" readonly
									class="form-control"></td>
							</tr>
							<tr>
								<td style="vertical-align: middle; width: 110px;">출발지</td>
								<td><input type="text" name="startSail" id="startSail"
									placeholder="출발지를 입력해주세요" class="form-control"></td>
							</tr>
							<tr>
								<td style="vertical-align: middle; width: 110px;">목적지</td>
								<td><input type="text" name="endSail" id="endSail"
									placeholder="목적지를 입력해주세요" class="form-control"></td>
							</tr>

							<tr>
								<td colspan="2">
									<button type="button" id="routeSet" @click="getFirstPoly"
										class="px-8 py-4 mt-8 rounded-2xl text-neutral-50 bg-violet-800 hover:bg-violet-600 active:bg-violet-900 disabled:bg-neutral-900 disabled:cursor-not-allowed transition-colors"
										style="margin: 8px 0px">경로 탐색</button>
								</td>
							</tr>
						</table>
					</form>
				</div>

				<svg viewBox="0 0 16 16" xmlns="http://www.w3.org/2000/svg"
					class="w-[16px] h-[16px] absolute right-6 top-6"
					@click="closeSailModal" style="cursor: pointer;">
					<path d="m2 2 12 12m0-12-12 12" class="stroke-2 stroke-current" /></svg>

				<div class="wayPoint">

					<!-- 여기에 지도 추가 -->
					<div id="sailModalMap"
						style="width: 100%; height: 400px; z-index: 1000000"></div>

					<div class="sailSetAlert">
						<ol style="list-style-position: inside;">
							<p>경유지를 추가할 경우 경로 재탐색이 필요합니다</p>
						</ol>
					</div>

					<button type="button" id="addWaypoint" @click="getPoly"
						class="px-8 py-4 mt-8 rounded-2xl text-neutral-50 bg-violet-800 hover:bg-violet-600 active:bg-violet-900 disabled:bg-neutral-900 disabled:cursor-not-allowed transition-colors"
						style="margin: 16px 32px;">경로 재탐색 🚤</button>
					<button type="button" id="addWaypoint" @click="showAlert"
						class="px-8 py-4 mt-8 rounded-2xl text-neutral-50 bg-violet-800 hover:bg-violet-600 active:bg-violet-900 disabled:bg-neutral-900 disabled:cursor-not-allowed transition-colors"
						style="margin: 16px 32px;">항해 시작 🚤</button>
				</div>

			</div>
		</div>

		<!-- 속도계 -->
		<div id="speedDisplay" class="speed-display">0</div>

		<!-- 속도 조절 패널 -->
		<div class="speed-control-wrapper">
			<h1>속도 조절</h1>
			<h3>km를 설정하세요</h3>

			<!-- 슬라이더 -->
			<input type="range" id="speedRange1" min="0" max="40" value="0" />

			<!-- 슬라이더 값 표시 영역 -->
			<div id="h4-container">
				<div id="h4-subcontainer">
					<h4 id="speedDisplay">
						0<span></span>
					</h4>
				</div>
			</div>

			<!-- 속도 설정 버튼 -->
			<div class="speed-control">
				<button id="setSpeedBtn">속도 설정</button>
			</div>
		</div>

		<!-- 허재혁 -->

		<!-- 아이콘 패널(우측) -->
		<div class="icon-panel">
			<div class="icon" @click="toggleShipModal()">🚤</div>
			<div class="icon" @click="getInfo('온도')">🌡️</div>
			<div class="icon" @click="getInfo('배터리')">🔋</div>
			<div class="icon" @click="getInfo('통신 상태')">📶</div>
			<div class="icon" @click="getInfo('현재 위치')">📍</div>
			<div class="icon" @click="getInfo('방위')">🧭</div>
			<div class="icon" @click="getInfo('주변 장애물 탐지')">🚧</div>
			<div class="icon" @click="goMain()">🔙</div>
			<div class="icon" @click="toggleModal()">📷</div>
		</div>

		<!-- 수동 제어 패널 -->
		<div class="control-panel" id="controlPanel">
			<div class="arrow-buttons">
				<button onclick="move('up')" class="control-button up-btn">
					<img
						src="<%=request.getContextPath()%>/resources/img/arrowButton.png"
						alt="up">
				</button>
				<button onclick="moveServo('left')" class="control-button left-btn">
					<img
						src="<%=request.getContextPath()%>/resources/img/arrowButton.png"
						alt="left">
				</button>
				<button onclick="moveServo('right')"
					class="control-button right-btn">
					<img
						src="<%=request.getContextPath()%>/resources/img/arrowButton.png"
						alt="right">
				</button>
				<button onclick="motorStop()" class="control-button stop-btn">
					<img src="<%=request.getContextPath()%>/resources/img/stop.png"
						alt="STOP">
				</button>
			</div>
		</div>

		<!-- 남은 시간 거리 패널 -->
		<div class="info-overlay">
			<div class="time-distance" id="info-overlay2">
				<span id="remainingTime">9분</span> <span id="remainingDistance">4.1km</span>
			</div>

			<button class="startSail-btn" @click="toggleSailStart"
				:disabled="sailStatus === '1'">항해 시작</button>
			<button class="destination-btn" @click="endSail"
				:disabled="sailStatus === '0'">항해 완료</button>

		</div>

		<!-- 아이콘 정보 상세 패널 -->
		<div class="info-panel" id="infoPanel">
			<button class="close-btn" @click="closeInfoPanel">✖</button>
			<h3 id="infoTitle">정보</h3>
			<p id="infoContent">상세 내용</p>
		</div>

	</div>

	<!-- 자동/수동, 운항중 상태 표시 패널 -->
	<div class="status-overlay">
		<div class="status-btn">
			<button class="autoSift-btn" id="autoSift-btn"
				@click="toggleAutopilot()">auto "on"</button>
			<button class="custom-btn btn-1">start</button>
			<button class="custom-btn btn-2">stop</button>
		</div>
	</div>

	<!-- 새로운 상태 표시 오버레이 추가 -->
	<div id="shipStatusOverlay" class="ship-status-overlay">
		<div id="statusLight" class="status-light red"></div>
		<span id="statusText">정박 중</span>
	</div>

	<!-- 최초 선박 정보 표시 모달 -->
	<div id="shipModal" class="modal-overlay">
		<div class="modal" @click="closeShipModal2">

			<article class="modal-container">
				<header class="modal-container-header">
					<h1 class="modal-container-title">
						<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"
							width="24" height="24" aria-hidden="true">
          <path fill="none" d="M0 0h24v24H0z" />
          <path fill="currentColor"
								d="M14 9V4H5v16h6.056c.328.417.724.785 1.18 1.085l1.39.915H3.993A.993.993 0 0 1 3 21.008V2.992C3 2.455 3.449 2 4.002 2h10.995L21 8v1h-7zm-2 2h9v5.949c0 .99-.501 1.916-1.336 2.465L16.5 21.498l-3.164-2.084A2.953 2.953 0 0 1 12 16.95V11zm2 5.949c0 .316.162.614.436.795l2.064 1.36 2.064-1.36a.954.954 0 0 0 .436-.795V13h-5v3.949z" />
        </svg>
						Current Ship
					</h1>
					<button class="icon-button" @click="closeShipModal">
						<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"
							width="24" height="24">
          <path fill="none" d="M0 0h24v24H0z" />
          <path fill="currentColor"
								d="M12 10.586l4.95-4.95 1.414 1.414-4.95 4.95 4.95 4.95-1.414 1.414-4.95-4.95-4.95 4.95-1.414-1.414 4.95-4.95-4.95-4.95L7.05 5.636z" />
        </svg>
					</button>
				</header>
				<section class="modal-container-body rtf">

					<h1>Ship Code</h1>

					<p id="siCode">${sessionScope.nowShip.siCode}</p>

					<h2>선박 명</h2>

					<p id="siName">${sessionScope.nowShip.siName}</p>

					<p id="siCert">인증 여부 : ${sessionScope.nowShip.siCert == '1' ? '인증 승인 완료' : '인증 미승인'}
					</p>
					<p id="sailStatus">운항 상태 : ${sessionScope.nowShip.sailStatus == '1' ? '운항중' : '정박중'}
					</p>

					<h2>자율운항 이용약관</h2>
					<ol
						style="margin-left: 20px; list-style-position: inside; list-style: numeric;">
						<li>자율운항선박 운항해역의 지정·변경·해제(안 제2조) 해수부장관은 자율운항선박 운항해역 지정·변경·해제
							절차 등 규정</li>
						<li>자율운항선박 및 기자재 안전성 평가(안 제3조) 안전성 평가의 신청, 심사·평가 및 활용에 관한 사항
							규정</li>
						<li>운항의 승인신청(안 제4조) 자율운항선박의 운항 승인 신청 절차 규정</li>
						<li>운항의 승인(안 제5조) 자율운항선박의 운항 승인·불승인 관련 사항 규정</li>
						<li>규제 신속확인(안 제6조) 규제 신속확인 신청서 및 통지서 서식</li>
					</ol>
				</section>
				<footer class="modal-container-footer">
					<button class="button is-ghost" @click="goMain">Decline</button>
					<button class="button is-primary" @click="closeShipModal">Accept</button>
				</footer>
			</article>
		</div>
	</div>

	<%
	Ship nowShip = (Ship) session.getAttribute("nowShip");
	char sailStatus = (nowShip != null) ? nowShip.getSailStatus() : '0';
	String siCode = (nowShip != null) ? nowShip.getSiCode() : "siCode is null";
	String msgType = (String) request.getAttribute("msgType");
	String waypoints = (String) session.getAttribute("waypoints");
	%>

	<script src="https://cdn.jsdelivr.net/npm/vue@2/dist/vue.js"></script>
	<!-- GSAP Scripts -->
	<script src='https://unpkg.com/gsap@3/dist/gsap.min.js'></script>
	<script src='https://unpkg.com/gsap@3/dist/Draggable.min.js'></script>
	<script src='https://assets.codepen.io/16327/InertiaPlugin.min.js'></script>
	<script>
	
	new Vue({
	    el: '#app',
	    data() {
	        return {
	            map: null,    // Google Maps 객체를 저장할 변수
	            marker: null, // 사용자 마커 객체를 저장할 변수
	            flightPlanCoordinates: [], // Polyline 데이터를 저장할 곳
	            flightPath: null,
	            sailStatus: '<%=String.valueOf(sailStatus)%>',
	            
	            sailMap: null, // sailModal에 들어갈 지도
	            sailMarkers: [], // sailModal에서 표시된 마커들
	            endMarker: [],
	            currentPositionMarker: null, // 사용자 현재 위치 마커
	            waypoints: <%=(waypoints != null) ? waypoints : "[]"%>,
	            destination: [],
	            
	            formData: { // 항해 시작 설정 form 데이터 저장
	                siCode: "<%=siCode%>",
	                startSail: "",
	                endSail: ""
	            },
	            msgType: '<%=(msgType != null) ? msgType : ""%>'
	        };
	    },
	    mounted() {
	    	// 전역에서 참조 가능하도록 저장
	        window.appVueInstance = this;
	    	
	        this.loadPoly(); // 경로 데이터 받아오기
	        this.updateLocation(); // 위치 업데이트 시작
	        this.initSpeedControls(); // 속도 조절 컨트롤 초기화
	        this.toggleModal(); // 실시간 비디오 모달 켜기
	        this.initDraggable(); // 모달 드래그 기능 초기화
	        this.afterStartSail(); // 항해 시작 후 (경유지 추가)
	        
	        this.startRealTimePoly(); // realTimePoly 자동실행 메서드
	    },
	    methods: {
	    	loadPoly() { // 1. 경로 데이터 받아오기(GoogleMapController)

	    		const waypoints = JSON.stringify(this.waypoints);
	            axios.post("http://localhost:8085/controller/aStarConnection", waypoints, {
	                headers: {
	                    'Content-Type': 'application/json' // 올바른 Content-Type 헤더 설정
	                }
	            })
	            .then(response => {
	              this.flightPlanCoordinates = response.data;  // 데이터를 Vue 데이터 속성에 할당
	              this.initMap();
	              this.initSailMap();
	            })
	            .catch(error => {
	              
	            	axios.post("http://localhost:8085/controller/flightPlanCoordinates", waypoints, {
		                headers: {
		                    'Content-Type': 'application/json' // 올바른 Content-Type 헤더 설정
		                }
		            })
		            .then(response => {
		              this.flightPlanCoordinates = response.data;  // 데이터를 Vue 데이터 속성에 할당
		              this.initMap();
		              this.initSailMap();
		            })
		            .catch(error => {
		              console.error("Error fetching flightCoordinates:", error);
		            });
	              console.error("Error fetching aStarConnection:", error);
	            });
	    	
	        },
	        initMap() { // 2. 지도 초기화 및 polyline 그리기(Google maps api)
	            // Google Maps 스타일 설정 (다크 모드)
	            var styledMapType = new google.maps.StyledMapType(
	                [
	                    { elementType: 'geometry', stylers: [{ color: '#212121' }] },
	                    { elementType: 'labels.icon', stylers: [{ visibility: 'off' }] },
	                    { elementType: 'labels.text.fill', stylers: [{ color: '#757575' }] },
	                    { elementType: 'labels.text.stroke', stylers: [{ color: '#212121' }] },
	                    {
	                        featureType: 'administrative',
	                        elementType: 'geometry',
	                        stylers: [{ color: '#757575' }]
	                    },
	                    {
	                        featureType: 'road',
	                        elementType: 'geometry.fill',
	                        stylers: [{ color: '#2c2c2c' }]
	                    },
	                    {
	                        featureType: 'water',
	                        elementType: 'geometry',
	                        stylers: [{ color: '#000000' }]
	                    },
	                    {
	                        featureType: 'poi.park',
	                        elementType: 'geometry',
	                        stylers: [{ color: '#181818' }]
	                    }
	                ],
	                { name: 'Dark Mode' }
	            );
	        
	        	let zoomLevel = 14;
	        	let centerSet = { lat: 34.804309-0.001609, lng: 126.364591-0.040446 };
	        	
	        	if(this.sailStatus === '1'){
	        		zoomLevel = 16;
	        		centerSet = { lat: 34.804309-0.000154, lng: 126.364591-0.012067 };
	        	}

	            // Google Maps 초기화
	            this.map = new google.maps.Map(document.getElementById('map'), {
	            	center: centerSet, // 초기 중심 좌표 설정(북항)
	                zoom: zoomLevel, 
	                mapTypeControlOptions: {
	                    mapTypeIds: ['roadmap', 'satellite', 'hybrid', 'terrain', 'styled_map']
	                },
	                mapTypeId: "roadmap", // 지도 유형 설정
	            });

	            // 기본 맵 스타일 적용
	            this.map.mapTypes.set('styled_map', styledMapType);
	            this.map.setMapTypeId('roadmap');
	            
	            // Polyline 생성 및 지도에 추가
	            const flightPath = new google.maps.Polyline({
	                path: this.flightPlanCoordinates,
	                geodesic: true,
	                strokeColor: "#FF0000",
	                strokeOpacity: 1.0,
	                strokeWeight: 3,
	                icons: [
	                    {
	                      icon: {
	                        path: google.maps.SymbolPath.FORWARD_CLOSED_ARROW, // 화살표 모양 설정
	                        scale: 2,
	                        strokeColor: "#0000FF"
	                      },
	                      offset: "50%", // 전체 경로의 중간에 아이콘 배치
	                    }
	                  ]
	            });
	            flightPath.setMap(this.map);

	        },
	        async updateLocation() { // 3. 사용자 현재 위치 표시(Google geolocation api)
	            // 위치 업데이트를 위한 함수
	            const updatePosition = () => {
	                // Geolocation API를 사용하여 현재 위치 가져오기
	                navigator.geolocation.getCurrentPosition(async (position) => {
	                    const { latitude, longitude } = position.coords;

	                    // Google Maps에 사용자 마커 표시
	                    if (!this.marker) {
	                        // 마커가 없는 경우 새로 생성
	                        this.marker = new google.maps.Marker({
	                            position: { lat: latitude, lng: longitude }, // 마커 위치
	                            map: this.map, // 표시할 지도
	                            icon: {
	                                url: '<%=request.getContextPath()%>/resources/img/icon.png', // 마커 아이콘 경로
	                                scaledSize: new google.maps.Size(100, 100) // 아이콘 크기 조정
	                            }
	                        });

	                        // 마커의 위치로 지도의 중심 이동
	                        this.map.setCenter({ lat: latitude, lng: longitude });
	                    } else {
	                        // 마커가 이미 있는 경우 위치 업데이트
	                        this.marker.setPosition({ lat: latitude, lng: longitude });
	                    }

	                    // 서버에 위치 정보 요청
	                    try {
	                        const response = await fetch(`/api/location?latitude=${latitude}&longitude=${longitude}`);
	                        const data = await response.json();
	                    } catch (error) {
	                        console.error('Error fetching location info:', error);
	                    }
	                }, (error) => {
	                    console.error('Geolocation error:', error); // 오류 처리
	                });
	            };

	            // 위치 업데이트 간격 설정(100초 간격)
	            setInterval(updatePosition, 100000);
	        },
	        initSpeedControls() { // 4. 속도 조절 함수
	            
	            document.getElementById('speedRange1').addEventListener('input', function () {
	                document.getElementById('speedDisplay1').textContent = this.value;
	            });

	            document.getElementById('setSpeedBtn').addEventListener('click', function () {
	                var currentSpeed = document.getElementById('speedRange1').value;
	                alert(currentSpeed + 'km로 속도를 설정합니다.');
	            });

	            document.getElementById('speedRange1').addEventListener('input', function () {
	                var speedValue = this.value;
	                document.getElementById('speedDisplay').textContent = speedValue;
	                document.getElementById('speedDisplay1').textContent = speedValue;
	            });
	        },
	        showInfo(title) { // 5. 정보 패널 표시 함수

	            const infoPanel = document.getElementById('infoPanel');
	            const infoTitle = document.getElementById('infoTitle');

	            infoTitle.textContent = title; // 패널 제목 설정
	            infoPanel.classList.add('active'); // 패널 표시

	        }, getInfo(title){ // 6. 정보 패널 데이터 받아오기
	        	
	            const infoContent = document.getElementById('infoContent');
	        
	        	axios.get("http://localhost:8085/controller/getInfo", {
	        		params: {
	        			infoTitle: title
	        		}
	        	}) 
	            .then(response => {
	                this.infoTitle = title;
	                infoContent.textContent = response.data;  // 받아온 데이터로 infoContent 업데이트
	                this.showInfo(title);  // info-panel을 열어줌
	            })
	            .catch(error => {
	                console.error('Error getInfow data:', error);
	            });
	        	
	        }, closeInfoPanel() { // 7. 정보 패널 숨김 함수

	            const infoPanel = document.getElementById('infoPanel');
	            infoPanel.classList.remove('active'); // 패널 숨김
	            
	        }, startSail(){ // 8. startSail 메서드 실행 함수
	        	console.log("startSail");
	        	axios.get("http://localhost:8085/controller/sail/startSail")
                .then(response => {
                    this.updateStatus("운항 중", "green"); // 상태 업데이트
                })
                .catch(error => {
                    console.error('Error in startSail:', error);
                });
	        	
	        }, endSail() { // 9. endSail 메서드 실행 함수
	        	console.log("endSail");
	        	axios.get("http://localhost:8085/controller/sail/endSail")
                .then(response => {
                    this.updateStatus("정박 중", "red"); // 상태 업데이트
                    window.location.href = "http://localhost:8085/controller/map2";
                })
                .catch(error => {
                    console.error('Error in endSail:', error);
                });
	        
	        },
            updateStatus(statusText, colorClass) {
	        	console.log("updateStatus");
                const statusLight = document.getElementById("statusLight");
                const statusTextElement = document.getElementById("statusText");

                if (statusTextElement) {
                    statusTextElement.textContent = statusText;
                }
                if (statusLight) {
                    statusLight.className = `status-light ${colorClass}`;
                }
            }, closeVideoModal(){ // 10. 실시간 카메라 모달 끄기 함수
	        	
	        	var videoModal = document.getElementById("videoModal");
	        	videoModal.style.display = "none";
	        	 
	        }, toggleModal() { // 11. 실시간 카메라 모달 켜기 함수
	            var modal = document.getElementById("videoModal");
	            var mapDiv = document.getElementById("map");

	            if (modal.style.display === "none" || modal.style.display === "") {
	                var mapHeight = mapDiv.offsetHeight;
	                var mapWidth = mapDiv.offsetWidth;
	                
	                var modalWidth = mapWidth * 0.35;
	                var modalHeight = modalWidth * 0.946;

	                // 모달 크기 설정
	                modal.style.height = modalHeight + "px";
	                modal.style.width = modalWidth + "px";
	                
	                // 모달 위치 중앙에 설정
	                modal.style.top = (mapHeight * 0.3) + "px";
	                modal.style.left = (mapWidth * 0.075) + "px";

	                modal.style.display = "block"; // 모달 표시
	            } else {
	                modal.style.display = "none";
	            }
	        }, videoError(){ // 11-1. 비디오 x 일때 대응
	        	
	        	document.getElementById('cameraVideo').src = '<%=request.getContextPath()%>/resources/img/videoError.png';
	        },
	        initDraggable() { // 12. 실시간 카메라 모달 드래그 함수
	        	
	            const modal = document.getElementById('videoModal');
	            const wrapper = document.getElementById('map');
	            const reset = document.getElementById('reset');
	            const page = document.getElementById('app');

	            const resetModalPosition = () => {
	            	
	            	const wrapperRect = wrapper.getBoundingClientRect();
	                const pageRect = page.getBoundingClientRect();
	                
	                modal.style.position = 'fixed';
	            	
	                gsap.to(modal, {
	                    duration: 0.6,
	                    ease: "power3.out",
	                    x: wrapperRect.left,
	                    y: pageRect.top,
	                    xPercent: 0,
	                    yPercent: 0,
	                });
	                reset.disabled = true;
	            };

	            Draggable.create(modal, {
	                type: 'x,y',
	                bounds: wrapper,
	                edgeResistance: 0.85,
	                inertia: true,
	                throwResistance: 3000,
	                onPressInit: function() {
	                    page.classList.add('bg-violet-900');
	                },
	                onRelease: function() {
	                    page.classList.remove('bg-violet-900');
	                },
	                onDrag: function() {
	                    const x = gsap.getProperty(this, 'x');
	                    const y = gsap.getProperty(this, 'y');

	                    if (x === 0 && y === 0) {
	                        reset.disabled = true;
	                    } else {
	                        reset.disabled = false;
	                    }
	                }
	            });

	            reset.addEventListener('click', resetModalPosition);

	            window.addEventListener('resize', () => {
	                resetModalPosition();
	            });
	        }, toggleSailStart() { // 1. 항해 시작 모달(sailModal) 켜기 ------------------------------------------------------------------------------------------

	        	var modal = document.getElementById("sailModal");

	            if (modal.style.display === "none" || modal.style.display === "") {
	               
	            	modal.style.display = "block"; // 모달 표시
	            } else {
	                modal.style.display = "none";
	            }
	        },
	        initSailMap() { // 2. sailModal에 지도를 띄우는 새로운 로직(마커 정보를 변수에 저장하고 좌표 정보도 저장)
	            
	            this.sailMap = new google.maps.Map(document.getElementById('sailModalMap'), {
	            	center: { lat: 34.804309-0.000409, lng: 126.364591-0.015446 }, // 초기 중심 좌표 설정(북항)
	                zoom: 14
	            });
	        
	            // 사용자의 현재 위치 마커 표시
	            const updatePosition = () => {
	                navigator.geolocation.getCurrentPosition(async (position) => {
	                    const { latitude, longitude } = position.coords;

	                    if (!this.marker) {
	                        this.marker = new google.maps.Marker({
	                            //position: { lat: latitude, lng: longitude },
	                            position: { lat: 34.804309, lng: 126.364591 },
	                            map: this.sailMap, // 표시할 지도
	                            icon: {
	                                url: '<%=request.getContextPath()%>/resources/img/icon.png', // 마커 아이콘 경로
	                                scaledSize: new google.maps.Size(100, 100) // 아이콘 크기 조정
	                            }
	                        });

	                        //this.sailMap.setCenter({ lat: latitude, lng: longitude });
	                        this.sailMap.setCenter({ lat: 34.804309, lng: 126.364591 });
	                    } else {
	                        this.marker.setPosition({ lat: latitude, lng: longitude });
	                    }

	                    try {
	                        const response = await fetch(`/api/location?latitude=${latitude}&longitude=${longitude}`);
	                        const data = await response.json();
	                    } catch (error) {
	                        console.error('Error fetching location info:', error);
	                    }
	                }, (error) => {
	                    console.error('Geolocation error:', error); 
	                });
	            };

	            // 위치 업데이트 간격 설정(5초 간격)
	            setInterval(updatePosition, 500000000000000);
	        	
	            // sailModal 지도를 클릭할 때마다 마커를 추가하는 기능
	            this.sailMap.addListener('click', (event) => {
	                const position = { lat: event.latLng.lat(), lng: event.latLng.lng() };
	                const markerNumber = this.sailMarkers.length + 2;
	                const marker = new google.maps.Marker({
	                    position,
	                    map: this.sailMap,
	                    label: markerNumber.toString(), // 마커에 번호 부여
	                    draggable: true,
	                });
	                
	             	// 드래그가 끝났을 때 위치 업데이트 및 waypoints 배열 업데이트
	                marker.addListener('dragend', () => {
	                    const newPosition = marker.getPosition();
	                    
	                    const markerIndex = this.sailMarkers.indexOf(marker);
	                    this.waypoints = this.sailMarkers.map(m => ({
	                        lat: m.getPosition().lat(),
	                        lng: m.getPosition().lng(),
	                    }));

	                 	// 해당 인덱스의 위치를 업데이트
	                    if (markerIndex !== -1) {
	                        this.waypoints[markerIndex] = {
	                            lat: newPosition.lat(),
	                            lng: newPosition.lng(),
	                        };
	                    }
	                });
	                
	             	// 마커 클릭 시 해당 마커 삭제 기능 추가
	                marker.addListener('click', () => {
	                	
	                    marker.setMap(null);
	                    this.sailMarkers = this.sailMarkers.filter(m => m !== marker);
	                    this.waypoints = this.sailMarkers.map(m => ({
	                        lat: m.getPosition().lat(),
	                        lng: m.getPosition().lng(),
	                    }));	                    
	                 	// 마커 번호 다시 매기기
	                    this.sailMarkers.forEach((m, index) => {
	                        m.setLabel((index + 1).toString());
	                    });
	                });

	                // 추가된 마커를 배열에 저장
	                this.sailMarkers.push(marker);
	                
	                this.waypoints = this.sailMarkers.map(marker => ({
		                lat: marker.getPosition().lat(),
		                lng: marker.getPosition().lng(),
		            }));
	            });
	            
	        }, 
	        getFirstPoly() { // 3. 목적지 설정 버튼 누르면 비동기 방식으로 경로 받아오기(GoogleMapController에서 a*알고리즘과 통신)

	    		const address = document.getElementById('endSail').value;
	            axios.post('http://localhost:8085/controller/firstGeocode', address, {
	                headers: {
	                    'Content-Type': 'application/json; charset=UTF-8;' // 올바른 Content-Type 헤더 설정
	                }
	            }).then(response => {
	            	
                	this.destination = response.data;
                	const waypoints = JSON.stringify(this.destination);
                	axios.post('http://localhost:8085/controller/aStarConnection', waypoints, {
    	                headers: {
    	                    'Content-Type': 'application/json' // 올바른 Content-Type 헤더 설정
    	                }
    	            }).then(response => {
    	                	this.flightPlanCoordinates = response.data;
    	                	
    	                	// 이전에 그려진 Polyline이 있으면 제거
    	                    if (this.flightPath) {
    	                        this.flightPath.setMap(null);
    	                    }
    	  	              	
    	  	           		// Polyline 생성 및 지도에 추가
    	  		            this.flightPath = new google.maps.Polyline({
    	  		                path: this.flightPlanCoordinates,
    	  		                geodesic: true,
    	  		                strokeColor: "#FF0000",
    	  		                strokeOpacity: 1.0,
    	  		                strokeWeight: 3,
    	  		            });
    	  		          	this.flightPath.setMap(this.sailMap);
    	  		          	
    	  		          	this.sailMarkers.forEach(marker => marker.setMap(null));
  	  		            	this.sailMarkers = [];
  	  		            	this.waypoints = [];
  	  		            	
  		  		          	if (this.endMarker.length > 0) {
  		  		            	this.endMarker.forEach(marker => marker.setMap(null));
  		  		            	this.endMarker = []; // 마커 배열 초기화
  		  		        	}

  		  		     		// 커스텀 마커 추가
  		  		        	this.addCustomMarker(this.destination[0].lat, this.destination[0].lng, address);
  		  		          	
  	  		                const marker = new google.maps.Marker({
  	  		                	position: { lat: this.destination[0].lat, lng: this.destination[0].lng }, // 위치 설정
  	  		                    map: this.sailMap,
  	  		                    label: address, // 마커에 번호 부여
  	  		                });

  	  		                // 추가된 마커를 배열에 저장
  	  		                this.endMarker.push(marker);
    	                })
    	                .catch(error => {
    	                    console.error("목적지 경로 설정 실패:", error);
    	                });
                })
                .catch(error => {
                    console.error("목적지 좌표 설정 실패:", error);
                });
	            
	    	},

	        addCustomMarker(lat, lng, label) {
	          const position = new google.maps.LatLng(lat, lng);
	          const map = this.sailMap;

	          // 커스텀 마커 클래스 정의
	          class CustomMarker extends google.maps.OverlayView {
	            constructor(position, map, label) {
	              super();
	              this.position = position;
	              this.label = label;

	              // HTML 요소 생성 및 스타일 적용
	              this.div = document.createElement("div");
	              this.div.style.position = "absolute";
	              this.div.style.padding = "5px 10px";
	              this.div.style.backgroundColor = "white";
	              this.div.style.borderRadius = "8px";
	              this.div.style.border = "1px solid #ddd";
	              this.div.style.boxShadow = "0 2px 6px rgba(0,0,0,0.3)";
	              this.div.style.fontSize = "14px";
	              this.div.style.color = "#333";
	              this.div.style.whiteSpace = "nowrap";
	              this.div.innerText = label;

	              // 지도에 추가
	              map.getDiv().appendChild(this.div);
	              this.setMap(map);
	            }

	            // CustomOverlay의 위치 업데이트
	            draw() {
	              const projection = this.getProjection();
	              const position = projection.fromLatLngToDivPixel(this.position);

	              // HTML 요소 위치 설정
	              if (position) {
	                this.div.style.left = position.x + "px";
	                this.div.style.top = position.y + "px";
	              }
	            }

	            // CustomOverlay 삭제
	            onRemove() {
	              if (this.div) {
	                this.div.parentNode.removeChild(this.div);
	                this.div = null;
	              }
	            }
	          }

	          // 커스텀 마커 인스턴스 생성
	          new CustomMarker(position, map, label);
	        }, getPoly(){ // 3-1. 경로 재설정 버튼 누르면 비동기 방식으로 경로 받아오기(GoogleMapController에서 a*알고리즘과 통신)

	        	const lastWaypoint = this.waypoints[this.waypoints.length - 1];
	        	if (!lastWaypoint || lastWaypoint.lat !== this.destination[0].lat || lastWaypoint.lng !== this.destination[0].lng) {
	        		this.waypoints.push({lat: this.destination[0].lat, lng: this.destination[0].lng})
	        	}
	        	
	        	const waypoints = JSON.stringify(this.waypoints);
        	    console.log("waypoints : " + waypoints);
	            
	            axios.post('http://localhost:8085/controller/aStarConnection', waypoints, {
	                headers: {
	                    'Content-Type': 'application/json' // 올바른 Content-Type 헤더 설정
	                }
	            }).then(response => {
	                	this.flightPlanCoordinates = response.data;
	                	
	                	// 이전에 그려진 Polyline이 있으면 제거
	                    if (this.flightPath) {
	                        this.flightPath.setMap(null);
	                    }
	  	              	
	  	           		// Polyline 생성 및 지도에 추가
	  		            this.flightPath = new google.maps.Polyline({
	  		                path: this.flightPlanCoordinates,
	  		                geodesic: true,
	  		                strokeColor: "#FF0000",
	  		                strokeOpacity: 1.0,
	  		                strokeWeight: 3,
	  		            });
	  		          	this.flightPath.setMap(this.sailMap);
	  		       		
	                })
	                .catch(error => {
	                    console.error("목적지 설정 실패:", error);
	                });
	    	},
	        sendWaypoints() { // 4. sailMarkers에 저장된 좌표 정보를 Controller로 전송(db 저장)
	        
	            axios.post("http://localhost:8085/controller/saveWaypoint", this.waypoints, {
	                headers: {
	                    'Content-Type': 'application/json' // 올바른 Content-Type 헤더 설정
	                }
	            })
	                .then(response => {
	                })
	                .catch(error => {
	                    console.error("Error saving waypoints:", error);
	                });
	            
	        }, startSailInsert(){ // 5. sailController에 데이터 보내서(form submit) 항해시작db저장[그 전에 waypoints 데이터 세션 저장]
	        	
	        	axios.post("http://localhost:8085/controller/waypointSession", this.waypoints)
                .then(response => {
                })
                .catch(error => {
                    console.error("Error waypointSession waypoints:", error);
                });
	        	
	    		document.getElementById("sailForm").submit(); // 항해 시작 Controller 연결

	        }, afterStartSail(){
	        	if (this.msgType === "성공") {
		    		this.sendWaypoints();
	            }
	        	
	        }, showAlert() { // 6. 항해 확정 alert 창 
	        	
	            const waypointsList = this.waypoints.map(waypoint => 
	            	waypoint.lat + " " + waypoint.lng
	        	).join('<br>');
	        	console.log("waypointsList : "+waypointsList);

	        	Swal.fire({
	                title: "<strong>Waypoints</strong>",
	                icon: "info",
	                html: "Here are the waypoints:<br>"
	                    + waypointsList,
	                showCloseButton: true,
	                showCancelButton: true,
	                focusConfirm: false,
	                confirmButtonText: `
	                    <i class="fa fa-thumbs-up">Great!</i>
	                `,
	                confirmButtonAriaLabel: "Thumbs up, great!",
	                cancelButtonText: `
	                    <i class="fa fa-thumbs-down">Cancel</i>
	                `,
	                cancelButtonAriaLabel: "Thumbs down"
	            }).then((result) => {
	                if (result.isConfirmed) {
	                    this.startSailInsert(); // 버튼 클릭 시 메소드 호출
	                }
	            });
	            
	        }, closeSailModal(){ // 항해 시작 모달 끄기(x 클릭)1
	        	var videoModal = document.getElementById("sailModal");
	        	videoModal.style.display = "none";
	        }, closeSailModal2(event){ // 항해 시작 모달 끄기(레이아웃 클릭)2---------------------------------------------------------------------------
	        	
	        	var modal = document.getElementById("sailModal");
	        	
	        	if (event.target === event.currentTarget) {
	                modal.style.display = "none";
	            }
	        }, // 5초마다 실행될 realTimePoly 메서드
	        realTimePoly() {
	        	
	        	const waypoints = JSON.stringify(this.waypoints);
	        	axios.post('http://localhost:8085/controller/aStarConnection', waypoints, {
	                headers: {
	                    'Content-Type': 'application/json' // 올바른 Content-Type 헤더 설정
	                }
	            }).then(response => {
	                	this.flightPlanCoordinates = response.data;
	                	
	                	// 이전에 그려진 Polyline이 있으면 제거
	                    if (this.flightPath) {
	                        this.flightPath.setMap(null);
	                    }
	  	              	
	  	           		// Polyline 생성 및 지도에 추가
	  		            this.flightPath = new google.maps.Polyline({
	  		                path: this.flightPlanCoordinates,
	  		                geodesic: true,
	  		                strokeColor: "#FF0000",
	  		                strokeOpacity: 1.0,
	  		                strokeWeight: 3,
	  		            });
	  		          	this.flightPath.setMap(this.sailMap);
	  		       		console.log("realTimePoly 경로 자동 재탐색 완료");
	                })
	                .catch(error => {
	                	
	                	axios.post('http://localhost:8085/controller/flightPlanCoordinates', waypoints, {
	    	                headers: {
	    	                    'Content-Type': 'application/json' // 올바른 Content-Type 헤더 설정
	    	                }
	    	            }).then(response => {
	    	                	this.flightPlanCoordinates = response.data;
	    	                	
	    	                	// 이전에 그려진 Polyline이 있으면 제거
	    	                    if (this.flightPath) {
	    	                        this.flightPath.setMap(null);
	    	                    }
	    	  	              	
	    	  	           		// Polyline 생성 및 지도에 추가
	    	  		            this.flightPath = new google.maps.Polyline({
	    	  		                path: this.flightPlanCoordinates,
	    	  		                geodesic: true,
	    	  		                strokeColor: "#FF0000",
	    	  		                strokeOpacity: 1.0,
	    	  		                strokeWeight: 3,
	    	  		            });
	    	  		          	this.flightPath.setMap(this.sailMap);
	    	  		       		console.log("realTimePoly 경로 자동 재탐색 완료");
	    	                })
	    	                .catch(error => {
	    	                    console.error("목적지 설정 실패:", error);
	    	                });
	                    console.error("a* 목적지 설정 실패:", error);
	                });
	            
	        }, // realTimePoly 실행 메서드
	        startRealTimePoly() {
	            if (this.sailStatus === '1') {
	                setInterval(() => {
	                    this.realTimePoly();
	                }, 5000000);
	            }
	        }, goMain(){
	        	window.location.href = "http://localhost:8085/controller/main"; // 특정 페이지로 이동
	        	
	        }, toggleShipModal() { // 1. 선박 정보 최조 출력 모달
	            
				var modal = document.getElementById("shipModal");

	            if (modal.style.display === "none" || modal.style.display === "") {
	               
	            	modal.style.display = "block"; // 모달 표시
	            } else {
	                modal.style.display = "none";
	            }
	        }
	    }
	});
	
	new Vue({
		el: '#shipModal',
		data(){
			return{
				
				sailStatus: '<%=String.valueOf(sailStatus)%>'
			};
		}, mounted(){
			
			// 이전 페이지가 main인지 확인
	        if (document.referrer === "http://localhost:8085/controller/main") {
	        	this.toggleShipModal();
	        }
		},
		methods: {
			toggleShipModal() { // 1. 선박 정보 최조 출력 모달
	            
				var modal = document.getElementById("shipModal");

	            if (modal.style.display === "none" || modal.style.display === "") {
	               
	            	modal.style.display = "block"; // 모달 표시
	            } else {
	                modal.style.display = "none";
	            }
	        }, closeShipModal(){ // 2. 선박 정보 최초 출력 모달 끄기
	        	
	        	var shipModal = document.getElementById("shipModal");
	        	shipModal.style.display = "none";
	        	
	        }, closeShipModal2(event){
	        	
	        	var modal = document.getElementById("shipModal");
	        	
	        	if (event.target === event.currentTarget) {
	                modal.style.display = "none";
	            }
	        }, goMain(){ // 3. 메인으로 이동
	        	window.location.href = "http://localhost:8085/controller/main"; // 특정 페이지로 이동
	        	
	        }
		}
	});
	
	new Vue({
	    el: '.status-overlay',
	    data() {
	        return {
	            sailStatus: '<%=String.valueOf(sailStatus)%>',
	            isAutopilotOn: true // 초기 상태: Autopilot이 켜져 있다고 가정
	        };
	    }, mounted () {
	    	
	    	this.checkSailStatus(); // 운항 상태 확인
	    	this.updateControlPanel(); // 초기 상태에 맞게 Control Panel 업데이트
	    },
	    methods: {
	    	toggleAutopilot() {
	            // autoSift-btn의 텍스트와 상태 변경
	            const btn = document.getElementById("autoSift-btn");
	            this.isAutopilotOn = !this.isAutopilotOn; // 상태 토글
	            btn.textContent = this.isAutopilotOn ? 'auto "on"' : 'auto "off"';

	            // 버튼의 opacity 상태 변경
	            btn.style.opacity = this.isAutopilotOn ? 1 : 0.7;

	            // Control Panel 업데이트
	            this.updateControlPanel();
	          },
	          updateControlPanel() {
	            // autopilot 상태에 따라 controlPanel 표시/숨기기
	            const controlPanel = document.getElementById("controlPanel");
	            controlPanel.style.display = this.isAutopilotOn ? "none" : "flex";
	          },
	          checkSailStatus() {
	            // const btn = document.getElementById("nowSail-btn");
	            const info = document.getElementById("info-overlay2");

	            console.log(this.sailStatus);
	            if (this.sailStatus === '1') {
	              //btn.style.opacity = 1;
	              //btn.style.boxShadow = '0 0 20px rgba(255, 0, 0, 0.7), 0 0 30px rgba(255, 0, 0, 0.5)';
	            } else {
	              //btn.style.opacity = 0.5;
	              //btn.style.boxShadow = 'none';
	              if (!info) {
	            	  console.warn("info overlay element not found.");
		              return;
		          }else{
		        	  info.style.display = 'none';
		          }
	            }
	          }
	        }
	      });

	<!-- 수동제어 관련 / 허재혁 -->

    var speed = 0; // 초기값
    var maxSpeed = 100;
    var minSpeed = 0;

    var degree = 90;  // 서보 모터 기본 각도
    var maxDegree = 180;
    var minDegree = 0;
    
    // 속도 ↑ ↓
    function move(direction) {
        if (direction === 'up') {
            speed += 10;
            if (speed > maxSpeed) {
                speed = maxSpeed;
            }
        } else if (direction === 'down') {
            speed -= 10;
            if (speed < minSpeed) {
                speed = minSpeed;
            }
        }

        // AJAX 요청으로 서버에 속도 값 전달
        fetch('/controller/updateSpeed', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ speed: speed })
        })
        .then(response => response.json())
        .then(data => {
            console.log('Speed updated on server:', data);
        })
        .catch(error => {
            console.error('Error updating speed:', error);
        });
    }
  
    // 방향타 ← →
    function moveServo(direction) {
        if (direction === 'left') {
            degree -= 10;
            if (degree < minDegree) {
                degree = minDegree;
            }
        } else if (direction === 'right') {
            degree += 10;
            if (degree > maxDegree) {
                degree = maxDegree;
            }
        }

        console.log('Sending degree to server:', degree);

        // AJAX 요청으로 서버에 각도 값 전달
        fetch('/controller/updateServoDegree', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ degree: degree })
        })
        .then(response => response.json())
        .then(data => {
            console.log('Degree updated on server:', data);
        })
        .catch(error => {
            console.error('Error updating degree:', error);
        });
    }
    
    // 모터 스탑 속도값 0
    function motorStop() {
       speed = 0;
       fetch('/controller/updateSpeed', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ speed: speed })
        })
        .then(response => response.json())
        .then(data => {
            console.log('Speed updated on server:', data);
        })
        .catch(error => {
            console.error('Error updating speed:', error);
        });
    }           
    
    // 서보 중앙고정 90도 값
    function servoReset() {
       degree = 90;
       fetch('/controller/updateServoDegree', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ degree: degree })
        })
        .then(response => response.json())
        .then(data => {
            console.log('Degree updated on server:', data);
        })
        .catch(error => {
            console.error('Error updating degree:', error);
        });
    }
    
    // 속도 조절 js
    $(function() {
        var maxVal = $('#speedRange1').attr('max'); // 슬라이더의 최대값을 가져옵니다.
        var rangePercent = $('#speedRange1').val();

        // 초기 버블 위치 설정
        var leftPosition = (rangePercent / maxVal) * 100 + '%';
        $('#h4-subcontainer h4').css('left', leftPosition);

        $('#speedRange1').on('input', function() {
            rangePercent = $('#speedRange1').val();
            $('#h4-subcontainer h4').html(rangePercent + '<span></span>');

            // hue-rotate 효과 (선택사항)
            $('#speedRange1, #h4-subcontainer h4 > span').css('filter', 'hue-rotate(-' + (rangePercent * 9) + 'deg)');

            // 버블 위치 계산
            var leftPosition = (rangePercent / maxVal) * 100 + '%';

            $('#h4-subcontainer h4').css({
                'transform': 'translateX(-50%) scale(' + (1 + (rangePercent / 100)) + ')',
                'left': leftPosition
            });
        });
    });
    
</script>

</body>
</html>