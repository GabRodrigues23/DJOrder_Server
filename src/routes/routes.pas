unit routes;

{$mode OBJFPC}{$H+}

interface

uses
  order_controller;

procedure Registry;

implementation

procedure Registry;
begin
  order_controller.Registry;
end;

end.
