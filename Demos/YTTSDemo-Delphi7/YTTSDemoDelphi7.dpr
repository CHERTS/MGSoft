program YTTSDemoDelphi7;

uses
  Forms,
  YTTS in 'YTTS.pas' {MainForm},
  GlobalYTTS in 'GlobalYTTS.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
