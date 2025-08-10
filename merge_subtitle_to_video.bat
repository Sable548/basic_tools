@echo off
setlocal EnableDelayedExpansion

:main_menu
cls
echo Subtitle Processing Script
echo 1. Subtitle file format conversion (srt, ass, vtt)
echo 2. Merge subtitle with video
set "mission="
set /p mission="Choose mission (1 or 2): "

if "!mission!"=="1" goto format_conversion
if "!mission!"=="2" goto merge_subtitle
goto main_menu

:format_conversion
cls
set "input_sub="
set /p input_sub="Enter input subtitle file (e.g., sub.srt): "
set "input_sub=!input_sub:"=!"
if not exist "!input_sub!" (
    echo Error: Input file does not exist.
    pause
    goto main_menu
)

echo Available formats: srt, ass, vtt
set "target_format="
set /p target_format="Enter target format: "

for %%F in ("!input_sub!") do (
    set "sub_name=%%~nF"
    set "sub_ext=%%~xF"
)

set "counter=001"
set "output_sub=!sub_name!_converted!counter!.!target_format!"

:check_sub
if exist "!output_sub!" (
    set /a counter+=1
    set "counter=00!counter!"
    set "counter=!counter:~-3!"
    set "output_sub=!sub_name!_converted!counter!.!target_format!"
    goto check_sub
)

set "ffmpeg_cmd=ffmpeg -i "!input_sub!" "!output_sub!""
echo Running: !ffmpeg_cmd!
!ffmpeg_cmd!

if !errorlevel! equ 0 (
    echo Conversion successful: "!output_sub!"
) else (
    echo Error: Conversion failed.
)
pause
goto main_menu

:merge_subtitle
cls
set /p video_file="Enter video file (e.g., video.mp4): "
set "video_file=!video_file:"=!"
if not exist "!video_file!" (
    echo Error: Video file does not exist.
    pause
    goto main_menu
)

set /p sub_file_fullpath="Enter subtitle file (e.g., sub.vtt): "
set "sub_file_fullpath=!sub_file_fullpath:"=!"
if not exist "!sub_file_fullpath!" (
    echo Error: Subtitle file does not exist.
    pause
    goto main_menu
)

for %%F in ("!sub_file_fullpath!") do (
    echo Filename with extension: %%~nxF
	set "sub_file=%%~nxF"
)
for %%F in ("!sub_file!") do set "sub_ext=%%~xF"

if /i "!sub_ext!"==".ass" (
    set "filter=ass='!sub_file!'"
    set "use_force_style=no"
) else (
    set "use_force_style=yes"
    set "filter=subtitles='!sub_file!'"
)

:: Initialize style variables
set "style1="
set "style2="
set "style3="
set "style4="
set "style5="
set "style6="
set "style7="
set "style8="
set "style9="
set "style10="
set "style11="
set "style12="
set "style13="
set "style14="
set "style15="
set "style16="
set "style17="
set "style18="
set "style19="
set "style20="
set "style21="
set "style22="
set "style23="
set "style24="

:style_menu
cls
echo Style Configuration for Merge (press number to edit, 'q' to quit/restart, 'm' to merge)
echo 1. Name !style1!
echo 2. Fontname !style2!
echo 3. Fontsize !style3!
echo 4. PrimaryColour !style4!
echo 5. SecondaryColour !style5!
echo 6. OutlineColour/TertiaryColour !style6!
echo 7. BackColour !style7!
echo 8. Bold !style8!
echo 9. Italic !style9!
echo 10. Underline !style10!
echo 11. StrikeOut !style11!
echo 12. ScaleX !style12!
echo 13. ScaleY !style13!
echo 14. Spacing !style14!
echo 15. Angle !style15!
echo 16. BorderStyle !style16!
echo 17. Outline !style17!
echo 18. Shadow !style18!
echo 19. Alignment !style19!
echo 20. MarginL !style20!
echo 21. MarginR !style21!
echo 22. MarginV !style22!
echo 23. AlphaLevel !style23!
echo 24. Encoding !style24!
echo q. Quit/Restart
echo.
echo Enter 'm' to merge if ready.

if "!use_force_style!"=="no" (
    echo Note: .ass file detected - styles ignored, using ass filter.
)

:: Initialize variables
set "choice="
set "field_num="

:: Prompt user for input
set /p choice="Choose field number, 'q', or 'm': "

:: Handle 'q' or 'm' options
if /i "!choice!"=="q" goto quit_restart
if /i "!choice!"=="m" goto execute_merge
if /i "!choice!"=="" goto style_menu

:: Validate if the choice is a number
for /f "delims=0123456789" %%a in ("!choice!") do (
    echo Invalid input. Please enter a number, 'q', or 'm'.
    goto style_menu
)

:: Convert choice to a number
set /a field_num=!choice!

:: Check numerical range and direct to corresponding label
if !field_num! gtr 0 if !field_num! lss 25 (
	goto edit_field_!choice!) 
else (
	goto style_menu
)


:edit_field_1
cls
echo Name: The name of the style. Usually not needed for override.
echo Format: String, e.g., Default
echo Suggestion: Leave empty unless overriding specific style.
set "new_value="
set /p new_value="Enter value (empty to clear): "
set "style1=!new_value!"
goto style_menu

:edit_field_2
cls
echo Fontname: The font name as used by Windows.
echo Format: String, e.g., Arial
echo Suggestion: Arial, Times New Roman, Verdana.
set "new_value="
set /p new_value="Enter value (empty to clear): "
set "style2=!new_value!"
goto style_menu

:edit_field_3
cls
echo Fontsize: The size of the font in points.
echo Format: Integer, e.g., 24
echo Suggestion: 16-28 for subtitles.
set "new_value="
set /p new_value="Enter value (empty to clear): "
set "style3=!new_value!"
goto style_menu

:edit_field_4
cls
echo PrimaryColour: A long integer BGR (blue-green-red) value. ie. the byte order in the hexadecimal equivalent of this number is BBGGRR. This is the colour that a subtitle will normally appear in.
echo Format: ^&HBBGGRR or Add alpha ^&HAABBGGRR, AA=00 opaque, FF transparent. e.g., ^&H00FFFFFF for white, ^&H00000000 for black, ^&H00CCCCCC for grey, ^&H000000FF for red, ^&H0000FF00 for green, ^&H00FF0000 for blue.
echo Suggestion: ^&H00FFFFFF for opaque white.
set "new_value="
set /p new_value="Enter value (empty to clear): "
set "style4=!new_value!"
goto style_menu

:edit_field_5
cls
echo SecondaryColour: This colour may be used instead of the Primary colour when a subtitle is automatically shifted to prevent an onscreen collision.
echo Format: ^&HBBGGRR, similar to PrimaryColour.
echo Suggestion: ^&H0000FFFF for cyan.
set "new_value="
set /p new_value="Enter value (empty to clear): "
set "style5=!new_value!"
goto style_menu

:edit_field_6
cls
echo OutlineColour/TertiaryColour: The color of the subtitle outline. TertiaryColour is another name for OutlineColour in some contexts.
echo Format: ^&HBBGGRR, e.g., ^&H00000000 for black.
echo Suggestion: ^&H00000000 for black outline.
set "new_value="
set /p new_value="Enter value (empty to clear): "
set "style6=!new_value!"
goto style_menu

:edit_field_7
cls
echo BackColour: The color of the outline or the rectangular background box for subtitles.
echo Format: ^&HBBGGRR, e.g., ^&H80000000 for semi-transparent black.
echo Suggestion: ^&H80000000 for 50%% opacity black, ^&HFF000000 for 100% transparent
set "new_value="
set /p new_value="Enter value (empty to clear): "
set "style7=!new_value!"
goto style_menu

:edit_field_8
cls
echo Bold: Defines whether text is bold.
echo Format: -1 for true, 0 for false.
echo Suggestion: -1 for bold.
set "new_value="
set /p new_value="Enter value (empty to clear): "
set "style8=!new_value!"
goto style_menu

:edit_field_9
cls
echo Italic: Defines whether text is italic.
echo Format: -1 for true, 0 for false.
echo Suggestion: -1 for italic.
set "new_value="
set /p new_value="Enter value (empty to clear): "
set "style9=!new_value!"
goto style_menu

:edit_field_10
cls
echo Underline: Defines whether text is underlined.
echo Format: -1 for true, 0 for false.
echo Suggestion: -1 for underline.
set "new_value="
set /p new_value="Enter value (empty to clear): "
set "style10=!new_value!"
goto style_menu

:edit_field_11
cls
echo StrikeOut: Defines whether text is strike-out.
echo Format: -1 for true, 0 for false.
echo Suggestion: 0 normally.
set "new_value="
set /p new_value="Enter value (empty to clear): "
set "style11=!new_value!"
goto style_menu

:edit_field_12
cls
echo ScaleX: Modifies the width of the font (a factor).
echo Format: Float, e.g., 1
echo Suggestion: 1 for normal.
set "new_value="
set /p new_value="Enter value (empty to clear): "
set "style12=!new_value!"
goto style_menu

:edit_field_13
cls
echo ScaleY: Modifies the height of the font (a factor).
echo Format: Float, e.g., 1
echo Suggestion: 1 for normal.
set "new_value="
set /p new_value="Enter value (empty to clear): "
set "style13=!new_value!"
goto style_menu

:edit_field_14
cls
echo Spacing: Extra space between characters (pixels).
echo Format: Float, e.g., 0
echo Suggestion: 0 for normal.
set "new_value="
set /p new_value="Enter value (empty to clear): "
set "style14=!new_value!"
goto style_menu

:edit_field_15
cls
echo Angle: The rotation angle of the text (degrees).
echo Format: Float, e.g., 0.0
echo Suggestion: 0 for no rotation.
set "new_value="
set /p new_value="Enter value (empty to clear): "
set "style15=!new_value!"
goto style_menu

:edit_field_16
cls
echo BorderStyle: Controls outline or background box.
echo Format: 1 for outline+shadow, 3 for opaque box.
echo Suggestion: 1 for standard, 3 for box.
set "new_value="
set /p new_value="Enter value (empty to clear): "
set "style16=!new_value!"
goto style_menu

:edit_field_17
cls
echo Outline: The width of the outline around the text (pixels). Use with 'BorderStyle'.
echo Format: Float, 0-4
echo Suggestion: 2 for visible outline.
set "new_value="
set /p new_value="Enter value (empty to clear): "
set "style17=!new_value!"
goto style_menu

:edit_field_18
cls
echo Shadow: The depth of the drop shadow (pixels). Use with 'BorderStyle'.
echo Format: Float, 0-4
echo Suggestion: 2 for visible shadow.
set "new_value="
set /p new_value="Enter value (empty to clear): "
set "style18=!new_value!"
goto style_menu

:edit_field_19
cls
echo Alignment: The alignment of the text.
echo Format: 1 bottom left, 2 bottom center, 3 bottom right, 5 top left, 6 top center, 7 top right, 9 mid left, 10 mid center, 11 mid right.
echo Suggestion: 2 for bottom center.
set "new_value="
set /p new_value="Enter value (empty to clear): "
set "style19=!new_value!"
goto style_menu

:edit_field_20
cls
echo MarginL: Left margin offset (pixels).
echo Format: Integer, e.g., 10
echo Suggestion: 10-20.
set "new_value="
set /p new_value="Enter value (empty to clear): "
set "style20=!new_value!"
goto style_menu

:edit_field_21
cls
echo MarginR: Right margin offset (pixels).
echo Format: Integer, e.g., 10
echo Suggestion: 10-20.
set "new_value="
set /p new_value="Enter value (empty to clear): "
set "style21=!new_value!"
goto style_menu

:edit_field_22
cls
echo MarginV: Vertical margin offset (pixels).
echo Format: Integer, e.g., 10
echo Suggestion: 10 for bottom.
set "new_value="
set /p new_value="Enter value (empty to clear): "
set "style22=!new_value!"
goto style_menu

:edit_field_23
cls
echo AlphaLevel: Legacy overall alpha transparency (0-255). Not used in ASS v4+, use per-color alpha instead.
echo Format: Integer, 0-255
echo Suggestion: 0 for opaque, but prefer color alphas.
set "new_value="
set /p new_value="Enter value (empty to clear): "
set "style23=!new_value!"
goto style_menu

:edit_field_24
cls
echo Encoding: Font encoding/character set.
echo Format: Integer, 0 ANSI, 1 default, 128 ShiftJIS.
echo Suggestion: 1 for default.
set "new_value="
set /p new_value="Enter value (empty to clear): "
set "style24=!new_value!"
goto style_menu

:quit_restart
cls
echo Want to quit or restart?
echo y: Quit the script
echo n: Return to style menu
echo r: Restart from beginning (clears all variables)
set "qr_choice="
set /p qr_choice="Enter choice (y/n/r): "
if /i "!qr_choice!"=="y" exit /b
if /i "!qr_choice!"=="n" goto style_menu
if /i "!qr_choice!"=="r" (
    set "video_file="
    set "sub_file="
    set "filter="
    set "use_force_style="
    set "style1="
    set "style2="
    set "style3="
    set "style4="
    set "style5="
    set "style6="
    set "style7="
    set "style8="
    set "style9="
    set "style10="
    set "style11="
    set "style12="
    set "style13="
    set "style14="
    set "style15="
    set "style16="
    set "style17="
    set "style18="
    set "style19="
    set "style20="
    set "style21="
    set "style22="
    set "style23="
    set "style24="
    goto main_menu
)
goto quit_restart

:execute_merge
if "!use_force_style!"=="yes" (
    set "force_style="
    if not "!style1!"=="" set "force_style=!force_style!Name=!style1!,"
    if not "!style2!"=="" set "force_style=!force_style!Fontname=!style2!,"
    if not "!style3!"=="" set "force_style=!force_style!Fontsize=!style3!,"
    if not "!style4!"=="" set "force_style=!force_style!PrimaryColour=!style4!,"
    if not "!style5!"=="" set "force_style=!force_style!SecondaryColour=!style5!,"
    if not "!style6!"=="" set "force_style=!force_style!OutlineColour=!style6!,"
    if not "!style7!"=="" set "force_style=!force_style!BackColour=!style7!,"
    if not "!style8!"=="" set "force_style=!force_style!Bold=!style8!,"
    if not "!style9!"=="" set "force_style=!force_style!Italic=!style9!,"
    if not "!style10!"=="" set "force_style=!force_style!Underline=!style10!,"
    if not "!style11!"=="" set "force_style=!force_style!StrikeOut=!style11!,"
    if not "!style12!"=="" set "force_style=!force_style!ScaleX=!style12!,"
    if not "!style13!"=="" set "force_style=!force_style!ScaleY=!style13!,"
    if not "!style14!"=="" set "force_style=!force_style!Spacing=!style14!,"
    if not "!style15!"=="" set "force_style=!force_style!Angle=!style15!,"
    if not "!style16!"=="" set "force_style=!force_style!BorderStyle=!style16!,"
    if not "!style17!"=="" set "force_style=!force_style!Outline=!style17!,"
    if not "!style18!"=="" set "force_style=!force_style!Shadow=!style18!,"
    if not "!style19!"=="" set "force_style=!force_style!Alignment=!style19!,"
    if not "!style20!"=="" set "force_style=!force_style!MarginL=!style20!,"
    if not "!style21!"=="" set "force_style=!force_style!MarginR=!style21!,"
    if not "!style22!"=="" set "force_style=!force_style!MarginV=!style22!,"
    if not "!style23!"=="" set "force_style=!force_style!AlphaLevel=!style23!,"
    if not "!style24!"=="" set "force_style=!force_style!Encoding=!style24!,"

    :: Remove trailing comma
    if not "!force_style!"=="" set "force_style=!force_style:~0,-1!"

    if not "!force_style!"=="" (
        set "filter=subtitles='!sub_file!':force_style='!force_style!'"
    ) else (
        set "filter=subtitles='!sub_file!'"
    )
) else (
    set "filter=ass='!sub_file!'"
)

for %%F in ("!video_file!") do (
    set "vid_name=%%~nF"
    set "vid_ext=%%~xF"
)

set "counter=001"
set "output_file=!vid_name!_mergesub!counter!!vid_ext!"

:check_output
if exist "!output_file!" (
    set /a counter+=1
    set "counter=00!counter!"
    set "counter=!counter:~-3!"
    set "output_file=!vid_name!_mergesub!counter!!vid_ext!"
    goto check_output
)

::set "ffmpeg_cmd=ffmpeg -i "!video_file!" -vf "!filter!" -c:v libx264 -crf 18 -c:a copy "!output_file!""
set "ffmpeg_cmd=ffmpeg -i "!video_file!" -vf "!filter!" "!output_file!""
echo Running: !ffmpeg_cmd!
!ffmpeg_cmd!

if !errorlevel! equ 0 (
    echo Merge successful: "!output_file!"
) else (
    echo Error: Merge failed.
)

echo.
echo Press Enter to continue editing styles, or any key to quit.
set "continue_choice="
set /p continue_choice=""
if "!continue_choice!"=="" goto style_menu
exit /b