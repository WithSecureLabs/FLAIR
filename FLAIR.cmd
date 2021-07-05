@ECHO off
REM =====================================================================================
REM Work out the OS version
REM =====================================================================================
SET V_OS=NUL
SET x64=NUL
SET DT=NUL
for /f "tokens=1-7" %%a in ('ver.exe') do if "[Version" EQU "%%d" (for /f "delims=. tokens=1-5" %%i in ("%%e") do SET V_OS=%%i%%j) else for /f "delims=. tokens=1-5" %%i in ("%%d") do SET V_OS=%%i%%j
if %V_OS% EQU 500 SET V_OS=50 && REM needed because of the odd versioning of 2K

:CheckAdmin
REM =====================================================================================
REM Only works on > XP so skip it if it is NT4 and assume we are admin
REM =====================================================================================
color 4e
if %V_OS% GTR 51 (
    %systemroot%\system32\Whoami.exe /priv | find "SeTakeOwnershipPrivilege" >NUL && goto Main
) ELSE (
    goto Main
)
:NotAdmin
cls
color e4
ECHO.
ECHO Administrator Privilege Not Detected!
ECHO.
whoami.exe /user /nh
ECHO.
ECHO   Please restart under an account in the Administrators group
ECHO.
pause > NUL
GOTO :eof

:Main
REM =====================================================================================
REM Find out where we are running from 
REM =====================================================================================
set Store=%~d0
set Store=%Store%%~p0

REM =====================================================================================
REM Set-up Processor type
REM =====================================================================================
if %PROCESSOR_ARCHITECTURE% EQU AMD64 (
    set x64=64
) ELSE (
    set x64=
)
CLS
ECHO.
ECHO Please wait. Starting FLAIR for %COMPUTERNAME%
ECHO.
TIMEOUT.exe /T 10 /NOBREAK

REM =====================================================================================
REM Create the folder and remove any old copies first
REM =====================================================================================
SET outputfile=%COMPUTERNAME%
SET outputdir=%TEMP%\%outputfile%
if exist "%outputdir%" RD /s /q "%outputdir%"
md "%outputdir%"
cls
REM =====================================================================================
REM Enable hashing, get the date and set file output filename
REM =====================================================================================
echo SHA1 > "%outputdir%\hashes.SHA1"
if %V_OS% GTR 52 ( 
	echo MD5 > "%outputdir%\hashes.MD5"
	echo SHA256 > "%outputdir%\hashes.SHA256"
	EVENTCREATE.exe /T ERROR /ID 42 /L Application /D "F-Secure FLAIR" 1>NUL
    REM =====================================================================================
    REM Retrieve date and time in ISO8601 date format
    REM =====================================================================================
    for /f "tokens=1-30 delims== " %%a in ('wevtutil.exe qe Application /f:text /rd:true /q:"*[System[(Level=2) and (EventID=42)]]"') do if "%%a" equ "Date:" SET DT=%%b
)
call :logme FLAIR Running on %COMPUTERNAME% (%V_OS%) 
ver >> "%outputdir%\_COLLECTION_LOG.TXT" 2>&1
call :logme data in - "%outputdir%" on %DT%
call :logme Running from %Store%
:Volatile
REM =====================================================================================
call :logme     File: Metadata
REM =====================================================================================
ECHO                                                          This will take a while...
ECHO                                                          =========================
if %V_OS% GEQ 61 (
    call :logme     File: USN
    FSUTIL.exe usn readjournal %SystemDrive% csv > "%outputdir%\USN_System.csv"
)
call :logme     File: SystemRoot
"%Store%Utils\LogParser.exe" -stats:OFF -oDQuotes:on -i:fs -o:csv -recurse:0 -useLocalTime:OFF -preserveLastAccTime:ON "Select Path,HASHMD5_FILE(Path) AS Hash,Size,Attributes,CreationTime,LastAccessTime,LastWriteTime INTO '%outputdir%\LP_Systemroot.csv' from '%SystemRoot%\*.*'" >> "%outputdir%\_COLLECTION_LOG.TXT" 2>&1
if "%x64%" EQU "64" (
    call :logme     File: SystemRoot - SysWOW64
	"%Store%Utils\LogParser.exe" -stats:OFF -oDQuotes:on -i:fs -o:csv -recurse:-1 -useLocalTime:OFF -preserveLastAccTime:ON "Select Path,HASHMD5_FILE(Path) AS Hash,Size,Attributes,CreationTime,LastAccessTime,LastWriteTime INTO '%outputdir%\LP_SysWOW64.csv' from %SystemRoot%\SysWOW64\*.*" >> "%outputdir%\_COLLECTION_LOG.TXT" 2>&1
)
call :logme     File: SystemRoot - System32
"%Store%Utils\LogParser.exe" -stats:OFF -oDQuotes:on -i:fs -o:csv -recurse:-1 -useLocalTime:OFF -preserveLastAccTime:ON "Select Path,HASHMD5_FILE(Path) AS Hash,Size,Attributes,CreationTime,LastAccessTime,LastWriteTime INTO '%outputdir%\LP_System32.csv' from '%SystemRoot%\System32\*.*'" >> "%outputdir%\_COLLECTION_LOG.TXT" 2>&1
call :logme     File: Profiles
"%Store%Utils\LogParser.exe" -stats:OFF -oDQuotes:on -i:fs -o:csv -recurse:-1 -useLocalTime:OFF -preserveLastAccTime:ON "Select Path,HASHMD5_FILE(Path) AS Hash,Size,Attributes,CreationTime,LastAccessTime,LastWriteTime INTO '%outputdir%\LP_USERPROFILE.csv' from '%USERPROFILE%\..\*.*'" >> "%outputdir%\_COLLECTION_LOG.TXT" 2>&1
call :logme     File: System Temp
"%Store%Utils\LogParser.exe" -stats:OFF -oDQuotes:on -i:fs -o:csv -recurse:-1 -useLocalTime:OFF -preserveLastAccTime:ON "Select Path,HASHMD5_FILE(Path) AS Hash,Size,Attributes,CreationTime,LastAccessTime,LastWriteTime INTO '%outputdir%\LP_Win_temp.csv' from '%SystemRoot%\temp\*.*'" >> "%outputdir%\_COLLECTION_LOG.TXT" 2>&1
call :logme     File: ProgramData
"%Store%Utils\LogParser.exe" -stats:OFF -oDQuotes:on -i:fs -o:csv -recurse:-1 -useLocalTime:OFF -preserveLastAccTime:ON "Select Path,HASHMD5_FILE(Path) AS Hash,Size,Attributes,CreationTime,LastAccessTime,LastWriteTime INTO '%outputdir%\LP_ProgramData.csv' from '%ProgramData%\*.*'" >> "%outputdir%\_COLLECTION_LOG.TXT" 2>&1
call :logme     File: Metadata Complete

REM =====================================================================================
call :logme Network
REM =====================================================================================
if %V_OS% GEQ 100 (
    GETMAC /V /FO csv  >"%outputdir%\GETMAC.csv"
)
arp -a >"%outputdir%\arp.txt"
route print >"%outputdir%\Route_Print.txt"
if %V_OS% GEQ 51 (
    netstat -anO >"%outputdir%\Netstat_ANO.txt"    
    netstat -anob >"%outputdir%\Netstat_ANOB.txt"
) else (
    netstat -an >"%outputdir%\Netstat_AN.txt"    
)
ipconfig /All >"%outputdir%\Ipconfig_all.txt"
ipconfig /displaydns >"%outputdir%\Ipconfig_dns.txt"
netsh dump >"%outputdir%\netsh.txt"
net share > "%outputdir%\shares.txt"
net config workstation > "%outputdir%\net_config.txt"
net config Server > "%outputdir%\net_config.txt"
if %V_OS% GEQ 60 netsh advfirewall export "%outputdir%\Firewall.hbin"
call :logme Network Complete -%ERRORLEVEL%-
REM =====================================================================================
call :logme     System: System
REM =====================================================================================
if %V_OS% GEQ 60 (
	"%systemroot%\system32\msinfo32.exe" /report "%outputdir%\msinfo32.txt" >> "%outputdir%\_COLLECTION_LOG.TXT" 2>&1
) ELSE (
    "%Store%Utils\srvinfo.exe" -r > "%outputdir%\srvinfo.txt" >> "%outputdir%\_COLLECTION_LOG.TXT" 2>&1
)
REM =====================================================================================
call :logme     System: Sysinternals tools
REM =====================================================================================
if %V_OS% GTR 60 (
	"%Store%Utils\handle%x64%.exe" -a -nobanner -accepteula > "%outputdir%\handle.txt" 2>&1
)
"%Store%Utils\Listdlls%x64%.exe" -v -accepteula > "%outputdir%\Listdlls.txt" 2>&1
"%Store%Utils\pipelist%x64%.exe" -accepteula > "%outputdir%\pipelist.txt" 2>&1
REM =====================================================================================
call :logme     System: Openfiles and Systeminfo
REM =====================================================================================
openfiles.exe /query /fo csv >"%outputdir%\openfiles.csv"
systeminfo.exe /fo csv >"%outputdir%\system.csv"
call :logme     System: Defender collection
if exist "%ProgramFiles%\Windows Defender\MpCmdRun.exe" "%ProgramFiles%\Windows Defender\MpCmdRun.exe" -GetFiles
call :logme     System: System Complete -%ERRORLEVEL%-

REM =====================================================================================
call :logme     System: Certificate data
REM =====================================================================================
certutil.exe -URLCache -v>"%outputdir%\CERT_URLCache.txt"
call :logme     System: Certificate data -%ERRORLEVEL%-

call :logme     System: Event Logs
REM =====================================================================================
md "%outputdir%\Event_Logs"
if %V_OS% GEQ 60 (
    wevtutil.exe el > "%outputdir%\Event_Logs\List.txt"
    for /f "tokens=1* delims=^/" %%a in (.\Utils\EventLogs.txt) do (
        call :logme     System: Event Log - %%a/%%b -
        if "%%b" EQU "" (
            wevtutil.exe epl "%%a" "%outputdir%\Event_Logs\%%a.evtx" >> "%outputdir%\_COLLECTION_LOG.TXT" 2>&1
        ) ELSE (
            wevtutil.exe epl "%%a/%%b" "%outputdir%\Event_Logs\%%a-%%b.evtx" >> "%outputdir%\_COLLECTION_LOG.TXT" 2>&1
        )
    )
) ELSE (
    "%Store%Utils\LogParser.exe" -i:evt -o:xml -structure:2 -rootName:EVENTLOG -rowName:Event -compact:ON  "Select * INTO '%outputdir%\Event_Logs\System.xml' from 'System'"
    "%Store%Utils\LogParser.exe" -i:evt -o:xml -structure:2 -rootName:EVENTLOG -rowName:Event -compact:ON  "Select * INTO '%outputdir%\Event_Logs\Application.xml' from 'Application'"
    "%Store%Utils\LogParser.exe" -i:evt -o:xml -structure:2 -rootName:EVENTLOG -rowName:Event -compact:ON  "Select * INTO '%outputdir%\Event_Logs\Security.xml' from 'Security'"
    "%Store%Utils\LogParser.exe" -i:evt -o:xml -structure:2 -rootName:EVENTLOG -rowName:Event -compact:ON  "Select * INTO '%outputdir%\Event_Logs\PowerShell.xml' from 'Windows Powershell'"
)
call :logme     System: Event Logs Complete -%ERRORLEVEL%-

REM =====================================================================================
call :logme     System: RDP
REM =====================================================================================
if %V_OS% GEQ 60 (
    query.exe user > "%outputdir%\Q_RDP.csv"
    query.exe session >> "%outputdir%\Q_RDP.csv"
    query.exe session /VM >> "%outputdir%\Q_RDP.csv"
) ELSE (
    quser.exe > "%outputdir%\Q_RDP.csv"
    qwinsta.exe >> "%outputdir%\Q_RDP.csv"
)
call :logme     System: RDP Complete -%ERRORLEVEL%-

REM =====================================================================================
call :logme     System: Registry
REM =====================================================================================
for /f "delims=\ tokens=1-8" %%a in ('REG QUERY HKEY_CURRENT_USER\SOFTWARE\MICROSOFT\WINDOWS\CURRENTVERSION\EXPLORER\USERASSIST\ /s^|findstr "Count"') do (
    REG save HKEY_CURRENT_USER\SOFTWARE\MICROSOFT\WINDOWS\CURRENTVERSION\EXPLORER\USERASSIST\%%h\count "%outputdir%\UA_%%h.hbin" >> "%outputdir%\_COLLECTION_LOG.TXT" 2>&1
)
REG SAVE "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\AppCompatCache" "%outputdir%\REG_AppCompatCache.hbin" 2>NUL && call :logme     System: Registry AppCompatCache -%ERRORLEVEL%-
REG SAVE "HKEY_CURRENT_USER\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell" "%outputdir%\REG_Shell_MRU.hbin" 2>NUL && call :logme     System: Registry REG_Shell_MRU -%ERRORLEVEL%-
REG QUERY  "HKEY_CURRENT_USER\Software\Microsoft\Terminal Server Client\servers" > "%outputdir%\REG_TS_srv.csv" 2>NUL && call :logme     System: Registry REG_TS_srv -%ERRORLEVEL%-
REG SAVE "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\bam" "%outputdir%\REG_bam.hbin" 2>NUL && call :logme     System: Registry REG_bam -%ERRORLEVEL%-
call :logme     System: Registry Complete -%ERRORLEVEL%-

REM =====================================================================================
call :logme     System: Processes
REM =====================================================================================
if %V_OS% GEQ 60 (
    query.exe process * >"%outputdir%\Q_process.csv"
    "%Store%Utils\tlist%x64%.exe" -t > "%outputdir%\tlist.csv"
    "%Store%Utils\tlist%x64%.exe" -v >> "%outputdir%\tlist.csv"
) ELSE (
    qprocess.exe * >"%outputdir%\Q_process.csv"
)
if %V_OS% GTR 100 vulkaninfo.exe -j >"%outputdir%\vulkan.json"
SCHTASKS.exe /query >"%outputdir%\SCHTASKS.txt"
TASKLIST.exe /V /FO CSV >"%outputdir%\tasklist.csv"
call :logme     System: Processes Complete -%ERRORLEVEL%-

REM =====================================================================================
call :logme     System: Autoruns
REM =====================================================================================
"%Store%Utils\Autorunsc%x64%.exe" -t -a * -ct -h -s -nobanner -accepteula> "%outputdir%\Autoruns.csv"
call :logme     System: Autoruns Complete -%ERRORLEVEL%-

REM =====================================================================================
call :logme     System: Services
REM =====================================================================================
TASKLIST.exe /svc /FO CSV >"%outputdir%\tasklist_svc.csv"
sc.exe queryex >"%outputdir%\sc_svc.txt"
call :logme     System: Services Complete -%ERRORLEVEL%-

REM =====================================================================================
call :logme     System: Applications
REM =====================================================================================
if %V_OS% GEQ 61 TASKLIST.exe /apps /V /FO CSV >"%outputdir%\tasklist_apps.csv"
reg query HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall /s|findstr /c:"DisplayName" > "%outputdir%\Installed_pgm.txt"
call :logme     System: Applications Complete -%ERRORLEVEL%-

REM =====================================================================================
call :logme     System: Privileges, Users and Groups
REM =====================================================================================
if %V_OS% GEQ 60 WHOAMI /ALL /FO CSV >"%outputdir%\whoami.csv"
net.exe user >"%outputdir%\Logon.txt"
REM Accounting for locale on names
for /f "skip=4 delims=*" %%a in ('net localgroup') do Net Localgroup "%%a">>"%outputdir%\localgroups.txt" 2>NUL && call :logme     System: Localgroup -%%a-
gpresult.exe /z /scope computer>"%outputdir%\GP_Computer.txt"
gpresult.exe /z /scope user>"%outputdir%\GP_User.txt"
call :logme     System: Privileges, Users and Groups Complete -%ERRORLEVEL%-

REM =====================================================================================
call :logme     System: Drivers
REM =====================================================================================
DRIVERQUERY.exe /V /FO CSV > "%outputdir%\Drivers.csv"
DRIVERQUERY.exe /SI /FO CSV > "%outputdir%\Drivers_Signed.csv"
if %V_OS% GTR 52 pnputil /e > "%outputdir%\pnputil.txt"
call :logme     System: Drivers Complete -%ERRORLEVEL%-

REM =====================================================================================
call :logme     System: Environment
REM =====================================================================================
REG export HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Control\TimeZoneInformation "%outputdir%\Timezone.reg" /y 2>NUL
if %V_OS% GEQ 61 (
    w32tm.exe /tz >"%outputdir%\Timezone.txt"
    bcdedit.exe /enum >"%outputdir%\bdcedit.txt"
)
if exist "%systemroot%\system32\manage-bde.exe" manage-bde.exe -status >"%outputdir%\bitlocker.txt"
ECHO Name,Value >"%outputdir%\env.csv"
for /f "tokens=1,2* delims==" %%a in ('set') do ECHO %%a,"%%b" >>"%outputdir%\env.csv"
call :logme     System: Environment - Disks
if %V_OS% GEQ 51 diskpart /s "%Store%Utils\diskpart.txt" >"%outputdir%\diskpart.txt"
if exist "%systemroot%\system32\diskshadow.exe" diskshadow.exe /s "%Store%Utils\diskshadow.txt" /log "%outputdir%\ds_log.txt" >> "%outputdir%\_COLLECTION_LOG.TXT" 2>&1

call :logme     System: Environment Complete -%ERRORLEVEL%-

REM =====================================================================================
call :logme     IoC check
REM =====================================================================================
if %V_OS% GEQ 60 (
    call :logme     IoC check : Eventlog scan
    wevtutil.exe qe "Windows PowerShell" /f:RenderedXml /e:PS /q:"*[*[(EventID=600)]]" > "%outputdir%\Event_Logs\PS.xml"
    wevtutil.exe qe "Security" /f:RenderedXml /e:Type10 /q:"*[*[(EventID=4624)] and EventData[Data[@Name='LogonType']='10']]" > "%outputdir%\Event_Logs\Type10.xml"
    wevtutil.exe qe "Security" /f:RenderedXml /e:Type7 /q:"*[*[(EventID=4624)] and EventData[Data[@Name='LogonType']='7']]" > "%outputdir%\Event_Logs\Type7.xml"
    wevtutil.exe qe "Security" /f:RenderedXml /e:Type3 /q:"*[*[(EventID=4624)] and EventData[Data[@Name='LogonType']='3']]" > "%outputdir%\Event_Logs\Type3.xml"
    wevtutil.exe qe "System" /f:RenderedXml /e:System /q:"*[System[(EventID=7035 or EventID=3005 or EventID=1116 or EventID=3004 or EventID=104 or EventID=7045)]]" > "%outputdir%\Event_Logs\System.xml"
    wevtutil.exe qe "Application" /f:RenderedXml /e:Application /q:"*[Application[(EventID=1000 or EventID=1001 or EventID=1002 or EventID=257 or EventID=51 or EventID=400 or EventID=46)]]" > "%outputdir%\Event_Logs\Application.xml"
)
set ExchangePath=NUL
for /f "tokens=3*" %%b in ('reg query HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\ExchangeServer\v15\Setup /v MsiInstallPath') DO set ExchangePath=%%b %%c
IF EXIST "%ExchangePath%" (
    REM +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    call :logme     IoC ExchangeServer - "%ExchangePath%"
    REM +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    MD "%outputdir%\ProxyLogon"
    call :logme     IoC ExchangeServer - ProxyLogon - .aspx files
    "%Store%Utils\LogParser.exe" -stats:OFF -oDQuotes:on -i:fs -o:csv -recurse:-1 -useLocalTime:OFF -preserveLastAccTime:ON "Select Path,HASHMD5_FILE(Path) AS Hash,Size,Attributes,CreationTime,LastAccessTime,LastWriteTime INTO '%outputdir%\ProxyLogon\ProxyLogon_Exch_aspx.csv' from '%ExchangePath%*.aspx'" >>"%outputdir%\_COLLECTION_LOG.TXT" 2>&1
    "%Store%Utils\LogParser.exe" -stats:OFF -oDQuotes:on -i:fs -o:csv -recurse:-1 -useLocalTime:OFF -preserveLastAccTime:ON "Select Path,HASHMD5_FILE(Path) AS Hash,Size,Attributes,CreationTime,LastAccessTime,LastWriteTime INTO '%outputdir%\ProxyLogon\ProxyLogon_Inetpub_aspx.csv' from '%SystemDrive%\inetpub\wwwroot\*.*'" >>"%outputdir%\_COLLECTION_LOG.TXT" 2>&1
    call :logme     IoC ExchangeServer - ProxyLogon - Temporary ASP.Net Files
    for /f "delims=@" %%a in ('dir /s /b /a:d "%windir%\Temporary ASP.NET Files"') do (
        "%Store%Utils\LogParser.exe" -stats:OFF -oDQuotes:on -i:fs -o:csv -recurse:-1 -useLocalTime:OFF -preserveLastAccTime:ON "Select Path,HASHMD5_FILE(Path) AS Hash,Size,Attributes,CreationTime,LastAccessTime,LastWriteTime INTO STDOUT from '%%a\*.*'" >>"%outputdir%\ProxyLogon\Temporary_ASP.NET_Files.csv" 2>&1
    )
    for /f "delims=@" %%a in ('dir /s /b /a:d "%ExchangeInstallPath%\temp"') do (
        "%Store%Utils\LogParser.exe" -stats:OFF -oDQuotes:on -i:fs -o:csv -recurse:-1 -useLocalTime:OFF -preserveLastAccTime:ON "Select Path,HASHMD5_FILE(Path) AS Hash,Size,Attributes,CreationTime,LastAccessTime,LastWriteTime INTO STDOUT from '%%a\*.*'" >>"%outputdir%\ProxyLogon\Exchange_Temps.csv" 2>&1
    )
    call :logme     IoC ExchangeServer - ProxyLogon - find Key IoCs in log files
    for /f "delims=@" %%a in ('findstr /m /s /i /c:"ServerInfo~" "%ExchangePath%*.log" 2^>NUL') do (
        XCOPY.EXE /qyh "%%a" "%outputdir%\ProxyLogon" 1>NUL 2>NUL
    )
    for /f "delims=@" %%a in ('findstr /m /s /i /c:"Set-OabVirtualDirectory" "%ExchangePath%*.log" 2^>NUL') do (
        XCOPY.EXE /qyh "%%a" "%outputdir%\ProxyLogon" 1>NUL 2>NUL
    )
    for /f "delims=@" %%a in ('findstr /m /s /i /c:"function Page_Load(){eval(" "%ExchangePath%*.log" 2^>NUL') do (
        XCOPY.EXE /qyh "%%a" "%outputdir%\ProxyLogon" 1>NUL 2>NUL
    )
    for /f "delims=@" %%a in ('findstr /m /s /i /c:"Download failed and temporary file" "%ExchangePath%*.log" 2^>NUL') do (
        XCOPY.EXE /qyh "%%a" "%outputdir%\ProxyLogon" 1>NUL 2>NUL
    )
)
REM +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
call :logme     IoC Get_Files
REM +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
for /f "tokens=1,2*" %%a in (.\Utils\Get_Files.txt) do (
    CALL :getfile %%a %%b %%c
)
REM +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
call :logme     IoC check Complete -%ERRORLEVEL%-

:TheEnd
REM =====================================================================================
call :logme Collection finished for %COMPUTERNAME%
REM =====================================================================================
REM Create the ddf and add all files
REM =====================================================================================
call :logme Creating ddf
ECHO .OPTION EXPLICIT ; Generate errors  >"%COMPUTERNAME%.ddf"
ECHO .Set DiskLabel1="F-Secure FLAIR" >>"%COMPUTERNAME%.ddf"
ECHO .Set CabinetNameTemplate="%outputfile%.cab" >>"%COMPUTERNAME%.ddf"
ECHO .Set RptFileName="%outputfile%.rpt" >>"%COMPUTERNAME%.ddf"
ECHO .Set InfFileName="%outputfile%.inf" >>"%COMPUTERNAME%.ddf"
ECHO .Set CompressionType="LZX" >>"%COMPUTERNAME%.ddf"
ECHO .Set UniqueFiles="ON" >>"%COMPUTERNAME%.ddf"
ECHO .Set Cabinet="ON" >>"%COMPUTERNAME%.ddf"
ECHO .Set CabinetFileCountThreshold=0 >>"%COMPUTERNAME%.ddf"
ECHO .Set FolderFileCountThreshold=0 >>"%COMPUTERNAME%.ddf"
ECHO .Set FolderSizeThreshold=0 >>"%COMPUTERNAME%.ddf"
ECHO .Set MaxCabinetSize=0 >>"%COMPUTERNAME%.ddf"
ECHO .Set MaxDiskFileCount=0 >>"%COMPUTERNAME%.ddf"
ECHO .Set MaxDiskSize=CDROM >>"%COMPUTERNAME%.ddf"
ECHO .set DestinationDir="%COMPUTERNAME%" >>"%COMPUTERNAME%.ddf" 
ECHO .set DiskDirectoryTemplate="FLAIR" >>"%COMPUTERNAME%.ddf"
ECHO .new Folder >>"%COMPUTERNAME%.ddf"
ECHO "%outputdir%\%COMPUTERNAME%.ddf" >>"%COMPUTERNAME%.ddf" 
REM =====================================================================================
for /f "delims=@" %%a in (' dir /a:-d /b "%outputdir%\*.*"') do (
	ECHO "%outputdir%\%%a" >>"%COMPUTERNAME%.ddf"
	call :hashit "%outputdir%\%%a"
)
REM =====================================================================================
REM Now add all the subfolders we have collected
REM =====================================================================================
for /f "delims=@" %%z in ('dir /a:d /b "%outputdir%"') do (
    ECHO Adding "%%z"
    ECHO .set DestinationDir="%COMPUTERNAME%\%%z" >>"%COMPUTERNAME%.ddf" 
    ECHO .new Folder >>"%COMPUTERNAME%.ddf"
	for /f "delims=@" %%a in (' dir /a:-d /b "%outputdir%\%%z\*.*"') do (
		ECHO "%outputdir%\%%z\%%a" >>"%COMPUTERNAME%.ddf"
		call :hashit "%outputdir%\%%z\%%a"
	)
)
copy "%COMPUTERNAME%.ddf" "%outputdir%"
REM =====================================================================================
REM Make the CAB
REM =====================================================================================
call :logme Starting Compression
makecab.exe /f "%COMPUTERNAME%.ddf"
call :logme Compression Complete -%ERRORLEVEL%-
REM =====================================================================================
REM Cleanup and make it obvious we are done
REM =====================================================================================
color e4
TITLE FLAIR ++ Please send "%outputfile%.cab" to F-Secure
ECHO.
ECHO.
dir /b /s *.cab
ECHO =====================================================================================
ECHO Please send the above file to F-Secure.
ECHO =====================================================================================
Echo    This file contains contents of folder "%outputdir%"
ECHO.
GOTO :eof

:getfile
if exist "%2" (
    if not exist "%outputdir%\%1\" MD "%outputdir%\%1\"
    XCOPY.EXE /qyh "%2" "%outputdir%\%1\" >> "%outputdir%\_COLLECTION_LOG.TXT" 2>&1
) ELSE (
    EXIT /B
)
:logme
TITLE FLAIR ++ Please ignore any errors from this window - Processing %*
ECHO -- %time% : %*
ECHO -- %time% : %* >> "%outputdir%\_COLLECTION_LOG.TXT" 2>&1
EXIT /B

:hashit
SETLOCAL
SET h_fn=%*
set h_ft=SHA1
:hashit_loop
if %V_OS% GTR 52 (
	SET h_alg=%h_ft%
) ELSE (
	SET h_alg=
)
for /f "skip=1 tokens=1-20" %%a in ('certutil -hashfile %h_fn% %h_alg%') do (
	IF "%%a" EQU "CertUtil:" (
		SET h_ft= 
	) ELSE (
		echo %%a%%b%%c%%d%%e%%f%%g%%hi%%j%%k%%l%%m%%n%%o%%p%%q%%r%%s%%t %h_fn% >> "%outputdir%\hashes.%h_ft%
	)
)
if "%h_alg%" EQU "" GOTO :SHA256
GOTO %h_alg%
:MD5
if exist "%outputdir%\hashes.SHA256" SET h_ft=SHA256&&GOTO :hashit_loop
ELSE GOTO :SHA256
:SHA1
if exist "%outputdir%\hashes.md5" SET h_ft=MD5&&GOTO :hashit_loop
:SHA256
EXIT /b
