#!/bin/bash

# === 사용자 설정 ===
SFTP_USER="your_username"
SFTP_HOST="your_sftp_host"
REMOTE_DIR="/remote/path/"
LOCAL_DIR="/path/to/local/folder"
FILE_COUNT=5  # 전송할 파일 개수

# === 임시 파일 생성 ===
SFTP_CMD_FILE=$(mktemp)

# SFTP 명령어 초기화
echo "open $SFTP_USER@$SFTP_HOST" > "$SFTP_CMD_FILE"
echo "cd $REMOTE_DIR" >> "$SFTP_CMD_FILE"

# === 로컬 디렉토리에서 랜덤 파일 선택 ===
FILES=($(find "$LOCAL_DIR" -maxdepth 1 -type f))
TOTAL_FILES=${#FILES[@]}

if [ "$TOTAL_FILES" -lt "$FILE_COUNT" ]; then
  echo "로컬 폴더에 충분한 파일이 없습니다. ($TOTAL_FILES 개 발견됨)"
  exit 1
fi

# 랜덤 파일 선택 및 SFTP 명령 추가
SELECTED_FILES=($(printf "%s\n" "${FILES[@]}" | shuf | head -n "$FILE_COUNT"))
for FILE in "${SELECTED_FILES[@]}"; do
  echo "put \"$FILE\"" >> "$SFTP_CMD_FILE"
done

echo "bye" >> "$SFTP_CMD_FILE"

# === SFTP 명령 실행 ===
sftp -b "$SFTP_CMD_FILE"

# === 임시 파일 삭제 ===
rm "$SFTP_CMD_FILE"

echo "✅ 전송 완료! $FILE_COUNT 개의 파일이 업로드되었습니다."
