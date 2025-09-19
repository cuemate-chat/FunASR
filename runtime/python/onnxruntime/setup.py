# -*- encoding: utf-8 -*-
import setuptools


MODULE_NAME = "funasr_onnx"
VERSION_NUM = "0.4.1"

setuptools.setup(
    name=MODULE_NAME,
    version=VERSION_NUM,
    platforms="Any",
    url="https://github.com/alibaba-damo-academy/FunASR.git",
    author="Speech Lab of DAMO Academy, Alibaba Group",
    author_email="funasr@list.alibaba-inc.com",
    description="FunASR: A Fundamental End-to-End Speech Recognition Toolkit",
    license="MIT",
    long_description="FunASR: A Fundamental End-to-End Speech Recognition Toolkit",
    long_description_content_type="text/markdown",
    include_package_data=True,
    install_requires=[
        "librosa",
        "onnxruntime>=1.7.0",
        "scipy",
        "numpy<=1.26.4",
        "kaldi-native-fbank",
        "PyYAML>=5.1.2",
        "onnx",
        "sentencepiece",
    ],
    packages=[MODULE_NAME, f"{MODULE_NAME}.utils"],
    keywords=["funasr,asr"],
    classifiers=[
        "Programming Language :: Python :: 3.6",
        "Programming Language :: Python :: 3.7",
        "Programming Language :: Python :: 3.8",
        "Programming Language :: Python :: 3.9",
        "Programming Language :: Python :: 3.10",
    ],
)
