package com.campus.life;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * 校园智慧生活 APP 后端服务启动类
 */
@SpringBootApplication
@MapperScan("com.campus.life.mapper")
public class CampusLifeApplication {

    public static void main(String[] args) {
        SpringApplication.run(CampusLifeApplication.class, args);
        System.out.println("""

                ╔══════════════════════════════════════════════╗
                ║   校园智慧生活后端服务启动成功                  ║
                ║   接口地址: http://localhost:8080/api         ║
                ║   接口文档: http://localhost:8080/api/doc.html ║
                ╚══════════════════════════════════════════════╝
                """);
    }
}
