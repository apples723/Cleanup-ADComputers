# Cleanup-ADComputers
Automated PowerShell Script to keep active directory clean. Removes inactive computers after 90 days of not talking to domain, and that do not resolve to a ping. 

# Notes

  1.  Scripts use a custom attribute called "JobEndDate" to keep track of how long the computer has been disabled, modify your schema and add that attribute or change the name to an unused attribute on the computer objects like description. 
  2. Computers are not deleted right away they are disabled and then after thirty days are deleted. This prevents machines that are offsite or only being used every now and then from being deleted. It's much easier for someone to re-enable a computer account then to rejoin it to the domain. So, you will need a disabled computers OU to put computer objects in.
  3. There are three scripts, one to get disabled computers and computers to be disabled, one to report on those computers, and one to remove or disable those computers. I set it up this way so that you can be notified before the computers are disabled or removed in case the script caught something it shouldn't have. I set it up using task schedule to run the first two in the morning, and then the last one in the afternoon. 

I will add more detail later in this file, you can read my comments in the scripts as well to get a better understanding of how they work.



