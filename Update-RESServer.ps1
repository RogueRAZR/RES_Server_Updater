<#PSScriptInfo
 
.VERSION 1.1
 
.GUID b7d7c2fc-3fc2-405f-bbd8-62775faf2ce0
 
.AUTHOR Kyle Mosley
 
.COMPANYNAME RazerSharp
 
.COPYRIGHT
 
.TAGS Windows Update, Micros RES 3700
 
.LICENSEURI
 
.PROJECTURI
 
.ICONURI
 
.EXTERNALMODULEDEPENDENCIES
 
.REQUIREDSCRIPTS
 
.EXTERNALSCRIPTDEPENDENCIES
 
.RELEASENOTES
Version 1.0: Original published version.
Version 1.1: Now it checks if the Pre-Reqs are installed. 
Reverted some PSWindowsUpdate to the original commands as they seem to work better.
Fixed bad true string missing the $. Changed cd to Set-Location Commands as /D apparently doesnt work in PS
#>

<#
.SYNOPSIS
Stops RES Database with clcontrol. Then performs a windows update check, install, and checks for reboot.
 
GNU General Public License v3.0
 
 Copyright (C) 2007 Free Software Foundation, Inc. <https://fsf.org/>
 Everyone is permitted to copy and distribute verbatim copies
 of this license document, but changing it is not allowed.
 
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
.DESCRIPTION
This script was designed to perform updates to Micros RES 3700 Database servers. This script will check and install windows updates. Then it will properly shutdown the RES Database before proceeding to restart the server.
Designed to be deployed in a regular maintenance period (Weekly or Monthly).
.PARAMETER NoReboot
Switch which prevents the machine from rebooting, useful if checking for and installing updates but cannot currently reboot. 
#>

param
(
	[Parameter(Mandatory=$False)] [switch] $NoReboot = $False
)

function Stop-RES
{
	param
	(
		[Parameter(Mandatory=$True)] [string] $State = ""
	)
	Set-Location -Path 'D:\micros\res\pos\bin'
	# Shutdown RES Systems
	clcontrol.exe $State
	Start-Sleep -s 300
}

function Get-Updates
{
	Set-Location -Path 'C:\Windows\System32'
	# Check for and install windows updates. Catch Exception if WinUpdate Fails
	Try 
	{
		Get-WindowsUpdate -ForceInstall -AcceptAll -IgnoreReboot
		If ($NoReboot -eq $False)
		{
			# Reboot only if required
			$Reboot = Get-WURebootStatus -Silent
			If ($Reboot -eq $True) 
			{
                		Write-Output "Restart Required, Shutting down RES, Rebooting in 5 Minutes."
				Stop-RES -State "/SYSTEM IDLE"
				Get-WindowsUpdate -AutoReboot
			}
			else 
			{
				Write-Output "Windows Update has finshed installing updates, no reboot is required."
				Start-Sleep -s 15
			}
		}
	}
	Catch 
	{
		Write-Output "Windows Update has Failed: " $_
	}
}
$Module = Get-Module -Name 'PSWindowsUpdate'
If ($Module.Version -ne '2.2.0.2')
{
    Write-Output "Pre-Requisite module is missing, please wait while we install"
    Install-Module -Name 'PSWindowsUpdate' -RequiredVersion '2.2.0.2' -Confirm
}
Get-Updates
Exit
