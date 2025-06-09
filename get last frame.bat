@echo off
setlocal enabledelayedexpansion

set /p input_video="Enter the path to your input video file: "

rem Get the base filename without extension
for %%f in ("%input_video%") do (
    set "base_name=%%~nf"
)

set "output_base_name=%base_name%_last_"
set "output_extension=.png"
set "counter=1"

:check_file
rem Format the counter with leading zeros
set "formatted_counter=00!counter!"
set "formatted_counter=!formatted_counter:~-3!"

set "output_image=%output_base_name%!formatted_counter!%output_extension%"
if exist "%output_image%" (
    set /a counter+=1
    goto check_file
)


ffmpeg -sseof -0.1 -i "%input_video%" -vframes 1 -q:v 1 "%output_image%"

echo Frame extracted and saved as %output_image%.
pause