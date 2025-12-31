#!/usr/bin/env bash

# Initialize color variables
color() {
  YW=$(echo "\033[33m")
  BL=$(echo "\033[36m")
  RD=$(echo "\033[01;31m")
  BGN=$(echo "\033[4;92m")
  GN=$(echo "\033[1;92m")
  DGN=$(echo "\033[32m")
  CL=$(echo "\033[m")
  CM="${GN}✓${CL}"
  CROSS="${RD}✗${CL}"
  BFR="\\r\\033[K"
  HOLD=" "
}

# Enable error handling
catch_errors() {
  set -Eeuo pipefail
  trap 'error_handler $LINENO "$BASH_COMMAND"' ERR
}

# Error handler
error_handler() {
  if [ -n "$SPINNER_PID" ] && ps -p $SPINNER_PID > /dev/null; then 
    kill $SPINNER_PID > /dev/null
  fi
  printf "\e[?25h"
  local exit_code="$?"
  local line_number="$1"
  local command="$2"
  echo -e "\n${RD}[ERROR]${CL} in line ${RD}$line_number${CL}: exit code ${RD}$exit_code${CL}: while executing command ${YW}$command${CL}\n"
}

# Center text with word wrapping
center_text() {
  local MSG="$1"
  local term_width=$(tput cols)
  local max_width=$((term_width / 4))
  local msg_part=""
  local lines=()
  
  # Split into lines
  for word in $MSG; do
    local test_line="$msg_part $word"
    test_line="${test_line# }" 
    
    if [ ${#test_line} -le $max_width ]; then
      msg_part="$test_line"
    else
      [ -n "$msg_part" ] && lines+=("$msg_part")
      msg_part="$word"
    fi
  done
  [ -n "$msg_part" ] && lines+=("$msg_part")
  
  # Output centered lines
  for line in "${lines[@]}"; do
      local clean_line=$(echo -e "$line" | sed 's/\x1b\[[0-9;]*m//g')
      local col_offset=$(( (term_width - ${#clean_line}) / 2 ))
      tput hpa $col_offset
      echo -e "$line"
  done
}

# Display Christmas tree
show_tree() {
  clear
  local cols=$(tput cols)
  local tree_width=45
  local offset=$(( (cols - tree_width) / 2 ))
  
  center_line() {
      printf "%${offset}s%s\n" "" "$1"
  }
  
  # Red star
  tput setaf 1; tput bold
  while IFS= read -r line; do
      center_line "${line//_/ }"
  done << 'EOF'
___________________________88
__________________________6¶¶8
_____________________06668¶¶0¶¶¶¶¶0
______________________8¶¶¶8_0_8¶¶6
________________________8¶¶8¶¶¶¶¶
________________________¶¶¶¶8068¶
EOF
    
  # Green crown
  tput setaf 2; tput bold
  mapfile -t tree_lines << 'EOF'
________________________008¶¶0
________________________0¶¶8¶8
_______________________8¶¶6_6¶6
____________________08¶¶¶0___8¶8
_________________06¶¶¶¶6______8¶¶6
______________08¶¶¶¶60_________08¶¶80
______________08¶¶¶¶¶¶¶¶¶¶¶80_____6¶¶¶0
_________________0¶¶¶0____________6¶¶¶
_______________6¶¶¶0_____________8¶¶¶0
___________08¶¶¶80________________06¶¶¶¶80
_________¶¶¶¶80_____________________08¶¶¶¶6
_________6¶¶¶60__________6¶¶¶¶¶¶¶¶¶¶¶¶¶860
___________6¶¶¶¶860________06666666¶¶
____________6¶¶88860_______________0¶¶60
_________68¶¶6_______________________08¶¶¶660
_____6¶¶¶¶80____________________________06¶¶¶¶¶0
_____6¶¶¶¶86666668880_____________________8¶¶¶8
_______06¶¶¶¶¶¶¶86___________________068¶¶¶¶6
_______6¶¶6________60___________6¶¶¶¶¶¶8860
___068¶¶¶0_________6¶¶60_____________8¶¶800
_8¶¶¶¶60____________0¶¶¶¶¶800__________68¶¶¶¶¶¶8
_0¶¶¶¶¶¶86666666688¶¶¶¶¶¶¶¶¶¶¶¶¶¶888666688¶¶¶¶80
____6¶¶¶¶¶¶¶¶¶¶¶¶¶860_8¶0__¶¶88¶¶¶¶¶¶¶¶¶¶¶866
EOF
    
  for line in "${tree_lines[@]}"; do
      center_line "${line//_/ }"
  done
  
  # Brown trunk
  tput setaf 3
  while IFS= read -r line; do
      center_line "${line//_/ }"
  done << 'EOF'
______________________¶8___6¶
_____________________6¶6___8¶6
_____________________8¶¶¶¶¶¶¶0
______________________688860
EOF
    
  # Ornaments
  local toys=(
"  .--. 
 ( oo )
  \`--' "
"  .__. 
 (    )
  \`\"\"' "
"  _||_ 
 (    )
  \"\"\"\" "
"  /--\\
 |  o |
  \\__/ "
    )

  local colors=(4 5 3)
  local toy_data=("10:0:0:2" "13:-10:1:0" "16:8:2:2" "19:-5:3:1" "22:12:0:0" "25:-18:1:2" "28:10:2:1")
  
  for data in "${toy_data[@]}"; do
      IFS=':' read -r row col toy_idx color_idx <<< "$data"
      tput setaf ${colors[$color_idx]}; tput bold
      local line_offset=0
      while IFS= read -r toy_line; do
          tput cup $((row + line_offset)) $((offset + 22 + col))
          echo -n "$toy_line"
          ((line_offset++)) || true
      done <<< "${toys[$toy_idx]}"
  done
  
  tput cup $((13 + ${#tree_lines[@]})) 0
  tput sgr0
  echo
}

# Display scroll with message
show_roll() {
    clear
    local MSG="$1"
    local art=(
        "  ▄▄▀███▀▀▀▀▀▀▀▀▀▀▀▀▀▀▄▄ "
        "▄█▄▄▄▄█               ▀▄"
        "█ ▀▄ ▄█               ▄▀"
        "▀█ ▀▀▀▀▀▀▀▀▀▀▀▀▀▀█▀▀▀▀  "
        " █                █     "
        "  █  ▀▀▀▀▀▀▀▀▀▀▀  ▀▄    "
        "   █   ▄▄▄▄▄▄▄▄▄▄  █▄   "
        "   ▀█              █▄   "
        "    ▀▄  ▀▀▀▀▀▀▀▀▀▀▀  █  "
        "     █▄              █  "
        "      █  ▀▀▀▀▀▀▀▀▀▀▀  ▀▄"
        "      █▄  ▄▄▄▄▄▄▄▄▄▄▄  █"
        "▄█▀██▀▀█              █ "
        "█  ▄█▄▄▀  ▄▄▄▄▄▄      █ "
        "█     █              ▄▀ "
        " ▀█▄███▄▄▄▄▄▄▄▄▄▄▄▄▄█▀▀ "
    )
    
    local term_width=$(tput cols)
    local offset=$(( (term_width - ${#art[0]}) / 2 ))
    
    for line in "${art[@]}"; do
        printf "%${offset}s%s\n" "" "$line"
    done
    
    [ -n "$MSG" ] && { echo; center_text "$MSG"; }
}

# Spinner control
kill_spinner() {
    [[ -v SPINNER_PID ]] && [ -n "$SPINNER_PID" ] && ps -p $SPINNER_PID > /dev/null 2>&1 && {
        kill $SPINNER_PID > /dev/null 2>&1
        wait $SPINNER_PID 2>/dev/null || true
    }
    printf "\r\e[K\e[?25h"
}

spinner() {
    local chars="/-\|"
    local spin_i=0
    printf "\e[?25l"
    while true; do
        printf "\r \e[36m%s\e[0m" "${chars:spin_i++%${#chars}:1}"
        sleep 0.1
    done
}

# Message functions
msg_info() {
    kill_spinner
    echo -ne " ${HOLD} ${YW}$1${CL}"
    spinner &
    SPINNER_PID=$!
}

msg_ok() {
    kill_spinner
    echo -e "${BFR} ${CM} ${GN}$1${CL}"
}

msg_error() {
    kill_spinner
    echo -e "${BFR} ${CROSS} ${RD}$1${CL}"
}

# Main
tput civis
color
catch_errors

clear
read -r -p "Готовы отпраздновать? <y/N> " prompt

if [[ ${prompt,,} =~ ^(y|yes)$ ]]; then
    clear
    msg_info "*ищем ёлочку*"
      sleep 1
    msg_info "*звуки топора*"
      sleep 1
    msg_info "*звон шариков*"
      sleep 1
    msg_ok "Ёлка готова!"
      sleep 1
      
    show_tree
    
    if [ $# -ge 2 ]; then
        MSG="$(echo "$1" | base64 -d)"
        NAME="$(echo "$2" | base64 -d)"
        
        center_text "Под ёлкой лежит записка: \"Лично в руки ${NAME}\" [Ent]"
        read -n 1 -s -r

        clear
        msg_info "*Открываем конверт*"
        sleep 1
        clear

        show_roll "$MSG"
        center_text "${RD}[Ent] Сжечь бумажку${CL}"
    fi
    
    read -n 1 -s -r
else
    clear
fi

clear
tput cnorm
exit 0
