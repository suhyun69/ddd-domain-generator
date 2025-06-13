#!/bin/bash

PACKAGE_NAME="$1"
PACKAGE_PATH="$2"

DOMAIN_NAME="auth"
CAP_DOMAIN="$(tr '[:lower:]' '[:upper:]' <<< ${DOMAIN_NAME:0:1})${DOMAIN_NAME:1}"
BASE_DIR="../src/main/java/${PACKAGE_PATH}/${DOMAIN_NAME}"

echo "📁 생성 중: $CAP_DOMAIN 도메인"

mkdir -p $BASE_DIR/adapter/in/web/request
mkdir -p $BASE_DIR/adapter/in/web/response
mkdir -p $BASE_DIR/port/in/request
mkdir -p $BASE_DIR/port/in/response
mkdir -p $BASE_DIR/domain
mkdir -p $BASE_DIR/application/service
mkdir -p $BASE_DIR/port/out
mkdir -p $BASE_DIR/adapter/out/persistence/entity
mkdir -p $BASE_DIR/adapter/out/persistence/mapper
mkdir -p $BASE_DIR/adapter/out/persistence/repository

# EmailLoginWebRequest
cat <<EOF > $BASE_DIR/adapter/in/web/request/EmailLoginWebRequest.java
package ${PACKAGE_NAME}.${DOMAIN_NAME}.adapter.in.web.request;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@AllArgsConstructor
@NoArgsConstructor
public class EmailLoginWebRequest {
    private String email;
    private String password;
}
EOF

# EmailSignupWebRequest
cat <<EOF > $BASE_DIR/adapter/in/web/request/EmailSignupWebRequest.java
package ${PACKAGE_NAME}.${DOMAIN_NAME}.adapter.in.web.request;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@AllArgsConstructor
@NoArgsConstructor
public class EmailSignupWebRequest {
    private String email;
    private String password;
}
EOF

# EmailSignupWebResponse
cat <<EOF > $BASE_DIR/adapter/in/web/response/EmailSignupWebResponse.java
package ${PACKAGE_NAME}.${DOMAIN_NAME}.adapter.in.web.response;

import ${PACKAGE_NAME}.user.port.in.response.UserAppResponse;
import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class EmailSignupWebResponse {
    private String email;

    public EmailSignupWebResponse(UserAppResponse appRes) {
        this.email = appRes.getEmail();
    }
}
EOF

# LoginWebResponse
cat <<EOF > $BASE_DIR/adapter/in/web/response/LoginWebResponse.java
package ${PACKAGE_NAME}.${DOMAIN_NAME}.adapter.in.web.response;

import ${PACKAGE_NAME}.${DOMAIN_NAME}.port.in.response.LoginAppResponse;
import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class LoginWebResponse {
    private String token;
    private String refreshToken;

    public LoginWebResponse(LoginAppResponse appRes) {
        this.token = appRes.getToken();
        this.refreshToken = appRes.getRefreshToken();
    }
}
EOF

# ApiV1${CAP_DOMAIN}Controller
cat <<EOF > $BASE_DIR/adapter/in/web/ApiV1${CAP_DOMAIN}Controller.java
package ${PACKAGE_NAME}.${DOMAIN_NAME}.adapter.in.web;

import ${PACKAGE_NAME}.${DOMAIN_NAME}.adapter.in.web.request.EmailLoginWebRequest;
import ${PACKAGE_NAME}.${DOMAIN_NAME}.adapter.in.web.request.EmailSignupWebRequest;
import ${PACKAGE_NAME}.${DOMAIN_NAME}.adapter.in.web.response.EmailSignupWebResponse;
import ${PACKAGE_NAME}.${DOMAIN_NAME}.adapter.in.web.response.LoginWebResponse;
import ${PACKAGE_NAME}.${DOMAIN_NAME}.port.in.LoginUseCase;
import ${PACKAGE_NAME}.${DOMAIN_NAME}.port.in.LogoutUseCase;
import ${PACKAGE_NAME}.${DOMAIN_NAME}.port.in.request.EmailLoginAppRequest;
import ${PACKAGE_NAME}.${DOMAIN_NAME}.port.in.response.LoginAppResponse;
import ${PACKAGE_NAME}.user.port.in.SignupUseCase;
import ${PACKAGE_NAME}.user.port.in.request.EmailSignupAppRequest;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseCookie;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/${DOMAIN_NAME}")
@Tag(name = "${DOMAIN_NAME}", description = "${DOMAIN_NAME} API Document")
@RequiredArgsConstructor
public class ApiV1${CAP_DOMAIN}Controller {

    private final SignupUseCase signupUseCase;
    private final LoginUseCase loginUseCase;
    private final LogoutUseCase logoutUseCase;
    private final PasswordEncoder passwordEncoder;

    @PostMapping("/signup/email")
    @Operation(summary = "Signup", description = "by email")
    public ResponseEntity<EmailSignupWebResponse> emailSignup(@Valid @RequestBody EmailSignupWebRequest webReq) {

        EmailSignupAppRequest appReq = EmailSignupAppRequest.builder()
                .email(webReq.getEmail())
                .password(passwordEncoder.encode(webReq.getPassword()))
                .build();
        EmailSignupWebResponse response = new EmailSignupWebResponse(signupUseCase.emailSignup(appReq));

        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(response);
    }

    @PostMapping("/login/email")
    @Operation(summary = "Login", description = "by email")
    public ResponseEntity<LoginWebResponse> emailLogin(@Valid @RequestBody EmailLoginWebRequest webReq, HttpServletResponse response) {
        EmailLoginAppRequest appReq = EmailLoginAppRequest.builder()
                .email(webReq.getEmail())
                .password(webReq.getPassword())
                .build();

        LoginAppResponse appRes = loginUseCase.emailLogin(appReq);

        // accessToken은 쿠키로
        ResponseCookie accessCookie = ResponseCookie.from("accessToken", appRes.getToken())
                .httpOnly(true).secure(true).path("/").maxAge(15 * 60).build();
        response.addHeader(HttpHeaders.SET_COOKIE, accessCookie.toString());

        // refreshToken도 쿠키로
        ResponseCookie refreshCookie = ResponseCookie.from("refreshToken", appRes.getRefreshToken())
                .httpOnly(true).secure(true).path("/").maxAge(7 * 24 * 60 * 60).build();
        response.addHeader(HttpHeaders.SET_COOKIE, refreshCookie.toString());

        LoginWebResponse webRes = new LoginWebResponse(appRes);
        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(webRes);
    }

    @PostMapping("/${DOMAIN_NAME}/refresh")
    public ResponseEntity<?> refreshToken(HttpServletRequest request, HttpServletResponse response) {

        LoginAppResponse appRes = loginUseCase.refresh(request);

        ResponseCookie accessCookie = ResponseCookie.from("accessToken", appRes.getRefreshToken())
                .httpOnly(true).secure(true).path("/").maxAge(15 * 60).build();
        response.addHeader(HttpHeaders.SET_COOKIE, accessCookie.toString());

        LoginWebResponse webRes = new LoginWebResponse(appRes);
        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(webRes);
    }

    @PostMapping("/${DOMAIN_NAME}/logout")
    public ResponseEntity<?> logout(HttpServletRequest request, HttpServletResponse response) {

        logoutUseCase.logout(request);

        // 쿠키 삭제
        ResponseCookie deleteAccess = ResponseCookie.from("accessToken", "")
                .httpOnly(true).secure(true).path("/").maxAge(0).build();
        ResponseCookie deleteRefresh = ResponseCookie.from("refreshToken", "")
                .httpOnly(true).secure(true).path("/").maxAge(0).build();

        response.addHeader(HttpHeaders.SET_COOKIE, deleteAccess.toString());
        response.addHeader(HttpHeaders.SET_COOKIE, deleteRefresh.toString());

        return ResponseEntity.ok("로그아웃 완료");
    }
}
EOF

# EmailLoginAppRequest
cat <<EOF > $BASE_DIR/port/in/request/EmailLoginAppRequest.java
package ${PACKAGE_NAME}.${DOMAIN_NAME}.port.in.request;

import lombok.Builder;
import lombok.Value;

@Value
@Builder
public class EmailLoginAppRequest {
    String email;
    String password;
}
EOF

# LoginAppResponse
cat <<EOF > $BASE_DIR/port/in/response/LoginAppResponse.java
package ${PACKAGE_NAME}.${DOMAIN_NAME}.port.in.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
@AllArgsConstructor
public class LoginAppResponse {
    private String token;
    private String refreshToken;
}
EOF

# LoginUseCase
cat <<EOF > $BASE_DIR/port/in/LoginUseCase.java
package ${PACKAGE_NAME}.${DOMAIN_NAME}.port.in;

import ${PACKAGE_NAME}.${DOMAIN_NAME}.port.in.request.EmailLoginAppRequest;
import ${PACKAGE_NAME}.${DOMAIN_NAME}.port.in.response.LoginAppResponse;
import jakarta.servlet.http.HttpServletRequest;

public interface LoginUseCase {
    LoginAppResponse emailLogin(EmailLoginAppRequest appReq);
    LoginAppResponse refresh(HttpServletRequest request);
}
EOF

# LogoutUseCase
cat <<EOF > $BASE_DIR/port/in/LogoutUseCase.java
package ${PACKAGE_NAME}.${DOMAIN_NAME}.port.in;

import jakarta.servlet.http.HttpServletRequest;

public interface LogoutUseCase {
    void logout(HttpServletRequest request);
}

EOF

# RefreshToken
cat <<EOF > $BASE_DIR/domain/RefreshToken.java
package ${PACKAGE_NAME}.${DOMAIN_NAME}.domain;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor

public class RefreshToken {
    private String username;
    private String refreshToken;
    private LocalDateTime expiryDate;
}
EOF

# ${DOMAIN_NAME}Service
cat <<EOF > $BASE_DIR/application/service/${CAP_DOMAIN}Service.java
package ${PACKAGE_NAME}.${DOMAIN_NAME}.application.service;

import ${PACKAGE_NAME}.${DOMAIN_NAME}.port.in.LoginUseCase;
import ${PACKAGE_NAME}.${DOMAIN_NAME}.domain.RefreshToken;
import ${PACKAGE_NAME}.${DOMAIN_NAME}.port.in.LoginUseCase;
import ${PACKAGE_NAME}.${DOMAIN_NAME}.port.in.LogoutUseCase;
import ${PACKAGE_NAME}.${DOMAIN_NAME}.port.in.request.EmailLoginAppRequest;
import ${PACKAGE_NAME}.${DOMAIN_NAME}.port.in.response.LoginAppResponse;
import ${PACKAGE_NAME}.${DOMAIN_NAME}.port.out.CreateTokenPort;
import ${PACKAGE_NAME}.${DOMAIN_NAME}.port.out.DeleteTokenPort;
import ${PACKAGE_NAME}.${DOMAIN_NAME}.port.out.SelectTokenPort;
import ${PACKAGE_NAME}.global.exception.CustomException;
import ${PACKAGE_NAME}.global.exception.ErrorCode;
import ${PACKAGE_NAME}.security.JwtUtil;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.stereotype.Service;

import java.util.Arrays;

@Service
@RequiredArgsConstructor
public class ${CAP_DOMAIN}Service implements LoginUseCase, LogoutUseCase {

    private final AuthenticationManager authenticationManager;
    private final JwtUtil jwtUtil;
    private final CreateTokenPort createTokenPort;
    private final SelectTokenPort selectTokenPort;
    private final DeleteTokenPort deleteTokenPort;

    @Override
    public LoginAppResponse emailLogin(EmailLoginAppRequest appReq) {

        authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(appReq.getEmail(), appReq.getPassword()));

        String token = jwtUtil.generateToken(appReq.getEmail());
        String refreshToken = jwtUtil.generateRefreshToken(appReq.getEmail());

        createTokenPort.createRefreshToken(appReq.getEmail(), refreshToken);

        return LoginAppResponse.builder()
                .token(token)
                .refreshToken(refreshToken)
                .build();
    }

    @Override
    public LoginAppResponse refresh(HttpServletRequest request) {

        String refreshToken = Arrays.stream(request.getCookies())
                .filter(c -> c.getName().equals("refreshToken"))
                .findFirst()
                .map(Cookie::getValue)
                .orElse(null);
        if (refreshToken == null || !jwtUtil.validateToken(refreshToken)) {
            throw new CustomException(ErrorCode.UNAUTHORIZED, "Refresh token invalid");
        }

        String email = jwtUtil.extractUsername(refreshToken);
        RefreshToken saved = selectTokenPort.findRefreshTokenByEmail(email).orElse(null);
        if (saved == null || !saved.equals(refreshToken)) {
            throw new CustomException(ErrorCode.UNAUTHORIZED, "Refresh token mismatch");
        }

        String newToken = jwtUtil.generateToken(email);

        return LoginAppResponse.builder()
                .token(newToken)
                .build();
    }

    @Override
    public void logout(HttpServletRequest request) {

        String email = jwtUtil.extractUsernameFromRequest(request);
        deleteTokenPort.deleteRefreshToken(email);
    }
}
EOF

# CreateTokenPort
cat <<EOF > $BASE_DIR/port/out/CreateTokenPort.java
package ${PACKAGE_NAME}.${DOMAIN_NAME}.port.out;

public interface CreateTokenPort {
    void createRefreshToken(String email, String refreshToken);
}
EOF

# SelectTokenPort
cat <<EOF > $BASE_DIR/port/out/SelectTokenPort.java
package ${PACKAGE_NAME}.${DOMAIN_NAME}.port.out;

import ${PACKAGE_NAME}.${DOMAIN_NAME}.domain.RefreshToken;

import java.util.Optional;

public interface SelectTokenPort {
    Optional<RefreshToken> findRefreshTokenByEmail(String email);
}

EOF

# DeleteTokenPort
cat <<EOF > $BASE_DIR/port/out/DeleteTokenPort.java
package ${PACKAGE_NAME}.${DOMAIN_NAME}.port.out;

public interface DeleteTokenPort {
    void deleteRefreshToken(String email);
}
EOF


# RefreshTokenJpaEntity
cat <<EOF > $BASE_DIR/adapter/out/persistence/entity/RefreshTokenJpaEntity.java
package ${PACKAGE_NAME}.${DOMAIN_NAME}.adapter.out.persistence.entity;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Getter
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class RefreshTokenJpaEntity {
    @Id
    private String username;
    private String refreshToken;
    private LocalDateTime expiryDate;
}
EOF

# RefreshTokenMapper
cat <<EOF > $BASE_DIR/adapter/out/persistence/mapper/RefreshTokenMapper.java
package ${PACKAGE_NAME}.${DOMAIN_NAME}.adapter.out.persistence.mapper;

import ${PACKAGE_NAME}.${DOMAIN_NAME}.adapter.out.persistence.entity.RefreshTokenJpaEntity;
import ${PACKAGE_NAME}.${DOMAIN_NAME}.domain.RefreshToken;
import ${PACKAGE_NAME}.user.domain.User;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;

@Component
@RequiredArgsConstructor
public class RefreshTokenMapper {

    public RefreshTokenJpaEntity mapToJpaEntity(String email, String refreshToken) {
        return RefreshTokenJpaEntity.builder()
                .username(email)
                .refreshToken(refreshToken)
                .expiryDate(LocalDateTime.now().plusDays(7))
                .build();
    }

    public RefreshToken mapToDomainEntity(RefreshTokenJpaEntity refreshTokenT) {
        return RefreshToken.builder()
                .username(refreshTokenT.getUsername())
                .refreshToken(refreshTokenT.getRefreshToken())
                .expiryDate(refreshTokenT.getExpiryDate())
                .build();
    }
}
EOF

# RefreshTokenRepository
cat <<EOF > $BASE_DIR/adapter/out/persistence/repository/RefreshTokenRepository.java
package ${PACKAGE_NAME}.${DOMAIN_NAME}.adapter.out.persistence.repository;

import ${PACKAGE_NAME}.${DOMAIN_NAME}.adapter.out.persistence.entity.RefreshTokenJpaEntity;
import org.springframework.data.jpa.repository.JpaRepository;

public interface RefreshTokenRepository extends JpaRepository<RefreshTokenJpaEntity, String> {}
EOF

# TokenPersistenceAdapter
cat <<EOF > $BASE_DIR/adapter/out/persistence/TokenPersistenceAdapter.java
package ${PACKAGE_NAME}.${DOMAIN_NAME}.adapter.out.persistence;

import ${PACKAGE_NAME}.${DOMAIN_NAME}.adapter.out.persistence.entity.RefreshTokenJpaEntity;
import ${PACKAGE_NAME}.${DOMAIN_NAME}.adapter.out.persistence.mapper.RefreshTokenMapper;
import ${PACKAGE_NAME}.${DOMAIN_NAME}.adapter.out.persistence.repository.RefreshTokenRepository;
import ${PACKAGE_NAME}.${DOMAIN_NAME}.domain.RefreshToken;
import ${PACKAGE_NAME}.${DOMAIN_NAME}.port.out.CreateTokenPort;
import ${PACKAGE_NAME}.${DOMAIN_NAME}.port.out.DeleteTokenPort;
import ${PACKAGE_NAME}.${DOMAIN_NAME}.port.out.SelectTokenPort;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.Optional;

@Component
@RequiredArgsConstructor
public class TokenPersistenceAdapter implements CreateTokenPort, SelectTokenPort, DeleteTokenPort {

    private final RefreshTokenRepository refreshTokenRepository;
    private final RefreshTokenMapper refreshTokenMapper;

    @Override
    public void createRefreshToken(String email, String refreshToken) {

        RefreshTokenJpaEntity refreshTokenT = refreshTokenMapper.mapToJpaEntity(email, refreshToken);
        refreshTokenRepository.save(refreshTokenT);
    }

    @Override
    public Optional<RefreshToken> findRefreshTokenByEmail(String email) {

        return refreshTokenRepository.findById(email)
                .map(refreshTokenMapper::mapToDomainEntity);
    }

    @Override
    public void deleteRefreshToken(String email) {
        refreshTokenRepository.deleteById(email);
    }
}
EOF

echo "✅ $CAP_DOMAIN 도메인 생성 완료"
