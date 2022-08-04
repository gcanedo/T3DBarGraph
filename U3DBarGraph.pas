unit U3DBarGraph;

interface
  uses
    FMX.Viewport3D, System.Classes, FMX.Objects3D, Math, System.SysUtils,
    FMX.MaterialSources, System.UIConsts;

  type

    TBar = class(TCube)

      private

      public
        row, col: Integer;
        val: Single;
    end;

    TBarContainer = class(TDummy)
      public
        RowCount, ColCount: Integer;
        DataMin, DataMax: Single;
        constructor Create(AOwner: TComponent); override;
        procedure Add(row, col: Integer; Value: Single);
        procedure CreateBar(row, col: Integer; Value: Single);
    end;

    T3DBarGraph = class(TViewport3D)
      private
      protected
      public
        constructor Create(AOwner: TComponent); override;
        destructor Destroy; override;
      published
    end;

implementation

constructor TBarContainer.Create(AOwner: TComponent);
begin
  inherited;
  RowCount := 0;
  ColCount := 0;
  DataMin := MaxSingle;
  DataMax := MinSingle;
end;

procedure TBarContainer.CreateBar(row, col: Integer; Value: Single);
var
  bar: TBar;
  mat:  TLightMaterialSource;
begin
  bar := TBar.Create(self);
  bar.Name := Format('Bar_%d_%d', [row, col]);
  bar.BeginUpdate;
  bar.Parent := Self;
  bar.row := row;
  bar.col := col;
  bar.val := value;
  bar.Opacity := 1.0;


  mat := TLightMaterialSource.Create(self);
  mat.Shininess := 00;
  mat.Ambient := claBlue;
  mat.Emissive := $00;
  mat.Specular := $00;

  bar.HitTest := false;
  bar.EndUpdate;
  bar.Repaint;
end;

procedure TBarContainer.Add(row, col: Integer; Value: Single);
begin
  RowCount := Max(RowCount, row + 1);
  ColCount := Max(ColCount, col + 1);
  DataMin := Min(DataMin, value);
  DataMax := Max(DataMax, value);
  CreateBar(row, col, Value);
end;

constructor T3DBarGraph.Create(AOwner: TComponent);
begin
  inherited;
end;

destructor T3DBarGraph.Destroy;
begin
  inherited;
end;


end.
