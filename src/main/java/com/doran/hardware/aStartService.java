package com.doran.hardware;

import java.util.Properties;

import org.python.core.PyObject;
import org.python.core.PyUnicode;
import org.python.util.PythonInterpreter;
import org.springframework.stereotype.Service;

@Service
public class aStartService {
    
    private static PythonInterpreter interpreter;
    
    static {
        Properties properties = new Properties();
        properties.setProperty("python.import.site", "false");
        PythonInterpreter.initialize(System.getProperties(), properties, new String[0]);
        interpreter = new PythonInterpreter();
    }

    public String executePythonScript(String input) {
    	
        interpreter.execfile("src/main/resources/GPS.py"); // py 파일 경로 설정
        PyObject processFunction = interpreter.get("main"); // 함수 이름 지정
        PyObject result = processFunction.__call__(new PyUnicode(input));
        return result.toString();
    }
}
