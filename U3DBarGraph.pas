unit U3DBarGraph;

interface
  uses
    FMX.Viewport3D, System.Classes, FMX.Objects3D, Math, System.SysUtils,
    FMX.MaterialSources, System.UIConsts, FMX.Types3D, System.Math.Vectors,
    System.UITypes, FMX.Controls3D, System.Types;

  const
    BAR_PAD = 0.25;
    BAR_WIDTH = 0.5;
    BAR_DEPTH = 0.5;
    DEFAULT_ROWCOUNT = 3;
    DEFAULT_COLCOUNT = 4;
    DEFAULT_BACKGROUND_COLOR = claBlack;

    DEFAULT_PLANE_COLOR = claWhite;
    DEFAULT_GRID_COLOR = claGray;

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
        ColorPlane: TColorMaterialSource;
      protected
        procedure MainRender(Sender: TObject; Context: TContext3D);
        procedure XYPlaneRender(Sender: TObject; Context: TContext3D);
        procedure CreateXYPlane;
      public
        XYPlane: TRectangle3D;
        origin: TSphere;
        BarContainer: TBarContainer;
        HalfPlaneHeight: Single;
        constructor Create(AOwner: TComponent); override;
    end;

    T3DBarGraph = class(TViewport3D)
      private
      protected
        procedure MouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; var Handled: Boolean);
        procedure MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
        procedure MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
        procedure MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
        procedure InitMouseEvents;
      public
        Stage: TMainContainer;
        FrontCamera: TCamera;
        status: String;
        Pos3D: TPoint3D;
        PosMouse: TPointF;

        constructor Create(AOwner: TComponent); override;
        destructor Destroy; override;
        procedure Add(row, col: Integer; Value: Single);
        procedure Plot;
      published
    end;

implementation

constructor TMainContainer.Create(AOwner: TComponent);
begin
  inherited;
  ColorPlane := TColorMaterialSource.Create(Self);
  ColorPlane.Color := DEFAULT_PLANE_COLOR;

  BarContainer := TBarContainer.Create(Self);

  Width := BarContainer.ColCount*(BAR_WIDTH + 2*BAR_PAD);
  Depth := BarContainer.RowCount*(BAR_DEPTH + 2*BAR_PAD);
  HalfPlaneHeight := Max(Width, Depth);
  Height := HalfPlaneHeight;

  origin := TSphere.Create(Self);
  origin.Parent := self;
  origin.Width := 0.01;
  origin.Depth := origin.Width;
  origin.Height := origin.Width;

  origin.Position.X := -Width/2;
  origin.Position.Y := Height/2;
  origin.Position.Z := Depth/2;

  CreateXYPlane;

  OnRender := MainRender;
end;

procedure TMainContainer.CreateXYPlane;
begin
  XYPlane := TRectangle3D.Create(Self);
  XYPlane.Width := Width;
  XYPlane.Depth := Depth;
  XYPlane.Height := 0.001;
  XYPlane.MaterialBackSource := ColorPlane;
  XYPlane.MaterialShaftSource := ColorPlane;
  XYPlane.MaterialSource := ColorPlane;
  XYPlane.Parent := Self;
  XYPlane.HitTest := false;
  XYPlane.OnRender := XYPlaneRender;
end;

procedure TMainContainer.XYPlaneRender(Sender: TObject; Context: TContext3D);
var
  i: Integer;
  StartPoint, EndPoint, RefPoint: TPoint3D;
  WidthBlock, DepthBlock: Single;
begin
  WidthBlock := BAR_WIDTH + 2*BAR_PAD;
  DepthBlock := BAR_DEPTH + 2*BAR_PAD;

  RefPoint := TPoint3D.Create(XYPlane.Width/2, 0, 0) - TPoint3D.Create(Width/2, XYPlane.Height, Depth/2);
  for I := 1 to BarContainer.ColCount - 1 do
    begin
      StartPoint := RefPoint +  TPoint3D.Create(WidthBlock*I, XYPlane.Height/2, 0);
      EndPoint := RefPoint +  TPoint3D.Create(WidthBlock*I, XYPlane.Height/2, Depth);
      Context.DrawLine(StartPoint, EndPoint, 1, DEFAULT_GRID_COLOR);
    end;

  for I := 1 to BarContainer.RowCount - 1 do
    begin
      StartPoint := RefPoint +  TPoint3D.Create(0, XYPlane.Height/2, DepthBlock*I);
      EndPoint := RefPoint +  TPoint3D.Create(Width, XYPlane.Height/2, DepthBlock*I);
      Context.DrawLine(StartPoint, EndPoint, 1, DEFAULT_GRID_COLOR);
    end;


  Context.DrawCube(TPoint3D.Create(XYPlane.Width/2, 0, 0), TPoint3D.Create(XYPlane.Width, XYPlane.Height, XYPlane.Depth), 1, DEFAULT_GRID_COLOR);
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
  status := 'static';
  UsingDesignCamera := False;
  color := DEFAULT_BACKGROUND_COLOR;
  Stage := TMainContainer.Create(Self);
  Stage.Parent := Self;

  FrontCamera := TCamera.Create(self);
  FrontCamera.Parent := Self;
  FrontCamera.Target := Stage;
  FrontCamera.Position.X := 0;
  FrontCamera.Position.Z := -10;
  FrontCamera.Position.Y := -Stage.Height/2;

  Stage.RotationAngle.Y := 45;


  Camera := FrontCamera;
  InitMouseEvents;
end;

procedure T3DBarGraph.InitMouseEvents;
begin
  OnMouseWheel := MouseWheel;
  OnMouseDown := MouseDown;
  OnMouseMove := MouseMove;
  OnMouseUp := MouseUp;
end;

procedure T3DBarGraph.MouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; var Handled: Boolean);
begin
  FrontCamera.Position.Z := FrontCamera.Position.Z + 0.01*WheelDelta;
end;

procedure T3DBarGraph.MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  if Status = 'static' then
    begin
      PosMouse := TPointF.Create(X, Y);
      Pos3D := Stage.RotationAngle.Point;
      status := 'MouseMove';
    end;
end;

procedure T3DBarGraph.MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
begin
  if(Status = 'MouseMove') then
    begin
      //RotationAngle.X := RX + (Y-LY)*0.4;
      Stage.RotationAngle.Y := Pos3D.Y + (PosMouse.X - X)*0.4;
      //RotationAngle.Z := RZ - 0.4*((LX-X)-(Y-LY));
    end;
end;

procedure T3DBarGraph.MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  if(Status = 'MouseMove') then Status := 'static';
end;

procedure T3DBarGraph.Plot;
begin
  //

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
