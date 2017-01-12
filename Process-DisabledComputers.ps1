##Add overall logging


####Variable Declarations####

#Get todays date in format as TXT file names 
$TodaysDate = Get-Date -Format M.d.y
#30 Days Date 
$30DaysDate = [DateTime]::Today.AddDays(-30)
#Computers To Disable Today 
$ComputersToDisable = GC "OnDeck\OnDeck$TodaysDate.txt"
#Log File
$LogFile = "History\Process-$TodaysDate.txt"




#Disables ADComputer

Function Disable-ADComputer($Comptuer){
	Get-ADComputer -Identity $Computer | Set-ADComputer -Enabled $false -Server HVDC1-V
	If($?){
		$JobEnd = (Get-Date)
		Set-ADComputer -Identity $Computer -replace @{jobEndDate=$JobEnd}
		If($?){
			Return $True
		}
		else{
			Return $False
		}
	}
	else{
		Return $False
	}
	
}
#Deletes ADComputer

Function Delete-ADComputer($Computer){
	Get-ADComputer -Identity $Computer -Properties * | Where Enabled -Like False  | Remove-ADObject -Recursive -Confirm:$false -Verbose
	If($?){
		Return $True
	}
	else{
		Return $False
	}
}

#Gets all eligiable computers to be deleted
Function Get-DisabledComputers{
	$DisableComputers = Get-ADComputer -SearchBase "OU=Disabled Computers,OU=your,DC=domain,DC=net" " -Filter * -Properties jobEndDate 
	$ComputersBeingDeleted = New-Object System.Collections.Generic.List[System.Object]
	Foreach($Comptuer in $DisableComputers){
		$ComputerName = $Computer.Name
		$DisabledDate = $Comptuer.jobEndDate
		$DaysChangedAgo = $DisabledDate - (Get-Date)
		if($DaysChangedAgo -ge 30){
				$ComputersBeingDeleted.Add($ComputerName) 
		}
	}
	Return $ComputersBeingDeleted
	
	
}

$ComputersToDelete = Get-DisabledComputers


Foreach($Computer in $ComputersToDisable){
	$DisableStatus = Disable-ADComputer $Computer
	If($DisableStatus -eq $True){
		$OutLog = $Computer + " - Disabled"
		$OutLog | Out-File $LogFile
	}
}

Foreach($Computer in $ComputersToDelete){
	$DeleteStatus = Delete-ADComputer $Computer
	If($DeleteStatus -eq $True){
		$OutLog = $Computer + " - Deleted"
		$OutLog | Out-File $LogFile
	}
}