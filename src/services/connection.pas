unit connection;

{$mode OBJFPC}{$H+}

interface

uses
  Classes, SysUtils, ZConnection, ZDataset;

function GetConnection: TZConnection;

implementation

const
  DB_PATH = 'C:\DJSYSTEM\MONITOR\DJPDV.FDB';
  DB_USER = 'SYSDBA';
  DB_PASS = 'masterkey';

function GetConnection: TZConnection;
var
  AppPath: string;
begin
  Result := TZConnection.Create(nil);

  AppPath := ExtractFilePath(ParamStr(0));

  Result.Protocol := 'firebird';
  Result.LibraryLocation := AppPath + 'fbclient.dll';
  Result.Database := DB_PATH;
  Result.User := DB_User;
  Result.Password := DB_Pass;
  Result.Properties.Add('Codepage=UTF8');
  Result.LoginPrompt := False;
end;

end.
