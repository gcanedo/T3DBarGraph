unit UTest;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Viewport3D,
  System.UIConsts, U3DBarGraph;

type
  TForm1 = class(TForm)
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    BarGraph: TBarGraph;
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

procedure TForm1.FormCreate(Sender: TObject);
begin
  BarGraph := TBarGraph.Create(Self);
  BarGraph.Parent := Self;
  BarGraph.Align := TAlignLayout.Client;


  BarGraph.Position.Point := PointF(0, 0);
  BarGraph.Width := 1024;
  BarGraph.Height := 768;
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

  //BarGraph.Add(40, 40, 15, claRed);

  BarGraph.AutoScale := true;


end;

end.
