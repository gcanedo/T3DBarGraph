unit U3DBarGraph;

interface
  uses
    FMX.Viewport3D, System.Classes, FMX.Objects3D, Math, System.SysUtils,
    FMX.MaterialSources, System.UIConsts, FMX.Types3D, System.Math.Vectors;

  const
    BAR_PAD = 0.25;
    BAR_WIDTH = 0.5;
    BAR_DEPTH = 0.5;
    DEFAULT_ROWCOUNT = 3;
    DEFAULT_COLCOUNT = 4;

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

    TMainContainer = class(TDummy)
      protected
        procedure MainRender(Sender: TObject; Context: TContext3D);
      public
        BarContainer: TBarContainer;
        constructor Create(AOwner: TComponent); override;
    end;

    T3DBarGraph = class(TViewport3D)
      private

      protected

      public
        Stage: TMainContainer;
        constructor Create(AOwner: TComponent); override;
        destructor Destroy; override;
        procedure Add(row, col: Integer; Value: Single);
      published
    end;

implementation

constructor TMainContainer.Create(AOwner: TComponent);
begin
  inherited;
  BarContainer := TBarContainer.Create(Self);
  //OnRender := MainRender;
end;

procedure TMainContainer.MainRender(Sender: TObject; Context: TContext3D);
begin
  Context.DrawCube(TPoint3D.Zero, TPoint3D.Create(Width, Height, Depth), 1, claWhite);
end;

constructor TBarContainer.Create(AOwner: TComponent);
begin
  inherited;
  RowCount := DEFAULT_ROWCOUNT;
  ColCount := DEFAULT_COLCOUNT;
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

  //bar.Position.X := -0.5*DX*GRIDSX + x*DX + 0.5*DX;
  //bar.Position.Y := -0.5*cylinder.Height; // Normaly origin is the center, lets set origin to base
  //bar.Position.Z := -0.5*DX*GRIDSY + y*DY + 0.5*DY;

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
  Stage := TMainContainer.Create(Self);
end;

procedure T3DBarGraph.Add(row, col: Integer; Value: Single);
begin
  Stage.BarContainer.Add(row, col, Value);
end;

destructor T3DBarGraph.Destroy;
begin
  inherited;
end;


end.
