@echo off
setlocal EnableDelayedExpansion

:: Prompt for input file
set /p input_file="Enter the input .vtt file (e.g., subtitles.vtt or 'subtitles with spaces.vtt'): "
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

:: Prompt for reset to zero
echo Reset timestamps to start at 00:00? (y/n)
set /p reset_choice="Reset to zero [y/n]: "
if /i "!reset_choice!"=="y" (
    set "reset_to_zero=True"
) else (
    set "reset_to_zero=False"
)

:: Extract file name and extension
for %%F in ("!input_file!") do (
    set "file_name=%%~nF"
    set "file_ext=%%~xF"
)

:: Initialize output file name
set "counter=001"
set "output_file=!file_name!_clip!counter!!file_ext!"

:: Check for existing files and increment counter
:check_file
if exist "!output_file!" (
    set /a counter+=1
    set "counter=00!counter!"
    set "counter=!counter:~-3!"
    set "output_file=!file_name!_clip!counter!!file_ext!"
    goto check_file
)

:: Build Python command with proper quoting
set "python_cmd=python filter_vtt.py "!input_file!" "!output_file!" "!start_time!" "!end_time!" !reset_to_zero!"
echo Running: !python_cmd!
!python_cmd!

:: Check if Python command was successful
if !errorlevel! equ 0 (
    echo Subtitle file successfully created: "!output_file!"
) else (
    echo Error: Python script failed to process the subtitle file.
)

pause