"""
CueMate 统一日志模块
"""

import os
import logging
import logging.handlers
from pathlib import Path
from datetime import datetime
from pythonjsonlogger import jsonlogger

def print_banner(service_name: str, version: str = None, port: int = None):
    """打印启动 banner"""
    service_version = version or os.getenv('VERSION', '0.1.0')
    
    banner = f"""
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║    ██████╗██╗   ██╗███████╗███╗   ███╗ █████╗ ████████╗███████╗
║   ██╔════╝██║   ██║██╔════╝████╗ ████║██╔══██╗╚══██╔══╝██╔════╝
║   ██║     ██║   ██║█████╗  ██╔████╔██║███████║   ██║   █████╗  
║   ██║     ╚██╗ ██╔╝██╔══╝  ██║╚██╔╝██║██╔══██║   ██║   ██╔══╝  
║   ╚██████╗ ╚████╔╝ ███████╗██║ ╚═╝ ██║██║  ██║   ██║   ███████╗
║    ╚═════╝  ╚═══╝  ╚══════╝╚═╝     ╚═╝╚═╝  ╚═╝   ╚═╝   ╚══════╝
║                                                              ║
║  Service: {service_name:<20} Version: {service_version:<10} ║
║  Port: {str(port) if port else 'N/A':<20} ║
║  Environment: {os.getenv('NODE_ENV', 'development'):<15} ║
║  Started: {datetime.now().isoformat():<20} ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
"""
    print(banner)

def print_success_info(service_name: str, port: int, additional_info: dict = None):
    """打印成功启动信息"""
    separator = '========================================='
    print(f'[SUCCESS] {separator}')
    print(f'[SUCCESS] 启动完成！')
    print(f'[SUCCESS] 服务名称: {service_name}')
    print(f'[SUCCESS] 端口号: {port}')
    
    if additional_info:
        for key, value in additional_info.items():
            print(f'[SUCCESS] {key}: {value}')
    
    print(f'[SUCCESS] {separator}')

def setup_cuemate_logger(service_name: str, log_level: str = "INFO") -> logging.Logger:
    """
    设置 CueMate 统一日志格式

    Args:
        service_name: 服务名称
        log_level: 日志级别

    Returns:
        配置好的 logger 实例
    """
    # 创建 logger
    logger = logging.getLogger(service_name)
    logger.setLevel(getattr(logging, log_level.upper()))

    # 避免重复添加 handler
    if logger.handlers:
        return logger

    # 日志目录配置
    log_base_dir = Path(os.getenv('CUEMATE_LOG_DIR', '/opt/cuemate/logs'))
    today = datetime.now().strftime('%Y-%m-%d')

    # 创建目录
    info_dir = log_base_dir / 'info' / service_name / today
    warn_dir = log_base_dir / 'warn' / service_name / today
    error_dir = log_base_dir / 'error' / service_name / today

    for dir_path in [info_dir, warn_dir, error_dir]:
        dir_path.mkdir(parents=True, exist_ok=True)

    # JSON 格式化器
    json_formatter = jsonlogger.JsonFormatter(
        '%(asctime)s %(name)s %(levelname)s %(message)s',
        datefmt='%Y-%m-%d %H:%M:%S'
    )

    # 控制台输出 (简单格式)
    console_handler = logging.StreamHandler()
    console_formatter = logging.Formatter(
        '%(asctime)s [%(levelname)s] %(name)s: %(message)s',
        datefmt='%Y-%m-%d %H:%M:%S'
    )
    console_handler.setFormatter(console_formatter)
    logger.addHandler(console_handler)

    # INFO 级别文件日志
    info_handler = logging.handlers.RotatingFileHandler(
        info_dir / 'info.log',
        maxBytes=50*1024*1024,  # 50MB
        backupCount=5
    )
    info_handler.setLevel(logging.INFO)
    info_handler.setFormatter(json_formatter)
    logger.addHandler(info_handler)

    # WARNING 级别文件日志
    warn_handler = logging.handlers.RotatingFileHandler(
        warn_dir / 'warn.log',
        maxBytes=50*1024*1024,  # 50MB
        backupCount=5
    )
    warn_handler.setLevel(logging.WARNING)
    warn_handler.setFormatter(json_formatter)
    logger.addHandler(warn_handler)

    # ERROR 级别文件日志
    error_handler = logging.handlers.RotatingFileHandler(
        error_dir / 'error.log',
        maxBytes=50*1024*1024,  # 50MB
        backupCount=5
    )
    error_handler.setLevel(logging.ERROR)
    error_handler.setFormatter(json_formatter)
    logger.addHandler(error_handler)

    return logger
