unit UMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Viewport3D,
  System.Math.Vectors, FMX.Controls3D, FMX.Objects3D, FMX.Types3D,
  FMX.MaterialSources, Math, FMX.Memo.Types, FMX.Controls.Presentation,
  FMX.ScrollBox, FMX.Memo, FMX.StdCtrls, System.UIConsts;

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
  BARWIDTH = 1.5;
  BARDEPTH = 1.5;


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
    Cube1: TCube;
    Light1: TLight;
    Light2: TLight;
    Camera1: TCamera;
    LightMaterialSource1: TLightMaterialSource;
    Memo1: TMemo;
    Button1: TButton;
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
  private
    { Private declarations }
  public
    { Public declarations }
    data: TDataArray;
    bars: TBarsArray;
    DataMin, DataMax: Single;
    ScaleY, LX, LY, RX, RY, RZ: Single;

    plane: TPlane;
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

procedure TMainForm.Button1Click(Sender: TObject);
begin
  Cube1.Visible := false;
  CreateCylinders;
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
  ScaleY := 0.05;
  Generate2DData;
  Print2DData;
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
  Memo1.Lines.Clear;
  for I := 0 to GRIDSY - 1 do
     for J := 0 to GRIDSX - 1 do
       begin
         Memo1.Lines.Add(IntToStr(i) + ',' +  IntToStr(j) + ' = ' + FloatToStr(data[i][j]));
       end;
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
