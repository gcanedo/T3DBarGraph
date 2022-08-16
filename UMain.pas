unit UMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Viewport3D,
  System.Math.Vectors, FMX.Controls3D, FMX.Objects3D, FMX.Types3D,
  FMX.MaterialSources, Math, FMX.Memo.Types, FMX.Controls.Presentation,
  FMX.ScrollBox, FMX.Memo, FMX.StdCtrls, System.UIConsts, U3DBarGraph,
  FMX.Layers3D, FMX.Objects, FMX.Menus, FMX.ExtCtrls, FMX.ListBox, FMX.Colors,
  FMX.Edit, FMX.EditBox, FMX.NumberBox;
type


  TMainForm = class(TForm)
    Panel1: TPanel;
    BarGraph: TBarGraph;
    Panel2: TPanel;
    Label1: TLabel;
    ColorComboBox1: TColorComboBox;
    Label2: TLabel;
    ColorComboBox2: TColorComboBox;
    Label3: TLabel;
    ColorComboBox3: TColorComboBox;
    Label4: TLabel;
    ColorComboBox4: TColorComboBox;
    ColorComboBox5: TColorComboBox;
    Label5: TLabel;
    Label6: TLabel;
    ColorComboBox6: TColorComboBox;
    Label7: TLabel;
    ColorComboBox7: TColorComboBox;
    Label8: TLabel;
    ColorComboBox8: TColorComboBox;
    Label9: TLabel;
    ColorComboBox9: TColorComboBox;
    CheckBox1: TCheckBox;
    Label10: TLabel;
    NumberBox1: TNumberBox;
    Label11: TLabel;
    NumberBox2: TNumberBox;
    Label12: TLabel;
    NumberBox3: TNumberBox;
    Button1: TButton;
    procedure FormCreate(Sender: TObject);
    procedure ColorComboBox2Change(Sender: TObject);
    procedure ColorComboBox1Change(Sender: TObject);
    procedure ColorComboBox3Change(Sender: TObject);
    procedure ColorComboBox4Change(Sender: TObject);
    procedure ColorComboBox5Change(Sender: TObject);
    procedure ColorComboBox6Change(Sender: TObject);
    procedure ColorComboBox7Change(Sender: TObject);
    procedure ColorComboBox8Change(Sender: TObject);
    procedure ColorComboBox9Change(Sender: TObject);
    procedure CheckBox1Change(Sender: TObject);
    procedure NumberBox1ChangeTracking(Sender: TObject);
    procedure NumberBox2ChangeTracking(Sender: TObject);
    procedure NumberBox3ChangeTracking(Sender: TObject);
    procedure Button1Click(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
    procedure InitComps;
    procedure InitNumbersBox;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.fmx}


procedure TMainForm.Button1Click(Sender: TObject);
begin
  BarGraph.Reset;
end;

procedure TMainForm.CheckBox1Change(Sender: TObject);
begin
  BarGraph.AutoScale := CheckBox1.IsChecked;
  InitNumbersBox;
end;

procedure TMainForm.ColorComboBox1Change(Sender: TObject);
begin
  BarGraph.BackgroundColor := ColorComboBox1.Color;
end;

procedure TMainForm.ColorComboBox2Change(Sender: TObject);
begin
  BarGraph.FontColor := ColorComboBox2.Color;
end;

procedure TMainForm.ColorComboBox3Change(Sender: TObject);
begin
  BarGraph.XYPlaneColor := ColorComboBox3.Color;
end;

procedure TMainForm.ColorComboBox4Change(Sender: TObject);
begin
  BarGraph.XZandYZPlaneColor := ColorComboBox4.Color;
end;

procedure TMainForm.ColorComboBox5Change(Sender: TObject);
begin
  BarGraph.GridColor := ColorComboBox5.Color;
end;

procedure TMainForm.ColorComboBox6Change(Sender: TObject);
begin
  BarGraph.LegendBackgroundColor := ColorComboBox6.Color;
end;

procedure TMainForm.ColorComboBox7Change(Sender: TObject);
begin
  BarGraph.LegendFontColor := ColorComboBox7.Color;
end;

procedure TMainForm.ColorComboBox8Change(Sender: TObject);
begin
  BarGraph.BarColor := ColorComboBox8.Color;
end;

procedure TMainForm.ColorComboBox9Change(Sender: TObject);
begin
  BarGraph.BarSelectedColor := ColorComboBox9.Color;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  BarGraph.XLabel := 'SEASON';
  BarGraph.YLabel := 'TIME PERIOD';
  BarGraph.ZLabel := 'MEAN TEMPERATURE';

  BarGraph.AddYLabel(0, '1987-1996');
  BarGraph.AddYLabel(1, '1937-1946');
  BarGraph.AddYLabel(2, '1887-1896');

  BarGraph.AddXLabel(0, 'SPRING');
  BarGraph.AddXLabel(1, 'SUMMER');
  BarGraph.AddXLabel(2, 'AUTUMN');
  BarGraph.AddXLabel(3, 'WINTER');

  BarGraph.Add(0, 0, -15, claGreen);
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

  InitComps;
end;

procedure TMainForm.InitComps;
begin
  ColorComboBox1.Color := BarGraph.BackgroundColor;
  ColorComboBox2.Color := BarGraph.FontColor;

  ColorComboBox3.Color := BarGraph.XYPlaneColor;
  ColorComboBox4.Color := BarGraph.XZandYZPlaneColor;

  ColorComboBox5.Color := BarGraph.GridColor;

  ColorComboBox6.Color := BarGraph.LegendBackgroundColor;
  ColorComboBox7.Color := BarGraph.LegendFontColor;

  ColorComboBox8.Color := BarGraph.BarColor;
  ColorComboBox9.Color := BarGraph.BarSelectedColor;

  CheckBox1.IsChecked := BarGraph.AutoScale;

  InitNumbersBox;

  NumberBox3.Value := BarGraph.NumTicks;
end;

procedure TMainForm.InitNumbersBox;
begin
 if not BarGraph.AutoScale then
    begin
      NumberBox1.Value := BarGraph.ZMin;
      NumberBox2.Value := BarGraph.ZMax;
      NumberBox1.Enabled := true;
      NumberBox2.Enabled := true;
    end
  else
    begin
      NumberBox1.Enabled := false;
      NumberBox2.Enabled := false;
    end;
end;

procedure TMainForm.NumberBox1ChangeTracking(Sender: TObject);
begin
  BarGraph.ZMin := NumberBox1.Value;
end;

procedure TMainForm.NumberBox2ChangeTracking(Sender: TObject);
begin
  BarGraph.ZMax := NumberBox2.Value;
end;

procedure TMainForm.NumberBox3ChangeTracking(Sender: TObject);
begin
  BarGraph.NumTicks := Round(NumberBox3.Value);
end;

end.
