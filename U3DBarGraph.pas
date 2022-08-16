unit U3DBarGraph;

interface
  uses
    FMX.Viewport3D, System.Classes, FMX.Objects3D, Math, System.SysUtils,
    FMX.MaterialSources, System.UIConsts, FMX.Types3D, System.Math.Vectors,
    System.UITypes, FMX.Controls3D, System.Types, FMX.Ani, FMX.Layers3D,
    FMX.Graphics, FMX.Types, FMX.Objects, FMX.Dialogs, FMX.StdCtrls, FMX.Menus;

  const

    //Sticker Legend Box
    LEGEND_BOX_PAD = 0.05;
    LEGEND_BOX_GAP = 0.02;
    LEGEND_BOX_FONT_SIZE = 0.09;
    LEGEND_BOX_BACKGROUND_COLOR = claWhite;
    LEGEND_BOX_DEPTH = 0.05;
    LEGEND_BOX_HEIGHT_POLE = 0.50;
    LEGEND_BOX_COLOR_POLE = claBlack;
    LEGEND_BACKGROUND_COLOR_STICKER = claYellow;
    LEGEND_FONT_COLOR = claBlack;

    /// AXIS DIMS //////
    SIZE_PANEL_TICKS = 1;
    SIZE_LABEL = 0.3;
    PANEL_PAD = 0.125;
    WIDTH_LINE_TICK = 0.100;
    HEIGHT_LINE_TICK = 0.040;
    GAP_LINE_NUMBER = 0.0625;

    ////BAR PROPERTIES ////
    BAR_SELECTED_DEFAULT_COLOR = claBlue;
    BAR_DEFAULT_COLOR = claRed;
    BAR_PAD = 0.25;
    BAR_WIDTH = 0.5;
    BAR_DEPTH = 0.5;


    ///// XZ and YZ Planes /////
    XZPLANE_YZPLANE_DEFAULT_COLOR = claWhite;
    PLANE_DEPTH = 0.001;
    PLANE_OPACITY = 1;

    ///// XY PLANE  ///////
    XYPLANE_BACKGROUNDCOLOR = claAntiquewhite;

    ///// GENERAL //////
    BARGRAPH_DEFAULT_BACKGROUND_COLOR = claBlack;
    BARGRAPH_DEFAULT_GRID_COLOR = claRed;
    BARGRAPH_FONT_COLOR = claBlack;
    DEFAULT_ROWCOUNT = 3;
    DEFAULT_COLCOUNT = 4;


    //// Z Axis  ///
    ZAXIS_DEFAULT_NUMTICKS = 10;
    AXIS_DEFAULT_ZMAX = 20;
    AXIS_DEFAULT_ZMIN = -20;

    //// GENERAL SETTINGS////////
    ROTATION_STEP = 0.3;
    TRANSLATION_STEP = 0.02;

    DEFAULT_RESOLUTION = 150;
    ZOOM_STEP = 1;
    CAMERA_MAX_Z = 50;
    CAMERA_MIN_Z = -102;

    DURATION_CAMERA_CHANGE_VIEW_PLANE = 0.5;
    STAGE_INITIAL_ROT_ANGLE_Y = 45;
    CAMERA_INITIAL_ROT_ANGLE_X = -10;
    CAMERA_INITIAL_POSITION_Z = -4;

    SHOW_GUIDES = 0;
    SIZE_GUIDES = 0.001;

  type
    TMainContainer = class;

    TMyCamera = class(TDummy)
      public
        MinZ, MaxZ: Single;
        cam: TCamera;
        dir: Integer;
        guide: TSphere;
        constructor Create(AOwner: TComponent); override;
        procedure Init(AMinZ, AMaxZ, IniZ: Single; t: TControl3D);
    end;

    TGlobalData = class(TObject)
      NumTicks: Integer;
      FZMin, FZMax: Single;
      AutoScale: Boolean;
      DataMin, DataMax: Single;
      XYPlaneBackgroundColor: TAlphaColor;
      BarGraphGridColor: TAlphaColor;
      BarGraphFontColor: TAlphaColor;
      XZPlaneYZPlaneBackgroundColor: TAlphaColor;
      BarColor: TAlphaColor;
      BarSelectedColor: TAlphaColor;
      LegendBackgroundColor: TAlphaColor;
      LegendFontColor: TAlphaColor;

      constructor Create;
      function GetZMin: Single;
      procedure SetZMin(val: Single);
      function GetZMax: Single;
      procedure SetZMax(val: Single);
      property ZMin: Single read GetZMin write SetZMin;
      property ZMax: Single read GetZMax write SetZMax;
    end;

    TInfoStr = Array of String;

    TOnUpdateEvent = procedure of object;

    TInfoCell = record
      pos: Integer;
      Text: String;
    end;

    TListBlocks = Array of TInfoCell;
    TInfoAxis = class(TObject)
      blockCount: Integer;
      blocks: TListBlocks;
      public
        dir: Integer;
        constructor Create;
        procedure SetCount(val: Integer);
        procedure Add(pos: Integer; value: String);
        function IndexOf(pos: Integer): Integer;
        property Count: Integer read blockCount write SetCount;
        function Data(pos: Integer): String;
    end;

    TStickerInfo = class(TTextLayer3D)
      public
        info: TInfoStr;
        Dims: TSizeF;
        Stg: TMainContainer;
        procedure Paint(Sender: TObject; Canvas: TCanvas; const ARect: TRectF);
        constructor Create(AOwner: TComponent); override;
        procedure SetInfo(Val: TInfoStr);
        property Data: TInfoStr read info write SetInfo;
        function getDims(Canvas: TCanvas): TSizeF;
        procedure Close;
    end;

    TSign = class(TDummy)
      StickerA, StickerB: TStickerInfo;
      Wood: TRectangle3D;
      Stg: TMainContainer;
      Pack: TMyCamera;
      constructor Create(AOwner: TComponent); override;
    end;


    TBar = class(TCube)
      private
        procedure SetPosition(RowCount, ColCount: Integer);
      public
        row, col: Integer;
        val: Single;
        fcolor: TAlphaColor;
        FIsSelected: Boolean;
        Stg: TMainContainer;
        constructor Create(AOwner: TComponent); override;
        procedure BarRender(Sender: TObject; Context: TContext3D);
        destructor Destroy; override;
        procedure SetIsSelected(val: Boolean);
        function GetIsSelected: Boolean;
        procedure SetColor(val: TAlphaColor);
        property color: TAlphaColor write SetColor;
        property isSelected: Boolean read GetIsSelected write SetIsSelected;
    end;

    TLegend3D = class(TDummy)
      Sign: TSign;
      Pole: TCylinder;
      bar: TBar;
      Stg: TMainContainer;

      procedure SetData(val: TInfoStr);
      procedure Invalidate;
      constructor Create(AOwner: TComponent); override;
      property Data: TInfoStr write SetData;

    end;


    TBarContainer = class(TDummy)
      private
        procedure SetRowCount(val: Integer);
        procedure SetColCount(val: Integer);
      public
        FOnUpdate: TOnUpdateEvent;
        FRowCount, FColCount: Integer;


        Legend: TLegend3D;
        Stg: TMainContainer;
        procedure UnSelected(ExceptBar: TBar = Nil);
        procedure BarClick(Sender: TObject);
        procedure LegendClick(Sender: TObject);
        procedure BarMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single; RayPos, RayDir: TVector3D);
        procedure BarMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single; RayPos, RayDir: TVector3D);
        procedure BarMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single; RayPos, RayDir: TVector3D);
        procedure RotateLegend;
        constructor Create(AOwner: TComponent); override;
        procedure Add(row, col: Integer; Value: Single; cl: TAlphaColor = claBlue);
        procedure CreateBar(row, col: Integer; Value: Single; cl: TAlphaColor = claBlue);
        property RowCount: Integer read FRowCount write SetRowCount;
        property ColCount: Integer read FColCount write SetColCount;
        procedure UpdatePositions;
        function IndexOf(row, col: Integer): TBar;
    end;

    TSticker = class(TTextLayer3D)
      private
        info: TInfoAxis;
      public
        Stg: TMainContainer;
        procedure Paint(Sender: TObject; Canvas: TCanvas; const ARect: TRectF);
        procedure PaintR(Sender: TObject; Canvas: TCanvas; const ARect: TRectF);
        constructor Create(AOwner: TComponent); override;
        procedure SetInfo(Val: TInfoAxis);
        property Data: TInfoAxis read info write SetInfo;
    end;

    TGroupSticker = class(TDummy)
      public
        Sticker: TSticker;
        Lb: TTextLayer3D;
        Stg: TMainContainer;
        constructor Create(AOwner: TComponent); override;
        procedure Resize;
        procedure Invalidate;
    end;

    TAxisYPanel = class(TDummy)
      public
        TopSticker, BottomSticker: TGroupSticker;
        Base: TRectangle3D;
        Stg: TMainContainer;
        constructor Create(AOwner: TComponent); override;
        procedure Resize;
    end;

    TAxisXPanel = class(TDummy)
      public
        TopSticker, BottomSticker: TGroupSticker;
        Base: TRectangle3D;
        Stg: TMainContainer;
        constructor Create(AOwner: TComponent); override;
        procedure Resize;
    end;


    TPanelTicks = class(TRectangle3D)
      public
        Front, ZLabelTop, ZLabelBottom: TTextLayer3D;
        Stg: TMainContainer;
        StartNum: TPointF;
        constructor Create(AOwner: TComponent); override;
        procedure SetPosition(RefPlane: TRectangle3D);
        procedure SetPositionLeft(RefPlane: TRectangle3D);
        procedure FrontPaint(Sender: TObject; Canvas: TCanvas; const ARect: TRectF);
        procedure FrontPaint180(Sender: TObject; Canvas: TCanvas; const ARect: TRectF);
        function  UnitsToPixels(u: Single): Single;
        procedure ShowPositiveSpace;
        procedure ShowNegativeSpace;
        function GetWidthMax(c: TCanvas): Single;
        procedure tempPaint(Sender: TObject; Canvas: TCanvas; const ARect: TRectF);
        procedure UpdateLabels;
        procedure Invalidate;
    end;

    TMainContainer = class(TDummy)
      private
        ColorPlane, ColorPlaneXY: TColorMaterialSource;
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

        procedure SetColor;
      public
        FGlobal: TGlobalData;

        XYPlane, XZPlane, YZPlane: TRectangle3D;
        PanelRightTicks, PanelLeftTicks: TPanelTicks;
        BarContainer: TBarContainer;
        HalfPlaneHeight: Single;

        FZLabel: String;

        DataYAxis: TInfoAxis;
        DataXAxis: TInfoAxis;

        AxisYPanel: TAxisYPanel;
        AxisXPanel: TAxisXPanel;

        Corner : TRectangle3D;
        //Guia: TSphere;
        Boss: TObject;

        constructor Create(AOwner: TComponent); override;
        destructor Destroy; override;
        procedure ResizePlanes;
        procedure Invalidate;
        function GetScale: Single;


        procedure PanelPaint(Sender: TObject; Canvas: TCanvas; const ARect: TRectF);
        function RequestData(b: Tbar): TInfoStr;


        function GetGlobalData: TGlobalData;
        property global: TGlobalData read GetGlobalData;


        property Scale: Single read GetScale;

    end;

    TBarGraph = class(TViewport3D)
      private
        dir: Integer;
        FDown: TPointF;
        PopupMenu: TPopupMenu;

        function GetZMin: Single;
        procedure SetZMin(val: Single);
        function GetZMax: Single;
        procedure SetZMax(val: Single);
        function GetNumTicks: Integer;
        procedure SetNumTicks(val: Integer);

        function GetAutoScale: Boolean;
        procedure SetAutoScale(val: Boolean);

        procedure DoZoom(aIn: Boolean);
        procedure MouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; var Handled: Boolean);
        procedure MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
        procedure MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
        procedure MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
        procedure ViewportClick(Sender: TObject);
        procedure InitMouseEvents;
        procedure SetPositionLights;

        procedure SetZLabel(val: String);
        function GetZLabel: String;

        procedure SetYLabel(val: String);
        function GetYLabel: String;

        procedure SetXLabel(val: String);
        function GetXLabel: String;

      protected
      public
        globalVars: TGlobalData;
        Stage: TMainContainer;
        status: String;
        Pos3D: TPoint3D;
        PosMouse: TPointF;
        LeftLight, RightLight: TLight;
        MainCamera: TMyCamera;
        Guide: TSphere;
        zpos: Single;

        constructor Create(AOwner: TComponent); override;
        destructor Destroy; override;
        procedure Invalidate;
        procedure Add(row, col: Integer; Value: Single; cl: TAlphaColor = 0);

        procedure ViewNegativePlane;
        procedure ViewPositivePlane;
        procedure SetStateRotationAngle(ang: TPoint3D);

        function GetBackgroundColor: TAlphaColor;
        procedure SetBackgroundColor(val: TAlphaColor);

        function GetXYPlaneColor: TAlphaColor;
        procedure SetXYPlaneColor(val: TAlphaColor);

        function GetXZandYZPlaneColor: TAlphaColor;
        procedure SetXZandYZPlaneColor(val: TAlphaColor);


        function GetGridColor: TAlphaColor;
        procedure SetGridColor(val: TAlphaColor);

        function GetBarGraphFontColor: TAlphaColor;
        procedure SetBarGraphFontColor(val: TAlphaColor);

        function GetBarColor: TAlphaColor;
        procedure SetBarColor(val: TAlphaColor);

        function GetBarSelectedColor: TAlphaColor;
        procedure SetBarSelectedColor(val: TAlphaColor);

        function GetLegendBackgroundColor: TAlphaColor;
        procedure SetLegendBackgroundColor(val: TAlphaColor);

        function GetLegendFontColor: TAlphaColor;
        procedure SetLegendFontColor(val: TAlphaColor);


        procedure AddYLabel(row: Integer; val: String);
        procedure AddXLabel(col: Integer; val: String);

        procedure SetInitialValues;
        function getZ: Single;
        procedure Reset;



        property ZLabel: String read GetZLabel write SetZLabel;
        property YLabel: String read GetYLabel write SetYLabel;
        property XLabel: String read GetXLabel write SetXLabel;





      published

        property BackgroundColor: TAlphaColor read GetBackgroundColor write SetBackgroundColor;
        property AutoScale: Boolean read GetAutoScale write SetAutoScale;
        property NumTicks: Integer read GetNumTicks write SetNumTicks;

        property BarSelectedColor: TAlphaColor read GetBarSelectedColor write SetBarSelectedColor;
        property BarColor: TAlphaColor read GetBarColor write SetBarColor;

        property ZMin: Single read GetZMin write SetZMin;
        property ZMax: Single read GetZMax write SetZMax;
        property GridColor: TAlphaColor read GetGridColor write SetGridColor;
        property XYPlaneColor: TAlphaColor read GetXYPlaneColor write SetXYPlaneColor;
        property FontColor: TAlphaColor read GetBarGraphFontColor write SetBarGraphFontColor;
        property XZandYZPlaneColor: TAlphaColor read GetXZandYZPlaneColor write SetXZandYZPlaneColor;
        property LegendFontColor: TAlphaColor read GetLegendFontColor write SetLegendFontColor;
        property LegendBackgroundColor: TAlphaColor read GetLegendBackgroundColor write SetLegendBackgroundColor;



    end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('UofW', [TBarGraph]);
end;

function NiceNum(val: Single):String;
begin
  Result := Format('%.2f', [val]);
  Result := Format('%g', [StrToFloat(Result)]);
end;

constructor TGlobalData.Create;
begin
  LegendFontColor := LEGEND_FONT_COLOR;
  LegendBackgroundColor := LEGEND_BACKGROUND_COLOR_STICKER;
  BarColor := BAR_DEFAULT_COLOR;
  BarSelectedColor := BAR_SELECTED_DEFAULT_COLOR;

  XYPlaneBackgroundColor := XYPLANE_BACKGROUNDCOLOR;
  XZPlaneYZPlaneBackgroundColor := XZPLANE_YZPLANE_DEFAULT_COLOR;

  BarGraphGridColor := BARGRAPH_DEFAULT_GRID_COLOR;
  BarGraphFontColor := BARGRAPH_FONT_COLOR;

  DataMin := MaxSingle;
  DataMax := MinSingle;
  FZMin := AXIS_DEFAULT_ZMIN;
  FZMax := AXIS_DEFAULT_ZMAX;
  NumTicks := ZAXIS_DEFAULT_NUMTICKS;
  AutoScale := false;
end;

function TGlobalData.GetZMin: Single;
begin
  if (AutoScale) and (DataMin <> MaxSingle) then
    Result := DataMin
  else
    Result := FZMin;
end;

procedure TGlobalData.SetZMin(val: Single);
begin
  if val <> FZMin then FZMin := val;
end;

function TGlobalData.GetZMax: Single;
begin
  if (AutoScale) and (DataMax <> MinSingle) then
    Result := DataMax
  else
    Result := FZMax;
end;

procedure TGlobalData.SetZMax(val: Single);
begin
  if val <> FZMax then FZMax := val;
end;

procedure TLegend3D.Invalidate;
begin
  Sign.StickerA.Invalidate;
  Sign.StickerB.Invalidate;
end;

constructor TLegend3D.Create(AOwner: TComponent);
var
  clMat: TColorMaterialSource;
begin
  inherited;
  Stg := (AOwner as TBarContainer).Stg;

  Sign := TSign.Create(Self);
  Sign.Parent := Self;
  Pole := TCylinder.Create(Self);
  Pole.Parent := Self;
  Pole.Height := LEGEND_BOX_HEIGHT_POLE;
  Pole.Width := LEGEND_BOX_DEPTH;
  Pole.Depth := LEGEND_BOX_DEPTH;
  clMat := TColorMaterialSource.Create(Self);
  clMat.Color := LEGEND_BOX_COLOR_POLE;
  Pole.MaterialSource := clMat;
  Pole.HitTest := false;
  Pole.Position.Y := -Pole.Height/2;
end;

procedure TLegend3D.SetData(val: TInfoStr);
begin
  Sign.StickerA.Data := val;
  Sign.StickerB.Data := val;
  Sign.Wood.Width := Sign.StickerA.Width;
  Sign.Wood.Height := Sign.StickerA.Height;
  Sign.Position.Point := Pole.Position.Point + TPoint3D.Create(0, -Pole.Height/2 - Sign.Wood.Height/2, 0);
end;

constructor TSign.Create(AOwner: TComponent);
var
  colorMat: TColorMaterialSource;
begin
  inherited;
  Stg := (AOwner as TLegend3D).Stg;


  Wood := TRectangle3D.Create(Self);
  Wood.Parent := Self;
  Wood.HitTest := False;
  colorMat := TColorMaterialSource.Create(self);
  colorMat.Color := LEGEND_BOX_BACKGROUND_COLOR;


  Wood.MaterialBackSource := colorMat;
  Wood.MaterialShaftSource := colorMat;
  Wood.MaterialSource := colorMat;
  Wood.Depth := LEGEND_BOX_DEPTH;

  StickerA := TStickerInfo.Create(Self);
  StickerA.Parent := Self;
  StickerA.Position.Z := Wood.Depth/2 + 0.001;

  StickerB := TStickerInfo.Create(Self);
  StickerB.Parent := Self;
  StickerB.Position.Z := -StickerA.Position.Z;

  StickerA.HitTest := true;
  StickerA.AutoCapture := true;

  StickerB.HitTest := true;
  StickerB.AutoCapture := true;


  Pack := TMyCamera.Create(self);
  Pack.Init(7.8, 20, 9.8, self);
  Pack.dir := -1;
  Pack.Parent := Self;
end;

procedure TStickerInfo.SetInfo(Val: TInfoStr);
begin
  info := Val;
  Dims := getDims(Canvas);
  Width := 2*LEGEND_BOX_PAD + Dims.Width/Resolution;
  Height := 2*LEGEND_BOX_PAD + Dims.Height/Resolution + LEGEND_BOX_GAP*(length(info) - 1);
  OnPaint := Paint;
end;

procedure TStickerInfo.Close;
begin
  Width := 0;
  Height := 0;
  OnPaint := Nil;
end;

procedure TStickerInfo.Paint(Sender: TObject; Canvas: TCanvas; const ARect: TRectF);
var
  I: Integer;
  TopLeft: TPointF;
  R: TRectF;
  Flags: TFillTextFlags;
  H: Single;
begin
  Canvas.Clear(Stg.global.LegendBackgroundColor);

  Canvas.Font.Size := LEGEND_BOX_FONT_SIZE*Resolution;
  TopLeft := TPointF.Create(LEGEND_BOX_PAD, LEGEND_BOX_PAD)*Resolution;
  for I := 0 to length(info) - 1 do
    begin
      H := Canvas.TextHeight(info[I]);
      R := TRectF.Create(TopLeft, Dims.Width, H);
      Canvas.Fill.Color := Stg.global.LegendFontColor;
      Canvas.FillText(R, info[I], false, 1, Flags, TTextAlign.Leading, TTextAlign.Center);
      TopLeft := TopLeft + TPointF.Create(0, H + LEGEND_BOX_GAP*Resolution);
    end;
end;

constructor TStickerInfo.Create(AOwner: TComponent);
begin
  inherited;
  Stg := (AOwner as TSign).Stg;
  DeleteChildren;
  HitTest := true;
  AutoCapture := true;
  Resolution := DEFAULT_RESOLUTION;
end;

function TStickerInfo.getDims(Canvas: TCanvas): TSizeF;
var
  I: Integer;
begin
  Result := TSizeF.Create(0, 0);
  Canvas.Font.Size := LEGEND_BOX_FONT_SIZE*Resolution;
  for I := 0 to length(info) - 1 do
    begin
      Result.Width := Max(Result.Width, Canvas.TextWidth(info[I]));
      Result.Height := Result.Height + Canvas.TextHeight(info[I]);
    end;
end;

constructor TInfoAxis.Create;
begin
  inherited;
  blocks := [];
  blockCount := 0;
  dir := 1;
end;

procedure TInfoAxis.SetCount(val: Integer);
begin
  blockCount := Max(blockCount, val);
end;

procedure TInfoAxis.Add(pos: Integer; value: String);
var
  k: Integer;
  b: TInfoCell;
begin
  k := IndexOf(pos);
  if k <> -1 then
     blocks[k].Text := value
  else
    begin
      b.pos := pos;
      b.Text := value;
      blocks := blocks + [b];
      Count := Pos + 1;
    end;
end;

function TInfoAxis.IndexOf(pos: Integer): Integer;
var
  I: Integer;
begin
  for I := 0 to length(blocks) - 1 do
    if blocks[I].pos = pos then Exit(I);
  Result := -1;
end;

function TInfoAxis.Data(pos: Integer): String;
var
  k: Integer;
begin
  k := IndexOf(pos);
  if k <> -1 then
    Result := blocks[k].Text
  else
    Result := '';
end;

constructor TAxisXPanel.Create(AOwner: TComponent);
var
  ColorPlane: TColorMaterialSource;
begin
  inherited;
  Stg := AOwner as TMainContainer;
  tag := -1;
  TopSticker := TGroupSticker.Create(Self);
  TopSticker.RotationAngle.X := 90;
  TopSticker.RotationAngle.Z := -90;
  TopSticker.Sticker.RotationAngle.Y := 180;
  TopSticker.Lb.RotationAngle.Y := 180;

  TopSticker.Parent := Self;
  Width := TopSticker.Width;

  Base := TRectangle3D.Create(Self);
  Base.Width := TopSticker.Width;
  Base.Parent := Self;
  ColorPlane := TColorMaterialSource.Create(Self);
  ColorPlane.Color := MakeColor(Stg.global.XYPlaneBackgroundColor, PLANE_OPACITY);



  Base.MaterialBackSource := ColorPlane;
  Base.MaterialShaftSource := ColorPlane;
  Base.MaterialSource := ColorPlane;
  Base.HitTest := false;
  Base.Opacity := PLANE_OPACITY;


  tag := 1;
  BottomSticker := TGroupSticker.Create(Self);
  BottomSticker.RotationAngle.X := 90;
  BottomSticker.RotationAngle.Z := -90;
  BottomSticker.Sticker.RotationAngle.Y := 0;
  BottomSticker.Lb.RotationAngle.Y := 0;
  BottomSticker.Parent := Self;
end;

procedure TAxisXPanel.Resize;
begin
  Base.Height := Height;
  Base.Depth := Depth;
  Base.Width := Width;
  TopSticker.Height := Width;
  TopSticker.Position.Y := -Height/2 - 0.001;
  TopSticker.Resize;
  BottomSticker.Height := Width;
  BottomSticker.Position.Y := Height/2 + 0.001;
  BottomSticker.Resize;
end;

constructor TAxisYPanel.Create(AOwner: TComponent);
var
  ColorPlane: TColorMaterialSource;
begin
  inherited;
  Stg := AOwner as TMainContainer;
  tag := 1;
  TopSticker := TGroupSticker.Create(Self);
  TopSticker.RotationAngle.X := -90;
  TopSticker.Parent := Self;
  Width := TopSticker.Width;

  Base := TRectangle3D.Create(Self);
  Base.Width := TopSticker.Width;
  Base.Parent := Self;
  ColorPlane := TColorMaterialSource.Create(Self);
  ColorPlane.Color := MakeColor(Stg.global.XYPlaneBackgroundColor, 1);

  Base.MaterialBackSource := ColorPlane;
  Base.MaterialShaftSource := ColorPlane;
  Base.MaterialSource := ColorPlane;
  Base.HitTest := false;
  Base.Opacity := 0;//PLANE_OPACITY;

  tag := -1;
  BottomSticker := TGroupSticker.Create(Self);
  BottomSticker.RotationAngle.X := -90;
  BottomSticker.Sticker.RotationAngle.Y := 180;
  BottomSticker.Lb.RotationAngle.Y := 180;
  BottomSticker.Parent := Self;
end;

procedure TAxisYPanel.Resize;
begin
  Base.Height := Height;
  Base.Depth := Depth;

  TopSticker.Height := Depth;
  TopSticker.Position.Y := -Height/2 - 0.001;
  TopSticker.Resize;

  BottomSticker.Height := Depth;
  BottomSticker.Position.Y := Height/2 + 0.001;
  BottomSticker.Resize;
end;

procedure TGroupSticker.Invalidate;
begin
  Lb.Fill.Color := MakeColor(Stg.global.XYPlaneBackgroundColor, PLANE_OPACITY);
  Lb.Color := Stg.global.BarGraphFontColor;
end;

constructor TGroupSticker.Create(AOwner: TComponent);
begin
  inherited;
  Stg := (AOwner as TFMXObject).Owner as TMainContainer;

  Tag := AOwner.Tag;
  Width := SIZE_PANEL_TICKS;

  Lb := TTextLayer3D.Create(Self);
  Lb.Text := '';
  Lb.Height := SIZE_LABEL;
  Lb.Parent := Self;
  Lb.HitTest := false;
  (Lb.Children[0] as TText).HitTest := false;


  Lb.Resolution := DEFAULT_RESOLUTION;
  Lb.RotationAngle.Z := -90;
  Lb.Color := Stg.global.BarGraphFontColor;
  Lb.Fill.Kind := TBrushKind.Solid;
  Lb.Fill.Color := MakeColor(Stg.global.XYPlaneBackgroundColor, PLANE_OPACITY);

  Lb.Font.Size := Lb.Resolution*PANEL_PAD;
  Lb.Position.X := Width/2 - Lb.Height/2;

  Sticker := TSticker.Create(Self);
  Sticker.Width := Width - SIZE_LABEL;
  Sticker.Parent := Self;
  Sticker.Position.X := -Width/2 + Sticker.Width/2;
  Sticker.HitTest := false;

  HitTest := false;

end;

procedure TGroupSticker.Resize;
begin
  Lb.Width := Height;
  Lb.Invalidate;
  Sticker.Height := Height;
  Sticker.Invalidate;
end;

procedure TSticker.SetInfo(val: TInfoAxis);
begin
  info := val;
  if tag = 1 then
    OnPaint := Paint
  else
    OnPaint := PaintR;
end;

procedure TSticker.Paint(Sender: TObject; Canvas: TCanvas; const ARect: TRectF);
var
  PxHeightBlock, xRef, yRef, PxWidthBlock: Single;
  I: Integer;
  tickSizePx, TopLeft: TPointF;
  R: TRectF;
  b: TInfoCell;
  Flags: TFillTextFlags;
begin
  Canvas.Clear(MakeColor(Stg.global.XYPlaneBackgroundColor, PLANE_OPACITY));
  Canvas.Font.Size := (0.1*Resolution);

  PxHeightBlock := ARect.Height/info.blockCount;
  tickSizePx := TPointF.Create(WIDTH_LINE_TICK, HEIGHT_LINE_TICK)*Resolution;
  Canvas.Fill.Color := Stg.global.BarGraphGridColor;

  for I := 0 to info.BlockCount - 1 do
    begin
      yRef :=  PxHeightBlock*I;
      TopLeft := TPointF.Create(0, yRef + (PxHeightBlock - tickSizePx.Y)/2);
      R := TRectF.Create(TopLeft, tickSizePx.X, tickSizePx.Y);
      Canvas.FillRect(R, 1);
    end;

  xRef := tickSizePx.X + GAP_LINE_NUMBER*Resolution;
  PxWidthBlock := ARect.Width - xRef;
  Canvas.Fill.Color := Stg.global.BarGraphFontColor;
  for I := 0 to length(info.blocks) - 1 do
    begin
      b := info.blocks[I];
      yRef :=  PxHeightBlock*b.pos;
      TopLeft.X := xRef;
      TopLeft.Y := yRef;
      R := TRectF.Create(TopLeft, PxWidthBlock, PxHeightBlock);
      Canvas.FillText(R, b.Text, True, 1, Flags, TTextAlign.Leading, TTextAlign.Center);
    end;
end;

procedure TSticker.PaintR(Sender: TObject; Canvas: TCanvas; const ARect: TRectF);
var
  PxHeightBlock, xRef, yRef, PxWidthBlock: Single;
  I: Integer;
  tickSizePx, TopLeft: TPointF;
  R: TRectF;
  b: TInfoCell;
  Flags: TFillTextFlags;
begin

  Canvas.Clear(MakeColor(Stg.global.XYPlaneBackgroundColor, PLANE_OPACITY));
  Canvas.Font.Size := (0.1*Resolution);

  PxHeightBlock := ARect.Height/info.blockCount;
  tickSizePx := TPointF.Create(WIDTH_LINE_TICK, HEIGHT_LINE_TICK)*Resolution;
  Canvas.Fill.Color := Stg.global.BarGraphGridColor;
  xRef := ARect.Width - tickSizePx.X;
  for I := 0 to info.BlockCount - 1 do
    begin
      yRef :=  PxHeightBlock*I;
      TopLeft := TPointF.Create(xRef, yRef + (PxHeightBlock - tickSizePx.Y)/2);
      R := TRectF.Create(TopLeft, tickSizePx.X, tickSizePx.Y);
      Canvas.FillRect(R, 1);
    end;

  xRef := 0;
  PxWidthBlock := ARect.Width - tickSizePx.X - GAP_LINE_NUMBER*Resolution;
  Canvas.Fill.Color := Stg.global.BarGraphFontColor;
  for I := 0 to length(info.blocks) - 1 do
    begin
      b := info.blocks[I];
      yRef :=  PxHeightBlock*b.pos;
      TopLeft.X := xRef;
      TopLeft.Y := yRef;
      R := TRectF.Create(TopLeft, PxWidthBlock, PxHeightBlock);
      Canvas.FillText(R, b.Text, True, 1, Flags, TTextAlign.Trailing, TTextAlign.Center);
    end;
end;

constructor TSticker.Create(AOwner: TComponent);
begin
  inherited;
  Stg := (AOwner as TGroupSticker).Stg;
  (Children[0] as TText).HitTest := false;
  tag := AOwner.Tag;
  HitTest := false;
  Resolution := DEFAULT_RESOLUTION;
end;

constructor TPanelTicks.Create(AOwner: TComponent);
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
  Front.DeleteChildren;
  Front.Resolution := DEFAULT_RESOLUTION;

  ZLabelTop := TTextLayer3D.Create(Self);
  ZLabelTop.Parent := Self;
  ZLabelTop.Text := Stg.FZLabel;
  ZLabelTop.HitTest := false;
  ZLabelTop.Resolution := DEFAULT_RESOLUTION;
  ZLabelTop.RotationAngle.Z := -90;
  (ZLabelTop.Children[0] as TText).HitTest := false;


  ZlabelTop.Color := Stg.global.BarGraphFontColor;
  ZlabelTop.Font.Size := ZLabelTop.Resolution*PANEL_PAD;


  ZLabelBottom := TTextLayer3D.Create(Self);
  ZLabelBottom.Parent := Self;
  ZLabelBottom.Text := Stg.FZLabel;
  ZLabelBottom.HitTest := false;
  (ZLabelBottom.Children[0] as TText).HitTest := false;

  ZLabelBottom.Resolution := DEFAULT_RESOLUTION;
  ZLabelBottom.RotationAngle.Z := -90;
  ZlabelBottom.Color := Stg.global.BarGraphFontColor;
  ZlabelBottom.Font.Size := ZLabelBottom.Resolution*PANEL_PAD;
end;

procedure TPanelTicks.ShowPositiveSpace;
begin

  StartNum.X := Stg.global.ZMin;
  StartNum.Y := 1;

  if tag = 1 then
    begin
      Front.OnPaint := FrontPaint;
      Front.RotationAngle.Z := 0;
    end
  else
    begin
      Front.OnPaint := FrontPaint180;
      Front.RotationAngle.Z := 0;
    end;

  Front.Invalidate;
end;

procedure TPanelTicks.ShowNegativeSpace;
begin
  StartNum.X := Stg.global.ZMax;
  StartNum.Y := -1;

  if tag = 1 then
    begin
      Front.OnPaint := FrontPaint180;
      Front.RotationAngle.Z := 180;
    end
  else
    begin
      Front.OnPaint := FrontPaint;
      Front.RotationAngle.Z := 180;
    end;

  Front.Invalidate;
end;

function TPanelTicks.UnitsToPixels(u: Single): Single;
begin
  Result := u*Front.Resolution;
end;

function TPanelTicks.GetWidthMax(C: TCanvas): Single;
var
  num, DeltaNum: Single;
  s: String;
  I: Integer;
begin
  DeltaNum := (Stg.global.ZMax - Stg.global.ZMin)/Stg.global.NumTicks;
  num := Stg.global.ZMin;

  Result := 0;
  for I := 0 to Stg.global.NumTicks do
    begin
      s := NiceNum(num);
      Result := Max(Result, C.TextWidth(s));
      num := num + DeltaNum;
    end;
end;

procedure TPanelTicks.FrontPaint180(Sender: TObject; Canvas: TCanvas; const ARect: TRectF);
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

  dy := Stg.XZPlane.Height/Stg.global.NumTicks;
  DeltaNum := (Stg.global.ZMax - Stg.global.ZMin)/Stg.global.NumTicks;
  wmax := GetWidthMax(Canvas);

  num := StartNum.X;
  for I := 0 to Stg.global.NumTicks do
    begin
      RefX := ARect.Width;

      Canvas.Fill.Color := Stg.global.BarGraphGridColor;
      Canvas.Stroke.Color := Stg.global.BarGraphGridColor;
      w := UnitsToPixels(WIDTH_LINE_TICK);
      Canvas.DrawLine(TPointF.Create(RefX, RefY), TPointF.Create(RefX - w, RefY), 1);
      RefX := RefX - w - UnitsToPixels(GAP_LINE_NUMBER);
      s := NiceNum(num);

      H := Canvas.TextHeight(s);
      Canvas.Fill.Color := Stg.global.BarGraphFontColor;
      TopLeft.X := RefX - wmax;
      TopLeft.Y := RefY - H/2;
      R := TRectF.Create(TopLeft, wmax, H);
      Canvas.FillText(R, s, FALSE, 1, Flags, TTextAlign.Trailing, TTextAlign.Center);
      RefY := RefY - UnitsToPixels(dy);
      num := num + StartNum.Y*DeltaNum;
    end;
end;

procedure TPanelTicks.tempPaint(Sender: TObject; Canvas: TCanvas; const ARect: TRectF);
begin
   Canvas.Clear(claBlue);
end;

procedure TPanelTicks.FrontPaint(Sender: TObject; Canvas: TCanvas; const ARect: TRectF);
var
  Flags: TFillTextFlags;
  R: TRectF;
  TopLeft: TPointF;
  W, H, RefY, RefX, dy, num, DeltaNum, wmax: Single;
  s: String;
  I: Integer;
begin
  //Canvas.Clear(claYellow);

  RefY := UnitsToPixels(PANEL_PAD + Stg.XZPlane.Height);
  Canvas.Font.Size := UnitsToPixels(PANEL_PAD);
  dy := Stg.XZPlane.Height/Stg.global.NumTicks;
  DeltaNum := (Stg.global.ZMax - Stg.global.ZMin)/Stg.global.NumTicks;
  wmax := GetWidthMax(Canvas);

  num := StartNum.X;
  for I := 0 to Stg.global.NumTicks do
    begin
      RefX := 0;
      Canvas.Fill.Color := Stg.global.BarGraphGridColor;
      Canvas.Stroke.Color := Stg.global.BarGraphGridColor;
      w := UnitsToPixels(WIDTH_LINE_TICK);
      Canvas.DrawLine(TPointF.Create(RefX, RefY), TPointF.Create(w, RefY), 1);
      RefX := w + UnitsToPixels(GAP_LINE_NUMBER);
      s := NiceNum(num);
      H := Canvas.TextHeight(s);
      Canvas.Fill.Color := Stg.global.BarGraphFontColor;
      TopLeft.X := RefX;
      TopLeft.Y := RefY - H/2;
      R := TRectF.Create(TopLeft, wmax, H);
      Canvas.FillText(R, s, FALSE, 1, Flags, TTextAlign.Trailing, TTextAlign.Center);
      RefY := RefY - UnitsToPixels(dy);
      num := num + StartNum.Y*DeltaNum;
    end;
end;

procedure TPanelTicks.Invalidate;
begin
  UpdateLabels;
  ZlabelTop.Color := Stg.global.BarGraphFontColor;
  ZlabelBottom.Color := Stg.global.BarGraphFontColor;
end;

procedure TPanelTicks.UpdateLabels;
begin
  ZLabelTop.Text := Stg.FZLabel;
  ZLabelBottom.Text := Stg.FZLabel;
end;

procedure TPanelTicks.SetPosition(RefPlane: TRectangle3D);
begin
  Width := SIZE_PANEL_TICKS;
  Height := RefPlane.Height + 2*PANEL_PAD;
  Depth := RefPlane.Depth;
  Position.Point := RefPlane.Position.Point + TPoint3D.Create(RefPlane.Width/2 + Width/2, 0, 0);

  Front.Width := Width*(1 - SIZE_LABEL);
  Front.Height := Height;
  Front.Position.Point := TPoint3D.Create(-Width/2 + Front.Width/2, 0, -Depth/2 - 0.001);

  ZLabelTop.Text := Stg.FZLabel;
  ZLabelTop.Width := Stg.XZPlane.Height/2 + Stg.XYPlane.Position.Y;
  ZLabelTop.Visible := ZLabelTop.Width > 0;

  ZLabelTop.Height := Width - Front.Width;
  ZLabelTop.Position.Point := Front.Position.Point +

  TPoint3D.Create(Front.Width/2 + ZLabelTop.Height/2, -RefPlane.Height/2 + ZLabelTop.Width/2, 0);
  //ZLabelTop.OnPaint := TempPaint;

  ZLabelBottom.Text := Stg.FZLabel;
  ZLabelBottom.Width := Stg.XZPlane.Height - ZLabelTop.Width;
  ZLabelBottom.Visible := ZLabelBottom.Width > 0;

  ZLabelBottom.Height := Width - Front.Width;
  ZLabelBottom.Position.Point := ZLabelTop.Position.Point + TPoint3D.Create(0, ZLabelTop.Width/2 + ZLabelBottom.Width/2, 0);

  tag := 1;
  ShowPositiveSpace;
end;

procedure TPanelTicks.SetPositionLeft(RefPlane: TRectangle3D);
begin
  Width := RefPlane.Width;
  Height := RefPlane.Height + 2*PANEL_PAD;

  Depth := SIZE_PANEL_TICKS;
  Position.Point := RefPlane.Position.Point + TPoint3D.Create(0, 0, -RefPlane.depth/2 - depth/2);

  Front.Width := SIZE_PANEL_TICKS*(1 - SIZE_LABEL);
  Front.Height := Height;
  Front.RotationAngle.Y := -90;
  Front.Position.Point := TPoint3D.Create(Width/2 + 0.001, 0, Depth/2 - Front.Width/2);

  ZLabelTop.Text := Stg.FZLabel;
  ZLabelTop.Width := Stg.XZPlane.Height/2 + Stg.XYPlane.Position.Y;
  ZLabelTop.Visible := ZLabelTop.Width > 0;

  ZLabelTop.Height := Depth - Front.Width;
  ZLabelTop.RotationAngle.Z := 90;
  ZLabelTop.RotationAngle.X := -90;
  ZLabelTop.Position.Point := Front.Position.Point +

  TPoint3D.Create(0, -RefPlane.Height/2 + ZLabelTop.Width/2, -Front.Width/2 - ZLabelTop.Height/2);

  //ZLabelBottom.OnPaint := TempPaint;

  ZLabelBottom.Text := Stg.FZLabel;
  ZLabelBottom.Width := Stg.XZPlane.Height - ZLabelTop.Width;
  ZLabelBottom.Visible := ZLabelBottom.Width > 0;

  ZLabelBottom.Height := Depth - Front.Width;
  ZLabelBottom.RotationAngle.Z := 90;
  ZLabelBottom.RotationAngle.X := -90;
  ZLabelBottom.Position.Point := ZLabelTop.Position.Point +

  TPoint3D.Create(0, ZLabelTop.Width/2 + ZLabelBottom.Width/2, 0);

  tag := -1;
  ShowPositiveSpace;
end;

destructor TMainContainer.Destroy;
begin
  DataYAxis.Free;
  DataXAxis.Free;
  Inherited;
end;

function TMainContainer.RequestData(b: Tbar): TInfoStr;
var
  gb: TBarGraph;
begin
  gb := Boss as TBarGraph;
  Result := [
    Format('%s: %s', [gb.ZLabel, NiceNum(b.val)]),
    Format('%s: %s', [gb.XLabel, DataXAxis.Data(b.col)]),
    Format('%s: %s', [gb.YLabel, DataYAxis.Data(b.row)])
  ];
end;

function TMainContainer.GetScale: Single;
begin
  Result := (global.ZMax - global.ZMin)/Height;
end;

function TMainContainer.GetGlobalData: TGlobalData;
var
  Root: TComponent;
begin
  if not Assigned(FGlobal)then
    begin
      Root := Owner;
      while not (Root is TBarGraph) do Root := Root.Owner;
      FGlobal := (Root as TBarGraph).globalVars;
    end;
  Result := FGlobal;
end;

constructor TMainContainer.Create(AOwner: TComponent);
begin
  inherited;

  Boss := AOwner;
  FGlobal := (Boss as TBarGraph).globalVars;

  {
  Guia := TSphere.Create(Self);
  Guia.Parent := Self;
  Guia.width := 0.001;
  Guia.Height := Guia.width;
  Guia.Depth := Guia.Height;
  Guia.HitTest := false;
  Guia.Opacity := 0;
  }

  DataYAxis := TInfoAxis.Create;
  DataXAxis := TInfoAxis.Create;
  HitTest := false;
  FZLabel := '';

  ColorPlaneXY := TColorMaterialSource.Create(Self);
  ColorPlaneXY.Color := global.XYPlaneBackgroundColor;

  ColorPlane := TColorMaterialSource.Create(Self);
  ColorPlane.Color := global.XZPlaneYZPlaneBackgroundColor;



  BarContainer := TBarContainer.Create(Self);
  BarContainer.Parent := Self;
  BarContainer.FOnUpdate := ResizePlanes;

  CreateXZPlane;
  CreateXYPlane;
  CreateYZPlane;

  PanelRightTicks := TPanelTicks.Create(Self);
  PanelRightTicks.HitTest := false;

  PanelLeftTicks := TPanelTicks.Create(Self);
  PanelLeftTicks.HitTest := false;

  AxisYPanel := TAxisYPanel.Create(Self);
  AxisYPanel.Parent := Self;
  AxisYPanel.TopSticker.Sticker.Data := DataYAxis;
  AxisYPanel.BottomSticker.Sticker.Data := DataYAxis;


  AxisXPanel := TAxisXPanel.Create(Self);
  AxisXPanel.Parent := Self;
  AxisXPanel.TopSticker.Sticker.Data := DataXAxis;
  AxisXPanel.BottomSticker.Sticker.Data := DataXAxis;


  Corner := TRectangle3D.Create(Self);
  Corner.Parent := Self;
  Corner.Width := SIZE_PANEL_TICKS;
  Corner.Depth := Corner.Width;
  Corner.MaterialBackSource := ColorPlaneXY;
  Corner.MaterialShaftSource := ColorPlaneXY;
  Corner.MaterialSource := ColorPlaneXY;
  Corner.HitTest := false;
  Corner.Opacity := PLANE_OPACITY;

  ResizePlanes;

  XZPlane.OnRender := XZPlaneRender;
  YZPlane.OnRender := YZPlaneRender;
  XYPlane.OnRender := XYPlaneRender;
  OnRender := MainRender;

end;


procedure TMainContainer.Invalidate;
begin
  BarContainer.UpdatePositions;
  ResizePlanes;

  AxisYPanel.TopSticker.Invalidate;
  AxisYPanel.BottomSticker.Invalidate;
  AxisXPanel.TopSticker.Invalidate;
  AxisXPanel.BottomSticker.Invalidate;
  PanelRightTicks.Invalidate;
  PanelLeftTicks.Invalidate;

  SetColor;
end;

procedure TMainContainer.ResizePlanes;
begin
  Width := BarContainer.ColCount*(BAR_WIDTH + 2*BAR_PAD);
  Depth := BarContainer.RowCount*(BAR_DEPTH + 2*BAR_PAD);
  HalfPlaneHeight := Max(Width, Depth);
  Height := HalfPlaneHeight;

  (Boss as TBarGraph).SetPositionLights;


  XZPlane.Width := Width;
  XZPlane.Depth := PLANE_DEPTH;
  XZPlane.Height := Height;
  XZPlane.Position.X := 0;
  XZPlane.Position.Y := 0;
  XZPlane.Position.Z := Depth/2 + XZPlane.Depth/2;

  ResizeBordersR(XZPlane);

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
  XYPlane.Position.Y := Height/2 + global.Zmin/Scale;
  XYPlane.Position.Z := 0;

  PanelRightTicks.SetPosition(XZPlane);
  PanelLeftTicks.SetPositionLeft(YZPlane);

  BarContainer.Position.Y := XYPlane.Position.Y;


  AxisYPanel.Height := XYPlane.Height;
  AxisYPanel.Depth := XYPlane.Depth;
  AxisYPanel.Position.Point := XYPlane.Position.Point +
  TPoint3D.Create(XYPlane.Width/2 + AxisYPanel.Width/2, 0, 0);
  AxisYPanel.Resize;


  AxisXPanel.Height := XYPlane.Height;
  AxisXPanel.Width := XYPlane.Width;
  AxisXPanel.Depth := SIZE_PANEL_TICKS;


  AxisXPanel.Position.Point := XYPlane.Position.Point -
  TPoint3D.Create(0, 0, XYPlane.Depth/2 + AxisXPanel.Depth/2);
  AxisXPanel.Resize;

  Corner.Height := XYPlane.Height;
  Corner.Position.Point := XYPlane.Position.Point +
  TPoint3D.Create(XYPlane.Width/2 + Corner.Width/2, 0, -XYPlane.Depth/2 - Corner.Depth/2);

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
      Context.DrawLine(StartPoint, EndPoint, 1, global.BarGraphGridColor);
    end;


  for I := 1 to global.NumTicks - 1 do
    begin
      StartPoint := Ref +  TPoint3D.Create(0, -HeightBlock*I, 0);
      EndPoint := StartPoint +  TPoint3D.Create(0, 0, Depth);
      Context.DrawLine(StartPoint, EndPoint, 1, global.BarGraphGridColor);
    end;

end;


begin
  WidthBlock := BAR_WIDTH + 2*BAR_PAD;
  HeightBlock := YZPlane.Height/global.NumTicks;

  CenterPoint := TPoint3D.Create(YZPlane.Width/2, YZPlane.Height/2, 0);
  TopLeft := TPoint3D.Create(YZPlane.Width/2, YZPlane.Height/2, -YZPlane.Depth/2);
  DrawGrid(CenterPoint + TopLeft);

  {
  TopLeft := TPoint3D.Create(-XZPlane.Width/2, XZPlane.Height/2, XZPlane.Depth/2);
  DrawGrid(CenterPoint + TopLeft);
  }

  Context.DrawCube(CenterPoint, TPoint3D.Create(YZPlane.Width, YZPlane.Height, YZPlane.Depth), 1, global.BarGraphGridColor);
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
  (Panel.Children[0] as TText).HitTest := false;
  Panel.OnPaint := PanelPaint;

  Panel := TTextLayer3D.Create(P);
  Panel.Name := 'BottomPanel';
  Panel.Parent := P;
  Panel.HitTest := false;
  (Panel.Children[0] as TText).HitTest := false;
  Panel.OnPaint := PanelPaint;
end;

procedure  TMainContainer.PanelPaint(Sender: TObject; Canvas: TCanvas; const ARect: TRectF);
begin
  Canvas.Clear(global.XZPlaneYZPlaneBackgroundColor);
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
      Context.DrawLine(StartPoint, EndPoint, 1, global.BarGraphGridColor);
    end;

  for I := 1 to global.NumTicks - 1 do
    begin
      StartPoint := Ref +  TPoint3D.Create(0, -HeightBlock*I, 0);
      EndPoint := StartPoint +  TPoint3D.Create(Width, 0, 0);
      Context.DrawLine(StartPoint, EndPoint, 1, global.BarGraphGridColor);
    end;
end;


begin
  WidthBlock := BAR_WIDTH + 2*BAR_PAD;
  HeightBlock := XZPlane.Height/global.NumTicks;

  CenterPoint := TPoint3D.Create(XZPlane.Width/2, XZPlane.Height/2, 0);
  TopLeft := TPoint3D.Create(-XZPlane.Width/2, XZPlane.Height/2, -XZPlane.Depth/2);
  DrawGrid(CenterPoint + TopLeft);

  {
  TopLeft := TPoint3D.Create(-XZPlane.Width/2, XZPlane.Height/2, XZPlane.Depth/2);
  DrawGrid(CenterPoint + TopLeft);
  }

  Context.DrawCube(CenterPoint, TPoint3D.Create(XZPlane.Width, XZPlane.Height, XZPlane.Depth), 1, global.BarGraphGridColor);
end;


procedure TMainContainer.SetColor;
begin
  //var CP: TColorMaterialSource;
  ColorPlaneXY.Color := global.XYPlaneBackgroundColor;
  ColorPlane.Color := global.XZPlaneYZPlaneBackgroundColor;

  {
  (Corner.MaterialBackSource as TColorMaterialSource).Color := global.XYPlaneBackgroundColor;
  (Corner.MaterialShaftSource as TColorMaterialSource).Color := global.XYPlaneBackgroundColor;
  (Corner.MaterialSource as TColorMaterialSource).Color := global.XYPlaneBackgroundColor;
  }
end;


procedure TMainContainer.CreateXYPlane;
begin
  XYPlane := TRectangle3D.Create(Self);
  XYPlane.MaterialBackSource := ColorPlaneXY;
  XYPlane.MaterialShaftSource := ColorPlaneXY;
  XYPlane.MaterialSource := ColorPlaneXY;
  XYPlane.Parent := Self;
  XYPlane.HitTest := false;
  XYPlane.OnClick := (Boss as TBarGraph).ViewportClick;
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
      Context.DrawLine(StartPoint, EndPoint, 1, global.BarGraphGridColor);
    end;

  for I := 1 to BarContainer.RowCount - 1 do
    begin
      StartPoint := Ref +  TPoint3D.Create(0, 0, -DepthBlock*I);
      EndPoint := StartPoint +  TPoint3D.Create(Width, 0, 0);
      Context.DrawLine(StartPoint, EndPoint, 1, global.BarGraphGridColor);
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

  Context.DrawCube(CenterPoint, TPoint3D.Create(XYPlane.Width, XYPlane.Height, XYPlane.Depth), 1, global.BarGraphGridColor);
end;

procedure TMainContainer.MainRender(Sender: TObject; Context: TContext3D);
begin
  //Context.DrawCube(TPoint3D.Zero, TPoint3D.Create(Width, Height, Depth), 1, DEFAULT_GRID_COLOR);
end;

procedure TBarContainer.UnSelected(ExceptBar: TBar = Nil);
var
  I: Integer;
  b: TBar;
  gb: TBarGraph;
begin
  gb := Stg.Boss as TBarGraph;
  if gb.Camera <> gb.MainCamera.cam then
    begin
      gb.Camera := gb.MainCamera.cam;
      Exit;
    end;

  Legend.Visible := false;
  Legend.RotationAngle.y := 135;
  Legend.RotationAngle.X := 0;

  for I := 0 to ChildrenCount - 1 do
    if Children[I] is TBar then
      begin
        b := Children[I] as TBar;
        if (b <> ExceptBar) and (b.isSelected) then b.isSelected := false;
      end;
end;

procedure TBarContainer.RotateLegend;
begin
  if (Legend.Visible) and Assigned(Legend.bar) then
    begin
      if Legend.bar.val >= 0 then
        Legend.RotationAngle.y := 180 - stg.RotationAngle.Y
      else
        Legend.RotationAngle.y := 90 + stg.RotationAngle.Y;
    end;
end;

procedure TBarContainer.BarMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Single; RayPos, RayDir: TVector3D);
var
  gb: TBarGraph;
begin
  gb := Stg.Boss as TBarGraph;
  gb.MouseMove(Sender, Shift, X, Y);
end;

procedure TBarContainer.BarMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single; RayPos, RayDir: TVector3D);
var
  gb: TBarGraph;
begin
  gb := Stg.Boss as TBarGraph;
  gb.MouseDown(Sender, Button, Shift, X, Y);
end;

procedure TBarContainer.BarMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single; RayPos, RayDir: TVector3D);
var
  gb: TBarGraph;
begin
  gb := Stg.Boss as TBarGraph;
  gb.MouseUp(Sender, Button, Shift, X, Y);
end;

procedure TBarContainer.LegendClick(Sender: TObject);
var
  gb: TBarGraph;
begin
  gb := Stg.Boss as TBarGraph;
  gb.Camera := Legend.Sign.Pack.cam;
end;

procedure TBarContainer.BarClick(Sender: TObject);
var
  bar: TBar;
  gb: TBarGraph;
begin
  gb := Stg.Boss as TBarGraph;

  if (gb.Tag <> 1) and (Sender is TBar) then
    begin
      bar := Sender as TBar;
      UnSelected(bar);
      bar.isSelected := not bar.isSelected;
      if bar.isSelected then
        begin
          Legend.bar := bar;
          Legend.Data := Stg.RequestData(bar);
          Legend.Visible := true;
          Legend.Invalidate;

          //gb.Camera := Legend.Sign.Pack.cam;


          if bar.val >= 0 then
            begin
              Legend.Position.Point := bar.Position.Point + TPoint3D.Create(0, -bar.Height/2, 0);
              Legend.RotationAngle.X := 0;
              Legend.Sign.StickerA.RotationAngle.Y := 180;
              Legend.Sign.RotationAngle.Z := 0;
            end
          else
            begin
              Legend.Position.Point := bar.Position.Point + TPoint3D.Create(0, bar.Height/2, 0);
              Legend.RotationAngle.X := 180;
              Legend.Sign.StickerA.RotationAngle.Y := 180;
              Legend.Sign.RotationAngle.Z := 180;
            end;


          RotateLegend;
        end;
    end;
end;

constructor TBarContainer.Create(AOwner: TComponent);
begin
  inherited;
  Stg := AOwner as TMainContainer;
  FRowCount := DEFAULT_ROWCOUNT;
  FColCount := DEFAULT_COLCOUNT;
  Stg.DataYAxis.Count := FRowCount;
  Stg.DataXAxis.Count := FColCount;
  Legend := TLegend3D.Create(self);
  Legend.Visible := false;
  Legend.Parent := Self;

  Legend.Sign.HitTest := true;
  Legend.Sign.AutoCapture := true;
  //Legend.Sign.OnClick := LegendClick;
  Legend.Sign.StickerB.OnClick := LegendClick;
  Legend.Sign.StickerA.OnClick := LegendClick;

end;

procedure TBar.BarRender(Sender: TObject; Context: TContext3D);
begin
  if FIsSelected then
    Context.DrawCube(TPoint3D.Zero, TPoint3D.Create(1, 1, 1), 1, claBlack);
end;

constructor TBar.Create(AOwner: TComponent);
begin
  inherited;
  Stg := (AOwner as TBarContainer).Stg;
  FIsSelected := false;
  OnRender := BarRender;
end;

procedure TBar.SetColor(val: TAlphaColor);
var
  mat: TLightMaterialSource;
begin
  mat := TLightMaterialSource.Create(self);
  mat.Shininess := 10;
  mat.Ambient := val;
  mat.Emissive := val;
  mat.Specular := val;
  MaterialSource := mat;
end;

procedure TBar.SetIsSelected(val: Boolean);
begin
  if val <> FIsSelected then
    begin
      FIsSelected := val;
      if FIsSelected then
        color := Stg.global.BarSelectedColor
      else
        color := fcolor;
      repaint;
    end;
end;

function TBar.GetIsSelected: Boolean;
begin
  Result := FIsSelected;
end;

destructor TBar.Destroy;
begin
  inherited;
end;

procedure TBar.SetPosition(RowCount, ColCount: Integer);
var
  RefPoint, TopLeft: TPoint3D;
  WB, DB: Single;
  DH: Single;
begin
  Height := Abs(Val/Stg.Scale);
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
begin
  bar := TBar.Create(self);
  bar.Name := Format('Bar_%d_%d', [row, col]);
  bar.BeginUpdate;
  bar.Parent := Self;
  bar.row := row;
  bar.col := col;
  bar.fcolor := cl;
  bar.val := value;
  bar.Opacity := 1.0;

  bar.Width := BAR_WIDTH;
  bar.Depth := BAR_DEPTH;
  bar.SetPosition(RowCount, ColCount);
  bar.color := cl;
  bar.HitTest := true;
  bar.AutoCapture := true;
  bar.SubdivisionsHeight := 18;
  bar.SubdivisionsDepth := 5;
  bar.SubdivisionsWidth := 5;

  bar.OnClick := BarClick;
  bar.OnMouseDown := BarMouseDown;
  bar.OnMouseMove := BarMouseMove;
  bar.OnMouseUp := BarMouseUp;
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
  UpdatePositions;
  if (bar <> Nil) and (bar.val <> Value) then
    begin
      bar.val := Value;
      bar.Height := Abs(Value/Stg.Scale);
      bar.SetPosition(RowCount, ColCount);
      Stg.global.DataMin := Min(Stg.global.DataMin, value);
      Stg.global.DataMax := Max(Stg.global.DataMax, value);
    end
  else
    begin
      RowCount := Max(RowCount, row + 1);
      ColCount := Max(ColCount, col + 1);
      Stg.global.DataMin := Min(Stg.global.DataMin, value);
      Stg.global.DataMax := Max(Stg.global.DataMax, value);
      CreateBar(row, col, Value, cl);
    end;


end;

procedure TBarGraph.ViewNegativePlane;
begin
  Stage.PanelRightTicks.ShowNegativeSpace;
  Stage.PanelLeftTicks.ShowNegativeSpace;
  {
  TAnimator.AnimateFloat(FrontCamera, 'RotationAngle.X', 0, DURATION_CAMERA_CHANGE_VIEW_PLANE);
  TAnimator.AnimateFloat(FrontCamera, 'RotationAngle.Y', 0, DURATION_CAMERA_CHANGE_VIEW_PLANE);
  TAnimator.AnimateFloat(FrontCamera, 'RotationAngle.Z', 180, DURATION_CAMERA_CHANGE_VIEW_PLANE);

  TAnimator.AnimateFloat(FrontCamera, 'Position.X', 0, DURATION_CAMERA_CHANGE_VIEW_PLANE);
  TAnimator.AnimateFloat(FrontCamera, 'Position.Y', Stage.Height/2, DURATION_CAMERA_CHANGE_VIEW_PLANE);
  }
  SetStateRotationAngle(TPoint3D.Create(0, 45, 0));
end;

procedure TBarGraph.ViewPositivePlane;
begin
  Stage.PanelRightTicks.ShowPositiveSpace;
  Stage.PanelLeftTicks.ShowPositiveSpace;
  {
  TAnimator.AnimateFloat(FrontCamera, 'RotationAngle.X', 0, DURATION_CAMERA_CHANGE_VIEW_PLANE);
  TAnimator.AnimateFloat(FrontCamera, 'RotationAngle.Y', 0, DURATION_CAMERA_CHANGE_VIEW_PLANE);
  TAnimator.AnimateFloat(FrontCamera, 'RotationAngle.Z', 0, DURATION_CAMERA_CHANGE_VIEW_PLANE);
  TAnimator.AnimateFloat(FrontCamera, 'Position.X', 0, DURATION_CAMERA_CHANGE_VIEW_PLANE);
  TAnimator.AnimateFloat(FrontCamera, 'Position.Y', -Stage.Height/2, DURATION_CAMERA_CHANGE_VIEW_PLANE);
  }
  SetStateRotationAngle(TPoint3D.Create(0, 45, 0));
end;

procedure TBarGraph.SetStateRotationAngle(ang: TPoint3D);
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


procedure TBarGraph.SetXLabel(val: String);
begin
  if val <> Stage.AxisXPanel.TopSticker.Lb.Text then
    begin
      Stage.AxisXPanel.TopSticker.Lb.Text := val;
      Stage.AxisXPanel.TopSticker.Lb.Invalidate;
      Stage.AxisXPanel.BottomSticker.Lb.Text := val;
      Stage.AxisXPanel.BottomSticker.Lb.Invalidate;
    end;
end;

function TBarGraph.GetXLabel: String;
begin
  Result := Stage.AxisXPanel.TopSticker.Lb.Text;
end;

procedure TBarGraph.SetYLabel(val: String);
begin
  if val <> Stage.AxisYPanel.TopSticker.Lb.Text then
    begin
      Stage.AxisYPanel.TopSticker.Lb.Text := val;
      Stage.AxisYPanel.TopSticker.Lb.Invalidate;

      Stage.AxisYPanel.BottomSticker.Lb.Text := val;
      Stage.AxisYPanel.BottomSticker.Lb.Invalidate;
    end;
end;

function TBarGraph.GetYLabel: String;
begin
  Result := Stage.AxisYPanel.TopSticker.Lb.Text;
end;

procedure TBarGraph.SetZLabel(val: String);
begin
  if val <> Stage.FZLabel then
    begin
      Stage.FZLabel := val;
      Stage.PanelRightTicks.UpdateLabels;
      Stage.PanelLeftTicks.UpdateLabels;
    end;
end;

function TBarGraph.GetZLabel: String;
begin
  Result := Stage.FZLabel;
end;

procedure TBarGraph.Invalidate;
begin
  if Assigned(Stage) then
    Stage.Invalidate;
end;

function TBarGraph.GetZMin: Single;
begin
  if Assigned(globalVars) then
    Result := globalVars.ZMin
  else
    Result := AXIS_DEFAULT_ZMIN;
end;

procedure TBarGraph.SetZMin(val: Single);
begin
  if (Assigned(globalVars)) and (val <> globalVars.ZMin) then
    begin
      globalVars.ZMin := val;
      if Assigned(Stage) then Stage.Invalidate;
    end;
end;

function TBarGraph.GetZMax: Single;
begin
  if Assigned(globalVars) then
    Result := globalVars.ZMax
  else
    Result := AXIS_DEFAULT_ZMAX;
end;

procedure TBarGraph.SetZMax(val: Single);
begin
  if (Assigned(globalVars)) and (val <> globalVars.ZMax) then
    begin
      globalVars.ZMax := val;
      if Assigned(Stage) then Stage.Invalidate;
    end;
end;

function TBarGraph.GetLegendFontColor: TAlphaColor;
begin
  if Assigned(globalVars) then
    Result := globalVars.LegendFontColor
  else
    Result := LEGEND_FONT_COLOR;
end;

procedure TBarGraph.SetLegendFontColor(val: TAlphaColor);
begin
  if (Assigned(globalVars)) and (val <> globalVars.LegendFontColor) then
    begin
      globalVars.LegendFontColor := val;
      Stage.BarContainer.Legend.Invalidate;
    end;
end;

function TBarGraph.GetLegendBackgroundColor: TAlphaColor;
begin
  if Assigned(globalVars) then
    Result := globalVars.LegendBackgroundColor
  else
    Result := LEGEND_BOX_BACKGROUND_COLOR;
end;

procedure TBarGraph.SetLegendBackgroundColor(val: TAlphaColor);
begin
  if (Assigned(globalVars)) and (val <> globalVars.LegendBackgroundColor) then
    begin
      globalVars.LegendBackgroundColor := val;
      Stage.BarContainer.Legend.Invalidate;
    end;
end;

function TBarGraph.GetBarSelectedColor: TAlphaColor;
begin
  if Assigned(globalVars) then
    Result := globalVars.BarSelectedColor
  else
    Result := BAR_SELECTED_DEFAULT_COLOR;
end;

procedure TBarGraph.SetBarSelectedColor(val: TAlphaColor);
begin
  if (Assigned(globalVars)) and (val <> globalVars.BarSelectedColor) then
    begin
      globalVars.BarSelectedColor := val;
      if Assigned(Stage) then Stage.Invalidate;
    end;
end;

function TBarGraph.GetBarColor: TAlphaColor;
begin
  if Assigned(globalVars) then
    Result := globalVars.BarColor
  else
    Result := BAR_DEFAULT_COLOR;
end;

procedure TBarGraph.SetBarColor(val: TAlphaColor);
begin
  if (Assigned(globalVars)) and (val <> globalVars.BarColor) then
    begin
      globalVars.BarColor := val;
      if Assigned(Stage) then Stage.Invalidate;
    end;
end;


function TBarGraph.GetBarGraphFontColor: TAlphaColor;
begin
  if Assigned(globalVars) then
    Result := globalVars.BarGraphFontColor
  else
    Result := BARGRAPH_FONT_COLOR;
end;

procedure TBarGraph.SetBarGraphFontColor(val: TAlphaColor);
begin
  if (Assigned(globalVars)) and (val <> globalVars.BarGraphFontColor) then
    begin
      globalVars.BarGraphFontColor := val;
      if Assigned(Stage) then Stage.Invalidate;
    end;
end;

function TBarGraph.GetGridColor: TAlphaColor;
begin
  if Assigned(globalVars) then
    Result := globalVars.BarGraphGridColor
  else
    Result := BARGRAPH_DEFAULT_GRID_COLOR;
end;

procedure TBarGraph.SetGridColor(val: TAlphaColor);
begin
  if (Assigned(globalVars)) and (val <> globalVars.BarGraphGridColor) then
    begin
      globalVars.BarGraphGridColor := val;
      if Assigned(Stage) then Stage.Invalidate;
    end;
end;

function TBarGraph.GetXZandYZPlaneColor: TAlphaColor;
begin
  if Assigned(globalVars) then
    Result := globalVars.XZPlaneYZPlaneBackgroundColor
  else
    Result := XZPLANE_YZPLANE_DEFAULT_COLOR;
end;

procedure TBarGraph.SetXZandYZPlaneColor(val: TAlphaColor);
begin
  if (Assigned(globalVars)) and (val <> globalVars.XZPlaneYZPlaneBackgroundColor) then
    begin
      globalVars.XZPlaneYZPlaneBackgroundColor := val;
      if Assigned(Stage) then Stage.Invalidate;
    end;
end;

function TBarGraph.GetXYPlaneColor: TAlphaColor;
begin
  if Assigned(globalVars) then
    Result := globalVars.XYPlaneBackgroundColor
  else
    Result := XYPLANE_BACKGROUNDCOLOR;
end;

procedure TBarGraph.SetXYPlaneColor(val: TAlphaColor);
begin
  if (Assigned(globalVars)) and (val <> globalVars.XYPlaneBackgroundColor) then
    begin
      globalVars.XYPlaneBackgroundColor := val;
      if Assigned(Stage) then Stage.Invalidate;
    end;
end;

procedure TBarGraph.SetBackgroundColor(val: TAlphaColor);
begin
  if val <> color then
    begin
      color := val;
    end;
end;

function TBarGraph.GetBackgroundColor: TAlphaColor;
begin
  Result := color;
end;

function TBarGraph.GetAutoScale: Boolean;
begin
  if Assigned(globalVars) then
    Result := globalVars.AutoScale
  else
    Result := false;
end;

procedure TBarGraph.SetAutoScale(val: Boolean);
begin
  if (Assigned(globalVars)) and (val <> globalVars.AutoScale) then
    begin
      globalVars.AutoScale := val;
      if Assigned(Stage) then Stage.Invalidate;
    end;
end;


function TBarGraph.GetNumTicks: Integer;
begin
  if Assigned(globalVars) then
    Result := globalVars.NumTicks
  else
    Result := ZAXIS_DEFAULT_NUMTICKS;
end;

procedure TBarGraph.SetNumTicks(val: Integer);
begin
  if (Assigned(globalVars)) and (val <> globalVars.NumTicks) then
    begin
      globalVars.NumTicks := val;
      if Assigned(Stage) then Stage.Invalidate;
    end;
end;

procedure TBarGraph.Reset;
begin
  SetInitialValues;
end;


function TBarGraph.getZ: Single;
var
  WR: Single;
begin
  WR := Stage.Width + Stage.Height;
  Result := (WR*-15)/27;
end;

procedure TBarGraph.SetInitialValues;
begin
  Camera := MainCamera.cam;
  MainCamera.RotationAngle.X := CAMERA_INITIAL_ROT_ANGLE_X;
  MainCamera.Init(CAMERA_MIN_Z, CAMERA_MAX_Z, zpos, Guide);

  Stage.RotationAngle.Y := STAGE_INITIAL_ROT_ANGLE_Y;
  Stage.Position.X := 0;
  Stage.Position.Y := 0;
  Stage.BarContainer.RotateLegend;
  Status := 'static';

  Guide.Position.X := 0;
  Guide.Position.Y := 0;
  MainCamera.Position.X := 0;
  MainCamera.Position.Y := 0;

end;

constructor TBarGraph.Create(AOwner: TComponent);
var
  menuItem: TMenuItem;
begin
  inherited;

  globalVars := TGlobalData.Create;
  zpos := CAMERA_INITIAL_POSITION_Z;

  PopupMenu := TPopupMenu.Create(self);
  PopupMenu.Parent := Self;
  menuItem := TMenuItem.Create(PopupMenu);
  menuItem.Text := 'V1.0.0.1';
  PopupMenu.AddObject(menuItem);
  status := 'static';
  UsingDesignCamera := False;
  color := BARGRAPH_DEFAULT_BACKGROUND_COLOR;

  if csDesigning in ComponentState then Exit;

  Stage := TMainContainer.Create(Self);
  AddObject(Stage);

  Guide := TSphere.Create(Self);
  Guide.Parent := Self;
  Guide.width := SIZE_GUIDES;
  Guide.Height := Guide.width;
  Guide.Depth := Guide.Height;
  Guide.HitTest := false;
  Guide.Opacity := SHOW_GUIDES;

  MainCamera := TMyCamera.Create(Self);
  MainCamera.Parent := self;

  SetInitialValues;
  dir := 1;

  LeftLight := TLight.Create(self);
  LeftLight.LightType := TLightType.Point;
  LeftLight.Parent := Self;

  RightLight := TLight.Create(self);
  RightLight.LightType := TLightType.Point;
  RightLight.Parent := Self;
  SetPositionLights;
  InitMouseEvents;
end;

procedure TBarGraph.SetPositionLights;
var
  F: Single;
begin
  if Assigned(RightLight) then
    begin
      F := 10;
      RightLight.Position.X := F*Stage.Width;
      RightLight.Position.Y := 0;
      RightLight.Position.Z := F*Stage.Depth;

      LeftLight.Position.X := -RightLight.Position.X;
      LeftLight.Position.Y := 0;
      LeftLight.Position.Z := 0;
    end;

  if Assigned(MainCamera) then
    begin
      zPos := getZ;
      MainCamera.Position.Z := zPos;
    end;
end;

procedure TBarGraph.InitMouseEvents;
begin
  OnMouseWheel := MouseWheel;
  OnMouseDown := MouseDown;
  OnMouseMove := MouseMove;
  OnMouseUp := MouseUp;
  OnClick := ViewportClick;
end;

constructor TMyCamera.Create(AOwner: TComponent);
var
  cl: TColorMaterialSource;
begin
  inherited;
  dir := 1;
  cam := TCamera.Create(Self);
  AddObject(cam);

  guide := TSphere.Create(Self);
  guide.width := SIZE_GUIDES;
  guide.Height := guide.width;
  guide.Depth := guide.Height;
  guide.HitTest := false;
  guide.Opacity := SHOW_GUIDES;

  cl := TColorMaterialSource.Create(self);
  cl.Color := claGreen;
  guide.MaterialSource := cl;

  AddObject(guide);
end;

procedure TMyCamera.Init(AMinZ, AMaxZ, IniZ: Single; t: TControl3D);
begin
  MinZ := AMinZ;
  MaxZ := AMaxZ;
  Position.Z := IniZ;
  cam.Target := t;
end;

procedure TBarGraph.DoZoom(aIn: Boolean);
var
  newZ: Single;
  mc: TMyCamera;
begin
  mc := Camera.Parent as TMyCamera;
  if AIn then
    newZ := mc.Position.Z + mc.dir*ZOOM_STEP
  else
    newZ := mc.Position.Z - mc.dir*ZOOM_STEP;

  if (newZ < mc.MaxZ) and (newZ > mc.MinZ) then
     mc.Position.Z := newZ;

  //Lb.Text := Format('z: %f, w: %f, h:%f', [mc.Position.Z, stage.Width, stage.Depth]);
end;

procedure TBarGraph.MouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; var Handled: Boolean);
begin
  DoZoom(WheelDelta > 0);
end;

procedure TBarGraph.ViewportClick(Sender: TObject);
begin
  if Tag <> 1 then
    Stage.BarContainer.UnSelected;
end;

procedure TBarGraph.MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
var
  val: boolean;
  P: TPointF;
begin
  Tag := 0;
  FDown := PointF(X, Y);
  if ((ssLeft in Shift) or (ssCtrl in Shift)) and (Status = 'static') then
    begin
      Status := 'MouseMove';
    end
  else
  if (ssRight in Shift) and (Status = 'static') then
   begin
     P := LocalToScreen(PointF(X, Y));
     PopupMenu.Popup(P.X, P.Y);
   end;
end;

procedure TBarGraph.MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
var
  Delta: TPointF;
  T: Single;
  mc: TMyCamera;
begin
  Delta := PointF(X, Y) - FDown;
  if (ssCtrl in Shift) and (Status = 'MouseMove') then
    begin
      mc := Camera.Parent as TMyCamera;
      if Camera = MainCamera.cam then
        begin
          guide.Position.X := guide.Position.X - Delta.X*TRANSLATION_STEP;
          guide.Position.Y := guide.Position.Y - Delta.Y*TRANSLATION_STEP;
          mc.Position.X := mc.Position.X - Delta.X*TRANSLATION_STEP;
          mc.Position.Y := mc.Position.Y - Delta.Y*TRANSLATION_STEP;
        end;
    end
  else
  if (ssLeft in Shift) and (Status = 'MouseMove') then
    begin
      mc := Camera.Parent as TMyCamera;
      mc.RotationAngle.X := mc.RotationAngle.X - Delta.Y*ROTATION_STEP;
      Stage.RotationAngle.Y := Stage.RotationAngle.Y - Delta.X*ROTATION_STEP;
      Stage.BarContainer.RotateLegend;
    end;
  FDown := PointF(X, Y);
  Tag := 1;

  //Lb.Text := Format('W: %f, H:%f', [stage.ScreenBounds.Width, stage.ScreenBounds.Height]);
end;

procedure TBarGraph.MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  if(Status = 'MouseMove') then
    begin
      Status := 'static';
    end;
end;

procedure TBarGraph.Add(row, col: Integer; Value: Single; cl: TAlphaColor = 0);
var
  temp: TAlphaColor;
begin
  if cl = 0 then temp := globalVars.BarColor else temp := cl;
  Stage.BarContainer.Add(row, col, Value, temp);
  Stage.DataYAxis.Count := row + 1;
  Stage.DataXAxis.Count := col + 1;
  Stage.Invalidate;
end;

procedure TBarGraph.AddYLabel(row: Integer; val: String);
begin
  Stage.DataYAxis.Add(row, val);
end;

procedure TBarGraph.AddXLabel(col: Integer; val: String);
begin
  Stage.DataXAxis.Add(col, val);
end;

destructor TBarGraph.Destroy;
begin
  if Assigned(globalVars) then globalVars.Destroy;
  inherited;
end;


end.
