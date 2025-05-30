@echo off
setlocal EnableDelayedExpansion

:: Prompt user for the MP4 file path
set /p "input_file=Please enter the path to the MP4 file (or drag and drop the file here):"

:: Remove quotes from input path if present 
set input_file=%input_file:"=%

:: Prompt user for frames per second
set /p "fps=Please enter the frames per second (e.g., 1 for one frame per second):"

:: Validate FPS input (basic check for non-empty and numeric) 
if "!fps!"=="" ( 
	echo Error: FPS value cannot be empty. 
	pause 
	exit /b 
) 

echo !fps!| findstr /r "^[0-9]*\.[0-9]*$ ^[0-9]*$" >nul 
if %ERRORLEVEL% neq 0 ( 
	echo Error: Please enter a valid number for FPS. 
	pause exit /b 
)

:: Extract directory and filename without extension 
for %%F in ("%input_file%") do ( 
	set "file_dir=%%~dpF" 
	set "file_name=%%~nF" 
)

:: Create output folder named _frames 
set "output_folder=%file_dir%%file_name%_frames" 
if not exist "%output_folder%" mkdir "%output_folder%" 

:: Extract frames using ffmpeg with specified FPS 
echo Extracting frames from %input_file% at %fps% FPS... 
ffmpeg -i "%input_file%" -vf fps=%fps% "%output_folder%\%file_name%_%%04d.png"

:: Check if ffmpeg command was successful 
if %ERRORLEVEL% equ 0 ( 
	echo Frames extracted successfully to %output_folder%! 
) else ( 
	echo An error occurred during extraction. Please check if ffmpeg is installed and the file path is correct. 
)

:: Pause to display result 
pause