@echo off
setlocal EnableDelayedExpansion

:INPUT_FOLDER 
:: Prompt for input folder
echo Enter the input folder path containing the frame images (e.g., C:\frames).
echo Hint: Ensure the folder contains sequentially numbered images like img0001.png.
set /p input_folder="Input folder [default: .\frames]: "
set input_folder=!input_folder:"=!
if not exist "!input_folder!" ( 
	echo File "!input_file!" does not exist. Please try again. 
	goto INPUT_FILE 
)
if "!input_folder!"=="" set input_folder=.\frames
echo.

:: Prompt for filename prefix
echo Enter the filename prefix for the images (e.g., img for img0001.png).
echo Hint: Only include the base name before the number and extension (e.g., 'img' for img0001.png).
set /p prefix="Filename prefix [default: frame]: "
if "!prefix!"=="" set prefix=frame
echo.

:: Prompt for start number
echo Enter the starting frame number (e.g., 61).
echo Hint: This is the number of the first frame in the sequence.
set /p start_num="Start number [default: 1]: "
if "!start_num!"=="" set start_num=1
echo.

:: Prompt for framerate
echo Enter the framerate for the output video (e.g., 24, 30, 60).
echo Hint: Common framerates are 24 (film), 30 (video), 60 (smooth motion).
set /p framerate="Framerate [default: 24]: "
if "!framerate!"=="" set framerate=24
echo.

:: Prompt for video codec (-c:v) with numbered selection
echo Available video codecs (-c:v):
echo 1. libx264 (default, H.264, good quality and compatibility)
echo 2. libx265 (H.265, better compression)
echo 3. vp9 (WebM, good for web)
echo 4. mpeg4 (older codec)
set /p codec_choice="Enter video codec number (1-4, default: 1): " || set codec_choice=1
if "!codec_choice!"=="1" set codec=libx264
if "!codec_choice!"=="2" set codec=libx265
if "!codec_choice!"=="3" set codec=vp9
if "!codec_choice!"=="4" set codec=mpeg4
echo Selected video codec: !codec!
echo.

:: Prompt for pixel format (-pix_fmt) with numbered selection
echo Available pixel formats (-pix_fmt):
echo 1. yuv420p (default, standard for most players)
echo 2. yuv444p (higher quality, less compatible)
set /p pix_choice="Enter pixel format number (1-2, default: 1): " || set pix_choice=1
if "!pix_choice!"=="1" set pix_fmt=yuv420p
if "!pix_choice!"=="2" set pix_fmt=yuv444p
echo Selected pixel format: !pix_fmt!
echo.

:: Count the number of frames in the input folder to determine the end frame
set frame_count=0
for %%F in ("!input_folder!\!prefix!*.png") do (
    set /a frame_count+=1
)
if !frame_count! equ 0 (
    echo Error: No frames found in the specified folder with prefix '!input_folder!\!prefix!'.
    pause
    exit /b
)
set /a end_num=start_num+frame_count-1

:: Set output filename based on frame range
set output_file=!prefix!_!start_num!to!end_num!.mp4

:: Construct and execute FFmpeg command
echo Generating video with the following command:
echo ffmpeg -framerate !framerate! -start_number !start_num! -i "!input_folder!\!prefix!%%04d.png" -c:v !codec! -pix_fmt !pix_fmt! "!output_file!"
ffmpeg -framerate !framerate! -start_number !start_num! -i "!input_folder!\!prefix!%%04d.png" -c:v !codec! -pix_fmt !pix_fmt! "!output_file!"

:: Check if FFmpeg command was successful
if %ERRORLEVEL% equ 0 (
    echo Video created successfully: !output_file!
) else (
    echo Error: Video creation failed. Check FFmpeg installation or input parameters.
)

pause