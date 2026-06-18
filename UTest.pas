unit UTest;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Diagnostics, System.Math, FMX.Types, FMX.Controls, FMX.Forms,
  FMX.Graphics, FMX.Dialogs, FMX.Viewport3D, FMX.StdCtrls, FMX.Layouts,
  System.UIConsts, U3DBarGraph;

type
  TForm1 = class(TForm)
    procedure FormCreate(Sender: TObject);
  private
    FToolbar: TLayout;
    FStatusLabel: TLabel;
    FDetailLabel: TLabel;
    FTimer: TTimer;
    FWatch: TStopwatch;
    FTotalBars: Integer;
    FCurrentIndex: Integer;
    FColCount: Integer;
    FBatchSize: Integer;
    FRunActive: Boolean;

    procedure CreateToolbar;
    procedure CreateGraph;
    function CreateRunButton(const AText: string; ATotalBars: Integer; AX: Single): TButton;
    procedure RunButtonClick(Sender: TObject);
    procedure StopButtonClick(Sender: TObject);
    procedure TimerTick(Sender: TObject);
    procedure StartRun(ATotalBars: Integer);
    procedure StopRun(const AReason: string);
    procedure UpdateStatus(const AReason: string = '');
    function BarValue(AIndex: Integer): Single;
    function BarColor(AIndex: Integer): TAlphaColor;
  public
    BarGraph: TBarGraph;
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

procedure TForm1.FormCreate(Sender: TObject);
begin
  Width := 1280;
  Height := 800;

  CreateToolbar;
  CreateGraph;

  FTimer := TTimer.Create(Self);
  FTimer.Enabled := false;
  FTimer.Interval := 16;
  FTimer.OnTimer := TimerTick;

  StartRun(100);
end;

procedure TForm1.CreateToolbar;
var
  Btn: TButton;
  NavLabel: TLabel;
begin
  FToolbar := TLayout.Create(Self);
  FToolbar.Parent := Self;
  FToolbar.Align := TAlignLayout.Top;
  FToolbar.Height := 128;
  FToolbar.Padding.Left := 12;
  FToolbar.Padding.Right := 12;
  FToolbar.Padding.Top := 10;
  FToolbar.Padding.Bottom := 8;

  CreateRunButton('1k', 1000, 12);
  CreateRunButton('5k', 5000, 84);
  CreateRunButton('10k', 10000, 156);
  CreateRunButton('50k', 50000, 236);

  Btn := TButton.Create(Self);
  Btn.Parent := FToolbar;
  Btn.Position.X := 324;
  Btn.Position.Y := 10;
  Btn.Width := 80;
  Btn.Height := 32;
  Btn.Text := 'Stop';
  Btn.OnClick := StopButtonClick;

  FStatusLabel := TLabel.Create(Self);
  FStatusLabel.Parent := FToolbar;
  FStatusLabel.Position.X := 424;
  FStatusLabel.Position.Y := 8;
  FStatusLabel.Width := 780;
  FStatusLabel.Height := 34;
  FStatusLabel.Text := 'Ready';

  FDetailLabel := TLabel.Create(Self);
  FDetailLabel.Parent := FToolbar;
  FDetailLabel.Position.X := 12;
  FDetailLabel.Position.Y := 52;
  FDetailLabel.Width := 1190;
  FDetailLabel.Height := 20;
  FDetailLabel.Text := 'Choose a dataset size to start a timed load.';

  NavLabel := TLabel.Create(Self);
  NavLabel.Parent := FToolbar;
  NavLabel.Position.X := 12;
  NavLabel.Position.Y := 76;
  NavLabel.Width := 1190;
  NavLabel.Height := 20;
  NavLabel.Text := 'Mouse: left-drag to rotate | Ctrl + left-drag to pan | wheel zooms toward cursor | click a bar to select';

  NavLabel := TLabel.Create(Self);
  NavLabel.Parent := FToolbar;
  NavLabel.Position.X := 12;
  NavLabel.Position.Y := 100;
  NavLabel.Width := 1190;
  NavLabel.Height := 20;
  NavLabel.Text := 'Keyboard: arrow keys pan | R or Home resets the view | click empty space to clear selection';
end;

procedure TForm1.CreateGraph;
begin
  if Assigned(BarGraph) then
    FreeAndNil(BarGraph);

  BarGraph := TBarGraph.Create(Self);
  BarGraph.Parent := Self;
  BarGraph.Align := TAlignLayout.Client;
  if Assigned(BarGraph.Stage) and Assigned(BarGraph.Stage.BarContainer) then
    BarGraph.Stage.BarContainer.RenderMode := brMesh;
  BarGraph.Position.Point := PointF(0, 0);
  BarGraph.XLabel := 'COLUMN';
  BarGraph.YLabel := 'ROW';
  BarGraph.ZLabel := 'VALUE';
  BarGraph.AutoScale := true;
  BarGraph.NumTicks := 10;

  BarGraph.PlaneOpacity := 0.5;

  if Assigned(FToolbar) then
    FToolbar.BringToFront;
end;

function TForm1.CreateRunButton(const AText: string; ATotalBars: Integer; AX: Single): TButton;
begin
  Result := TButton.Create(Self);
  Result.Parent := FToolbar;
  Result.Position.X := AX;
  Result.Position.Y := 10;
  Result.Width := 64;
  Result.Height := 32;
  Result.Text := AText;
  Result.Tag := ATotalBars;
  Result.OnClick := RunButtonClick;
end;

procedure TForm1.RunButtonClick(Sender: TObject);
begin
  if Sender is TButton then
    StartRun(Integer((Sender as TButton).Tag));
end;

procedure TForm1.StopButtonClick(Sender: TObject);
begin
  StopRun('Stopped');
end;

procedure TForm1.StartRun(ATotalBars: Integer);
const
  LABEL_TARGET_COUNT = 10;
var
  RowCount: Integer;
  LabelStep: Integer;
  I: Integer;
begin
  if FRunActive then
    StopRun('Restarted');

  CreateGraph;

  FTotalBars := ATotalBars;
  FCurrentIndex := 0;
  FColCount := Max(10, Ceil(Sqrt(FTotalBars)));
  RowCount := Max(1, Ceil(FTotalBars/FColCount));
  FBatchSize := Max(25, Min(500, FTotalBars div 50));
  FRunActive := true;

  BarGraph.BeginDataUpdate;
  try
    LabelStep := Max(1, FColCount div LABEL_TARGET_COUNT);
    I := 0;
    while I < FColCount do
      begin
        BarGraph.AddXLabel(I, Format('C%d', [I]));
        Inc(I, LabelStep);
      end;
    BarGraph.AddXLabel(FColCount - 1, Format('C%d', [FColCount - 1]));

    LabelStep := Max(1, RowCount div LABEL_TARGET_COUNT);
    I := 0;
    while I < RowCount do
      begin
        BarGraph.AddYLabel(I, Format('R%d', [I]));
        Inc(I, LabelStep);
      end;
    BarGraph.AddYLabel(RowCount - 1, Format('R%d', [RowCount - 1]));
  finally
    BarGraph.EndDataUpdate;
  end;

  FWatch := TStopwatch.StartNew;
  FTimer.Enabled := true;
  UpdateStatus('Running');
end;

procedure TForm1.StopRun(const AReason: string);
begin
  if Assigned(FTimer) then
    FTimer.Enabled := false;

  if FRunActive then
    FWatch.Stop;

  FRunActive := false;
  UpdateStatus(AReason);
end;

procedure TForm1.TimerTick(Sender: TObject);
var
  TargetIndex: Integer;
  Row: Integer;
  Col: Integer;
begin
  if not FRunActive then Exit;

  TargetIndex := Min(FTotalBars, FCurrentIndex + FBatchSize);

  BarGraph.BeginDataUpdate;
  try
    while FCurrentIndex < TargetIndex do
      begin
        Row := FCurrentIndex div FColCount;
        Col := FCurrentIndex mod FColCount;
        BarGraph.Add(Row, Col, BarValue(FCurrentIndex), BarColor(FCurrentIndex));
        Inc(FCurrentIndex);
      end;
  finally
    BarGraph.EndDataUpdate;
  end;

  if FCurrentIndex >= FTotalBars then
    StopRun('Done')
  else
    UpdateStatus('Running');
end;

procedure TForm1.UpdateStatus(const AReason: string = '');
var
  ElapsedSec: Double;
  BarsPerSec: Double;
  PercentDone: Double;
  RowCount: Integer;
begin
  if FTotalBars <= 0 then Exit;

  ElapsedSec := Max(FWatch.Elapsed.TotalSeconds, 0.001);
  BarsPerSec := FCurrentIndex/ElapsedSec;
  PercentDone := 100*FCurrentIndex/FTotalBars;
  RowCount := Max(1, Ceil(FTotalBars/FColCount));

  FStatusLabel.Text := Format('%s: %d / %d bars (%.1f%%), %.2f sec, %.0f bars/sec',
    [AReason, FCurrentIndex, FTotalBars, PercentDone, ElapsedSec, BarsPerSec]);

  FDetailLabel.Text := Format('Render: TMesh | Pick: screen-space v2 | Columns: %d | Rows: %d | Batch size: %d | Timer: %d ms | Tip: compare 1k, 10k, and 50k to see scaling.',
    [FColCount, RowCount, FBatchSize, FTimer.Interval]);
end;

function TForm1.BarValue(AIndex: Integer): Single;
begin
  Result := ((AIndex*37) mod 120) - 60;
end;

function TForm1.BarColor(AIndex: Integer): TAlphaColor;
begin
  case AIndex mod 6 of
    0: Result := claGreen;
    1: Result := claPurple;
    2: Result := claRed;
    3: Result := claBlue;
    4: Result := claYellow;
  else
    Result := claAqua;
  end;
end;

end.
