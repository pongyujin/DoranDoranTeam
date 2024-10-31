package com.doran.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.client.RestTemplate;

@Configuration
public class AppConfig {

	// api 사용을 위해 필요한 RestTemplate
	@Bean
	public RestTemplate restTemplate() {
		return new RestTemplate();
	}
}
