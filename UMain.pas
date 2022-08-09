unit UMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Viewport3D,
  System.Math.Vectors, FMX.Controls3D, FMX.Objects3D, FMX.Types3D,
  FMX.MaterialSources, Math, FMX.Memo.Types, FMX.Controls.Presentation,
  FMX.ScrollBox, FMX.Memo, FMX.StdCtrls, System.UIConsts, U3DBarGraph,
  FMX.Layers3D;

Type
  TInfoCell = record
    row, col: byte;
    val: Single;
  end;

  TInfoAxis = Array of String;
  TInfoRow = Array[0..2] of TInfoCell;
  TInfo = Array[0..3] of TInfoRow;

const
  GRIDSY = 10;
  GRIDSX = 10;
  DX = 0.8;
  DY = 0.8;
  BARWIDTH = 0.5;
  BARDEPTH = 0.5;


  Season: TInfoAxis = ['Spring', 'Summer', 'Autum', 'Winter'];
  TimePeriod: TInfoAxis = ['1987-1996', '1937-1946', '1887-1896'];

  MeanTemperature00: TInfoCell = (row: 0; col: 0; val: 14);

//  MeanTemperatureRow0: TInfoRow = [MeanTemperature00, MeanTemperature00];
//  MeanTemperatureRow1: TInfoRow = [MeanTemperature00];

  MeanTemperature: TInfo = (((row: 0; col: 0; val: 14), (), ()), ((), (), ()), ((), (), ()), ((), (), ()));


type

  TDataArray = Array[0..GRIDSY - 1, 0..GRIDSX - 1] of Single;
  TBarsArray = Array[0..GRIDSY - 1, 0..GRIDSX - 1] of TCylinder;

  TMainForm = class(TForm)
    Viewport3D1: TViewport3D;
    Dummy1: TDummy;
    Light1: TLight;
    Light2: TLight;
    Camera1: TCamera;
    LightMaterialSource1: TLightMaterialSource;
    Button1: TButton;
    Sphere1: TSphere;
    Rectangle3D1: TRectangle3D;
    ColorMaterialSource1: TColorMaterialSource;
    Button2: TButton;
    TextLayer3D1: TTextLayer3D;
    TextLayer3D2: TTextLayer3D;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Viewport3D1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure Viewport3D1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Single);
    procedure Viewport3D1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure Viewport3D1MouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; var Handled: Boolean);
    procedure Dummy1Render(Sender: TObject; Context: TContext3D);
    procedure Button2Click(Sender: TObject);
    procedure TextLayer3D1Paint(Sender: TObject; Canvas: TCanvas;
      const ARect: TRectF);
  private
    { Private declarations }
  public
    { Public declarations }
    data: TDataArray;
    bars: TBarsArray;
    DataMin, DataMax: Single;
    ScaleY, LX, LY, RX, RY, RZ: Single;


    BarGraph: T3DBarGraph;
    rotation_by_mouse: Boolean;
    procedure Generate2DData;
    procedure Print2DData;
    procedure CreateCylinder(x, y: Integer; value: Single; cla: TAlphaColor);
    procedure CreateCylinders;
    procedure free2DData;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.fmx}

procedure TMainForm.CreateCylinders;
var
  i, j: Integer;
begin
  for I := 0 to GRIDSY - 1 do
     for J := 0 to GRIDSX - 1 do
       begin
         CreateCylinder(j, i, data[i, j], claBrown);
       end;
end;

procedure TMainForm.Dummy1Render(Sender: TObject; Context: TContext3D);
begin
  Context.DrawCube(TPoint3D.Zero, TPoint3D.Create(5, 5, 5), 1, claWhite);
end;

procedure TMainForm.Button1Click(Sender: TObject);
begin
  //CreateCylinders;
end;

procedure TMainForm.free2DData;
var
  i, j: Integer;
begin
  for I := 0 to GRIDSY - 1 do
     for J := 0 to GRIDSX - 1 do
       if bars[I, J] <> Nil then
         begin
           if bars[i][j].MaterialSource <> Nil then bars[i][j].MaterialSource.Free;
           bars[i][j].Free;
         end;
end;


procedure TMainForm.Button2Click(Sender: TObject);
begin

   if Button2.Text = 'View Negative Plane' then
     begin
       Button2.Text := 'View Positive Plane';
       BarGraph.ViewNegativePlane;
     end
   else
     begin
       Button2.Text := 'View Negative Plane';
       BarGraph.ViewPositivePlane;
     end;

end;

procedure TMainForm.CreateCylinder(x, y: Integer; value: Single; cla: TAlphaColor);
var
  cylinder: TCylinder;
  mat: TLightMaterialSource;
begin
  cylinder := TCylinder.Create(Viewport3D1);
  cylinder.BeginUpdate;
    cylinder.Parent := Dummy1;
    cylinder.Width := BARWIDTH;
    cylinder.Depth := BARDEPTH;
    cylinder.Height := value*ScaleY;

    cylinder.SubdivisionsAxes := 18; // higher numbers more smooth but slower display
    cylinder.Opacity := 1.0;

    cylinder.Position.X := -0.5*DX*GRIDSX + x*DX + 0.5*DX;
    cylinder.Position.Y := -0.5*cylinder.Height; // Normaly origin is the center, lets set origin to base
    cylinder.Position.Z := -0.5*DX*GRIDSY + y*DY + 0.5*DY;

    mat := TLightMaterialSource.Create(Dummy1);
    mat.Shininess := 00;
		mat.Ambient := cla;
		mat.Emissive := $00;
		mat.Specular := $00;

		cylinder.MaterialSource := mat;
		cylinder.HitTest := false;
  cylinder.EndUpdate;
  cylinder.Repaint;
  bars[x][y] := cylinder;
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  free2DData;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  BarGraph := T3DBarGraph.Create(Self);
  BarGraph.Parent := Self;
  BarGraph.Width := 640;
  BarGraph.Height := 480;
  BarGraph.ZLabel := 'MEAN TEMPERATURE';
  BarGraph.YLabel := 'TIME PERIOD';


  BarGraph.Position.X := 568;
  BarGraph.Position.Y := 16;

  BarGraph.Add(0, 0, -14, claGreen);
  BarGraph.Add(1, 0, 14, claPurple);
  BarGraph.Add(2, 0, 14, claRed);

  BarGraph.Add(0, 1, 25, claGreen);
  BarGraph.Add(1, 1, 25, claPurple);
  BarGraph.Add(2, 1, 25, claRed);

  BarGraph.Add(0, 2, 10, claGreen);
  BarGraph.Add(1, 2, 10, claPurple);
  BarGraph.Add(2, 2, 10, claRed);

  BarGraph.Add(0, 3, 5, claGreen);
  BarGraph.Add(1, 3, 5, claPurple);
  BarGraph.Add(2, 3, -5, claRed);

  BarGraph.AddYLabel(0, '1987-1996');
  BarGraph.AddYLabel(1, '1937-1946');
  BarGraph.AddYLabel(2, '1887-1896');
end;


procedure TMainForm.Generate2DData;
var
  i, j: Integer;
begin
   randomize;
   DataMax := -1000000;
   DataMin := 1000000;

   for I := 0 to GRIDSY - 1 do
     for J := 0 to GRIDSX - 1 do
       begin
         data[i, j] := random(50);
         dataMax := Max(DataMax, data[i, j]);
         dataMin := Min(DataMin, data[i, j]);
       end;
end;

procedure TMainForm.Print2DData;
var
  i, j: Integer;
begin

  {
  Memo1.Lines.Clear;
  for I := 0 to GRIDSY - 1 do
     for J := 0 to GRIDSX - 1 do
       begin
         Memo1.Lines.Add(IntToStr(i) + ',' +  IntToStr(j) + ' = ' + FloatToStr(data[i][j]));
       end;
       }
end;

procedure TMainForm.TextLayer3D1Paint(Sender: TObject; Canvas: TCanvas;
  const ARect: TRectF);

var
  Flags: TFillTextFlags;
  b : tBrush;
begin
  //Flags := TFillTextFlag.RightToLeft;
  //b := TBrush.Create(TBrushKind.Solid, claRed);
 // b.Color := clared;
 // Canvas.Fill := TBrush.Create(TBrushKind.Solid, claRed);

 Canvas.Fill.Color := claYellow;
 Canvas.FillRect(ARect, 0, 0, [], 1, TCornerType.Round);


 Canvas.Fill.Color := claBlue;
 Canvas.FillText(ARect, 'ESTE ES UN TEXTO', false, 1, Flags, TTextAlign.Center, TTextAlign.Center);
end;

procedure TMainForm.Viewport3D1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
   LX :=X;
   LY :=Y;
   RX := Dummy1.RotationAngle.X;
   RY := Dummy1.RotationAngle.Y;
   RZ := Dummy1.RotationAngle.Z;
   rotation_by_mouse := true;
end;

procedure TMainForm.Viewport3D1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Single);
begin
  if(rotation_by_mouse) then
    begin
      Dummy1.RotationAngle.X := RX + (Y-LY)*0.4;
      Dummy1.RotationAngle.Y := RY + (LX-X)*0.4;
      Dummy1.RotationAngle.Z := RZ - 0.4*((LX-X)-(Y-LY));
    end;
end;

procedure TMainForm.Viewport3D1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
  rotation_by_mouse := false;
end;

procedure TMainForm.Viewport3D1MouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; var Handled: Boolean);
begin
  Camera1.Position.Z := Camera1.Position.Z + 0.01*WheelDelta;
end;

end.
