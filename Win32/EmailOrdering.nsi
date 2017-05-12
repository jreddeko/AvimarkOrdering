!include "LogicLib.nsh"
!include "TextFunc.nsh"
!include "nsDialogs.nsh"
!include "LogicLib.nsh"
!include "WinMessages.nsh"
!include "WordFunc.nsh"
!include "MUI2.nsh"
!include "FileFunc.nsh"


;-------------------------------
;Variables

!define APP_NAME "Avimark Email Ordering"
!define COMP_NAME "WDDC"
!define INSTDIR_REG_ROOT "HKLM"
!define INSTDIR_REG_KEY "Software\${COMP_NAME}\${APP_NAME}"
!define UNINSTDIR_REG_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}"
!define APP_VERSION "0.1.0"
!define APP_EXE "EmailOrdering.exe"
!define APP_DESCRIPTION ""
!define LICENSE_FILE "License.rtf"
!include "x64.nsh"

;--------------------------------

;General

Name "${APP_NAME}"
OutFile "${APP_NAME}.exe"
InstallDir "$PROGRAMFILES\${COMP_NAME}\${APP_NAME}"


;Interface Settings

!define MUI_ABORTWARNING

;--------------------------------
;Pages

  !insertmacro MUI_PAGE_LICENSE "${LICENSE_FILE}"
  !insertmacro MUI_PAGE_COMPONENTS
  !insertmacro MUI_PAGE_DIRECTORY
  !insertmacro MUI_PAGE_INSTFILES

  !insertmacro MUI_UNPAGE_CONFIRM
  !insertmacro MUI_UNPAGE_INSTFILES
  
;--------------------------------
;Languages
 
!insertmacro MUI_LANGUAGE "English"


;--------------------------------


;Sections

Section "${APP_NAME}" SecApp
  # define output path
  SetOutPath $INSTDIR

  WriteUninstaller "uninstall.exe"
 
  ;Get Files
  File "release\EmailOrdering.exe" 
  File "release\symbol.ico" 
  File "release\success.ico" 
  File "release\error.ico" 
  File "release\midas.dll" 

  SetShellVarContext all
  CreateDirectory '$SMPROGRAMS\${APP_NAME}'
  CreateShortcut "$desktop\${APP_NAME}.lnk" "$INSTDIR\${APP_EXE}" \
    "" "$INSTDIR\${APP_EXE}" 0 SW_SHOWNORMAL 
  CreateShortcut "$SMPROGRAMS\${APP_NAME}\${APP_NAME}.lnk" "$INSTDIR\${APP_EXE}" \
    "" "$INSTDIR\${APP_EXE}" 0 SW_SHOWNORMAL 

  WriteRegExpandStr ${INSTDIR_REG_ROOT} "${INSTDIR_REG_KEY}" "DisplayVersion" "${APP_VERSION}"
  WriteRegExpandStr ${INSTDIR_REG_ROOT} "${INSTDIR_REG_KEY}" "InstallLocation" $INSTDIR
  WriteRegExpandStr ${INSTDIR_REG_ROOT} "${UNINSTDIR_REG_KEY}" "DisplayName" "${APP_NAME}"
  WriteRegExpandStr ${INSTDIR_REG_ROOT} "${UNINSTDIR_REG_KEY}" "UninstallString" "$\"$INSTDIR\uninstall.exe$\""
  WriteRegStr HKEY_LOCAL_MACHINE "Software\Microsoft\Windows\CurrentVersion\Run" \
    "${APP_NAME}" "$INSTDIR\${APP_EXE}"    

  ; Get Estimated size
  ${GetSize} "$INSTDIR" "/S=0K" $0 $1 $2
  IntFmt $0 "0x%08X" $0
  WriteRegDWORD ${INSTDIR_REG_ROOT} "${INSTDIR_REG_KEY}" "EstimatedSize" "$0"

  RegDLL "$INSTDIR\midas.ocx"
SectionEnd
;--------------------------------

Section UnInstall

  SetShellVarContext all
  Delete "$SMPROGRAMS\${APP_NAME}\${APP_NAME}.lnk"
  Delete "$desktop\${APP_NAME}.lnk" 
  RmDir "$SMPROGRAMS\${APP_NAME}"

  DeleteRegKey HKLM "${INSTDIR_REG_KEY}"
  DeleteRegKey HKLM "${UNINSTDIR_REG_KEY}"
  DeleteRegValue HKEY_LOCAL_MACHINE "Software\Microsoft\Windows\CurrentVersion\Run" "${APP_NAME}"     

  #need to delete files here
  Delete "$INSTDIR\EmailOrdering.exe"
  Delete "$INSTDIR\symbol.ico" 
  Delete "$INSTDIR\success.ico" 
  Delete "$INSTDIR\error.ico" 
  Delete "$INSTDIR\uninstall.exe" 

  RmDir "$PROGRAMFILES\${COMP_NAME}\${APP_NAME}"
  RMDir /r "$LOCALAPPDATA\YourApp"

SectionEnd

Function .onInit
  ReadRegStr $R0 ${INSTDIR_REG_ROOT} "${INSTDIR_REG_KEY}" "DisplayVersion"
  
  StrCmp $R0 "" done

  MessageBox MB_OKCANCEL|MB_ICONEXCLAMATION \
   "${APP_NAME} is already installed. $\n$\nClick 'OK' to remove the \
      previous version or 'Cancel' to cancel this upgrade." \
    IDOK uninst
  Abort
 
  ;Run the uninstaller
  uninst:
    ClearErrors
    ReadRegStr $R0 ${INSTDIR_REG_ROOT} "${UNINSTDIR_REG_KEY}" "UninstallString" 
    ExecWait '$R0 _?=$INSTDIR' ;Do not copy the uninstaller to a temp file
   
    IfErrors no_remove_uninstaller done

    no_remove_uninstaller:
   
  done:
 
FunctionEnd

