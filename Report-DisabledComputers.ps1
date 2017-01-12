#Get todays date 
$Today = (Get-Date).ToString("MM-dd-yyyy")
#Get time
$Time = (Get-Date).ToString("hh:MM tt")
#Get todays date in format as TXT file names 
$TodaysDate = Get-Date -Format M.d.y
#30 Days Date 
$30DaysDate = [DateTime]::Today.AddDays(-30)


####################
##   Functions    ##
####################

#Send Weeely Disabled Computers Report

Function Send-DisabledComputersReport($OnDeck, $ChoppingBlock){
	$OnDeckCount = $OnDeck.Count
	$ChoppingBlockCount = $ChoppingBlock.Count
	#create html email
	$a = $a + "<style>"
	$a = $a + "BODY{background-color:#FFFFF;}"
	$a = $a + "H1{color:#B10503;}"
	$a = $a + "TABLE{border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse;}"
	$a = $a + "TH{border-width: 1px;padding: 0px;border-style: solid;border-color: black;}"
	$a = $a + "TD{border-width: 1px;padding: 0px;border-style: solid;border-color: black;}"
	$a = $a + "</style>"
	$a = $a + "</head>"
	$a = $a + "<body>"
	$Info = "<h1>Weekly Disabled Computers Report</h1><h3>Report-DisabledComputers was ran on $Today at $Time<h3><h4>The following $OnDeckCount computer accounts have been inactive for over 30 days and DO NOT ping. They will be disabled at 2PM, if you have a problem with any of these accounts please email System Admins. </h4>"
	#Create computers being disabled table
	$HTMlEmail = "$a <body>$Info<table><tr><th>Computers Being Disabled Today</th></tr>"
	Foreach($Computer in $OnDeck){
		$HTMLEmail += "<tr><td>$Computer</td></tr>" 
	}
	#Create computers being removed table
	$HTMLEmail += "</table><h4>The following $ChoppingBlockCount computer accounts have been inactive for over 60 days and DO NOT ping. They will be removed at 2PM, if you have a problem with any of these accounts please email System Admins.</h4><table><tr><th>Computers Being Removed Today</th>"
	Foreach($Computer in $ChoppingBlock){
		$HTMLEmail += "<tr><td>$Computer</td></tr>" 
	}
	$HTMLEmail += "</table>"
	#send email
	Send-MailMessage -To "youremail@hy-vee.com" `
 					 -From "DisabledComputers@yourdomain.com" `
					 -Subject "Weekly Disabled Computers Report" `
					 -SmtpServer smtp.hy-vee.com `
					 -Body $HTMLEmail `
					 -BodyAsHTML
}

Function Get-DisabledComputers{
	$DisableComputers = Get-ADComputer -SearchBase "OU=Disabled Computers,OU=your,DC=domain,DC=net" -Filter * -Properties jobEndDate -Server HVDC1-V
	$ComputersBeingDeleted = New-Object System.Collections.Generic.List[System.Object]
	Foreach($Comptuer in $DisableComputers){
		$ComputerName = $Computer.Name
		$DisabledDate = $Comptuer.jobEndDate
		$DaysChangedAgo = $DisabledDate - (Get-Date)
		if($DisabledDate -ge 30){
				$ComputersBeingDeleted.Add($ComputerName) #Verify This Works
		}
	}
	Return $ComputersBeingDeleted
	
	
}

$OnDeck = GC "OnDeck\OnDeck$TodaysDate.txt"
$ChoppingBlock = Get-DisabledComputers

Send-DisabledComputersReport $OnDeck $ChoppingBlock