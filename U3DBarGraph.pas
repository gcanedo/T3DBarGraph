unit U3DBarGraph;

interface
  uses
    FMX.Viewport3D, System.Classes, FMX.Objects3D, Math, System.SysUtils,
    FMX.MaterialSources, System.UIConsts, FMX.Types3D, System.Math.Vectors,
    System.UITypes, FMX.Controls3D, System.Types, FMX.Ani, FMX.Layers3D,
    FMX.Graphics, FMX.Types, FMX.Objects, FMX.Dialogs, FMX.StdCtrls, FMX.Menus,
    FMX.Forms, System.Generics.Collections;

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
    PLANE_OPACITY = 0.5;

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
    MIN_AXIS_RANGE = 1.0;
    MESH_RENDER_THRESHOLD = 300;
    MESH_BARS_PER_CHUNK = 2500;
    MESH_VERTICES_PER_BAR = 24;
    MESH_INDICES_PER_BAR = 36;
    MESH_TRIANGLES_PER_BAR = 12;
    MIN_BAR_PICK_HEIGHT = 0.001;
    SELECTION_BAR_PAD = 0.025;

    //// GENERAL SETTINGS////////
    ROTATION_STEP = 0.3;
    TRANSLATION_STEP = 0.02;

    DEFAULT_RESOLUTION = 150;
    MAX_TEXT_LAYER_BITMAP_SIZE = 2048;
    MIN_TEXT_LAYER_RESOLUTION = 1;
    ZOOM_STEP = 0.01;
    CAMERA_MAX_Z = 50;
    CAMERA_MIN_Z = -102;

    DURATION_CAMERA_CHANGE_VIEW_PLANE = 0.5;
    CAMERA_INITIAL_ROT_ANGLE_Y = -45;
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
        Light: TLight;
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
      PlaneOpacity: Single;
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

    TBarRenderMode = (brAuto, brCubes, brMesh);

    TBarData = record
      row, col: Integer;
      val: Single;
      color: TAlphaColor;
    end;

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
      constructor Create(AOwner: TComponent); override;
    end;

    TTransparentRectangle3D = class(TRectangle3D)
      protected
        procedure Render; override;
    end;

    TAlphaPanelRectangle3D = class(TTransparentRectangle3D)
      private
        FPanelColor: TAlphaColor;
        FPanelOpacity: Single;
      protected
        procedure Render; override;
      public
        procedure SetPanelFill(AColor: TAlphaColor; AOpacity: Single);
    end;

    TZTestTextLayer3D = class(TTextLayer3D)
      protected
        procedure Render; override;
    end;


    TBar = class(TCube)
      private
        FMaterial: TLightMaterialSource;
        FRenderBody: Boolean;
        procedure SetPosition(RowCount, ColCount: Integer);
      protected
        procedure Render; override;
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

      procedure SetDataVal(val: TInfoStr);
      procedure Invalidate;
      constructor Create(AOwner: TComponent); override;
      property Data: TInfoStr write SetDataVal;

    end;


    TBarContainer = class(TDummy)
      private
        FBarIndex: TDictionary<Int64, TBar>;
        FDataIndex: TDictionary<Int64, Integer>;
        FBarData: TList<TBarData>;
        FMeshGroups: TObjectList<TMesh>;
        FMeshDataIndexes: TObjectDictionary<TMesh, TList<Integer>>;
        FMeshSelectionBar: TBar;
        FRenderMode: TBarRenderMode;
        FMeshDirty: Boolean;
        FUpdateLock: Integer;
        FNeedsLayoutUpdate: Boolean;
        FNeedsCameraUpdate: Boolean;
        function BarKey(row, col: Integer): Int64;
        function ActiveRenderMode: TBarRenderMode;
        function UpsertBarData(row, col: Integer; Value: Single; cl: TAlphaColor; out OldValue: Single; out ExistingBar: Boolean): Integer;
        procedure BeginDataUpdate;
        procedure EndDataUpdate;
        procedure RequestLayoutUpdate(UpdateCamera: Boolean);
        procedure ApplyPendingLayout;
        procedure ApplyRenderMode;
        procedure SetRenderMode(val: TBarRenderMode);
        procedure SetCubeVisibility(Visible: Boolean);
        procedure ClearMeshGroups;
        procedure RebuildMesh;
        procedure ClearMeshSelection;
        procedure GetBarBox(const AData: TBarData; out Center: TPoint3D; out BarHeight: Single);
        function TryPickMeshBarAtScreen(const P: TPointF; out DataIndex: Integer): Boolean;
        function TryPickMeshCell(const RayPos, RayDir: TPoint3D; out DataIndex: Integer; out Intersection: TPoint3D): Boolean;
        function TryPickMeshBar(const RayPos, RayDir: TPoint3D; out DataIndex: Integer; out Intersection: TPoint3D): Boolean;
        function TryPickMeshTriangles(AMesh: TMesh; const RayPos, RayDir: TPoint3D; out DataIndex: Integer; out Intersection: TPoint3D): Boolean;
        function SelectMeshDataIndex(DataIndex: Integer): Boolean;
        procedure BuildMeshChunk(AColor: TAlphaColor; const AIndexes: TList<Integer>; AStart, ACount: Integer);
        procedure AddMeshBar(AMesh: TMesh; const AData: TBarData; AVertexBase, AIndexBase: Integer);
        procedure SetRowCount(val: Integer);
        procedure SetColCount(val: Integer);
        procedure RecalculateDataBounds;
        procedure PositionLegendForBar(bar: TBar);
      public
        FOnUpdate: TOnUpdateEvent;
        FRowCount, FColCount: Integer;
        PackCamera: TMyCamera;
        BearingTop, BearingMiddle: TDummy;
        Legend: TLegend3D;
        Stg: TMainContainer;
        function LastSelected: TBar;
        procedure UnSelected(SelectedBar: TBar = Nil);
        procedure ChangeCamera;
        procedure BarClick(Sender: TObject);
        procedure InitCamera;
        procedure LegendClick(Sender: TObject);
        procedure BarMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single; RayPos, RayDir: TVector3D);
        procedure BarMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single; RayPos, RayDir: TVector3D);
        procedure BarMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single; RayPos, RayDir: TVector3D);
        procedure RotateLegend;
        constructor Create(AOwner: TComponent); override;
        destructor Destroy; override;
        procedure Add(row, col: Integer; Value: Single; cl: TAlphaColor = claBlue);
        procedure CreateBar(row, col: Integer; Value: Single; cl: TAlphaColor = claBlue);
        function SelectMeshBarAtScreen(const P: TPointF): Boolean;
        function SelectMeshBarFromRay(const RayPos, RayDir: TPoint3D): Boolean;
        function SelectMeshBarFromMeshRay(AMesh: TMesh; const RayPos, RayDir: TPoint3D): Boolean;
        property RenderMode: TBarRenderMode read FRenderMode write SetRenderMode;
        property RowCount: Integer read FRowCount write SetRowCount;
        property ColCount: Integer read FColCount write SetColCount;
        procedure UpdatePositions;
        procedure InvalidateSelected;
        procedure InvalidateNotSelectedBars;
        function IndexOf(row, col: Integer): TBar;
    end;

    TSticker = class(TZTestTextLayer3D)
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
        Title3D: TText3D;
        ValueTexts3D: TObjectList<TText3D>;
        TextMaterial: TLightMaterialSource;
        Stg: TMainContainer;
        constructor Create(AOwner: TComponent); override;
        destructor Destroy; override;
        procedure Resize;
        procedure Invalidate;
        procedure RebuildText3D;
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


    TPanelTicks = class(TAlphaPanelRectangle3D)
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
        procedure ApplyPlaneOpacity;
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
        FClickStart: TPointF;
        FDragMoved: Boolean;
        PopupMenu: TPopupMenu;
        FUpdateLock: Integer;
        FNeedsInvalidate: Boolean;

        function GetZMin: Single;
        procedure SetZMin(val: Single);
        function GetZMax: Single;
        procedure SetZMax(val: Single);
        function GetNumTicks: Integer;
        procedure SetNumTicks(val: Integer);

        function GetAutoScale: Boolean;
        procedure SetAutoScale(val: Boolean);

        procedure DoZoom(WheelDelta: Integer);
        procedure BarMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; var Handled: Boolean);
        procedure BarMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
        procedure BarMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
        procedure BarMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
        procedure ViewportClick(Sender: TObject);
        procedure InitMouseEvents;
        procedure SetPositionLights;
        procedure RequestInvalidate;
        function TrySelectMeshAt(const P: TPointF): Boolean;


        procedure SetZLabel(val: String);
        function GetZLabel: String;

        procedure SetYLabel(val: String);
        function GetYLabel: String;

        procedure SetXLabel(val: String);
        function GetXLabel: String;

        procedure Rotate(const aX, aY: Single);
        function OnTheHead: Boolean;

      protected
      public
        globalVars: TGlobalData;
        Stage: TMainContainer;
        status: String;
        Pos3D: TPoint3D;
        PosMouse: TPointF;
        LeftLight, RightLight: TLight;
        //MainCamera: TMyCamera;
        Guide: TSphere;
        zpos: Single;
        BearingTop: TDummy;
        BearingMiddle: TDummy;
        PackCamera: TMyCamera;


        constructor Create(AOwner: TComponent); override;
        destructor Destroy; override;
        procedure Invalidate;
        procedure TurnLights(Val: Boolean);
        procedure UpdateCameraPosition;
        procedure Add(row, col: Integer; Value: Single; cl: TAlphaColor = 0);
        procedure BeginDataUpdate;
        procedure EndDataUpdate;

        procedure ViewNegativePlane;
        procedure ViewPositivePlane;
        procedure SetStateRotationAngle(ang: TPoint3D);

        function GetBackgroundColor: TAlphaColor;
        procedure SetBackgroundColor(val: TAlphaColor);

        function GetXYPlaneColor: TAlphaColor;
        procedure SetXYPlaneColor(val: TAlphaColor);

        function GetXZandYZPlaneColor: TAlphaColor;
        procedure SetXZandYZPlaneColor(val: TAlphaColor);

        function GetPlaneOpacity: Single;
        procedure SetPlaneOpacity(val: Single);

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
        property PlaneOpacity: Single read GetPlaneOpacity write SetPlaneOpacity;
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

function SafeTextResolution(AWidth, AHeight: Single): Integer;
var
  MaxDimension: Single;
  ProposedResolution: Single;
begin
  MaxDimension := Max(Abs(AWidth), Abs(AHeight));
  if SameValue(MaxDimension, 0) then
    Exit(DEFAULT_RESOLUTION);

  ProposedResolution := MAX_TEXT_LAYER_BITMAP_SIZE/MaxDimension;
  Result := Integer(Trunc(ProposedResolution));
  Result := Max(MIN_TEXT_LAYER_RESOLUTION, Result);
  Result := Min(DEFAULT_RESOLUTION, Result);
end;

constructor TGlobalData.Create;
begin
  LegendFontColor := LEGEND_FONT_COLOR;
  LegendBackgroundColor := LEGEND_BACKGROUND_COLOR_STICKER;
  BarColor := BAR_DEFAULT_COLOR;
  BarSelectedColor := BAR_SELECTED_DEFAULT_COLOR;

  XYPlaneBackgroundColor := XYPLANE_BACKGROUNDCOLOR;
  XZPlaneYZPlaneBackgroundColor := XZPLANE_YZPLANE_DEFAULT_COLOR;
  PlaneOpacity := PLANE_OPACITY;

  BarGraphGridColor := BARGRAPH_DEFAULT_GRID_COLOR;
  BarGraphFontColor := BARGRAPH_FONT_COLOR;

  DataMin := MaxSingle;
  DataMax := MinSingle;
  FZMin := AXIS_DEFAULT_ZMIN;
  FZMax := AXIS_DEFAULT_ZMAX;
  NumTicks := ZAXIS_DEFAULT_NUMTICKS;
  AutoScale := false;
end;

procedure TTransparentRectangle3D.Render;
var
  M: TMatrix3D;
begin
  // Keep TRectangle3D's local coordinate system without its opaque fill.
  M := TMatrix3D.Identity;
  M.m41 := -Width/2;
  M.m42 := -Height/2;
  Context.SetMatrix(M * AbsoluteMatrix);
end;

procedure TAlphaPanelRectangle3D.Render;
begin
  inherited;

  if FPanelOpacity <= 0 then Exit;

  Context.SetContextState(TContextState.csAlphaBlendOn);
  Context.SetContextState(TContextState.csZTestOn);
  if FPanelOpacity >= 1 then
    Context.SetContextState(TContextState.csZWriteOn)
  else
    Context.SetContextState(TContextState.csZWriteOff);

  Context.FillCube(TPoint3D.Create(Width/2, Height/2, 0),
    TPoint3D.Create(Width, Height, Depth), FPanelOpacity, FPanelColor);
end;

procedure TAlphaPanelRectangle3D.SetPanelFill(AColor: TAlphaColor; AOpacity: Single);
begin
  FPanelColor := AColor;
  FPanelOpacity := EnsureRange(AOpacity, 0, 1);
  Repaint;
end;

procedure TZTestTextLayer3D.Render;
begin
  Context.SetContextState(TContextState.csZTestOn);
  if ZWrite then
    Context.SetContextState(TContextState.csZWriteOn)
  else
    Context.SetContextState(TContextState.csZWriteOff);
  inherited;
end;

function TGlobalData.GetZMin: Single;
begin
  if (AutoScale) and (DataMin <> MaxSingle) then
    begin
      if SameValue(DataMin, DataMax) then
        Result := DataMin - MIN_AXIS_RANGE/2
      else
        Result := DataMin;
    end
  else
    Result := FZMin;
end;

procedure TGlobalData.SetZMin(val: Single);
begin
  if val <> FZMin then
    begin
      FZMin := val;
      if FZMin >= FZMax then
        FZMax := FZMin + MIN_AXIS_RANGE;
    end;
end;

function TGlobalData.GetZMax: Single;
begin
  if (AutoScale) and (DataMax <> MinSingle) then
    begin
      if SameValue(DataMin, DataMax) then
        Result := DataMax + MIN_AXIS_RANGE/2
      else
        Result := DataMax;
    end
  else
    Result := FZMax;
end;

procedure TGlobalData.SetZMax(val: Single);
begin
  if val <> FZMax then
    begin
      FZMax := val;
      if FZMax <= FZMin then
        FZMin := FZMax - MIN_AXIS_RANGE;
    end;
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

procedure TLegend3D.SetDataVal(val: TInfoStr);
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

  Base := TAlphaPanelRectangle3D.Create(Self);
  Base.Width := TopSticker.Width;
  Base.Parent := Self;
  ColorPlane := TColorMaterialSource.Create(Self);
  ColorPlane.Color := MakeColor(Stg.global.XYPlaneBackgroundColor, Stg.global.PlaneOpacity);



  Base.MaterialBackSource := ColorPlane;
  Base.MaterialShaftSource := ColorPlane;
  Base.MaterialSource := ColorPlane;
  Base.HitTest := false;
  Base.Visible := false;


  tag := 1;
  BottomSticker := TGroupSticker.Create(Self);
  BottomSticker.RotationAngle.X := 90;
  BottomSticker.RotationAngle.Z := -90;
  BottomSticker.Sticker.RotationAngle.Y := 0;
  BottomSticker.Lb.RotationAngle.Y := 0;
  BottomSticker.Parent := Self;
  BottomSticker.Visible := false;
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
  BottomSticker.Visible := false;
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
  TopSticker.Sticker.RotationAngle.Y := 0;
  TopSticker.Lb.RotationAngle.Y := 0;
  TopSticker.Parent := Self;
  Width := TopSticker.Width;

  Base := TAlphaPanelRectangle3D.Create(Self);
  Base.Width := TopSticker.Width;
  Base.Parent := Self;
  ColorPlane := TColorMaterialSource.Create(Self);
  ColorPlane.Color := MakeColor(Stg.global.XYPlaneBackgroundColor, Stg.global.PlaneOpacity);

  Base.MaterialBackSource := ColorPlane;
  Base.MaterialShaftSource := ColorPlane;
  Base.MaterialSource := ColorPlane;
  Base.HitTest := false;
  Base.Visible := false;

  tag := -1;
  BottomSticker := TGroupSticker.Create(Self);
  BottomSticker.RotationAngle.X := -90;
  BottomSticker.Sticker.RotationAngle.Y := 180;
  BottomSticker.Lb.RotationAngle.Y := 180;
  BottomSticker.Parent := Self;
  BottomSticker.Visible := false;
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
  BottomSticker.Visible := false;
end;

procedure TGroupSticker.Invalidate;
var
  PanelOpacity: Single;
  UseFillAlpha: Boolean;
begin
  PanelOpacity := Stg.global.PlaneOpacity;
  UseFillAlpha := false;

  Lb.Visible := true;
  Lb.Transparency := true;
  Lb.ZWrite := PanelOpacity >= 1;
  Lb.TwoSide := true;
  if UseFillAlpha then
    begin
      Lb.Opacity := 1;
      Lb.Fill.Color := MakeColor(Stg.global.XYPlaneBackgroundColor, PanelOpacity);
      Lb.Fill.Kind := TBrushKind.Solid;
    end
  else
    begin
      Lb.Opacity := PanelOpacity;
      Lb.Fill.Color := Stg.global.XYPlaneBackgroundColor;
      Lb.Fill.Kind := TBrushKind.Solid;
    end;
  Lb.Color := Stg.global.BarGraphFontColor;

  if Assigned(Sticker) then
    begin
      Sticker.Visible := true;
      Sticker.Transparency := true;
      Sticker.ZWrite := Lb.ZWrite;
      Sticker.TwoSide := true;
      if UseFillAlpha then
        begin
          Sticker.Opacity := 1;
          Sticker.Fill.Color := MakeColor(Stg.global.XYPlaneBackgroundColor, PanelOpacity);
          Sticker.Fill.Kind := TBrushKind.Solid;
        end
      else
        begin
          Sticker.Opacity := PanelOpacity;
          Sticker.Fill.Color := Stg.global.XYPlaneBackgroundColor;
          Sticker.Fill.Kind := TBrushKind.Solid;
        end;
      Sticker.Invalidate;
    end;

  RebuildText3D;
end;

constructor TGroupSticker.Create(AOwner: TComponent);
begin
  inherited;
  Stg := (AOwner as TFMXObject).Owner as TMainContainer;

  Tag := AOwner.Tag;
  Width := SIZE_PANEL_TICKS;

  Lb := TZTestTextLayer3D.Create(Self);
  Lb.Text := '';
  Lb.Height := SIZE_LABEL;
  Lb.Parent := Self;
  Lb.HitTest := false;
  Lb.Visible := true;
  Lb.Transparency := true;
  Lb.ZWrite := Stg.global.PlaneOpacity >= 1;
  Lb.TwoSide := true;
  (Lb.Children[0] as TText).HitTest := false;


  Lb.Resolution := DEFAULT_RESOLUTION;
  Lb.RotationAngle.Z := -90;
  Lb.Opacity := Stg.global.PlaneOpacity;
  Lb.Color := Stg.global.BarGraphFontColor;
  Lb.Fill.Kind := TBrushKind.Solid;
  Lb.Fill.Color := Stg.global.XYPlaneBackgroundColor;

  Lb.Font.Size := Lb.Resolution*PANEL_PAD;
  Lb.Position.X := Width/2 - Lb.Height/2;

  Sticker := TSticker.Create(Self);
  Sticker.Width := Width - SIZE_LABEL;
  Sticker.Parent := Self;
  Sticker.Position.X := -Width/2 + Sticker.Width/2;
  Sticker.HitTest := false;
  Sticker.Visible := true;
  Sticker.Transparency := true;
  Sticker.ZWrite := Stg.global.PlaneOpacity >= 1;
  Sticker.TwoSide := true;

  TextMaterial := TLightMaterialSource.Create(Self);
  Title3D := TText3D.Create(Self);
  Title3D.Parent := Self;
  Title3D.Visible := false;
  Title3D.HitTest := false;
  Title3D.Depth := 0.001;
  Title3D.WordWrap := false;
  Title3D.Stretch := true;
  Title3D.HorzTextAlign := TTextAlign.Center;
  Title3D.VertTextAlign := TTextAlign.Center;
  Title3D.MaterialBackSource := TextMaterial;
  Title3D.MaterialShaftSource := TextMaterial;
  Title3D.MaterialSource := TextMaterial;

  ValueTexts3D := TObjectList<TText3D>.Create(true);

  HitTest := false;

end;

destructor TGroupSticker.Destroy;
begin
  ValueTexts3D.Free;
  inherited;
end;

procedure TGroupSticker.Resize;
var
  PanelOpacity: Single;
  UseFillAlpha: Boolean;
begin
  PanelOpacity := Stg.global.PlaneOpacity;
  UseFillAlpha := false;

  Lb.Visible := true;
  Lb.Transparency := true;
  Lb.ZWrite := PanelOpacity >= 1;
  Lb.TwoSide := true;
  if UseFillAlpha then
    begin
      Lb.Opacity := 1;
      Lb.Fill.Color := MakeColor(Stg.global.XYPlaneBackgroundColor, PanelOpacity);
      Lb.Fill.Kind := TBrushKind.Solid;
    end
  else
    begin
      Lb.Opacity := PanelOpacity;
      Lb.Fill.Color := Stg.global.XYPlaneBackgroundColor;
      Lb.Fill.Kind := TBrushKind.Solid;
    end;
  Lb.Resolution := SafeTextResolution(Height, Lb.Height);
  Lb.Font.Size := Lb.Resolution*PANEL_PAD;
  Lb.Width := Height;
  Lb.Invalidate;

  Sticker.Visible := true;
  Sticker.Transparency := true;
  Sticker.ZWrite := PanelOpacity >= 1;
  Sticker.TwoSide := true;
  if UseFillAlpha then
    begin
      Sticker.Opacity := 1;
      Sticker.Fill.Color := MakeColor(Stg.global.XYPlaneBackgroundColor, PanelOpacity);
      Sticker.Fill.Kind := TBrushKind.Solid;
    end
  else
    begin
      Sticker.Opacity := PanelOpacity;
      Sticker.Fill.Color := Stg.global.XYPlaneBackgroundColor;
      Sticker.Fill.Kind := TBrushKind.Solid;
    end;
  Sticker.Resolution := SafeTextResolution(Sticker.Width, Height);
  Sticker.Height := Height;
  Sticker.Invalidate;

  RebuildText3D;
end;

procedure TGroupSticker.RebuildText3D;
var
  I: Integer;
  Info: TInfoAxis;
  BlockHeight, TextHeight, TextWidth, TextX, TextY: Single;
  AxisText: TText3D;
begin
  if Assigned(Title3D) then
    Title3D.Visible := false;
  if Assigned(ValueTexts3D) then
    ValueTexts3D.Clear;
  Exit;

  if not Assigned(TextMaterial) then Exit;

  TextMaterial.Ambient := Stg.global.BarGraphFontColor;
  TextMaterial.Diffuse := Stg.global.BarGraphFontColor;
  TextMaterial.Emissive := Stg.global.BarGraphFontColor;
  TextMaterial.Specular := Stg.global.BarGraphFontColor;

  if Assigned(Title3D) then
    begin
      Title3D.Text := Lb.Text;
      Title3D.Visible := Lb.Text <> '';
      Title3D.Width := Max(Height, 0.001);
      Title3D.Height := PANEL_PAD;
      Title3D.Position.X := Width/2 - SIZE_LABEL/2;
      Title3D.Position.Y := 0;
      Title3D.Position.Z := 0.002;
      Title3D.RotationAngle.Z := -90;
      Title3D.RotationAngle.Y := Lb.RotationAngle.Y;
      Title3D.Font.Size := 12;
    end;

  if not Assigned(ValueTexts3D) then Exit;
  ValueTexts3D.Clear;

  if (not Assigned(Sticker)) or (not Assigned(Sticker.info)) or
    (Sticker.info.blockCount <= 0) then Exit;

  Info := Sticker.info;
  BlockHeight := Height/Info.blockCount;
  TextHeight := Min(Max(BlockHeight*0.18, PANEL_PAD*0.45), PANEL_PAD*0.90);
  TextWidth := Max(Sticker.Width - WIDTH_LINE_TICK - GAP_LINE_NUMBER, 0.001);

  for I := 0 to Length(Info.blocks) - 1 do
    begin
      AxisText := TText3D.Create(Self);
      AxisText.Parent := Self;
      AxisText.HitTest := false;
      AxisText.Depth := 0.001;
      AxisText.WordWrap := false;
      AxisText.Stretch := true;
      AxisText.Width := TextWidth;
      AxisText.Height := TextHeight;
      AxisText.Text := Info.blocks[I].Text;
      AxisText.Font.Size := 12;
      AxisText.MaterialBackSource := TextMaterial;
      AxisText.MaterialShaftSource := TextMaterial;
      AxisText.MaterialSource := TextMaterial;
      AxisText.RotationAngle.Y := Sticker.RotationAngle.Y;
      AxisText.Position.Z := 0.002;

      if Tag = 1 then
        begin
          TextX := -Width/2 + WIDTH_LINE_TICK + GAP_LINE_NUMBER + TextWidth/2;
          AxisText.HorzTextAlign := TTextAlign.Leading;
        end
      else
        begin
          TextX := -Width/2 + TextWidth/2;
          AxisText.HorzTextAlign := TTextAlign.Trailing;
        end;

      TextY := -Height/2 + BlockHeight*(Info.blocks[I].pos + 0.5);
      AxisText.Position.X := TextX;
      AxisText.Position.Y := TextY;
      AxisText.VertTextAlign := TTextAlign.Center;

      ValueTexts3D.Add(AxisText);
    end;
end;

procedure TSticker.SetInfo(val: TInfoAxis);
begin
  info := val;
  if tag = 1 then
    OnPaint := Paint
  else
    OnPaint := PaintR;
  if Parent is TGroupSticker then
    TGroupSticker(Parent).RebuildText3D;
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
  Opacity := Stg.global.PlaneOpacity;
  Transparency := true;
  ZWrite := Stg.global.PlaneOpacity >= 1;
  TwoSide := true;
  Fill.Kind := TBrushKind.Solid;
  Fill.Color := Stg.global.XYPlaneBackgroundColor;
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
  Opacity := 1;
  ZWrite := Stg.global.PlaneOpacity >= 1;
  SetPanelFill(Stg.global.XZPlaneYZPlaneBackgroundColor, Stg.global.PlaneOpacity);

  Front := TZTestTextLayer3D.Create(Self);
  Front.Parent := Self;
  Front.Text := '';
  Front.HitTest := false;
  Front.DeleteChildren;
  Front.Resolution := DEFAULT_RESOLUTION;

  ZLabelTop := TZTestTextLayer3D.Create(Self);
  ZLabelTop.Parent := Self;
  ZLabelTop.Text := Stg.FZLabel;
  ZLabelTop.HitTest := false;
  ZLabelTop.Resolution := DEFAULT_RESOLUTION;
  ZLabelTop.RotationAngle.Z := -90;
  (ZLabelTop.Children[0] as TText).HitTest := false;


  ZlabelTop.Color := Stg.global.BarGraphFontColor;
  ZlabelTop.Font.Size := ZLabelTop.Resolution*PANEL_PAD;


  ZLabelBottom := TZTestTextLayer3D.Create(Self);
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
var
  FrontWidth, FrontHeight: Single;
  ZTopWidth, ZBottomWidth, ZLabelHeight: Single;
begin
  Width := SIZE_PANEL_TICKS;
  Height := RefPlane.Height + 2*PANEL_PAD;
  Depth := RefPlane.Depth;
  Position.Point := RefPlane.Position.Point + TPoint3D.Create(RefPlane.Width/2 + Width/2, 0, 0);

  FrontWidth := Width*(1 - SIZE_LABEL);
  FrontHeight := Height;
  Front.Resolution := SafeTextResolution(FrontWidth, FrontHeight);
  Front.Width := FrontWidth;
  Front.Height := FrontHeight;
  Front.Position.Point := TPoint3D.Create(-Width/2 + Front.Width/2, 0, -Depth/2 - 0.001);

  ZTopWidth := Stg.XZPlane.Height/2 + Stg.XYPlane.Position.Y;
  ZBottomWidth := Stg.XZPlane.Height - ZTopWidth;
  ZLabelHeight := Width - Front.Width;

  ZLabelTop.Text := Stg.FZLabel;
  ZLabelTop.Resolution := SafeTextResolution(ZTopWidth, ZLabelHeight);
  ZLabelTop.Font.Size := ZLabelTop.Resolution*PANEL_PAD;
  ZLabelTop.Width := ZTopWidth;
  ZLabelTop.Visible := ZLabelTop.Width > 0;
  ZLabelTop.Height := ZLabelHeight;
  ZLabelTop.Position.Point := Front.Position.Point +

  TPoint3D.Create(Front.Width/2 + ZLabelTop.Height/2, -RefPlane.Height/2 + ZLabelTop.Width/2, 0);
  //ZLabelTop.OnPaint := TempPaint;

  ZLabelBottom.Text := Stg.FZLabel;
  ZLabelBottom.Resolution := SafeTextResolution(ZBottomWidth, ZLabelHeight);
  ZLabelBottom.Font.Size := ZLabelBottom.Resolution*PANEL_PAD;
  ZLabelBottom.Width := ZBottomWidth;
  ZLabelBottom.Visible := ZLabelBottom.Width > 0;
  ZLabelBottom.Height := ZLabelHeight;
  ZLabelBottom.Position.Point := ZLabelTop.Position.Point + TPoint3D.Create(0, ZLabelTop.Width/2 + ZLabelBottom.Width/2, 0);

  tag := 1;
  ShowPositiveSpace;
end;

procedure TPanelTicks.SetPositionLeft(RefPlane: TRectangle3D);
var
  FrontWidth, FrontHeight: Single;
  ZTopWidth, ZBottomWidth, ZLabelHeight: Single;
begin
  Width := RefPlane.Width;
  Height := RefPlane.Height + 2*PANEL_PAD;

  Depth := SIZE_PANEL_TICKS;
  Position.Point := RefPlane.Position.Point + TPoint3D.Create(0, 0, -RefPlane.depth/2 - depth/2);

  FrontWidth := SIZE_PANEL_TICKS*(1 - SIZE_LABEL);
  FrontHeight := Height;
  Front.Resolution := SafeTextResolution(FrontWidth, FrontHeight);
  Front.Width := FrontWidth;
  Front.Height := FrontHeight;
  Front.RotationAngle.Y := -90;
  Front.Position.Point := TPoint3D.Create(Width/2 + 0.001, 0, Depth/2 - Front.Width/2);

  ZTopWidth := Stg.XZPlane.Height/2 + Stg.XYPlane.Position.Y;
  ZBottomWidth := Stg.XZPlane.Height - ZTopWidth;
  ZLabelHeight := Depth - Front.Width;

  ZLabelTop.Text := Stg.FZLabel;
  ZLabelTop.Resolution := SafeTextResolution(ZTopWidth, ZLabelHeight);
  ZLabelTop.Font.Size := ZLabelTop.Resolution*PANEL_PAD;
  ZLabelTop.Width := ZTopWidth;
  ZLabelTop.Visible := ZLabelTop.Width > 0;
  ZLabelTop.Height := ZLabelHeight;
  ZLabelTop.RotationAngle.Z := 90;
  ZLabelTop.RotationAngle.X := -90;
  ZLabelTop.Position.Point := Front.Position.Point +

  TPoint3D.Create(0, -RefPlane.Height/2 + ZLabelTop.Width/2, -Front.Width/2 - ZLabelTop.Height/2);

  //ZLabelBottom.OnPaint := TempPaint;

  ZLabelBottom.Text := Stg.FZLabel;
  ZLabelBottom.Resolution := SafeTextResolution(ZBottomWidth, ZLabelHeight);
  ZLabelBottom.Font.Size := ZLabelBottom.Resolution*PANEL_PAD;
  ZLabelBottom.Width := ZBottomWidth;
  ZLabelBottom.Visible := ZLabelBottom.Width > 0;
  ZLabelBottom.Height := ZLabelHeight;
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
var
  AxisRange: Single;
begin
  AxisRange := global.ZMax - global.ZMin;
  if SameValue(Height, 0) then
    Result := MIN_AXIS_RANGE
  else
    begin
      if SameValue(AxisRange, 0) then
        AxisRange := MIN_AXIS_RANGE;
      Result := AxisRange/Height;
    end;
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
  ColorPlaneXY.Color := MakeColor(global.XYPlaneBackgroundColor, global.PlaneOpacity);

  ColorPlane := TColorMaterialSource.Create(Self);
  ColorPlane.Color := MakeColor(global.XZPlaneYZPlaneBackgroundColor, global.PlaneOpacity);



  CreateXZPlane;
  CreateXYPlane;
  CreateYZPlane;

  BarContainer := TBarContainer.Create(Self);
  BarContainer.Parent := Self;
  BarContainer.FOnUpdate := ResizePlanes;

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


  Corner := TAlphaPanelRectangle3D.Create(Self);
  Corner.Parent := Self;
  Corner.Width := SIZE_PANEL_TICKS;
  Corner.Depth := Corner.Width;
  Corner.MaterialBackSource := ColorPlaneXY;
  Corner.MaterialShaftSource := ColorPlaneXY;
  Corner.MaterialSource := ColorPlaneXY;
  Corner.HitTest := false;
  Corner.Opacity := 1;
  Corner.ZWrite := global.PlaneOpacity >= 1;
  TAlphaPanelRectangle3D(Corner).SetPanelFill(global.XYPlaneBackgroundColor,
    global.PlaneOpacity);

  ResizePlanes;
  ApplyPlaneOpacity;

  XZPlane.OnRender := XZPlaneRender;
  YZPlane.OnRender := YZPlaneRender;
  XYPlane.OnRender := XYPlaneRender;
  OnRender := MainRender;

end;


procedure TMainContainer.Invalidate;
begin
  BarContainer.UpdatePositions;
  BarContainer.InvalidateSelected;

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
  P.Resolution := SafeTextResolution(Q.Width, PANEL_PAD);
  P.Width := Q.Width;
  P.Height := PANEL_PAD;
  P.Position.Y := -Q.Height/2 - P.Height/2;
  P.Invalidate;

  P := Q.FindComponent('BottomPanel') as TTextLayer3D;
  P.Resolution := SafeTextResolution(Q.Width, PANEL_PAD);
  P.Width := Q.Width;
  P.Height := PANEL_PAD;
  P.Position.Y := Q.Height/2 + P.Height/2;
  P.Invalidate;
end;

procedure TMainContainer.ResizeBordersL(Q: TRectangle3D);
var
  P: TTextLayer3D;
begin
  P := Q.FindComponent('TopPanel') as TTextLayer3D;

  P.Resolution := SafeTextResolution(Q.Depth, PANEL_PAD);
  P.Width := Q.Depth;
  P.Height := PANEL_PAD;
  P.Position.Y := -Q.Height/2 - P.Height/2;
  P.RotationAngle.Y := 90;
  P.Invalidate;

  P := Q.FindComponent('BottomPanel') as TTextLayer3D;
  P.Resolution := SafeTextResolution(Q.Depth, PANEL_PAD);
  P.Width := Q.Depth;
  P.Height := PANEL_PAD;
  P.Position.Y := Q.Height/2 + P.Height/2;
  P.RotationAngle.Y := 90;
  P.Invalidate;
end;

procedure TMainContainer.CreateYZPlane;
begin
  YZPlane := TTransparentRectangle3D.Create(Self);
  YZPlane.MaterialBackSource := ColorPlane;
  YZPlane.MaterialShaftSource := ColorPlane;
  YZPlane.MaterialSource := ColorPlane;
  YZPlane.Parent := Self;
  YZPlane.HitTest := false;
  YZPlane.Opacity := 1;
  YZPlane.ZWrite := global.PlaneOpacity >= 1;

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
  Context.SetContextState(TContextState.csAlphaBlendOn);
  Context.SetContextState(TContextState.csZTestOn);
  if global.PlaneOpacity >= 1 then
    Context.SetContextState(TContextState.csZWriteOn)
  else
    Context.SetContextState(TContextState.csZWriteOff);
  Context.FillCube(CenterPoint, TPoint3D.Create(YZPlane.Width, YZPlane.Height,
    YZPlane.Depth), global.PlaneOpacity, global.XZPlaneYZPlaneBackgroundColor);
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
  XZPlane := TTransparentRectangle3D.Create(Self);
  XZPlane.MaterialBackSource := ColorPlane;
  XZPlane.MaterialShaftSource := ColorPlane;
  XZPlane.MaterialSource := ColorPlane;
  XZPlane.Parent := Self;
  XZPlane.HitTest := false;
  XZPlane.Opacity := 1;
  XZPlane.ZWrite := global.PlaneOpacity >= 1;

  CreateBorderPanels(XZPlane);
end;

procedure TMainContainer.CreateBorderPanels(P: TRectangle3D);
var
  Panel: TTextLayer3D;
begin
  Panel := TZTestTextLayer3D.Create(P);
  Panel.Name := 'TopPanel';
  Panel.Parent := P;
  Panel.HitTest := false;
  Panel.Opacity := global.PlaneOpacity;
  Panel.Transparency := true;
  Panel.ZWrite := global.PlaneOpacity >= 1;
  (Panel.Children[0] as TText).HitTest := false;
  Panel.OnPaint := PanelPaint;

  Panel := TZTestTextLayer3D.Create(P);
  Panel.Name := 'BottomPanel';
  Panel.Parent := P;
  Panel.HitTest := false;
  Panel.Opacity := global.PlaneOpacity;
  Panel.Transparency := true;
  Panel.ZWrite := global.PlaneOpacity >= 1;
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
  Context.SetContextState(TContextState.csAlphaBlendOn);
  Context.SetContextState(TContextState.csZTestOn);
  if global.PlaneOpacity >= 1 then
    Context.SetContextState(TContextState.csZWriteOn)
  else
    Context.SetContextState(TContextState.csZWriteOff);
  Context.FillCube(CenterPoint, TPoint3D.Create(XZPlane.Width, XZPlane.Height,
    XZPlane.Depth), global.PlaneOpacity, global.XZPlaneYZPlaneBackgroundColor);
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
  ColorPlaneXY.Color := MakeColor(global.XYPlaneBackgroundColor, global.PlaneOpacity);
  ColorPlane.Color := MakeColor(global.XZPlaneYZPlaneBackgroundColor, global.PlaneOpacity);

  {
  (Corner.MaterialBackSource as TColorMaterialSource).Color := global.XYPlaneBackgroundColor;
  (Corner.MaterialShaftSource as TColorMaterialSource).Color := global.XYPlaneBackgroundColor;
  (Corner.MaterialSource as TColorMaterialSource).Color := global.XYPlaneBackgroundColor;
  }
end;

procedure TMainContainer.ApplyPlaneOpacity;
var
  UseZWrite: Boolean;

  procedure ApplyRect(Rect: TRectangle3D; AColor: TAlphaColor);
  var
    BorderPanel: TComponent;
  begin
    if not Assigned(Rect) then Exit;

    Rect.Opacity := 1;
    Rect.ZWrite := UseZWrite;

    if Rect is TAlphaPanelRectangle3D then
      TAlphaPanelRectangle3D(Rect).SetPanelFill(AColor, global.PlaneOpacity);

    if Rect.MaterialBackSource is TColorMaterialSource then
      TColorMaterialSource(Rect.MaterialBackSource).Color := MakeColor(AColor, global.PlaneOpacity);
    if Rect.MaterialShaftSource is TColorMaterialSource then
      TColorMaterialSource(Rect.MaterialShaftSource).Color := MakeColor(AColor, global.PlaneOpacity);
    if Rect.MaterialSource is TColorMaterialSource then
      TColorMaterialSource(Rect.MaterialSource).Color := MakeColor(AColor, global.PlaneOpacity);

    BorderPanel := Rect.FindComponent('TopPanel');
    if BorderPanel is TTextLayer3D then
      begin
        TTextLayer3D(BorderPanel).Opacity := global.PlaneOpacity;
        TTextLayer3D(BorderPanel).Transparency := true;
        TTextLayer3D(BorderPanel).ZWrite := UseZWrite;
        TTextLayer3D(BorderPanel).Invalidate;
      end;

    BorderPanel := Rect.FindComponent('BottomPanel');
    if BorderPanel is TTextLayer3D then
      begin
        TTextLayer3D(BorderPanel).Opacity := global.PlaneOpacity;
        TTextLayer3D(BorderPanel).Transparency := true;
        TTextLayer3D(BorderPanel).ZWrite := UseZWrite;
        TTextLayer3D(BorderPanel).Invalidate;
      end;
  end;

  procedure ApplySticker(Group: TGroupSticker; AOpacity: Single;
    UseFillAlpha: Boolean = false);
  var
    StickerZWrite: Boolean;
  begin
    if not Assigned(Group) then Exit;

    StickerZWrite := AOpacity >= 1;
    Group.Invalidate;
    if Assigned(Group.Lb) then
      begin
        Group.Lb.Visible := Group.Visible;
        Group.Lb.Transparency := true;
        Group.Lb.ZWrite := StickerZWrite;
        Group.Lb.TwoSide := true;
        if UseFillAlpha then
          begin
            Group.Lb.Opacity := 1;
            Group.Lb.Fill.Color := MakeColor(global.XYPlaneBackgroundColor, AOpacity);
            Group.Lb.Fill.Kind := TBrushKind.Solid;
          end
        else
          begin
            Group.Lb.Opacity := AOpacity;
            Group.Lb.Fill.Color := global.XYPlaneBackgroundColor;
            Group.Lb.Fill.Kind := TBrushKind.Solid;
          end;
        Group.Lb.Invalidate;
      end;
    if Assigned(Group.Sticker) then
      begin
        Group.Sticker.Visible := Group.Visible;
        Group.Sticker.Transparency := true;
        Group.Sticker.ZWrite := StickerZWrite;
        Group.Sticker.TwoSide := true;
        if UseFillAlpha then
          begin
            Group.Sticker.Opacity := 1;
            Group.Sticker.Fill.Color := MakeColor(global.XYPlaneBackgroundColor, AOpacity);
            Group.Sticker.Fill.Kind := TBrushKind.Solid;
          end
        else
          begin
            Group.Sticker.Opacity := AOpacity;
            Group.Sticker.Fill.Color := global.XYPlaneBackgroundColor;
            Group.Sticker.Fill.Kind := TBrushKind.Solid;
          end;
        Group.Sticker.Invalidate;
      end;
  end;

begin
  SetColor;
  UseZWrite := global.PlaneOpacity >= 1;

  ApplyRect(XYPlane, global.XYPlaneBackgroundColor);
  ApplyRect(XZPlane, global.XZPlaneYZPlaneBackgroundColor);
  ApplyRect(YZPlane, global.XZPlaneYZPlaneBackgroundColor);
  ApplyRect(Corner, global.XYPlaneBackgroundColor);

  if Assigned(PanelRightTicks) then
    begin
      ApplyRect(PanelRightTicks, global.XZPlaneYZPlaneBackgroundColor);
      PanelRightTicks.Invalidate;
    end;

  if Assigned(PanelLeftTicks) then
    begin
      ApplyRect(PanelLeftTicks, global.XZPlaneYZPlaneBackgroundColor);
      PanelLeftTicks.Invalidate;
    end;

  if Assigned(AxisXPanel) then
    begin
      AxisXPanel.TopSticker.Visible := true;
      AxisXPanel.BottomSticker.Visible := false;
      ApplySticker(AxisXPanel.TopSticker, global.PlaneOpacity);
    end;

  if Assigned(AxisYPanel) then
    begin
      AxisYPanel.TopSticker.Visible := true;
      AxisYPanel.BottomSticker.Visible := false;
      ApplySticker(AxisYPanel.TopSticker, global.PlaneOpacity);
    end;
end;


procedure TMainContainer.CreateXYPlane;
begin
  XYPlane := TTransparentRectangle3D.Create(Self);
  XYPlane.MaterialBackSource := ColorPlaneXY;
  XYPlane.MaterialShaftSource := ColorPlaneXY;
  XYPlane.MaterialSource := ColorPlaneXY;
  XYPlane.Parent := Self;
  XYPlane.HitTest := false;
  XYPlane.OnClick := (Boss as TBarGraph).ViewportClick;
  XYPlane.Opacity := 1;
  XYPlane.ZWrite := global.PlaneOpacity >= 1;
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
  Context.SetContextState(TContextState.csAlphaBlendOn);
  Context.SetContextState(TContextState.csZTestOn);
  if global.PlaneOpacity >= 1 then
    Context.SetContextState(TContextState.csZWriteOn)
  else
    Context.SetContextState(TContextState.csZWriteOff);
  Context.FillCube(CenterPoint, TPoint3D.Create(XYPlane.Width, XYPlane.Height,
    XYPlane.Depth), global.PlaneOpacity, global.XYPlaneBackgroundColor);
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

function TBarContainer.LastSelected: TBar;
var
  I: Integer;
  b: TBar;
begin
  for I := 0 to ChildrenCount - 1 do
    if Children[I] is TBar then
      begin
        b := Children[I] as TBar;
        if b.isSelected then Exit(b);
      end;
  Result := Nil;
end;

procedure TBarContainer.ChangeCamera;
var
  gb: TBarGraph;
begin
  gb := Stg.Boss as TBarGraph;
  gb.Camera := gb.PackCamera.cam;
  RotateLegend;
end;

procedure TBarContainer.RotateLegend;
var
  gb: TBarGraph;
  PackCamera: TMyCamera;
  BearingTop, BearingMiddle: TDummy;
begin
  if (Legend.Visible) and Assigned(Legend.bar) then
    begin
      gb := Stg.Parent as TBarGraph;
      PackCamera := gb.Camera.Parent as TMyCamera;
      BearingMiddle := PackCamera.Parent as TDummy;
      BearingTop := BearingMiddle.Parent as TDummy;
      with BearingTop.RotationAngle do
        if Legend.bar.val >= 0 then
          Legend.RotationAngle.Y := 180 + Y
        else
          Legend.RotationAngle.Y := 90 - Y;
    end;
end;

procedure TBarContainer.BarMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Single; RayPos, RayDir: TVector3D);
var
  gb: TBarGraph;
begin
  gb := Stg.Boss as TBarGraph;
  gb.BarMouseMove(Sender, Shift, X, Y);
end;

procedure TBarContainer.BarMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single; RayPos, RayDir: TVector3D);
var
  gb: TBarGraph;
begin
  gb := Stg.Boss as TBarGraph;
  gb.BarMouseDown(Sender, Button, Shift, X, Y);
end;

procedure TBarContainer.BarMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single; RayPos, RayDir: TVector3D);
var
  gb: TBarGraph;
begin
  gb := Stg.Boss as TBarGraph;

  if (Button = TMouseButton.mbLeft) and (ActiveRenderMode = brMesh) and
    (Sender is TMesh) and (not gb.FDragMoved) then
    begin
      gb.Status := 'static';
      if gb.TrySelectMeshAt(PointF(X, Y)) then
        begin
          gb.Tag := 1;
        end;
      Exit;
    end;

  gb.BarMouseUp(Sender, Button, Shift, X, Y);
end;

procedure TBarContainer.InitCamera;
var
  gb: TBarGraph;
begin
  gb := Stg.Boss as TBarGraph;
  if gb.Camera = PackCamera.cam then
    begin
      if Legend.bar.val >= 0 then
        BearingTop.Position.Point := Legend.Position.Point + TPoint3D.Create(0, -Legend.Height, 0)
      else
        BearingTop.Position.Point := Legend.Position.Point + TPoint3D.Create(0, Legend.Height, 0);
      BearingTop.RotationAngle.Y := -45;
      BearingMiddle.RotationAngle.X := -10;
      PackCamera.Position.Z := 0;
    end;
end;

procedure TBarContainer.LegendClick(Sender: TObject);
var
  gb: TBarGraph;
begin
  gb := Stg.Boss as TBarGraph;
  gb.Camera := PackCamera.cam;
  InitCamera;
  RotateLegend;
end;

procedure TBarContainer.UnSelected(SelectedBar: TBar = Nil);
var
  last: TBar;
begin
  last := LastSelected;
  if (last <> Nil) and (last <> SelectedBar) then last.isSelected := false;

  if (SelectedBar = Nil) or ((last <> Nil) and (last = SelectedBar)) then
    ChangeCamera;

  if SelectedBar <> FMeshSelectionBar then
    ClearMeshSelection;

  Legend.Visible := false;
  Legend.RotationAngle.y := 135;
  Legend.RotationAngle.X := 0;
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
      gb.Tag := 1;

      if bar.isSelected then
        begin
          Legend.bar := bar;
          Legend.Data := Stg.RequestData(bar);
          Legend.Visible := true;
          Legend.Invalidate;
          PositionLegendForBar(bar);

          InitCamera;
          RotateLegend;
        end;
    end;
end;

procedure TBarContainer.PositionLegendForBar(bar: TBar);
begin
  if not Assigned(bar) then Exit;

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
end;

constructor TBarContainer.Create(AOwner: TComponent);
begin
  inherited;
  Stg := AOwner as TMainContainer;
  FBarIndex := TDictionary<Int64, TBar>.Create;
  FDataIndex := TDictionary<Int64, Integer>.Create;
  FBarData := TList<TBarData>.Create;
  FMeshGroups := TObjectList<TMesh>.Create(true);
  FMeshDataIndexes := TObjectDictionary<TMesh, TList<Integer>>.Create([doOwnsValues]);
  FRenderMode := brAuto;
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

  FMeshSelectionBar := TBar.Create(Self);
  FMeshSelectionBar.Name := 'MeshSelectionBar';
  FMeshSelectionBar.Parent := Self;
  FMeshSelectionBar.Visible := false;
  FMeshSelectionBar.HitTest := false;
  FMeshSelectionBar.AutoCapture := false;
  FMeshSelectionBar.FRenderBody := false;
  FMeshSelectionBar.Width := BAR_WIDTH;
  FMeshSelectionBar.Depth := BAR_DEPTH;
  FMeshSelectionBar.SubdivisionsHeight := 1;
  FMeshSelectionBar.SubdivisionsDepth := 1;
  FMeshSelectionBar.SubdivisionsWidth := 1;

  BearingTop := TDummy.Create(Self);
  AddObject(BearingTop);
  BearingMiddle := TDummy.Create(Self);
  BearingTop.AddObject(BearingMiddle);
  PackCamera := TMyCamera.Create(self);
  PackCamera.cam.Target := Legend;
  BearingMiddle.AddObject(PackCamera);
end;

destructor TBarContainer.Destroy;
begin
  FMeshGroups.Free;
  FMeshDataIndexes.Free;
  FBarData.Free;
  FDataIndex.Free;
  FBarIndex.Free;
  inherited;
end;

procedure TBar.BarRender(Sender: TObject; Context: TContext3D);
begin
  if FIsSelected then
    begin
      if FRenderBody then
        Context.DrawCube(TPoint3D.Zero, TPoint3D.Create(1, 1, 1), 1, claBlack)
      else
        Context.DrawCube(TPoint3D.Zero, TPoint3D.Create(Width, Height, Depth), 1, claBlack);
    end;
end;

constructor TBar.Create(AOwner: TComponent);
begin
  inherited;
  Stg := (AOwner as TBarContainer).Stg;
  FIsSelected := false;
  FRenderBody := true;
  FMaterial := TLightMaterialSource.Create(Self);
  FMaterial.Shininess := 10;
  MaterialSource := FMaterial;
  OnRender := BarRender;
end;

procedure TBar.Render;
begin
  if FRenderBody then
    inherited;
end;

procedure TBar.SetColor(val: TAlphaColor);
begin
  if not Assigned(FMaterial) then
    begin
      FMaterial := TLightMaterialSource.Create(Self);
      FMaterial.Shininess := 10;
      MaterialSource := FMaterial;
    end;

  FMaterial.Ambient := val;
  FMaterial.Emissive := val;
  FMaterial.Specular := val;
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

function TBarContainer.BarKey(row, col: Integer): Int64;
begin
  Result := (Int64(row) shl 32) or Int64(Cardinal(col));
end;

function TBarContainer.ActiveRenderMode: TBarRenderMode;
begin
  Result := FRenderMode;
  if Result = brAuto then
    begin
      if FBarData.Count >= MESH_RENDER_THRESHOLD then
        Result := brMesh
      else
        Result := brCubes;
    end;
end;

function TBarContainer.UpsertBarData(row, col: Integer; Value: Single; cl: TAlphaColor;
  out OldValue: Single; out ExistingBar: Boolean): Integer;
var
  key: Int64;
  data: TBarData;
begin
  key := BarKey(row, col);
  ExistingBar := FDataIndex.TryGetValue(key, Result);

  if ExistingBar then
    begin
      data := FBarData[Result];
      OldValue := data.val;
      data.val := Value;
      data.color := cl;
      FBarData[Result] := data;
    end
  else
    begin
      OldValue := Value;
      data.row := row;
      data.col := col;
      data.val := Value;
      data.color := cl;
      Result := FBarData.Count;
      FBarData.Add(data);
      FDataIndex.Add(key, Result);
    end;

  FMeshDirty := true;
end;

procedure TBarContainer.BeginDataUpdate;
begin
  Inc(FUpdateLock);
end;

procedure TBarContainer.EndDataUpdate;
begin
  if FUpdateLock > 0 then
    Dec(FUpdateLock);

  if FUpdateLock = 0 then
    ApplyPendingLayout;
end;

procedure TBarContainer.RequestLayoutUpdate(UpdateCamera: Boolean);
begin
  FNeedsLayoutUpdate := true;
  FNeedsCameraUpdate := FNeedsCameraUpdate or UpdateCamera;

  if FUpdateLock = 0 then
    ApplyPendingLayout;
end;

procedure TBarContainer.ApplyPendingLayout;
var
  UpdateCamera: Boolean;
begin
  if not FNeedsLayoutUpdate then Exit;

  UpdateCamera := FNeedsCameraUpdate;
  FNeedsLayoutUpdate := false;
  FNeedsCameraUpdate := false;

  if Assigned(FOnUpdate) then FOnUpdate;
  UpdatePositions;

  if UpdateCamera and Assigned(Stg) and Assigned(Stg.Parent) and (Stg.Parent is TBarGraph) then
    (Stg.Parent as TBarGraph).UpdateCameraPosition;

  ApplyRenderMode;
end;

procedure TBarContainer.ApplyRenderMode;
begin
  if ActiveRenderMode = brMesh then
    begin
      SetCubeVisibility(false);
      if FMeshDirty then
        RebuildMesh;
    end
  else
    begin
      ClearMeshGroups;
      SetCubeVisibility(true);
    end;
end;

procedure TBarContainer.SetRenderMode(val: TBarRenderMode);
begin
  if FRenderMode <> val then
    begin
      FRenderMode := val;
      FMeshDirty := true;
      RequestLayoutUpdate(false);
    end;
end;

procedure TBarContainer.SetCubeVisibility(Visible: Boolean);
var
  I: Integer;
  bar: TBar;
begin
  for I := 0 to ChildrenCount - 1 do
    if Children[I] is TBar then
      begin
        bar := Children[I] as TBar;
        if bar <> FMeshSelectionBar then
          bar.Visible := Visible;
      end;

  if Visible then
    ClearMeshSelection;
end;

procedure TBarContainer.ClearMeshGroups;
begin
  FMeshDataIndexes.Clear;
  FMeshGroups.Clear;
  FMeshDirty := true;
end;

procedure TBarContainer.RebuildMesh;
var
  Groups: TObjectDictionary<TAlphaColor, TList<Integer>>;
  Items: TList<Integer>;
  Pair: TPair<TAlphaColor, TList<Integer>>;
  I, StartIndex, ChunkCount: Integer;
begin
  FMeshDataIndexes.Clear;
  FMeshGroups.Clear;

  Groups := TObjectDictionary<TAlphaColor, TList<Integer>>.Create([doOwnsValues]);
  try
    for I := 0 to FBarData.Count - 1 do
      begin
        if not Groups.TryGetValue(FBarData[I].color, Items) then
          begin
            Items := TList<Integer>.Create;
            Groups.Add(FBarData[I].color, Items);
          end;
        Items.Add(I);
      end;

    for Pair in Groups do
      begin
        StartIndex := 0;
        while StartIndex < Pair.Value.Count do
          begin
            ChunkCount := Min(MESH_BARS_PER_CHUNK, Pair.Value.Count - StartIndex);
            BuildMeshChunk(Pair.Key, Pair.Value, StartIndex, ChunkCount);
            Inc(StartIndex, ChunkCount);
          end;
      end;
  finally
    Groups.Free;
  end;

  FMeshDirty := false;
end;

procedure TBarContainer.ClearMeshSelection;
begin
  if Assigned(FMeshSelectionBar) then
    begin
      FMeshSelectionBar.Visible := false;
      FMeshSelectionBar.FIsSelected := false;
    end;
end;

procedure TBarContainer.GetBarBox(const AData: TBarData; out Center: TPoint3D;
  out BarHeight: Single);
var
  RefPoint, TopLeft: TPoint3D;
  WB, DB, DH: Single;
begin
  BarHeight := Abs(AData.val/Stg.Scale);
  WB := BAR_WIDTH + 2*BAR_PAD;
  DB := BAR_DEPTH + 2*BAR_PAD;
  RefPoint := TPoint3D.Create(-ColCount*WB/2, 0, RowCount*DB/2);
  TopLeft := TPoint3D.Create(AData.col*WB, 0, -AData.row*DB);

  if AData.val >= 0 then
    DH := -BarHeight/2
  else
    DH := BarHeight/2;

  Center := RefPoint + TopLeft + TPoint3D.Create(WB/2, DH, -DB/2);
end;

function PointInTriangle2D(const P, A, B, C: TPointF): Boolean;
var
  D1, D2, D3: Single;
  HasNeg, HasPos: Boolean;

  function Sign2D(const P1, P2, P3: TPointF): Single;
  begin
    Result := (P1.X - P3.X)*(P2.Y - P3.Y) - (P2.X - P3.X)*(P1.Y - P3.Y);
  end;

begin
  D1 := Sign2D(P, A, B);
  D2 := Sign2D(P, B, C);
  D3 := Sign2D(P, C, A);

  HasNeg := (D1 < 0) or (D2 < 0) or (D3 < 0);
  HasPos := (D1 > 0) or (D2 > 0) or (D3 > 0);
  Result := not (HasNeg and HasPos);
end;

function TBarContainer.TryPickMeshBarAtScreen(const P: TPointF; out DataIndex: Integer): Boolean;
var
  gb: TBarGraph;
  I, J: Integer;
  Center, CameraPos, FaceCenter: TPoint3D;
  BarHeight, PickHeight: Single;
  X0, X1, Y0, Y1, Z0, Z1: Single;
  Corners: array[0..7] of TPoint3D;
  ScreenCorners: array[0..7] of TPoint3D;
  MinX, MaxX, MinY, MaxY: Single;
  BestDistance, DistanceToFace: Single;
  CandidateIndex: Integer;

  procedure CheckTriangle(A, B, C: Integer);
  begin
    if not PointInTriangle2D(P,
      PointF(ScreenCorners[A].X, ScreenCorners[A].Y),
      PointF(ScreenCorners[B].X, ScreenCorners[B].Y),
      PointF(ScreenCorners[C].X, ScreenCorners[C].Y)) then
      Exit;

    FaceCenter := (TPoint3D(LocalToAbsolute3D(Corners[A])) +
      TPoint3D(LocalToAbsolute3D(Corners[B])) +
      TPoint3D(LocalToAbsolute3D(Corners[C]))) * (1/3);
    DistanceToFace := CameraPos.Distance(FaceCenter);
    if DistanceToFace < BestDistance then
      begin
        BestDistance := DistanceToFace;
        CandidateIndex := I;
        Result := true;
      end;
  end;

begin
  Result := false;
  DataIndex := -1;
  CandidateIndex := -1;
  BestDistance := MaxSingle;

  if ActiveRenderMode <> brMesh then
    Exit;

  if not Assigned(Stg) or not Assigned(Stg.Boss) or not (Stg.Boss is TBarGraph) then
    Exit;

  gb := Stg.Boss as TBarGraph;
  if not Assigned(gb.Context) or not Assigned(gb.Camera) then
    Exit;

  CameraPos := TPoint3D(gb.Camera.AbsolutePosition);

  for I := 0 to FBarData.Count - 1 do
    begin
      GetBarBox(FBarData[I], Center, BarHeight);
      PickHeight := Max(MIN_BAR_PICK_HEIGHT, BarHeight);

      X0 := Center.X - BAR_WIDTH/2;
      X1 := Center.X + BAR_WIDTH/2;
      Y0 := Center.Y - PickHeight/2;
      Y1 := Center.Y + PickHeight/2;
      Z0 := Center.Z - BAR_DEPTH/2;
      Z1 := Center.Z + BAR_DEPTH/2;

      Corners[0] := TPoint3D.Create(X0, Y0, Z0);
      Corners[1] := TPoint3D.Create(X1, Y0, Z0);
      Corners[2] := TPoint3D.Create(X1, Y1, Z0);
      Corners[3] := TPoint3D.Create(X0, Y1, Z0);
      Corners[4] := TPoint3D.Create(X0, Y0, Z1);
      Corners[5] := TPoint3D.Create(X1, Y0, Z1);
      Corners[6] := TPoint3D.Create(X1, Y1, Z1);
      Corners[7] := TPoint3D.Create(X0, Y1, Z1);

      MinX := MaxSingle;
      MinY := MaxSingle;
      MaxX := -MaxSingle;
      MaxY := -MaxSingle;
      for J := 0 to 7 do
        begin
          ScreenCorners[J] := gb.Context.WorldToScreen(TProjection.Camera,
            TPoint3D(LocalToAbsolute3D(Corners[J])));
          MinX := Min(MinX, ScreenCorners[J].X);
          MaxX := Max(MaxX, ScreenCorners[J].X);
          MinY := Min(MinY, ScreenCorners[J].Y);
          MaxY := Max(MaxY, ScreenCorners[J].Y);
        end;

      if (P.X < MinX) or (P.X > MaxX) or (P.Y < MinY) or (P.Y > MaxY) then
        Continue;

      CheckTriangle(0, 1, 5);
      CheckTriangle(5, 4, 0);
      CheckTriangle(3, 2, 6);
      CheckTriangle(6, 7, 3);
      CheckTriangle(0, 4, 7);
      CheckTriangle(7, 3, 0);
      CheckTriangle(1, 2, 6);
      CheckTriangle(6, 5, 1);
      CheckTriangle(0, 3, 2);
      CheckTriangle(2, 1, 0);
      CheckTriangle(4, 5, 6);
      CheckTriangle(6, 7, 4);
    end;

  if Result then
    DataIndex := CandidateIndex;
end;

function TBarContainer.TryPickMeshBar(const RayPos, RayDir: TPoint3D; out DataIndex: Integer;
  out Intersection: TPoint3D): Boolean;
var
  I, HitCount: Integer;
  Center, NearHit, FarHit: TPoint3D;
  BarHeight, PickHeight, DistanceToHit, BestDistance: Single;
begin
  Result := false;
  DataIndex := -1;
  BestDistance := MaxSingle;

  if ActiveRenderMode <> brMesh then
    Exit;

  for I := 0 to FBarData.Count - 1 do
    begin
      GetBarBox(FBarData[I], Center, BarHeight);
      PickHeight := Max(MIN_BAR_PICK_HEIGHT, BarHeight);
      HitCount := RayCastCuboidIntersect(RayPos, RayDir, Center, BAR_WIDTH,
        PickHeight, BAR_DEPTH, NearHit, FarHit);

      if HitCount > 0 then
        begin
          DistanceToHit := RayPos.Distance(NearHit);
          if DistanceToHit < BestDistance then
            begin
              BestDistance := DistanceToHit;
              DataIndex := I;
              Intersection := NearHit;
              Result := true;
            end;
        end;
    end;
end;

function TBarContainer.TryPickMeshCell(const RayPos, RayDir: TPoint3D; out DataIndex: Integer;
  out Intersection: TPoint3D): Boolean;
var
  WB, DB, RefX, RefZ: Single;
  Row, Col: Integer;
begin
  Result := false;
  DataIndex := -1;

  if ActiveRenderMode <> brMesh then
    Exit;

  if not RayCastPlaneIntersect(RayPos, RayDir, TPoint3D.Zero, TPoint3D.Create(0, 1, 0),
    Intersection) then
    Exit;

  WB := BAR_WIDTH + 2*BAR_PAD;
  DB := BAR_DEPTH + 2*BAR_PAD;
  RefX := -ColCount*WB/2;
  RefZ := RowCount*DB/2;

  Col := Floor((Intersection.X - RefX)/WB);
  Row := Floor((RefZ - Intersection.Z)/DB);

  if (Row < 0) or (Row >= RowCount) or (Col < 0) or (Col >= ColCount) then
    Exit;

  Result := FDataIndex.TryGetValue(BarKey(Row, Col), DataIndex);
end;

function TBarContainer.TryPickMeshTriangles(AMesh: TMesh; const RayPos, RayDir: TPoint3D;
  out DataIndex: Integer; out Intersection: TPoint3D): Boolean;
var
  BestDistance: Single;
  Found: Boolean;

  procedure CheckMesh(LMesh: TMesh);
  var
    Items: TList<Integer>;
    TriIndex, BarOffset: Integer;
    I0, I1, I2: Integer;
    P0, P1, P2, Hit: TPoint3D;
    DistanceToHit: Single;
  begin
    if not Assigned(LMesh) then Exit;
    if not FMeshDataIndexes.TryGetValue(LMesh, Items) then Exit;

    for TriIndex := 0 to (LMesh.Data.IndexBuffer.Length div 3) - 1 do
      begin
        I0 := LMesh.Data.IndexBuffer.Indices[TriIndex*3 + 0];
        I1 := LMesh.Data.IndexBuffer.Indices[TriIndex*3 + 1];
        I2 := LMesh.Data.IndexBuffer.Indices[TriIndex*3 + 2];

        P0 := LMesh.Data.VertexBuffer.Vertices[I0];
        P1 := LMesh.Data.VertexBuffer.Vertices[I1];
        P2 := LMesh.Data.VertexBuffer.Vertices[I2];

        if RayCastTriangleIntersect(RayPos, RayDir, P0, P1, P2, Hit) then
          begin
            DistanceToHit := RayPos.Distance(Hit);
            if DistanceToHit < BestDistance then
              begin
                BarOffset := TriIndex div MESH_TRIANGLES_PER_BAR;
                if (BarOffset >= 0) and (BarOffset < Items.Count) then
                  begin
                    BestDistance := DistanceToHit;
                    DataIndex := Items[BarOffset];
                    Intersection := Hit;
                    Found := true;
                  end;
              end;
          end;
      end;
  end;

var
  I: Integer;
begin
  Found := false;
  DataIndex := -1;
  BestDistance := MaxSingle;

  if ActiveRenderMode <> brMesh then
    Exit(false);

  if Assigned(AMesh) then
    CheckMesh(AMesh)
  else
    for I := 0 to FMeshGroups.Count - 1 do
      CheckMesh(FMeshGroups[I]);

  Result := Found;
end;

function TBarContainer.SelectMeshDataIndex(DataIndex: Integer): Boolean;
var
  data: TBarData;
begin
  Result := false;
  if (DataIndex < 0) or (DataIndex >= FBarData.Count) then
    Exit;

  data := FBarData[DataIndex];
  UnSelected(FMeshSelectionBar);

  FMeshSelectionBar.row := data.row;
  FMeshSelectionBar.col := data.col;
  FMeshSelectionBar.val := data.val;
  FMeshSelectionBar.fcolor := data.color;
  FMeshSelectionBar.SetPosition(RowCount, ColCount);
  FMeshSelectionBar.Width := BAR_WIDTH + 2*SELECTION_BAR_PAD;
  FMeshSelectionBar.Depth := BAR_DEPTH + 2*SELECTION_BAR_PAD;
  FMeshSelectionBar.Height := Max(MIN_BAR_PICK_HEIGHT, Abs(data.val/Stg.Scale)) +
    2*SELECTION_BAR_PAD;
  FMeshSelectionBar.FIsSelected := false;
  FMeshSelectionBar.isSelected := true;
  FMeshSelectionBar.Visible := false;

  Legend.bar := FMeshSelectionBar;
  Legend.Data := Stg.RequestData(FMeshSelectionBar);
  Legend.Visible := true;
  Legend.Invalidate;
  PositionLegendForBar(FMeshSelectionBar);

  InitCamera;
  RotateLegend;
  (Stg.Boss as TBarGraph).Invalidate;
  Result := true;
end;

function TBarContainer.SelectMeshBarFromRay(const RayPos, RayDir: TPoint3D): Boolean;
var
  DataIndex: Integer;
  Intersection: TPoint3D;
begin
  Result := TryPickMeshBar(RayPos, RayDir, DataIndex, Intersection);

  if not Result then
    Exit;

  Result := SelectMeshDataIndex(DataIndex);
end;

function TBarContainer.SelectMeshBarAtScreen(const P: TPointF): Boolean;
var
  DataIndex: Integer;
begin
  Result := TryPickMeshBarAtScreen(P, DataIndex);
  if not Result then
    Exit;

  Result := SelectMeshDataIndex(DataIndex);
end;

function TBarContainer.SelectMeshBarFromMeshRay(AMesh: TMesh; const RayPos, RayDir: TPoint3D): Boolean;
var
  DataIndex: Integer;
  Intersection: TPoint3D;
begin
  Result := TryPickMeshTriangles(AMesh, RayPos, RayDir, DataIndex, Intersection);
  if not Result then
    Exit;

  Result := SelectMeshDataIndex(DataIndex);
end;

procedure TBarContainer.BuildMeshChunk(AColor: TAlphaColor; const AIndexes: TList<Integer>;
  AStart, ACount: Integer);
var
  mesh: TMesh;
  mat: TLightMaterialSource;
  meshIndexes: TList<Integer>;
  I: Integer;
begin
  if ACount <= 0 then Exit;

  mesh := TMesh.Create(Self);
  mesh.Parent := Self;
  mesh.HitTest := true;
  mesh.AutoCapture := true;
  mesh.OnMouseDown := BarMouseDown;
  mesh.OnMouseMove := BarMouseMove;
  mesh.OnMouseUp := BarMouseUp;
  mesh.TwoSide := true;
  mesh.WrapMode := TMeshWrapMode.Original;
  mesh.Width := 1;
  mesh.Height := 1;
  mesh.Depth := 1;

  mat := TLightMaterialSource.Create(mesh);
  mat.Shininess := 10;
  mat.Ambient := AColor;
  mat.Emissive := AColor;
  mat.Specular := AColor;
  mesh.MaterialSource := mat;

  mesh.Data.VertexBuffer.Length := ACount*MESH_VERTICES_PER_BAR;
  mesh.Data.IndexBuffer.Length := ACount*MESH_INDICES_PER_BAR;

  meshIndexes := TList<Integer>.Create;
  meshIndexes.Capacity := ACount;

  for I := 0 to ACount - 1 do
    begin
      meshIndexes.Add(AIndexes[AStart + I]);
      AddMeshBar(mesh, FBarData[AIndexes[AStart + I]], I*MESH_VERTICES_PER_BAR,
        I*MESH_INDICES_PER_BAR);
    end;

  FMeshGroups.Add(mesh);
  FMeshDataIndexes.Add(mesh, meshIndexes);
end;

procedure TBarContainer.AddMeshBar(AMesh: TMesh; const AData: TBarData; AVertexBase,
  AIndexBase: Integer);
var
  Center: TPoint3D;
  BarHeight: Single;
  X0, X1, Y0, Y1, Z0, Z1: Single;
  V, Idx: Integer;

  procedure AddFace(const P0, P1, P2, P3, Normal: TPoint3D);
  begin
    AMesh.Data.VertexBuffer.Vertices[V + 0] := P0;
    AMesh.Data.VertexBuffer.Vertices[V + 1] := P1;
    AMesh.Data.VertexBuffer.Vertices[V + 2] := P2;
    AMesh.Data.VertexBuffer.Vertices[V + 3] := P3;

    AMesh.Data.VertexBuffer.Normals[V + 0] := Normal;
    AMesh.Data.VertexBuffer.Normals[V + 1] := Normal;
    AMesh.Data.VertexBuffer.Normals[V + 2] := Normal;
    AMesh.Data.VertexBuffer.Normals[V + 3] := Normal;

    AMesh.Data.VertexBuffer.TexCoord0[V + 0] := PointF(0, 0);
    AMesh.Data.VertexBuffer.TexCoord0[V + 1] := PointF(1, 0);
    AMesh.Data.VertexBuffer.TexCoord0[V + 2] := PointF(1, 1);
    AMesh.Data.VertexBuffer.TexCoord0[V + 3] := PointF(0, 1);

    AMesh.Data.IndexBuffer.Indices[Idx + 0] := V + 0;
    AMesh.Data.IndexBuffer.Indices[Idx + 1] := V + 1;
    AMesh.Data.IndexBuffer.Indices[Idx + 2] := V + 2;
    AMesh.Data.IndexBuffer.Indices[Idx + 3] := V + 2;
    AMesh.Data.IndexBuffer.Indices[Idx + 4] := V + 3;
    AMesh.Data.IndexBuffer.Indices[Idx + 5] := V + 0;

    Inc(V, 4);
    Inc(Idx, 6);
  end;

begin
  GetBarBox(AData, Center, BarHeight);

  X0 := Center.X - BAR_WIDTH/2;
  X1 := Center.X + BAR_WIDTH/2;
  Y0 := Center.Y - BarHeight/2;
  Y1 := Center.Y + BarHeight/2;
  Z0 := Center.Z - BAR_DEPTH/2;
  Z1 := Center.Z + BAR_DEPTH/2;

  V := AVertexBase;
  Idx := AIndexBase;

  AddFace(TPoint3D.Create(X0, Y1, Z0), TPoint3D.Create(X1, Y1, Z0),
    TPoint3D.Create(X1, Y1, Z1), TPoint3D.Create(X0, Y1, Z1), TPoint3D.Create(0, 1, 0));
  AddFace(TPoint3D.Create(X0, Y0, Z1), TPoint3D.Create(X1, Y0, Z1),
    TPoint3D.Create(X1, Y0, Z0), TPoint3D.Create(X0, Y0, Z0), TPoint3D.Create(0, -1, 0));
  AddFace(TPoint3D.Create(X0, Y0, Z0), TPoint3D.Create(X0, Y1, Z0),
    TPoint3D.Create(X0, Y1, Z1), TPoint3D.Create(X0, Y0, Z1), TPoint3D.Create(-1, 0, 0));
  AddFace(TPoint3D.Create(X1, Y0, Z1), TPoint3D.Create(X1, Y1, Z1),
    TPoint3D.Create(X1, Y1, Z0), TPoint3D.Create(X1, Y0, Z0), TPoint3D.Create(1, 0, 0));
  AddFace(TPoint3D.Create(X0, Y0, Z1), TPoint3D.Create(X0, Y1, Z1),
    TPoint3D.Create(X1, Y1, Z1), TPoint3D.Create(X1, Y0, Z1), TPoint3D.Create(0, 0, 1));
  AddFace(TPoint3D.Create(X1, Y0, Z0), TPoint3D.Create(X1, Y1, Z0),
    TPoint3D.Create(X0, Y1, Z0), TPoint3D.Create(X0, Y0, Z0), TPoint3D.Create(0, 0, -1));
end;

procedure TBarContainer.InvalidateNotSelectedBars;
var
  I: Integer;
  bar: TBar;
  data: TBarData;
begin
  for I := 0 to FBarData.Count - 1 do
    begin
      data := FBarData[I];
      data.color := Stg.global.BarColor;
      FBarData[I] := data;
    end;
  FMeshDirty := true;

  for I := 0 to ChildrenCount - 1 do
    if Children[I] is TBar then
      begin
        bar := Children[I] as TBar;
        bar.fcolor := Stg.global.BarColor;
        if not bar.isSelected then bar.color := bar.fcolor;
        bar.repaint;
      end;

  RequestLayoutUpdate(false);
end;

procedure TBarContainer.InvalidateSelected;
var
  I: Integer;
  bar: TBar;
begin
  for I := 0 to ChildrenCount - 1 do
    if Children[I] is TBar then
      begin
        bar := Children[I] as TBar;
        if bar.isSelected then
          begin
            bar.color := Stg.global.BarSelectedColor;
            Exit;
          end;
      end;
end;

procedure TBarContainer.RecalculateDataBounds;
var
  I: Integer;
begin
  Stg.global.DataMin := MaxSingle;
  Stg.global.DataMax := MinSingle;

  for I := 0 to FBarData.Count - 1 do
    begin
      Stg.global.DataMin := Min(Stg.global.DataMin, FBarData[I].val);
      Stg.global.DataMax := Max(Stg.global.DataMax, FBarData[I].val);
    end;
end;

function TBarContainer.IndexOf(row, col: Integer): TBar;
var
  comp: TComponent;
  s: String;
begin
  if Assigned(FBarIndex) and FBarIndex.TryGetValue(BarKey(row, col), Result) then
    Exit;

  s := Format('Bar_%d_%d', [row, col]);
  comp := FindComponent(s);
  if (comp <> Nil) and (comp is TBar) then
    begin
      Result := comp as TBar;
      if Assigned(FBarIndex) then
        FBarIndex.AddOrSetValue(BarKey(row, col), Result);
    end
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
  FBarIndex.AddOrSetValue(BarKey(row, col), bar);
  bar.Repaint;
end;

procedure TBarContainer.SetRowCount(val: Integer);
begin
  if val <> FRowCount then
    begin
      FRowCount := val;
      RequestLayoutUpdate(true);
    end;
end;

procedure TBarContainer.SetColCount(val: Integer);
begin
  if val <> FColCount then
    begin
      FColCount := val;
      RequestLayoutUpdate(true);
    end;
end;

procedure TBarContainer.Add(row, col: Integer; Value: Single; cl: TAlphaColor = claBlue);
var
  bar: TBar;
  OldValue: Single;
  ExistingData: Boolean;
  RecalculateBounds: Boolean;
  UpdateSelectedLegend: Boolean;
begin
  if (row < 0) or (col < 0) then
    raise EArgumentException.Create('Row and column indexes must be greater than or equal to zero.');

  RecalculateBounds := false;
  UpdateSelectedLegend := false;
  BeginDataUpdate;
  try
    UpsertBarData(row, col, Value, cl, OldValue, ExistingData);

    RowCount := Max(RowCount, row + 1);
    ColCount := Max(ColCount, col + 1);

    bar := IndexOf(row, col);

    RecalculateBounds := ExistingData and (not SameValue(OldValue, Value)) and
      (SameValue(OldValue, Stg.global.DataMin) or SameValue(OldValue, Stg.global.DataMax));

    if Assigned(bar) then
      begin
        bar.val := Value;
        bar.fcolor := cl;

        if not bar.isSelected then
          bar.color := cl;
      end
    else if ActiveRenderMode = brCubes then
      begin
        CreateBar(row, col, Value, cl);
        bar := IndexOf(row, col);
      end;

    if RecalculateBounds then
      RecalculateDataBounds
    else
      begin
        Stg.global.DataMin := Min(Stg.global.DataMin, Value);
        Stg.global.DataMax := Max(Stg.global.DataMax, Value);
      end;

    RequestLayoutUpdate(false);
    UpdateSelectedLegend := Assigned(bar) and bar.isSelected and (Legend.bar = bar);
  finally
    EndDataUpdate;
  end;

  if UpdateSelectedLegend then
    begin
      Legend.Data := Stg.RequestData(bar);
      PositionLegendForBar(bar);
      Legend.Invalidate;
      RotateLegend;
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
      Stage.AxisXPanel.TopSticker.RebuildText3D;
      Stage.AxisXPanel.BottomSticker.Lb.Text := val;
      Stage.AxisXPanel.BottomSticker.Lb.Invalidate;
      Stage.AxisXPanel.BottomSticker.RebuildText3D;
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
      Stage.AxisYPanel.TopSticker.RebuildText3D;

      Stage.AxisYPanel.BottomSticker.Lb.Text := val;
      Stage.AxisYPanel.BottomSticker.Lb.Invalidate;
      Stage.AxisYPanel.BottomSticker.RebuildText3D;
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

procedure TBarGraph.RequestInvalidate;
begin
  if FUpdateLock > 0 then
    begin
      FNeedsInvalidate := true;
      Exit;
    end;

  Invalidate;
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
      RequestInvalidate;
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
      RequestInvalidate;
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
      RequestInvalidate;
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
      if Assigned(Stage) then
        begin
          Stage.BarContainer.InvalidateNotSelectedBars;
          RequestInvalidate;
        end;
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
      RequestInvalidate;
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
      RequestInvalidate;
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
      if Assigned(Stage) then
        Stage.SetColor;
      RequestInvalidate;
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
      if Assigned(Stage) then
        Stage.SetColor;
      RequestInvalidate;
    end;
end;

function TBarGraph.GetPlaneOpacity: Single;
begin
  if Assigned(globalVars) then
    Result := globalVars.PlaneOpacity
  else
    Result := PLANE_OPACITY;
end;

procedure TBarGraph.SetPlaneOpacity(val: Single);
var
  NewValue: Single;
begin
  NewValue := EnsureRange(val, 0, 1);
  if (Assigned(globalVars)) and (not SameValue(NewValue, globalVars.PlaneOpacity)) then
    begin
      globalVars.PlaneOpacity := NewValue;
      if Assigned(Stage) then
        Stage.ApplyPlaneOpacity;
      RequestInvalidate;
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
      RequestInvalidate;
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
var
  NewValue: Integer;
begin
  NewValue := Max(1, val);
  if (Assigned(globalVars)) and (NewValue <> globalVars.NumTicks) then
    begin
      globalVars.NumTicks := NewValue;
      RequestInvalidate;
    end;
end;

procedure TBarGraph.Reset;
begin
  SetInitialValues;
end;

procedure TBarGraph.BeginDataUpdate;
begin
  Inc(FUpdateLock);

  if Assigned(Stage) and Assigned(Stage.BarContainer) then
    Stage.BarContainer.BeginDataUpdate;
end;

procedure TBarGraph.EndDataUpdate;
begin
  if Assigned(Stage) and Assigned(Stage.BarContainer) then
    Stage.BarContainer.EndDataUpdate;

  if FUpdateLock > 0 then
    Dec(FUpdateLock);

  if (FUpdateLock = 0) and FNeedsInvalidate then
    begin
      FNeedsInvalidate := false;
      Invalidate;
    end;
end;

procedure TBarGraph.UpdateCameraPosition;
var
  D, Dx, Dz: Single;
begin
  Dx := Stage.BarContainer.ColCount*(BAR_DEPTH + 2*BAR_PAD)/2 + SIZE_PANEL_TICKS;
  Dz := Stage.BarContainer.RowCount*(BAR_DEPTH + 2*BAR_PAD)/2 + SIZE_PANEL_TICKS;
  D := Sqrt(Sqr(Dx) + Sqr(Dz));
  PackCamera.Position.Z := -D;
end;

procedure TBarGraph.SetInitialValues;
begin
  Camera := PackCamera.cam;
  Camera.Target := Stage;

  BearingTop.RotationAngle.Y := CAMERA_INITIAL_ROT_ANGLE_Y;
  BearingMiddle.RotationAngle.X := CAMERA_INITIAL_ROT_ANGLE_X;
  UpdateCameraPosition;

  Stage.Position.X := 0;
  Stage.Position.Y := 0;
  Stage.BarContainer.RotateLegend;
  Status := 'static';
  Guide.Position.X := 0;
  Guide.Position.Y := 0;
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


  BearingTop := TDummy.Create(self);
  AddObject(BearingTop);
  BearingMiddle := TDummy.Create(Self);
  BearingTop.AddObject(BearingMiddle);
  PackCamera := TMyCamera.Create(Self);
  BearingMiddle.AddObject(PackCamera);


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


procedure TBarGraph.TurnLights(Val: Boolean);
begin
  LeftLight.Enabled := Val;
  RightLight.Enabled := Val;
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
end;

procedure TBarGraph.InitMouseEvents;
begin
  OnMouseWheel := BarMouseWheel;
  OnMouseDown := BarMouseDown;
  OnMouseMove := BarMouseMove;
  OnMouseUp := BarMouseUp;
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

procedure TBarGraph.DoZoom(WheelDelta: Integer);
var
  PackCamera: TMyCamera;
begin
  PackCamera := Camera.Parent as TMyCamera;
  with PackCamera.Position do Z := Z + WheelDelta * ZOOM_STEP * PackCamera.dir;
end;

procedure TBarGraph.BarMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; var Handled: Boolean);
begin
  DoZoom(WheelDelta);
end;

function TBarGraph.TrySelectMeshAt(const P: TPointF): Boolean;
begin
  Result := false;
  if not Assigned(Context) or not Assigned(Stage) or not Assigned(Stage.BarContainer) then
    Exit;

  Result := Stage.BarContainer.SelectMeshBarAtScreen(P);
end;

procedure TBarGraph.ViewportClick(Sender: TObject);
begin
  if Tag = 1 then
    Exit;

  Stage.BarContainer.UnSelected;
end;

procedure TBarGraph.BarMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
var
  P: TPointF;
begin
  Tag := 0;
  FDown := PointF(X, Y);
  FClickStart := FDown;
  FDragMoved := false;
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

function TBarGraph.OnTheHead: Boolean;
var
  K: TVector3D;
begin
  K := Context.CurrentCameraMatrix.M[1];
  K := K.Normalize;
  Result := K.Y > 0;
end;

procedure TBarGraph.Rotate(const aX, aY: Single);
var
  PackCamera: TMyCamera;
  BearingTop, BearingMiddle: TDummy;
begin
  PackCamera := Camera.Parent as TMyCamera;
  BearingMiddle := PackCamera.Parent as TDummy;
  BearingTop := BearingMiddle.Parent as TDummy;
  with BearingTop.RotationAngle do if OnTheHead then Y := Y + (FDown.X - aX) else Y := Y + (aX - FDown.X);
  with BearingMiddle.RotationAngle do X := X + (FDown.Y - aY) * PackCamera.dir;
  FDown := PointF(aX, aY);
  Stage.BarContainer.RotateLegend;
end;

procedure TBarGraph.BarMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
var
  Delta: TPointF;
 // mc: TMyCamera;
begin
  Delta := PointF(X, Y) - FDown;
  if ((ssLeft in Shift) or (ssCtrl in Shift)) and (Status = 'MouseMove') and
    ((Abs(X - FClickStart.X) > 3) or (Abs(Y - FClickStart.Y) > 3)) then
    FDragMoved := true;

  if not FDragMoved then
    Exit;

  if (ssCtrl in Shift) and (Status = 'MouseMove') then
    begin
      {
      mc := Camera.Parent as TMyCamera;
      if Camera = MainCamera.cam then
        begin
          guide.Position.X := guide.Position.X - Delta.X*TRANSLATION_STEP;
          guide.Position.Y := guide.Position.Y - Delta.Y*TRANSLATION_STEP;
          mc.Position.X := mc.Position.X - Delta.X*TRANSLATION_STEP;
          mc.Position.Y := mc.Position.Y - Delta.Y*TRANSLATION_STEP;
        end;
        }
    end
  else
  if (ssLeft in Shift) and (Status = 'MouseMove') then
    begin
      Rotate(X, Y);
    end;

  if FDragMoved then
    Tag := 1;
end;

procedure TBarGraph.BarMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  if(Status = 'MouseMove') then
    begin
      Status := 'static';
    end;

  if (Button = TMouseButton.mbLeft) and (not FDragMoved) then
    begin
      if TrySelectMeshAt(PointF(X, Y)) then
        Tag := 1;
    end;
end;

procedure TBarGraph.Add(row, col: Integer; Value: Single; cl: TAlphaColor = 0);
var
  temp: TAlphaColor;
begin
  if (row < 0) or (col < 0) then
    raise EArgumentException.Create('Row and column indexes must be greater than or equal to zero.');

  if cl = 0 then temp := globalVars.BarColor else temp := cl;
  Stage.BarContainer.Add(row, col, Value, temp);
  Stage.DataYAxis.Count := Max(Stage.DataYAxis.Count, row + 1);
  Stage.DataXAxis.Count := Max(Stage.DataXAxis.Count, col + 1);
  RequestInvalidate;
end;

procedure TBarGraph.AddYLabel(row: Integer; val: String);
begin
  if row < 0 then
    raise EArgumentException.Create('Row index must be greater than or equal to zero.');

  Stage.DataYAxis.Add(row, val);
  Stage.AxisYPanel.TopSticker.Sticker.Invalidate;
  Stage.AxisYPanel.TopSticker.RebuildText3D;
  Stage.AxisYPanel.BottomSticker.Sticker.Invalidate;
  Stage.AxisYPanel.BottomSticker.RebuildText3D;
  RequestInvalidate;
end;

procedure TBarGraph.AddXLabel(col: Integer; val: String);
begin
  if col < 0 then
    raise EArgumentException.Create('Column index must be greater than or equal to zero.');

  Stage.DataXAxis.Add(col, val);
  Stage.AxisXPanel.TopSticker.Sticker.Invalidate;
  Stage.AxisXPanel.TopSticker.RebuildText3D;
  Stage.AxisXPanel.BottomSticker.Sticker.Invalidate;
  Stage.AxisXPanel.BottomSticker.RebuildText3D;
  RequestInvalidate;
end;

destructor TBarGraph.Destroy;
begin
  if Assigned(globalVars) then globalVars.Destroy;
  inherited;
end;


end.
