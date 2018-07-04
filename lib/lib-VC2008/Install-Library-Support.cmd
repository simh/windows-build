@echo off
: Tbis procedure installs tbe required object libraries to build using 
: Visual Studio 2008
:
set _Path=%~dp0
if exist "%_Path%..\Debug" rmdir /s /q "%_Path%..\Debug"
xcopy /S /I "%_Path%Debug\*"   "%_Path%..\Debug\"       > NUL 2>&1
if exist "%_Path%..\Release" rmdir /s /q "%_Path%..\Release"
xcopy /S /I "%_Path%Release\*" "%_Path%..\Release\"     > NUL 2>&1
if exist "%_Path%VisualCVersionSupport.txt" copy /y "%_Path%VisualCVersionSupport.txt" "%_Path%..\"        > NUL 2>&1