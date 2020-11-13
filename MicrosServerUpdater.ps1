@echo off
D:
cd D:\micros\res\pos\bin
# Shutdown RES Systems
clcontrol.exe /SYSTEM IDLE
Write-Output "*********************************************************************
*                                                                   *
*                      SHUTTING DOWN RES3700...                     *
*                                                                   *
*********************************************************************"
C:
cd C:\Windows\System32
# Check for and install windows updates.
Get-WUInstall -MicrosoftUpdate -AcceptAll
Write-Output "*********************************************************************
*                                                                   *
*                         Updating Windows                          *
*                                                                   *
*********************************************************************"
# Reboot only if required
$Reboot = Get-WURebootStatus -Silent
IF ($Reboot -eq "True") {
	Get-WURebootStatus -AutoReboot
	Write-Output "*********************************************************************
*                                                                   *
*                           REBOOTING!!!                            *
*                                                                   *
*********************************************************************"
	}
	else
	{
	Write-Output "*********************************************************************
*                                                                   *
*                            COMPLETE!!!                            *
*                                                                   *
*********************************************************************"
	Start-Sleep -s 15
	}
exit