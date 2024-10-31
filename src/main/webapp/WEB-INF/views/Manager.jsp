<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>관리자 페이지</title>
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
    
    <!-- SweetAlert2 CSS 및 JS -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.min.css">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

    <style>
        /* 스타일 설정 */
        body {
            font-family: Arial, sans-serif;
            background-color: #1A2529;
            margin: 0;
            padding: 0;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            color: white;
        }
        .manager-page {
            background-color: #17293A;
            padding: 50px;
            border-radius: 10px;
            box-shadow: 0 8px 16px rgba(0, 0, 0, 0.3);
            text-align: center;
            width: 90vw;
            height: 90vh;
            overflow-y: auto;
        }
        h1 {
            margin-bottom: 40px;
            font-size: 28px;
        }
        table {
            width: 100%;
            border-collapse: collapse;
        }
        th, td {
            padding: 16px 20px;
            text-align: center;
            border-bottom: 1px solid #313F49;
        }
        th {
            background-color: #1C2933;
            color: white;
            font-weight: normal;
            font-size: 16px;
        }
        tr:nth-child(even) {
            background-color: #1F2D3A;
        }
        tr:hover {
            background-color: #313F49;
        }
        .button-group {
            display: inline-flex;
            gap: 10px;
            justify-content: center;
        }
        .approve-btn, .reject-btn {
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 5px;
            cursor: pointer;
            font-size: 16px;
        }
        .approve-btn { background-color: #5A77F9; }
        .approve-btn:hover { background-color: #4763C8; }
        .reject-btn { background-color: #F95A5A; }
        .reject-btn:hover { background-color: #D44A4A; }
    </style>
</head>
<body>

<script>
// 승인 안된 선박 리스트 불러오기
$(document).ready(function() {
    $.ajax({
        url: "/controller/AllShipList",
        method: "GET",
        success: function(data) {
            let tbody = $("#shipListBody");
            tbody.empty();

            for (let i = 0; i < data.length; i++) {
                let ship = data[i];
                let row = 
                    "<tr>" +
                        "<td>" + (ship.memId ? ship.memId : 'N/A') + "</td>" +
                        "<td>" + (ship.siCode ? ship.siCode : 'N/A') + "</td>" +
                        "<td>" + (ship.siDocs ? "<a href='" + ship.siDocs + "' download>파일 다운로드</a>" : "파일 없음") + "</td>" +
                        "<td>" +
                            "<div class='button-group'>" +
                                "<button class='approve-btn' onclick='approveShip(\"" + ship.siCode + "\", \"" + ship.memId + "\")'>승인</button>" +
                                "<button class='reject-btn' onclick='rejectShip(\"" + ship.siCode + "\", \"" + ship.memId + "\")'>거절</button>" +
                            "</div>" +
                        "</td>" +
                    "</tr>";
                tbody.append(row);
            }
        },
        error: function(err) {
            Swal.fire({
                icon: 'error',
                title: '오류',
                text: '선박 리스트를 불러오는 중 오류가 발생했습니다.'
            });
        }
    });
});

// 선박 승인 요청 함수
function approveShip(siCode, memId) {
    $.ajax({
        url: "/controller/update?siCode=" + siCode + "&memId=" + memId,
        method: "PUT",
        success: function(response) {
            Swal.fire({
                icon: 'success',
                title: '승인 완료',
                text: '선박이 승인되었습니다.'
            }).then(() => {
                location.reload();
            });
        },
        error: function(err) {
            Swal.fire({
                icon: 'error',
                title: '승인 실패',
                text: '선박 승인에 실패했습니다.'
            });
        }
    });
}

//선박 거절 요청 함수
function rejectShip(siCode, memId) {
    Swal.fire({
        title: '거절 사유 입력',
        input: 'textarea',
        inputPlaceholder: '거절 사유를 입력하세요...',
        showCancelButton: true,
        confirmButtonText: '거절',
        cancelButtonText: '취소',
    }).then((result) => {
        if (result.isConfirmed) {
            const reason = result.value;

            // 요청 데이터 확인
            const requestData = { siCode: siCode, memId: memId, siCert: '2', siCertReason: reason };
            console.log("전송 데이터:", requestData);
            
            $.ajax({
                url: "/controller/reject",
                method: "PUT",
                contentType: "application/json",
                data: JSON.stringify(requestData), // 거절 코드와 사유 전송
                success: function(response) {
                    console.log("응답 데이터:", response);
                    Swal.fire({
                        icon: 'success',
                        title: '거절 완료',
                        text: '선박이 거절되었습니다.'
                    }).then(() => {
                        location.reload();
                    });
                },
                error: function(err) {
                    console.error("에러 응답:", err);
                    Swal.fire({
                        icon: 'error',
                        title: '거절 실패',
                        text: '선박 거절에 실패했습니다.'
                    });
                }
            });
        }
    });
}

</script>

<div class="manager-page">
    <h1>관리자 페이지</h1>
    <table>
        <thead>
            <tr>
                <th>사용자 ID</th>
                <th>선박 ID</th>
                <th>파일</th>
                <th>승인 / 거절</th>
            </tr>
        </thead>
        <tbody id="shipListBody">
            <!-- AJAX로 불러온 선박 리스트가 여기에 추가됩니다 -->
        </tbody>
    </table>
</div>

</body>
</html>
