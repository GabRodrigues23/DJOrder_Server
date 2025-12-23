unit connection;

{$mode OBJFPC}{$H+}

interface

uses
  Classes, SysUtils, ZConnection, ufrm_server;

function GetConnection: TZConnection;

implementation

const
  DB_USER = 'SYSDBA';
  DB_PASS = 'masterkey';

function GetConnection: TZConnection;
var
  AppPath: string;
  DB_PATH: string;
  DB_PORT: integer;
begin
  Result := TZConnection.Create(nil);
  DB_PATH := frm_server.edtPath.Text;
  DB_PORT := StrToInt(frm_server.edtPort.Text);

  AppPath := ExtractFilePath(ParamStr(0));

  Result.Protocol := 'firebird';
  Result.LibraryLocation := AppPath + 'fbclient.dll';
  Result.Database := DB_PATH;
  Result.Port := DB_PORT;
  Result.User := DB_USER;
  Result.Password := DB_PASS;
  Result.Properties.Add('Codepage=UTF8');
  Result.LoginPrompt := False;
end;

end.
