OutFile "C:\tmp\VMware Shared\accp2.8.2.exe"
Name "�AccountPak� 2.8.2"
XPStyle on

!define APPNAME "AccountPak 2"
!define MULTIUSER_EXECUTIONLEVEL Highest
!define MULTIUSER_INSTALLMODE_COMMANDLINE
!define MULTIUSER_INSTALLMODE_INSTDIR "${APPNAME}"
!define MULTIUSER_MUI

!include x64.nsh
!include InvokeShellVerb.nsh
!include MultiUser.nsh
!include MUI2.nsh
!include StdUtils.nsh         ; ExecShellWait/03.04.2014  PinToTaskBar/20.04.2014

RequestExecutionLevel Admin	; 09.12.2013 this for Windows 8 

; The default installation directory
InstallDir "$LOCALAPPDATA\APPNAME"
ShowInstDetails show

; Registry key to check for directory (so if you install again, it will overwrite the old one automatically)
InstallDirRegKey HKCU "Software\AccountPak" "InstallDir"

; MUI ---------------------------
;Interface Configuration
!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_BITMAP_NOSTRETCH
!define MUI_HEADERIMAGE_BITMAP "C:\ABCDSOFT\AccountPak\NSIS\RES\caption-logo-accp.bmp"
!define MUI_WELCOMEFINISHPAGE_BITMAP "C:\ABCDSOFT\AccountPak\NSIS\RES\logo-accp-sided.bmp"
!define MUI_ABORTWARNING
; MUI Settings / Icons:
!define MUI_ICON "C:\ABCDSOFT\AccountPak\RES\AccountPak.ico"
!define MUI_UNICON "${NSISDIR}\Contrib\Graphics\Icons\orange-uninstall-nsis.ico"

!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "C:\ABCDSOFT\AccountPak\NSIS\������������ ����������\�������� AccountPak.txt"

!define MULTIUSER_INSTALLMODEPAGE "������!!!!!!"
!define MULTIUSER_INSTALLMODEPAGE_TEXT_TOP "�������� ��� ����������� ��������� AccountPak:"
!define MULTIUSER_INSTALLMODEPAGE_TEXT_ALLUSERS "���������� ��� ���� ������� �������"
!define MULTIUSER_INSTALLMODEPAGE_TEXT_CURRENTUSER "������ ��� ������� ������� ������"
!insertmacro MULTIUSER_PAGE_INSTALLMODE

!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

;!define MUI_FINISHPAGE_RUN "$INSTDIR\AccpLicActivate.exe"
;!define MUI_FINISHPAGE_RUN_NOTCHECKED
;!define MUI_FINISHPAGE_RUN_TEXT "&��������� ��������� �AccountPak�"
;!define MUI_FINISHPAGE_SHOWREADME $INSTDIR\Release.txt
;!define MUI_FINISHPAGE_SHOWREADME_NOTCHECKED
;!define MUI_FINISHPAGE_SHOWREADME_TEXT "�������� ���� ���������� Release.txt"

;!define MUI_FINISHPAGE_LINK "My website"
;!define MUI_FINISHPAGE_LINK_LOCATION "http://example.com"

!define MUI_BUTTONTEXT_FINISH "&������"
!define MUI_TEXT_FINISH_INFO_TITLE "���������� ������ ������� ��������� $(^Name)"
!define MUI_TEXT_FINISH_INFO_TEXT "��������� $(^Name) ���������.$\r$\n$\r$\n������� ������ ������� ��� ������ �� ��������� ���������."
!define MUI_FINISHPAGE_NOREBOOTSUPPORT
!define MUI_FINISHPAGE_NOAUTOCLOSE
!insertmacro MUI_PAGE_FINISH
!insertmacro MUI_LANGUAGE "Russian"

!addplugindir "plugins"

#Declare variables
var MajorVersion
var MinorVersion
var BuildNumber
var PlatformID
var CSDVersion
var ProductType 

var GrdVer
var GrdBuild

Function .onInit
  !insertmacro MULTIUSER_INIT

  #call plugin dll function 
  Version::GetWindowsVersion

  Pop $MajorVersion
  Pop $MinorVersion
  Pop $BuildNumber
  Pop $PlatformID
  Pop $CSDVersion
  Pop $ProductType
FunctionEnd

Function un.onInit
  !insertmacro MULTIUSER_UNINIT
FunctionEnd

; ---------- Guardant Drivers: -----------
Section "Install-Guardant-Drivers"

${If} ${RunningX64}
  DetailPrint "����������� AccountPak ����������� �� ���������� x64"
${Else}
  DetailPrint "����������� AccountPak ����������� �� ���������� x86"
${EndIf}

DetailPrint "������ Windows:"
${if} $ProductType == "1"
  DetailPrint "���������: $PlatformID, ������: $MajorVersion.$MinorVersion, build $BuildNumber $CSDVersion - Workstation"
${ElseIf} $ProductType == "2"
  DetailPrint "���������: $PlatformID, ������: $MajorVersion.$MinorVersion, build $BuildNumber $CSDVersion - DomainController"
${ElseIf} $ProductType == "3"
  DetailPrint "���������: $PlatformID, ������: $MajorVersion.$MinorVersion, build $BuildNumber $CSDVersion - Server"
${Else}
  DetailPrint "���������: $PlatformID, ������: $MajorVersion.$MinorVersion, build $BuildNumber $CSDVersion - ����������� �������!"
${EndIf}

SetRegView 64
ClearErrors
ReadRegDWORD $GrdVer HKLM "SOFTWARE\Aktiv\Guardant\Drivers" "Version"
ReadRegDWORD $GrdBuild HKLM "SOFTWARE\Aktiv\Guardant\Drivers" "Build"
DetailPrint "�������� Guardant, ������: $GrdVer, ������: $GrdBuild"
IfErrors GUARDDRV_NOT_INSTALLED 0
DetailPrint "�������� Guardant ��� �����������, ��������� ������������ ������"

IntCmp $GrdVer 1586 GUARDDRV_ACTUAL 0 GUARDDRV_ACTUAL 	; 1585D == 6.31 , ������ ��������� �� �������� ������,
DetailPrint "������ ��������� Guardant �������� - ��������� ���������"
Goto GUARDDRV_OLD

GUARDDRV_ACTUAL:
DetailPrint "�������� Guardant ���������� ������ - �� ���������� ���������"
Goto GUARDDRV_OK

GUARDDRV_NOT_INSTALLED:
DetailPrint "�������� Guardant �� ����������� - ��������� ���������"
GUARDDRV_OLD:
SetOutPath $TEMP ; ������������� � ������������� �� ��������� ����������
${If} ${RunningX64}
  File "/oname=$TEMP\GrdDriversRU.msi" "C:\ABCDSOFT\AccountPak\NSIS\Shared\guardant-drivers-x64\GrdDriversRU-x64.msi"
${Else}
  File "/oname=$TEMP\GrdDriversRU.msi" "C:\ABCDSOFT\AccountPak\NSIS\Shared\guardant-drivers-x32\GrdDriversRU-x86.msi"
${EndIf}
DetailPrint "��������� ��������� Guardant"
;SetDetailsPrint none
	;DetailPrint 'ExecShellWait: "$TEMP\GrdDriversRU.msi" ; /quiet'
	; Sleep 1000
	${StdUtils.ExecShellWaitEx} $0 $1 "$TEMP\GrdDriversRU.msi" "open" "" ;try to launch the process
	;
	;DetailPrint "���������: $0: $1" ;returns "ok", "no_wait" or "error".
	StrCmp $0 "error" ExecFailed ;check if process failed to create
	StrCmp $0 "no_wait" WaitNotPossible ;check if process can be waited for - always check this!
	StrCmp $0 "ok" WaitForProc ;make sure process was created successfully
	Abort
WaitForProc:
	; ����� �� 25.03.2015
	DetailPrint "��������� ��������� GUARDANT:"
	DetailPrint "�������� ��������� ����������� � ��������� ���������� ���������"

; 03.04.2014 ����������� �.�. ������ ���������� ${StdUtils.ExecShellWaitEx}
; 02.03.2013 MK:
loop:
FindWindow $0 "MsiDialogCloseClass" ""
IsWindow $0 0 loop
System::Call 'user32::SetForegroundWindow(i r0)'

	${StdUtils.WaitForProcEx} $2 $1
	DetailPrint "��������� ���������, ���������� ����������� (exit code: $2)"
	Goto WaitDone
ExecFailed:
	DetailPrint "Failed to create process (error code: $1)"
	Goto WaitDone
WaitNotPossible:
	DetailPrint "Can't wait for process."
	Goto WaitDone
WaitDone:
Delete "$TEMP\GrdDriversRU.msi" 
;SetDetailsPrint both

GUARDDRV_OK:
SectionEnd

; The stuff to install
Section "AccountPak (required)"
SectionIn RO
  
SetShellVarContext current

; Set output path to the installation directory.
SetOutPath $INSTDIR
;AccessControl::GrantOnFile "$INSTDIR" "(BU)" "FullAccess"
;AccessControl::EnableFileInheritance "$INSTDIR" 
  
; ================== �����: ======================
CreateDirectory $INSTDIR\LOG
AccessControl::GrantOnFile "$INSTDIR\LOG" "(BU)" "FullAccess"
AccessControl::EnableFileInheritance "$INSTDIR\LOG" 
; ������� � ������:
CreateDirectory $INSTDIR\reports
AccessControl::GrantOnFile "$INSTDIR\reports" "(BU)" "FullAccess"
AccessControl::EnableFileInheritance "$INSTDIR\reports" 
CreateDirectory $INSTDIR\patterns
AccessControl::GrantOnFile "$INSTDIR\patterns" "(BU)" "FullAccess"
AccessControl::EnableFileInheritance "$INSTDIR\patterns" 
SetOutPath $INSTDIR\patterns
File "C:\ABCDSOFT\AccountPak\patterns\zakaz_plenka_pattern.htm"
File "C:\ABCDSOFT\AccountPak\patterns\zakaz_pakets_pattern.htm"
File "C:\ABCDSOFT\AccountPak\patterns\pattern_prods_remains.htm"
File "C:\ABCDSOFT\AccountPak\patterns\pattern_journ_zakazes.htm"
File "C:\ABCDSOFT\AccountPak\patterns\pattern_journ_prods_wroffs.htm"
File "C:\ABCDSOFT\AccountPak\patterns\pattern_feeds_remains.htm"
;File "C:\ABCDSOFT\AccountPak\patterns\pattern_general_report.htm"
File "C:\ABCDSOFT\AccountPak\patterns\pattern_journ_feeds_purch.htm"
File "C:\ABCDSOFT\AccountPak\patterns\pattern_journ_feeds_wroffs.htm"
File "C:\ABCDSOFT\AccountPak\patterns\pattern_journ_prods.htm"
File "C:\ABCDSOFT\AccountPak\patterns\zayavka_plenka_pattern.htm"
File "C:\ABCDSOFT\AccountPak\patterns\zayavka_pakets_pattern.htm"

SetOverwrite off	; 17.11.2013
${If} ${RunningX64}
  IfFileExists $WINDIR\SysWOW64 0 NO_WOW64_OCX_INSTALL
  SetOutPath $WINDIR\SysWOW64
  DetailPrint "��������� ocx � ���������� x64 - � ������� '$OUTDIR'"
Goto CONTINUE_OCX_INSTALL

NO_WOW64_OCX_INSTALL:
SetOutPath $SYSDIR
CONTINUE_OCX_INSTALL:

${Else}
SetOutPath $SYSDIR
${EndIf}

  File "C:\ABCDSOFT\AccountPak\NSIS\Shared\Msdatgrd.ocx" 
  ReadRegStr $R0 HKCR "TypeLib\{CDE57A40-8B86-11D0-B3C6-00A0C90AEA82}\1.0\0\win32" ""
  IfErrors 0 MsDatGrdRegistered
    DetailPrint "������������ COM-���������� ����������: Msdatgrd.ocx "
    RegDLL Msdatgrd.ocx
  MsDatGrdRegistered:

  File "C:\ABCDSOFT\AccountPak\NSIS\Shared\msstdfmt.dll" 
  ReadRegStr $R0 HKCR "TypeLib\{6B263850-900B-11D0-9484-00A0C91110ED}\1.0\0\win32" ""
  IfErrors 0 MsStdFmtRegistered
    DetailPrint "������������ COM-���������� ����������: msstdfmt.dll"
    RegDLL msstdfmt.dll
  MsStdFmtRegistered:


SetOverwrite	ifnewer ; 09.01.2014
SetOutPath $INSTDIR
File "C:\ABCDSOFT\AccountPak\ReleaseGuardant\AccountPak.exe"
IfFileExists "$INSTDIR\AccountPak.mdb" ACCOUNTPAK_MDB_EXISTS 0
DetailPrint "�������� ������� ���� ������: AccountPak.mdb"
File "C:\ABCDSOFT\AccountPak\NSIS\Shared\AccountPak.mdb" ; ���� ������ ���� �� �������� Shared
Goto ACCOUNTPAK_MDB_FURTHER
ACCOUNTPAK_MDB_EXISTS:
DetailPrint "������� ���� ������ AccountPak.mdb ��� ������������ - �� ��������������"
ACCOUNTPAK_MDB_FURTHER:
; ������������� ����� ��� ���� ������������� �� ����:
AccessControl::GrantOnFile "$INSTDIR\AccountPak.mdb" "(BU)" "FullAccess"
;AccessControl::EnableFileInheritance "$INSTDIR\AccountPak.mdb" 

File "C:\ABCDSOFT\AccountPak\NSIS\Shared\GrdVkc32.dll"   ; ������� Guardant
File "C:\ABCDSOFT\AccountPak\NSIS\Shared\grdspactivate.dll"
File "/oname=$INSTDIR\AccountPak.grdvd" "C:\ABCDSOFT\Guardant\AccountPak-60.grdvd" ; ��������� ���.��� ������� 19.02.2015
File "C:\ABCDSOFT\AccountPak\Release\AccpLicActivate.exe"
File "C:\ABCDSOFT\AccountPak\Release.txt"

; VC2012 Redistributable 14.01.2018 - ��������� � ������������� ������ x86-����������:
${If} ${RunningX64}
ReadRegDWORD $0 HKLM SOFTWARE\Wow6432Node\Microsoft\VisualStudio\11.0\VC\Runtimes\x86 "Installed"
${Else}
ReadRegDWORD $0 HKLM SOFTWARE\Microsoft\VisualStudio\10.0\VC\VCRedist\x86 "Installed"
${EndIf}
DetailPrint "����� VC2012 Redistributable: '$0'"
StrCmp $0 "1" 0 VC2012_REDIST_NOT_INSTALLED
DetailPrint "����� VC2012 Redistributable ��� ���������� - ���������� ��������� ������"
Goto VC2012_REDIST_ALREADY_INSTALLED

VC2012_REDIST_NOT_INSTALLED:

DetailPrint "����� VC2012 Redistributable �� ���������� - ��������� ���������:"
SetOutPath $TEMP ; ������������� � ������������� �� ��������� ����������:
File "C:\ABCDSOFT\AccountPak\NSIS\Shared\VC Redist\2012\x86\vcredist_x86.exe"
ExecWait '"$TEMP\vcredist_x86.exe" /q'
VC2012_REDIST_ALREADY_INSTALLED:

SetOutPath $INSTDIR
SectionEnd

; =============== ����� �������: ==================
Section "Registry Values"

; License Information for MsDatGrd.ocx:
WriteRegStr HKCR "Licenses\CDE57A55-8B86-11D0-b3C6-00A0C90AEA82" "" "ekpkhddkjkekpdjkqemkfkldoeoefkfdjfqe"

ReadRegStr $R0 HKCU "Software\ABCDsoft\AccountPak\1.0" "base"
IfErrors 0 NoError
  WriteRegStr HKCU "Software\ABCDsoft\AccountPak\1.0" "base" "$INSTDIR\accountpak.mdb"
  Goto ErrorYay
NoError:
  ; ���� ����������� - ������ �� ������
ErrorYay:

; ��������� ���� AccountPak - miximized, ������ ���������� - ��������:
StrCpy $0 0
loop:
  ClearErrors
  EnumRegValue $1 HKCU Software\ABCDsoft\AccountPak\2.0 $0
  StrCmp $1 "wstate" found
  IfErrors not_found
  IntOp $0 $0 + 1
Goto loop
not_found:
DetailPrint "������� � Registry ��������� ���� wstate"
; 15.01.2013 ����������. "Normal" ���:
WriteRegBin HKCU "Software\ABCDsoft\AccountPak\2.0" "wstate" 780000000200000002000000020000000200000003000000F1FFFFFF00000000000000000000000090010000000000CC03020122417269616C204E6172726F770000000000000000000000000000000000000000F1FFFFFF000000000000000000000000BC020000000000CC0302012256657264616E6100742053616E73205365726966000000000000000000000000F1FFFFFF00000000000000000000000090010000000000CC03020122417269616C204E6172726F770000000000000000000000000000000000000000F1FFFFFF000000000000000000000000BC020000000000CC0302012256657264616E61005365726966000000000000000000000000000000000000002C00000002000000030000000000000000000000FFFFFFFFFFFFFFFF3200000032000000B2020000C201000000000000010000000000000000000000
found:

; Write the installation path into the registry
WriteRegStr HKCU SOFTWARE\AccountPak "InstallDir" "$INSTDIR"
  
; 01.08.2013 ��������� ����������� - �� ������ ������������:
;MessageBox MB_YESNO "��������� ���������� ����� AutoRun � ��������� ���� CDROM?$\n \
;  �������� ����� '��' ������ �� ��� �����������, ��� ����� ���������(�) 3G-�����(�) -$\n\
;  ��� ������� �������������� ��� ��������." IDYES true IDNO false
;true:
;  ; ��������� 24.06.2013, 30.06.2013:
;  WriteRegDWORD HKLM "SYSTEM\CurrentControlSet\Services\Cdrom" "AutoRun" 0
;  ;DetailPrint "it's true!"
;  Goto next
;false:
;  ;DetailPrint "it's false"
;next:

; Write the uninstall keys for Windows
WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\AccountPak" "DisplayName" "�AccountPak� - ��������� ��� ������-������������ ������-��"
WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\AccountPak" "DisplayIcon" "$INSTDIR\AccountPak.exe,0"
WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\AccountPak" "InstallLocation" "$INSTDIR"
WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\AccountPak" "DisplayVersion" "2.8"
WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\AccountPak" "HelpLink" "www.accountpak.ru"
WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\AccountPak" "Publisher" "Kazakov Marat: +79033435813"
WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\AccountPak" "URLInfoAbout" "http://www.accountpak.ru"
WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\AccountPak" "URLUpdateInfo" "http://www.accountpak.ru/accp_inst.zip"
WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\AccountPak" "UninstallString" '"$INSTDIR\uninstall.exe"'
WriteRegDWORD HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\AccountPak" "NoModify" 1
WriteRegDWORD HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\AccountPak" "NoRepair" 1
WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\AccountPak" "Version" "2.8"
WriteRegDWORD HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\AccountPak" "VersionMajor" 2
WriteRegDWORD HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\AccountPak" "VersionMinor" 8
WriteUninstaller "uninstall.exe"
SectionEnd

Section "Utils"
SetOverwrite ifnewer
CreateDirectory $INSTDIR\UTILS
SetOutPath $INSTDIR\UTILS

; Resources:
CreateDirectory $INSTDIR\Res
AccessControl::GrantOnFile "$INSTDIR\Res" "(BU)" "FullAccess"
AccessControl::EnableFileInheritance "$INSTDIR\Res" 
SetOutPath $INSTDIR\Res
File "C:\ABCDSOFT\AccountPak\Res\na-splash-001.bmp"
File "C:\ABCDSOFT\AccountPak\Res\na-splash-002.bmp"
File "C:\ABCDSOFT\AccountPak\Res\about-bkg.bmp"

WriteRegStr HKCU "Software\ABCDsoft\AccountPak\2.0" "splashbmp" "$INSTDIR\Res\na-splash-001.bmp"
WriteRegStr HKCU "Software\ABCDsoft\AccountPak\2.0" "tbbmp" "$INSTDIR\Res\about-bkg.bmp"

; ����� ��� �������� AutoRun:
CreateDirectory "$INSTDIR\3G Modem\Megafon\Autorun"
AccessControl::GrantOnFile "$INSTDIR\3G Modem\Megafon\Autorun" "(BU)" "FullAccess" ; 18.02.2015
AccessControl::EnableFileInheritance "$INSTDIR\3G Modem\Megafon\Autorun"
SetOutPath "$INSTDIR\3G Modem\Megafon\Autorun"
File "C:\ABCDSOFT\AccountPak\NSIS\3G Modem\Megafon\AutoRun\Autorun Uninstall.exe"

SetOutPath $INSTDIR
SectionEnd

; ================ ������ ���������: =============
Section "Start Menu Shortcuts"
SetOutPath $INSTDIR ; bug "Working Directory" 15/05/2013

; 26.07.2013: ������ ����������� ����� AccountPak:
SetShellVarContext all ; current <--- 28.07.2013
CreateDirectory "$SMPROGRAMS\AccountPak 2"
CreateShortCut "$SMPROGRAMS\AccountPak 2\AccountPak 2.lnk" "$INSTDIR\AccountPak.exe" "" "" ""
CreateShortCut "$SMPROGRAMS\AccountPak 2\�������� AccountPak 2.lnk" "$INSTDIR\uninstall.exe" "" "$INSTDIR\uninstall.exe" 0

; ������ ����� �� ���. �����:
CreateShortCut "$DESKTOP\AccountPak 2.lnk" "$INSTDIR\AccountPak.exe" "" "$INSTDIR\AccountPak.exe" 0

; ����. ������� �� TaskBar'� (Win7 � ����):
;${PinToTaskBar} "$INSTDIR\AccountPak.exe"
${StdUtils.InvokeShellVerb} $0 "$INSTDIR" "AccountPak.exe" ${StdUtils.Const.ShellVerb.PinToTaskbar}

; 31.03.2014 ��������� ����������� �������� GUARDANT SP/AccountPak:
SetOutPath $INSTDIR
DetailPrint "����������� ��������� ����� �������� ACCOUNTPAK, ���������"

SetDetailsPrint none
ExecWait "$INSTDIR\AccpLicActivate.exe"
SetDetailsPrint both

SectionEnd

; =============== �����������: ==================
Section "Cleanup"
;Delete /REBOOTOK $TEMP\GrdDriversRU.msi
SetRebootFlag true
SectionEnd

;--------------------------------
; Uninstaller
Section "Uninstall"

; Remove registry keys
DeleteRegKey HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\AccountPak"

Delete $INSTDIR\UTILS\*.*
RMDir "$INSTDIR\UTILS"
Delete $INSTDIR\reports\*.*
RMDir "$INSTDIR\reports"
Delete $INSTDIR\patterns\*.*
RMDir "$INSTDIR\patterns"
Delete $INSTDIR\Guardant\*.*
RMDir "$INSTDIR\Guardant"
Delete $INSTDIR\Res\*.*
RMDir "$INSTDIR\Res"
Delete "$INSTDIR\3G Modem\Megafon\Autorun\*.*"
RMDir "$INSTDIR\3G Modem\Megafon\Autorun"
Delete "$INSTDIR\3G Modem\Megafon\*.*"
RMDir "$INSTDIR\3G Modem\Megafon"
Delete "$INSTDIR\3G Modem\*.*"
RMDir "$INSTDIR\3G Modem"
RMDir "$INSTDIR\LOG"

${StdUtils.InvokeShellVerb} $0 "$INSTDIR" "AccountPak.exe" ${StdUtils.Const.ShellVerb.UnpinFromTaskbar}

; Remove desktop shortcut:
Delete "$DESKTOP\AccountPak 2.*"

; Remove files and uninstaller
Delete $INSTDIR\*.exe
Delete $INSTDIR\*.dll
Delete $INSTDIR\*.txt
Delete $INSTDIR\*.grdvd
Delete $INSTDIR\*.grdvd.toserver
Delete $INSTDIR\*.grdvd.fromserver

; Remove program folder and its contents:
;Delete "$STARTMENU\Programs\AccountPak 2\*.*"
;RMDir "$STARTMENU\Programs\AccountPak 2"

; Remove directories used
Delete "$SMPROGRAMS\AccountPak 2\*.*"	; - 28.07.2013
RMDir "$SMPROGRAMS\AccountPak 2"

SectionEnd
