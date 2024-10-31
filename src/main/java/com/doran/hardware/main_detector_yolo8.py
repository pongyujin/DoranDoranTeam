import cv2
import numpy as np
from sklearn.cluster import DBSCAN
import matplotlib.pyplot as plt
import math
import serial
from ultralytics import YOLO
import time
import binascii


class LidarData:
    def __init__(self, FSA, LSA, CS, Speed, TimeStamp, Confidence_i, Angle_i, Distance_i):
        self.FSA = FSA
        self.LSA = LSA
        self.CS = CS
        self.Speed = Speed
        self.TimeStamp = TimeStamp

        self.Confidence_i = Confidence_i
        self.Angle_i = Angle_i
        self.Distance_i = Distance_i


def ProcessLidarData(str):
    str = str.replace(' ', '')

    Speed = int(str[2:4] + str[0:2], 16) / 100
    FSA = float(int(str[6:8] + str[4:6], 16)) / 100
    LSA = float(int(str[-8:-6] + str[-10:-8], 16)) / 100
    TimeStamp = int(str[-4:-2] + str[-6:-4], 16)
    CS = int(str[-2:], 16)

    Confidence_i = list()
    Angle_i = list()
    Distance_i = list()
    count = 0
    if (LSA - FSA > 0):
        angleStep = float(LSA - FSA) / (12)
    else:
        angleStep = float((LSA + 360) - FSA) / (12)

    counter = 0
    circle = lambda deg: deg - 360 if deg >= 360 else deg
    for i in range(0, 6 * 12, 6):
        Distance_i.append(int(str[8 + i + 2:8 + i + 4] + str[8 + i:8 + i + 2], 16) / 100)
        Confidence_i.append(int(str[8 + i + 4:8 + i + 6], 16))
        Angle_i.append(circle(angleStep * counter + FSA) * math.pi / 180.0)
        counter += 1

    lidarData = LidarData(FSA, LSA, CS, Speed, TimeStamp, Confidence_i, Angle_i, Distance_i)
    return lidarData


class LidarClusterDetector:
    def __init__(self):
        self.eps = 0.3
        self.min_samples = 3
        self.min_points = 5
        self.max_distance = 100.0
        self.min_distance = 1.0

    def detect_clusters(self, angles, distances):
        """라이다 데이터에서 클러스터 감지"""
        # 유효한 포인트 필터링
        valid_points = []
        for angle, distance in zip(angles, distances):
            if self.min_distance < distance < self.max_distance:
                x = distance * math.cos(angle)
                y = distance * math.sin(angle)
                valid_points.append([x, y])

        if len(valid_points) < self.min_points:
            return []

        # DBSCAN 클러스터링
        points = np.array(valid_points)
        clustering = DBSCAN(
            eps=self.eps,
            min_samples=self.min_samples
        ).fit(points)

        # 클러스터 정보 추출
        clusters = []
        for label in range(max(clustering.labels_) + 1):
            if label == -1:
                continue

            mask = clustering.labels_ == label
            cluster_points = points[mask]

            if len(cluster_points) < self.min_points:
                continue

            # 클러스터 특성 계산
            center = np.mean(cluster_points, axis=0)
            distance = np.linalg.norm(center)
            angle = math.atan2(center[1], center[0])

            clusters.append({
                'center_x': center[0],
                'center_y': center[1],
                'distance': distance,
                'angle': angle,
                'points': len(cluster_points)
            })

        return clusters


class IntegratedDetector:
    def __init__(self, camera_index=0, lidar_port='COM4', yolo_model='yolov8n.pt'):
        # matplotlib 설정
        self.fig = plt.figure(facecolor='black', figsize=(16, 16))
        self.ax = self.fig.add_subplot(111, projection='polar')
        self.ax.set_title('Lidar Test with Object Detection', fontsize=18)
        self.ax.set_facecolor('black')
        self.ax.set_ylim([0, 100])
        self.ax.xaxis.grid(True, color='white', linestyle='dashed', linewidth=0.2)
        self.ax.yaxis.grid(True, color='white', linestyle='dashed', linewidth=0.2)
        self.ax.set_theta_direction(-1)
        self.ax.set_theta_offset(math.pi / 2)

        # 라이다 객체 감지기
        self.detector = LidarClusterDetector()

        video_url = 'http://192.168.219.47:5001/video'
        #video_url = 'http://192.168.219.47:8080/video_feed'



        # YOLO 초기화
        self.yolo = YOLO(yolo_model)

        # 웹캠에서 프레임 캡처
        print("웹캠 초기화 중...")
        self.cap = cv2.VideoCapture(video_url)
        print("웹캠 초기화 완료")

        # 시리얼 통신 설정
        self.ser = serial.Serial(
            port=lidar_port,
            baudrate=230400,
            timeout=5.0,
            bytesize=8,
            parity='N',
            stopbits=1
        )

        # 데이터 저장용
        self.scatter_points = None
        self.cluster_points = []
        self.cluster_labels = []
		
    def get_distance_color(self, distance):
        """거리에 따른 색상 반환"""
        distance = distance / 10  # 미터 단위로 변환
        if distance < 1.0:  # 1m 이내
            return (0, 0, 255)  # 빨간색
        elif distance < 2.0:  # 2m 이내
            return (0, 255, 255)  # 노란색
        else:
            return (0, 255, 0)  # 녹색

    def match_detections(self, clusters, yolo_boxes, frame_width):
        """YOLO와 라이다 클러스터 매칭 (-30도 ~ +30도 범위)"""
        matched_objects = []

        for box in yolo_boxes:
            x1, y1, x2, y2, conf, cls = box
            center_x = (x1 + x2) / 2
            angle_deg = ((center_x / frame_width) - 0.5) * 60
            angle_rad = math.radians(angle_deg)

            best_match = None
            min_angle_diff = float('inf')

            for cluster in clusters:
                cluster_angle_deg = math.degrees(cluster['angle'])

                # -30도 ~ +30도 범위 내의 클러스터만 고려
                if -30 <= cluster_angle_deg <= 30:
                    angle_diff = abs(cluster_angle_deg - angle_deg)
                    if angle_diff < min_angle_diff:
                        min_angle_diff = angle_diff
                        best_match = cluster

            # 매칭 임계값 (5도) 내에서 매칭된 경우만 추가
            if best_match and min_angle_diff < 5:
                matched_objects.append({
                    'angle': best_match['angle'],
                    'distance': best_match['distance'],
                    'class': self.yolo.names[int(cls)],
                    'confidence': conf,
                    'box': (x1, y1, x2, y2)
                })

        return matched_objects

    def update_plot(self, angles, distances):
        """플롯 업데이트"""
        # 이전 데이터 제거
        if self.scatter_points:
            self.scatter_points.remove()

        for point in self.cluster_points:
            point.remove()
        for label in self.cluster_labels:
            label.remove()
        self.cluster_points = []
        self.cluster_labels = []

        # 산점도 그리기
        self.scatter_points = self.ax.scatter(angles, distances, c="yellow", s=1)

        # 클러스터 감지
        clusters = self.detector.detect_clusters(angles, distances)
        for cluster in clusters:
            # 클러스터 중심점 표시
            print(f"[INFO] cluster['angle']: {cluster['angle']}")
            angle_deg = math.degrees(cluster['angle'])
            if angle_deg> -30 and angle_deg < 30 :
                point = self.ax.scatter(
                    cluster['angle'],
                    cluster['distance'],
                    c='blue',
                    s=50,
                    alpha=1.0
                )
            else :
                point = self.ax.scatter(
                    cluster['angle'],
                    cluster['distance'],
                    c='red',
                    s=30,
                    alpha=0.7
                )
            self.cluster_points.append(point)

            # 클러스터 정보 표시
            label = self.ax.text(
                cluster['angle'],
                cluster['distance'],
                f"{cluster['distance']/10:.1f}m",
                color='white',
                fontsize=8
            )
            self.cluster_labels.append(label)

        # 그래프 갱신
        plt.draw()
		
        # 카메라 프레임 읽기 및 YOLO 처리
        ret, frame = self.cap.read()
        if ret:
            # YOLO로 객체 감지
            yolo_results = self.yolo(frame)

            # YOLO 결과와 라이다 클러스터 매칭
            matched_objects = self.match_detections(
                clusters,
                yolo_results[0].boxes.data,
                frame.shape[1]
            )

            # 결과를 카메라 프레임에 표시
            for obj in matched_objects:
                x1, y1, x2, y2 = obj['box']

                # 거리에 따른 색상 선택
                color = self.get_distance_color(obj['distance'])

                # 박스 그리기
                cv2.rectangle(frame,
                              (int(x1), int(y1)),
                              (int(x2), int(y2)),
                              color, 2)

                # 정보 표시
                distance_text = (f"{obj['class']} "
                                 f"{obj['distance'] / 10:.2f}m")

                cv2.putText(frame,
                            distance_text,
                            (int(x1), int(y1) - 10),
                            cv2.FONT_HERSHEY_SIMPLEX,
                            0.5,
                            color,
                            2)

            # YOLO 결과 표시
            cv2.imshow('Object Detection with Distance', frame)
            cv2.waitKey(1)

        return clusters

    def run(self):
        """메인 실행 루프"""
        try:
            tmpString = ""
            angles = []
            distances = []
            i = 0

            plt.connect('key_press_event',
                        lambda event: exit(1) if event.key == 'Esc' else None)

            while True:
                loopFlag = True
                flag2c = False

                if (i % 40 == 39):
                    clusters = self.update_plot(angles, distances)
                    plt.pause(0.01)
                    angles.clear()
                    distances.clear()
                    i = 0

                # 라이다 데이터 읽기
                while loopFlag:
                    b = self.ser.read()
                    tmpInt = int.from_bytes(b, 'big')

                    if (tmpInt == 0x54):
                        tmpString += b.hex() + " "
                        flag2c = True
                        continue

                    elif (tmpInt == 0x2c and flag2c):
                        tmpString += b.hex()

                        if (not len(tmpString[0:-5].replace(' ', '')) == 90):
                            tmpString = ""
                            loopFlag = False
                            flag2c = False
                            continue

                        lidarData = ProcessLidarData(tmpString[0:-5])
                        angles.extend(lidarData.Angle_i)
                        distances.extend(lidarData.Distance_i)
                        tmpString = ""
                        loopFlag = False
                    else:
                        tmpString += b.hex() + " "

                    flag2c = False

                i += 1

        finally:
            self.cap.release()
            cv2.destroyAllWindows()
            self.ser.close()


if __name__ == "__main__":
    detector = IntegratedDetector()
    detector.run()