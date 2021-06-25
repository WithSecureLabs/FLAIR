# F-Secure Lightweight Acquisition for Incident Response (FLAIR)

This document describes the purpose and basic operation of the FLAIR acquisition script.

## Purpose

During the investigation of incidents on a client estate, there are occasions where there is no EDR deployed which the IR team can collect artefacts across the client estate. FLAIR was created to perform the semi-automated acquisition of several key artefacts from a host.
FLAIR bridges the gap between the deep level of data available from a full forensic image of the host and the more targeted and interactive approach offered by EDR solutions.

## Design

FLAIR was created based on the following principles:

* As far as practical, only use tooling native to Microsoft Windows systems. i.e. Only programs 'built-in' to the OS
* No 3rd party programs. i.e. only Microsoft signed executables will reduce the impact on running the acquisition on sensitive client sites.
* Batch file operation for maximum compatibility and minimum dependencies.
* Windows XP is the minimum platform version to allow for collections to take place on systems which are out-of-support. (i.e. IoT/ICS envorinments)

## Operation

Execute the 'FLAIR.cmd' from either an external storage device (i.e. a USB drive) or a mapped network drive.

Processing can take over 20 minutes to process and as a lot of files are created/examined the duration has been observed as taking over an hour especially when AV is active.
