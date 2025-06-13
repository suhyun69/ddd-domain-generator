#!/bin/bash

if [ -z "$1" ]; then
  echo "⚠️  패키지 이름을 입력하세요. 예: com.latinhosue.backend"
  exit 1
fi

echo "✅ init from shell 시작"

PACKAGE_NAME=$1
# PACKAGE_PATH="${PACKAGE_NAME//./\/}"
PACKAGE_PATH=$(echo "$PACKAGE_NAME" | sed 's/\./\//g')

echo ${PACKAGE_PATH}

# add-dependencies.sh
chmod +x "add-dependencies.sh"
"./add-dependencies.sh"

# generate_config.sh
chmod +x "generate_config.sh"
"./generate_config.sh" "$PACKAGE_NAME" "$PACKAGE_PATH"

# generate_global_exception.sh
chmod +x "generate_global_exception.sh"
"./generate_global_exception.sh" "$PACKAGE_NAME" "$PACKAGE_PATH"

# generate_resources_application.sh
chmod +x "generate_resources_application.sh"
"./generate_resources_application.sh" "$PACKAGE_NAME" "$PACKAGE_PATH"

# generate_security.sh
chmod +x "generate_security.sh"
"./generate_security.sh" "$PACKAGE_NAME" "$PACKAGE_PATH"

# generate_hex_domain_user.sh
chmod +x "generate_hex_domain_user.sh"
"./generate_hex_domain_user.sh" "$PACKAGE_NAME" "$PACKAGE_PATH"

# generate_hex_domain_auth.sh
chmod +x "generate_hex_domain_auth.sh"
"./generate_hex_domain_auth.sh" "$PACKAGE_NAME" "$PACKAGE_PATH"

# generate_hex_domain.sh
chmod +x "generate_hex_domain.sh"

echo "✅ init from shell 완료"