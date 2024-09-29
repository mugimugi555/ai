#!/bin/bash

# CUDAのインストール方法のヘルプ
echo "CUDAがインストールされているか確認します..."

if ! nvcc --version &>/dev/null; then
    echo "CUDAがインストールされていません。"
    echo "CUDAをインストールするには、以下のコマンドを実行してください。"
    echo "1. 必要な依存関係をインストール: sudo apt update && sudo apt install -y build-essential"
    echo "2. CUDA Toolkitをダウンロード: wget https://developer.download.nvidia.com/compute/cuda/11.8.0/local_installers/cuda_11.8.0_520.61.05_linux.run"
    echo "3. CUDAをインストール: sudo sh cuda_11.8.0_520.61.05_linux.run --silent --toolkit"
    echo "4. 環境変数を設定: echo 'export PATH=/usr/local/cuda/bin:\$PATH' >> ~/.bashrc"
    echo "5. 環境変数を適用: source ~/.bashrc"
else
    echo "CUDAが正常にインストールされています。"
fi

# ffmpegのインストール方法のヘルプ
echo "ffmpegがインストールされているか確認します..."

if ! ffmpeg -version &>/dev/null; then
    echo "ffmpegがインストールされていません。"
    echo "ffmpegをインストールするには、以下のコマンドを実行してください。"
    echo "sudo apt update && sudo apt install -y ffmpeg"
else
    echo "ffmpegが正常にインストールされています。"
fi

# コマンドライン引数から入力ファイルを取得
if [ "$#" -lt 1 ]; then
    echo "使用法: ./upscale.sh <input_video_file>"
    exit 1
fi

input_movie_file_name="$1"

# 動画ファイル名から拡張子を取り除いて作業用ディレクトリ名を設定
base_name=$(basename "$input_movie_file_name" .mp4)
working_dir_input="${base_name}_input"
working_dir_upscaled="${base_name}_upscaled"

# 出力ファイル名を指定 (元のファイル名に -upscaled を追加)
output_movie_file_name="${base_name}-upscaled.mp4"

# 作業用ディレクトリの作成と初期化
mkdir -p "$working_dir_input"
rm -f "$working_dir_input/*.png"

mkdir -p "$working_dir_upscaled"
rm -f "$working_dir_upscaled/*.png"

# input.mp4からフレームをPNG形式で抽出
ffmpeg -i "$input_movie_file_name" -vcodec png "$working_dir_input/%03d.png" > /dev/null 2>&1

# PNGファイルの枚数をカウント
totalFiles=$(find "$working_dir_input" -type f -name '*.png' | wc -l)

# 対象画像ファイル数を表示
echo "対象画像ファイル数: $totalFiles"

# 入力ファイルのフレームレートを取得
frameRate=$(ffmpeg -i "$input_movie_file_name" 2>&1 | grep -oP '\d+(\.\d+)? fps' | awk '{print $1}')

# 入力フレームレートを表示
echo "入力フレームレート: $frameRate"

# Real-ESRGANで画像のアップスケールを実行し、進捗を表示
processedFiles=0
startTime=$(date +%s)

# PNGファイルを取得
files=("$working_dir_input"/*.png)

for file in "${files[@]}"; do
    outputFile="$working_dir_upscaled/$(basename "$file")"

    # Real-ESRGANで1枚ずつアップスケール
    CMD="./realesrgan-ncnn-vulkan -i \"$file\" -o \"$outputFile\" -n realesrgan-x4plus -s 4 -f png"
    eval "$CMD" > /dev/null 2>&1

    processedFiles=$((processedFiles + 1))

    # プログレスバーの表示を更新
    progress=$((processedFiles * 100 / totalFiles))
    echo -ne "\r進行状況: $progress%"

    # 残り時間の推定
    elapsedTime=$(( $(date +%s) - startTime ))
    if [ "$processedFiles" -ne 0 ]; then
        remainingTime=$(( (elapsedTime * (totalFiles - processedFiles)) / processedFiles ))
    else
        remainingTime=0
    fi
    remainingMinutes=$(( remainingTime / 60 ))
    remainingSeconds=$(( remainingTime % 60 ))
    echo -ne " 残り時間: $remainingMinutes分$remainingSeconds秒"
done

echo -e "\n"

# 生成されたPNGから動画を作成（音声なし）の高画質設定
ffmpeg -y -framerate "$frameRate" -i "$working_dir_upscaled/%03d.png" -c:v hevc_nvenc -preset p7 -rc vbr -cq 17 -b:v 20M -maxrate 30M -bufsize 40M -pix_fmt yuv444p working_upscaled_none_audio.mp4 > /dev/null 2>&1

# input.mp4から音声を抽出して、指定された出力ファイルに追加する
ffmpeg -i working_upscaled_none_audio.mp4 -i "$input_movie_file_name" -c copy -map 0:v:0 -map 1:a:0 -shortest -y "$output_movie_file_name" > /dev/null 2>&1

# 一時ファイルの削除
rm -f working_upscaled_none_audio.mp4

# 最終的な出力動画の情報を表示
echo "出力された動画の情報:"
ffmpeg -i "$output_movie_file_name" 2>&1 | grep -E "Duration:|Stream.*Video:|Stream.*Audio:"

exit 0
