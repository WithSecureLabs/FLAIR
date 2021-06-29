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
for /f "tokens=1-4" %%a in ( Versions.md ) do if "%%b" NEQ "|" SET V_BLD=%%b
echo FLAIR_%V_BLD%

ECHO .OPTION EXPLICIT ; Generate errors  >"FLAIR.ddf"
ECHO .Set DiskLabel1="F-Secure FLAIR %V_BLD%" >>"FLAIR.ddf"
ECHO .Set CabinetNameTemplate="FLAIR_%V_BLD%.cab" >>"FLAIR.ddf"
ECHO .Set RptFileName="FLAIR_%V_BLD%.rpt" >>"FLAIR.ddf"
ECHO .Set InfFileName="FLAIR_%V_BLD%.inf" >>"FLAIR.ddf"
ECHO .Set CompressionType="LZX" >>"FLAIR.ddf"
ECHO .Set UniqueFiles="ON" >>"FLAIR.ddf"
ECHO .Set Cabinet="ON" >>"FLAIR.ddf"
ECHO .Set CabinetFileCountThreshold=0 >>"FLAIR.ddf"
ECHO .Set FolderFileCountThreshold=0 >>"FLAIR.ddf"
ECHO .Set FolderSizeThreshold=0 >>"FLAIR.ddf"
ECHO .Set MaxCabinetSize=0 >>"FLAIR.ddf"
ECHO .Set MaxDiskFileCount=0 >>"FLAIR.ddf"
ECHO .Set MaxDiskSize=CDROM >>"FLAIR.ddf"
ECHO .set DestinationDir="FLAIR" >>"FLAIR.ddf" 
ECHO .set DiskDirectoryTemplate="FLAIR" >>"FLAIR.ddf"
ECHO .new Folder >>"FLAIR.ddf"
ECHO ".\FLAIR.ddf" >>"FLAIR.ddf" 
REM =====================================================================================
ECHO ".\FLAIR.cmd" >>"FLAIR.ddf"
ECHO ".\ReadMe.md" >>"FLAIR.ddf"
REM =====================================================================================
REM Now add the Utils subfolders
REM =====================================================================================
ECHO Adding "Utils"
ECHO .set DestinationDir="FLAIR\Utils" >>"FLAIR.ddf" 
ECHO .new Folder >>"FLAIR.ddf"
for /f "delims=@" %%a in (' dir /a:-d /b ".\Utils\*.*"') do (
	ECHO ".\Utils\%%a" >>"FLAIR.ddf"
)
REM =====================================================================================
REM Make the CAB
REM =====================================================================================
makecab.exe /f "FLAIR.ddf"

copy /b "%windir%\system32\extrac32.exe"+"FLAIR_%V_BLD%.cab" "FLAIR_%V_BLD%.exe"
del /q /f "FLAIR_%V_BLD%.cab"
