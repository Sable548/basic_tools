@echo off
setlocal EnableDelayedExpansion

title Merge Videos with Crossfade
echo Video Merging Script with Crossfade Effects

:: Check if ffmpeg and ffprobe are available
where ffmpeg >nul 2>nul
if %errorlevel% neq 0 (
    echo ERROR: FFmpeg not found. Ensure FFmpeg is installed and in your PATH.
    pause
    exit /b 1
)
where ffprobe >nul 2>nul
if %errorlevel% neq 0 (
    echo ERROR: FFprobe not found. Ensure FFmpeg is installed and in your PATH.
    pause
    exit /b 1
)

:: Prompt for first video file
:INPUT_VIDEO1
set /p video1="Enter the first video file (e.g., video1.mp4): "
set video1=!video1:"=!
if not exist "!video1!" (
    echo ERROR: File "!video1!" does not exist. Please try again.
    goto INPUT_VIDEO1
)

:: Prompt for second video file
:INPUT_VIDEO2
set /p video2="Enter the second video file (e.g., video2.mp4): "
set video2=!video2:"=!
if not exist "!video2!" (
    echo ERROR: File "!video2!" does not exist. Please try again.
    goto INPUT_VIDEO2
)

:: Get durations using ffprobe with temporary files 
ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "!video1!" > "%temp%\duration1.txt" 
ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "!video2!" > "%temp%\duration2.txt"

:: Read durations from temp files 
set /p duration1=<"%temp%\duration1.txt" 
set /p duration2=<"%temp%\duration2.txt"

:: Clean up temp files 
del "%temp%\duration1.txt" "%temp%\duration2.txt" 2>nul

:: Validate durations 
if "!duration1!"=="" ( 
	echo ERROR: Could not retrieve duration for "!video1!". Check if the file is valid. 
	pause 
	exit /b 1 
) 
if "!duration2!"=="" (
	echo ERROR: Could not retrieve duration for "!video2!". Check if the file is valid. 
	pause 
	exit /b 1 
)

:: Display durations 
echo. 
echo Video Durations: 
echo Video 1: !duration1! seconds 
echo Video 2: !duration2! seconds

:: Prompt for audio inclusion
:INPUT_AUDIO
set /p include_audio="Include audio with crossfade? (y/n): "
if /i "!include_audio!"=="y" (
    set audio_filter=1
) else if /i "!include_audio!"=="n" (
    set audio_filter=0
) else (
    echo ERROR: Please enter 'y' or 'n'.
    goto INPUT_AUDIO
)
echo audio_filter is !audio_filter!
:: Prompt for fade duration
:INPUT_FADE
set /p fade_duration="Enter fade duration in seconds (e.g., 1): "

:: Calculate offset
set offset=0
for /f "tokens=*" %%i in ('powershell -command "!duration1! - !fade_duration!"') do set offset=%%i
echo Calculated offset: !offset! seconds

:: Prompt for video codec (-c:v)
:INPUT_VCODEC
echo.
echo Select video codec (-c:v):
echo 1 - libx264 (H.264, high compatibility, good quality, default)
echo 2 - libx265 (H.265/HEVC, better compression, less compatibility)
echo 3 - vp9 (WebM, good for web, open-source)
set /p vcodec_choice="Enter choice (1-3, default 1): "
if "!vcodec_choice!"=="" set vcodec_choice=1
if "!vcodec_choice!"=="1" (
    set vcodec=libx264
) else if "!vcodec_choice!"=="2" (
    set vcodec=libx265
) else if "!vcodec_choice!"=="3" (
    set vcodec=vp9
) else (
    echo ERROR: Invalid choice. Please enter 1, 2, or 3.
    goto INPUT_VCODEC
)

:: Prompt for pixel format (-pix_fmt)
:INPUT_PIXFMT
echo.
echo Select pixel format (-pix_fmt):
echo 1 - yuv420p (Widely compatible, default for most players)
echo 2 - yuv444p (Higher quality, larger files, less compatible)
echo 3 - nv12 (Hardware-friendly, common for H.264/H.265)
set /p pixfmt_choice="Enter choice (1-3, default 1): "
if "!pixfmt_choice!"=="" set pixfmt_choice=1
if "!pixfmt_choice!"=="1" (
    set pixfmt=yuv420p
) else if "!pixfmt_choice!"=="2" (
    set pixfmt=yuv444p
) else if "!pixfmt_choice!"=="3" (
    set pixfmt=nv12
) else (
    echo ERROR: Invalid choice. Please enter 1, 2, or 3.
    goto INPUT_PIXFMT
)

:: Prompt for audio codec (-c:a) if audio is included
if !audio_filter! equ 1 (
    :INPUT_ACODEC
    echo.
    echo Select audio codec ^(-c:a^):
    echo 1 - aac ^(Widely compatible, good quality, default^)
    echo 2 - mp3 ^(Older format, highly compatible^)
    echo 3 - opus ^(Modern, high quality, good for web^)
    set /p acodec_choice="Enter choice ^(1-3, default 1^): "
    if "!acodec_choice!"=="" set acodec_choice=1
    if "!acodec_choice!"=="1" (
        set acodec=aac
    ) else if "!acodec_choice!"=="2" (
        set acodec=mp3
    ) else if "!acodec_choice!"=="3" (
        set acodec=opus
    ) else (
        echo ERROR: Invalid choice. Please enter 1, 2, or 3.
        goto INPUT_ACODEC
    )
) else (
    set acodec=
)

:: Generate unique output filename
set index=1
:CHECK_OUTPUT
set "formatted_index=00!index!"
set "formatted_index=!formatted_index:~-3!"
set output_file=output!formatted_index!.mp4
if exist "!output_file!" (
    set /a index+=1
    goto CHECK_OUTPUT
)

:: Build FFmpeg command
if !audio_filter! equ 1 (
    set filter_complex="[0:v][1:v]xfade=transition=fade:duration=!fade_duration!:offset=!offset![v];[0:a][1:a]acrossfade=d=!fade_duration![a]"
    set map=-map "[v]" -map "[a]"
) else (
    set filter_complex="[0:v][1:v]xfade=transition=fade:duration=!fade_duration!:offset=!offset![v]"
    set map=-map "[v]"
)

echo.
echo Running FFmpeg command:
if !audio_filter! equ 0 (
	echo ffmpeg -i "!video1!" -i "!video2!" -filter_complex !filter_complex! !map! -c:v !vcodec! -pix_fmt !pixfmt! "!output_file!"
	ffmpeg -i "!video1!" -i "!video2!" -filter_complex !filter_complex! !map! -c:v !vcodec! -pix_fmt !pixfmt! "!output_file!"
) else (
	echo ffmpeg -i "!video1!" -i "!video2!" -filter_complex !filter_complex! !map! -c:v !vcodec! -pix_fmt !pixfmt! -c:a !acodec! "!output_file!"
	ffmpeg -i "!video1!" -i "!video2!" -filter_complex !filter_complex! !map! -c:v !vcodec! -pix_fmt !pixfmt! -c:a !acodec! "!output_file!"
)


if !errorlevel! neq 0 (
    echo ERROR: FFmpeg failed to merge videos. Check input files or FFmpeg installation.
) else (
    echo Success: Videos merged into "!output_file!".
)

pause
exit /b 0