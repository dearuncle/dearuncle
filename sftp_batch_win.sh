@echo off
REM === 사용자 설정 ===
setlocal enabledelayedexpansion
set SFTP_USER=your_username
set SFTP_HOST=your_sftp_host
set REMOTE_DIR=/remote/path/
set LOCAL_DIR=C:\path\to\local\folder
set FILE_COUNT=5  REM 전송할 파일 개수

REM === 임시 파일 생성 ===
set SFTP_CMD_FILE=temp_sftp_commands.txt
echo open %SFTP_USER%@%SFTP_HOST% > %SFTP_CMD_FILE%
echo cd %REMOTE_DIR% >> %SFTP_CMD_FILE%

REM === 로컬 디렉토리에서 랜덤 파일 선택 ===
set /a count=0
for /f "delims=" %%F in ('dir /b /a:-d "%LOCAL_DIR%"') do (
    set /a rand=!random! %% 100
    if !rand! lss 50 (
        echo put "%LOCAL_DIR%\%%F" >> %SFTP_CMD_FILE%
        set /a count+=1
    )
    if !count! geq %FILE_COUNT% (
        goto :UPLOAD
    )
)

:UPLOAD
echo bye >> %SFTP_CMD_FILE%

REM === SFTP 명령 실행 ===
sftp -b %SFTP_CMD_FILE%

REM === 임시 파일 삭제 ===
del %SFTP_CMD_FILE%

echo 전송 완료!
pause
