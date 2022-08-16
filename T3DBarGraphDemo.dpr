program T3DBarGraphDemo;

uses
  System.StartUpCopy,
  FMX.Forms,
  FMX.Types,
  UMain in 'UMain.pas' {MainForm},
  U3DBarGraph in 'U3DBarGraph.pas';

{$R *.res}

begin

  GlobalUseMetal := true;

  {$IFDEF DEBUG}
  ReportMemoryLeaksOnShutdown := True;
  {$ENDIF}

  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
