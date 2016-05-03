; Script generated by the Inno Script Studio Wizard.
; SEE THE DOCUMENTATION FOR DETAILS ON CREATING INNO SETUP SCRIPT FILES!

#define MyAppName "Arcanist"
#define MyAppVersion "1.2.1"
#define MyAppPublisher "By a user"
#define MyAppURL "https://secure.phabricator.com/book/phabricator/article/arcanist_quick_start/"

[Setup]
; NOTE: The value of AppId uniquely identifies this application.
; Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppId={{648A33E5-C28F-40E1-B585-4BAE924D72D9}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
;AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={pf}\{#MyAppName}
DefaultGroupName={#MyAppName}
OutputDir=out
OutputBaseFilename=setup
Compression=lzma
SolidCompression=yes
ChangesEnvironment=yes
ArchitecturesInstallIn64BitMode=x64

[Types]
Name: "full"; Description: "Full installation"
Name: "custom"; Description: "Custom installation"; Flags: iscustom

[Components]
Name: "program"; Description: "Program Files"; Types: full custom; Flags: fixed
Name: "php_x64"; Description: "PHP 7.0.6 x64 files"; Types: custom; Check: IsWin64
Name: "php_x86"; Description: "PHP 7.0.6 x86 files"; Types: custom; Check: "not IsWin64"

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Files]
Source: "Arcanist\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs; Components: program
Source: "php\x64\*"; DestDir: "{app}\php\x64"; Flags: ignoreversion recursesubdirs createallsubdirs; Check: IsWin64; Components: php_x64
Source: "php\x86\*"; DestDir: "{app}\php\x86"; Flags: ignoreversion recursesubdirs createallsubdirs; Check: "not IsWin64"; Components: php_x86
Source: "vc_2015\vc_redist.x64.exe"; DestDir: {tmp}; Flags: deleteafterinstall; Check: IsWin64; Components: php_x64
Source: "vc_2015\vc_redist.x86.exe"; DestDir: {tmp}; Flags: deleteafterinstall; Check: not IsWin64; Components: php_x86
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Run]
; add the Parameters, WorkingDir and StatusMsg as you wish, just keep here
; the conditional installation Check
Filename: "{tmp}\vc_redist.x64.exe"; Check: IsWin64 and not VCinstalled; Components: php_x64
Filename: "{tmp}\vc_redist.x86.exe"; Check: not IsWin64 and not VCinstalled; Components: php_x86

[Registry]
; set PATH
Root: HKLM; Subkey: "SYSTEM\CurrentControlSet\Control\Session Manager\Environment"; ValueType:string; ValueName:"Path"; ValueData:"{olddata};{app}\arcanist\bin"
Root: HKLM; Subkey: "SYSTEM\CurrentControlSet\Control\Session Manager\Environment"; ValueType:string; ValueName:"Path"; ValueData:"{olddata};{app}\php\x64"; Check: IsWin64; Components: php_x64
Root: HKLM; Subkey: "SYSTEM\CurrentControlSet\Control\Session Manager\Environment"; ValueType:string; ValueName:"Path"; ValueData:"{olddata};{app}\php\x86"; Check: "not IsWin64"; Components: php_x86

[Code]

const
  EnvironmentKey = 'SYSTEM\CurrentControlSet\Control\Session Manager\Environment';

procedure RemovePath(Path: string);
var
  Paths: string;
  P: Integer;
begin
  if not RegQueryStringValue(HKEY_LOCAL_MACHINE, EnvironmentKey, 'Path', Paths) then
  begin
    Log('PATH not found');
  end
    else
  begin
    Log(Format('PATH is [%s]', [Paths]));

    P := Pos(';' + Uppercase(Path) + ';', ';' + Uppercase(Paths) + ';');
    if P = 0 then
    begin
      Log(Format('Path [%s] not found in PATH', [Path]));
    end
      else
    begin
      Delete(Paths, P - 1, Length(Path) + 1);
      Log(Format('Path [%s] removed from PATH => [%s]', [Path, Paths]));

      if RegWriteStringValue(HKEY_LOCAL_MACHINE, EnvironmentKey, 'Path', Paths) then
      begin
        Log('PATH written');
      end
        else
      begin
        Log('Error writing PATH');
      end;
    end;
  end;
end;

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
begin
  if CurUninstallStep = usUninstall then
  begin
    RemovePath(ExpandConstant('{app}\arcanist\bin'));
    RemovePath(ExpandConstant('{app}\php\x64'));
    RemovePath(ExpandConstant('{app}\php\x86'));
  end;
end;

function VCinstalled: Boolean;
 // By Michael Weiner <mailto:spam@cogit.net>
 // Function for Inno Setup Compiler
 // 13 November 2015
 // Returns True if Microsoft Visual C++ Redistributable is installed, otherwise False.
 // The programmer may set the year of redistributable to find; see below.
 var
  names: TArrayOfString;
  i: Integer;
  dName, key, year: String;
 begin
  // Year of redistributable to find; leave null to find installation for any year.
  year := '';
  Result := False;
  key := 'Software\Microsoft\Windows\CurrentVersion\Uninstall';
  // Get an array of all of the uninstall subkey names.
  if RegGetSubkeyNames(HKEY_LOCAL_MACHINE, key, names) then
   // Uninstall subkey names were found.
   begin
    i := 0
    while ((i < GetArrayLength(names)) and (Result = False)) do
     // The loop will end as soon as one instance of a Visual C++ redistributable is found.
     begin
      // For each uninstall subkey, look for a DisplayName value.
      // If not found, then the subkey name will be used instead.
      if not RegQueryStringValue(HKEY_LOCAL_MACHINE, key + '\' + names[i], 'DisplayName', dName) then
       dName := names[i];
      // See if the value contains both of the strings below.
      Result := (Pos(Trim('Visual C++ ' + year),dName) * Pos('Redistributable',dName) <> 0)
      i := i + 1;
     end;
   end;
 end;
