cls
CL /VERSION
call :_Do_It VCE 
call :_Do_It VCE-static
call :_Do_It VC 
call :_Do_It VC-static
call :_Do_It VSE 
call :_Do_It VSE-static
call :_Do_It VSE 
call :_Do_It VSE-static
exit /B 0




:_Do_It
nmake realclean
nmake %1
cd tests
nmake clean
nmake %1
cd ..
:_EOF
exit /B 0
