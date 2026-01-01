#!/usr/bin/env bash

# Script URL
SCRIPT_URL="https://raw.githubusercontent.com/Fragoler/happy-new-year/refs/heads/master/happy-new-year.sh"

# Colors
GN="\033[1;92m"
YW="\033[33m"
BL="\033[36m"
RD="\033[01;31m"
CL="\033[m"

echo -e "${BL}==================================${CL}"
echo -e "${GN}  Генератор новогодних ссылок${CL}"
echo -e "${BL}==================================${CL}"
echo

# Get multiline message
echo -e "${YW}Введите поздравление (многострочное):${CL}"
echo -e "${BL}(Нажмите Ctrl+D или введите EOF на новой строке для завершения)${CL}"
echo

MESSAGE=""
while IFS= read -r line; do
    if [ "$line" = "EOF" ]; then
        break
    fi
    MESSAGE="${MESSAGE}${line}"$'\n'
done

# Remove trailing newline
MESSAGE="${MESSAGE%$'\n'}"

# Get name
echo
echo -e "${YW}Введите имя получателя:${CL}"
read -r NAME

# Encode to base64
MESSAGE_B64=$(echo -n "$MESSAGE" | base64 -w 0 2>/dev/null || echo -n "$MESSAGE" | base64)
NAME_B64=$(echo -n "$NAME" | base64 -w 0 2>/dev/null || echo -n "$NAME" | base64)

# Generate command
COMMAND="bash <(curl -sSL $SCRIPT_URL) '$MESSAGE_B64' '$NAME_B64'"

echo
echo -e "${BL}==================================${CL}"
echo -e "${GN}Готовая команда для запуска:${CL}"
echo -e "${BL}==================================${CL}"
echo
echo -e "${YW}$COMMAND${CL}"
echo
echo -e "${BL}==================================${CL}"

# Preview
echo -e "${GN}Предварительный просмотр:${CL}"
echo -e "${BL}---${CL}"
echo -e "$MESSAGE"
echo -e "${BL}---${CL}"
echo -e "${GN}Получатель: ${YW}$NAME${CL}"
echo -e "${BL}==================================${CL}"

# Save to file
OUTPUT_FILE="greeting_${NAME// /_}_$(date +%s).txt"
cat > "$OUTPUT_FILE" << EOF
Новогоднее поздравление для: $NAME

Команда для запуска:
$COMMAND

---
Сообщение:
$MESSAGE

Получатель: $NAME
Дата создания: $(date '+%Y-%m-%d %H:%M:%S')
EOF

echo
echo -e "${GN}✓${CL} Команда сохранена в: ${YW}$OUTPUT_FILE${CL}"
