# RealSRのダウンロードとセットアップ手順

1. **RealSRをダウンロードして解凍します。**
    ```bash
    wget https://github.com/nihui/realsr-ncnn-vulkan/releases/download/20220728/realsr-ncnn-vulkan-20220728-ubuntu.zip
    unzip realsr-ncnn-vulkan-20220728-ubuntu.zip
    cd realsr-ncnn-vulkan-20220728-ubuntu
    ```

2. **アップスケールスクリプトをダウンロードします。**
    ```bash
    wget https://raw.githubusercontent.com/mugimugi555/ai/refs/heads/main/upscale/realesrgan/upscale.sh
    ```

3. **テスト用の動画をダウンロードします。**
    ```bash
    wget https://raw.githubusercontent.com/mugimugi555/ai/refs/heads/main/upscale/realesrgan/test.mp4
    ```

4. **アップスケールを開始します。**
    ```bash
    bash upscale.sh test.mp4
    ```
