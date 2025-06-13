#!/bin/bash

PACKAGE_NAME="$1"
PACKAGE_PATH="$2"

BASE_DIR="../src/main/java/${PACKAGE_PATH}"

echo "📁 생성 중: global.exception"

mkdir -p $BASE_DIR/global/exception

# CustomException
cat <<EOF > $BASE_DIR/global/exception/CustomException.java
package ${PACKAGE_NAME}.global.exception;

import lombok.Getter;

@Getter
public class CustomException extends RuntimeException {
    private final ErrorCode errorCode;

    public CustomException(ErrorCode code) {
        super(code.getMessage());
        this.errorCode = code;
    }

    public CustomException(ErrorCode code, String message) {
        super(message);
        this.errorCode = code;
    }
}
EOF

# ErrorCode
cat <<EOF > $BASE_DIR/global/exception/ErrorCode.java
package ${PACKAGE_NAME}.global.exception;

import lombok.Getter;
import org.springframework.http.HttpStatus;

@Getter
public enum ErrorCode {
    USER_NOT_FOUND("사용자를 찾을 수 없습니다", HttpStatus.NOT_FOUND),
    EMAIL_ALREADY_EXISTS("이미 존재하는 이메일입니다", HttpStatus.CONFLICT),
    INVALID_REQUEST("잘못된 요청입니다", HttpStatus.BAD_REQUEST),
    UNAUTHORIZED("", HttpStatus.UNAUTHORIZED);

    private final String message;
    private final HttpStatus status;

    ErrorCode(String message, HttpStatus status) {
        this.message = message;
        this.status = status;
    }
}
EOF

# ErrorResponse
cat <<EOF > $BASE_DIR/global/exception/ErrorResponse.java
package ${PACKAGE_NAME}.global.exception;

import lombok.Getter;

import java.time.LocalDateTime;
import java.util.List;

@Getter
public class ErrorResponse {
    private final LocalDateTime timestamp = LocalDateTime.now();
    private final int status;
    private final String error;
    private final String message;
    private final List<FieldErrorResponse> fieldErrors;

    // 일반 오류용
    public ErrorResponse(ErrorCode code) {
        this.status = code.getStatus().value();
        this.error = code.getStatus().name();
        this.message = code.getMessage();
        this.fieldErrors = null;
    }

    // 필드 오류용
    public ErrorResponse(ErrorCode code, List<FieldErrorResponse> fieldErrors) {
        this.status = code.getStatus().value();
        this.error = code.getStatus().name();
        this.message = code.getMessage();
        this.fieldErrors = fieldErrors;
    }
}
EOF

# FieldErrorResponse
cat <<EOF > $BASE_DIR/global/exception/FieldErrorResponse.java
package ${PACKAGE_NAME}.global.exception;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class FieldErrorResponse {
    private final String field;
    private final String message;
}
EOF

# GlobalExceptionHandler
cat <<EOF > $BASE_DIR/global/exception/GlobalExceptionHandler.java
package ${PACKAGE_NAME}.global.exception;

import io.swagger.v3.oas.annotations.Hidden;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.util.List;
import java.util.stream.Collectors;

@Hidden
@RestControllerAdvice
public class GlobalExceptionHandler {

    // @Valid 검증 실패 처리
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ErrorResponse> handleValidationException(MethodArgumentNotValidException e) {
        BindingResult bindingResult = e.getBindingResult();

        List<FieldErrorResponse> fieldErrors = bindingResult.getFieldErrors().stream()
                .map(error -> new FieldErrorResponse(error.getField(), error.getDefaultMessage()))
                .collect(Collectors.toList());

        ErrorResponse response = new ErrorResponse(ErrorCode.INVALID_REQUEST, fieldErrors);
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response);
    }

    // 커스텀 예외 처리
    @ExceptionHandler(CustomException.class)
    public ResponseEntity<ErrorResponse> handleCustomException(CustomException e) {
        ErrorCode code = e.getErrorCode();
        return ResponseEntity
                .status(code.getStatus())
                .body(new ErrorResponse(code));
    }

    // 기본 예외 처리
    @ExceptionHandler(Exception.class)
    public ResponseEntity<ErrorResponse> handleException(Exception e) {
        ErrorCode defaultError = ErrorCode.INVALID_REQUEST;
        return ResponseEntity
                .status(defaultError.getStatus())
                .body(new ErrorResponse(defaultError));
    }
}
EOF

# UserNotFoundException
cat <<EOF > $BASE_DIR/global/exception/UserNotFoundException.java
package ${PACKAGE_NAME}.global.exception;

public class UserNotFoundException extends CustomException {
    public UserNotFoundException() {
        super(ErrorCode.USER_NOT_FOUND);
    }
}

/*
    readUserPort.findUserByEmail(email)
        .orElseThrow(UserNotFoundException::new);
 */
EOF

echo "✅ generate_global_exception 생성 완료"
