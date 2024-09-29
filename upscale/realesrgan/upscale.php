<?php

// コマンドライン引数から入力ファイルを取得
if ($argc < 2) {
    echo "使用法: php script.php <input_video_file>\n";
    exit(1);
}

$target_movie_file_name = $argv[1]; // ターミナルから指定された入力動画ファイル

// 動画ファイル名から拡張子を取り除いて作業用ディレクトリ名を設定
$base_name = pathinfo($target_movie_file_name, PATHINFO_FILENAME);
$working_dir_target = "{$base_name}_target";
$working_dir_result = "{$base_name}_upscaled";

// 出力ファイル名を指定 (元のファイル名に -upscaled を追加)
$output_movie_file_name = "{$base_name}-upscaled.mp4";

// 作業用ディレクトリの作成と初期化
@mkdir($working_dir_target);
$CMD = "rm -f {$working_dir_target}/*.png";
@system($CMD);

@mkdir($working_dir_result);
$CMD = "rm -f {$working_dir_result}/*.png";
@system($CMD);

// input.mp4からフレームをPNG形式で抽出
$CMD = "ffmpeg -i {$target_movie_file_name} -vcodec png {$working_dir_target}/%03d.png > /dev/null 2>&1";
ob_start();
system($CMD);
ob_end_clean();

// 入力ファイルのフレームレートを取得
$CMD = "ffmpeg -i {$target_movie_file_name} 2>&1 | grep 'fps' | awk '{print $2}' | sed 's/[^0-9]//g'";
$frameRate = (int)shell_exec($CMD);

// PNGファイルの枚数をカウント
$files = glob("{$working_dir_target}/*.png");
$totalFiles = count($files);

// Real-ESRGANで画像のアップスケールを実行し、進捗を表示
$processedFiles = 0;
$startTime = time(); // 処理開始時間を記録

foreach ($files as $index => $file) {
    // 出力ファイル名を指定 (元のファイル名をそのまま使用)
    $outputFile = "{$working_dir_result}/" . basename($file); // 元のファイル名を使用

    // Real-ESRGANで1枚ずつアップスケール
    $CMD = "./realesrgan-ncnn-vulkan -i \"$file\" -o \"$outputFile\" -n realesrgan-x4plus -s 4 -f png > /dev/null 2>&1";
    ob_start();
    system($CMD);
    ob_end_clean();
    
    $processedFiles++;
    
    // プログレスバーの表示を更新
    $progress = ($processedFiles / $totalFiles) * 100;
    $barLength = 50; // プログレスバーの長さ
    $completed = round(($processedFiles / $totalFiles) * $barLength);
    $remaining = $barLength - $completed;
    $progressBar = str_repeat('█', $completed) . str_repeat(' ', $remaining);

    // 残り時間の推定
    $elapsedTime = time() - $startTime;
    $estimatedTotalTime = ($elapsedTime / $processedFiles) * $totalFiles;
    $remainingTime = $estimatedTotalTime - $elapsedTime;
    $remainingMinutes = floor($remainingTime / 60);
    $remainingSeconds = $remainingTime % 60;

    // 進捗と残り時間を同じ行に表示
    echo sprintf("\r進行状況: [%s] %d/%d (%.2f%%) 残り時間: %02d分%02d秒", $progressBar, $processedFiles, $totalFiles, $progress, $remainingMinutes, $remainingSeconds);
    flush();
}

// 最後に改行を追加
echo "\n";

// 生成されたPNGから動画を作成（音声なし）の高画質設定
//$CMD = "ffmpeg -y -framerate {$frameRate} -i {$working_dir_result}/%03d.png -vf scale=3840:2160 -c:v hevc_nvenc -preset p7 -rc vbr -cq 17 -b:v 20M -maxrate 30M -bufsize 40M -pix_fmt yuv444p working_upscaled_none_audio.mp4";
$CMD = "ffmpeg -y -framerate {$frameRate} -i {$working_dir_result}/%03d.png -c:v hevc_nvenc -preset p7 -rc vbr -cq 17 -b:v 20M -maxrate 30M -bufsize 40M -pix_fmt yuv444p working_upscaled_none_audio.mp4";
system($CMD);

// input.mp4から音声を抽出して、指定された出力ファイルに追加する
$CMD = "ffmpeg -i working_upscaled_none_audio.mp4.mp4.mp4 -i {$target_movie_file_name} -c copy -map 0:v:0 -map 1:a:0 -shortest -y {$output_movie_file_name}";
system($CMD);

// 一時ファイルの削除
@unlink("working_upscaled_none_audio.mp4");

exit;

?>
