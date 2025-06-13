#!/bin/bash

PACKAGE_NAME="$1"
PACKAGE_PATH="$2"

DOMAIN_NAME="user"
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

# Update${CAP_DOMAIN}WebRequest
cat <<EOF > $BASE_DIR/adapter/in/web/request/Update${CAP_DOMAIN}WebRequest.java
package ${PACKAGE_NAME}.${DOMAIN_NAME}.adapter.in.web.request;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@AllArgsConstructor
@NoArgsConstructor
public class Update${CAP_DOMAIN}WebRequest {
    private String password;
}
EOF


# ${CAP_DOMAIN}WebResponse
cat <<EOF > $BASE_DIR/adapter/in/web/response/${CAP_DOMAIN}WebResponse.java
package ${PACKAGE_NAME}.${DOMAIN_NAME}.adapter.in.web.response;

import ${PACKAGE_NAME}.${DOMAIN_NAME}.port.in.response.${CAP_DOMAIN}AppResponse;
import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class ${CAP_DOMAIN}WebResponse {
    private String email;

    public ${CAP_DOMAIN}WebResponse(${CAP_DOMAIN}AppResponse appRes) {
        this.email = appRes.getEmail();
    }
}
EOF

# ApiV1${CAP_DOMAIN}Controller
cat <<EOF > $BASE_DIR/adapter/in/web/ApiV1${CAP_DOMAIN}Controller.java
package ${PACKAGE_NAME}.${DOMAIN_NAME}.adapter.in.web;

import ${PACKAGE_NAME}.${DOMAIN_NAME}.adapter.in.web.request.Update${CAP_DOMAIN}WebRequest;
import ${PACKAGE_NAME}.${DOMAIN_NAME}.adapter.in.web.response.${CAP_DOMAIN}WebResponse;
import ${PACKAGE_NAME}.${DOMAIN_NAME}.port.in.Find${CAP_DOMAIN}UseCase;
import ${PACKAGE_NAME}.${DOMAIN_NAME}.port.in.Update${CAP_DOMAIN}UseCase;
import ${PACKAGE_NAME}.${DOMAIN_NAME}.port.in.request.Update${CAP_DOMAIN}AppRequest;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/v1/${DOMAIN_NAME}")
@Tag(name = "${CAP_DOMAIN}", description = "${CAP_DOMAIN} API Document")
@RequiredArgsConstructor
public class ApiV1${CAP_DOMAIN}Controller {

    private final Find${CAP_DOMAIN}UseCase find${CAP_DOMAIN}UseCase;
    private final Update${CAP_DOMAIN}UseCase update${CAP_DOMAIN}UseCase;

    @GetMapping("/{email}")
    @Operation(summary = "Find ${CAP_DOMAIN}", description = "by Email")
    public ResponseEntity<${CAP_DOMAIN}WebResponse> findByEmail(@RequestParam("email") String email) {

        ${CAP_DOMAIN}WebResponse response = new ${CAP_DOMAIN}WebResponse(find${CAP_DOMAIN}UseCase.findByEmail(email));

        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(response);
    }

    @GetMapping()
    @Operation(summary = "Find ${CAP_DOMAIN}s", description = "Find ${CAP_DOMAIN}s")
    public ResponseEntity<List<${CAP_DOMAIN}WebResponse>> findAll() {

        List<${CAP_DOMAIN}WebResponse> response = find${CAP_DOMAIN}UseCase.findAll().stream()
                .map(${CAP_DOMAIN}WebResponse::new)
                .collect(Collectors.toList());

        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(response);
    }

    @PutMapping("/{id}")
    @Operation(summary = "Update ${CAP_DOMAIN}", description = "Update ${CAP_DOMAIN}")
    public ResponseEntity<${CAP_DOMAIN}WebResponse> update(@RequestParam("id") String id, @Valid @RequestBody Update${CAP_DOMAIN}WebRequest webReq) {

        Update${CAP_DOMAIN}AppRequest appReq = Update${CAP_DOMAIN}AppRequest.builder()
                .password(webReq.getPassword())
                .build();
        ${CAP_DOMAIN}WebResponse response = new ${CAP_DOMAIN}WebResponse(update${CAP_DOMAIN}UseCase.update(id, appReq));

        return ResponseEntity
                .status(HttpStatus.OK)
                .body(response);
    }
}
EOF

# EmailSignupAppRequest
cat <<EOF > $BASE_DIR/port/in/request/EmailSignupAppRequest.java
package ${PACKAGE_NAME}.${DOMAIN_NAME}.port.in.request;

import lombok.Builder;
import lombok.Value;

@Value
@Builder
public class EmailSignupAppRequest {
    String email;
    String password;
}
EOF

# Update${CAP_DOMAIN}AppRequest
cat <<EOF > $BASE_DIR/port/in/request/Update${CAP_DOMAIN}AppRequest.java
package ${PACKAGE_NAME}.${DOMAIN_NAME}.port.in.request;

import lombok.Builder;
import lombok.Value;

@Value
@Builder
public class Update${CAP_DOMAIN}AppRequest {
    String password;
}
EOF


# ${CAP_DOMAIN}AppResponse
cat <<EOF > $BASE_DIR/port/in/response/${CAP_DOMAIN}AppResponse.java
package ${PACKAGE_NAME}.${DOMAIN_NAME}.port.in.response;

import ${PACKAGE_NAME}.${DOMAIN_NAME}.domain.${CAP_DOMAIN};
import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class ${CAP_DOMAIN}AppResponse {
    private String email;

    public ${CAP_DOMAIN}AppResponse(${CAP_DOMAIN} ${DOMAIN_NAME}) {
        this.email = ${DOMAIN_NAME}.getEmail();
    }
}
EOF

# SignupUseCase
cat <<EOF > $BASE_DIR/port/in/SignupUseCase.java
package ${PACKAGE_NAME}.${DOMAIN_NAME}.port.in;

import ${PACKAGE_NAME}.${DOMAIN_NAME}.port.in.request.EmailSignupAppRequest;
import ${PACKAGE_NAME}.${DOMAIN_NAME}.port.in.response.${CAP_DOMAIN}AppResponse;

public interface SignupUseCase {
    ${CAP_DOMAIN}AppResponse emailSignup(EmailSignupAppRequest appReq);
}
EOF

# Find${CAP_DOMAIN}UseCase
cat <<EOF > $BASE_DIR/port/in/Find${CAP_DOMAIN}UseCase.java
package ${PACKAGE_NAME}.${DOMAIN_NAME}.port.in;

import ${PACKAGE_NAME}.${DOMAIN_NAME}.port.in.response.${CAP_DOMAIN}AppResponse;

import java.util.List;

public interface Find${CAP_DOMAIN}UseCase {
    ${CAP_DOMAIN}AppResponse findByEmail(String email);
    List<${CAP_DOMAIN}AppResponse> findAll();
}
EOF

# Update${CAP_DOMAIN}UseCase
cat <<EOF > $BASE_DIR/port/in/Update${CAP_DOMAIN}UseCase.java
package ${PACKAGE_NAME}.${DOMAIN_NAME}.port.in;

import ${PACKAGE_NAME}.${DOMAIN_NAME}.port.in.request.Update${CAP_DOMAIN}AppRequest;
import ${PACKAGE_NAME}.${DOMAIN_NAME}.port.in.response.${CAP_DOMAIN}AppResponse;

public interface Update${CAP_DOMAIN}UseCase {
    ${CAP_DOMAIN}AppResponse update(String id, Update${CAP_DOMAIN}AppRequest appReq);
}
EOF

# ${CAP_DOMAIN}
cat <<EOF > $BASE_DIR/domain/${CAP_DOMAIN}.java
package ${PACKAGE_NAME}.${DOMAIN_NAME}.domain;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ${CAP_DOMAIN} {
    private String email;
    private String password;
}
EOF

# ${CAP_DOMAIN}Service
cat <<EOF > $BASE_DIR/application/service/${CAP_DOMAIN}Service.java
package ${PACKAGE_NAME}.${DOMAIN_NAME}.application.service;

import ${PACKAGE_NAME}.${DOMAIN_NAME}.domain.${CAP_DOMAIN};
import ${PACKAGE_NAME}.${DOMAIN_NAME}.port.in.Find${CAP_DOMAIN}UseCase;
import ${PACKAGE_NAME}.${DOMAIN_NAME}.port.in.SignupUseCase;
import ${PACKAGE_NAME}.${DOMAIN_NAME}.port.in.Update${CAP_DOMAIN}UseCase;
import ${PACKAGE_NAME}.${DOMAIN_NAME}.port.in.request.EmailSignupAppRequest;
import ${PACKAGE_NAME}.${DOMAIN_NAME}.port.in.request.Update${CAP_DOMAIN}AppRequest;
import ${PACKAGE_NAME}.${DOMAIN_NAME}.port.in.response.${CAP_DOMAIN}AppResponse;
import ${PACKAGE_NAME}.${DOMAIN_NAME}.port.out.Create${CAP_DOMAIN}Port;
import ${PACKAGE_NAME}.${DOMAIN_NAME}.port.out.Read${CAP_DOMAIN}Port;
import ${PACKAGE_NAME}.${DOMAIN_NAME}.port.out.Update${CAP_DOMAIN}Port;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ${CAP_DOMAIN}Service implements SignupUseCase
        , Find${CAP_DOMAIN}UseCase
        , Update${CAP_DOMAIN}UseCase
{

    private final Create${CAP_DOMAIN}Port create${CAP_DOMAIN}Port;
    private final Read${CAP_DOMAIN}Port read${CAP_DOMAIN}Port;
    private final Update${CAP_DOMAIN}Port update${CAP_DOMAIN}Port;

    @Override
    public ${CAP_DOMAIN}AppResponse emailSignup(EmailSignupAppRequest appReq) {
        return new ${CAP_DOMAIN}AppResponse(create${CAP_DOMAIN}Port.create(appReq));
    }

    @Override
    public ${CAP_DOMAIN}AppResponse findByEmail(String id) {
        return read${CAP_DOMAIN}Port.findByEmail(id)
                .map(${CAP_DOMAIN}AppResponse::new)
                .orElse(null);
    }

    @Override
    public List<${CAP_DOMAIN}AppResponse> findAll() {
        return read${CAP_DOMAIN}Port.findAll().stream()
                .map(${CAP_DOMAIN}AppResponse::new)
                .collect(Collectors.toList());
    }

    @Override
    public ${CAP_DOMAIN}AppResponse update(String id, Update${CAP_DOMAIN}AppRequest appReq) {
        Optional<${CAP_DOMAIN}> optional${CAP_DOMAIN} = read${CAP_DOMAIN}Port.findByEmail(id);
        if (optional${CAP_DOMAIN}.isEmpty()) {
            throw new RuntimeException("${CAP_DOMAIN} not found");
        }

        ${CAP_DOMAIN} ${DOMAIN_NAME} = optional${CAP_DOMAIN}.get();
        ${DOMAIN_NAME}.setPassword(appReq.getPassword());

        ${CAP_DOMAIN} updated = update${CAP_DOMAIN}Port.update(${DOMAIN_NAME});
        return new ${CAP_DOMAIN}AppResponse(updated);
    }
}
EOF

# Create${CAP_DOMAIN}Port
cat <<EOF > $BASE_DIR/port/out/Create${CAP_DOMAIN}Port.java
package ${PACKAGE_NAME}.${DOMAIN_NAME}.port.out;

import ${PACKAGE_NAME}.${DOMAIN_NAME}.domain.${CAP_DOMAIN};
import ${PACKAGE_NAME}.${DOMAIN_NAME}.port.in.request.EmailSignupAppRequest;

public interface Create${CAP_DOMAIN}Port {
    ${CAP_DOMAIN} create(EmailSignupAppRequest appReq);
}
EOF

# Read${CAP_DOMAIN}Port
cat <<EOF > $BASE_DIR/port/out/Read${CAP_DOMAIN}Port.java
package ${PACKAGE_NAME}.${DOMAIN_NAME}.port.out;

import ${PACKAGE_NAME}.${DOMAIN_NAME}.domain.${CAP_DOMAIN};

import java.util.List;
import java.util.Optional;

public interface Read${CAP_DOMAIN}Port {
    List<${CAP_DOMAIN}> findAll();
    Optional<${CAP_DOMAIN}> findByEmail(String email);
}
EOF

# Update${CAP_DOMAIN}Port
cat <<EOF > $BASE_DIR/port/out/Update${CAP_DOMAIN}Port.java
package ${PACKAGE_NAME}.${DOMAIN_NAME}.port.out;

import ${PACKAGE_NAME}.${DOMAIN_NAME}.domain.${CAP_DOMAIN};

public interface Update${CAP_DOMAIN}Port {
    ${CAP_DOMAIN} update(${CAP_DOMAIN} ${DOMAIN_NAME});
}
EOF

# ${CAP_DOMAIN}JpaEntity
cat <<EOF > $BASE_DIR/adapter/out/persistence/entity/${CAP_DOMAIN}JpaEntity.java
package ${PACKAGE_NAME}.${DOMAIN_NAME}.adapter.out.persistence.entity;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "${DOMAIN_NAME}s")
@Data
@Builder // mapToJpaEntity
@NoArgsConstructor
@AllArgsConstructor
public class ${CAP_DOMAIN}JpaEntity {
    @Id
    private String email;
    private String password;
}
EOF

# ${CAP_DOMAIN}Mapper
cat <<EOF > $BASE_DIR/adapter/out/persistence/mapper/${CAP_DOMAIN}Mapper.java
package ${PACKAGE_NAME}.${DOMAIN_NAME}.adapter.out.persistence.mapper;

import ${PACKAGE_NAME}.${DOMAIN_NAME}.adapter.out.persistence.entity.${CAP_DOMAIN}JpaEntity;
import ${PACKAGE_NAME}.${DOMAIN_NAME}.domain.${CAP_DOMAIN};
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class ${CAP_DOMAIN}Mapper {
    public ${CAP_DOMAIN}JpaEntity mapToJpaEntity(${CAP_DOMAIN} ${DOMAIN_NAME}) {
        return ${CAP_DOMAIN}JpaEntity.builder()
                .email(${DOMAIN_NAME}.getEmail())
                .password(${DOMAIN_NAME}.getPassword())
                .build();
    }

    public ${CAP_DOMAIN} mapToDomainEntity(${CAP_DOMAIN}JpaEntity ${DOMAIN_NAME}T) {
        return ${CAP_DOMAIN}.builder()
                .email(${DOMAIN_NAME}T.getEmail())
                .password(${DOMAIN_NAME}T.getPassword())
                .build();
    }
}
EOF

# ${CAP_DOMAIN}Repository
cat <<EOF > $BASE_DIR/adapter/out/persistence/repository/${CAP_DOMAIN}Repository.java
package ${PACKAGE_NAME}.${DOMAIN_NAME}.adapter.out.persistence.repository;

import ${PACKAGE_NAME}.${DOMAIN_NAME}.adapter.out.persistence.entity.${CAP_DOMAIN}JpaEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface ${CAP_DOMAIN}Repository extends JpaRepository<${CAP_DOMAIN}JpaEntity, String> {
    Optional<${CAP_DOMAIN}JpaEntity> findByEmail(String email);
}
EOF

# ${CAP_DOMAIN}PersistenceAdapter
cat <<EOF > $BASE_DIR/adapter/out/persistence/${CAP_DOMAIN}PersistenceAdapter.java
package ${PACKAGE_NAME}.${DOMAIN_NAME}.adapter.out.persistence;

import ${PACKAGE_NAME}.${DOMAIN_NAME}.adapter.out.persistence.entity.${CAP_DOMAIN}JpaEntity;
import ${PACKAGE_NAME}.${DOMAIN_NAME}.adapter.out.persistence.mapper.${CAP_DOMAIN}Mapper;
import ${PACKAGE_NAME}.${DOMAIN_NAME}.adapter.out.persistence.repository.${CAP_DOMAIN}Repository;
import ${PACKAGE_NAME}.${DOMAIN_NAME}.domain.${CAP_DOMAIN};
import ${PACKAGE_NAME}.${DOMAIN_NAME}.port.in.request.EmailSignupAppRequest;
import ${PACKAGE_NAME}.${DOMAIN_NAME}.port.out.Create${CAP_DOMAIN}Port;
import ${PACKAGE_NAME}.${DOMAIN_NAME}.port.out.Read${CAP_DOMAIN}Port;
import ${PACKAGE_NAME}.${DOMAIN_NAME}.port.out.Update${CAP_DOMAIN}Port;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.Optional;

@Component
@RequiredArgsConstructor
public class ${CAP_DOMAIN}PersistenceAdapter implements Create${CAP_DOMAIN}Port
        , Read${CAP_DOMAIN}Port
        , Update${CAP_DOMAIN}Port
{

    private final ${CAP_DOMAIN}Mapper ${DOMAIN_NAME}Mapper;
    private final ${CAP_DOMAIN}Repository ${DOMAIN_NAME}Repository;

    @Override
    public ${CAP_DOMAIN} create(EmailSignupAppRequest appReq) {

        ${CAP_DOMAIN}JpaEntity ${DOMAIN_NAME}T = ${CAP_DOMAIN}JpaEntity.builder()
                .email(appReq.getEmail())
                .password(appReq.getPassword())
                .build();
        return ${DOMAIN_NAME}Mapper.mapToDomainEntity(${DOMAIN_NAME}Repository.save(${DOMAIN_NAME}T));
    }

    @Override
    public List<${CAP_DOMAIN}> findAll() {
        return ${DOMAIN_NAME}Repository.findAll().stream()
                .map(${DOMAIN_NAME}Mapper::mapToDomainEntity)
                .toList();
    }

    @Override
    public Optional<${CAP_DOMAIN}> findByEmail(String email) {
        return ${DOMAIN_NAME}Repository.findByEmail(email)
                .map(${DOMAIN_NAME}Mapper::mapToDomainEntity);
    }

    @Override
    public ${CAP_DOMAIN} update(${CAP_DOMAIN} ${DOMAIN_NAME}) {
        ${CAP_DOMAIN}JpaEntity ${DOMAIN_NAME}T = ${DOMAIN_NAME}Mapper.mapToJpaEntity(${DOMAIN_NAME});
        ${CAP_DOMAIN}JpaEntity updated = ${DOMAIN_NAME}Repository.save(${DOMAIN_NAME}T);
        return ${DOMAIN_NAME}Mapper.mapToDomainEntity(updated);
    }
}
EOF

echo "✅ $CAP_DOMAIN 도메인 생성 완료"
