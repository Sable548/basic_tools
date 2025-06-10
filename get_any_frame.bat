@echo off
setlocal enabledelayedexpansion

set /p input_video="Enter the path to your input video file (e.g., video.mp4): " 

if not exist "%input_video%" ( 
	echo Error: The specified video file does not exist. 
	pause 
	exit /b 1 
)

set /p seek_time="Enter the time to extract a frame from (in seconds, e.g., 5 or 5.3):" 

:: Validate FPS input (basic check for non-empty and numeric) 
if "!seek_time!"=="" ( 
	echo Error: Value cannot be empty. 
	pause 
	exit /b 
) 

echo !seek_time!|findstr /r "^[0-9]*\.[0-9]*$ ^[0-9]*$" >nul 
if %errorlevel% neq 0 ( 
	echo Error: Please enter a valid non-negative number.
	pause
	exit /b 1
)


:: Get the base filename without extension 
for %%f in ("%input_video%") do (
	set "base_name=%%~nf" 
)

set "output_base_name=%base_name%_frame_at_%seek_time%s_" 
set "output_extension=.png" 
set "counter=1"

:check_file 
:: Format the counter with leading zeros 
set "formatted_counter=00!counter!" 
set "formatted_counter=!formatted_counter:~-3!"

set "output_image=%output_base_name%!formatted_counter!%output_extension%" 
if exist "%output_image%" ( 
	set /a counter+=1 
	goto check_file 
)

ffmpeg -ss %seek_time% -i "%input_video%" -vframes 1 -q:v 1 "%output_image%"

if !errorlevel! neq 0 ( 
	echo Error: Failed to extract frame using ffmpeg. 
	pause 
	exit /b !errorlevel! 
)

echo Frame extracted and saved as %output_image%. 
pause