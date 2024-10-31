package com.doran.hardware;

public class test1_ssh {

	public static void main(String[] args) {

		// 라즈베리파이에 연결후 커맨드입력
		RaspberrypiConnect rp = new RaspberrypiConnect();

		//ssh [username]@[hostname or IP address]
		String user = "xo";
		String host = "192.168.219.47";
		int port = 22;
		String password = "xo";
		String command = "cd /srv/shared/project/ && python3 app.py";
		rp.cmdRemote(user, host, port, password, command);

	}

}