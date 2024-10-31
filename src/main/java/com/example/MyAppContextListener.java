package com.example;

import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;

import com.mysql.cj.jdbc.AbandonedConnectionCleanupThread;

@WebListener // 어노테이션을 사용하여 리스너 등록
public class MyAppContextListener implements ServletContextListener {

	// 애플리케이션이 시작될 때 호출됩니다.
	@Override
	public void contextInitialized(ServletContextEvent sce) {
		System.out.println("Application started");
	}

	// 애플리케이션이 종료될 때 호출됩니다.
	@Override
	public void contextDestroyed(ServletContextEvent sce) {
		AbandonedConnectionCleanupThread.checkedShutdown();
		System.out.println("MySQL AbandonedConnectionCleanupThread stopped.");
	}
}