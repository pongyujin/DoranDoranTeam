import cv2
import time
import requests
import json
from ultralytics import YOLO

# YOLOv8 모델 로드
model = YOLO('yolov8s.pt')

# 라즈베리파이 스트림 URL
stream_url = "http://192.168.219.47:8080/video_feed"

# Java 서버 주소

java_server_url = "http://192.168.219.101:8085/controller/receive-data"

# 스트림 열기
cap = cv2.VideoCapture(stream_url)

if not cap.isOpened():
    print("Error: Could not open video stream")
    exit()

# 신뢰도 임계값 및 시간 설정
confidence_threshold = 0.7  # 신뢰도 기준
save_interval = 5  # 5초에 한 번씩만 전송
last_sent_time = time.time()  # 마지막 전송 시간을 초기화
last_sent_classes = set()  # 마지막 전송된 클래스 ID를 저장하는 집합

while True:
    ret, frame = cap.read()
    if not ret:
        print("Failed to grab frame")
        break

    # YOLO 감지 수행
    results = model(frame)

    # 감지된 객체 정보를 추출 (신뢰도가 임계값 이상인 경우만 포함)
    detection_data = [{'classId': int(box.cls[0]),
                       'className': model.names[int(box.cls[0])],
                       'confidence': float(box.conf[0]),
                       'bbox': box.xywh[0].tolist()}
                      for box in results[0].boxes if float(box.conf[0]) >= confidence_threshold]

    # YOLO 결과를 사용해 바운딩 박스가 그려진 이미지 생성
    annotated_frame = results[0].plot()  # 바운딩 박스와 텍스트가 그려진 이미지

    # 현재 시간과 마지막 전송 시간 비교
    current_time = time.time()
    # JSON 데이터를 문자열로 직렬화
    json_data = json.dumps(detection_data)

    # 데이터가 있고, 클래스 ID가 이전에 전송된 것과 다르며, 5초 이상 지난 경우에만 전송
    current_classes = set(d['classId'] for d in detection_data)
    if detection_data and current_classes != last_sent_classes and (current_time - last_sent_time >= save_interval):
        # 이미지 데이터를 JPEG 형식으로 변환 (바운딩 박스가 그려진 상태)
        _, img_encoded = cv2.imencode('.jpg', annotated_frame)

        # 멀티파트 요청으로 이미지와 JSON 데이터 전송
        try:
            response = requests.post(
                java_server_url,
                files={'image': ('frame.jpg', img_encoded.tobytes(), 'image/jpeg')},
                data={'json': json_data}  # json_data를 문자열로 전송합니다.
            )
            print(f"Data sent, response: {response.status_code}")
            # 전송된 클래스 ID를 콘솔에 출력
            print(f"Current classes sent: {current_classes}")
        except Exception as e:
            print(f"Error sending data: {e}")

        # 마지막 전송 시간을 현재 시간으로 업데이트
        last_sent_time = current_time
        # 마지막 전송된 클래스 ID 업데이트
        last_sent_classes = current_classes

    # 결과 화면 출력 (로컬 화면에 바운딩 박스가 그려진 프레임을 보여줌)
    if 'annotated_frame' in locals():
        cv2.imshow('YOLOv8 Detection', annotated_frame)

    # 'q' 키를 누르면 종료
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

    # 0.1초 대기 (프레임 처리 속도를 조정)
    time.sleep(0.1)

# 스트림 종료
cap.release()
cv2.destroyAllWindows()
