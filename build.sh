#!/bin/bash

# FunASR Docker 构建脚本
# 基于 FunASR 源码，为 CueMate 项目定制实时转录服务 (CPU)

set -e

# 配置变量
PROJECT_NAME="cuemate-asr"
VERSION=${VERSION:-"0.1.0"}
IMAGE_NAME="${PROJECT_NAME}:${VERSION}"
BASE_IMAGE="python:3.11-slim"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

echo_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

echo_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

echo_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 拉取基础镜像
pull_base_image() {
    echo_info "拉取基础镜像: ${BASE_IMAGE}"

    if ! docker pull "${BASE_IMAGE}"; then
        echo_error "拉取基础镜像失败"
        exit 1
    fi

    echo_success "基础镜像拉取完成"
}


# 清理旧镜像
cleanup_old_images() {
    echo_info "清理旧的镜像..."

    # 删除同名镜像
    if docker images | grep -q "${PROJECT_NAME}"; then
        echo_warning "发现旧版本镜像，正在清理..."
        docker rmi "${IMAGE_NAME}" 2>/dev/null || true
        # 清理 <none> 标签的镜像
        docker image prune -f
    fi

    echo_success "镜像清理完成"
}

# 构建镜像
build_image() {
    echo_info "开始构建 Docker 镜像: ${IMAGE_NAME}"

    # 构建镜像
    docker build -t "${IMAGE_NAME}" . \
        --build-arg VERSION="${VERSION}" \
        --no-cache

    if [ $? -eq 0 ]; then
        echo_success "镜像构建成功: ${IMAGE_NAME}"
    else
        echo_error "镜像构建失败"
        exit 1
    fi
}

# 主函数
main() {
    echo_info "========================================="
    echo_info "CueMate ASR Docker 镜像构建工具"
    echo_info "基于: ${BASE_IMAGE}"
    echo_info "项目: ${PROJECT_NAME}"
    echo_info "版本: ${VERSION}"
    echo_info "========================================="

    # 执行构建流程
    pull_base_image
    cleanup_old_images
    build_image

    echo_success "========================================="
    echo_success "构建完成！"
    echo_success "镜像名称: ${IMAGE_NAME}"
    echo_success "WebSocket地址: ws://localhost:10095"
    echo_success "========================================="
}

# 执行主函数
main "$@"