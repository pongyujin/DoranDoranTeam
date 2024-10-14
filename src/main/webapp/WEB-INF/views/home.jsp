<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>Vue.js with Google Maps</title>
    <script src="https://cdn.jsdelivr.net/npm/vue@2/dist/vue.js"></script>
    <!-- Google Maps API - Spring에서 전달된 API 키 사용 -->
    <script src="https://maps.googleapis.com/maps/api/js?key=AIzaSyDtt1tmfQ-lTeQaCimRBn2PQPTlCLRO6Pg"></script> 
    <style>
        /* 지도 위에 버튼을 위치시키기 위한 스타일 */
        #map {
            width: 100%;
            height: 500px;
        }
        .map-button {
            position: absolute;
            top: 20px;
            left: 200px;
            z-index: 1;  /* 지도 위에 버튼이 표시되도록 z-index 설정 */
            background-color: white;
            border: 2px solid #007bff;
            padding: 10px;
            cursor: pointer;
        }
    </style>
</head>
<body>
    <div id="app">
        <!-- 지도 영역 -->
        <div id="map"></div>

        <!-- 지도 위에 오버레이할 버튼 -->
        <div class="map-button" @click="handleButtonClick">Click Me</div>
    </div>

    <script>
        new Vue({
            el: '#app',
            mounted() {
                this.initMap();
            },
            methods: {
                initMap() {
                    var map = new google.maps.Map(document.getElementById('map'), {
                        center: { lat: 37.5665, lng: 126.9780 },  // 서울 좌표
                        zoom: 10
                    });
                },
                handleButtonClick() {
                    alert('Button clicked!');
                }
            }
        });
    </script>
</body>
</html>
