@echo off
setlocal EnableDelayedExpansion

:: Prompt for GIF file 
set /p "input_file=Please enter the path to the GIF file (or drag and drop the file here):"

:: Remove quotes from input path if present 
set "input_file=%input_file:"=%"

:: Get the directory and filename without extension 
for %%F in ("%input_file%") do ( 
	set "file_dir=%%~dpF"
	set "file_name=%%~nF"
)

:: Create output folder named _frames 
set "output_folder=%file_dir%%file_name%_frames" 
if not exist "%output_folder%" mkdir "%output_folder%"

:: Run ffmpeg to extract frames 
echo Extracting frames from %input_file%... 
ffmpeg -i "%input_file%" -vsync 0 "%output_folder%\%file_name%_%%04d.png"

:: Check if ffmpeg succeeded 
if %ERRORLEVEL% equ 0 ( 
	echo Frames extracted successfully to %output_folder%! 
) else ( 
	echo An error occurred during extraction. Please check if ffmpeg is installed and the file path is correct. 
)

pause