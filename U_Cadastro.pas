unit U_Cadastro;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils,System.JSON,Data.DBXJSON, DBXJSONReflect,
  idHTTP, System.Variants, System.Classes,Vcl.Graphics,
  xmldom, XMLIntf, StdCtrls, msxmldom, XMLDoc,
  IdIOHandler, IdIOHandlerSocket, IdIOHandlerStack, IdSSL, IdSSLOpenSSL,
  IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Buttons,
  Vcl.Imaging.pngimage, Vcl.ExtCtrls;

type
  TTipoConsulta = (tcCep, tcEndereco);

type
  TEnderecoCompleto = record
    CEP,
    Logradouro,
    Numero,
    Complemento,
    Bairro,
    Cidade,
    Estado,
    Pais : string
  end;

type
  Tfrm_Cad_Cli = class(TForm)
    lbl_Titulo: TLabel;
    lbl_Telefone: TLabel;
    lbl_RG: TLabel;
    lbl_CPF: TLabel;
    lbl_Nome: TLabel;
    lbl_endereco: TLabel;
    lbl_Cep: TLabel;
    lbl_Logradouro: TLabel;
    lbl_Numero: TLabel;
    Label8: TLabel;
    lbl_Bairro: TLabel;
    lbl_Cidade: TLabel;
    lbl_Estado: TLabel;
    lbl_Pais: TLabel;
    spb_Enviar: TSpeedButton;
    edt_RG: TEdit;
    edt_CPF: TEdit;
    edt_Telefone: TEdit;
    edt_CEP: TEdit;
    edt_Logradouro: TEdit;
    edt_Numero: TEdit;
    edt_Complemento: TEdit;
    edt_Bairro: TEdit;
    edt_Cidade: TEdit;
    edt_Estado: TEdit;
    edt_Pais: TEdit;
    spb_Encerrar: TSpeedButton;
    edt_Nome: TEdit;
    btb_LocalizarCEP: TBitBtn;
    procedure btb_LocalizarCEPClick(Sender: TObject);
    procedure spb_EncerrarClick(Sender: TObject);
    procedure EDT_CEPKeyPress(Sender: ToBject; var Key: Char);
    procedure spb_EnviarClick(Sender: TObject);

  private
     function getDados(params: TEnderecoCompleto; tipoConsulta: TTipoConsulta): TJSONObject;
     procedure CarregarCep(JSON: TJSONObject);
     procedure Limpar_Edit(LimparCEP : Boolean = True);

  public
  var
     dadosEnderecoCompleto : TEnderecoCompleto;

  end;

var
  frm_Cad_Cli: Tfrm_Cad_Cli;
const
   C_SYS_CEP                = '<<CEP>>';
   CEP_NOTFOUND             = 'CEP não encontrado!';
   CEP_INVALID              = 'CEP inválido!';

implementation

{$R *.dfm}

procedure Tfrm_Cad_Cli.btb_LocalizarCEPClick(Sender: TObject);
var
   _LJsonObj : TJSONObject;
procedure Mostrar_Erro(Mensagem: String);
begin
  ShowMEssage(Mensagem);
  Limpar_Edit;
  edt_CEP.SetFocus;
end;

begin
             Limpar_Edit(False);

     If Length(edt_CEP.text) <> 8 then
      begin
             Mostrar_Erro(CEP_INVALID);
             Limpar_Edit;
             edt_CEP.SetFocus;
             Exit;
      end;
        If _LJsonObj <> nil then
          begin
             CarregarCep(_LJsonObj);
          end
        ELSE
          begin
              Mostrar_Erro(CEP_NOTFOUND);
              Limpar_Edit;
              edt_CEP.SetFocus;
              Exit;
          end;

    If edt_CEP.Text = '' then
     begin
      ShowMessage('Preenchimento Obrigatório!!!');
      edt_CEP.SetFocus;
     end;

     _LJsonObj := getDados(dadosEnderecoCompleto, tcEndereco);
end;

function Tfrm_Cad_Cli.getDados(params: TEnderecoCompleto; tipoConsulta: TTipoConsulta): TJSONObject;
var
  idHTTP        : TIdHTTP;
  idSSLHandler  : TIdSSLIOHandlerSocketOpenSSL;
  sslRetorno    : TStringStream;
  LSJSONObj     : TJSONObject;

begin
     try
       idHTTP                              := TIdHTTP.Create;
       idSSLHandler                        := TIdSSLIOHandlerSocketOpenSSL.Create;
       idHTTP.IOHandler                    := idSSLHandler;
       //idSSLHandler.SSLOptions.SSLVersions := [];

       sslRetorno := TStringStream.Create('');
       idHTTP.Get('https://viacep.com.br/ws/' + C_SYS_CEP + '/json', sslRetorno);


       if (idHTTP.ResponseCode = 200) and
          (not(Utf8ToAnsi(sslRetorno.DataString) = '{'#$A' "erro": true'#$A'}')) then
        begin
            Result := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes( Utf8ToAnsi(sslRetorno.DataString)), 0) as TJSONObject;
        end;
     finally
         FreeAndNil(idHTTP);
         FreeAndNil(idSSLHandler);
         sslRetorno.Destroy;
     end;
end;

procedure Tfrm_Cad_Cli.spb_EncerrarClick(Sender: TObject);
begin
    Application.Terminate;
end;

procedure Tfrm_Cad_Cli.spb_EnviarClick(Sender: TObject);
var
  XMLDocument: TXMLDocument;
  NodeTabela, NodeRegistro, NodeEndereco: IXMLNode;
  I: Integer;

begin
   XMLDocument := TXMLDocument.Create(Self);
  try
    XMLDocument.Active := True;
    NodeTabela := XMLDocument.AddChild('Pessoa');

    for I := 1 to 5 do
    begin
      NodeRegistro := NodeTabela.AddChild('REGISTRO');
      NodeRegistro.ChildValues['Nome'] := 'NOME ' + IntToStr(I);
      NodeRegistro.ChildValues['RG'] := 'RG ' + IntToStr(I);
      NodeRegistro.ChildValues['CPF'] := 'CPF ' + IntToStr(I);
      NodeRegistro.ChildValues['Telefone'] := 'TELEFONE ' + IntToStr(I);
      NodeEndereco := NodeRegistro.AddChild('ENDERECO');
      NodeRegistro.ChildValues['CEP'] := 'CEP ' + IntToStr(I);
      NodeEndereco.ChildValues['Logradouro'] := Format('RUA %d', [I]);
      NodeEndereco.ChildValues['Numero'] := I * 1000;
      NodeRegistro.ChildValues['Complemento'] := 'COMPLEMENTO ' + IntToStr(I);
      NodeRegistro.ChildValues['Bairro'] := 'BAIRRO ' + IntToStr(I);
      NodeRegistro.ChildValues['Cidade'] := 'CIDADE ' + IntToStr(I);
      NodeRegistro.ChildValues['Estado'] := 'eSTADO ' + IntToStr(I);
      NodeRegistro.ChildValues['Pais'] := 'PAIS ' + IntToStr(I);
    end;
    XMLDocument.SaveToFile('C:\PROJETOS DELPHI\Xml');

  finally
    XMLDocument.Free;
  end;
end;

procedure Tfrm_Cad_Cli.CarregarCep(JSON: TJSONObject);
begin
        Limpar_Edit(False);

        edt_Logradouro.Text      := JSON.Get('Logradouro').JsonValue.Value;
        edt_Numero.Text          := JSON.Get('Numero').JsonValue.Value;
        edt_Complemento.Text     := JSON.Get('Complemento').JsonValue.Value;
        edt_Bairro.Text          := JSON.Get('Bairro').JsonValue.Value;
        edt_Cidade.Text          := UpperCase(JSON.Get('Cidade').JsonValue.Value);
        edt_Estado.Text          := UpperCase(JSON.Get('Estado').JsonValue.Value);
        edt_Pais.Text            := UpperCase(JSON.Get('Pais').JsonValue.Value);
end;


procedure Tfrm_Cad_Cli.EDT_CEPKeyPress(Sender: ToBject; var Key: Char);
begin
  If Key <> #8 then
    if not (Key in ['0'..'9']) then
      Key := #0;
end;

procedure Tfrm_Cad_Cli.Limpar_Edit(LimparCEP : Boolean = True);
begin
   if (LimparCEP) then
     begin
       edt_Logradouro.Text      := '';
       edt_Numero.Text          := '';
       edt_Complemento.Text     := '';
       edt_Bairro.Text          := '';
       edt_Cidade.Text          := '';
       edt_Estado.Text          := '';
       edt_Pais.Text            := '';
     end;

end;

end.
