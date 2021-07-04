@echo off
REM 
REM ## Filename    | MakeFlare
REM 
REM ## Author      | Alan Melia (F-Secure)
REM 
REM ## Description | Perform collection of transient data for later analysis
REM                  Creates a cab file of the necessary files
REM                  Creates a self-extracting EXE
REM ## Note        | AV on many systems can reject the resulting file 
REM                  as the signature will not match that of extrac32.exe
REM                     
IF NOT EXIST "Release" MD "Release"
for /f "tokens=1-4" %%a in ( Versions.md ) do if "%%b" NEQ "|" SET V_BLD=%%b
echo FLAIR_%V_BLD%

ECHO .OPTION EXPLICIT ; Generate errors  >"Release\FLAIR_%V_BLD%.ddf"
ECHO .Set DiskLabel1="F-Secure FLAIR %V_BLD%" >>"Release\FLAIR_%V_BLD%.ddf"
ECHO .Set CabinetNameTemplate="FLAIR_%V_BLD%.cab" >>"Release\FLAIR_%V_BLD%.ddf"
ECHO .Set RptFileName="Release\FLAIR_%V_BLD%.rpt" >>"Release\FLAIR_%V_BLD%.ddf"
ECHO .Set InfFileName="Release\FLAIR_%V_BLD%.inf" >>"Release\FLAIR_%V_BLD%.ddf"
ECHO .Set CompressionType="LZX" >>"Release\FLAIR_%V_BLD%.ddf"
ECHO .Set UniqueFiles="ON" >>"Release\FLAIR_%V_BLD%.ddf"
ECHO .Set Cabinet="ON" >>"Release\FLAIR_%V_BLD%.ddf"
ECHO .Set CabinetFileCountThreshold=0 >>"Release\FLAIR_%V_BLD%.ddf"
ECHO .Set FolderFileCountThreshold=0 >>"Release\FLAIR_%V_BLD%.ddf"
ECHO .Set FolderSizeThreshold=0 >>"Release\FLAIR_%V_BLD%.ddf"
ECHO .Set MaxCabinetSize=0 >>"Release\FLAIR_%V_BLD%.ddf"
ECHO .Set MaxDiskFileCount=0 >>"Release\FLAIR_%V_BLD%.ddf"
ECHO .Set MaxDiskSize=CDROM >>"Release\FLAIR_%V_BLD%.ddf"
ECHO .set DiskDirectoryTemplate="Release" >>"Release\FLAIR_%V_BLD%.ddf"
ECHO .set DestinationDir="" >>"Release\FLAIR_%V_BLD%.ddf" 
ECHO .new Folder >>"Release\FLAIR_%V_BLD%.ddf"
REM =====================================================================================
ECHO ".\FLAIR.cmd" >>"Release\FLAIR_%V_BLD%.ddf"
ECHO ".\ReadMe.md" >>"Release\FLAIR_%V_BLD%.ddf"
REM =====================================================================================
REM Now add the Utils subfolders
REM =====================================================================================
ECHO Adding "Utils"
ECHO .set DestinationDir="Utils" >>"Release\FLAIR_%V_BLD%.ddf" 
ECHO .new Folder >>"Release\FLAIR_%V_BLD%.ddf"
for /f "delims=@" %%a in (' dir /a:-d /b ".\Utils\*.*"') do (
	ECHO ".\Utils\%%a" >>"Release\FLAIR_%V_BLD%.ddf"
)
REM =====================================================================================
REM Make the CAB
REM =====================================================================================
makecab.exe /f "Release\FLAIR_%V_BLD%.ddf"

REM copy /b "%windir%\system32\extrac32.exe"+"FLAIR_%V_BLD%.cab" "FLAIR_%V_BLD%.exe"
REM del /q /f "FLAIR_%V_BLD%.cab"
