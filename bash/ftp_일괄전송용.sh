📁 한 쌍의 .csv & .fin 파일 전송용 Bash 스크립트 (sftp_paired_upload.sh)
bash
복사
편집
#!/bin/bash

# === 사용자 설정 ===
SFTP_USER="your_username"
SFTP_HOST="your_sftp_host"
REMOTE_DIR="/remote/path/"
LOCAL_DIR="/path/to/local/folder"
FILE_COUNT=5  # 전송할 파일 쌍 개수

# === 임시 파일 생성 ===
SFTP_CMD_FILE=$(mktemp)

# SFTP 명령어 초기화
echo "open $SFTP_USER@$SFTP_HOST" > "$SFTP_CMD_FILE"
echo "cd $REMOTE_DIR" >> "$SFTP_CMD_FILE"

# === .csv와 .fin 파일 쌍 찾기 ===
PAIRS=()
for CSV_FILE in "$LOCAL_DIR"/*.csv; do
  # .csv 파일이 존재하는지 확인
  [ -e "$CSV_FILE" ] || continue

  BASENAME=$(basename "$CSV_FILE" .csv)
  FIN_FILE="$LOCAL_DIR/$BASENAME.fin"

  # .fin 파일이 존재하면 쌍으로 추가
  if [ -e "$FIN_FILE" ]; then
    PAIRS+=("$CSV_FILE" "$FIN_FILE")
  fi
done

# === 유효한 파일 쌍 확인 ===
TOTAL_PAIRS=$((${#PAIRS[@]} / 2))

if [ "$TOTAL_PAIRS" -lt 1 ]; then
  echo "⚠️ 유효한 .csv & .fin 파일 쌍이 없습니다."
  exit 1
fi

echo "✅ $TOTAL_PAIRS 개의 유효한 파일 쌍을 발견했습니다."

# === 랜덤으로 파일 쌍 선택 ===
SELECTED_PAIRS=($(printf "%s\n" "${PAIRS[@]}" | paste - - | shuf | head -n "$FILE_COUNT" | tr '\t' '\n'))

# === SFTP 명령어 파일에 추가 ===
for FILE in "${SELECTED_PAIRS[@]}"; do
  echo "put \"$FILE\"" >> "$SFTP_CMD_FILE"
done

echo "bye" >> "$SFTP_CMD_FILE"

# === SFTP 명령 실행 ===
sftp -b "$SFTP_CMD_FILE"

# === 임시 파일 삭제 ===
rm "$SFTP_CMD_FILE"

echo "🚀 전송 완료! $FILE_COUNT 개의 파일 쌍이 업로드되었습니다."
💡 스크립트 설명:
사용자 설정:

SFTP_USER → SFTP 사용자 이름
SFTP_HOST → SFTP 호스트 주소
REMOTE_DIR → 원격 서버 경로
LOCAL_DIR → 로컬 폴더 경로
FILE_COUNT → 전송할 파일 쌍 수
핵심 로직:

.csv 파일을 기준으로, 같은 이름의 .fin 파일이 있는지 검사합니다.
.csv와 .fin 파일이 모두 존재하는 경우 쌍으로 목록에 추가합니다.
쌍 목록에서 랜덤으로 FILE_COUNT 개수를 선택해 전송합니다.
SFTP 전송:

-b 옵션으로 배치 모드에서 SFTP 명령 실행
선택된 .csv & .fin 파일 쌍을 전송
✅ 사용 방법:
스크립트 저장:
sftp_paired_upload.sh로 저장합니다.

실행 권한 부여:

bash
복사
편집
chmod +x sftp_paired_upload.sh
스크립트 실행:

bash
복사
편집
./sftp_paired_upload.sh
출력 예시:

bash
복사
편집
✅ 8 개의 유효한 파일 쌍을 발견했습니다.
Connecting to your_sftp_host...
sftp> put /path/to/local/folder/data1.csv
sftp> put /path/to/local/folder/data1.fin
...
🚀 전송 완료! 5 개의 파일 쌍이 업로드되었습니다.
🔒 보안 팁:
SSH 키 기반 인증을 사용하는 것이 안전합니다.
비밀번호 기반 인증이 필요한 경우 sshpass를 사용할 수 있습니다.
이제 .csv와 .fin 파일이 쌍으로 존재할 때만 랜덤으로 선택해서 SFTP로 전송할 수 있습니다! 🚀✨

다른 요청 사항이 있으면 언제든지 말씀해 주세요! 😊







나의 말:
PAIRS는 배열변수인가?
ChatGPT의 말:
네! 🔥

PAIRS는 Bash 배열 변수입니다. 이 배열에는 .csv와 .fin 파일 쌍을 순차적으로 저장합니다. 즉, 배열의 짝수 인덱스에는 .csv 파일 경로가, 홀수 인덱스에는 해당하는 .fin 파일 경로가 들어가게 됩니다.

📁 PAIRS 배열 구성 예시:
로컬 폴더에 아래와 같은 파일이 있다고 가정할게요:

bash
복사
편집
data1.csv   data1.fin  
data2.csv   data2.fin  
data3.csv   data3.fin  
PAIRS 배열에 저장되는 형태:

bash
복사
편집
PAIRS[0]="path/to/data1.csv"
PAIRS[1]="path/to/data1.fin"
PAIRS[2]="path/to/data2.csv"
PAIRS[3]="path/to/data2.fin"
PAIRS[4]="path/to/data3.csv"
PAIRS[5]="path/to/data3.fin"
🔄 쌍으로 묶는 부분:
bash
복사
편집
for CSV_FILE in "$LOCAL_DIR"/*.csv; do
  [ -e "$CSV_FILE" ] || continue

  BASENAME=$(basename "$CSV_FILE" .csv)
  FIN_FILE="$LOCAL_DIR/$BASENAME.fin"

  if [ -e "$FIN_FILE" ]; then
    PAIRS+=("$CSV_FILE" "$FIN_FILE")
  fi
done
PAIRS+=("$CSV_FILE" "$FIN_FILE") → .csv와 .fin 파일을 순서대로 배열에 추가
결과적으로 PAIRS 배열은 [csv1, fin1, csv2, fin2, ...] 형태가 됩니다.
🎯 랜덤 선택 시:
bash
복사
편집
SELECTED_PAIRS=($(printf "%s\n" "${PAIRS[@]}" | paste - - | shuf | head -n "$FILE_COUNT" | tr '\t' '\n'))
paste - - → 2개씩 묶어서 쌍을 생성
shuf → 랜덤으로 섞음
head -n "$FILE_COUNT" → 원하는 개수만큼 랜덤으로 선택
tr '\t' '\n' → 다시 배열로 변환
결과: 랜덤으로 선택된 .csv & .fin 쌍이 SELECTED_PAIRS 배열에 저장됩니다.

✅ Bash 배열 기초 팁:
배열 선언 및 추가:

bash
복사
편집
my_array=("item1" "item2")
my_array+=("item3" "item4")
배열 순회:

bash
복사
편집
for item in "${my_array[@]}"; do
  echo "$item"
done
배열 길이:

bash
복사
편집
echo "${#my_array[@]}"  # 요소 개수 출력
💡 궁금한 부분이나 추가로 수정할 점이 있다면 언제든 알려주세요! 🚀🔥







나의 말:
SELECTED\_PAIRS=($(printf "%s\\n" "${PAIRS\[@\]}" | paste - - | shuf | head -n "$FILE\_COUNT" | tr '\\t' '\\n'))

이 부분이 잘 이해가 안되네
ChatGPT의 말:
좋아요! 이 부분을 하나씩 자세히 설명해 드릴게요. 🚀

bash
복사
편집
SELECTED_PAIRS=($(printf "%s\n" "${PAIRS[@]}" | paste - - | shuf | head -n "$FILE_COUNT" | tr '\t' '\n'))
이 코드는 PAIRS 배열에서 랜덤으로 파일 쌍을 선택해서 SELECTED_PAIRS 배열에 저장하는 작업을 합니다.

🔍 한 줄씩 분해해서 설명:
1️⃣ printf "%s\n" "${PAIRS[@]}"
PAIRS[@] 배열의 모든 요소를 줄바꿈(\n)으로 구분해서 출력합니다.
출력 예시:
pgsql
복사
편집
/path/to/file1.csv  
/path/to/file1.fin  
/path/to/file2.csv  
/path/to/file2.fin  
/path/to/file3.csv  
/path/to/file3.fin  
2️⃣ paste - -
paste는 입력받은 줄을 두 줄씩 묶어서 한 줄로 합칩니다.

- -는 두 개의 입력 스트림을 의미합니다.

결과적으로 .csv와 .fin 파일을 한 쌍으로 묶습니다.

출력 예시:

pgsql
복사
편집
/path/to/file1.csv    /path/to/file1.fin  
/path/to/file2.csv    /path/to/file2.fin  
/path/to/file3.csv    /path/to/file3.fin  
📌 탭 문자로 두 개의 파일이 구분됩니다.

3️⃣ shuf
shuf는 입력받은 줄을 랜덤으로 섞는 명령어입니다.
출력 예시 (랜덤화):
pgsql
복사
편집
/path/to/file3.csv    /path/to/file3.fin  
/path/to/file1.csv    /path/to/file1.fin  
/path/to/file2.csv    /path/to/file2.fin  
4️⃣ head -n "$FILE_COUNT"
shuf로 섞은 목록에서 상위 $FILE_COUNT 개만 선택합니다.
예를 들어, FILE_COUNT=2 라면:
pgsql
복사
편집
/path/to/file3.csv    /path/to/file3.fin  
/path/to/file1.csv    /path/to/file1.fin  
5️⃣ tr '\t' '\n'
선택된 파일 쌍에서 탭 문자를 줄바꿈 문자로 변환합니다.

이렇게 하면 각 파일이 별도의 줄에 위치하게 됩니다.

출력 예시:

pgsql
복사
편집
/path/to/file3.csv  
/path/to/file3.fin  
/path/to/file1.csv  
/path/to/file1.fin  
6️⃣ SELECTED_PAIRS=( ... )
최종적으로 위 결과를 배열에 저장합니다.
SELECTED_PAIRS 배열 구조:
bash
복사
편집
SELECTED_PAIRS[0]="/path/to/file3.csv"  
SELECTED_PAIRS[1]="/path/to/file3.fin"  
SELECTED_PAIRS[2]="/path/to/file1.csv"  
SELECTED_PAIRS[3]="/path/to/file1.fin"  
⚡ 전체 흐름 요약:
PAIRS 배열 → 줄바꿈으로 출력
paste로 .csv + .fin 쌍으로 묶음
shuf로 랜덤화
head로 원하는 수만 선택
tr로 탭 구분 → 줄바꿈 변환
최종적으로 SELECTED_PAIRS 배열에 저장
✅ 실제로 테스트해보세요:
샘플 배열:

bash
복사
편집
PAIRS=(file1.csv file1.fin file2.csv file2.fin file3.csv file3.fin)
FILE_COUNT=2
SELECTED_PAIRS=($(printf "%s\n" "${PAIRS[@]}" | paste - - | shuf | head -n "$FILE_COUNT" | tr '\t' '\n'))
결과 확인:

bash
복사
편집
echo "${SELECTED_PAIRS[@]}"
# 출력 예시:
# file2.csv file2.fin file1.csv file1.fin

/usr/bin/expect <<EOF >> ${SFTPLOGFILE}
set timeout 14400
spawn sftp -oPort=${KEPCOPort} ${KEPCOUser}@${KEPCOHostAddr}
expect "s password: " { send ${KEPCOPwd}\r" }
expect "sftp> " { send "cd ${KEPCODir} \r" }
expect "sftp> " { send "put ${sendFileName} \r" }
expect "sftp> " { send "quit \r" }
interact
EOF

