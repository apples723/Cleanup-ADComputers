
####Varaibles#####

#Testing all computers
$TestAllComputers = Get-ADComputer -Filter * -SearchBase "OU=TestComputers,OU=Disabled Computers,OU=your,DC=domain,DC=net" " -Properties name,lastlogondate,memberof
#Get All Computers
$AllComputers = Get-ADComputer -Filter * -SearchBase ""OU=your,DC=domain,DC=net" " -Properties name,lastlogondate,memberof
#Wireless Register Group
$WirelessRegisterGroup = ""CN=GrouptoExclude,OU=your,DC=domain,DC=net"
#Computers OnDeck to be disabled
$OnDeck = New-Object System.Collections.Generic.List[System.Object]
#90 Days Date 
$90DaysDate = [DateTime]::Today.AddDays(-90)
#OnDeck File 
$OnDeckFile = "C:\Scripts\CleanUp-ADComputers\OnDeck\OnDeck.cv"

####Functions#####

#Make sure computer is not a Training Workstation or a wireless register
Function Check-Computer($Computer){
	$ComputerName = $Computer.name
	$MemberOf = $Computer.MemberOf
	Write-Host $MemberOf
	#Make Sure Computer is not a training workstatoin
	If($Computer -NotLike "Train-WS*" -And $Computer -NotLike "TrainRX*"){
		If($MemberOf -NotContains $WirelessRegisterGroup){
			Return "Clean"
		}
		Else{
			Return "Dirty"
		}
	}
	Else{
		Return "Dirty"      
	}	
}
#Checks to see if computer returns a ping or not
Function Get-OnlineStatus($Computer){
			if(Test-Connection -CN $Computer -Count 2 -Quiet){
				return $True
			}
			else{
				return $False
			}

}
#Check to see if lastlogondate is older than 90 Days
Function Check-LastLogonDate($Computer){
	$ComputerName = $Computer.Name 
	$LastLogonDate = $Computer.LastLogonDate
	if($LastLogonDate -le $90DaysDate){
		return "OFF WITH ITS HEAD"
	}
	else{
		return "YOUR SAFE FOR NOW"
	}


}



#Filter for only the computers we want
foreach($Computer in $AllComputers){
	$CleanComputer = Check-Computer($Computer)
	$ComputerName = $Computer.name
	if($CleanComputer -eq "Clean"){
		$LifeStatus = Get-OnlineStatus($ComputerName)
		if($LifeStatus -eq $False){
			$LogonStatus = Check-LastLogonDate($Computer)
			if($LogonStatus -eq "OFF WITH ITS HEAD"){
				$OnDeck.Add($Computer.Name)
			}
			else{
				Continue
			}
		}
		else{
			Continue
		}
	}
	else{
		Continue
	}
}					


$OnDeck  | Export-Csv $OnDeckCSV				
						
# Foreach(New Array)
	# If LastLogonDate > 90
		# Output to OnDeck.csv
