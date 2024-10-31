// modal.js 파일로 이동할 스크립트
console.log("modal.js 파일이 로드되었습니다.");

// 모달 이동을 위한 변수
var isDragging = false;
var offsetX = 0;
var offsetY = 0;

// 모든 모달 헤더에 대해 이벤트 리스너를 추가합니다.
$(document).ready(function() {
    $('.modal-header').on('mousedown', function(e) {
        var $modal = $(this).closest('.modal');
        isDragging = true;
        offsetX = e.clientX - $modal.offset().left;
        offsetY = e.clientY - $modal.offset().top;

        // 드래그 중인 상태를 나타내는 클래스 추가
        $(this).addClass('dragging');

        // 마우스 이동 이벤트 바인딩
        $(document).on('mousemove.modalDrag', function(e) {
            if (isDragging) {
                $modal.offset({
                    top: e.clientY - offsetY,
                    left: e.clientX - offsetX
                });
            }
        });

        // 마우스 업 이벤트 바인딩
        $(document).on('mouseup.modalDrag', function() {
            isDragging = false;

            // 드래그 중인 상태 클래스를 제거
            $('.modal-header').removeClass('dragging');

            // 이벤트 언바인딩
            $(document).off('mousemove.modalDrag mouseup.modalDrag');
        });
    });
});

// 모달 드래그 기능
function makeModalDraggable(modalId, headerId) {
    const modal = document.getElementById(modalId);
    const header = document.getElementById(headerId);

    if (!modal) {
        console.error("Modal not found with ID:", modalId);
        return;
    }
    if (!header) {
        console.error("Header not found with ID:", headerId);
        return;
    }

    let posX = 0, posY = 0, mouseX = 0, mouseY = 0;

    header.onmousedown = dragMouseDown;

    function dragMouseDown(e) {
        e = e || window.event;
        e.preventDefault();
        // 마우스 초기 위치 저장
        mouseX = e.clientX;
        mouseY = e.clientY;
        document.onmouseup = closeDragElement;
        document.onmousemove = elementDrag;
    }

    function elementDrag(e) {
        e = e || window.event;
        e.preventDefault();
        // 커서가 이동한 거리 계산
        posX = mouseX - e.clientX;
        posY = mouseY - e.clientY;
        mouseX = e.clientX;
        mouseY = e.clientY;
        // 모달 창의 위치 조정
        modal.style.top = (modal.offsetTop - posY) + "px";
        modal.style.left = (modal.offsetLeft - posX) + "px";
    }

    function closeDragElement() {
        // 이벤트 리스너 제거
        document.onmouseup = null;
        document.onmousemove = null;
    }
}

// 모달 리사이즈 기능
function makeModalResizable(modalId) {
    const modal = document.getElementById(modalId);
    const resizeHandle = modal.querySelector('.resize-handle');

    if (!modal) {
        console.error("Modal not found with ID:", modalId);
        return;
    }
    if (!resizeHandle) {
        console.error("Resize handle not found in modal:", modalId);
        return;
    }

    resizeHandle.addEventListener('mousedown', initResize, false);

    function initResize(e) {
        e.preventDefault();
        window.addEventListener('mousemove', Resize, false);
        window.addEventListener('mouseup', stopResize, false);
    }

    function Resize(e) {
        const minWidth = 300;
        const minHeight = 200;
        const maxWidth = window.innerWidth - modal.offsetLeft;
        const maxHeight = window.innerHeight - modal.offsetTop;

        let newWidth = e.clientX - modal.offsetLeft;
        let newHeight = e.clientY - modal.offsetTop;

        newWidth = Math.max(minWidth, Math.min(newWidth, maxWidth));
        newHeight = Math.max(minHeight, Math.min(newHeight, maxHeight));

        modal.style.width = newWidth + 'px';
        modal.style.height = newHeight + 'px';
    }

    function stopResize(e) {
        window.removeEventListener('mousemove', Resize, false);
        window.removeEventListener('mouseup', stopResize, false);
    }
}

// 모든 모달 창에 적용
document.addEventListener('DOMContentLoaded', function() {
    makeModalDraggable("joinModal", "joinModalHeader");
    makeModalDraggable("loginModal", "loginModalHeader");
    makeModalDraggable("shipRegisterModal", "shipRegisterModalHeader");
    makeModalDraggable("editModal", "editModalHeader");
    makeModalDraggable("listModal", "listModalHeader");
    makeModalDraggable("rejectModal", "rejectModalHeader");
    makeModalDraggable("groupInfoModal", "groupInfoModalHeader");
    makeModalDraggable("sailListModal", "sailListModalHeader");

    makeModalResizable("joinModal");
    makeModalResizable("loginModal");
    makeModalResizable("shipRegisterModal");
    makeModalResizable("editModal");
    makeModalResizable("listModal");
    makeModalResizable("rejectModal");
    makeModalResizable("groupInfoModal");
    makeModalResizable("sailListModal");
});

// 그 외의 기존 코드들은 그대로 유지


// Member - 1. 아이디 중복 체크


// Member - 1. 아이디 중복 체크
var isIdAvailable = false; // 아이디 사용 가능 여부를 저장하는 변수

function registerCheck() {
    var memId = $("#memIdJoin").val();
    console.log(memId);
    $.ajax({
        url: "registerCheck",
        type: "get",
        data: { "memId": memId },
        success: function(data) {
            if (data == 0) {
                // 사용 불가능한 아이디
                $("#memIdJoin").removeClass("input-success").addClass("input-error");
                isIdAvailable = false;
            } else {
                // 사용 가능한 아이디
                $("#memIdJoin").removeClass("input-error").addClass("input-success");
                isIdAvailable = true;
            }
            toggleJoinButton();
        },
        error: function() {
            console.log("error");
        }
    });
}

// 아이디 입력 필드 변경 시 스타일 초기화
$(document).ready(function() {
    $("#memIdJoin").on('input', function() {
        $("#memIdJoin").removeClass("input-success input-error");
        isIdAvailable = false;
        toggleJoinButton();
    });
});


// Member - 2. 비밀번호 확인
function passwordCheck() {
    var pw1 = $("#memPw").val();
    var pw2 = $("#memPw2").val();
    if (pw1 === pw2 && pw1 !== "") {
        // 비밀번호가 일치할 때
        $(".passMessage").css({ "color": "green", "vertical-align": "middle", "margin-top": "10px" });
        $(".passMessage").text("비밀 번호가 일치합니다");
        $("#memPw, #memPw2").removeClass("input-error").addClass("input-success");
    } else {
        // 비밀번호가 일치하지 않을 때
        $(".passMessage").css({ "color": "#ff5656", "vertical-align": "middle", "margin-top": "10px" });
        $(".passMessage").text("비밀 번호가 일치하지 않습니다");
        $("#memPw, #memPw2").removeClass("input-success").addClass("input-error");
    }
}

// 비밀번호 입력 필드 변경 시 스타일 초기화
$(document).ready(function() {
    $("#memPw, #memPw2").on('input', function() {
        $("#memPw, #memPw2").removeClass("input-success input-error");
        $(".passMessage").text("");
    });
});


// 4. 비밀번호 검사
function validateForm() {
   // 현재 비밀번호를 세션에서 가져온 값으로 설정
   const currentPassword = `${sessionScope.user.memPw}`; // 세션의 현재 비밀번호
   var pwCheckValue = $("#pwCheck").val();

   // 현재 비밀번호 확인
   if (pwCheckValue !== currentPassword) {
      alert("기존 비밀번호를 올바르게 작성해주세요.");
      return false; // 폼 제출 방지
   }

   return true; // 폼 제출 허용
}
// Ship - 3. 모달을 열 때 선박 리스트 로드
function loadShipList() {
   $.ajax({
      url: 'shipList',
      type: 'GET',
      dataType: 'json', // 서버로부터 받는 데이터의 형식
      success: function(data) {
         console.log("선박리스트 데이터:", data);
         const shipListElement = document.getElementById('shipList');
         const rejectReasonListElement = document.getElementById('rejectReasonList');

         // 기존 리스트 초기화
         shipListElement.innerHTML = '';
         rejectReasonListElement.innerHTML = '';

         let siCertCount = 0; // siCert가 2인 선박의 개수

         data.forEach(function(ship) {
            // siCert 값이 2인 경우 거절 모달 리스트에 추가
            if (ship.siCert === '2') {
               siCertCount++;

               // 거절된 선박 정보 및 재신청 버튼 추가
               const rejectListItem = document.createElement('li');
               rejectListItem.innerHTML = `
                        <p>선박번호: ${ship.siCode}</p>
                        <p>선박명: ${ship.siName}</p>
                        <p>거절 사유: ${ship.siCertReason || '사유가 없습니다.'}</p>
                        <div class="button-container">
                            <button class="reapply-btn" onclick="reapply('${ship.siCode}','${ship.siName}')">재신청</button>
                        </div>
                    `;
               rejectReasonListElement.appendChild(rejectListItem);
            }

            // siCert 값이 1인 선박만 메인 리스트에 표시
            if (ship.siCert === '1') {
               const listItem = document.createElement('li');
               listItem.classList.add('ship-info-row'); // 스타일 적용을 위해 클래스 추가
               listItem.innerHTML = `
                        <div class="ship-details">
                            <p>선박번호: ${ship.siCode}</p>
                            <p>선박명: ${ship.siName}</p>
                        </div>
                        <div class="button-container">
                            <button onclick="openGroupInfo('${ship.siCode}')">그룹 정보</button>
                            <button onclick="goToControllerPage('${ship.siCode}')">관제 화면</button>
                            <button onclick="loadSailList('${ship.siCode}')">항해 리스트</button>
                        </div>
                    `;
               shipListElement.appendChild(listItem);
            }
         });

         // siCert가 2인 선박이 있을 때만 알림 아이콘 표시 및 개수 업데이트
         const alertIcon = document.getElementById('alertIcon');
         if (siCertCount > 0) {
            alertIcon.style.display = 'flex';
            document.querySelector('.notification-count').textContent = siCertCount; // siCert가 2인 개수 표시
         } else {
            alertIcon.style.display = 'none';
         }
      },
      error: function(xhr, status, error) {
         console.error('Error fetching ship list:', error);
      }
   });
}


// 재신청 버튼 클릭 시 호출되는 함수
function reapply(siCode, siName) {
   // 기존의 선박등록 거절 모달을 닫기
   document.getElementById("rejectModal").style.display = "none";

   // Ship ID와 Ship Name을 입력 필드에 직접 설정
   document.getElementById("siCode").value = siCode;
   document.getElementById("siName").value = siName;

   // Ship ID는 readonly로 설정하여 수정 불가
   document.getElementById("siCode").setAttribute("readonly", true);

   // 재신청 시 form action을 "shipReapply"로 설정
   document.querySelector("#shipRegisterModal form").setAttribute("action", "shipReapply");

   // 파일 선택 초기화 및 파일명 표시 초기화
   document.getElementById("siDocsFile").value = ""; // 기존 파일 제거
   document.getElementById("fileName").textContent = "파일이 선택되지 않았습니다";

   // submit 버튼 텍스트를 "재신청"으로 설정
   document.querySelector("#shipRegisterModal .register-button").textContent = "재신청";

   // shipRegisterModal 모달 표시
   document.getElementById("shipRegisterModal").style.display = "block";
}




//선박리스트의 벨아이콘 누르면 선박등록거부 모달창 뜨는거
document.addEventListener('DOMContentLoaded', function() {
   const alertIcon = document.getElementById('alertIcon');

   // 벨 아이콘을 클릭하면 rejectModal을 열기
   alertIcon.addEventListener('click', function() {
      document.getElementById("listModal").style.display = "none";
      document.getElementById('rejectModal').style.display = 'block';
   });

   // 모달의 닫기 버튼을 클릭하면 모달을 닫기
   document.getElementById('closeRejectModal').addEventListener('click', function() {
      document.getElementById('rejectModal').style.display = 'none';
      document.getElementById("listModal").style.display = "block";
      loadShipList(); // 리스트 로드 함수 호출
   });

   // 모달 외부를 클릭하면 모달 닫기
   window.addEventListener('click', function(event) {
      const modal = document.getElementById('rejectModal');
      if (event.target === modal) {
         modal.style.display = 'none';
      }
   });
});


let currentPage = 1; // 현재 페이지 번호
const itemsPerPage = 3; // 페이지 당 표시할 항목 수

// Ship - 3. 모달을 열 때 항해 리스트 로드
function loadSailList(siCode) {
   // 모달 제목에 siCode 설정
   document.getElementById("sailListSiCode").textContent = siCode;

   $.ajax({
      url: '/controller/sailList?siCode=' + siCode,  // URL에 siCode를 직접 포함하여 전달
      type: 'GET',
      dataType: 'json',
      success: function(data) {
         console.log("항해 리스트 데이터:", data);

         // 초기 페이지를 1로 설정하고, 페이징 함수 호출
         currentPage = 1;
         paginateSailList(data, currentPage); // 페이징 함수 호출
         createPaginationButtons(data); // 페이지 버튼 생성

         // 모달을 화면에 표시
         document.getElementById('listModal').style.display = 'none';
         document.getElementById("sailListModal").style.display = "block";
      },
      error: function(xhr, status, error) {
         console.error('항해 리스트를 가져오는 중 오류 발생:', error);
      }
   });
}

// 항해 리스트 데이터 페이징 처리 함수
function paginateSailList(data, page) {
   const sailListElement = document.getElementById('sailList');
   sailListElement.innerHTML = ''; // 기존 리스트 초기화

   const start = (page - 1) * itemsPerPage;
   const end = start + itemsPerPage;
   const paginatedData = data.slice(start, end); // 현재 페이지에 해당하는 데이터 가져오기

   paginatedData.forEach(function(sail) {
      const listItem = document.createElement('li');
      listItem.classList.add('sail-info-card'); // 카드 스타일 클래스 추가

      // 데이터가 없을 경우 '데이터 없음' 표시
      const createdAt = sail.createdAt || '데이터 없음';
      const status = sail.status || '데이터 없음';
      const comment = sail.comment || '데이터 없음';

      listItem.innerHTML = `
         <div class="sail-details">
            <p><strong>등록일자:</strong> ${createdAt}</p>
            <p><strong>운항상태:</strong> ${status}</p>
            <p><strong>코멘트:</strong> ${comment}</p>
         </div>
         <div class="button-container">
            <button onclick="goToStatisticsPage('${sail.siCode}')">통계 페이지</button>
         </div>
      `;
      sailListElement.appendChild(listItem);
   });

   createPaginationButtons(data);
}

// 페이지 버튼 생성 함수
function createPaginationButtons(data) {
   const paginationContainer = document.getElementById('paginationContainer');
   paginationContainer.innerHTML = ''; // 기존 버튼 초기화

   const pageCount = Math.ceil(data.length / itemsPerPage); // 총 페이지 수 계산

   for (let i = 1; i <= pageCount; i++) {
      const pageButton = document.createElement('button');
      pageButton.textContent = i;
      pageButton.classList.add('page-button');
      if (i === currentPage) pageButton.classList.add('active'); // 현재 페이지 강조 표시
      pageButton.onclick = function() {
         currentPage = i;
         paginateSailList(data, currentPage);
      };
      paginationContainer.appendChild(pageButton);
   }
}




// 통계 페이지 이동 함수
function goToStatisticsPage(siCode) {
   window.location.href = `/controller/statistics?siCode=${siCode}`;
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

