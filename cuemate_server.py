#!/usr/bin/env python3
"""
CueMate ASR 服务
基于 FunASR 的定制化语音识别服务
"""

import os
import sys
import json
import asyncio
import logging
from datetime import datetime
from pathlib import Path

# 导入 CueMate 日志模块
from cuemate_logger import setup_cuemate_logger

# 导入 FunASR 相关模块
sys.path.append('/workspace')

async def main():
    """主函数"""
    # 设置日志
    logger = setup_cuemate_logger('cuemate-asr')

    logger.info("========================================")
    logger.info("CueMate ASR 服务启动")
    logger.info(f"版本: {os.getenv('VERSION', '0.1.0')}")
    logger.info("基于: FunASR Official Runtime")
    logger.info("========================================")

    try:
        # 启动 FunASR WebSocket 服务
        logger.info("ASR 服务初始化中...")

        # 导入 FunASR WebSocket 服务器
        sys.path.append('/app/runtime/python/websocket')
        from funasr_wss_server import main as funasr_main

        # 设置 FunASR 参数
        import argparse
        parser = argparse.ArgumentParser()
        # 添加默认参数
        args = parser.parse_args([
            "--host", "0.0.0.0",
            "--port", "10095",
            "--asr_model", "iic/speech_paraformer-large_asr_nat-zh-cn-16k-common-vocab8404-pytorch",
            "--vad_model", "iic/speech_fsmn_vad_zh-cn-16k-common-pytorch",
            "--punc_model", "iic/punc_ct-transformer_zh-cn-common-vad_realtime-vocab272727",
            "--ngpu", "0",
            "--device", "cpu"
        ])

        logger.info("启动 FunASR WebSocket 服务...")
        logger.info(f"服务地址: ws://0.0.0.0:10095")

        # 启动 FunASR 服务
        await funasr_main(args)

    except Exception as e:
        logger.error(f"服务启动失败: {e}")
        sys.exit(1)

if __name__ == "__main__":
    asyncio.run(main())
