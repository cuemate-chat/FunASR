#!/bin/bash

# FunASR Docker 构建脚本
# 本地安装 funasr，然后挂载到容器

set -e

PROJECT_NAME="cuemate-asr"
VERSION=${VERSION:-"0.1.0"}
IMAGE_NAME="${PROJECT_NAME}:${VERSION}"
FUNASR_DIR="./funasr_local"

echo "========================================="
echo "构建 FunASR Docker 镜像"
echo "项目: ${PROJECT_NAME}"
echo "版本: ${VERSION}"
echo "========================================="

# 检查并安装 FunASR Python 包
FUNASR_PACKAGES_DIR="/opt/cuemate/funasr-packages"
if [ ! -d "${FUNASR_PACKAGES_DIR}" ] || [ ! -d "${FUNASR_PACKAGES_DIR}/funasr" ]; then
    echo "FunASR 包不存在，开始安装..."
    mkdir -p "${FUNASR_PACKAGES_DIR}"

    # 使用临时容器安装 Python 包
    docker run --rm \
        -v "${FUNASR_PACKAGES_DIR}:/home/funasr/.local/lib/python3.11/site-packages" \
        python:3.11-slim \
        bash -c "
            useradd -m -u 1000 funasr && \
            apt-get update && apt-get install -y libsndfile1 libgomp1 && \
            chown -R funasr:funasr /home/funasr && \
            su - funasr -c '
                pip install --user torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu && \
                pip install --user funasr modelscope huggingface_hub \"websockets<12.0\"
            '
        "
    echo "FunASR 包安装完成"
else
    echo "FunASR 包已存在，跳过安装"
fi

# 构建镜像
echo "开始构建 Docker 镜像..."
docker build -t "${IMAGE_NAME}" . --build-arg VERSION="${VERSION}"

if [ $? -eq 0 ]; then
    echo "========================================="
    echo "构建完成！"
    echo "镜像名称: ${IMAGE_NAME}"
    echo "启动命令: docker run -p 10095:10095 ${IMAGE_NAME}"
    echo "WebSocket地址: ws://localhost:10095"
    echo "========================================="
else
    echo "构建失败！"
    exit 1
fi