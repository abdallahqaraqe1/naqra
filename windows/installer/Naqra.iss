; Naqra for Windows: a per-user installer (no administrator rights), in Arabic or English.
; Built by windows/tools/build-installer.sh, which publishes the app and passes:
;   /DArch=arm64|x64  /DSource=<published folder>  /DAppVersion=1.0.0

#ifndef Arch
  #define Arch "arm64"
#endif
#ifndef AppVersion
  #define AppVersion "1.0.0"
#endif
#ifndef Source
  #define Source "..\build\publish\app-" + Arch
#endif

[Setup]
AppId={{8F6A9C31-5E2B-4D7A-9C14-7B3E8A42D905}
AppName=Naqra
AppVersion={#AppVersion}
AppVerName=Naqra {#AppVersion}
AppPublisher=Abdallah Qaraqe
AppPublisherURL=https://github.com/abdallahqaraqe1
AppSupportURL=https://github.com/abdallahqaraqe1/naqra/issues
AppUpdatesURL=https://github.com/abdallahqaraqe1/naqra/releases
AppCopyright=Abdallah Qaraqe · GPL v3
VersionInfoVersion={#AppVersion}
DefaultDirName={autopf}\Naqra
DefaultGroupName=Naqra
DisableProgramGroupPage=yes
DisableDirPage=auto
PrivilegesRequired=lowest
; No license page: the GPL needs no acceptance to install or use; LICENSE.txt is installed with the app.
SetupIconFile=..\assets\Naqra.ico
WizardImageFile=wizard-side-100.bmp,wizard-side-150.bmp,wizard-side-200.bmp
WizardSmallImageFile=wizard-corner-100.bmp,wizard-corner-150.bmp,wizard-corner-200.bmp
UninstallDisplayIcon={app}\Naqra.exe
UninstallDisplayName=Naqra
OutputDir=..\build\installer
; A fixed name keeps the "latest release" download links valid from one version to the next.
OutputBaseFilename=Naqra-Setup-{#Arch}
Compression=lzma2/ultra64
SolidCompression=yes
LZMAUseSeparateProcess=yes
WizardStyle=modern
ShowLanguageDialog=auto
MinVersion=10.0.17763
; A running Naqra locks its files; PrepareToInstall below closes it before anything is copied.
CloseApplications=no
#if Arch == "arm64"
ArchitecturesAllowed=arm64
ArchitecturesInstallIn64BitMode=arm64
#else
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
#endif

[Languages]
Name: "en"; MessagesFile: "compiler:Default.isl"
Name: "ar"; MessagesFile: "compiler:Languages\Arabic.isl"

[CustomMessages]
en.StartWithWindows=Start Naqra when Windows starts
ar.StartWithWindows=تشغيل نقرة مع بدء Windows
en.DesktopIcon=Create a desktop shortcut
ar.DesktopIcon=إنشاء اختصار على سطح المكتب
en.Extras=Options:
ar.Extras=خيارات:
en.Launch=Start Naqra
ar.Launch=تشغيل نقرة

[Tasks]
Name: "startup"; Description: "{cm:StartWithWindows}"; GroupDescription: "{cm:Extras}"
Name: "desktopicon"; Description: "{cm:DesktopIcon}"; GroupDescription: "{cm:Extras}"; Flags: unchecked

[Files]
Source: "{#Source}\*"; DestDir: "{app}"; Excludes: "*.pdb,Microsoft.Web.WebView2.*.xml"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "..\..\LICENSE"; DestDir: "{app}"; DestName: "LICENSE.txt"; Flags: ignoreversion
Source: "..\..\THIRD-PARTY-NOTICES.md"; DestDir: "{app}"; Flags: ignoreversion

[InstallDelete]
; Files from an earlier version that this one no longer ships.
Type: filesandordirs; Name: "{app}\ar"
Type: files; Name: "{app}\*.pdb"
Type: files; Name: "{app}\Microsoft.Web.WebView2.*.xml"

[Icons]
Name: "{autoprograms}\Naqra"; Filename: "{app}\Naqra.exe"
Name: "{autodesktop}\Naqra"; Filename: "{app}\Naqra.exe"; Tasks: desktopicon

[Registry]
; The same value the app's own "Start Naqra when Windows starts" setting writes.
Root: HKCU; Subkey: "Software\Microsoft\Windows\CurrentVersion\Run"; ValueType: string; ValueName: "Naqra"; ValueData: """{app}\Naqra.exe"""; Tasks: startup; Flags: uninsdeletevalue

[Run]
Filename: "{app}\Naqra.exe"; Description: "{cm:Launch}"; Flags: nowait postinstall skipifsilent

[UninstallRun]
Filename: "{sys}\taskkill.exe"; Parameters: "/im Naqra.exe /f"; Flags: runhidden; RunOnceId: "StopNaqra"

[UninstallDelete]
Type: filesandordirs; Name: "{app}"

[Code]
{ Closes a running Naqra (and its command line) so every file can be replaced; it holds no unsaved work. }
function PrepareToInstall(var NeedsRestart: Boolean): String;
var
  Code: Integer;
begin
  Exec(ExpandConstant('{sys}\taskkill.exe'), '/f /im Naqra.exe', '', SW_HIDE, ewWaitUntilTerminated, Code);
  Exec(ExpandConstant('{sys}\taskkill.exe'), '/f /im naqra-cli.exe', '', SW_HIDE, ewWaitUntilTerminated, Code);
  Sleep(500);
  Result := '';
end;

{ A first install in Arabic starts the app in Arabic too; later installs keep the language chosen in Settings. }
procedure CurStepChanged(CurStep: TSetupStep);
var
  Folder: String;
begin
  if CurStep = ssPostInstall then
  begin
    Folder := ExpandConstant('{userappdata}\Naqra');
    if not FileExists(Folder + '\settings.json') then
    begin
      ForceDirectories(Folder);
      SaveStringToFile(Folder + '\settings.json', '{"Language":"' + ActiveLanguage + '"}', False);
    end;
  end;
end;
