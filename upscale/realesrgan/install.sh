#!/bin/bash

# see https://github.com/xinntao/Real-ESRGAN/releases

wget https://github.com/xinntao/Real-ESRGAN/releases/download/v0.2.5.0/realesrgan-ncnn-vulkan-20220424-ubuntu.zip
unzip realesrgan-ncnn-vulkan-20220424-ubuntu.zip -d realesrgan-ncnn-vulkan-20220424-ubuntu
cd realesrgan-ncnn-vulkan-20220424-ubuntu

#
chmod +x realesrgan-ncnn-vulkan

#
wget https://github.com/xinntao/Real-ESRGAN/releases/download/v0.2.5.0/realesr-animevideov3.pth     -P models
wget https://github.com/xinntao/Real-ESRGAN/releases/download/v0.2.5.0/realesr-general-wdn-x4v3.pth -P models
wget https://github.com/xinntao/Real-ESRGAN/releases/download/v0.2.5.0/realesr-general-x4v3.pth     -P models

#
wget https://raw.githubusercontent.com/mugimugi555/ai/refs/heads/main/upscale/realesrgan/upscale.sh
chmod +x upscale.sh
./upscale.sh onepiece_demo.mp4
