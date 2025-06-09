@echo off
setlocal EnableDelayedExpansion

:: Initialize variables
set "count=0"

:: Prompt for input files
echo Enter video filenames one by one (press Enter after each, type 'm' to merge):
:loop
set /p "input=File: "
if /i "!input!"=="m" goto :process
if not "!input!"=="" (
    :: Check if file exists
    if exist "!input!" (
        set /a count+=1
        :: Store input for later writing
        set "input_!count!=!input!"
    ) else (
        echo File "!input!" not found, please try again.
    )
)
goto :loop

:process
:: Check if any files were added
if !count! equ 0 (
    echo No files provided. Exiting.
    pause
    exit /b
)

:: Find next available merged_XXX.txt
set "txt_num=1"
:check_txt
set "formatted_txt_num=00!txt_num!"
set "formatted_txt_num=!formatted_txt_num:~-3!"
set "txt_file=merged_!formatted_txt_num!.txt"
if exist "!txt_file!" (
    set /a txt_num+=1
    goto :check_txt
)

:: Write file list to txt with line breaks
del "!txt_file!" 2>nul
for /l %%i in (1,1,!count!) do (
    echo file '!input_%%i!' >> "!txt_file!"
)

:: Find next available output_merged_XXX.mp4
set "out_num=1"
:check_output
set "formatted_out_num=00!out_num!"
set "formatted_out_num=!formatted_out_num:~-3!"
set "output_file=output_merged_!formatted_out_num!.mp4"
if exist "!output_file!" (
    set /a out_num+=1
    goto :check_output
)

:: Run FFmpeg command
echo Merging files using FFmpeg...
ffmpeg -f concat -safe 0 -i "!txt_file!" -c copy "!output_file!"

:: Check if FFmpeg was successful
if !errorlevel! equ 0 (
    echo Merge completed successfully: !output_file!
) else (
    echo An error occurred during merging.
)

pause
endlocal