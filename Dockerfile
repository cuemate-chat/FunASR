# CueMate ASR Service
# 基于 FunASR pip 安装的实时转录服务 (CPU)

FROM python:3.11-slim

# 设置标签
LABEL maintainer="CueMate"
LABEL version="0.1.0"
LABEL description="CueMate ASR Service - Real-time Transcription (CPU)"

# 安装必要的系统依赖
RUN apt-get update && apt-get install -y \
    libsndfile1 \
    libgomp1 \
    && rm -rf /var/lib/apt/lists/*

# 设置版本环境变量
ARG VERSION=0.1.0
ENV VERSION=${VERSION}

# 设置环境变量
ENV MODELSCOPE_CACHE=/app/models
ENV CUEMATE_LOG_DIR=/opt/cuemate/logs
ENV TZ=Asia/Shanghai
ENV OMP_NUM_THREADS=1

# 创建应用目录和用户
RUN useradd -m -u 1000 funasr
RUN mkdir -p /app /app/models /opt/cuemate/logs && \
    chown -R funasr:funasr /app /opt/cuemate

# 切换到应用用户
USER funasr
WORKDIR /app

# 复制 FunASR WebSocket 服务器
COPY --chown=funasr:funasr runtime/python/websocket/funasr_wss_server.py /app/

# 暴露端口
EXPOSE 10095

# 启动命令 - 使用复制的 WebSocket 服务器
CMD ["python", "funasr_wss_server.py", \
     "--host", "0.0.0.0", \
     "--port", "10095", \
     "--asr_model", "iic/speech_paraformer-large_asr_nat-zh-cn-16k-common-vocab8404-pytorch", \
     "--vad_model", "iic/speech_fsmn_vad_zh-cn-16k-common-pytorch", \
     "--punc_model", "iic/punc_ct-transformer_zh-cn-common-vad_realtime-vocab272727", \
     "--device", "cpu", \
     "--certfile", ""]
