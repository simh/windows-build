@echo off
:: Build the specific static libraries which are flagged as 
:: incompatible when building simh simulators with the latest version 
:: of Microsoft Visual Studio.
::
::

set _VC_VER=
call :FindVCVersion _VC_VER
if not "%_VC_VER%" == "" goto GotVC
if exist "%ProgramFiles%\Microsoft Visual Studio\2022\Enterprise\VC\Auxiliary\Build\vcvars32.bat" call "%ProgramFiles%\Microsoft Visual Studio\2022\Enterprise\VC\Auxiliary\Build\vcvars32.bat"
call :FindVCVersion _VC_VER
if not "%_VC_VER%" == "" goto GotVC
if exist "%ProgramFiles%\Microsoft Visual Studio\2022\Professional\VC\Auxiliary\Build\vcvars32.bat" call "%ProgramFiles%\Microsoft Visual Studio\2022\Professional\VC\Auxiliary\Build\vcvars32.bat"
call :FindVCVersion _VC_VER
if not "%_VC_VER%" == "" goto GotVC
if exist "%ProgramFiles%\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars32.bat" call "%ProgramFiles%\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars32.bat"
call :FindVCVersion _VC_VER
if not "%_VC_VER%" == "" goto GotVC

echo ** ERROR ** ERROR ** ERROR ** ERROR ** ERROR ** ERROR **
echo ** ERROR ** ERROR ** ERROR ** ERROR ** ERROR ** ERROR **
echo **                                                    **
echo **   A Visual Studio 2022 version can not be found    **
echo **   installed in the default location on this system.**
echo **                                                    **
echo **   If you installed Visual Studio C++ 2022          **
echo **   in a non default location, then you must invoke  **
echo **   this procedure from a developer command prompt   **
echo **   for the version of Visual Studio you have        **
echo **   installed.                                       **
echo **                                                    **
echo ** ERROR ** ERROR ** ERROR ** ERROR ** ERROR ** ERROR **
echo ** ERROR ** ERROR ** ERROR ** ERROR ** ERROR ** ERROR **
exit /b 1

:GotVC
call :FindVCVersion _VC_VER _MSVC_VER _MSVC_TOOLSET_VER  _MSVC_TOOLSET_DIR
echo _VC_VER=%_VC_VER%
echo _MSVC_VER=%_MSVC_VER%
echo _MSVC_TOOLSET_VER=%_MSVC_TOOLSET_VER%
echo _MSVC_TOOLSET_DIR=%_MSVC_TOOLSET_DIR%
:_DoMSBuild
set _WINDOWS_BLD_DIR=%~dp0
if exist "%_WINDOWS_BLD_DIR%lib\lib-VC2022\%_MSVC_VER%" echo Support for Visual Studio %_VC_VER% v%_MSVC_VER% already exists & exit /b 1
mkdir "%_WINDOWS_BLD_DIR%lib\lib-VC2022\%_MSVC_VER%"
set _LIBPNG_SLN="%_WINDOWS_BLD_DIR%libpng-1.6.37\projects\vstudio 2022\vstudio.sln"
set _EDITLINE_SLN="%_WINDOWS_BLD_DIR%wineditline\vstudio\2022\wineditline.sln"
set _LIBSDL_SLN="%_WINDOWS_BLD_DIR%libSDL\SDL2-2.0.20\VisualC\SDL_Static_VS2022.sln"
MSBuild /nologo %_LIBPNG_SLN%   /Target:Rebuild "/Property:Configuration=Release Library" /Property:Platform=Win32
MSBuild /nologo %_LIBPNG_SLN%   /Target:Rebuild "/Property:Configuration=Debug Library"   /Property:Platform=Win32
MSBuild /nologo %_EDITLINE_SLN% /Target:Rebuild "/Property:Configuration=Release"         /Property:Platform=x86
MSBuild /nologo %_EDITLINE_SLN% /Target:Rebuild "/Property:Configuration=Debug"           /Property:Platform=x86
MSBuild /nologo %_LIBSDL_SLN%   /Target:Rebuild "/Property:Configuration=Release"         /Property:Platform=Win32
MSBuild /nologo %_LIBSDL_SLN%   /Target:Rebuild "/Property:Configuration=Debug"           /Property:Platform=Win32
set _LIBPNG_SLN=
set _EDITLINE_SLN=
set _LIBSDL_SLN=
mkdir "%_WINDOWS_BLD_DIR%lib\lib-VC2022\%_MSVC_VER%\Release" "%_WINDOWS_BLD_DIR%lib\lib-VC2022\%_MSVC_VER%\Debug"
copy "%_WINDOWS_BLD_DIR%lib\lib-VC2022\Release\*" "%_WINDOWS_BLD_DIR%lib\lib-VC2022\%_MSVC_VER%\Release\"
copy "%_WINDOWS_BLD_DIR%lib\lib-VC2022\Debug\*"   "%_WINDOWS_BLD_DIR%lib\lib-VC2022\%_MSVC_VER%\Debug\"
set _LIB_VERS_FILE="%_WINDOWS_BLD_DIR%lib\lib-VC2022\%_MSVC_VER%\VisualCVersionSupport.txt"
echo # This file lists the Microsoft Visual C++ compatible libraries>%_LIB_VERS_FILE%
echo # Leading Space, Visual C++ Version, Visual C++ Version Name>>%_LIB_VERS_FILE%
echo _VC_VER=2022 Visual Studio 2022>>%_LIB_VERS_FILE%
echo _MSVC_VER=%_MSVC_VER%>>%_LIB_VERS_FILE%
echo _MSVC_TOOLSET_VER=%_MSVC_TOOLSET_VER%>>%_LIB_VERS_FILE%
echo _MSVC_TOOLSET_DIR=%_MSVC_TOOLSET_DIR%>>%_LIB_VERS_FILE%
copy "%_WINDOWS_BLD_DIR%lib\lib-VC2022\Install-Library-Support.cmd" "%_WINDOWS_BLD_DIR%lib\lib-VC2022\%_MSVC_VER%\" >NUL
set _LIB_VERS_FILE=
set _VERSIONS_FILE="%_WINDOES_BLD_DIR%Windows-Build_Versions.txt"
set _NEW_VERSIONS_FILE="%_WINDOES_BLD_DIR%Windows-Build_Versions-New.txt"
set _OLD_BLD_VER=
for /f "usebackq tokens=2" %%a in (`findstr WINDOWS-BUILD %_VERSIONS_FILE%`) do set _OLD_BLD_VER=%%a
set _NEW_BLD_VER=%DATE:~-4%%DATE:~4,2%%DATE:~7,2%
if exist %_NEW_VERSIONS_FILE% del %_NEW_VERSIONS_FILE%
setlocal enabledelayedexpansion
for /f "usebackq tokens=*" %%a in (`type %_VERSIONS_FILE%`) do (
  set _line=%%a
  set _line=!_line:%_OLD_BLD_VER%=%_NEW_BLD_VER%!
  echo !_line!>>%_NEW_VERSIONS_FILE%
  )
set _line=
setlocal disabledelayedexpansion
if exist %_NEW_VERSIONS_FILE% move /y %_NEW_VERSIONS_FILE% %_VERSIONS_FILE% 1>NUL
git add -f "%_WINDOWS_BLD_DIR%lib\lib-VC2022\*\*" "%_WINDOWS_BLD_DIR%lib\lib-VC2022\*" %_VERSIONS_FILE%
git commit -m "Add library support for VS2022 v%_MSVC_VER%"
set _NEW_VERSIONS_FILE=
set _VERSIONS_FILE=
set _WINDOWS_BLD_DIR=
exit /b 1

:WhichInPath
if "%~$PATH:1" EQU "" exit /B 1
set %2=%~$PATH:1
exit /B 0

:FindVCVersion
call :WhichInPath cl.exe _VC_CL_
for /f "tokens=3-10 delims=\" %%a in ("%_VC_CL_%") do call :VCCheck _VC_VER_NUM_ "%%a" "%%b" "%%c" "%%d" "%%e" "%%f" "%%g" "%%h"
for /f "delims=." %%a in ("%_VC_VER_NUM_%") do set %1=%%a
set _VC_CL_STDERR_=%TEMP%\cl_stderr%_TARGET%.tmp
set VS_UNICODE_OUTPUT=
"%_VC_CL_%" /? 2>"%_VC_CL_STDERR_%" 1>NUL <NUL
for /f "usebackq tokens=4-9" %%a in (`findstr Version "%_VC_CL_STDERR_%"`) do call :MSVCCheck _MSVC_VER_NUM_ "%%a" "%%b" "%%c" "%%d" "%%e"
if "%4" NEQ "" set %4=%_MSVC_TOOLSET_%
if "%_MSVC_TOOLSET_%" NEQ "" set _MSVC_TOOLSET_=v%_MSVC_TOOLSET_:~0,2%%_MSVC_TOOLSET_:~3,1%
if "%3" NEQ "" set %3=%_MSVC_TOOLSET_%
set _MSVC_TOOLSET_=
if "%2" NEQ "" set %2=%_MSVC_VER_NUM_%
set _MSVC_VER_NUM_=
for /f "delims=." %%a in ("%_MSVC_VER_NUM_%") do set %2=%%a
del %_VC_CL_STDERR_%
set _VC_CL_STDERR_=
set _VC_CL=
exit /B 0

:: Scan the elements of the file path of cl.exe to determine the Visual
:: Studio Version and potentially the toolset version
:VCCheck
set _VC_TMP=%1
set _VC_TOOLSET=
:_VCCheck_Next
shift
set _VC_TMP_=%~1
if "%_VC_TMP_%" equ "" goto _VCCheck_Done
if "%_VC_TMP_:~0,24%" EQU "Microsoft Visual Studio " set %_VC_TMP%=%_VC_TMP_:Microsoft Visual Studio =%
call :IsNumeric _VC_NUM_ %_VC_TMP_%
if "%_VC_NUM_%" neq "" set %_VC_TMP%=%~1
if "%_VC_NUM_%" neq "" goto _VCCheck_Done
goto _VCCheck_Next
:_VCCheck_Done
set _VC_TMP=_MSVC_TOOLSET_
:_VCTSCheck_Next
shift
set _VC_TMP_=%~1
if "%_VC_TMP_%" equ "" goto _VCTSCheck_Done
call :IsNumeric _VC_NUM_ %_VC_TMP_%
if "%_VC_NUM_%" neq "" set %_VC_TMP%=%~1
if "%_VC_NUM_%" neq "" goto _VCTSCheck_Done
goto _VCTSCheck_Next
:_VCTSCheck_Done
set _VC_TMP_=
set _VC_TMP=
set _VC_NUM_=
exit /B 0

:MSVCCheck
set _MSVC_TMP=%1
:_MSVCCheck_Next
shift
set _MSVC_TMP_=%~1
if "%_MSVC_TMP_%" equ "" goto _VCCheck_Done
call :IsNumeric _MSVC_NUM_ %_MSVC_TMP_%
if "%_MSVC_NUM_%" neq "" set %_MSVC_TMP%=%~1
if "%_MSVC_NUM_%" neq "" goto _MSVCCheck_Done
goto _MSVCCheck_Next
:_MSVCCheck_Done
set _MSVC_TMP_=
set _MSVC_TMP=
set _MSVC_NUM_=
exit /B 0

:IsNumeric
set _Numeric_TMP_=%~1
set _Numeric_Test_=%2
set _Numeric_Test_=%_Numeric_Test_:~0,1%
set %_Numeric_TMP_%=
if "%_Numeric_Test_%"=="0" set %_Numeric_TMP_%=1
if "%_Numeric_Test_%"=="1" set %_Numeric_TMP_%=1
if "%_Numeric_Test_%"=="2" set %_Numeric_TMP_%=1
if "%_Numeric_Test_%"=="3" set %_Numeric_TMP_%=1
if "%_Numeric_Test_%"=="4" set %_Numeric_TMP_%=1
if "%_Numeric_Test_%"=="5" set %_Numeric_TMP_%=1
if "%_Numeric_Test_%"=="6" set %_Numeric_TMP_%=1
if "%_Numeric_Test_%"=="7" set %_Numeric_TMP_%=1
if "%_Numeric_Test_%"=="8" set %_Numeric_TMP_%=1
if "%_Numeric_Test_%"=="9" set %_Numeric_TMP_%=1
set _Numeric_TMP_=
set _Numeric_Test_=
exit /B 0
