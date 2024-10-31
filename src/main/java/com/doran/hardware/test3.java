package com.doran.hardware;

public class test3 {

	public static void main(String[] args) {
		// 3. Python 파일 실행을 비동기 처리(별도의 스레드)
		// 파이썬 경로(cmd창에 where python 치면 경로 나옵니다)
		String pythonInterpreterPath = "C:\\Users\\smhrd11\\AppData\\Local\\Programs\\Python\\Python312\\python.exe";
		// 실행할 파이썬 스크립트 경로
		String pythonScriptPath = "src/main/java/com/doran/hardware/yolo8.py";
		new Thread(() -> {
			// py파일 연결
			PythonConnect py = new PythonConnect();
			py.pythonInterpreter(pythonInterpreterPath, pythonScriptPath); // Python 스크립트 실행
		}).start();

		// astar
		String python2ScriptPath = "src/main/java/com/doran/hardware/astar.py";
		new Thread(() -> {
			// py파일 연결
			PythonConnect py = new PythonConnect();
			py.pythonInterpreter(pythonInterpreterPath, python2ScriptPath); // Python 스크립트 실행
		}).start();

		// GPS
		String python3ScriptPath = "src/main/java/com/doran/hardware/GPS.py";
		new Thread(() -> {
			// py파일 연결
			PythonConnect py = new PythonConnect();
			py.pythonInterpreter(pythonInterpreterPath, python3ScriptPath); // Python 스크립트 실행
		}).start();

	}

}
