<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Ship Statistics with Vue.js</title>
<script src="https://cdn.jsdelivr.net/npm/vue@2"></script>
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

<style>
@keyframes slide-top {
  0% {
    transform: translateY(-100%); /* 화면 위에서 시작 */
  }
  100% {
    transform: translateY(0); /* 원래 위치로 슬라이드 */
  }
}

body, html {
	margin: 0;
	padding: 0;
	height: 100%;
	overflow-x: hidden;
	font-family: 'Roboto Slab', serif;
	background: linear-gradient(to bottom, rgba(4, 27, 35, 1) 0%,
		rgba(4, 27, 35, 0.5) 50%, rgba(4, 27, 35, 0) 100%);
}

.top-bar {
	display: flex;
	align-items: center;
	padding: 10px;
	background-color: rgba(4, 27, 35, 0.8);
}

.close-btn {
	position: relative;
	width: 30px;
	height: 30px;
	border-radius: 50%;
	background-color: red;
	margin-left: 10px;
	cursor: pointer;
}

.close-btn::before, .close-btn::after {
	content: '';
	position: absolute;
	top: 50%;
	left: 50%;
	width: 20px;
	height: 3px;
	background-color: white;
	transform-origin: center;
}

.close-btn::before {
	transform: translate(-50%, -50%) rotate(45deg);
}

.close-btn::after {
	transform: translate(-50%, -50%) rotate(-45deg);
}

.container {
	display: flex;
	flex-direction: column;
	align-items: center;
	justify-content: center;
	width: 100%;
}

.row {
	display: flex;
	justify-content: space-around;
	width: 80%;
	margin-bottom: 20px;
}

.box {
	width: 40%; /* 박스의 너비를 40%로 유지 */
	background-color: rgba(255, 255, 255, 0.1);
	border: 1px solid rgba(255, 255, 255, 0.2);
	border-radius: 8px;
	padding: 20px;
	box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
	position: relative; /* 자식 요소들이 차트 박스 안에서 정렬되도록 함 */
	height: 400px; /* 고정 높이 */
  /* 애니메이션 적용 */
  animation: slide-top 0.5s ease-in-out forwards;
}


.chart-box {
	width: 100%; /* 차트가 박스 너비에 맞게 채워지도록 함 */
	height: 100%; /* 차트가 박스 높이에 맞게 채워지도록 함 */
	position: relative;
}

#map-container {
	position: relative; /* 지도 컨테이너 안에 절대 위치 요소가 올 수 있도록 설정 */
	height: 400px;
}

#map {
	height: 100%;
	width: 100%;
}

#image-container {
	height: 400px;
	display: flex;
	flex-direction: column; /* 이미지가 세로로 쌓이도록 설정 */
	justify-content: center;
	align-items: center;
	overflow-y: scroll; /* 세로 스크롤 활성화 */
	background-color: rgba(255, 255, 255, 0.1);
	border: 1px solid rgba(255, 255, 255, 0.2);
	border-radius: 8px;
	box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
}

#image-container img {
	max-width: 100%;
	height: auto;
	margin-bottom: 10px; /* 이미지 간 간격 추가 */
}

.distance-label {
	background-color: white;
	padding: 10px;
	border: 1px solid black;
	border-radius: 5px;
	position: absolute; /* 지도 컨테이너를 기준으로 절대 위치 설정 */
	bottom: 20px; /* 지도 하단에서 20px 위로 */
	right: 20px; /* 지도 오른쪽에서 20px 떨어진 위치 */
	font-weight: bold;
	font-size: 16px;
	z-index: 10; /* 지도 위에 나타나도록 z-index 설정 */
}

#simple-form {
	margin-top: 20px;
	padding: 10px;
	background-color: rgba(255, 255, 255, 0.1);
	border: 1px solid rgba(255, 255, 255, 0.2);
	border-radius: 8px;
	width: 300px;
	text-align: center;
}
</style>


</head>
<script loading="async" defer
	src="https://maps.googleapis.com/maps/api/js?key=AIzaSyDtt1tmfQ-lTeQaCimRBn2PQPTlCLRO6Pg&callback=initMap&libraries=geometry"></script>
<div class="top-bar">
	<div class="close-btn"></div>
</div>

<div id="app">
	<div class="container">
		<!-- 첫 번째 줄: 지도와 첫 번째 차트 -->
		<div class="row">
			<!-- 지도 -->
			<div class="box">
				<div id="map-container">
					<div id="map"></div>
					<div v-if="totalDistanceKm" class="distance-label">총 경로 거리:
						{{ totalDistanceKm }} km</div>
				</div>
			</div>
			<!-- 첫 번째 차트 -->
			<div class="box">
				<div class="chart-box">
					<canvas id="weatherChart"></canvas>
				</div>
			</div>
		</div>

		<!-- 두 번째 줄: 두 번째 차트와 이미지 -->
		<div class="row">
			<!-- 두 번째 차트 -->
			<div class="box">
				<div class="chart-box">
					<canvas id="waveBatteryChart"></canvas>
				</div>
			</div>
			<!-- 이미지 -->
			<div class="box">
				<div id="image-container">
					<h3>장애물 이미지</h3>
					<div v-for="(url, index) in imageUrls" :key="index">
						<img :src="url" alt="선박 이미지"
							style="max-width: 100%; height: auto;">
					</div>
				</div>
			</div>
		</div>

	</div>
</div>


<script>
  // Vue 인스턴스 생성
  new Vue({
    el: '#app',
    data: {
      siCode: '', // URL로부터 가져올 siCode
      sailNum: '', // 추후에 사용 가능
      totalDistanceKm: '', // 총 경로 거리 저장
      map: null, // Google Map 객체 저장
      weatherList: [], // 날씨 정보 목록 저장
      imageUrls: [] // 서버에서 가져온 이미지 URL 목록 저장
    },
    methods: {
      initMap() {
        this.map = new google.maps.Map(document.getElementById("map"), {
          center: { lat: 33.5097, lng: 126.5219 },
          zoom: 7
        });
      },
      // URL에서 siCode 파라미터를 추출
      getSiCodeFromURL() {
        const urlParams = new URLSearchParams(window.location.search);
        this.siCode = urlParams.get('siCode'); // URL에서 siCode 추출
      },
      // 선박 경로를 지도에 그리는 함수
      drawRoute(routeData) {
        const routeCoordinates = [];
        let totalDistance = 0;

        for (let i = 0; i < routeData.length; i++) {
          const { gpsLat, gpsLng } = routeData[i];
          const position = { lat: gpsLat, lng: gpsLng };
          routeCoordinates.push(position);

          if (i > 0) {
            const prevPos = routeCoordinates[i - 1];
            const distance = google.maps.geometry.spherical.computeDistanceBetween(
              new google.maps.LatLng(prevPos.lat, prevPos.lng),
              new google.maps.LatLng(gpsLat, gpsLng)
            );
            totalDistance += distance;
          }
        }

        const routePath = new google.maps.Polyline({
          path: routeCoordinates,
          geodesic: true,
          strokeColor: '#FF0000',
          strokeOpacity: 1.0,
          strokeWeight: 2
        });

        routePath.setMap(this.map);
        this.totalDistanceKm = (totalDistance / 1000).toFixed(2); // 총 경로 거리
      },
      // 서버로부터 선박 통계와 경로 데이터를 가져오는 함수
      loadShipStats() {
        const siCode = this.siCode; // URL에서 받은 siCode 사용

        fetch('statistics/' + siCode + '/sailNum') // sailNum은 서버 측에서 필요한 값을 채워야 할 수 있음
          .then(response => response.json())
          .then(data => {
            const route = data.gpsList;
            const weather = data.weatherList;

            this.drawRoute(route);
            this.weatherList = weather;
            this.drawWeatherChart();
            this.drawWaveBatteryChart();

            return fetch('http://192.168.219.101:8085/controller/statistics/getImage?siCode=' + siCode + '&sailNum=sailNum');
          })
          .then(response => response.json())
          .then(data => {
            if (data && Array.isArray(data)) {
              this.imageUrls = data.map(camera => 'http://192.168.219.101:8085' + camera.obsImg);
            } else {
              this.imageUrls = [];
              console.error("이미지 정보가 없습니다.");
            }
          })
          .catch(error => {
            console.error("Error:", error);
          });
      },
      // 날씨와 배터리 상태를 차트로 그리는 함수
      drawWeatherChart() {
        const ctx = document.getElementById('weatherChart').getContext('2d');
        const labels = this.weatherList.map(item => item.wtime);
        const temps = this.weatherList.map(item => parseFloat(item.wtemp));
        const batteryLevels = this.weatherList.map(item => parseFloat(item.statBattery));

        new Chart(ctx, {
          type: 'line',
          data: {
            labels: labels,
            datasets: [
              {
                label: 'Temperature (°C)',
                data: temps,
                borderColor: 'rgba(255, 99, 132, 1)',
                fill: true,
              },
              {
                label: 'Battery Level (%)',
                data: batteryLevels,
                borderColor: 'rgba(54, 162, 235, 1)',
                fill: false,
              }
            ]
          },
          options: {
            responsive: true,
            maintainAspectRatio: false,
            title: {
              display: true,
              text: 'Weather and Battery Level Over Time',
              fontColor: 'white',
            },
            scales: {
              x: {
                display: true,
                title: {
                  display: true,
                  text: 'Time',
                  color: 'white',
                },
                ticks: {
                  color: 'white',
                },
                grid: {
                  color: 'rgba(255, 255, 255, 0.2)',
                }
              },
              y: {
                display: true,
                title: {
                  display: true,
                  text: 'Values',
                  color: 'white',
                },
                ticks: {
                  color: 'white',
                },
                grid: {
                  color: 'rgba(255, 255, 255, 0.2)',
                },
                min: 20,
                max: 100,
              }
            }
          }
        });
      },
      drawWaveBatteryChart() {
        const ctx = document.getElementById('waveBatteryChart').getContext('2d');
        const labels = this.weatherList.map(item => item.wtime);
        const waveHeights = this.weatherList.map(item => parseFloat(item.wwaveHeight));
        const batteryLevels = this.weatherList.map(item => parseFloat(item.statBattery));

        new Chart(ctx, {
          type: 'line',
          data: {
            labels: labels,
            datasets: [
              {
                label: 'Wave Height (m)',
                data: waveHeights,
                borderColor: 'rgba(75, 192, 192, 1)',
                fill: false,
              },
              {
                label: 'Battery Level (%)',
                data: batteryLevels,
                borderColor: 'rgba(153, 102, 255, 1)',
                fill: false,
              }
            ]
          },
          options: {
            responsive: true,
            maintainAspectRatio: false,
            title: {
              display: true,
              text: 'Weather and Battery Level Over Time',
              fontColor: 'white'
            },
            scales: {
              x: {
                display: true,
                title: {
                  display: true,
                  text: 'Time',
                  color: 'white'
                },
                ticks: {
                  color: 'white'
                },
                grid: {
                  color: 'rgba(255, 255, 255, 0.2)'
                }
              },
              y: {
                display: true,
                title: {
                  display: true,
                  text: 'Values',
                  color: 'white'
                },
                ticks: {
                  color: 'white'
                },
                grid: {
                  color: 'rgba(255, 255, 255, 0.2)'
                }
              }
            }
          }
        });
      }
    },
    mounted() {
      this.getSiCodeFromURL(); // URL에서 siCode 가져오기
      this.loadShipStats(); // siCode로 데이터를 로드
      window.initMap = this.initMap; // Vue의 this.initMap을 전역으로 설정
    }
  });
</script>


</body>
</html>
