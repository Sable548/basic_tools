@echo off
setlocal EnableDelayedExpansion

:INPUT_FILE 
set /p input_file="Enter the input video file (e.g., video1.mp4): " 
:: Strip quotes from input_file if present 
set input_file=%input_file:"=% 
if not exist "!input_file!" ( 
	echo File "!input_file!" does not exist. Please try again. 
	goto INPUT_FILE 
)

:MENU
cls
echo Metadata Query Tool for "!input_file!"
echo Available options:
echo 1 - Duration
echo 2 - Bitrate
echo 3 - Stream
echo 4 - Video Stream
echo 5 - Audio Stream
echo 6 - Frame Rate
echo txt - Save all metadata to metadata.txt
echo q - Quit
echo.

set /p choice="Enter your choice (1-6, txt, or q): "

if /i "!choice!"=="1" (
    echo Querying Duration...
    ffmpeg -i "!input_file!" 2>&1|findstr "Duration"
    pause
    goto MENU
)

if /i "!choice!"=="2" (
    echo Querying Bitrate...
    ffmpeg -i "!input_file!" 2>&1|findstr "bitrate"
    pause
    goto MENU
)

if /i "!choice!"=="3" (
    echo Querying Stream...
    ffmpeg -i "!input_file!" 2>&1|findstr "Stream"
    pause
    goto MENU
)

if /i "!choice!"=="4" (
    echo Querying Video Stream...
    ffmpeg -i "!input_file!" 2>&1|findstr "Video:"
    pause
    goto MENU
)

if /i "!choice!"=="5" (
    echo Querying Audio Stream...
    ffmpeg -i "!input_file!" 2>&1|findstr "Audio:"
    pause
    goto MENU
)

if /i "!choice!"=="6" ( 
	echo Querying Frame Rate... 
	ffprobe -v error -select_streams v:0 -show_entries stream=r_frame_rate -of default=noprint_wrappers=1:nokey=1 "!input_file!" 
	if !errorlevel! neq 0 ( 
		echo Error: Failed to retrieve Frame Rate. Check if the file is valid. 
	) 
	pause 
	goto MENU 
)

if /i "!choice!"=="txt" (
	rem Get the base filename without extension
	for %%f in ("!input_file!") do (
		set "base_name=%%~nf"
	)

	echo Saving all metadata to metadata.txt... 
	ffprobe -v quiet -print_format json -show_format -show_streams -show_chapters -show_programs "!input_file!" > !base_name!_metadata.txt 
	if !errorlevel! neq 0 ( 
		echo Error: Failed to save metadata. Check if the file is valid. 
	) else (
		echo Metadata saved to metadata.txt 
	) 
	pause 
	goto MENU 
) 

if /i "!choice!"=="q" (
    echo Exiting...
    exit /b
)

echo Invalid choice. Please enter 1-5, txt, or q.
pause
goto MENU