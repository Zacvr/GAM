##Moves CB into Maigorld within 1:1 OU
#.\ThisOneChangeOU_LocationASSET.ps1  -Location 'MA ' -OU '/Chromebooks/1:1/'

##Moves CB into 1:1
#.\ThisOneChangeOU_LocationASSET.ps1  -Location ' ' -OU '/Chromebooks/1:1/'

##Moves CB into G5 within Cart OU
#.\ThisOneChangeOU_LocationASSET.ps1  -Location ' ' -OU '/Chromebooks/1:1/G5'

### Renable CBs
#.\ChangeOU_LocationASSETdis.ps1 -PathCSV 'testingenable.csv'  -Reenable

### Dsiable CBs
#.\ChangeOU_LocationASSETdis.ps1 -PathCSV 'testingenable.csv'  -Disable


## Required to run the script Example: ".\ThisOneChangeOU_LocationASSET.ps1  -Location " " -OU "/Chromebooks/1:1/endyearwarning"
[cmdletbinding()]
param(
	#$Location,
	#$OU,  
    #[switch]$Reenable,
    #[switch]$Disable,
	[SWITCH]$Test, # 
	[SWITCH]$Slow # Good for pausing between each operation
)

##Auto changes path to file location (incase it defaults to C:\ or H:\) This allows a single run (which will fail to change the directory)
CD $PSScriptRoot

##Stops the GAM.exe popup on each device / swap to continue if you need the errors
#$ErrorActionPreference = 'SilentlyContinue'
$ErrorActionPreference = 'Continue'



$ENV:GAM_DEVICE_MAX_RESULTS += 100
#$Chromebooks = get-content $PathCSV
$GamPath = "C:\Users\$env:username\Desktop\cleverscript\Update-AssetTag\lib\gam-64-4.65\gam.exe"

####
##This allows a GUI based File choice
Function FileName ($InitialDirectory)
{   #Open Dialog Box to choose CSV File
    Add-Type -AssemblyName System.Windows.Forms
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.Title = "Please Select File"
    $OpenFileDialog.InitialDirectory = $InitialDirectory
    $OpenFileDialog.filter = “All files (*.*)| *.*”
    If ($OpenFileDialog.ShowDialog() -eq "Cancel") 
    {
    [System.Windows.Forms.MessageBox]::Show("No File Selected. Please select a file !", "Error", 0, 
    [System.Windows.Forms.MessageBoxIcon]::Exclamation)
    }
    $Global:PathCSV = $OpenFileDialog.FileName
    Return $PathCSV #add this return
    $Chromebooks = get-content $PathCSV
} 


##This Enables or Disables Chromebooks
Function EnableorDisable{
ForEach($Device in $Chromebooks){
    Write-Host -F Yellow "Running Iteration #$Loop"
   $Device
    $ChromebookInfo = & $GamPath print cros query "asset_id: $Device" | ConvertFrom-Csv
	$deviceId = $ChromebookInfo.deviceId
    If (!$Test){
        if ($Disable -eq "True") {
            & $GamPath update cros $deviceId Location $Location ou $OU action disable
        } elseif ($Reenable -eq "True") {
            & $GamPath update cros $deviceId Location $Location ou $OU action reenable
        }
    }
}}


##This moves the Chromebooks
Function MovingOUs {
If($Location -eq ""){$Location = " "}
If ($OU -eq "") {Write-Host "Your OU variable is empty"}
If ($OU -eq " ") {Write-Host "Your OU variable is empty"}
ForEach($Device in $Chromebooks)
{   Write-Progress -Activity "Working on # $Count out of $TotalMachines"
    Write-Host -F Green "Working on # $Count out of $TotalMachines"
	$Device
    $ChromebookInfo  = & $GamPath print cros query "asset_id: $Device" | ConvertFrom-Csv
	$deviceId = $ChromebookInfo.deviceId
    If (!$Test)
            {& $GamPath update cros $deviceId Location $Location ou $OU}
    Else  {"[TEST] $GamPath update cros $deviceId Location $Location ou $OU"}
    If ($slow) {read-host "Enter to Proceed" }
    }}

### Moving Choices
Function MovingChoices {
Do { $MoveSingleOrCSV = Read-Host "Move a single chromebook or a CSV file? (S/C)" } While ($MoveSingleOrCSV -notmatch "S|C")
Do {$(Write-Host "What OU?"  -nonewline) + $(Write-Host -F Magenta "Example: '/Chromebooks/1:1/G5' (DON'T use '')" -nonewline) + $(Write-Host ": " -nonewline);$OU = Read-Host} Until ($OU -gt 5)


$Location = Read-Host "What Location?" "(This can be left blank)"
$MoveSingleOrCSV = $MoveSingleOrCSV.substring(0,1)
    If ($MoveSingleOrCSV -eq "C"){
       FileName
       $Chromebooks = get-content $PathCSV
       $Count = [int]"0"
       #Counts Total Devices In List
       $TotalMachines= $Chromebooks.Count
       $TotalMachines = [int]$TotalMachines
       Write-Host -F Yellow "Running First Iteration"
       MovingOUs
       Write-Host -F Yellow "Running Second Iteration"
       MovingOUs
       Write-Host -F Yellow "Running Third Iteration"
       MovingOUs}
                                
    ElseIf ($MoveSingleOrCSV -eq "S") {$Chromebooks = Read-Host "Please scan the barcode"
        Do { $Correct = Read-Host "Is $Chromebooks correct?" } While ($Correct -notmatch "Y|N")
        $Correct = $Correct.substring(0,1)
        $TotalMachines = [int]"1"
            If ($Correct -eq "Y"){}
            ElseIf($Correct -eq "N") {exit}
    


    Write-Host -F Yellow "Running First Iteration"
    MovingOUs
    Write-Host -F Yellow "Running Second Iteration"
    MovingOUs
    Write-Host -F Yellow "Running Third Iteration"
    MovingOUs}



    }



Function ChooseYourAdventure {
Do {$MoveorEnableDisable = Read-Host "Would you like to Move, Enable, or Disable Chromebooks? (M/E/D)" } While ($MoveorEnableDisable -notmatch "M|E|D")
$MoveorEnableDisable = $MoveorEnableDisable.substring(0,1)
    If ($MoveorEnableDisable -eq "M") {MovingChoices}
    ElseIf ($MoveorEnableDisable -eq "E") {
        $Reenable = "True"
        $Disable = "False"
        FileName
        $Chromebooks = get-content $PathCSV
                Write-Host -F Yellow "Running First Iteration"
                EnableOrDisable
                Write-Host -F Yellow "Running Second Iteration"
                EnableOrDisable
                Write-Host -F Yellow "Running Third Iteration"
                EnableOrDisable}
    ElseIf ($MoveorEnableDisable -eq "D") {
        $Disable = "True"
        $Reenable = "False"
        FileName
        $Chromebooks = get-content $PathCSV
                Write-Host -F Yellow "Running First Iteration"
                EnableOrDisable
                Write-Host -F Yellow "Running Second Iteration"
                EnableOrDisable
                Write-Host -F Yellow "Running Third Iteration"
                EnableOrDisable}

}


ChooseYourAdventure

####