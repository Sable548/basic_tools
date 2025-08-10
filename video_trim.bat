@echo off
setlocal EnableDelayedExpansion

:: Prompt for input file
set /p input_file="Enter the input video file (e.g., video.mp4 or 'video with spaces.mp4'): "
:: Remove any surrounding quotes from input
set "input_file=%input_file:"=%"
if not exist "!input_file!" (
    echo Error: Input file does not exist.
    pause
    exit /b
)

:: Prompt for start time
echo Enter start time. Examples:
echo   Detailed: HH:MM:SS.sss (e.g., 00:39:54.000)
echo   Simple: MM:SS (e.g., 39:54)
set /p start_time="Start time: "

:: Prompt for end time
echo Enter end time. Examples:
echo   Detailed: HH:MM:SS.sss (e.g., 00:41:47.000)
echo   Simple: MM:SS (e.g., 41:47)
set /p end_time="End time: "

:: Prompt for video format conversion
echo Enter video format (or press Enter for direct copy):
echo   copy: No conversion, preserves original quality (fastest, works with MP4, MKV, AVI, WebM, etc.).
echo   h264: Converts to H.264 (widely compatible, good for MP4, MKV; web and devices).
echo   h265: Converts to H.265/HEVC (better compression, smaller files, modern devices; MP4, MKV).
echo   vp9: Converts to VP9 (efficient for web streaming, best with WebM, also supports MKV).
echo   mpeg4: Converts to MPEG-4 Part 2 (older format, compatible with MP4, AVI; legacy devices).
set /p video_format="Video format [copy/h264/h265/vp9/mpeg4]: "
if "!video_format!"=="" set video_format=copy

:: Prompt for audio format conversion
echo Enter audio format (or press Enter for direct copy):
echo   copy: No conversion, preserves original quality (fastest, works with MP4, MKV, AVI, WebM, etc.).
echo   aac: Converts to AAC (widely compatible, good for MP4, MKV; most players).
echo   mp3: Converts to MP3 (universal compatibility, works with MP4, AVI, MKV; slightly larger files).
echo   opus: Converts to Opus (high quality, efficient, best with WebM, also supports MKV).
echo   flac: Converts to FLAC (lossless, high fidelity, larger files; best with MKV, also MP4, AVI).
set /p audio_format="Audio format [copy/aac/mp3/opus/flac]: "
if "!audio_format!"=="" set audio_format=copy

:: Prompt for output file format
echo Enter output file format (or press Enter to keep input format):
echo   mp4: Widely compatible, supports H.264, H.265, MPEG-4, AAC, MP3, FLAC.
echo   mkv: Flexible, supports all codecs (H.264, H.265, VP9, MPEG-4, AAC, MP3, Opus, FLAC).
echo   avi: Older format, supports MPEG-4, MP3, FLAC (less compatible with H.265, VP9, Opus).
echo   webm: Optimized for web, best with VP9 and Opus (supports H.264, AAC in some cases).
set /p output_format="Output format [mp4/mkv/avi/webm]: "

:: Extract file name and extension
for %%F in ("!input_file!") do (
    set "file_name=%%~nF"
    set "file_ext=%%~xF"
)

:: Set output extension (use input extension if output_format is empty)
if "!output_format!"=="" (
    set "output_ext=!file_ext!"
) else (
    set "output_ext=.!output_format!"
)

:: Initialize output file name
set "counter=001"
set "output_file=!file_name!_cut!counter!!output_ext!"

:: Check for existing files and increment counter
:check_file
if exist "!output_file!" (
    set /a counter+=1
    set "counter=00!counter!"
    set "counter=!counter:~-3!"
    set "output_file=!file_name!_cut!counter!!output_ext!"
    goto check_file
)

:: Build FFmpeg command with proper quoting
set "ffmpeg_cmd=ffmpeg -i "!input_file!" -ss !start_time! -to !end_time! -c:v !video_format! -c:a !audio_format! "!output_file!""
if "!video_format!"=="h264" (
    set "ffmpeg_cmd=ffmpeg -i "!input_file!" -ss !start_time! -to !end_time! -c:v libx264 -crf 18 -preset fast -c:a !audio_format! "!output_file!""
) else if "!video_format!"=="h265" (
    set "ffmpeg_cmd=ffmpeg -i "!input_file!" -ss !start_time! -to !end_time! -c:v libx265 -crf 20 -preset fast -c:a !audio_format! "!output_file!""
) else if "!video_format!"=="vp9" (
    set "ffmpeg_cmd=ffmpeg -i "!input_file!" -ss !start_time! -to !end_time! -c:v libvpx-vp9 -crf 30 -b:v 0 -c:a !audio_format! "!output_file!""
) else if "!video_format!"=="mpeg4" (
    set "ffmpeg_cmd=ffmpeg -i "!input_file!" -ss !start_time! -to !end_time! -c:v mpeg4 -q:v 3 -c:a !audio_format! "!output_file!""
)

:: Execute FFmpeg command
echo Running: !ffmpeg_cmd!
!ffmpeg_cmd!

:: Check if FFmpeg was successful
if !errorlevel! equ 0 (
    echo Video successfully created: "!output_file!"
) else (
    echo Error: FFmpeg failed to process the video.
)

pause