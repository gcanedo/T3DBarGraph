unit UMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Viewport3D,
  System.Math.Vectors, FMX.Controls3D, FMX.Objects3D, FMX.Types3D,
  FMX.MaterialSources, Math, FMX.Memo.Types, FMX.Controls.Presentation,
  FMX.ScrollBox, FMX.Memo, FMX.StdCtrls, System.UIConsts, U3DBarGraph,
  FMX.Layers3D, FMX.Objects;


type


  TMainForm = class(TForm)
    Button2: TButton;
    procedure FormCreate(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    
  private
    { Private declarations }
  public
    { Public declarations }

    BarGraph: T3DBarGraph;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.fmx}


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

procedure TMainForm.FormCreate(Sender: TObject);
begin
  BarGraph := T3DBarGraph.Create(Self);
  BarGraph.Parent := Self;
  BarGraph.Align := TAlignLayout.Client;

  BarGraph.ZMin := -30;
  BarGraph.ZMax := 30;
  BarGraph.NumTicks := 8;
  BarGraph.AutoScale := true;
  BarGraph.BackgroundColor := claBlack;
  BarGraph.XYPlaneColor := claDarkblue;
  BarGraph.GridColor := claWhite;
  BarGraph.FontColor := claYellow;
  BarGraph.XZandYZPlaneColor := claDarkBlue;


  BarGraph.Width := 800;
  BarGraph.Height := 600;
  BarGraph.XLabel := 'SEASON';
  BarGraph.YLabel := 'TIME PERIOD';
  BarGraph.ZLabel := 'MEAN TEMPERATURE';

  BarGraph.Position.X := 0;
  BarGraph.Position.Y := 0;

  BarGraph.BarColor := claGreen;



  {
  BarGraph.Add(0, 0, -15);
  BarGraph.Add(1, 0, 14);
  BarGraph.Add(2, 0, 14);

  BarGraph.Add(0, 1, 25);
  BarGraph.Add(1, 1, 25);
  BarGraph.Add(2, 1, 25);

  BarGraph.Add(0, 2, 10);
  BarGraph.Add(1, 2, 10);
  BarGraph.Add(2, 2, 10);

  BarGraph.Add(0, 3, 5);
  BarGraph.Add(1, 3, 5);
  BarGraph.Add(2, 3, -5);
  }



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



  BarGraph.AddYLabel(0, '1987-1996');
  BarGraph.AddYLabel(1, '1937-1946');
  BarGraph.AddYLabel(2, '1887-1896');

  BarGraph.AddXLabel(0, 'SPRING');
  BarGraph.AddXLabel(1, 'SUMMER');
  BarGraph.AddXLabel(2, 'AUTUMN');
  BarGraph.AddXLabel(3, 'WINTER');




  //BarGraph.BarSelectedColor := claBurlywood;


end;


end.
