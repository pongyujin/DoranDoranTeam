import numpy as np
import matplotlib.pyplot as plt
from matplotlib.animation import FuncAnimation
import matplotlib.font_manager as fm

# 시뮬레이션 모드 설정
simulation_mode = True  # True이면 시뮬레이션 모드, False이면 실제 모드

# 한글 폰트 설정 (필요 시 시스템에 설치된 폰트로 변경)
plt.rcParams['font.family'] = 'Malgun Gothic'  # 또는 'AppleGothic', 'NanumGothic' 등
plt.rcParams['axes.unicode_minus'] = False  # 마이너스 기호 깨짐 방지

# 허버사인 공식을 사용하여 두 지점 간 거리 계산
def haversine(lat1, lon1, lat2, lon2):
    R = 6371.0  # 지구 반지름 (킬로미터)
    lat1_rad, lon1_rad = np.radians([lat1, lon1])
    lat2_rad, lon2_rad = np.radians([lat2, lon2])
    dlat = lat2_rad - lat1_rad
    dlon = lon2_rad - lon1_rad
    a = np.sin(dlat / 2) ** 2 + np.cos(lat1_rad) * np.cos(lat2_rad) * np.sin(dlon / 2) ** 2
    c = 2 * np.arcsin(np.sqrt(a))
    distance = R * c
    return distance

def haversine_matrix(lat1, lon1, lat2, lon2):
    # 벡터화된 허버사인 계산
    R = 6371.0  # 지구 반지름 (킬로미터)
    lat1_rad = np.radians(lat1)
    lon1_rad = np.radians(lon1)
    lat2_rad = np.radians(lat2)
    lon2_rad = np.radians(lon2)
    dlat = lat2_rad - lat1_rad
    dlon = lon2_rad - lon1_rad
    a = np.sin(dlat / 2) ** 2 + np.cos(lat1_rad) * np.cos(lat2_rad) * np.sin(dlon / 2) ** 2
    c = 2 * np.arcsin(np.sqrt(a))
    distance = R * c
    return distance

# 그리드 생성
def create_grid(lat1, lon1, lat2, lon2, grid_size=200):
    lat_min = min(lat1, lat2) - 0.5  # 범위를 넓게 조정
    lat_max = max(lat1, lat2) + 0.5
    lon_min = min(lon1, lon2) - 0.5
    lon_max = max(lon1, lon2) + 0.5

    lat_grid = np.linspace(lat_min, lat_max, grid_size)
    lon_grid = np.linspace(lon_min, lon_max, grid_size)

    return lat_grid, lon_grid

# 장애물 맵 생성
def create_obstacle_map(lat_grid, lon_grid, obstacles, moving_obstacles, ship_lat, ship_lon, sensing_radius,
                        obstacle_radius=2, avoidance_cost=5):
    obstacle_map = np.zeros((len(lat_grid), len(lon_grid)))

    # 고정 장애물 마킹
    for obstacle in obstacles:
        obstacle_lat, obstacle_lon = obstacle
        distances = haversine_matrix(lat_grid[:, np.newaxis], lon_grid[np.newaxis, :], obstacle_lat, obstacle_lon)
        obstacle_map[distances <= obstacle_radius] = 1  # 장애물 위치 표시

    # 센싱 반경 내의 이동 장애물만 고려
    for moving_obstacle in moving_obstacles:
        # 무인 선박과의 거리 계산
        distance_to_ship = haversine(ship_lat, ship_lon, moving_obstacle['lat'], moving_obstacle['lon'])
        if distance_to_ship <= sensing_radius:
            obstacle_lat = moving_obstacle['lat']
            obstacle_lon = moving_obstacle['lon']
            direction = moving_obstacle['direction']
            distances = haversine_matrix(lat_grid[:, np.newaxis], lon_grid[np.newaxis, :], obstacle_lat,
                                         obstacle_lon)
            obstacle_map[distances <= obstacle_radius] = 1  # 이동 장애물 위치 표시

            # 회피할 오른쪽 영역 계산
            right_angle = (direction + 90) % 360
            rad = np.radians(right_angle)
            dx = np.cos(rad) * obstacle_radius
            dy = np.sin(rad) * obstacle_radius

            # 오른쪽 방향으로 회피할 영역을 마킹
            avoidance_lat = obstacle_lat + (dy / 111)  # 대략적인 위도 변환 (1도 ≈ 111km)
            avoidance_lon = obstacle_lon + (dx / (111 * np.cos(np.radians(obstacle_lat))))  # 대략적인 경도 변환

            # 회피 영역에 추가 비용 적용
            avoidance_distance = haversine_matrix(lat_grid[:, np.newaxis], lon_grid[np.newaxis, :], avoidance_lat,
                                                  avoidance_lon)
            obstacle_map[avoidance_distance <= obstacle_radius] += avoidance_cost  # 회피 영역에 비용 추가

    return obstacle_map

# A* 알고리즘을 위한 노드 클래스
class Node:
    def __init__(self, position, parent=None, g=0, h=0):
        self.position = position  # (x, y)
        self.parent = parent
        self.g = g  # 시작 노드로부터의 비용
        self.h = h  # 휴리스틱 비용
        self.f = g + h  # 총 비용

    def __eq__(self, other):
        return self.position == other.position

# A* 알고리즘 구현
def astar(obstacle_map, start_idx, goal_idx, lat_grid, lon_grid):
    open_list = []
    closed_list = set()

    start_node = Node(start_idx)
    goal_node = Node(goal_idx)

    open_list.append(start_node)

    while open_list:
        # f 값이 가장 낮은 노드를 선택
        open_list.sort(key=lambda node: node.f)
        current_node = open_list.pop(0)
        closed_list.add(current_node.position)

        # 목표 지점에 도달하면 경로 반환
        if current_node == goal_node:
            path = []
            node = current_node
            while node is not None:
                path.append(node.position)
                node = node.parent
            return path[::-1]  # 경로를 역순으로 반환

        # 현재 노드의 인접한 노드 탐색
        (x, y) = current_node.position
        neighbors = [(-1, 0), (1, 0), (0, -1), (0, 1),
                     (-1, -1), (-1, 1), (1, -1), (1, 1)]

        for dx, dy in neighbors:
            nx, ny = x + dx, y + dy

            # 그리드 범위 내에 있는지 확인
            if nx < 0 or nx >= obstacle_map.shape[0] or ny < 0 or ny >= obstacle_map.shape[1]:
                continue
            # 장애물인지 확인
            if obstacle_map[nx][ny] >= 1:
                continue
            # 이미 닫힌 리스트에 있는지 확인
            if (nx, ny) in closed_list:
                continue

            g = current_node.g + 1
            # 휴리스틱을 허버사인 거리로 계산
            h = haversine(lat_grid[nx], lon_grid[ny], lat_grid[goal_idx[0]], lon_grid[goal_idx[1]])
            neighbor_node = Node((nx, ny), current_node, g, h)

            # 이미 열린 리스트에 있는 노드인지 확인
            in_open_list = False
            for node in open_list:
                if neighbor_node == node and neighbor_node.g >= node.g:
                    in_open_list = True
                    break

            if not in_open_list:
                open_list.append(neighbor_node)

    return None  # 경로 없음


# 경로 보간 함수
def interpolate_path(route_lats, route_lons):
    path_distances = [0]
    for i in range(1, len(route_lats)):
        distance = haversine(route_lats[i - 1], route_lons[i - 1], route_lats[i], route_lons[i])
        path_distances.append(distance)
    cumulative_distances = np.cumsum(path_distances)
    total_distance = cumulative_distances[-1]

    num_points = max(int(total_distance / 0.05), 2)
    new_distances = np.linspace(0, total_distance, num_points)

    route_lats_interp = np.interp(new_distances, cumulative_distances, route_lats)
    route_lons_interp = np.interp(new_distances, cumulative_distances, route_lons)

    return route_lats_interp, route_lons_interp, new_distances
# 센싱 반경 내의 장애물만 필터링하는 함수
def filter_obstacles_in_range(ship_lat, ship_lon, moving_obstacles, sensing_radius):
    obstacles_in_range = []
    for obstacle in moving_obstacles:
        distance = haversine(ship_lat, ship_lon, obstacle['lat'], obstacle['lon'])
        if distance <= sensing_radius:
            obstacles_in_range.append(obstacle)
    return obstacles_in_range



# 경로 생성 함수
def generate_route_with_obstacles(lat1, lon1, lat2, lon2, fixed_obstacles, moving_obstacles, ship_lat, ship_lon,
                                  sensing_radius, grid_size=200):
    lat_grid, lon_grid = create_grid(lat1, lon1, lat2, lon2, grid_size=grid_size)

    # 센싱 반경 내의 이동 장애물만 필터링
    obstacles_in_range = filter_obstacles_in_range(ship_lat, ship_lon, moving_obstacles, sensing_radius)

    obstacle_map = create_obstacle_map(lat_grid, lon_grid, fixed_obstacles, obstacles_in_range, ship_lat, ship_lon,
                                       sensing_radius)

    start_idx = (np.abs(lat_grid - lat1).argmin(), np.abs(lon_grid - lon1).argmin())
    goal_idx = (np.abs(lat_grid - lat2).argmin(), np.abs(lon_grid - lon2).argmin())

    path = astar(obstacle_map, start_idx, goal_idx, lat_grid, lon_grid)

    if path is None:
        print("경로를 찾을 수 없습니다.")
        return [], [], obstacle_map, lat_grid, lon_grid

    route_lats = [lat_grid[pos[0]] for pos in path]
    route_lons = [lon_grid[pos[1]] for pos in path]

    return route_lats, route_lons, obstacle_map, lat_grid, lon_grid

# 경유점을 포함한 전체 경로 생성 함수
def generate_route_through_waypoints(start_lat, start_lon, waypoints, fixed_obstacles, moving_obstacles, sensing_radius,
                                     grid_size=200):
    full_route_lats = [start_lat]
    full_route_lons = [start_lon]

    for end in waypoints:
        route_lats, route_lons, _, _, _ = generate_route_with_obstacles(
            full_route_lats[-1], full_route_lons[-1], end[0], end[1],
            fixed_obstacles, moving_obstacles, full_route_lats[-1], full_route_lons[-1], sensing_radius, grid_size)

        if not route_lats or not route_lons:
            print(f"경유점 {end}로의 경로 생성 실패.")
            return [], []

        full_route_lats.extend(route_lats[1:])  # 시작점 중복 제거
        full_route_lons.extend(route_lons[1:])

    return full_route_lats, full_route_lons



# 장애물과의 근접성을 확인하는 함수
def check_obstacle_proximity(ship_lat, ship_lon, obstacles, obstacle_radius):
    for obstacle in obstacles:
        distance = haversine(ship_lat, ship_lon, obstacle['lat'], obstacle['lon'])
        if distance <= obstacle_radius:
            return True
    return False

# 경로 이탈 여부 확인 함수
def calculate_min_distance_to_route(ship_lat, ship_lon, route_lats, route_lons):
    distances = haversine_matrix(np.array([ship_lat]), np.array([ship_lon]), np.array(route_lats), np.array(route_lons))
    min_distance = np.min(distances)
    return min_distance

# 방위각 계산 함수
def calculate_bearing(lat1, lon1, lat2, lon2):
    lat1_rad, lon1_rad = np.radians([lat1, lon1])
    lat2_rad, lon2_rad = np.radians([lat2, lon2])
    dlon = lon2_rad - lon1_rad
    x = np.sin(dlon) * np.cos(lat2_rad)
    y = np.cos(lat1_rad) * np.sin(lat2_rad) - (np.sin(lat1_rad) * np.cos(lat2_rad) * np.cos(dlon))
    initial_bearing = np.arctan2(x, y)
    bearing = (np.degrees(initial_bearing) + 360) % 360
    return bearing

# 현재 헤딩을 받아오는 함수
def get_current_heading():
    # 실제 센서로부터 현재 헤딩을 받아오는 코드 구현 필요
    current_heading = 0  # 시뮬레이션에서는 0도로 고정
    return current_heading

# 모터와 방향타 제어 함수
def control_motors_and_rudder(heading_error):
    # 헤딩 오류를 기반으로 모터와 방향타를 제어하는 함수
    # 실제 하드웨어와 통신하여 제어 신호를 보내야 함
    # heading_error를 이용하여 모터 속도와 방향타 각도를 조절
    pass

# 다음 목표 지점 인덱스 찾기 함수
def find_next_point_index(ship_lat, ship_lon, route_lats, route_lons):
    distances = haversine_matrix(np.array([ship_lat]), np.array([ship_lon]), np.array(route_lats), np.array(route_lons))
    min_index = np.argmin(distances)
    return min_index

# 코스 조정 함수
def adjust_course(ship_lat, ship_lon, route_lats, route_lons):
    # 경로 상의 다음 목표 지점을 찾음
    next_index = find_next_point_index(ship_lat, ship_lon, route_lats, route_lons)
    if next_index is not None and next_index + 1 < len(route_lats):
        target_lat = route_lats[next_index + 1]
        target_lon = route_lons[next_index + 1]
    else:
        target_lat = route_lats[-1]
        target_lon = route_lons[-1]

    # 목표 지점까지의 방위각 계산
    target_bearing = calculate_bearing(ship_lat, ship_lon, target_lat, target_lon)

    # 현재 헤딩 얻기
    current_heading = get_current_heading()

    # 헤딩 오류 계산
    heading_error = (target_bearing - current_heading + 180) % 360 - 180

    # 모터와 방향타 제어
    control_motors_and_rudder(heading_error)

# 실제 GPS 데이터를 받아오는 함수
def get_gps_data():
    # 실제 GPS 데이터를 받아오는 코드 구현 필요
    # 임시 적용
    current_lat, current_lon =  34.5, 128.73
    gps_lat = current_lat  # 시뮬레이션에서는 현재 위치 사용
    gps_lon = current_lon
    return gps_lat, gps_lon

# 시뮬레이션 설정
if simulation_mode:
    initial_lat, initial_lon = 34.5, 128.73
else:
    # 실제 GPS 데이터를 사용하여 초기 위치 설정
    initial_lat, initial_lon = get_gps_data()

current_lat, current_lon = initial_lat, initial_lon
previous_lat, previous_lon = initial_lat, initial_lon

destination_lat, destination_lon = 35.22, 128.90

# 경유점 리스트
waypoints = [
    (34.6, 128.7),
#    (34.8, 128.7),
    (34.8, 128.95),
#    (35.0, 128.85),
    (destination_lat, destination_lon)
]

# 고정 장애물 리스트 (5곳)
fixed_obstacles = [
    (34.95, 128.95),
    (34.90, 128.90),
    (34.75, 128.80),
    (34.85, 128.85),
    (35.00, 128.75),
]

# 이동 장애물 리스트 (30곳)
moving_obstacles = [
    {'lat': 34.85, 'lon': 128.85, 'direction': 90, 'speed': 15},
    {'lat': 35.0, 'lon': 129.0, 'direction': 135, 'speed': 12},
    {'lat': 34.95, 'lon': 129.25, 'direction': 180, 'speed': 10},
    {'lat': 34.70, 'lon': 128.80, 'direction': 90, 'speed': 8},
    {'lat': 34.75, 'lon': 129.00, 'direction': 270, 'speed': 14},
    {'lat': 34.90, 'lon': 129.10, 'direction': 315, 'speed': 16},
    {'lat': 34.60, 'lon': 128.75, 'direction': 180, 'speed': 9},
    {'lat': 34.85, 'lon': 128.95, 'direction': 90, 'speed': 13},
    {'lat': 35.05, 'lon': 128.90, 'direction': 270, 'speed': 11},
    {'lat': 34.95, 'lon': 129.10, 'direction': 225, 'speed': 17},
    {'lat': 34.65, 'lon': 128.85, 'direction': 90, 'speed': 15},
    {'lat': 34.80, 'lon': 128.90, 'direction': 180, 'speed': 12},
    {'lat': 35.10, 'lon': 129.05, 'direction': 315, 'speed': 18},
    {'lat': 34.75, 'lon': 128.75, 'direction': 135, 'speed': 14},
    {'lat': 34.88, 'lon': 129.05, 'direction': 90, 'speed': 16},
    {'lat': 34.92, 'lon': 129.20, 'direction': 180, 'speed': 9},
    {'lat': 35.12, 'lon': 129.00, 'direction': 45, 'speed': 20},
    {'lat': 34.82, 'lon': 128.88, 'direction': 225, 'speed': 11},
    {'lat': 34.78, 'lon': 129.15, 'direction': 270, 'speed': 13},
    {'lat': 34.67, 'lon': 128.78, 'direction': 315, 'speed': 10},
    {'lat': 34.85, 'lon': 128.80, 'direction': 90, 'speed': 14},
    {'lat': 34.90, 'lon': 128.95, 'direction': 135, 'speed': 12},
    {'lat': 35.05, 'lon': 129.15, 'direction': 180, 'speed': 9},
    {'lat': 34.65, 'lon': 128.70, 'direction': 90, 'speed': 15},
    {'lat': 34.80, 'lon': 129.05, 'direction': 270, 'speed': 13},
    {'lat': 34.95, 'lon': 129.05, 'direction': 315, 'speed': 16},
    {'lat': 34.55, 'lon': 128.80, 'direction': 180, 'speed': 11},
    {'lat': 34.90, 'lon': 128.85, 'direction': 90, 'speed': 14},
    {'lat': 35.00, 'lon': 128.95, 'direction': 270, 'speed': 12},
    {'lat': 34.85, 'lon': 129.00, 'direction': 225, 'speed': 17},
]

if simulation_mode:
    ship_speed = 30  # km/h
else:
    ship_speed = 0  # 실제 속도는 이후에 계산됨

total_time = 300  # 총 시뮬레이션 시간 (분)
time_step = 0.1  # 시간 간격 (분)
num_steps = int(total_time / time_step)
sensing_radius = 10  # km
obstacle_radius = 2  # km  # 장애물 반경 설정

ship_distance_traveled = 0
reached_destination = False
current_waypoint_index = 0  # 현재 목표로 하는 경유점 인덱스

# 초기 전체 경로 생성 (이동 장애물 미고려)
full_route_lats, full_route_lons = generate_route_through_waypoints(
    initial_lat, initial_lon, waypoints, fixed_obstacles, [], sensing_radius)

if not full_route_lats or not full_route_lons:
    print("초기 경로 생성 실패. 시뮬레이션을 종료합니다.")
    exit()
# 생성된 전체 경로 출력
print("생성된 전체 경로:")
for lat, lon in zip(full_route_lats, full_route_lons):
    print(f"위도: {lat:.6f}, 경도: {lon:.6f}")


route_lats_interp, route_lons_interp, cumulative_distances = interpolate_path(full_route_lats, full_route_lons)

# 축 범위 설정 (경로 및 목적지를 포함하도록)
lat_min_plot = min(min(route_lats_interp), destination_lat, initial_lat) - 0.1
lat_max_plot = max(max(route_lats_interp), destination_lat, initial_lat) + 0.1
lon_min_plot = min(min(route_lons_interp), destination_lon, initial_lon) - 0.1
lon_max_plot = max(max(route_lons_interp), destination_lon, initial_lon) + 0.1

# 애니메이션 초기화
fig, ax = plt.subplots(figsize=(12, 8))

def update(frame):
    global current_lat, current_lon, previous_lat, previous_lon, route_lats_interp, route_lons_interp
    global cumulative_distances, ship_distance_traveled, reached_destination, current_waypoint_index
    global full_route_lats, full_route_lons, ship_speed

    current_time = frame * time_step

    # 이동 장애물 위치 업데이트
    for mo in moving_obstacles:
        speed, direction = mo['speed'], mo['direction']
        distance = speed * (time_step / 60)  # km
        delta_lat = (distance / 111) * np.cos(np.radians(direction))
        delta_lon = (distance / (111 * np.cos(np.radians(mo['lat'])))) * np.sin(np.radians(direction))
        mo['lat'] += delta_lat
        mo['lon'] += delta_lon

    # 이전 위치 저장
    previous_lat, previous_lon = current_lat, current_lon

    if simulation_mode:
        # 무인 선박의 이동 거리 업데이트
        distance_step = ship_speed * (time_step / 60)  # km
        ship_distance_traveled += distance_step

        # 무인 선박의 위치 업데이트
        if ship_distance_traveled >= cumulative_distances[-1]:
            current_lat, current_lon = route_lats_interp[-1], route_lons_interp[-1]
            reached_destination = True
        else:
            idx = np.searchsorted(cumulative_distances, ship_distance_traveled)
            if idx == 0:
                current_lat, current_lon = route_lats_interp[0], route_lons_interp[0]
            else:
                ratio = (ship_distance_traveled - cumulative_distances[idx - 1]) / (
                        cumulative_distances[idx] - cumulative_distances[idx - 1])
                current_lat = route_lats_interp[idx - 1] + ratio * (route_lats_interp[idx] - route_lats_interp[idx - 1])
                current_lon = route_lons_interp[idx - 1] + ratio * (route_lons_interp[idx] - route_lons_interp[idx - 1])

        # 선박의 속도는 시뮬레이션 모드에서는 고정값 사용
        ship_speed = 30  # km/h

    else:
        # 실제 GPS 데이터로 위치 업데이트
        current_lat, current_lon = get_gps_data()

        # 이동 거리 및 속도 계산
        distance_moved = haversine(previous_lat, previous_lon, current_lat, current_lon)
        ship_speed = distance_moved / (time_step / 60)  # km/h

    # 현재 경유점에 도달했는지 확인
    if current_waypoint_index < len(waypoints):
        distance_to_waypoint = haversine(current_lat, current_lon, waypoints[current_waypoint_index][0],
                                         waypoints[current_waypoint_index][1])
        if distance_to_waypoint < 0.5:  # 500m 이내로 접근하면 도달한 것으로 간주
            print(f"경유점 {current_waypoint_index + 1}에 도달했습니다. 다음 경유점으로 이동합니다.")
            current_waypoint_index += 1

    # 목적지 도달 확인
    if current_waypoint_index == len(waypoints):
        reached_destination = True
        print(f"목적지에 도달했습니다. 시간: {current_time:.1f}분")
        ani.event_source.stop()

    # 장애물 근접성 확인 및 경로 재계획
    if check_obstacle_proximity(current_lat, current_lon, moving_obstacles,
                                obstacle_radius) and not reached_destination:

        # 센싱 반경 내의 이동 장애물 필터링
        obstacles_in_range = filter_obstacles_in_range(current_lat, current_lon, moving_obstacles, sensing_radius)

        remaining_waypoints = waypoints[current_waypoint_index:]
        new_route_lats, new_route_lons = generate_route_through_waypoints(
            current_lat, current_lon, remaining_waypoints, fixed_obstacles, obstacles_in_range, sensing_radius)

        if new_route_lats and new_route_lons:
            full_route_lats = [current_lat] + new_route_lats[1:]  # 현재 위치에서 시작
            full_route_lons = [current_lon] + new_route_lons[1:]

            route_lats_interp, route_lons_interp, cumulative_distances = interpolate_path(full_route_lats,
                                                                                          full_route_lons)

            # 현재 위치에 가장 가까운 인덱스를 찾아 이동 거리를 재설정
            ship_distance_traveled = 0
            print(f"장애물 근접 감지. 경로가 재계획되었습니다. 시간: {current_time:.1f}분")
        else:
            print("경로 재계획 실패. 이전 경로를 유지합니다.")

        # 생성된 전체 경로 출력
        print("생성된 전체 경로:")
        for lat, lon in zip(full_route_lats, full_route_lons):
            print(f"위도: {lat:.6f}, 경도: {lon:.6f}")

    # 경로 이탈 여부 확인
    deviation_distance = calculate_min_distance_to_route(current_lat, current_lon, route_lats_interp, route_lons_interp)
    allowed_deviation_threshold = 0.3  # 허용되는 최대 이탈 거리 (예: 300m)
    if deviation_distance > allowed_deviation_threshold:
        # 경로 재계획
        print(f"경로 이탈 감지. 경로를 재계획합니다. 이탈 거리: {deviation_distance:.2f} km")
        remaining_waypoints = waypoints[current_waypoint_index:]
        new_route_lats, new_route_lons = generate_route_through_waypoints(
            current_lat, current_lon, remaining_waypoints, fixed_obstacles, moving_obstacles, sensing_radius)

        if new_route_lats and new_route_lons:
            full_route_lats = [current_lat] + new_route_lats[1:]  # 현재 위치에서 시작
            full_route_lons = [current_lon] + new_route_lons[1:]

            route_lats_interp, route_lons_interp, cumulative_distances = interpolate_path(full_route_lats,
                                                                                          full_route_lons)
            print(f"새로운 경로가 생성되었습니다.")
        else:
            print("경로 재계획 실패. 이전 경로를 유지합니다.")

        # 생성된 전체 경로 출력
        print("생성된 전체 경로:")
        for lat, lon in zip(full_route_lats, full_route_lons):
            print(f"위도: {lat:.6f}, 경도: {lon:.6f}")

    # 코스 조정
    adjust_course(current_lat, current_lon, route_lats_interp, route_lons_interp)

    # 시각화
    ax.cla()
    ax.plot(full_route_lons, full_route_lats, color='blue', label='전체 경로', linewidth=2)

    # 고정 장애물 표시
    ax.scatter([lon for lat, lon in fixed_obstacles], [lat for lat, lon in fixed_obstacles],
               color='red', marker='x', label='고정 장애물', s=50)

    # 모든 이동 장애물 표시 (센싱 반경 밖의 장애물도 포함)
    for mo in moving_obstacles:
        ax.scatter(mo['lon'], mo['lat'], color='green', marker='o', s=50)
        arrow_dx = 0.02 * np.sin(np.radians(mo['direction']))
        arrow_dy = 0.02 * np.cos(np.radians(mo['direction']))
        ax.arrow(mo['lon'], mo['lat'], arrow_dx, arrow_dy,
                 head_width=0.01, head_length=0.01, fc='green', ec='green')

    # 센싱 반경 시각화
    sensing_circle = plt.Circle((current_lon, current_lat), sensing_radius / 111, color='cyan', fill=False,
                                linestyle='--')
    ax.add_artist(sensing_circle)

    # 장애물 반경 시각화
    obstacle_circle = plt.Circle((current_lon, current_lat), obstacle_radius / 111, color='red', fill=False,
                                 linestyle=':')
    ax.add_artist(obstacle_circle)

    # 무인 선박의 현재 위치 표시
    ax.scatter(current_lon, current_lat, marker='o', color='cyan', s=200, label='무인 선박')

    # 이동 방향 화살표 계산
    delta_lat, delta_lon = current_lat - previous_lat, current_lon - previous_lon
    if delta_lat != 0 or delta_lon != 0:
        direction_rad = np.arctan2(delta_lon, delta_lat)
        arrow_length = 0.05
        arrow_dx, arrow_dy = arrow_length * np.sin(direction_rad), arrow_length * np.cos(direction_rad)
        ax.arrow(current_lon, current_lat, arrow_dx, arrow_dy,
                 head_width=0.02, head_length=0.02, fc='cyan', ec='cyan')

    # 시작점과 목적지 표시
    ax.scatter(initial_lon, initial_lat, marker='o', color='yellow', s=100, label='시작점')
    ax.scatter(destination_lon, destination_lat, marker='*', color='magenta', s=200, label='목적지')

    # 경유점 표시
    for i, (wp_lat, wp_lon) in enumerate(waypoints[:-1], 1):
        if i >= current_waypoint_index:
            ax.scatter(wp_lon, wp_lat, marker='s', color='orange', s=100, label=f'경유점 {i}' if i == current_waypoint_index else "")

    # 그래프 설정
    ax.set_title(f'시간: {current_time:.1f}분')
    ax.set_xlabel('경도')
    ax.set_ylabel('위도')
    handles, labels = ax.get_legend_handles_labels()
    unique = dict(zip(labels, handles))
    ax.legend(unique.values(), unique.keys(), loc='upper left', bbox_to_anchor=(1, 1))
    ax.grid(True)

    # 축 범위 설정
    ax.set_xlim(lon_min_plot, lon_max_plot)
    ax.set_ylim(lat_min_plot, lat_max_plot)
    ax.set_aspect('equal', adjustable='box')

    # 디버깅 정보 출력
    print(f"시간: {current_time:.1f}분, 선박 위치: ({current_lat:.4f}, {current_lon:.4f})")
    print(f"선박 속도: {ship_speed:.2f} km/h")
    print(f"이동 거리: {ship_distance_traveled:.2f} km / 현재 경로 총 거리: {cumulative_distances[-1]:.2f} km")

# 애니메이션 실행
ani = FuncAnimation(fig, update, frames=num_steps, interval=50)
plt.tight_layout()
plt.show()
