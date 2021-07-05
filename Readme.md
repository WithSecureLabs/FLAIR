# F-Secure Lightweight Acquisition for Incident Response (FLAIR)

This document describes the purpose and basic operation of the FLAIR acquisition script.

## Purpose

During investigation of incidents on client estate, there are occasions where no EDR deployed which the IR team can make use of to collect artefacts across the estate. FLAIR was created to perform the semi-automated acquisition of a number of key artefacts from a target host.
FLAIR bridges the gap between the deep level of data available from a full forensic image of the host and the more targeted and interactive approach offered by EDR solutions.

## Design

FLAIR was created based on the following principles:

* As far as practical, only use tooling native to Microsoft Windows systems. i.e. Only programs 'built-in' to the OS
* No 3rd party programs. i.e. only Microsoft signed executables will reduce the impact on running the acquisition on sensitive client sites.
* Batch file operation for maximum compatibility and minimum dependencies.
* Windows XP is the minimum platform version to allow for collections to take place on systems which are out-of-support. (i.e. IoT/ICS envorinments)

### Notes

Yes we still use MD5 and yes we are aware of the possibiity of collision but 
a) it is computationally less expensive, so quicker to run
b) if there is a collision then that tells you something ;-)

The use of FLAIR on Multiple Locales remains the same (French, German etc), it should be noted that the output from many commands will return plain text content in the locale of the machine on which it is running such as "NETSTAT -ANO":

French
'''DOS
Connexions actives

  Proto  Adresse locale         Adresse distante       État
  TCP    0.0.0.0:25             0.0.0.0:0              LISTENING       5788

'''

German
'''DOS
Aktive Verbindungen

  Proto  Lokale Adresse         Remoteadresse          Status           PID
  TCP    0.0.0.0:25             0.0.0.0:0              ABH™REN         4552
'''

While the names and status fields reflect the locale of the target, the relative position remains the same. Even so when processing non-English targets it is something to consider.

## Operation

Execute the 'FLAIR.cmd' from either an external storage device (i.e. a USB drive) or a mapped network drive.

Processing may take over 30 minutes to process in many cases as a *LOT* of files are examined. 

## Analysis

The output of commands used is returned as plain text, mostly, so the use of Yara rules provdes a simple solution for checking common IoCs. 

When operating over a number of hosts then use of Elastic search, Logstash and Kibana (ELK Stack) can make the processing of multiple hosts more efficient once the overhead of creating import rules for each data type has been completed.
