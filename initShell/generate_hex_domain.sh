#!/bin/bash

if [ -z "$1" ]; then
  echo "⚠️  도메인 이름을 입력하세요. 예: ./generate_hex_domain.sh user"
  exit 1
fi

PACKAGE_NAME="$1"
PACKAGE_PATH="$2"

DOMAIN_NAME=$1
CAP_DOMAIN="$(tr '[:lower:]' '[:upper:]' <<< ${DOMAIN_NAME:0:1})${DOMAIN_NAME:1}"
BASE_DIR="../src/main/java/${PACKAGE_PATH}/$DOMAIN_NAME"

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

# Add$${CAP_DOMAIN}WebRequest
cat <<EOF > $BASE_DIR/adapter/in/web/request/Add${CAP_DOMAIN}WebRequest.java
package ${PACKAGE_NAME}.${DOMAIN_NAME}.adapter.in.web.request;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@AllArgsConstructor
@NoArgsConstructor
public class Add${CAP_DOMAIN}WebRequest {
    private String id;
    private String content;
}
EOF

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
    private String content;
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
    private String id;
    private String content;

    public ${CAP_DOMAIN}WebResponse(${CAP_DOMAIN}AppResponse appRes) {
        this.id = appRes.getId();
        this.content = appRes.getContent();
    }
}
EOF

# ApiV1${CAP_DOMAIN}Controller
cat <<EOF > $BASE_DIR/adapter/in/web/ApiV1${CAP_DOMAIN}Controller.java
package ${PACKAGE_NAME}.${DOMAIN_NAME}.adapter.in.web;

import ${PACKAGE_NAME}.${DOMAIN_NAME}.adapter.in.web.request.Add${CAP_DOMAIN}WebRequest;
import ${PACKAGE_NAME}.${DOMAIN_NAME}.adapter.in.web.request.Update${CAP_DOMAIN}WebRequest;
import ${PACKAGE_NAME}.${DOMAIN_NAME}.adapter.in.web.response.${CAP_DOMAIN}WebResponse;
import ${PACKAGE_NAME}.${DOMAIN_NAME}.port.in.Add${CAP_DOMAIN}UseCase;
import ${PACKAGE_NAME}.${DOMAIN_NAME}.port.in.Find${CAP_DOMAIN}UseCase;
import ${PACKAGE_NAME}.${DOMAIN_NAME}.port.in.Update${CAP_DOMAIN}UseCase;
import ${PACKAGE_NAME}.${DOMAIN_NAME}.port.in.request.Add${CAP_DOMAIN}AppRequest;
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

    private final Add${CAP_DOMAIN}UseCase add${CAP_DOMAIN}UseCase;
    private final Find${CAP_DOMAIN}UseCase find${CAP_DOMAIN}UseCase;
    private final Update${CAP_DOMAIN}UseCase update${CAP_DOMAIN}UseCase;

    @PostMapping
    @Operation(summary = "Add ${CAP_DOMAIN}", description = "Add ${CAP_DOMAIN}")
    public ResponseEntity<${CAP_DOMAIN}WebResponse> add(@Valid @RequestBody Add${CAP_DOMAIN}WebRequest webReq) {

        Add${CAP_DOMAIN}AppRequest appReq = Add${CAP_DOMAIN}AppRequest.builder()
                .id(webReq.getId())
                .content(webReq.getContent())
                .build();
        ${CAP_DOMAIN}WebResponse response = new ${CAP_DOMAIN}WebResponse(add${CAP_DOMAIN}UseCase.add(appReq));

        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(response);
    }

    @GetMapping("/{id}")
    @Operation(summary = "Find ${CAP_DOMAIN}", description = "Find ${CAP_DOMAIN}")
    public ResponseEntity<${CAP_DOMAIN}WebResponse> findById(@RequestParam("id") String id) {

        ${CAP_DOMAIN}WebResponse response = new ${CAP_DOMAIN}WebResponse(find${CAP_DOMAIN}UseCase.findById(id));

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
                .content(webReq.getContent())
                .build();
        ${CAP_DOMAIN}WebResponse response = new ${CAP_DOMAIN}WebResponse(update${CAP_DOMAIN}UseCase.update(id, appReq));

        return ResponseEntity
                .status(HttpStatus.OK)
                .body(response);
    }
}
EOF

# Add${CAP_DOMAIN}AppRequest
cat <<EOF > $BASE_DIR/port/in/request/Add${CAP_DOMAIN}AppRequest.java
package ${PACKAGE_NAME}.${DOMAIN_NAME}.port.in.request;

import lombok.Builder;
import lombok.Value;

@Value
@Builder
public class Add${CAP_DOMAIN}AppRequest {
    String id;
    String content;
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
    String id;
    String content;
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
    private String id;
    private String content;

    public ${CAP_DOMAIN}AppResponse(${CAP_DOMAIN} ${DOMAIN_NAME}) {
        this.id = ${DOMAIN_NAME}.getId();
        this.content = ${DOMAIN_NAME}.getContent();
    }
}
EOF

# Add${CAP_DOMAIN}UseCase
cat <<EOF > $BASE_DIR/port/in/Add${CAP_DOMAIN}UseCase.java
package ${PACKAGE_NAME}.${DOMAIN_NAME}.port.in;

import ${PACKAGE_NAME}.${DOMAIN_NAME}.port.in.request.Add${CAP_DOMAIN}AppRequest;
import ${PACKAGE_NAME}.${DOMAIN_NAME}.port.in.response.${CAP_DOMAIN}AppResponse;

public interface Add${CAP_DOMAIN}UseCase {
    ${CAP_DOMAIN}AppResponse add(Add${CAP_DOMAIN}AppRequest appReq);
}
EOF

# Find${CAP_DOMAIN}UseCase
cat <<EOF > $BASE_DIR/port/in/Find${CAP_DOMAIN}UseCase.java
package ${PACKAGE_NAME}.${DOMAIN_NAME}.port.in;

import ${PACKAGE_NAME}.${DOMAIN_NAME}.port.in.response.${CAP_DOMAIN}AppResponse;

import java.util.List;

public interface Find${CAP_DOMAIN}UseCase {
    ${CAP_DOMAIN}AppResponse findById(String id);
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
    private String id;
    private String content;
}
EOF

# ${CAP_DOMAIN}Service
cat <<EOF > $BASE_DIR/application/service/${CAP_DOMAIN}Service.java
package ${PACKAGE_NAME}.${DOMAIN_NAME}.application.service;

import ${PACKAGE_NAME}.${DOMAIN_NAME}.domain.${CAP_DOMAIN};
import ${PACKAGE_NAME}.${DOMAIN_NAME}.port.in.Add${CAP_DOMAIN}UseCase;
import ${PACKAGE_NAME}.${DOMAIN_NAME}.port.in.Find${CAP_DOMAIN}UseCase;
import ${PACKAGE_NAME}.${DOMAIN_NAME}.port.in.Update${CAP_DOMAIN}UseCase;
import ${PACKAGE_NAME}.${DOMAIN_NAME}.port.in.request.Add${CAP_DOMAIN}AppRequest;
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
public class ${CAP_DOMAIN}Service implements Add${CAP_DOMAIN}UseCase
        , Find${CAP_DOMAIN}UseCase
        , Update${CAP_DOMAIN}UseCase
{

    private final Create${CAP_DOMAIN}Port create${CAP_DOMAIN}Port;
    private final Read${CAP_DOMAIN}Port read${CAP_DOMAIN}Port;
    private final Update${CAP_DOMAIN}Port update${CAP_DOMAIN}Port;

    @Override
    public ${CAP_DOMAIN}AppResponse add(Add${CAP_DOMAIN}AppRequest appReq) {
        return new ${CAP_DOMAIN}AppResponse(create${CAP_DOMAIN}Port.create(appReq));
    }

    @Override
    public ${CAP_DOMAIN}AppResponse findById(String id) {
        return read${CAP_DOMAIN}Port.findById(id)
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
        Optional<${CAP_DOMAIN}> optional${CAP_DOMAIN} = read${CAP_DOMAIN}Port.findById(id);
        if (optional${CAP_DOMAIN}.isEmpty()) {
            throw new RuntimeException("${CAP_DOMAIN} not found");
        }

        ${CAP_DOMAIN} ${DOMAIN_NAME} = optional${CAP_DOMAIN}.get();
        ${DOMAIN_NAME}.setContent(appReq.getContent());

        ${CAP_DOMAIN} updated = update${CAP_DOMAIN}Port.update(${DOMAIN_NAME});
        return new ${CAP_DOMAIN}AppResponse(updated);
    }
}

EOF

# Create${CAP_DOMAIN}Port
cat <<EOF > $BASE_DIR/port/out/Create${CAP_DOMAIN}Port.java
package ${PACKAGE_NAME}.${DOMAIN_NAME}.port.out;

import ${PACKAGE_NAME}.${DOMAIN_NAME}.domain.${CAP_DOMAIN};
import ${PACKAGE_NAME}.${DOMAIN_NAME}.port.in.request.Add${CAP_DOMAIN}AppRequest;

public interface Create${CAP_DOMAIN}Port {
    ${CAP_DOMAIN} create(Add${CAP_DOMAIN}AppRequest appReq);
}
EOF

# Create${CAP_DOMAIN}Port
cat <<EOF > $BASE_DIR/port/out/Read${CAP_DOMAIN}Port.java
package ${PACKAGE_NAME}.${DOMAIN_NAME}.port.out;
package ${PACKAGE_NAME}.${DOMAIN_NAME}.port.out;

import ${PACKAGE_NAME}.${DOMAIN_NAME}.domain.${CAP_DOMAIN};
import ${PACKAGE_NAME}.${DOMAIN_NAME}.port.in.request.Add${CAP_DOMAIN}AppRequest;

public interface Create${CAP_DOMAIN}Port {
    ${CAP_DOMAIN} create(Add${CAP_DOMAIN}AppRequest appReq);
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
    Optional<${CAP_DOMAIN}> findById(String id);
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
@Table(name = "${DOMAIN_NAME}")
@Data
@Builder // mapToJpaEntity
@NoArgsConstructor
@AllArgsConstructor
public class ${CAP_DOMAIN}JpaEntity {
    @Id
    private String id;
    private String content;
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
                .id(${DOMAIN_NAME}.getId())
                .content(${DOMAIN_NAME}.getContent())
                .build();
    }

    public ${CAP_DOMAIN} mapToDomainEntity(${CAP_DOMAIN}JpaEntity userT) {
        return ${CAP_DOMAIN}.builder()
                .id(userT.getId())
                .content(userT.getContent())
                .build();
    }
}
EOF

# ${CAP_DOMAIN}Repository
cat <<EOF > $BASE_DIR/adapter/out/persistence/repository/${CAP_DOMAIN}Repository.java
package ${PACKAGE_NAME}.${DOMAIN_NAME}.adapter.out.persistence.repository;

import ${PACKAGE_NAME}.${DOMAIN_NAME}.adapter.out.persistence.entity.${CAP_DOMAIN}JpaEntity;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ${CAP_DOMAIN}Repository extends JpaRepository<${CAP_DOMAIN}JpaEntity, String> {
}
EOF

# ${CAP_DOMAIN}PersistenceAdapter
cat <<EOF > $BASE_DIR/adapter/out/persistence/${CAP_DOMAIN}PersistenceAdapter.java
package ${PACKAGE_NAME}.${DOMAIN_NAME}.adapter.out.persistence;

import ${PACKAGE_NAME}.${DOMAIN_NAME}.adapter.out.persistence.entity.${CAP_DOMAIN}JpaEntity;
import ${PACKAGE_NAME}.${DOMAIN_NAME}.adapter.out.persistence.mapper.${CAP_DOMAIN}Mapper;
import ${PACKAGE_NAME}.${DOMAIN_NAME}.adapter.out.persistence.repository.${CAP_DOMAIN}Repository;
import ${PACKAGE_NAME}.${DOMAIN_NAME}.domain.${CAP_DOMAIN};
import ${PACKAGE_NAME}.${DOMAIN_NAME}.port.in.request.Add${CAP_DOMAIN}AppRequest;
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
    public ${CAP_DOMAIN} create(Add${CAP_DOMAIN}AppRequest appReq) {

        ${CAP_DOMAIN}JpaEntity ${DOMAIN_NAME}T = ${CAP_DOMAIN}JpaEntity.builder()
                .id(appReq.getId())
                .content(appReq.getContent())
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
    public Optional<${CAP_DOMAIN}> findById(String id) {
        return ${DOMAIN_NAME}Repository.findById(id)
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
