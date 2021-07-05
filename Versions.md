# Versions

=====================================================================================

## Filename     FLAIR

## Author       Alan Melia (F-Secure)

## Description  Perform collection of transient data for later analysis

## Notes and Test Results

Examples of the OS version as recovered from the VER command and stored in %V_OS%

| V_OS | Short   | Full VER output                                  | Test Result                                     |
|------|---------|--------------------------------------------------|-------------------------------------------------|
| 40   | NT4     | Windows NT Version 4.0                           |                                                 |
| 50   | 2K      | Microsoft Windows 2000 [Version 5.00.2195]       |                                                 |
| 51   | XP      | Microsoft Windows XP [Version 5.1.2600]          |                                                 |
| 52   | 2003    | Microsoft Windows [Version 5.2.3790]             |                                                 |
| 60   | Vista   | Microsoft Windows [Version 6.0.6002]             |                                                 |
| 60   | 2008    | Microsoft Windows [Version 6.0.6002]             |                                                 |
| 61   | Win7    | Microsoft Windows [Version 6.1.7601]             |                                                 |
| 62   | Win8    | Microsoft Windows [Version 6.2.9200]             |                                                 |
| 63   | 2012 R2 | Microsoft Windows [Version 6.3.9600]             |                                                 |
| 100  | 2016    | Microsoft Windows [Version 10.0.14393]           |                                                 |
| 100  | Win10   | Microsoft Windows [Version 10.0.19043.1081] etc  |  OK                                             |
| 100  | 2019    | Microsoft Windows [Version 10.0.17763.1457] etc  |                                                 |
| 100  | 2004    | Microsoft Windows [Version 10.0.19041.685] etc   |                                                 |

## History

| Ver  | Date       | Name    | Reason                                                                                |
|------|------------|---------|---------------------------------------------------------------------------------------|
| 1.00 | 2021/03/15 | A.Melia | Initial version Derived from previous work and targeted for ProxyLogon investigations |
|      |            |         | Moved Windows Defender collection to System                                           |
|      |            |         | Added ProxyLogon .aspx capture                                                        |
| 1.01 | 2021/03/15 | A.Melia | Reduced the collection load for ProxyLogon Triage                                     |
|      |            |         | Limited the number of event logs collected by using EventLogs.txt                     |
|      |            |         | Collecting key AV logs                                                                |
|      |            |         | Collecting key mrt.log and msert.log                                                  |
| 1.02 | 2021/03/22 | A.Melia | Changed 'Hafnium' for 'ProxyLogon'                                                    |
|      |            |         | Added collection of details from "Temporary ASP.Net Files"                            |
|      |            |         | Changed LogParser command to ensure output strings are always "quoted"                |
|      |            |         | Added conditional checks for being run on Exchange Server                             |
| 1.03 | 2021/03/22 | A.Melia | Added locale independant capture of TimeZone information                              |
|      |            |         | Added supp0rt.aspx collection for ProxyLogon to Get_Files                             |
|      |            |         | Added -t to Autoruns to avoid local timezone issues                                   |
|      |            |         | Fixed an issue with parsing the ExchangePath                                          |
|      |            |         | Relocated file collection to allow for ExchangePath use                               |
|      |            |         | Added files identified from Microsoft's latest list to the collection                 |
| 1.04 | 2021/03/22 | A.Melia | Added check for "Download failed and temporary file" in Exchange logs                 |
|      |            |         | Collect data from all 'temp' folders inside ExchangePath                              |
|      | 2021/03/30 | A.Melia | Changed syntax for 'pnputil' so it works on 2012 and later                            |
|      |            |         | Made sure that Environment variables are properly quoted in CSV                       |
|      |            |         | Added a collection log entry for all event logs                                       |
|      |            |         | Changed the make process to create a Relay friendly named file                        |
|      |            |         | Fixed typo in event log collection                                                    |
|      |            |         | Changed absolute to relative references for config files to avoid folder issues       |
|      |            |         | Added additional info to aid debugging                                                |
|      |            |         | Simplified log to only show collected files                                           |
|      |            |         | Updated IoC_Files from TI                                                             |
| 1.05 | 2021/04/15 | A.Melia | Consolidated the collection using 'Get_Files' and 'IoC_Files' into a single file      |
| 1.06 | 2021/06/11 | A.Melia | Removed removed general "Proxylogon" aspx file grab                                   |
| 1.07 | 2021/06/22 | A.Melia | Revised OS version check logic                                                        |
|      |            |         | Added cab filename to closing window title                                            |
| 1.08 | 2021/06/24 | A.Melia | Added "System: Certificate data" based on conversation with Johann                    |
| 1.09 | 2021/07/04 | A.Melia | Tidied up use of NUL                                                                  |
|      |            |         | Removed the 'name' field from Logparser as it is already included in the path         |
|      |            |         | Added log entries for file metadata collection                                        |
|      |            |         | Added the use of a 'Release' folder                                                   |
|      |            |         | Commented out the creation of self-extracting EXE for now                             |
|      |            |         | Simplified the logic for checking for the presence of Exchange server                 |
|      |            |         | Added 'Windows' folder to Logparser collection without recursion                      |
