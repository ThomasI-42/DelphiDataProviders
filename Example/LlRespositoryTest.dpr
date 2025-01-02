program LlRespositoryTest;

uses
  Vcl.Forms,
  mainRepositoryTest in 'mainRepositoryTest.pas' {Form1},
  LlCoreRepository in '..\Sources\LlCoreRepository.pas',
  LlRepository in '..\Sources\LlRepository.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
