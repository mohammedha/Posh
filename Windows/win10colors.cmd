REM NO Credit to me, all credit to Michele Locati 
REM https://gist.github.com/mlocati/fdabcaeb8071d5c75a2d51712db24011#file-win10colors-cmd

@echo off

setlocal
call :setESC

cls
echo %ESC%[101;93m STYLES %ESC%[0m
echo ^<ESC^>[0m %ESC%[0mReset%ESC%[0m
echo ^<ESC^>[1m %ESC%[1mBold%ESC%[0m
echo ^<ESC^>[4m %ESC%[4mUnderline%ESC%[0m
echo ^<ESC^>[7m %ESC%[7mInverse%ESC%[0m
echo.
echo %ESC%[101;93m NORMAL FOREGROUND COLORS %ESC%[0m
echo ^<ESC^>[30m %ESC%[30mBlack%ESC%[0m (black)
echo ^<ESC^>[31m %ESC%[31mRed%ESC%[0m
echo ^<ESC^>[32m %ESC%[32mGreen%ESC%[0m
echo ^<ESC^>[33m %ESC%[33mYellow%ESC%[0m
echo ^<ESC^>[34m %ESC%[34mBlue%ESC%[0m
echo ^<ESC^>[35m %ESC%[35mMagenta%ESC%[0m
echo ^<ESC^>[36m %ESC%[36mCyan%ESC%[0m
echo ^<ESC^>[37m %ESC%[37mWhite%ESC%[0m
echo.
echo %ESC%[101;93m NORMAL BACKGROUND COLORS %ESC%[0m
echo ^<ESC^>[40m %ESC%[40mBlack%ESC%[0m
echo ^<ESC^>[41m %ESC%[41mRed%ESC%[0m
echo ^<ESC^>[42m %ESC%[42mGreen%ESC%[0m
echo ^<ESC^>[43m %ESC%[43mYellow%ESC%[0m
echo ^<ESC^>[44m %ESC%[44mBlue%ESC%[0m
echo ^<ESC^>[45m %ESC%[45mMagenta%ESC%[0m
echo ^<ESC^>[46m %ESC%[46mCyan%ESC%[0m
echo ^<ESC^>[47m %ESC%[47mWhite%ESC%[0m (white)
echo.
echo %ESC%[101;93m STRONG FOREGROUND COLORS %ESC%[0m
echo ^<ESC^>[90m %ESC%[90mWhite%ESC%[0m
echo ^<ESC^>[91m %ESC%[91mRed%ESC%[0m
echo ^<ESC^>[92m %ESC%[92mGreen%ESC%[0m
echo ^<ESC^>[93m %ESC%[93mYellow%ESC%[0m
echo ^<ESC^>[94m %ESC%[94mBlue%ESC%[0m
echo ^<ESC^>[95m %ESC%[95mMagenta%ESC%[0m
echo ^<ESC^>[96m %ESC%[96mCyan%ESC%[0m
echo ^<ESC^>[97m %ESC%[97mWhite%ESC%[0m
echo.
echo %ESC%[101;93m STRONG BACKGROUND COLORS %ESC%[0m
echo ^<ESC^>[100m %ESC%[100mBlack%ESC%[0m
echo ^<ESC^>[101m %ESC%[101mRed%ESC%[0m
echo ^<ESC^>[102m %ESC%[102mGreen%ESC%[0m
echo ^<ESC^>[103m %ESC%[103mYellow%ESC%[0m
echo ^<ESC^>[104m %ESC%[104mBlue%ESC%[0m
echo ^<ESC^>[105m %ESC%[105mMagenta%ESC%[0m
echo ^<ESC^>[106m %ESC%[106mCyan%ESC%[0m
echo ^<ESC^>[107m %ESC%[107mWhite%ESC%[0m
echo.
echo %ESC%[101;93m COMBINATIONS %ESC%[0m
echo ^<ESC^>[31m                     %ESC%[31mred foreground color%ESC%[0m
echo ^<ESC^>[7m                      %ESC%[7minverse foreground ^<-^> background%ESC%[0m
echo ^<ESC^>[7;31m                   %ESC%[7;31minverse red foreground color%ESC%[0m
echo ^<ESC^>[7m and nested ^<ESC^>[31m %ESC%[7mbefore %ESC%[31mnested%ESC%[0m
echo ^<ESC^>[31m and nested ^<ESC^>[7m %ESC%[31mbefore %ESC%[7mnested%ESC%[0m

:setESC
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do (
  set ESC=%%b
  exit /B 0
)
exit /B 0