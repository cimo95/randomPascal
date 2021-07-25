program KawalCorona;

{$R *.dres}

uses
  Vcl.Forms,
  formUtama in 'formUtama.pas' {fu};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(Tfu, fu);
  Application.Run;
end.
