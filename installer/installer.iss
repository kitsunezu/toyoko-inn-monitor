; Toyoko Inn Monitor — Inno Setup Script
; Compiled by GitHub Actions; do not edit AppVersion manually.
; Usage: ISCC /DAppVersion="1.2.3" installer.iss

#ifndef AppVersion
  #define AppVersion "1.0.0"
#endif

#define AppName      "Toyoko Inn Monitor"
#define AppPublisher "YOUR_GITHUB_USERNAME"
#define AppURL       "https://github.com/YOUR_GITHUB_USERNAME/toyoko_inn_monitor"
#define AppExeName   "toyoko_inn_monitor.exe"
#define BuildDir     "..\build\windows\x64\runner\Release"
#define OutDir       "..\dist"

[Setup]
AppId={{A1B2C3D4-E5F6-7890-ABCD-EF1234567890}
AppName={#AppName}
AppVersion={#AppVersion}
AppPublisher={#AppPublisher}
AppPublisherURL={#AppURL}
AppSupportURL={#AppURL}
AppUpdatesURL={#AppURL}/releases
DefaultDirName={autopf}\{#AppName}
DefaultGroupName={#AppName}
AllowNoIcons=yes
LicenseFile=
OutputDir={#OutDir}
OutputBaseFilename=ToyokoInnMonitor-{#AppVersion}-setup
Compression=lzma2/ultra64
SolidCompression=yes
WizardStyle=modern
; Allow silent install (/SILENT or /VERYSILENT)
; Automatically uninstall previous version before installing
CloseApplications=yes
RestartApplications=no
UninstallDisplayIcon={app}\{#AppExeName}
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "{#BuildDir}\{#AppExeName}"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#BuildDir}\*.dll"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs
Source: "{#BuildDir}\data\*"; DestDir: "{app}\data"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\{#AppName}"; Filename: "{app}\{#AppExeName}"
Name: "{group}\{cm:UninstallProgram,{#AppName}}"; Filename: "{uninstallexe}"
Name: "{autodesktop}\{#AppName}"; Filename: "{app}\{#AppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#AppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(AppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent

[UninstallDelete]
; Remove user data only if the user explicitly requests it (not done automatically).
