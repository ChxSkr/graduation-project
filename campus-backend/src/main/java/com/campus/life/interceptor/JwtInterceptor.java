package com.campus.life.interceptor;

import com.campus.life.common.Result;
import com.campus.life.common.ResultCode;
import com.campus.life.utils.JwtUtils;
import com.campus.life.utils.UserContext;
import com.fasterxml.jackson.databind.ObjectMapper;
import io.jsonwebtoken.Claims;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;
import org.springframework.web.servlet.HandlerInterceptor;

/**
 * JWT 认证拦截器
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class JwtInterceptor implements HandlerInterceptor {

    private final JwtUtils jwtUtils;
    private final ObjectMapper objectMapper;

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
        // OPTIONS 预检直接放行
        if ("OPTIONS".equalsIgnoreCase(request.getMethod())) {
            return true;
        }

        String header = request.getHeader("Authorization");
        if (!StringUtils.hasText(header)) {
            return writeUnauthorized(response, "未提供认证Token");
        }

        String token = jwtUtils.removePrefix(header);
        if (!StringUtils.hasText(token)) {
            return writeUnauthorized(response, "Token格式不正确");
        }

        Claims claims = jwtUtils.parseToken(token);
        if (claims == null) {
            return writeUnauthorized(response, "Token无效");
        }

        if (!jwtUtils.validateToken(token)) {
            return writeUnauthorized(response, "Token已过期");
        }

        // 设置用户上下文
        Object userIdObj = claims.get("userId");
        Long userId = null;
        if (userIdObj instanceof Number) {
            userId = ((Number) userIdObj).longValue();
        }
        if (userId == null) {
            return writeUnauthorized(response, "Token内容无效");
        }
        UserContext.setUserId(userId);
        UserContext.setStudentId((String) claims.get("studentId"));
        UserContext.setName((String) claims.get("name"));
        return true;
    }

    @Override
    public void afterCompletion(HttpServletRequest request, HttpServletResponse response, Object handler, Exception ex) {
        UserContext.clear();
    }

    private boolean writeUnauthorized(HttpServletResponse response, String message) throws Exception {
        response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
        response.setContentType("application/json;charset=UTF-8");
        Result<Void> result = Result.error(ResultCode.UNAUTHORIZED.getCode(), message);
        response.getWriter().write(objectMapper.writeValueAsString(result));
        return false;
    }
}
