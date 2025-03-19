# Ubuntu 이미지를 기반으로 사용
FROM ubuntu:latest

# 패키지 업데이트 및 설치
RUN apt-get update && apt-get install -y \
    vim \
    curl \
    git

# 컨테이너 실행 시 bash로 들어가도록 설정
CMD ["/bin/bash"]

