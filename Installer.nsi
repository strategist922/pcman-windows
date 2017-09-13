; Script generated by the HM NIS Edit Script Wizard.
!include LogicLib.nsh
!include x64.nsh

; HM NIS Edit Wizard helper defines
!ifdef _COMBO_
!define PRODUCT_NAME "PCMan Combo"
!define SRC_DIR "Combo\Release\PCMan Combo"
!define CONFIG_FOLDER "PCMAN Combo"
OutFile ".\Release\PCManCB.exe"
!else
!define PRODUCT_NAME "PCMan"
!define SRC_DIR "Lite\Release\PCMan"
!define CONFIG_FOLDER "PCMAN"
OutFile ".\Release\PCMan.exe"
!endif

!define PRODUCT_DIR "${PRODUCT_NAME}"
!define PRODUCT_VERSION "Novus"
!define PRODUCT_PUBLISHER "PCMan Team"
!define PRODUCT_WEB_SITE "http://pcman.openfoundry.org/"
!define PRODUCT_DIR_REGKEY "Software\Microsoft\Windows\CurrentVersion\App Paths\PCMan.exe"
!define PRODUCT_UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"
!define PRODUCT_UNINST_ROOT_KEY "HKLM"

!define /date BUILD_TIME "%H:%M %p, %Y-%m-%d"

SetCompressor /SOLID lzma

; MUI 1.67 compatible ------
!include "MUI.nsh"

; MUI Settings
!define MUI_ABORTWARNING
!define MUI_ICON "${NSISDIR}\Contrib\Graphics\Icons\orange-install.ico"
!define MUI_UNICON "${NSISDIR}\Contrib\Graphics\Icons\orange-uninstall.ico"

; Language Selection Dialog Settings
!define MUI_LANGDLL_REGISTRY_ROOT "${PRODUCT_UNINST_ROOT_KEY}"
!define MUI_LANGDLL_REGISTRY_KEY "${PRODUCT_UNINST_KEY}"
!define MUI_LANGDLL_REGISTRY_VALUENAME "NSIS:Language"

;BGGradient 0000FF 000000 FFFFFF
;Caption "${PRODUCT_NAME} ${PRODUCT_VERSION} ${BUILD_TIME}"
BrandingText "Copyright (C) 2009 PCMan Team  /  Build Time: ${BUILD_TIME}"

; Welcome page
!insertmacro MUI_PAGE_WELCOME
; License page
;!define MUI_LICENSEPAGE_CHECKBOX
!insertmacro MUI_PAGE_LICENSE "License.txt"
; Directory page
!insertmacro MUI_PAGE_DIRECTORY
; Instfiles page
!insertmacro MUI_PAGE_INSTFILES
; Finish page
!define MUI_FINISHPAGE_RUN "$INSTDIR\PCMan.exe"
!define MUI_FINISHPAGE_SHOWREADME "$INSTDIR\changelog.txt"
!insertmacro MUI_PAGE_FINISH

; Uninstaller pages
!insertmacro MUI_UNPAGE_INSTFILES

; Language files
!insertmacro MUI_LANGUAGE "English"
!insertmacro MUI_LANGUAGE "TradChinese"

; Reserve files
!insertmacro MUI_RESERVEFILE_INSTALLOPTIONS

; MUI end ------

Name "${PRODUCT_NAME} ${PRODUCT_VERSION}"
InstallDir "$PROGRAMFILES\${PRODUCT_DIR}"
InstallDirRegKey HKLM "${PRODUCT_DIR_REGKEY}" ""
ShowInstDetails show
ShowUnInstDetails show

Function .onInit
  !insertmacro MUI_LANGDLL_DISPLAY
;  MessageBox MB_ICONEXCLAMATION|MB_OK "${BUILD_TIME}"
FunctionEnd

!macro ExtractExecDelete Path
  File "${Path}"
  ClearErrors
  ExecWait "$INSTDIR\${Path}"
  IfErrors 0 +2
  Abort
  Delete "$INSTDIR\${Path}"
!macroend

Section SEC01
  SetOutPath "$INSTDIR"
  
; Must be Windows NT
  ClearErrors
  ReadRegStr $R0 HKLM "SOFTWARE\Microsoft\Windows NT\CurrentVersion" CurrentVersion
  IfErrors 0 +2
  Abort
  
  ${If} ${RunningX64}
    ReadRegStr $1 HKLM "SOFTWARE\Wow6432Node\Microsoft\VisualStudio\14.0\VC\Runtimes\x86" "Installed"
    StrCmp $1 1 installed
  ${Else}
    ReadRegStr $1 HKLM "SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\x86" "Installed"
    StrCmp $1 1 installed
  ${EndIf}
  !insertmacro ExtractExecDelete "vc_redist.x86.exe"
  installed:
  
  SetOverwrite on
  ;SetOverwrite ifnewer
  File /r /x "Symbols.txt" /x "Config" /x "*.svn" /x "Portable" "${SRC_DIR}\*.*"

  SetOverwrite off
  File "${SRC_DIR}\Symbols.txt"

  SetOutPath "$INSTDIR\Config"
  File "${SRC_DIR}\Config\Config.ini"
  File "${SRC_DIR}\Config\BBSFavorites"
  File "${SRC_DIR}\Config\FUS"

  SetOverwrite on
  File "${SRC_DIR}\Config\*.bmp"

  SetShellVarContext all    ; Install for all users

  CreateDirectory "$SMPROGRAMS\${PRODUCT_DIR}"
  CreateShortCut "$SMPROGRAMS\${PRODUCT_DIR}\${PRODUCT_NAME} ${PRODUCT_VERSION}.lnk" "$INSTDIR\PCMan.exe"
  CreateShortCut "$DESKTOP\${PRODUCT_NAME} ${PRODUCT_VERSION}.lnk" "$INSTDIR\PCMan.exe"

  StrCmp $LANGUAGE ${LANG_TRADCHINESE} Chi Eng
  Chi:
    CreateShortCut "$SMPROGRAMS\${PRODUCT_DIR}\標點符號輸入程式.lnk" "$INSTDIR\Symbols.exe" "$INSTDIR\Symbols.exe"
    Goto +2
  Eng:
    CreateShortCut "$SMPROGRAMS\${PRODUCT_DIR}\Symbols.lnk" "$INSTDIR\Symbols.exe" "$INSTDIR\Symbols.exe"

; Delete the previous UI file
  !define SHELLFOLDERS \
        "Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders"

  ReadRegStr $0 HKCU "${SHELLFOLDERS}" AppData
           StrCmp $0 "" 0 +2
       ReadRegStr $0 HKLM "${SHELLFOLDERS}" "Common AppData"
  StrCmp $0 "" 0 +2
         StrCpy $0 "$WINDIR\Application Data"

  Delete "$0\${CONFIG_FOLDER}\UI"
SectionEnd

Section -AdditionalIcons
  WriteIniStr "$INSTDIR\${PRODUCT_NAME}.url" "InternetShortcut" "URL" "${PRODUCT_WEB_SITE}"
  CreateShortCut "$SMPROGRAMS\${PRODUCT_DIR}\Website.lnk" "$INSTDIR\${PRODUCT_NAME}.url"
  CreateShortCut "$SMPROGRAMS\${PRODUCT_DIR}\Uninstall.lnk" "$INSTDIR\uninst.exe"
SectionEnd

Section -Post
  WriteUninstaller "$INSTDIR\uninst.exe"
  WriteRegStr HKLM "${PRODUCT_DIR_REGKEY}" "" "$INSTDIR\PCMan.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayName" "$(^Name)"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "UninstallString" "$INSTDIR\uninst.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayIcon" "$INSTDIR\PCMan.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayVersion" "${PRODUCT_VERSION}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "URLInfoAbout" "${PRODUCT_WEB_SITE}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "Publisher" "${PRODUCT_PUBLISHER}"
SectionEnd

Function un.onUninstSuccess
  HideWindow
  StrCmp $LANGUAGE ${LANG_TRADCHINESE} Chi Eng
  Chi:
    MessageBox MB_ICONINFORMATION|MB_OK "$(^Name) 已成功地從你的電腦移除。"
    Goto +2
  Eng:
    MessageBox MB_ICONINFORMATION|MB_OK "$(^Name) has been removed sucessfully."
FunctionEnd

Function un.onInit
!insertmacro MUI_UNGETLANGUAGE
  StrCmp $LANGUAGE ${LANG_TRADCHINESE} Chi Eng
  Chi:
    MessageBox MB_ICONQUESTION|MB_YESNO|MB_DEFBUTTON2 "你確定要完全移除 $(^Name) ，其及所有的元件？" IDYES +4
    Abort
  Eng:
    MessageBox MB_ICONQUESTION|MB_YESNO|MB_DEFBUTTON2 "Are you sure you want to completely remove $(^Name) and all of its components?" IDYES +2
    Abort
FunctionEnd

Section Uninstall
  RMDir /r "$INSTDIR\Conv"
  RMDir /r "$INSTDIR\Keyboard"
  RMDir /r "$INSTDIR\SearchPlugins"  ; Should search plugins be preserved?
  Delete "$INSTDIR\PCMan.exe"
  Delete "$INSTDIR\B2U"
  Delete "$INSTDIR\U2B"
  Delete "$INSTDIR\Story.txt"
  Delete "$INSTDIR\BBSList"
  Delete "$INSTDIR\${PRODUCT_NAME}.url"
  Delete "$INSTDIR\Symbols.exe"
  Delete "$INSTDIR\uninst.exe"
  Delete "$INSTDIR\*.dll"
  Delete "$INSTDIR\cacert.pem"
  Delete "$INSTDIR\changelog.txt"
  
  RMDir /r "$INSTDIR\Config"
  Delete "$INSTDIR\Symbols.txt"

  SetShellVarContext all    ; Install for all users

  Delete "$SMPROGRAMS\${PRODUCT_DIR}\${PRODUCT_NAME} ${PRODUCT_VERSION}.lnk"
  RMDir /r "$SMPROGRAMS\${PRODUCT_DIR}"

  Delete "$DESKTOP\${PRODUCT_NAME} ${PRODUCT_VERSION}.lnk"

  RMDir "$INSTDIR"

  DeleteRegKey ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}"
  DeleteRegKey HKLM "${PRODUCT_DIR_REGKEY}"
  SetAutoClose true
SectionEnd
