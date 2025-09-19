# CueMate ASR Service
# 基于 FunASR 源码构建的实时转录服务 (CPU)

FROM python:3.11-slim

# 设置标签
LABEL maintainer="CueMate Team"
LABEL version="0.1.0"
LABEL description="CueMate ASR Service - Real-time Transcription (CPU)"

# 安装必要的系统依赖 (包含PyTorch需要的库)
RUN apt-get update && apt-get install -y \
    libsndfile1 \
    libgomp1 \
    gcc \
    g++ \
    && rm -rf /var/lib/apt/lists/*

# 设置环境变量
ENV PYTHONPATH=/app:/app/funasr
ENV FUNASR_CACHE_DIR=/app/models
ENV CUEMATE_LOG_DIR=/opt/cuemate/logs
ENV TZ=Asia/Shanghai
ENV PYTORCH_DISABLE_NET_ACCESS=0

# 创建应用目录和用户
RUN useradd -m -u 1000 funasr
RUN mkdir -p /app /app/models /opt/cuemate/logs && \
    chown -R funasr:funasr /app /opt/cuemate

# 切换到应用用户
USER funasr
WORKDIR /app

# 复制项目文件 (精简版)
COPY --chown=funasr:funasr funasr/ /app/funasr/
COPY --chown=funasr:funasr fun_text_processing/ /app/fun_text_processing/
COPY --chown=funasr:funasr runtime/ /app/runtime/
COPY --chown=funasr:funasr setup.py /app/
COPY --chown=funasr:funasr cuemate_server.py /app/
COPY --chown=funasr:funasr cuemate_logger.py /app/

# 安装FunASR (使用setup.py，包含所有依赖)
RUN pip install --no-cache-dir --user -e .

# 暴露端口
EXPOSE 10095

# 启动命令
CMD ["python", "cuemate_server.py"]
