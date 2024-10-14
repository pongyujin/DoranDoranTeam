package com.doran.controller;

import java.io.*;
import java.net.*;
import javax.swing.*;
import java.awt.image.*;
import javax.imageio.ImageIO;
import java.nio.ByteBuffer;

public class JavaSocketServerUI {
    private JFrame frame;
    private JLabel label;

    public static void main(String[] args) {
        JavaSocketServerUI server = new JavaSocketServerUI();
        server.createUI();
        server.startServer(5000);
    }

    public void createUI() {
        frame = new JFrame("Java UI");
        label = new JLabel();
        frame.getContentPane().add(label);
        frame.setSize(640, 480);
        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        frame.setVisible(true);
    }

    public void startServer(int port) {
        try (ServerSocket serverSocket = new ServerSocket(port)) {
            System.out.println("서버가 포트 " + port + "에서 시작되었습니다.");
            while (true) {
                System.out.println("클라이언트 연결 대기 중...");
                Socket clientSocket = serverSocket.accept();
                System.out.println("클라이언트가 연결되었습니다: " + clientSocket.getInetAddress());
                
                try {
                    InputStream inputStream = clientSocket.getInputStream();
                    System.out.println("입력 스트림을 받았습니다.");

                    // 이미지 크기 정보 읽기
                    byte[] sizeInfo = new byte[4];
                    inputStream.read(sizeInfo);
                    int size = ByteBuffer.wrap(sizeInfo).getInt();
                    System.out.println("이미지 크기: " + size + " 바이트");

                    // 이미지 데이터 읽기
                    byte[] imageData = new byte[size];
                    int bytesRead = 0;
                    while (bytesRead < size) {
                        int result = inputStream.read(imageData, bytesRead, size - bytesRead);
                        if (result == -1) break;
                        bytesRead += result;
                    }
                    System.out.println("이미지 데이터 수신 완료: " + bytesRead + " 바이트");

                    BufferedImage image = ImageIO.read(new ByteArrayInputStream(imageData));
                    if (image != null) {
                        System.out.println("이미지를 성공적으로 읽었습니다. 크기: " + image.getWidth() + "x" + image.getHeight());
                        updateUI(image);
                    } else {
                        System.out.println("이미지를 읽는데 실패했습니다.");
                    }
                } catch (IOException e) {
                    System.out.println("데이터 처리 중 오류 발생: " + e.getMessage());
                    e.printStackTrace();
                } finally {
                    clientSocket.close();
                    System.out.println("클라이언트 연결을 종료했습니다.");
                }
            }
        } catch (IOException e) {
            System.out.println("서버 오류: " + e.getMessage());
            e.printStackTrace();
        }
    }

    public void updateUI(BufferedImage image) {
        ImageIcon icon = new ImageIcon(image);
        label.setIcon(icon);
        frame.repaint();
        System.out.println("UI를 업데이트했습니다.");
    }
}