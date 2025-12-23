program djorder_server;

{$apptype gui}

uses
  SysUtils,
  Forms,
  Interfaces,
  Horse,
  Horse.Jhonson,
  routes,
  ufrm_server;

begin
  THorse.Use(Jhonson());
  routes.Registry;

  Application.Scaled := True;
  Application.Initialize;
  Application.MainFormOnTaskBar := False;
  Application.CreateForm(Tfrm_server, frm_server);
  Application.ShowMainForm := False;
  Application.Run;
end.
