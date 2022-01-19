@echo off
: Tbis procedure installs tbe required object libraries to build using 
: Visual Studio 2019
: Note: Most object libraries are completely compatible from 
:       Visual Studio 2008, so those are referenced directly with 
:       specific exceptions handled here
:
set _Path=%~dp0
if exist "%_Path%..\Debug" rmdir /s /q "%_Path%..\Debug"
if exist "%_Path%..\lib-VC2008\Debug"   xcopy /S /I "%_Path%..\lib-VC2008\Debug\*"   "%_Path%..\Debug\"       > NUL 2>&1
xcopy /S /Y /I "%_Path%Debug\*"   "%_Path%..\Debug\"       > NUL 2>&1
if exist "%_Path%..\Release" rmdir /s /q "%_Path%..\Release"
if exist "%_Path%..\lib-VC2008\Release" xcopy /S /I "%_Path%..\lib-VC2008\Release\*" "%_Path%..\Release\"     > NUL 2>&1
xcopy /S /Y /I "%_Path%Release\*" "%_Path%..\Release\"     > NUL 2>&1
if exist "%_Path%VisualCVersionSupport.txt" copy /y "%_Path%VisualCVersionSupport.txt" "%_Path%..\"        > NUL 2>&1