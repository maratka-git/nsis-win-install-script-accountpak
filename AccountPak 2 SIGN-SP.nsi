OutFile "C:\tmp\VMware Shared\accp2.8.2.exe"
Name "«AccountPak» 2.8.2"
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
!insertmacro MUI_PAGE_LICENSE "C:\ABCDSOFT\AccountPak\NSIS\Лицензионное соглашение\Лицензия AccountPak.txt"

!define MULTIUSER_INSTALLMODEPAGE "Привет!!!!!!"
!define MULTIUSER_INSTALLMODEPAGE_TEXT_TOP "Выберите тип инсталляции программы AccountPak:"
!define MULTIUSER_INSTALLMODEPAGE_TEXT_ALLUSERS "Установить для всех учётных записей"
!define MULTIUSER_INSTALLMODEPAGE_TEXT_CURRENTUSER "Только для текущей учётной записи"
!insertmacro MULTIUSER_PAGE_INSTALLMODE

!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

;!define MUI_FINISHPAGE_RUN "$INSTDIR\AccpLicActivate.exe"
;!define MUI_FINISHPAGE_RUN_NOTCHECKED
;!define MUI_FINISHPAGE_RUN_TEXT "&Запустить программу «AccountPak»"
;!define MUI_FINISHPAGE_SHOWREADME $INSTDIR\Release.txt
;!define MUI_FINISHPAGE_SHOWREADME_NOTCHECKED
;!define MUI_FINISHPAGE_SHOWREADME_TEXT "Показать файл обновлений Release.txt"

;!define MUI_FINISHPAGE_LINK "My website"
;!define MUI_FINISHPAGE_LINK_LOCATION "http://example.com"

!define MUI_BUTTONTEXT_FINISH "&Готово"
!define MUI_TEXT_FINISH_INFO_TITLE "Завершение работы мастера установки $(^Name)"
!define MUI_TEXT_FINISH_INFO_TEXT "Установка $(^Name) завершена.$\r$\n$\r$\nНажмите кнопку «Готово» для выхода из программы установки."
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
  DetailPrint "Инсталляция AccountPak выполняется на подсистеме x64"
${Else}
  DetailPrint "Инсталляция AccountPak выполняется на подсистеме x86"
${EndIf}

DetailPrint "Версия Windows:"
${if} $ProductType == "1"
  DetailPrint "Платформа: $PlatformID, версия: $MajorVersion.$MinorVersion, build $BuildNumber $CSDVersion - Workstation"
${ElseIf} $ProductType == "2"
  DetailPrint "Платформа: $PlatformID, версия: $MajorVersion.$MinorVersion, build $BuildNumber $CSDVersion - DomainController"
${ElseIf} $ProductType == "3"
  DetailPrint "Платформа: $PlatformID, версия: $MajorVersion.$MinorVersion, build $BuildNumber $CSDVersion - Server"
${Else}
  DetailPrint "Платформа: $PlatformID, версия: $MajorVersion.$MinorVersion, build $BuildNumber $CSDVersion - Неизвестный продукт!"
${EndIf}

SetRegView 64
ClearErrors
ReadRegDWORD $GrdVer HKLM "SOFTWARE\Aktiv\Guardant\Drivers" "Version"
ReadRegDWORD $GrdBuild HKLM "SOFTWARE\Aktiv\Guardant\Drivers" "Build"
DetailPrint "Драйверы Guardant, Версия: $GrdVer, Сборка: $GrdBuild"
IfErrors GUARDDRV_NOT_INSTALLED 0
DetailPrint "Драйверы Guardant уже установлены, проверяем актуальность версии"

IntCmp $GrdVer 1586 GUARDDRV_ACTUAL 0 GUARDDRV_ACTUAL 	; 1585D == 6.31 , делаем сравнение на единичку больше,
DetailPrint "Версия Драйверов Guardant устарела - запускаем установку"
Goto GUARDDRV_OLD

GUARDDRV_ACTUAL:
DetailPrint "Драйверы Guardant актуальной версии - не предлагаем установку"
Goto GUARDDRV_OK

GUARDDRV_NOT_INSTALLED:
DetailPrint "Драйверы Guardant не установлены - запускаем установку"
GUARDDRV_OLD:
SetOutPath $TEMP ; распаковываем и устанавливаем из временной директории
${If} ${RunningX64}
  File "/oname=$TEMP\GrdDriversRU.msi" "C:\ABCDSOFT\AccountPak\NSIS\Shared\guardant-drivers-x64\GrdDriversRU-x64.msi"
${Else}
  File "/oname=$TEMP\GrdDriversRU.msi" "C:\ABCDSOFT\AccountPak\NSIS\Shared\guardant-drivers-x32\GrdDriversRU-x86.msi"
${EndIf}
DetailPrint "УСТАНОВКА ДРАЙВЕРОВ Guardant"
;SetDetailsPrint none
	;DetailPrint 'ExecShellWait: "$TEMP\GrdDriversRU.msi" ; /quiet'
	; Sleep 1000
	${StdUtils.ExecShellWaitEx} $0 $1 "$TEMP\GrdDriversRU.msi" "open" "" ;try to launch the process
	;
	;DetailPrint "Результат: $0: $1" ;returns "ok", "no_wait" or "error".
	StrCmp $0 "error" ExecFailed ;check if process failed to create
	StrCmp $0 "no_wait" WaitNotPossible ;check if process can be waited for - always check this!
	StrCmp $0 "ok" WaitForProc ;make sure process was created successfully
	Abort
WaitForProc:
	; текст от 25.03.2015
	DetailPrint "УСТАНОВКА ДРАЙВЕРОВ GUARDANT:"
	DetailPrint "СЛЕДУЙТЕ УКАЗАНИЯМ УСТАНОВЩИКА И ДОЖДИТЕСЬ ЗАВЕРШЕНИЯ УСТАНОВКИ"

; 03.04.2014 закомментил т.к. теперь используем ${StdUtils.ExecShellWaitEx}
; 02.03.2013 MK:
loop:
FindWindow $0 "MsiDialogCloseClass" ""
IsWindow $0 0 loop
System::Call 'user32::SetForegroundWindow(i r0)'

	${StdUtils.WaitForProcEx} $2 $1
	DetailPrint "Установка завершена, продолжаем инсталляцию (exit code: $2)"
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
  
; ================== Файлы: ======================
CreateDirectory $INSTDIR\LOG
AccessControl::GrantOnFile "$INSTDIR\LOG" "(BU)" "FullAccess"
AccessControl::EnableFileInheritance "$INSTDIR\LOG" 
; шаблоны и отчёты:
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
  DetailPrint "Установка ocx в подсистеме x64 - в каталог '$OUTDIR'"
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
    DetailPrint "Регистрируем COM-интерфейсы компонента: Msdatgrd.ocx "
    RegDLL Msdatgrd.ocx
  MsDatGrdRegistered:

  File "C:\ABCDSOFT\AccountPak\NSIS\Shared\msstdfmt.dll" 
  ReadRegStr $R0 HKCR "TypeLib\{6B263850-900B-11D0-9484-00A0C91110ED}\1.0\0\win32" ""
  IfErrors 0 MsStdFmtRegistered
    DetailPrint "Регистрируем COM-интерфейсы компонента: msstdfmt.dll"
    RegDLL msstdfmt.dll
  MsStdFmtRegistered:


SetOverwrite	ifnewer ; 09.01.2014
SetOutPath $INSTDIR
File "C:\ABCDSOFT\AccountPak\ReleaseGuardant\AccountPak.exe"
IfFileExists "$INSTDIR\AccountPak.mdb" ACCOUNTPAK_MDB_EXISTS 0
DetailPrint "Копируем рабочую Базу Данных: AccountPak.mdb"
File "C:\ABCDSOFT\AccountPak\NSIS\Shared\AccountPak.mdb" ; базу теперь берём из каталога Shared
Goto ACCOUNTPAK_MDB_FURTHER
ACCOUNTPAK_MDB_EXISTS:
DetailPrint "Рабочая База Данных AccountPak.mdb уже присутствует - не перезаписываем"
ACCOUNTPAK_MDB_FURTHER:
; устанавливаем права для всех Пользователей на Базу:
AccessControl::GrantOnFile "$INSTDIR\AccountPak.mdb" "(BU)" "FullAccess"
;AccessControl::EnableFileInheritance "$INSTDIR\AccountPak.mdb" 

File "C:\ABCDSOFT\AccountPak\NSIS\Shared\GrdVkc32.dll"   ; Вакцина Guardant
File "C:\ABCDSOFT\AccountPak\NSIS\Shared\grdspactivate.dll"
File "/oname=$INSTDIR\AccountPak.grdvd" "C:\ABCDSOFT\Guardant\AccountPak-60.grdvd" ; доработал исх.имя шаблона 19.02.2015
File "C:\ABCDSOFT\AccountPak\Release\AccpLicActivate.exe"
File "C:\ABCDSOFT\AccountPak\Release.txt"

; VC2012 Redistributable 14.01.2018 - проверяем и устанавливаем только x86-библиотеку:
${If} ${RunningX64}
ReadRegDWORD $0 HKLM SOFTWARE\Wow6432Node\Microsoft\VisualStudio\11.0\VC\Runtimes\x86 "Installed"
${Else}
ReadRegDWORD $0 HKLM SOFTWARE\Microsoft\VisualStudio\10.0\VC\VCRedist\x86 "Installed"
${EndIf}
DetailPrint "Пакет VC2012 Redistributable: '$0'"
StrCmp $0 "1" 0 VC2012_REDIST_NOT_INSTALLED
DetailPrint "Пакет VC2012 Redistributable уже установлен - пропускаем установку пакета"
Goto VC2012_REDIST_ALREADY_INSTALLED

VC2012_REDIST_NOT_INSTALLED:

DetailPrint "Пакет VC2012 Redistributable не установлен - запускаем установку:"
SetOutPath $TEMP ; распаковываем и устанавливаем из временной директории:
File "C:\ABCDSOFT\AccountPak\NSIS\Shared\VC Redist\2012\x86\vcredist_x86.exe"
ExecWait '"$TEMP\vcredist_x86.exe" /q'
VC2012_REDIST_ALREADY_INSTALLED:

SetOutPath $INSTDIR
SectionEnd

; =============== Ключи Реестра: ==================
Section "Registry Values"

; License Information for MsDatGrd.ocx:
WriteRegStr HKCR "Licenses\CDE57A55-8B86-11D0-b3C6-00A0C90AEA82" "" "ekpkhddkjkekpdjkqemkfkldoeoefkfdjfqe"

ReadRegStr $R0 HKCU "Software\ABCDsoft\AccountPak\1.0" "base"
IfErrors 0 NoError
  WriteRegStr HKCU "Software\ABCDsoft\AccountPak\1.0" "base" "$INSTDIR\accountpak.mdb"
  Goto ErrorYay
NoError:
  ; база установлена - ничего не делаем
ErrorYay:

; состояние окна AccountPak - miximized, пункты навигатора - раскрыты:
StrCpy $0 0
loop:
  ClearErrors
  EnumRegValue $1 HKCU Software\ABCDsoft\AccountPak\2.0 $0
  StrCmp $1 "wstate" found
  IfErrors not_found
  IntOp $0 $0 + 1
Goto loop
not_found:
DetailPrint "Запишем в Registry состояние окна wstate"
; 15.01.2013 устанавлив. "Normal" СМС:
WriteRegBin HKCU "Software\ABCDsoft\AccountPak\2.0" "wstate" 780000000200000002000000020000000200000003000000F1FFFFFF00000000000000000000000090010000000000CC03020122417269616C204E6172726F770000000000000000000000000000000000000000F1FFFFFF000000000000000000000000BC020000000000CC0302012256657264616E6100742053616E73205365726966000000000000000000000000F1FFFFFF00000000000000000000000090010000000000CC03020122417269616C204E6172726F770000000000000000000000000000000000000000F1FFFFFF000000000000000000000000BC020000000000CC0302012256657264616E61005365726966000000000000000000000000000000000000002C00000002000000030000000000000000000000FFFFFFFFFFFFFFFF3200000032000000B2020000C201000000000000010000000000000000000000
found:

; Write the installation path into the registry
WriteRegStr HKCU SOFTWARE\AccountPak "InstallDir" "$INSTDIR"
  
; 01.08.2013 запрещаем опционально - по выбору пользователя:
;MessageBox MB_YESNO "Запретить выполнение файла AutoRun с носителей типа CDROM?$\n \
;  Выберите пункт 'Да' только на тех компьютерах, где будет подключен(ы) 3G-Модем(ы) -$\n\
;  для отсылки уведомительных СМС клиентам." IDYES true IDNO false
;true:
;  ; запрещаем 24.06.2013, 30.06.2013:
;  WriteRegDWORD HKLM "SYSTEM\CurrentControlSet\Services\Cdrom" "AutoRun" 0
;  ;DetailPrint "it's true!"
;  Goto next
;false:
;  ;DetailPrint "it's false"
;next:

; Write the uninstall keys for Windows
WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\AccountPak" "DisplayName" "«AccountPak» - программа для пакето-делательного произв-ва"
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

; Файлы для удаления AutoRun:
CreateDirectory "$INSTDIR\3G Modem\Megafon\Autorun"
AccessControl::GrantOnFile "$INSTDIR\3G Modem\Megafon\Autorun" "(BU)" "FullAccess" ; 18.02.2015
AccessControl::EnableFileInheritance "$INSTDIR\3G Modem\Megafon\Autorun"
SetOutPath "$INSTDIR\3G Modem\Megafon\Autorun"
File "C:\ABCDSOFT\AccountPak\NSIS\3G Modem\Megafon\AutoRun\Autorun Uninstall.exe"

SetOutPath $INSTDIR
SectionEnd

; ================ Ярлыки программы: =============
Section "Start Menu Shortcuts"
SetOutPath $INSTDIR ; bug "Working Directory" 15/05/2013

; 26.07.2013: создаём программную папку AccountPak:
SetShellVarContext all ; current <--- 28.07.2013
CreateDirectory "$SMPROGRAMS\AccountPak 2"
CreateShortCut "$SMPROGRAMS\AccountPak 2\AccountPak 2.lnk" "$INSTDIR\AccountPak.exe" "" "" ""
CreateShortCut "$SMPROGRAMS\AccountPak 2\Удаление AccountPak 2.lnk" "$INSTDIR\uninstall.exe" "" "$INSTDIR\uninstall.exe" 0

; создаём ярлык на раб. столе:
CreateShortCut "$DESKTOP\AccountPak 2.lnk" "$INSTDIR\AccountPak.exe" "" "$INSTDIR\AccountPak.exe" 0

; созд. ярлычок на TaskBar'е (Win7 и выше):
;${PinToTaskBar} "$INSTDIR\AccountPak.exe"
${StdUtils.InvokeShellVerb} $0 "$INSTDIR" "AccountPak.exe" ${StdUtils.Const.ShellVerb.PinToTaskbar}

; 31.03.2014 Запускаем регистратор лицензии GUARDANT SP/AccountPak:
SetOutPath $INSTDIR
DetailPrint "ЗАПУСКАЕТСЯ АКТИВАТОР ВАШЕЙ ЛИЦЕНЗИИ ACCOUNTPAK, ПОДОЖДИТЕ"

SetDetailsPrint none
ExecWait "$INSTDIR\AccpLicActivate.exe"
SetDetailsPrint both

SectionEnd

; =============== Подчистимся: ==================
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
