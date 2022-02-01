package com.simonmdsn;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableScheduling
public class MyPortfolioBackendApplication {

    public static void main(String[] args) {
        SpringApplication.run(MyPortfolioBackendApplication.class, args);
    }

}
