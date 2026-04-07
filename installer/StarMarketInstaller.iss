#define MyAppName "StarMarket"
#ifndef MyAppVersion
  #define MyAppVersion "0.1.0"
#endif
#ifndef MyAppPublisher
  #define MyAppPublisher "StarMarket"
#endif
#ifndef SourceDir
  #define SourceDir "build\\windows\\x64\\runner\\Release"
#endif
#ifndef IconFile
  #define IconFile "..\\windows\\runner\\resources\\app_icon.ico"
#endif

[Setup]
AppId={{8D83F932-6CE2-4C4E-B2BA-0D1FA9D6F9D9}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
DisableProgramGroupPage=yes
OutputDir=build\installer
OutputBaseFilename=StarMarket-Setup
Compression=lzma
SolidCompression=yes
WizardStyle=modern
ArchitecturesInstallIn64BitMode=x64compatible
SetupIconFile={#IconFile}
UninstallDisplayIcon={app}\starcitizen_trader.exe

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "Create a desktop icon"; GroupDescription: "Additional icons:"; Flags: unchecked

[Files]
Source: "{#SourceDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\starcitizen_trader.exe"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\starcitizen_trader.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\starcitizen_trader.exe"; Description: "Launch {#MyAppName}"; Flags: nowait postinstall skipifsilent
