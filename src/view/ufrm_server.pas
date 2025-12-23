unit ufrm_server;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  EditBtn, Menus, Horse;

type

  { THorseThread }
  THorseThread = class(TThread)
  protected
    procedure Execute; override;
  end;

  { Tfrm_server }

  Tfrm_server = class(TForm)
    pnpData: TPanel;
    lbTitleDB: TLabel;
    lbPath: TLabel;
    lbPort: TLabel;
    edtPort: TEdit;
    edtPath: TFileNameEdit;
    btnStart: TButton;
    TrayIcon1: TTrayIcon;
    btnStop: TButton;
    lbTitle: TLabel;
    lbStatus: TLabel;
    lbTiming: TLabel;
    status: TLabel;
    timing: TLabel;
    Timer1: TTimer;
    PopupMenu1: TPopupMenu;
    mniClose: TMenuItem;
    procedure btnStartClick(Sender: TObject);
    procedure btnStopClick(Sender: TObject);
    procedure TrayIcon1Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure mniCloseClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);

  private
    FHorseThread: THorseThread;
    FServerRunning: boolean;
    procedure Start;
    procedure Stop;
    procedure MinimizeToTray;
  public

  end;

var
  frm_server: Tfrm_server;

implementation



{$R *.lfm}

{ THorseThread }

procedure THorseThread.Execute;
begin
  try
    THorse.Listen;
  except
    on E: Exception do
      ShowMessage('Erro Horse: ' + E.Message);
  end;
end;

{ Tfrm_server }

procedure Tfrm_server.FormCreate(Sender: TObject);
begin
  TrayIcon1.Visible := True;
  FServerRunning := False;
end;

procedure Tfrm_server.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  CanClose := False;
  MinimizeToTray;
end;

procedure Tfrm_server.mniCloseClick(Sender: TObject);
begin
  Stop;
  TrayIcon1.Visible := False;
  Application.Terminate;
end;

procedure Tfrm_server.TrayIcon1Click(Sender: TObject);
begin
  if WindowState = wsNormal then
  begin
    MinimizeToTray;
  end
  else
  begin
    Show;
    WindowState := wsNormal;
    Application.BringToFront;
  end;

end;

procedure Tfrm_server.btnStartClick(Sender: TObject);
begin
  ShowMessage('Servidor Iniciado na porta ' + edtPort.Text +
    ' Caminho do Banco: ' + edtPath.Text);
  Start;
end;

procedure Tfrm_server.btnStopClick(Sender: TObject);
begin
  Stop;
end;

procedure Tfrm_server.Start;
begin
  edtPath.Enabled := False;
  edtPort.Enabled := False;
  btnStart.Enabled := False;
  btnStop.Enabled := True;

  lbStatus.Font.Color := clGreen;
  status.Caption := 'Ativo';
  status.Font.Color := clGreen;

  Timer1.Enabled := True;
  timing.Caption := '00:00:00';

  THorse.Port := StrToInt(edtPort.Text);
  FHorseThread := THorseThread.Create(False);
  FHorseThread.FreeOnTerminate := True;
  FServerRunning := True;
end;

procedure Tfrm_server.Stop;
begin
  if not FServerRunning then Exit;

  if THorse.IsRunning then
    THorse.StopListen;

  FServerRunning := False;

  edtPath.Enabled := True;
  edtPort.Enabled := True;
  btnStart.Enabled := True;
  btnStop.Enabled := False;

  lbStatus.Font.Color := clRed;
  status.Caption := 'Inativo';
  status.Font.Color := clRed;

  Timer1.Enabled := False;
  timing.Caption := '00:00:00';

end;

procedure Tfrm_server.Timer1Timer(Sender: TObject);
var
  H, M, S: word;
  CurrTime: TDateTime;
begin
  try
    timing.Tag := timing.Tag + 1;
    S := timing.Tag mod 60;
    M := (timing.Tag div 60) mod 60;
    H := (timing.Tag div 3600);
    timing.Caption := Format('%.2d:%.2d:%.2d', [H, M, S]);
  except
    on E: Exception do
      ShowMessage('Erro Timer: ' + E.Message);
  end;
end;

procedure Tfrm_server.MinimizeToTray;
begin
  Self.Hide;
  WindowState := wsMinimized;
end;

end.
