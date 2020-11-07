#<
  Requirements: 
    
    Windows ADK (https://go.microsoft.com/fwlink/?linkid=2026036)
    Windows PE add-on for the Windows ADK (https://go.microsoft.com/fwlink/?linkid=2022233)
      The above are listed and linked as found on: https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/download-winpe--windows-pe
    PowerShell 
   
  Per Microsoft Website (https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/winpe-add-packages--optional-components-reference), 
    WinPE Optional Components (OC) can be found in the following locations:
      64-bit C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE\_OCs\
      32-bit C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\x86\WinPE\_OCs\
    Please refer to the Microsoft site for descriptions regarding the function of each WinPE OC.
    
    The following line can be modified to add drivers from a set location as well.  Helpful for unrecognized hardware issues, such as with newer WiFi modules, etc.
    Add device drivers (.inf files):
      Dism /Add-Driver /Image:"C:\WinPE_amd64\mount" /Driver:"C:\SampleDriver\driver.inf"
    
    #Apps make life easier.  I would suggest the following considering the environment, though it does make your WinPE larger.
      Windows_Repair_Toolbox (https://windows-repair-toolbox.com)  <-- you will have to tell it to "Update All" if you want it to be really functional
      FileZilla Server (https://filezilla-project.org/download.php?type=server)
      7Zip (https://www.7-zip.org)
      
    Add an app:
      md "C:\WinPE_amd64\mount\windows\<MyApp>"
      Xcopy C:\<MyApp> "C:\WinPE_amd64\mount\windows\<MyApp>"
    Test app(s) after booting WinPE
      X:\Windows\<MyApp>
      
    Background Image:
      C:\WinPE_amd64\mount\windows\system32\winpe.jpg
#>

#Create working Environment (per https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/winpe-create-usb-bootable-drive)
Invoke-command -Scriptblock { & C:\WINDOWS\system32\cmd.exe /k "C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\DandISetEnv.bat"
  copype amd64 C:\WinPE_amd64}


#Get architecture and set path for OC
Get-ComputerInfo -Property OsArchitecture | if($_.OsArchitecture -match "64-bit"){
  $oc = "C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE\_OCs\"
  }
  else{
    $oc = "C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\x86\WinPE\_OCs\"
  }
}

#Mount the Windows PE boot image
Dism /Mount-Image /ImageFile:"C:\WinPE_amd64\media\sources\boot.wim" /index:1 /MountDir:"C:\WinPE_amd64\mount"

#Get optional components EXCEPT for fonts
[System.Collections.ArrayList]$cabs=@()
get-childitem -path $oc -Filter *.cab | foreach-object { if($_.Name -notmatch "Font*"){$cabs += $_}}

#Install the OC into the WinPE image
$cabs | foreach {Dism /Add-Package /Image:"C:\WinPE_amd64\mount" /PackagePath:$p\"$_.Name"}

#Unmount the Windows PE image and create media
Dism /Unmount-Image /MountDir:"C:\WinPE_amd64\mount" /commit
MakeWinPEMedia /ISO C:\WinPE_amd64 C:\WinPE_amd64\WinPE_amd64.iso
