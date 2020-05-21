program CadastroClientes;

uses
  Vcl.Forms,
  U_Cadastro in 'U_Cadastro.pas' {frm_Cad_Cli};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(Tfrm_Cad_Cli, frm_Cad_Cli);
  Application.Run;
end.
