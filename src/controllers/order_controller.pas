unit order_controller;

{$mode DELPHI}{$H+}

interface

uses
  Classes, SysUtils,
  Horse, Horse.Jhonson,
  ZDataset, ZConnection,
  fpjson, connection;

procedure Registry;
procedure GetPing(Req: THorseRequest; Res: THorseResponse; Next: TNextProc);
procedure GetOrders(Req: THorseRequest; Res: THorseResponse; Next: TNextProc);

implementation

procedure Registry;
begin
  THorse.Get('/ping', GetPing);
  THorse.Get('/orders', GetOrders);
end;

procedure GetPing(Req: THorseRequest; Res: THorseResponse; Next: TNextProc);
begin
  res.Send('Pong...');
end;

procedure GetOrders(Req: THorseRequest; Res: THorseResponse; Next: TNextProc);
var
  Conn: TZConnection;
  Query: TZQuery;
  JsonArray: TJSONArray;
  JsonOrder: TJSONObject;
  JsonProductsList: TJSonArray;
  JsonProduct: TJsonObject;
  LastPreVenda: integer;
begin
  Conn := connection.GetConnection;
  Query := TZQuery.Create(nil);
  JsonArray := TJSonArray.Create;

  try
    Query.Connection := Conn;
    Query.SQL.Text :=
      'SELECT PV.CODPREVENDA, PV.ID_COMANDA, PV.IDMESA, PV.COO, PV.NOME_CLI, PV.SUBTOTAL, PV.TAXA_SERVICO, PV.DATAHORA_INICIO, PV.CANCELADO, ' +
      'PI.CODPRODUTO, PI.CANCELADO, PI.QTD, PI.PRECO_UNITARIO, P.DESCRICAO ' +
      'FROM PREVENDA PV ' +
      'INNER JOIN PRE_ITEM PI ON PV.CODPREVENDA = PI.CODPREVENDA ' +
      'INNER JOIN PRODUTO P ON PI.CODPRODUTO = P.CODPRODUTO ' +
      'ORDER BY PV.ID_COMANDA';

    Conn.Connect;
    Query.Open;

    LastPreVenda := -1;

    try
      while not Query.EOF do
      begin

        if Query.FieldByName('CODPREVENDA').AsInteger <> LastPreVenda then
        begin
          JsonOrder := TJSONObject.Create;
          JSonArray.Add(JsonOrder);

          JsonOrder.Add('CODPREVENDA', Query.FieldByName('CODPREVENDA').AsInteger);
          JsonOrder.Add('ID_COMANDA', Query.FieldByName('ID_COMANDA').AsInteger);
          JsonOrder.Add('IDMESA', Query.FieldByName('IDMESA').AsInteger);
          JsonOrder.Add('COO', Query.FieldByName('COO').AsInteger);
          JsonOrder.Add('NOME_CLIENTE', Query.FieldByName('NOME_CLI').AsString);
          JsonOrder.Add('SUBTOTAL', Query.FieldByName('SUBTOTAL').AsFloat);
          JsonOrder.Add('TAXA_SERVICO', Query.FieldByName('TAXA_SERVICO').AsFloat);
          JsonOrder.Add('DATAHORA_INICIO', DateToStr(Query.FieldByName(
            'DATAHORA_INICIO').AsDateTime));
          JsonOrder.Add('CANCELADO', Query.FieldByName('CANCELADO').AsString);

          JsonProductsList := TJSONArray.Create;
          JsonOrder.Add('products', JsonProductsList);

          LastPreVenda := Query.FieldByName('CODPREVENDA').AsInteger;
        end;

        JsonProduct := TJSONObject.Create;

        JsonProduct.Add('CODPRODUTO', Query.FieldByName('CODPRODUTO').AsInteger);
        JsonProduct.Add('DESCRICAO', Query.FieldByName('DESCRICAO').AsString);
        JsonProduct.Add('QTD', Query.FieldByName('QTD').AsFloat);
        JsonProduct.Add('PRECO_UNITARIO', Query.FieldByName('PRECO_UNITARIO').AsFloat);
        JsonProduct.Add('CANCELADO', Query.FieldByName('CANCELADO').AsString);

        JsonProductsList.Add(JsonProduct);

        Query.Next;

      end;

      Res.ContentType('application/json').Send(JsonArray.AsJSON);

    finally
      JSONArray.Free;
      Query.Free;
      Conn.Free;
    end;

  except
    on E: Exception do
      Res.Status(500).Send('Erro: ' + E.Message);
  end;

end;

end.
