unit UBarData;

interface
  uses
    Math;

  type

    PNode = ^TNode;
    TNode = record
      row, col: Integer;
      value: TObject;
      next: PNode;
    end;

    TRows = Array of PNode;

    TSparseMatrix = class(TObject)
      Data: TRows;
      RowCount, ColCount: Integer;
      DataMin, DataMax: Single;
      constructor Create;
      destructor Destroy;
      procedure Add(row, col: Integer; value: TObject);
      function Get(row, col: Integer): TObject;
      function GetRow(row: Integer): PNode;
      function CreateNode(row, col: Integer; value: TObject): PNode;
    end;

implementation

uses
  U3DBarGraph;

constructor TSparseMatrix.Create;
begin
  inherited;
  Data := [];
  RowCount := 0;
  ColCount := 0;
  DataMin := MaxSingle;
  DataMax := MinSingle;
end;

function TSparseMatrix.GetRow(row: Integer): PNode;
var
  P: PNode;
  i: Integer;
begin
  for i := 0 to length(Data) - 1 do
    begin
      P := Data[i];
      if P^.row = row then Exit(P);
    end;
  Result := Nil;
end;

function TSparseMatrix.Get(row, col: Integer): TObject;
var
  P: PNode;
begin
  P := GetRow(row);
  while P <> Nil do
    begin
      if P^.col = col then Exit(P^.value);
      P := P^.next;
    end;
  Result := Nil;
end;

function TSparseMatrix.CreateNode(row, col: Integer; value: TObject): PNode;
var
  bar: TBar;
begin
  bar := value as TBar;
  DataMin := Min(DataMin, bar.val);
  DataMax := Max(DataMax, bar.val);
  RowCount := Max(RowCount, row + 1);
  ColCount := Max(ColCount, col + 1);
  New(Result);
  Result^.col := col;
  Result^.row := row;
  Result^.value := value;
  Result^.Next := Nil;
end;

procedure TSparseMatrix.Add(row, col: Integer; value: TObject);
var
  P: PNode;
begin
  P := GetRow(row);
  if P = Nil then
    begin
      P := CreateNode(row, col, value);
      Data := Data + [P];
    end
  else
    begin
      while P^.next <> Nil do P := P^.next;
      P^.next := CreateNode(row, col, value);
    end;
end;

destructor TSparseMatrix.Destroy;
var
  P, Q: PNode;
  i: Integer;
begin
  for i := 0 to length(Data) - 1 do
    begin
      P := Data[i];
      while P <> Nil do
        begin
          Q := P^.Next;
          P^.Value.Destroy;
          Dispose(P);
          P := Q;
        end;
    end;
  Data := Nil;
  inherited;
end;

end.
