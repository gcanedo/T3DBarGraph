unit U3DBarGraph;

interface
  uses
    FMX.Viewport3D, System.Classes, FMX.Objects3D, Math, System.SysUtils,
    FMX.MaterialSources, System.UIConsts, FMX.Types3D, System.Math.Vectors,
    System.UITypes, FMX.Controls3D, System.Types, FMX.Ani, FMX.Layers3D,
    FMX.Graphics, FMX.Types;

  const
    PANEL_PAD = 0.125;
    WIDTH_LINE_TICK = 0.125;
    GAP_LINE_NUMBER = 0.0625;
    FONT_COLOR_AXIS = claBlack;

    BAR_PAD = 0.25;
    BAR_WIDTH = 0.5;
    BAR_DEPTH = 0.5;
    DEFAULT_ROWCOUNT = 3;
    DEFAULT_COLCOUNT = 4;
    DEFAULT_BACKGROUND_COLOR = claBlack;

    DEFAULT_PLANE_COLOR = claWhite;
    DEFAULT_GRID_COLOR = claRed;
    PLANE_DEPTH = 0.001;
    PLANE_OPACITY = 1;

    DEFAULT_NUMTICKS = 10;
    DEFAULT_ZMIN = -30;
    DEFAULT_ZMAX = 30;

    DURATION_CAMERA_CHANGE_VIEW_PLANE = 0.5;
    SIZE_PANEL_TICKS = 1;

  type
    TMainContainer = class;
    TOnUpdateEvent = procedure of object;

    TBar = class(TCube)

      private
        procedure SetPosition(RowCount, ColCount: Integer);
        procedure MainRender(Sender: TObject; Context: TContext3D);
      public
        row, col: Integer;
        val: Single;
        color: TAlphaColor;
        constructor Create(AOwner: TComponent); override;
    end;

    TBarContainer = class(TDummy)
      private
        procedure SetRowCount(val: Integer);
        procedure SetColCount(val: Integer);
      public
        FOnUpdate: TOnUpdateEvent;
        FRowCount, FColCount: Integer;
        DataMin, DataMax: Single;
        Scale: Single;
        constructor Create(AOwner: TComponent); override;
        procedure Add(row, col: Integer; Value: Single; cl: TAlphaColor = claBlue);
        procedure CreateBar(row, col: Integer; Value: Single; cl: TAlphaColor = claBlue);
        property RowCount: Integer read FRowCount write SetRowCount;
        property ColCount: Integer read FColCount write SetColCount;
        procedure UpdatePositions;
        function IndexOf(row, col: Integer): TBar;
    end;


    TPanelRightTicks = class(TRectangle3D)
        Front: TTextLayer3D;
        Stg: TMainContainer;
        constructor Create(AOwner: TComponent); override;
        procedure Resize;
        procedure FrontPaint(Sender: TObject; Canvas: TCanvas; const ARect: TRectF);
        procedure FrontPaint180(Sender: TObject; Canvas: TCanvas; const ARect: TRectF);
        function  UnitsToPixels(u: Single): Single;
        procedure Positive;
        procedure Negative;
    end;

    TMainContainer = class(TDummy)
        ColorPlane: TColorMaterialSource;
      protected
        procedure MainRender(Sender: TObject; Context: TContext3D);
        procedure XYPlaneRender(Sender: TObject; Context: TContext3D);
        procedure XZPlaneRender(Sender: TObject; Context: TContext3D);
        procedure YZPlaneRender(Sender: TObject; Context: TContext3D);
        procedure CreateXYPlane;
        procedure CreateXZPlane;
        procedure CreateYZPlane;
        procedure CreateBorderPanels(P: TRectangle3D);
        procedure ResizeBordersR(Q: TRectangle3D);
        procedure ResizeBordersL(Q: TRectangle3D);
      public
        XYPlane, XZPlane, YZPlane: TRectangle3D;
        PanelRightTicks: TPanelRightTicks;
        origin: TSphere;
        BarContainer: TBarContainer;
        HalfPlaneHeight: Single;
        NumTicks: Integer;
        constructor Create(AOwner: TComponent); override;
        procedure ResizePlanes;
        procedure PanelPaint(Sender: TObject; Canvas: TCanvas; const ARect: TRectF);
    end;

    T3DBarGraph = class(TViewport3D)
      private
        procedure MouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; var Handled: Boolean);
        procedure MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
        procedure MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
        procedure MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
        procedure InitMouseEvents;

      protected
      public
        Stage: TMainContainer;
        FrontCamera: TCamera;
        status: String;
        Pos3D: TPoint3D;
        PosMouse: TPointF;
        LeftLight, RightLight: TLight;

        constructor Create(AOwner: TComponent); override;
        destructor Destroy; override;
        procedure Add(row, col: Integer; Value: Single; cl: TAlphaColor = claBlue);

        procedure ViewNegativePlane;
        procedure ViewPositivePlane;
        procedure SetStateRotationAngle(ang: TPoint3D);
      published
    end;

implementation

constructor TPanelRightTicks.Create(AOwner: TComponent);
begin
  inherited;
  Stg := AOwner as TMainContainer;
  MaterialBackSource := Stg.ColorPlane;
  MaterialShaftSource := Stg.ColorPlane;
  MaterialSource := Stg.ColorPlane;

  Parent := Stg;
  HitTest := false;
  Opacity := PLANE_OPACITY;

  Front := TTextLayer3D.Create(Self);
  Front.Parent := Self;
  Front.Text := '';
  Front.HitTest := false;
  Front.Resolution := 100;

  Positive;
end;

procedure TPanelRightTicks.Positive;
begin
  Front.OnPaint := FrontPaint;
  Front.RotationAngle.Z := 0;
  Front.Invalidate;
end;

procedure TPanelRightTicks.Negative;
begin
  Front.OnPaint := FrontPaint180;
  Front.RotationAngle.Z := 180;
  Front.Invalidate;
end;

function TPanelRightTicks.UnitsToPixels(u: Single): Single;
begin
  Result := u*Front.Resolution;
end;


procedure TPanelRightTicks.FrontPaint180(Sender: TObject; Canvas: TCanvas; const ARect: TRectF);
var
  Flags: TFillTextFlags;
  R: TRectF;
  TopLeft: TPointF;
  W, H, RefY, RefX, dy, num, DeltaNum, wmax: Single;
  s: String;
  I: Integer;
begin
 // Canvas.Clear(MakeColor(DEFAULT_PLANE_COLOR, PLANE_OPACITY));
  RefY := UnitsToPixels(PANEL_PAD + Stg.XZPlane.Height);
  Canvas.Font.Size := UnitsToPixels(PANEL_PAD);

  dy := Stg.XZPlane.Height/Stg.NumTicks;
  DeltaNum := (DEFAULT_ZMAX - DEFAULT_ZMIN)/Stg.NumTicks;

  num := DEFAULT_ZMIN;
  wmax := 0;
  for I := 0 to Stg.NumTicks do
    begin
      s := FloatToStr(num);
      wmax := Max(wmax, Canvas.TextWidth(s));
      num := num + DeltaNum;
    end;
  num := DEFAULT_ZMAX;
  for I := 0 to Stg.NumTicks do
    begin
      RefX := UnitsToPixels(Front.Width);
      Canvas.Fill.Color := DEFAULT_GRID_COLOR;
      Canvas.Stroke.Color := DEFAULT_GRID_COLOR;
      w := UnitsToPixels(WIDTH_LINE_TICK);
      Canvas.DrawLine(TPointF.Create(RefX, RefY), TPointF.Create(RefX - w, RefY), 1);
      RefX := RefX - w - UnitsToPixels(GAP_LINE_NUMBER);
      s := FloatToStr(num);
      H := Canvas.TextHeight(s);
      Canvas.Fill.Color := FONT_COLOR_AXIS;
      TopLeft.X := RefX - wmax;
      TopLeft.Y := RefY - H/2;
      R := TRectF.Create(TopLeft, wmax, H);
      Canvas.FillText(R, s, FALSE, 1, Flags, TTextAlign.Trailing, TTextAlign.Center);
      RefY := RefY - UnitsToPixels(dy);
      num := num - DeltaNum;
    end;
end;



procedure TPanelRightTicks.FrontPaint(Sender: TObject; Canvas: TCanvas; const ARect: TRectF);
var
  Flags: TFillTextFlags;
  R: TRectF;
  TopLeft: TPointF;
  W, H, RefY, RefX, dy, num, DeltaNum, wmax: Single;
  s: String;
  I: Integer;
begin
 // Canvas.Clear(MakeColor(DEFAULT_PLANE_COLOR, PLANE_OPACITY));
  RefY := UnitsToPixels(PANEL_PAD + Stg.XZPlane.Height);
  Canvas.Font.Size := UnitsToPixels(PANEL_PAD);

  dy := Stg.XZPlane.Height/Stg.NumTicks;
  DeltaNum := (DEFAULT_ZMAX - DEFAULT_ZMIN)/Stg.NumTicks;

  num := DEFAULT_ZMIN;
  wmax := 0;
  for I := 0 to Stg.NumTicks do
    begin
      s := FloatToStr(num);
      wmax := Max(wmax, Canvas.TextWidth(s));
      num := num + DeltaNum;
    end;


  num := DEFAULT_ZMIN;
  for I := 0 to Stg.NumTicks do
    begin
      RefX := 0;
      Canvas.Fill.Color := DEFAULT_GRID_COLOR;
      Canvas.Stroke.Color := DEFAULT_GRID_COLOR;



      w := UnitsToPixels(WIDTH_LINE_TICK);
      Canvas.DrawLine(TPointF.Create(RefX, RefY), TPointF.Create(w, RefY), 1);

      RefX := w + UnitsToPixels(GAP_LINE_NUMBER);

      s := FloatToStr(num);
      H := Canvas.TextHeight(s);

      Canvas.Fill.Color := FONT_COLOR_AXIS;

      TopLeft.X := RefX;
      TopLeft.Y := RefY - H/2;
      R := TRectF.Create(TopLeft, wmax, H);
      Canvas.FillText(R, s, FALSE, 1, Flags, TTextAlign.Trailing, TTextAlign.Center);

      RefY := RefY - UnitsToPixels(dy);
      num := num + DeltaNum;
    end;
end;


procedure TPanelRightTicks.Resize;
begin
  Width := SIZE_PANEL_TICKS;
  Height := Stg.XZPlane.Height + 2*PANEL_PAD;
  Depth := Stg.XZPlane.Depth;
  Position.Point := Stg.XZPlane.Position.Point + TPoint3D.Create(Stg.XZPlane.Width/2 + Width/2, 0, 0);

  Front.Width := Width;
  Front.Height := Height;
  Front.Position.Point := TPoint3D.Create(0, 0, -Depth/2 - 0.001);
end;

constructor TMainContainer.Create(AOwner: TComponent);
begin
  inherited;
  NumTicks := DEFAULT_NUMTICKS;

  ColorPlane := TColorMaterialSource.Create(Self);
  ColorPlane.Color := DEFAULT_PLANE_COLOR;

  BarContainer := TBarContainer.Create(Self);
  BarContainer.Parent := Self;
  BarContainer.FOnUpdate := ResizePlanes;

  origin := TSphere.Create(Self);
  origin.Parent := self;
  origin.Width := 0.1;
  origin.Depth := origin.Width;
  origin.Height := origin.Width;
  origin.Opacity := 0.8;

  origin.Position.X := 0;
  origin.Position.Y := 0;
  origin.Position.Z := 0;

  CreateXZPlane;
  CreateXYPlane;
  CreateYZPlane;

  PanelRightTicks := TPanelRightTicks.Create(Self);

  ResizePlanes;

  XZPlane.OnRender := XZPlaneRender;
  YZPlane.OnRender := YZPlaneRender;
  XYPlane.OnRender := XYPlaneRender;
  OnRender := MainRender;
end;

procedure TMainContainer.ResizePlanes;
begin
  Width := BarContainer.ColCount*(BAR_WIDTH + 2*BAR_PAD);
  Depth := BarContainer.RowCount*(BAR_DEPTH + 2*BAR_PAD);
  HalfPlaneHeight := Max(Width, Depth);
  Height := HalfPlaneHeight;
  BarContainer.Scale := (DEFAULT_ZMAX - DEFAULT_ZMIN)/Height;

  XZPlane.Width := Width;
  XZPlane.Depth := PLANE_DEPTH;
  XZPlane.Height := Height;
  XZPlane.Position.X := 0;
  XZPlane.Position.Y := 0;
  XZPlane.Position.Z := Depth/2 + XZPlane.Depth/2;

  ResizeBordersR(XZPlane);
  PanelRightTicks.Resize;

  YZPlane.Width := PLANE_DEPTH;
  YZPlane.Depth := Depth;
  YZPlane.Height := Height;
  YZPlane.Position.X := -Width/2 - YZPlane.Width/2;
  YZPlane.Position.Y := 0;
  YZPlane.Position.Z := 0;
  ResizeBordersL(YZPlane);

  XYPlane.Width := Width;
  XYPlane.Depth := Depth;
  XYPlane.Height := PLANE_DEPTH;
  XYPlane.Position.X := 0;
  XYPlane.Position.Y := Height/2 + DEFAULT_ZMIN/BarContainer.Scale;
  XYPlane.Position.Z := 0;

  BarContainer.Position.Y := XYPlane.Position.Y;
end;

procedure TMainContainer.ResizeBordersR(Q: TRectangle3D);
var
  P: TTextLayer3D;
begin
  P := Q.FindComponent('TopPanel') as TTextLayer3D;
  P.Width := Q.Width;
  P.Height := PANEL_PAD;
  P.Position.Y := -Q.Height/2 - P.Height/2;

  P := Q.FindComponent('BottomPanel') as TTextLayer3D;
  P.Width := Q.Width;
  P.Height := PANEL_PAD;
  P.Position.Y := Q.Height/2 + P.Height/2;
end;

procedure TMainContainer.ResizeBordersL(Q: TRectangle3D);
var
  P: TTextLayer3D;
begin
  P := Q.FindComponent('TopPanel') as TTextLayer3D;

  P.Width := Q.Depth;
  P.Height := PANEL_PAD;
  P.Position.Y := -Q.Height/2 - P.Height/2;
  P.RotationAngle.Y := 90;

  P := Q.FindComponent('BottomPanel') as TTextLayer3D;
  P.Width := Q.Depth;
  P.Height := PANEL_PAD;
  P.Position.Y := Q.Height/2 + P.Height/2;
  P.RotationAngle.Y := 90;
end;

procedure TMainContainer.CreateYZPlane;
begin
  YZPlane := TRectangle3D.Create(Self);
  YZPlane.MaterialBackSource := ColorPlane;
  YZPlane.MaterialShaftSource := ColorPlane;
  YZPlane.MaterialSource := ColorPlane;
  YZPlane.Parent := Self;
  YZPlane.HitTest := false;
  YZPlane.Opacity := PLANE_OPACITY;

  CreateBorderPanels(YZPlane);
end;

procedure TMainContainer.YZPlaneRender(Sender: TObject; Context: TContext3D);
var
  StartPoint, EndPoint, TopLeft, CenterPoint: TPoint3D;
  WidthBlock, HeightBlock: Single;

procedure DrawGrid(Ref: TPoint3D);
var
  I: Integer;
begin
  for I := 1 to BarContainer.RowCount - 1 do
    begin
      StartPoint := Ref +  TPoint3D.Create(0, 0, WidthBlock*I);
      EndPoint := StartPoint - TPoint3D.Create(0, Height, 0);
      Context.DrawLine(StartPoint, EndPoint, 1, DEFAULT_GRID_COLOR);
    end;


  for I := 1 to NumTicks - 1 do
    begin
      StartPoint := Ref +  TPoint3D.Create(0, -HeightBlock*I, 0);
      EndPoint := StartPoint +  TPoint3D.Create(0, 0, Depth);
      Context.DrawLine(StartPoint, EndPoint, 1, DEFAULT_GRID_COLOR);
    end;

end;


begin
  WidthBlock := BAR_WIDTH + 2*BAR_PAD;
  HeightBlock := YZPlane.Height/NumTicks;

  CenterPoint := TPoint3D.Create(YZPlane.Width/2, YZPlane.Height/2, 0);
  TopLeft := TPoint3D.Create(YZPlane.Width/2, YZPlane.Height/2, -YZPlane.Depth/2);
  DrawGrid(CenterPoint + TopLeft);

  {
  TopLeft := TPoint3D.Create(-XZPlane.Width/2, XZPlane.Height/2, XZPlane.Depth/2);
  DrawGrid(CenterPoint + TopLeft);
  }

  Context.DrawCube(CenterPoint, TPoint3D.Create(YZPlane.Width, YZPlane.Height, YZPlane.Depth), 1, DEFAULT_GRID_COLOR);
end;



procedure TMainContainer.CreateXZPlane;
begin
  XZPlane := TRectangle3D.Create(Self);
  XZPlane.MaterialBackSource := ColorPlane;
  XZPlane.MaterialShaftSource := ColorPlane;
  XZPlane.MaterialSource := ColorPlane;
  XZPlane.Parent := Self;
  XZPlane.HitTest := false;
  XZPlane.Opacity := PLANE_OPACITY;

  CreateBorderPanels(XZPlane);
end;

procedure TMainContainer.CreateBorderPanels(P: TRectangle3D);
var
  Panel: TTextLayer3D;
begin
  Panel := TTextLayer3D.Create(P);
  Panel.Name := 'TopPanel';
  Panel.Parent := P;
  Panel.HitTest := false;
  Panel.OnPaint := PanelPaint;

  Panel := TTextLayer3D.Create(P);
  Panel.Name := 'BottomPanel';
  Panel.Parent := P;
  Panel.HitTest := false;
  Panel.OnPaint := PanelPaint;
end;

procedure  TMainContainer.PanelPaint(Sender: TObject; Canvas: TCanvas; const ARect: TRectF);
begin
  Canvas.Clear(MakeColor(DEFAULT_PLANE_COLOR, PLANE_OPACITY));
end;

procedure TMainContainer.XZPlaneRender(Sender: TObject; Context: TContext3D);
var
  StartPoint, EndPoint, TopLeft, CenterPoint: TPoint3D;
  WidthBlock, HeightBlock: Single;

procedure DrawGrid(Ref: TPoint3D);
var
  I: Integer;
begin
  for I := 1 to BarContainer.ColCount - 1 do
    begin
      StartPoint := Ref +  TPoint3D.Create(WidthBlock*I, 0, 0);
      EndPoint := StartPoint - TPoint3D.Create(0, Height, 0);
      Context.DrawLine(StartPoint, EndPoint, 1, DEFAULT_GRID_COLOR);
    end;

  for I := 1 to NumTicks - 1 do
    begin
      StartPoint := Ref +  TPoint3D.Create(0, -HeightBlock*I, 0);
      EndPoint := StartPoint +  TPoint3D.Create(Width, 0, 0);
      Context.DrawLine(StartPoint, EndPoint, 1, DEFAULT_GRID_COLOR);
    end;
end;


begin
  WidthBlock := BAR_WIDTH + 2*BAR_PAD;
  HeightBlock := XZPlane.Height/NumTicks;

  CenterPoint := TPoint3D.Create(XZPlane.Width/2, XZPlane.Height/2, 0);
  TopLeft := TPoint3D.Create(-XZPlane.Width/2, XZPlane.Height/2, -XZPlane.Depth/2);
  DrawGrid(CenterPoint + TopLeft);

  {
  TopLeft := TPoint3D.Create(-XZPlane.Width/2, XZPlane.Height/2, XZPlane.Depth/2);
  DrawGrid(CenterPoint + TopLeft);
  }

  Context.DrawCube(CenterPoint, TPoint3D.Create(XZPlane.Width, XZPlane.Height, XZPlane.Depth), 1, DEFAULT_GRID_COLOR);
end;


procedure TMainContainer.CreateXYPlane;
begin
  XYPlane := TRectangle3D.Create(Self);
  XYPlane.MaterialBackSource := ColorPlane;
  XYPlane.MaterialShaftSource := ColorPlane;
  XYPlane.MaterialSource := ColorPlane;
  XYPlane.Parent := Self;
  XYPlane.HitTest := false;
  XYPlane.Opacity := PLANE_OPACITY;
end;


procedure TMainContainer.XYPlaneRender(Sender: TObject; Context: TContext3D);
var
  StartPoint, EndPoint, TopLeft, CenterPoint: TPoint3D;
  WidthBlock, DepthBlock: Single;

procedure DrawGrid(Ref: TPoint3D);
var
  I: Integer;
begin
    for I := 1 to BarContainer.ColCount - 1 do
    begin
      StartPoint := Ref +  TPoint3D.Create(WidthBlock*I, 0, 0);
      EndPoint := StartPoint - TPoint3D.Create(0, 0, Depth);
      Context.DrawLine(StartPoint, EndPoint, 1, DEFAULT_GRID_COLOR);
    end;

  for I := 1 to BarContainer.RowCount - 1 do
    begin
      StartPoint := Ref +  TPoint3D.Create(0, 0, -DepthBlock*I);
      EndPoint := StartPoint +  TPoint3D.Create(Width, 0, 0);
      Context.DrawLine(StartPoint, EndPoint, 1, DEFAULT_GRID_COLOR);
    end;

end;


begin
  WidthBlock := BAR_WIDTH + 2*BAR_PAD;
  DepthBlock := BAR_DEPTH + 2*BAR_PAD;

  CenterPoint := TPoint3D.Create(XYPlane.Width/2, XYPlane.Height/2, 0);
  TopLeft := TPoint3D.Create(-XYPlane.Width/2, -XYPlane.Height/2, XYPlane.Depth/2);
  DrawGrid(CenterPoint + TopLeft);
  TopLeft := TPoint3D.Create(-XYPlane.Width/2, XYPlane.Height/2, XYPlane.Depth/2);
  DrawGrid(CenterPoint + TopLeft);

  Context.DrawCube(CenterPoint, TPoint3D.Create(XYPlane.Width, XYPlane.Height, XYPlane.Depth), 1, DEFAULT_GRID_COLOR);
end;

procedure TMainContainer.MainRender(Sender: TObject; Context: TContext3D);
begin
  //Context.DrawCube(TPoint3D.Zero, TPoint3D.Create(Width, Height, Depth), 1, DEFAULT_GRID_COLOR);
end;

constructor TBarContainer.Create(AOwner: TComponent);
begin
  inherited;
  FRowCount := DEFAULT_ROWCOUNT;
  FColCount := DEFAULT_COLCOUNT;
  DataMin := MaxSingle;
  DataMax := MinSingle;
end;

constructor TBar.Create(AOwner: TComponent);
begin
  inherited;

end;

procedure TBar.MainRender(Sender: TObject; Context: TContext3D);
begin
 // Context.DrawCube(TPoint3D.Zero, TPoint3D.Create(Width, Height, Depth), 1, claBlack);
end;

procedure TBar.SetPosition(RowCount, ColCount: Integer);
var
  RefPoint, TopLeft: TPoint3D;
  WB, DB: Single;
  DH: Single;
begin
  WB := BAR_WIDTH + 2*BAR_PAD;
  DB := BAR_DEPTH + 2*BAR_PAD;
  RefPoint := TPoint3D.Create(-ColCount*WB/2, 0, RowCount*DB/2);
  TopLeft := TPoint3D.Create(col*WB, 0, -row*DB);
  if val >= 0 then DH := -Height/2 else DH := Height/2;
  Position.Point := RefPoint + TopLeft + TPoint3D.Create(WB/2, DH, -DB/2);
end;

procedure TBarContainer.UpdatePositions;
var
  I: Integer;
  bar: TBar;
begin
  for I := 0 to ChildrenCount - 1 do
    if Children[I] is TBar then
      begin
        bar := Children[I] as TBar;
        bar.SetPosition(RowCount, ColCount);
      end;
end;

function TBarContainer.IndexOf(row, col: Integer): TBar;
var
  comp: TComponent;
  s: String;
begin
  s := Format('Bar_%d_%d', [row, col]);
  comp := FindComponent(s);
  if (comp <> Nil) and (comp is TBar) then
    Result := comp as TBar
  else
    Result := Nil;
end;

procedure TBarContainer.CreateBar(row, col: Integer; Value: Single; cl: TAlphaColor = claBlue);
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
  bar.color := cl;
  bar.val := value;
  bar.Opacity := 1.0;

  bar.Width := BAR_WIDTH;
  bar.Depth := BAR_DEPTH;
  bar.Height := Abs(Value/Scale);
  bar.SetPosition(RowCount, ColCount);

  mat := TLightMaterialSource.Create(self);
  mat.Shininess := 10;
  mat.Ambient := cl;
  mat.Emissive := cl;
  mat.Specular := cl;

  bar.MaterialSource := mat;
  bar.HitTest := false;
  bar.EndUpdate;
  bar.Repaint;
end;

procedure TBarContainer.SetRowCount(val: Integer);
begin
  if val <> FRowCount then
    begin
      FRowCount := val;
      if Assigned(FOnUpdate) then FOnUpdate;
      UpdatePositions;
    end;
end;

procedure TBarContainer.SetColCount(val: Integer);
begin
  if val <> FColCount then
    begin
      FColCount := val;
      if Assigned(FOnUpdate) then FOnUpdate;
      UpdatePositions;
    end;
end;

procedure TBarContainer.Add(row, col: Integer; Value: Single; cl: TAlphaColor = claBlue);
var
  bar: TBar;
begin
  bar := IndexOf(row, col);
  if (bar <> Nil) and (bar.val <> Value) then
    begin
      bar.val := Value;
      bar.Height := Abs(Value/Scale);
      bar.SetPosition(RowCount, ColCount);
      DataMin := Min(DataMin, value);
      DataMax := Max(DataMax, value);
    end
  else
    begin
      RowCount := Max(RowCount, row + 1);
      ColCount := Max(ColCount, col + 1);
      DataMin := Min(DataMin, value);
      DataMax := Max(DataMax, value);
      CreateBar(row, col, Value, cl);
    end;
end;

procedure T3DBarGraph.ViewNegativePlane;
begin
  Stage.PanelRightTicks.Negative;

  TAnimator.AnimateFloat(FrontCamera, 'RotationAngle.X', 0, DURATION_CAMERA_CHANGE_VIEW_PLANE);
  TAnimator.AnimateFloat(FrontCamera, 'RotationAngle.Y', 0, DURATION_CAMERA_CHANGE_VIEW_PLANE);
  TAnimator.AnimateFloat(FrontCamera, 'RotationAngle.Z', 180, DURATION_CAMERA_CHANGE_VIEW_PLANE);

  TAnimator.AnimateFloat(FrontCamera, 'Position.X', 0, DURATION_CAMERA_CHANGE_VIEW_PLANE);
  TAnimator.AnimateFloat(FrontCamera, 'Position.Y', Stage.Height/2, DURATION_CAMERA_CHANGE_VIEW_PLANE);

  SetStateRotationAngle(TPoint3D.Create(0, 45, 0));
end;

procedure T3DBarGraph.ViewPositivePlane;
begin
  Stage.PanelRightTicks.Positive;

  TAnimator.AnimateFloat(FrontCamera, 'RotationAngle.X', 0, DURATION_CAMERA_CHANGE_VIEW_PLANE);
  TAnimator.AnimateFloat(FrontCamera, 'RotationAngle.Y', 0, DURATION_CAMERA_CHANGE_VIEW_PLANE);
  TAnimator.AnimateFloat(FrontCamera, 'RotationAngle.Z', 0, DURATION_CAMERA_CHANGE_VIEW_PLANE);

  TAnimator.AnimateFloat(FrontCamera, 'Position.X', 0, DURATION_CAMERA_CHANGE_VIEW_PLANE);
  TAnimator.AnimateFloat(FrontCamera, 'Position.Y', -Stage.Height/2, DURATION_CAMERA_CHANGE_VIEW_PLANE);

  SetStateRotationAngle(TPoint3D.Create(0, 45, 0));
end;

procedure T3DBarGraph.SetStateRotationAngle(ang: TPoint3D);
var
  t: Single;
begin
  t := DURATION_CAMERA_CHANGE_VIEW_PLANE/2;

  TAnimator.AnimateFloat(Stage, 'RotationAngle.X', 0, t/2);
  TAnimator.AnimateFloat(Stage, 'RotationAngle.Y', 0, t/2);
  TAnimator.AnimateFloat(Stage, 'RotationAngle.Z', 0, t/2);


  TAnimator.AnimateFloatDelay(Stage, 'RotationAngle.X', ang.X, t, t);
  TAnimator.AnimateFloatDelay(Stage, 'RotationAngle.Y', ang.Y, t, t);
  TAnimator.AnimateFloatDelay(Stage, 'RotationAngle.Z', ang.Z, t, t);
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


  LeftLight := TLight.Create(self);
  LeftLight.LightType := TLightType.Point;
  LeftLight.Parent := Self;
  LeftLight.Position.X := -8;
  LeftLight.Position.Y := 0;
  LeftLight.Position.Z := 0;


  {
  LeftLight.RotationAngle.X := 320;
  LeftLight.RotationAngle.Y := 95;
  LeftLight.RotationAngle.Z := 321;
   }


  RightLight := TLight.Create(self);
  RightLight.LightType := TLightType.Point;
  RightLight.Parent := Self;
  RightLight.Position.X := 8;
  RightLight.Position.Y := 0;
  RightLight.Position.Z := 8;

  {
  LeftLight.RotationAngle.X := 320;
  LeftLight.RotationAngle.Y := 290;
  LeftLight.RotationAngle.Z := 321;
  }

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
      Stage.RotationAngle.X := Pos3D.X + (Y-PosMouse.Y)*0.4;
      Stage.RotationAngle.Y := Pos3D.Y + (PosMouse.X - X)*0.4;
      Stage.RotationAngle.Z := Pos3D.Z - 0.4*((PosMouse.X-X)-(Y-PosMouse.Y));
    end;
end;

procedure T3DBarGraph.MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  if(Status = 'MouseMove') then Status := 'static';
end;

procedure T3DBarGraph.Add(row, col: Integer; Value: Single; cl: TAlphaColor = claBlue);
begin
  Stage.BarContainer.Add(row, col, Value, cl);
end;

destructor T3DBarGraph.Destroy;
begin
  inherited;
end;


end.
