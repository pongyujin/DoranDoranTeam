// modal.js 파일로 이동할 스크립트
console.log("modal.js 파일이 로드되었습니다.");

// Member - 1. 아이디 중복 체크
function registerCheck() {
	var memId = $("#memIdJoin").val();
	console.log(memId);
	$.ajax({
		url: "registerCheck",
		type: "get",
		data: { "memId": memId },
		success: function(data) {
			if (data == 0) {
				$("#checkMessage").text("사용 불가능한 아이디 입니다.");
				$("#messageType").attr("class", "modal-content panel-danger");
			} else {
				$("#checkMessage").text("사용 가능한 아이디 입니다.");
				$("#messageType").attr("class", "modal-content panel-success");
			}
		},
		error: function() {
			console.log("error");
		}
	});
	// 모달창 띄우기
	$("#myModal").modal("show");
}

// Member - 2. 비밀번호 확인
function passwordCheck() {
	var pw1 = $("#memPw").val();
	var pw2 = $("#memPw2").val();
	if (pw1 == pw2) {
		$(".passMessage").attr("style", "color:green; vertical-align:middle; margin-top:10px;");
		$("#memPwJoin").attr("value", pw1);
		$(".passMessage").text("비밀 번호가 일치합니다");
	} else {
		$(".passMessage").attr("style", "color:#ff5656; vertical-align:middle; margin-top:10px;");
		$(".passMessage").text("비밀 번호가 일치하지 않습니다");
	}
}

// Ship - 3. 모달을 열 때 선박 리스트 로드
function loadShipList() {

	$.ajax({
		url: 'shipList',
		type: 'GET',
		dataType: 'json', // 서버로부터 받는 데이터의 형식
		success: function(data) {
			console.log("선박리스트 데이터 : " + data);
			const shipListElement = document.getElementById('shipList');
			shipListElement.innerHTML = ''; // 기존 리스트 초기화

			data.forEach(function(ship) {
				const listItem = document.createElement('li');
				listItem.innerHTML = `
                    <p>선박번호: ${ship.siCode}</p>
                    <p>선박명: ${ship.siName}</p>
                    <button onclick="openGroupInfo('${ship.siCode}')">그룹 정보</button>
                    <button onclick="goToControllerPage('${ship.siCode}')">관제 화면</button>
  					<button onclick="loadSailList('${ship.siCode}')">항해 리스트</button>
                `;
				shipListElement.appendChild(listItem);
			});
		},
		error: function(xhr, status, error) {
			console.error('Error fetching ship list:', error);
		}
	});
}

// Ship - 3. 모달을 열 때 항해 리스트 로드
function loadSailList(siCode) {
    // siCode가 정상적으로 전달되었는지 콘솔에서 확인
    console.log("전달된 siCode: ", siCode);

    $.ajax({
		// 이거 sailController 변경해야함 
        url: '/controller/sail/all',  // 서버의 API 경로
        type: 'GET',
        data: { siCode: siCode },  // siCode 전달
        dataType: 'json',
        success: function(data) {
            console.log("항해 리스트 데이터:", data);
            const sailListElement = document.getElementById('sailList');
            sailListElement.innerHTML = ''; // 기존 리스트 초기화

            data.forEach(function(sail) {
                const listItem = document.createElement('li');
                listItem.innerHTML = `
                    <p>선박번호 (siCode): ${sail.siCode}</p>
                    <p>등록일자: ${sail.registeredDate}</p>
                    <p>운항상태: ${sail.status}</p>
                    <p>코멘트: ${sail.comment}</p>
                `;
                sailListElement.appendChild(listItem);
            });

            // 모달을 화면에 표시
            document.getElementById("sailListModal").style.display = "block";
        },
        error: function(xhr, status, error) {
            console.error('항해 리스트를 가져오는 중 오류 발생:', error);
        }
    });
}

// 모달 닫기 기능
document.getElementById('closeSailListModal').onclick = function() {
    document.getElementById('sailListModal').style.display = 'none';
};


// 통계 페이지 이동
function goToStatisticsPage(siCode) {
    window.location.href = `/controller/statistics?siCode=${siCode}`;  // 권한 확인 없이 바로 이동
}

// 관제 페이지 이동
function goToControllerPage(siCode) {
    
    $.ajax({
        url: '/controller/setShipSession', 
        type: 'POST',
        contentType: 'application/json', // JSON 형식으로 전송
        data: JSON.stringify({ siCode: siCode }), // JSON 형태로 변환하여 전송
        success: function(response) {
            console.log('Success:', response);

            window.location.href = `/controller/map2`;
        },
        error: function(jqXHR, textStatus, errorThrown) {
            console.error('Error:', textStatus, errorThrown); 
        }
    });
}


// ------------------------------------- shipgroup 가져오기 



// 그룹 정보를 로드하고 siCode 설정
function loadGroupInfo(siCode) {
    selectedSiCode = siCode;  // 선택된 siCode를 전역 변수에 저장
    console.log("선택된 선박 코드: ", selectedSiCode);

    // AJAX 요청을 통해 그룹 멤버 리스트 불러오기
    $.ajax({
        url: 'grouplist',  // 서버 API 경로
        type: 'GET',
        data: { siCode: siCode },  // 선택된 선박의 siCode 전달
        dataType: 'json',
        success: function(data) {
            const userListElement = document.querySelector('.user-list');
            userListElement.innerHTML = '';  // 기존 리스트 초기화

            // 그룹 멤버 리스트 동적으로 추가
            data.forEach(function(member) {
                const listItem = document.createElement('li');
                listItem.innerHTML = `
                    <span>${member.memId}</span>
                    <select onchange="updateMemberRole('${member.memId}', this.value)">
                        <option value="1" ${member.authNum == 1 ? 'selected' : ''}>VIEWER</option>
                        <option value="2" ${member.authNum == 2 ? 'selected' : ''}>CONTROLLER</option>
                        <option value="3" ${member.authNum == 3 ? 'selected' : ''}>EDITOR</option>
                        <option value="0" ${member.authNum == 0 ? 'selected' : ''}>ADMIN</option>
                    </select>
                    <button onclick="deleteMember('${member.memId}')">삭제</button>
                `;
                userListElement.appendChild(listItem);
            });
        },
        error: function(xhr, status, error) {
            console.error('그룹 리스트 불러오기 실패:', error);
        }
    });
}


function inviteMember() {
    if (!selectedSiCode) {
        alert('선박이 선택되지 않았습니다.');
        return;
    }

    var memberId = document.getElementById('invitememID').value;  // 초대할 사용자 ID 또는 이메일
    var authNum = parseInt(document.querySelector('.invite-section select').value, 10);  // 선택된 권한 번호를 정수로 변환

    console.log("초대할 사용자 ID:", memberId);
    console.log("선택된 권한 번호 (전송 전):", authNum);
    console.log("초대할 선박 코드:", selectedSiCode);

    if (!memberId) {
        alert('초대할 사용자 ID 또는 이메일을 입력해주세요.');
        return;
    }

    // 소유자 여부 확인
    $.ajax({
        url: 'checkOwnership',
        type: 'POST',
        contentType: 'application/json',
        data: JSON.stringify({ siCode: selectedSiCode }),
        success: function(isOwner) {
            console.log("소유자 여부:", isOwner);

            // 여기에서 authNum을 변경하지 않고 그대로 유지
            // 소유자인 경우에도 authNum을 변경하지 않음
            console.log("최종 전송 권한 번호:", authNum);

            // 초대 요청
            $.ajax({
                url: 'groupinvite',
                type: 'POST',
                contentType: 'application/json',
                data: JSON.stringify({
                    memId: memberId,
                    siCode: selectedSiCode,
                    authNum: authNum  // 선택된 권한 번호 그대로 전송
                }),
                success: function(response) {
                    console.log('초대 성공:');
                    alert('초대 성공:');  // 서버에서 반환된 메시지를 출력
                    loadGroupInfo(selectedSiCode);  // 그룹 정보를 다시 로드
                },
                error: function(xhr, status, error) {
                    if (xhr.status === 409) {
                        alert('해당 사용자는 이미 그룹에 속해 있습니다.');
                    } else {
                        console.error('초대 실패:');
                        alert('사용자가 없습니다.');
                    }
                }
            });
        },
        error: function(xhr, status, error) {
            console.error('소유자 확인 실패:', error);
            alert('소유자 확인 실패');
        }
    });
}


// 권한 수정 메서드
function updateMemberRole(memberId, newRole) {
    if (!selectedSiCode) {
        alert('선박이 선택되지 않았습니다.');
        return;
    }

    // 권한 수정 요청
    $.ajax({
        url: 'groupupdate',
        type: 'PUT',
        contentType: 'application/json',
        data: JSON.stringify({
            memId: memberId,
            siCode: selectedSiCode,
            authNum: newRole  // 새로 선택된 권한 번호
        }),
        success: function(response) {
            alert('권한이 성공적으로 수정되었습니다.');
            loadGroupInfo(selectedSiCode);  // 수정 후 그룹 정보 다시 로드
        },
        error: function(xhr, status, error) {
            console.error('권한 수정 실패:', error);
            alert('권한 수정 실패');
        }
    });
}

// 그룹 삭제 메서드
function deleteMember(memberId) {
    if (!selectedSiCode) {
        alert('선박이 선택되지 않았습니다.');
        return;
    }

    // 사용자 삭제 요청
    $.ajax({
        url: 'groupdelete',
        type: 'DELETE',
        contentType: 'application/json',
        data: JSON.stringify({
            memId: memberId,
            siCode: selectedSiCode
        }),
        success: function(response) {
            alert('사용자가 성공적으로 삭제되었습니다.');
            loadGroupInfo(selectedSiCode);  // 삭제 후 그룹 정보 다시 로드
        },
        error: function(xhr, status, error) {
            console.error('사용자 삭제 실패:', error);
            alert('사용자 삭제 실패');
        }
    });
}

