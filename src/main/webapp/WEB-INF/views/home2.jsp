<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page session="false" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>배경 패럴랙스 및 흐림 효과</title>
    <style>
        body {
            margin: 0;
            height: 2000vh; /* 스크롤 길이를 매우 길게 설정 */
            background: url('resources/img/pexels-pixelcop-1556991.jpg') repeat-y center top/cover;
            transition: filter 0.3s ease, background 0.3s ease;
            background-attachment: fixed; /* 패럴랙스 효과 */
        }

        .content {
            height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 2rem;
            position: relative;
            z-index: 1;
        }

        .section {
            height: 100vh;
        }
    </style>
</head>
<body>
    <div class="section">
        <div class="content">
            배경 패럴랙스 및 흐림 효과 테스트 1
        </div>
    </div>

    <div class="section">
        <div class="content">
            배경 패럴랙스 및 흐림 효과 테스트 2
        </div>
    </div>

    <script>
        window.addEventListener('scroll', function() {
            const scrollPosition = window.scrollY;
            const fadeOutStart = 500;  // 흐림 효과가 시작되는 스크롤 위치
            const fadeOutEnd = 5000;   // 흐림 효과가 끝나는 스크롤 위치

            // 스크롤 위치에 따라 blur 및 투명도(Opacity) 값 계산
            let blurAmount = Math.min((scrollPosition - fadeOutStart) / (fadeOutEnd - fadeOutStart) * 20, 20);
            blurAmount = Math.max(blurAmount, 0); // 최소 blur 값은 0으로 유지

            let opacityAmount = 1 - Math.min((scrollPosition - fadeOutStart) / (fadeOutEnd - fadeOutStart), 1);
            opacityAmount = Math.max(opacityAmount, 0); // 최소 투명도는 0으로 유지

            // blur 및 투명도 조절하여 자연스럽게 배경 흐려짐과 그라데이션 적용
            document.body.style.filter = `blur(${blurAmount}px)`;
        });
    </script>
</body>
</html>
