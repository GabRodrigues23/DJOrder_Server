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
  JsonArrayOrders: TJSONArray;
  JsonOrder: TJSONObject;
  JsonProductsList: TJSONArray;
  JsonProduct: TJsonObject;
  JsonAdditionalList: TJsonArray;
  JsonAdditional: TJsonObject;

  LastPreVenda: integer;
  LastItem: integer;
  CurrentPreVenda: integer;
  CurrentItem: integer;
begin
  Conn := connection.GetConnection;
  Query := TZQuery.Create(nil);
  JsonArrayOrders := TJSonArray.Create;

  try
    Query.Connection := Conn;
        Query.SQL.Text :=
      'SELECT PV.CODPREVENDA, PV.ID_COMANDA, PV.IDMESA, PV.COO, PV.NOME_CLI,'
      + ' PV.SUBTOTAL, PV.TAXA_SERVICO, PV.DATAHORA_INICIO,'
      + ' PI.SEQUENCIA, PI.CODPRODUTO, PI.CANCELADO, PI.QTD AS QTD_PROD, PI.PRECO_UNITARIO AS PRECO_PROD,'
      + ' P.DESCRICAO AS DESC_PROD,'
      + ' PA.DESCRICAO AS DESC_ADIC, PA.QTD AS QTD_ADIC, PA.PRECO_UNITARIO AS PRECO_ADIC'
      + ' FROM PREVENDA PV'
      + ' INNER JOIN PRE_ITEM PI ON PV.CODPREVENDA = PI.CODPREVENDA'
      + ' INNER JOIN PRODUTO P ON PI.CODPRODUTO = P.CODPRODUTO'
      + ' LEFT JOIN PRE_ITEM_ADICIONAL PA ON (PI.CODPREVENDA = PA.CODPREVENDA AND PI.SEQUENCIA = PA.SEQUENCIA)'
      + ' WHERE PV.CANCELADO = ''N'' '
      + ' AND (PV.COO IS NULL OR PV.COO <= 0)'
      + ' ORDER BY PV.CODPREVENDA, PI.SEQUENCIA, PA.SEQUENCIA';

    Conn.Connect;
    Query.Open;

    LastPreVenda := -1;
    LastItem := -1;

    JsonOrder := nil;
    JsonProductsList := nil;
    JsonProduct := nil;
    JsonAdditionalList := nil;
    JsonAdditional := nil;

    try
      while not Query.EOF do
      begin
        CurrentPreVenda := Query.FieldByName('CODPREVENDA').AsInteger;
        CurrentItem := Query.FieldByName('SEQUENCIA').AsInteger;

        if CurrentPreVenda <> LastPreVenda then
        begin
          JsonOrder := TJSONObject.Create;
          JsonArrayOrders.Add(JsonOrder);

          JsonOrder.Add('CODPREVENDA', CurrentPreVenda);
          JsonOrder.Add('ID_COMANDA', Query.FieldByName('ID_COMANDA').AsInteger);
          JsonOrder.Add('IDMESA', Query.FieldByName('IDMESA').AsInteger);
          JsonOrder.Add('COO', Query.FieldByName('COO').AsInteger);
          JsonOrder.Add('NOME_CLIENTE', Query.FieldByName('NOME_CLI').AsString);
          JsonOrder.Add('SUBTOTAL', Query.FieldByName('SUBTOTAL').AsFloat);
          JsonOrder.Add('TAXA_SERVICO', Query.FieldByName('TAXA_SERVICO').AsFloat);
          if not Query.FieldByName('DATAHORA_INICIO').IsNull then
            JsonOrder.Add('DATAHORA_INICIO',
              FormatDateTime('yyyy-mm-dd"T"hh:nn:ss',
              Query.FieldByName('DATAHORA_INICIO').AsDateTime))
          else
            JsonOrder.Add('DATAHORA_INICIO', '');

          JsonProductsList := TJSONArray.Create;
          JsonOrder.Add('products', JsonProductsList);

          LastPreVenda := CurrentPreVenda;
          LastItem := -1;
        end;

        if CurrentItem <> LastItem then
        begin
          JsonProduct := TJSONObject.Create;
          JsonProductsList.Add(JsonProduct);

          JsonProduct.Add('SEQUENCIA', CurrentItem);
          JsonProduct.Add('CODPRODUTO', Query.FieldByName('CODPRODUTO').AsInteger);
          JsonProduct.Add('DESCRICAO', Query.FieldByName('DESC_PROD').AsString);
          JsonProduct.Add('QTD', Query.FieldByName('QTD_PROD').AsFloat);
          JsonProduct.Add('PRECO_UNITARIO', Query.FieldByName('PRECO_PROD').AsFloat);
          JsonProduct.Add('CANCELADO', Query.FieldByName('CANCELADO').AsString);

          JsonAdditionalList := TJSONArray.Create;
          JsonProduct.Add('additional', JsonAdditionalList);

          LastItem := CurrentItem;
        end;

        if not Query.FieldByName('DESC_ADIC').IsNull then
        begin
          JsonAdditional := TJSONObject.Create;
          JsonAdditional.Add('DESCRICAO', Query.FieldByName('DESC_ADIC').AsString);
          JsonAdditional.Add('QTD', Query.FieldByName('QTD_ADIC').AsFloat);
          JsonAdditional.Add('PRECO_UNITARIO', Query.FieldByName('PRECO_ADIC').AsFloat);

          JsonAdditionalList.Add(JsonAdditional);
        end;

        Query.Next;

      end;

      Res.ContentType('application/json').Send(JsonArrayOrders.AsJSON);

    finally
      JsonArrayOrders.Free;
      Query.Free;
      Conn.Free;
    end;

  except
    on E: Exception do
      Res.Status(500).Send('Erro: ' + E.Message);
  end;

end;

end.
