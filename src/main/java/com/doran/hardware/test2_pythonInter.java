package com.doran.hardware;

public class test2_pythonInter {

	public static void main(String[] args) {

		PythonConnect py = new PythonConnect();
		
		//cmd 창에 where python
		//String pythonInterpreterPath = "C:\\Users\\smhrd11\\AppData\\Local\\Programs\\Python\\Python312\\python.exe";
		String pythonInterpreterPath = "C:\\Users\\smhrd\\AppData\\Local\\Programs\\Python\\Python312\\python.exe";

		//실행할 py파일 경로
		String pythonScriptPath = "src/main/java/com/doran/hardware/yolov8.py";
		py.pythonInterpreter(pythonInterpreterPath, pythonScriptPath);
		

	}
		
}
