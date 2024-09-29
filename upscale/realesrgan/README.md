# RealSRをダウンロードして解凍
wget https://github.com/nihui/realsr-ncnn-vulkan/releases/download/20220728/realsr-ncnn-vulkan-20220728-ubuntu.zip
unzip realsr-ncnn-vulkan-20220728-ubuntu.zip
cd realsr-ncnn-vulkan-20220728-ubuntu

# アップスケールスクリプトをダウンロード
wget https://raw.githubusercontent.com/mugimugi555/ai/refs/heads/main/upscale/realesrgan/upscale.sh

# テスト用の動画をダウンロード
wget https://raw.githubusercontent.com/mugimugi555/ai/refs/heads/main/upscale/realesrgan/test.mp4

# アップスケールを開始
bash upscale.sh test.mp4
