; Electrical Weeding - Windows 10/11 installer (per-user, no admin rights needed)
Unicode true
!include "MUI2.nsh"
!include "LogicLib.nsh"
!include "FileFunc.nsh"
!include "x64.nsh"
!include "WordFunc.nsh"
!include "WinMessages.nsh"

!define APPNAME   "Electrical Weeding"
!define OLDNAME   "Electrical Weeding Beta"   ; no earlier name; cleanup of it is a harmless no-op
!define APPID     "ElectricalWeeding"
!define VERSION   "1.0.0"
!define PUBLISHER "Fictional Softworks"
!define UNINSTKEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPID}"

Name "${APPNAME}"
OutFile "ElectricalWeeding-Setup-${VERSION}.exe"
InstallDir "$LOCALAPPDATA\Programs\${APPID}"
; The previous InstallDir is read in .onInit (only used if that folder still exists).
RequestExecutionLevel user
SetCompressor /SOLID lzma
ManifestDPIAware true
ManifestSupportedOS all

VIProductVersion "${VERSION}.0"
VIAddVersionKey "ProductName" "${APPNAME}"
VIAddVersionKey "CompanyName" "${PUBLISHER}"
VIAddVersionKey "FileDescription" "${APPNAME} Setup"
VIAddVersionKey "FileVersion" "${VERSION}"
VIAddVersionKey "ProductVersion" "${VERSION}"
VIAddVersionKey "LegalCopyright" "(c) 1994 ${PUBLISHER}"

!define MUI_ICON "icon.ico"
!define MUI_UNICON "icon.ico"
!define MUI_WELCOMEFINISHPAGE_BITMAP "sidebar.bmp"
!define MUI_UNWELCOMEFINISHPAGE_BITMAP "sidebar.bmp"
!define MUI_ABORTWARNING
!define MUI_WELCOMEPAGE_TITLE "Welcome to ${APPNAME}"
; Static fallback only; WelcomeShow sets the real text at runtime (the
; $WelcomeText variable did not render when used here on real Windows).
!define MUI_WELCOMEPAGE_TEXT "A trading game of the Touchet Valley, in the style of 1990s DOS shareware.$\r$\n$\r$\nClick Next to continue."
!define MUI_FINISHPAGE_RUN
!define MUI_FINISHPAGE_RUN_TEXT "Play ${APPNAME} now"
!define MUI_FINISHPAGE_RUN_FUNCTION LaunchGame
!define MUI_FINISHPAGE_SHOWREADME "$INSTDIR\README.txt"
!define MUI_FINISHPAGE_SHOWREADME_NOTCHECKED

Var WelcomeText  ; set in .onInit, applied by WelcomeShow
Var FinishText   ; built by FinishShow
Var IsUpgrade    ; 1 = previous install folder found; Directory page is skipped
Var OldVersion   ; DisplayVersion of the previous install ("" if unknown)
Var OldDir       ; InstallDir of the previous install
Var KeepData     ; uninstaller: 1 = keep profile and InstallDir value
Var VerCmp       ; VersionCompare(old, new): 0 same/unknown, 1 old is newer, 2 old is older
Var PrevVer      ; version label for the "previous" shortcut
Var OldName      ; DisplayName of the previous install ("" if unknown)
Var RenameNote   ; "<old> is now <new>. " when upgrading from the old name, else ""
Var HadOldDesktop ; 1 = an old-name desktop shortcut was found (and removed) by this install

!define MUI_PAGE_CUSTOMFUNCTION_SHOW WelcomeShow
!insertmacro MUI_PAGE_WELCOME
!define MUI_PAGE_CUSTOMFUNCTION_PRE DirectoryPre
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_INSTFILES
!define MUI_PAGE_CUSTOMFUNCTION_SHOW FinishShow
!insertmacro MUI_PAGE_FINISH
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_LANGUAGE "English"

Var EdgePath

!define WELCOME_FRESH "A trading game of the Touchet Valley, in the style of 1990s DOS shareware.$\r$\n$\r$\nYou owe old Sy Wait $$5,500 at 10% a day. You've got 30 days to pay him back.$\r$\n$\r$\nNo administrator rights are needed. Click Next to continue."
!define KEEP_NOTE "Your saved game, high scores and settings will be kept."
!define PREV_NOTE "The previous version stays available from the Start menu."

Function .onInit
  StrCpy $IsUpgrade 0
  StrCpy $VerCmp 0
  StrCpy $HadOldDesktop 0
  StrCpy $RenameNote ""
  StrCpy $WelcomeText "${WELCOME_FRESH}"
  ReadRegStr $OldDir HKCU "Software\${APPID}" "InstallDir"
  ReadRegStr $OldVersion HKCU "${UNINSTKEY}" "DisplayVersion"
  ReadRegStr $OldName HKCU "${UNINSTKEY}" "DisplayName"

  ; Only treat it as a previous install if the folder (and so the player's
  ; profile) is really there. Otherwise this is a fresh install to the default.
  ${If} $OldDir == ""
  ${OrIfNot} ${FileExists} "$OldDir\*.*"
    Return
  ${EndIf}

  StrCpy $INSTDIR $OldDir
  StrCpy $IsUpgrade 1

  ${If} $OldVersion == ""
    ; e.g. reinstall after an uninstall that kept the player's data
    StrCpy $WelcomeText "Reinstalling ${APPNAME} v${VERSION} into $OldDir. ${KEEP_NOTE}$\r$\n$\r$\nClick Next to continue."
    Return
  ${EndIf}

  ; Mention the rename (once: after this install DisplayName is the new name).
  ${If} $OldName != ""
  ${AndIf} $OldName != "${APPNAME}"
    StrCpy $RenameNote "$OldName is now ${APPNAME}. "
  ${EndIf}

  ${VersionCompare} "$OldVersion" "${VERSION}" $VerCmp
  ${If} $VerCmp == 0
    StrCpy $WelcomeText "$RenameNote""Reinstalling ${APPNAME} v${VERSION}. ${KEEP_NOTE}$\r$\n$\r$\nClick Next to continue."
  ${ElseIf} $VerCmp == 1
    ; downgrade: installed version is newer than this installer
    MessageBox MB_YESNO|MB_ICONEXCLAMATION "${APPNAME} v$OldVersion is installed, which is newer than this installer (v${VERSION}).$\r$\n$\r$\nSaved games from the newer version may not load in this older one.$\r$\n$\r$\nContinue anyway?" /SD IDYES IDYES +2
      Quit
    StrCpy $WelcomeText "$RenameNote""Replacing v$OldVersion with the older v${VERSION}. ${KEEP_NOTE} ${PREV_NOTE}$\r$\n$\r$\nClick Next to continue."
  ${Else}
    StrCpy $WelcomeText "$RenameNote""Upgrading from v$OldVersion to v${VERSION}. ${KEEP_NOTE} ${PREV_NOTE}$\r$\n$\r$\nClick Next to continue."
  ${EndIf}
FunctionEnd

Function WelcomeShow
  SendMessage $mui.WelcomePage.Text ${WM_SETTEXT} 0 "STR:$WelcomeText"
FunctionEnd

Function FinishShow
  StrCpy $FinishText "${APPNAME} v${VERSION} has been installed on your computer.$\r$\n$\r$\n"
  ${If} $IsUpgrade == 1
    StrCpy $FinishText "$FinishText${KEEP_NOTE}"
    ${If} $OldVersion != ""
    ${AndIf} $VerCmp != 0
      StrCpy $FinishText "$FinishText v$OldVersion is still available from the Start menu."
    ${EndIf}
    StrCpy $FinishText "$FinishText$\r$\n$\r$\n"
  ${EndIf}
  StrCpy $FinishText "$FinishText""Click Finish to close Setup."
  SendMessage $mui.FinishPage.Text ${WM_SETTEXT} 0 "STR:$FinishText"
FunctionEnd

Function DirectoryPre
  ${If} $IsUpgrade == 1
    Abort ; keep the existing folder: the saves are tied to it
  ${EndIf}
FunctionEnd

Function FindEdge
  StrCpy $EdgePath ""
  SetRegView 64
  ReadRegStr $EdgePath HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\msedge.exe" ""
  SetRegView 32
  ${If} $EdgePath == ""
    ReadRegStr $EdgePath HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\msedge.exe" ""
  ${EndIf}
  ${If} $EdgePath == ""
    ReadRegStr $EdgePath HKCU "SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\msedge.exe" ""
  ${EndIf}
  ; strip surrounding quotes if present
  StrCpy $0 $EdgePath 1
  ${If} $0 == '"'
    StrCpy $EdgePath $EdgePath "" 1
    StrCpy $EdgePath $EdgePath -1
  ${EndIf}
  ${If} $EdgePath == ""
  ${OrIfNot} ${FileExists} "$EdgePath"
    StrCpy $EdgePath ""
    ${If} ${FileExists} "$PROGRAMFILES32\Microsoft\Edge\Application\msedge.exe"
      StrCpy $EdgePath "$PROGRAMFILES32\Microsoft\Edge\Application\msedge.exe"
    ${ElseIf} ${FileExists} "$PROGRAMFILES64\Microsoft\Edge\Application\msedge.exe"
      StrCpy $EdgePath "$PROGRAMFILES64\Microsoft\Edge\Application\msedge.exe"
    ${EndIf}
  ${EndIf}
FunctionEnd

; Creates a shortcut that opens an html page under $INSTDIR in its own Edge
; app window (no tabs or address bar); falls back to the default browser.
; Every game shortcut, including the "previous version" one, MUST share the
; same --user-data-dir so they all see the same saves.
!macro GameShortcutEx LNK HTML
  ${If} $EdgePath != ""
    CreateShortcut "${LNK}" "$EdgePath" '--app="file:///$INSTDIR\${HTML}" --start-maximized --window-size=1920,1080 --user-data-dir="$INSTDIR\profile"' "$INSTDIR\icon.ico" 0 SW_SHOWMAXIMIZED "" "${APPNAME}"
  ${Else}
    CreateShortcut "${LNK}" "$INSTDIR\${HTML}" "" "$INSTDIR\icon.ico" 0 SW_SHOWNORMAL "" "${APPNAME}"
  ${EndIf}
!macroend
!macro GameShortcut LNK
  !insertmacro GameShortcutEx "${LNK}" "index.html"
!macroend

; Never deletes or overwrites $INSTDIR\profile or any unknown files; only the
; files listed here are (over)written. Old uninstallers are never run.
Section "Game files (required)" SecCore
  SectionIn RO
  SetOutPath "$INSTDIR"

  ; Keep the version being replaced (upgrade or downgrade) in $INSTDIR\previous
  ; so it can still be run. Same-version reinstall (or unknown old version)
  ; leaves any existing previous\ untouched. Copies, never moves, so the
  ; installed game is intact if anything fails. profile\ is never touched.
  ${If} $IsUpgrade == 1
  ${AndIf} $OldVersion != ""
  ${AndIf} $VerCmp != 0
  ${AndIf} ${FileExists} "$INSTDIR\index.html"
    CreateDirectory "$INSTDIR\previous"
    ClearErrors
    CopyFiles /SILENT "$INSTDIR\index.html" "$INSTDIR\previous\index.html"
    ${IfNot} ${Errors}
      ; optional files: copy if present, otherwise drop a stale older copy
      ${If} ${FileExists} "$INSTDIR\icon.ico"
        CopyFiles /SILENT "$INSTDIR\icon.ico" "$INSTDIR\previous\icon.ico"
      ${Else}
        Delete "$INSTDIR\previous\icon.ico"
      ${EndIf}
      ${If} ${FileExists} "$INSTDIR\README.txt"
        CopyFiles /SILENT "$INSTDIR\README.txt" "$INSTDIR\previous\README.txt"
      ${Else}
        Delete "$INSTDIR\previous\README.txt"
      ${EndIf}
      ClearErrors
      FileOpen $0 "$INSTDIR\previous\version.txt" w
      ${IfNot} ${Errors}
        FileWrite $0 "$OldVersion"
        FileClose $0
      ${EndIf}
      WriteRegStr HKCU "Software\${APPID}" "PreviousVersion" "$OldVersion"
    ${Else}
      DetailPrint "Could not back up v$OldVersion; the previous-version shortcut will not be updated."
    ${EndIf}
  ${EndIf}

  File "index.html"
  File "icon.ico"
  File "README.txt"
  WriteUninstaller "$INSTDIR\Uninstall.exe"

  ; Remove shortcuts left by versions installed under the old name. Explicit
  ; files and a plain RMDir only (never /r), so unknown files are left alone.
  Delete "$SMPROGRAMS\${OLDNAME}\${OLDNAME}.lnk"
  Delete "$SMPROGRAMS\${OLDNAME}\Uninstall ${OLDNAME}.lnk"
  Delete "$SMPROGRAMS\${OLDNAME}\${OLDNAME} (previous *).lnk"
  RMDir "$SMPROGRAMS\${OLDNAME}"
  ${If} ${FileExists} "$DESKTOP\${OLDNAME}.lnk"
    StrCpy $HadOldDesktop 1
    Delete "$DESKTOP\${OLDNAME}.lnk"
  ${EndIf}

  Call FindEdge
  CreateDirectory "$SMPROGRAMS\${APPNAME}"
  !insertmacro GameShortcut "$SMPROGRAMS\${APPNAME}\${APPNAME}.lnk"
  CreateShortcut "$SMPROGRAMS\${APPNAME}\Uninstall ${APPNAME}.lnk" "$INSTDIR\Uninstall.exe"

  ; Previous-version shortcut: same profile (shared saves), older html.
  Delete "$SMPROGRAMS\${APPNAME}\${APPNAME} (previous *).lnk"
  ${If} ${FileExists} "$INSTDIR\previous\index.html"
    ReadRegStr $PrevVer HKCU "Software\${APPID}" "PreviousVersion"
    ${If} $PrevVer == ""
      ClearErrors
      FileOpen $0 "$INSTDIR\previous\version.txt" r
      ${IfNot} ${Errors}
        FileRead $0 $PrevVer
        FileClose $0
      ${EndIf}
      ; trim any trailing line break / spaces
      ${Do}
        StrCpy $1 $PrevVer 1 -1
        ${If} $1 == "$\r"
        ${OrIf} $1 == "$\n"
        ${OrIf} $1 == " "
          StrCpy $PrevVer $PrevVer -1
        ${Else}
          ${ExitDo}
        ${EndIf}
      ${Loop}
    ${EndIf}
    ${If} $PrevVer == ""
      StrCpy $PrevVer "earlier"
    ${EndIf}
    !insertmacro GameShortcutEx "$SMPROGRAMS\${APPNAME}\${APPNAME} (previous v$PrevVer).lnk" "previous\index.html"
  ${EndIf}

  ; The player had a desktop icon under the old name: keep one under the new
  ; name even if the Desktop shortcut component was unselected.
  ${If} $HadOldDesktop == 1
    !insertmacro GameShortcut "$DESKTOP\${APPNAME}.lnk"
  ${EndIf}

  WriteRegStr HKCU "Software\${APPID}" "InstallDir" "$INSTDIR"
  WriteRegStr HKCU "${UNINSTKEY}" "DisplayName" "${APPNAME}"
  WriteRegStr HKCU "${UNINSTKEY}" "DisplayVersion" "${VERSION}"
  WriteRegStr HKCU "${UNINSTKEY}" "Publisher" "${PUBLISHER}"
  WriteRegStr HKCU "${UNINSTKEY}" "DisplayIcon" "$INSTDIR\icon.ico"
  WriteRegStr HKCU "${UNINSTKEY}" "InstallLocation" "$INSTDIR"
  WriteRegStr HKCU "${UNINSTKEY}" "UninstallString" '"$INSTDIR\Uninstall.exe"'
  WriteRegStr HKCU "${UNINSTKEY}" "QuietUninstallString" '"$INSTDIR\Uninstall.exe" /S'
  WriteRegDWORD HKCU "${UNINSTKEY}" "NoModify" 1
  WriteRegDWORD HKCU "${UNINSTKEY}" "NoRepair" 1
  ; Top-level files only (/G=0): the Edge profile folder is huge. GetSize
  ; prints a "Size: ... Files: ..." detail line, so silence it.
  SetDetailsPrint none
  ${GetSize} "$INSTDIR" "/M=*.* /S=0K /G=0" $0 $1 $2
  SetDetailsPrint both
  IntFmt $0 "0x%08X" $0
  WriteRegDWORD HKCU "${UNINSTKEY}" "EstimatedSize" "$0"
SectionEnd

Section "Desktop shortcut" SecDesktop
  Call FindEdge
  !insertmacro GameShortcut "$DESKTOP\${APPNAME}.lnk"
SectionEnd

!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
  !insertmacro MUI_DESCRIPTION_TEXT ${SecCore} "The game, icon, readme, and Start menu entry."
  !insertmacro MUI_DESCRIPTION_TEXT ${SecDesktop} "Put a ${APPNAME} icon on your desktop."
!insertmacro MUI_FUNCTION_DESCRIPTION_END

Function LaunchGame
  ExecShell "open" "$SMPROGRAMS\${APPNAME}\${APPNAME}.lnk"
FunctionEnd

Section "Uninstall"
  StrCpy $KeepData 1
  ; Silent uninstall (/S) keeps the data.
  MessageBox MB_YESNO|MB_ICONQUESTION|MB_DEFBUTTON1 "Keep your saved game and high scores? (Choose Yes if you might reinstall later.)" /SD IDYES IDYES +2
    StrCpy $KeepData 0

  ; New-name and old-name shortcuts, explicit files and plain RMDir (never /r).
  Delete "$DESKTOP\${OLDNAME}.lnk"
  Delete "$SMPROGRAMS\${OLDNAME}\${OLDNAME}.lnk"
  Delete "$SMPROGRAMS\${OLDNAME}\Uninstall ${OLDNAME}.lnk"
  Delete "$SMPROGRAMS\${OLDNAME}\${OLDNAME} (previous *).lnk"
  RMDir "$SMPROGRAMS\${OLDNAME}"
  Delete "$DESKTOP\${APPNAME}.lnk"
  Delete "$SMPROGRAMS\${APPNAME}\${APPNAME}.lnk"
  Delete "$SMPROGRAMS\${APPNAME}\Uninstall ${APPNAME}.lnk"
  Delete "$SMPROGRAMS\${APPNAME}\${APPNAME} (previous *).lnk"
  RMDir "$SMPROGRAMS\${APPNAME}"
  Delete "$INSTDIR\index.html"
  Delete "$INSTDIR\intro.mp4"
  Delete "$INSTDIR\icon.ico"
  Delete "$INSTDIR\README.txt"
  Delete "$INSTDIR\Uninstall.exe"
  ; Previous-version backup: explicit files and a plain RMDir (never /r).
  ${If} $INSTDIR != ""
    Delete "$INSTDIR\previous\index.html"
    Delete "$INSTDIR\previous\icon.ico"
    Delete "$INSTDIR\previous\README.txt"
    Delete "$INSTDIR\previous\version.txt"
    RMDir "$INSTDIR\previous"
  ${EndIf}
  DeleteRegValue HKCU "Software\${APPID}" "PreviousVersion"
  ${If} $KeepData == 0
    ${If} $INSTDIR != ""
      RMDir /r "$INSTDIR\profile"
    ${EndIf}
    DeleteRegKey HKCU "Software\${APPID}"
  ${EndIf}
  ; Plain RMDir: only removes the folder if it is empty (never unknown files).
  RMDir "$INSTDIR"
  DeleteRegKey HKCU "${UNINSTKEY}"
SectionEnd
