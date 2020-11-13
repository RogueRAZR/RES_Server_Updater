D:
cd D:\micros\res\pos\bin
# Shutdown RES Systems
Try {
	clcontrol.exe /SYSTEM IDLE
}
Catch {
	Write-Output "Failed to shutdown the RES DB: " $_
}
C:
cd C:\Windows\System32
# Check for and install windows updates. Catch Exception if WinUpdate Fails
Try {
	Get-WUInstall -MicrosoftUpdate -AcceptAll
	# Reboot only if required
	$Reboot = Get-WURebootStatus -Silent
	If ($Reboot -eq "True") {
		Write-Output "Restart Required, Rebooting in 15 seconds."
		Get-WURebootStatus -AutoReboot
	}
	else {
		Write-Output "Windows Update has finshed installing updates, no reboot is required."
		Start-Sleep -s 15
	}
}
Catch {
	Write-Output "Windows Update has Failed: " $_
}
exit
