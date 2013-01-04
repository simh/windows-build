# windows-build for SIMH

This repository contains the external dependencies needed to build full
asynchronous and networking support for the simh simulators on Windows.

It contains two separate dependent packages:
    The WinPcap developer Pack
    Posix threads for Windows

The Visual Studio Projects in the simh source tree presume that 
The directory containing this file should be located parallel to the
directory containing the simh source code.  The makefile which can
be used by MinGW compiler also presumes the same directory structure.

For Example, the directory structure should look like:

    .../simh/simhv38-2-rc1/VAX/vax_cpu.c
    .../simh/simhv38-2-rc1/scp.c
    .../simh/simhv38-2-rc1/Visual Studio Projects/simh.sln
    .../simh/simhv38-2-rc1/Visual Studio Projects/VAX.vcproj
    .../simh/simhv38-2-rc1/BIN/Nt/Win32-Release/vax.exe
    .../simh/windows-build/pthreads/pthread.h
    .../simh/windows-build/winpcap/WpdPack/Include/pcap.h

The ../simh/windows-build/winpcap directory contains Version 4.1.2 of 
the winpcap developer pack from:

       http://www.winpcap.org/devel.htm

The ../simh/windows-build/pthreads directory contains the source to the 
next release of the pthreads-win32 Posix Threads package for the windows 
platform.

