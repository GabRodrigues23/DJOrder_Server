program djorder_server;

uses
  SysUtils,
  Horse,
  Horse.Jhonson,
  routes;

begin
  THorse.Use(Jhonson());

  routes.Registry;

  WriteLn('DJORDER SERVER RUNNING ON PORT 9000');
  THorse.Listen(9000);

end.
