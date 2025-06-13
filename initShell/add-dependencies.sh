#!/bin/bash

GRADLE_FILE="../build.gradle"

if [ ! -f "$GRADLE_FILE" ]; then
  echo "❌ build.gradle 파일을 찾을 수 없습니다."
  exit 1
fi

# 추가할 dependency 목록
DEPS=(
    "implementation group: 'org.springdoc', name: 'springdoc-openapi-starter-webmvc-ui', version: '2.2.0'"
    "implementation 'io.jsonwebtoken:jjwt-api:0.11.5'"
    "runtimeOnly 'io.jsonwebtoken:jjwt-impl:0.11.5'"
    "runtimeOnly 'io.jsonwebtoken:jjwt-jackson:0.11.5'"
)

# dependencies 블록 안에 추가
for dep in "${DEPS[@]}"; do
  grep -q "$dep" "$GRADLE_FILE"
  if [ $? -ne 0 ]; then
    sed -i '' "/dependencies {/a\\
    $dep
    " "$GRADLE_FILE"
    echo "✅ 추가됨: $dep"
  else
    echo "⚠️ 이미 존재함: $dep"
  fi
done
