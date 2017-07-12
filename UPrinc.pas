unit UPrinc;

interface

uses
  StrUtils,
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, ADODB, IniFiles, URotinas, StdCtrls, ExtCtrls, JvExStdCtrls,
  JvCheckBox, Buttons, Mask, JvExMask, JvToolEdit, JvComponentBase,
  JvErrorIndicator, JvValidators, clipbrd;

type
  TBackupAction = (baBackup, baRestore, baNone);

  TFrmPrinc = class(TForm)
    conn: TADOConnection;
    rgpAcao: TRadioGroup;
    lbEdtBanco: TLabeledEdit;
    lbEdtServidor: TLabeledEdit;
    cbxAutenticacaoWin: TJvCheckBox;
    lbEdtUsuario: TLabeledEdit;
    lbEdtSenha: TLabeledEdit;
    btnFechar: TBitBtn;
    Label1: TLabel;
    edtNomeBackup: TJvFilenameEdit;
    btnExecutar: TBitBtn;
    JvErrorIndicator1: TJvErrorIndicator;
    JvValidators1: TJvValidators;
    JvRequiredFieldValidator1: TJvRequiredFieldValidator;
    JvRequiredFieldValidator2: TJvRequiredFieldValidator;
    JvRequiredFieldValidator3: TJvRequiredFieldValidator;
    JvCustomValidator1: TJvCustomValidator;
    JvCustomValidator2: TJvCustomValidator;
    Label2: TLabel;
    btnParametros: TBitBtn;
    Label3: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure btnExecutarClick(Sender: TObject);
    procedure rgpAcaoClick(Sender: TObject);
    procedure JvCustomValidator1Validate(Sender: TObject;
      ValueToValidate: Variant; var Valid: Boolean);
    procedure JvCustomValidator2Validate(Sender: TObject;
      ValueToValidate: Variant; var Valid: Boolean);
    procedure btnParametrosClick(Sender: TObject);
  private
    Provider: String;
    procedure ValidatorUsuarioSenha(ValueToValidate: Variant; var Valid: Boolean);
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmPrinc: TFrmPrinc;

function PodeRestaurarBackup(Server, Database: String): Boolean;
procedure ShowHelp;
function BackupRestore(
  conn: TADOConnection;
  Action: TBackupAction;
  Server, Database, NomeBackup, Usuario, Senha, Provider: String;
  AutenticacaoWin: Boolean): Boolean;
function ParamExists(ParamName: String; Posicao: Integer = -1): Boolean;
procedure LerConfigConexao(
  var Server, Database, NomeBackup, Usuario, Senha, Provider: String;
  var AutenticacaoWin: Boolean);

implementation

{$R *.dfm}

function PodeRestaurarBackup(Server, Database: String): Boolean;
var
  conn: TADOConnection;
begin
  result:= true;
  conn:= TADOConnection.Create(nil);
  try
    {tenta conectar no banco que está tentando ser restaurado,
    se ele existir, pede confirmação de restauração.}
    conn.ConnectionString:=
      'Provider=SQLOLEDB.1;' +
      'Integrated Security=SSPI;Persist Security Info=False;' +
      'Initial Catalog='+Database+';Data Source='+server;
    try
      conn.Open;
      {se a conexão foi estabelecida com sucesso, pede confirmação para restaurar
      o backup}
      result:=
        Application.MessageBox(
          pchar('Tem certeza que deseja restaurar o banco "'+Database+'"?'),
          'Confirmar Restauração de Banco de Dados',
          MB_ICONWARNING or MB_OKCANCEL or MB_DEFBUTTON2) = mrOK;
      conn.close;
    except
    end;
  finally
    conn.Free;
  end;
end;

procedure ShowHelp;
var msg: string;
begin
  msg:=
    'Uso (as configurações do backup são definidos no arquivo ini ' +
    'de configuração na pasta do programa) '#13  +
    #13'    Fazer Backup: ' + ExtractFileName(Application.ExeName) + ' -b ' +
    #13'    Restaurar Backup: ' + ExtractFileName(Application.ExeName) + ' -r [NomeArquivoBackup]' +
    #13'    Mostrar Ajuda: ' + ExtractFileName(Application.ExeName) + ' -h ' +
    #13#13'    Os parâmetros entre [colchetes] são opcionais, '+
    'se não informados, os valores serão lidos do arquivo de configuração.';
    
  Application.MessageBox(
    pchar(msg), 'SQLServer Backup/Restore', MB_ICONINFORMATION);
end;

procedure ConfigurarConexao(
  var conn: TADOConnection; Server: string;
  AutenticacaoWin: Boolean; Usuario, Senha, Provider: string);
begin
  conn.LoginPrompt := false;
  if AutenticacaoWin then
    conn.ConnectionString :=
       'Provider='+Provider+';' +
       'Integrated Security=SSPI;Persist Security Info=False;' +
       'Initial Catalog=master;Data Source=' + server
  else
    conn.ConnectionString :=
       'Provider='+Provider+';' +
       'User ID=' + Usuario + ';' +
       'Password=' + Senha + ';' +
       'Persist Security Info=True;' +
       'Initial Catalog=master;Data Source=' + server;
end;

(***Retorna o número do último backup diferencial existente no arquivo
*)
function IdUltimoBackup(conn: TADOConnection; ArqBackup: String): integer;
var
  sql: string;
  qry: TADOQuery;
begin
  result:= 0;
  sql:= 'RESTORE headeronly FROM DISK = ' + QuotedStr(ArqBackup);
  qry:= TADOQuery.Create(nil);
  try
    qry.Connection := conn;
    qry.sql.text:= sql;
    qry.Open;
    result:= qry.RecordCount;
    qry.Close;
  finally
    qry.Free;
  end;
end;

function RestoreDatabaseSQL(Databasename, ArqBackup: String; FullBackup: Boolean = true; NumBackup: Integer = 1): String;
begin
  result:=
    ' RESTORE DATABASE [' + Databasename + '] ' +
    ' FROM  DISK = N'+ QuotedStr(ArqBackup) +
    ' WITH  FILE = '+IntToStr(NumBackup)+', ' +
    ' MOVE N' + QuotedStr(Databasename+'_Data') + ' TO N' + QuotedStr(ExePath + Databasename+'.mdf') + ',' +
    ' MOVE N' + QuotedStr(Databasename+'_Log') + ' TO N' + QuotedStr(ExePath + Databasename+'_Log.ldf') + ',' +
    ' NOUNLOAD, REPLACE, STATS = 10 ';
  if FullBackup then
     result:= result + ', NORECOVERY ';
  result:= result + '; ';
end;

function BackupRestore(
  conn: TADOConnection;
  Action: TBackupAction;
  Server, Database, NomeBackup, Usuario, Senha, Provider: String;
  AutenticacaoWin: Boolean): Boolean;
var
  pathLog, dirBackup, erro, sql: String;
  log: TStringList;
  records, idUltimoBak: Integer;
begin
  result:= false;
  log:= TStringList.Create;
  try
    try
      pathLog:= ExePath + 'SQLServerBackup.log';
      if FileExists(pathLog) then
         log.LoadFromFile(pathLog);

      ConfigurarConexao(conn, Server, AutenticacaoWin, Usuario, Senha, Provider);

      if Action = baBackup then //se é pra fazer backup
      begin
        dirBackup:= ExtractFilePath(NomeBackup);

        if (not DirectoryExists(dirBackup)) and
        (not CreateDir(dirBackup)) then
        begin
           Application.MessageBox(
             pchar('Não foi possível criar a pasta "'+
             dirBackup+'" para gerar o backup.'), 'Erro', MB_ICONSTOP);
           abort;
        end;

        sql :=
          ' BACKUP DATABASE ['+Database+'] ' +
          ' TO DISK = N' + QuotedStr(NomeBackup) + ' WITH ';
        if FileExists(NomeBackup) then
           sql:= sql + ' DIFFERENTIAL, ';
        sql:= sql + ' NOFORMAT, NOINIT, ' +
          ' NAME = N' + QuotedStr('Backup ' + Database + ' Diferencial - Agendado') + ',' +
          ' SKIP, NOREWIND, NOUNLOAD,  STATS = 10 ';
        conn.Open;
        conn.Execute(sql, records, [eoExecuteNoRecords]);
        result:= true;
        log.Insert(0, 'Backup do banco "'+Database+
           '" executado com sucesso em ' + FormatDateTime('dd/mm/yyyy hh:nn:ss', now));
        {Só mostra a mensagem se o programa está rodando a partir
        da interface do form principal e não por linha de comando}
        if FrmPrinc <> nil then
           Application.MessageBox(
              'Backup do Banco de Dados realizado com Sucesso.',
              'Informação', MB_ICONINFORMATION);
      end
      else
      begin
        if PodeRestaurarBackup(Server, Database) then
        begin
          idUltimoBak:= IdUltimoBackup(conn, NomeBackup);

          sql:=
            RestoreDatabaseSQL(Database, NomeBackup, true) +
            RestoreDatabaseSQL(Database, NomeBackup, false, idUltimoBak);
          Clipboard.AsText := sql;
          conn.Open;
          conn.Execute(sql, records, [eoExecuteNoRecords]);
          result:= true;
          log.Insert(0, 'Restauração do banco "'+Database+
             '" executado com sucesso em ' + FormatDateTime('dd/mm/yyyy hh:nn:ss', now));
          {Só mostra a mensagem se o programa está rodando a partir
          da interface do form principal e não por linha de comando}
          if FrmPrinc <> nil then
             Application.MessageBox(
               'Restauração do Banco de Dados realizada com Sucesso.',
               'Informação', MB_ICONINFORMATION);
        end;
      end
    except
      on e: Exception do
      begin
         erro:= 'Erro ao criar/restaurar backup - ' +
                FormatDateTime('dd/mm/yyyy hh:nn:ss', now) + #13;
         erro:= erro + '   Mensagem de Erro: ' + e.Message + #13;
         erro:= erro + '   SQL: ' + sql + #13;         
         log.Insert(0, erro);
         Application.MessageBox(pchar(e.message), 'Erro', mb_iconError);
      end;
    end;
  finally
    log.SaveToFile(pathLog);
    conn.close;
    log.free;
  end;
end;

function ParamExists(ParamName: String; Posicao: Integer = -1): Boolean;
var
  I: Integer;
  Exists: Boolean;
begin
  result:= false;
  if ParamName = '' then
     exit;
     
  for I := 1 to ParamCount do
  begin
    if (ParamName[1] = '-') or ((ParamName[1] = '/')) then
       delete(ParamName, 1,1);
    
    {o parâmetro deve ser precedido de - ou /}
    Exists:=
      AnsiSameText(ParamStr(i), '-'+ParamName) or
      AnsiSameText(ParamStr(i), '/'+ParamName);
      
    if Exists and ((i = Posicao) or (posicao = -1)) then
    begin
       result:= true;
       break;
    end;
  end;
end;

procedure LerConfigConexao(
  var Server, Database, NomeBackup, Usuario, Senha, Provider: String;
  var AutenticacaoWin: Boolean);
var
  ini: TIniFile;
  ExePath, IniFileName: String;
begin
  ExePath := ExtractFilePath(Application.ExeName);
  if FileExists(ExePath + 'Conexao.ini') then
     IniFileName:= ExePath + 'Conexao.ini'
  else IniFileName:= ExePath + '..\Conexao.ini';
  ini:=  TIniFile.Create(IniFileName);
  Server:= ini.ReadString('DB', 'Server', '.\sqlexpress');
  {AppPath:= ini.ReadString('AppServer', 'Path', ExtractFilePath(Application.ExeName));
  AppPath:= trim(AppPath);

  if (AppPath <> '') then
     AppPath:= IncludeTrailingBackslash(AppPath);  }


  {quando existir um parametro -r, o segundo parâmetro, se existir, será o
  caminho do arquivo de backup a ser restaurado}
  if ParamStr(2) <> '' then
     NomeBackup:= ParamStr(2)
  else NomeBackup:= ini.ReadString('DB', 'NomeBackup', ExePath + 'BackupSipom.bak');

  Database:= ini.ReadString('DB', 'Database', 'Sipom');
  Provider:= ini.ReadString('DB', 'Provider', 'SQLNCLI.1');

  Usuario:= Decrypt(ini.ReadString('DB', 'User', Crypt('sa')));
  Senha:= Decrypt(ini.ReadString('DB', 'Password', Crypt('sqlexpr2005')));
  AutenticacaoWin := ini.ReadBool('DB', 'UseWindowsAuthentication', true);
end;

procedure TFrmPrinc.btnExecutarClick(Sender: TObject);
begin
  Screen.Cursor:= crHourGlass;
  btnExecutar.Enabled := false;
  try
    ExecuteJvValidators(JvValidators1);

    BackupRestore(
      conn, TBackupAction(rgpAcao.ItemIndex),
      lbEdtServidor.Text, lbEdtBanco.Text, edtNomeBackup.Text,
      lbEdtUsuario.Text, lbEdtSenha.Text, Provider, cbxAutenticacaoWin.Checked);
  finally
    Screen.Cursor:= crDefault;
    btnExecutar.Enabled := true;
  end;
end;

procedure TFrmPrinc.btnParametrosClick(Sender: TObject);
begin
  ShowHelp;
end;

procedure TFrmPrinc.FormCreate(Sender: TObject);
var
  Server, Database, NomeBackup, Usuario, Senha: String;
  AutenticacaoWin: Boolean;
begin
  LerConfigConexao(
     Server, Database, NomeBackup,
     Usuario, Senha, Provider, AutenticacaoWin);
  lbEdtServidor.Text := Server;
  lbEdtBanco.Text := Database;
  edtNomeBackup.Text:= NomeBackup;
  cbxAutenticacaoWin.Checked := AutenticacaoWin;

  {Como o restore, por medida de segurança, só será feito
  informando-se o usuário e senha do sql server,
  os dados se usuário e senha que possam estar gravados
  no arquivo ini de configuração não são carregados,
  para que o usuário sempre digite esses dados caso
  queira fazer um restore do banco de dados}
  {lbEdtUsuario.Text := Usuario;
  lbEdtSenha.Text := Senha;}
end;

procedure TFrmPrinc.JvCustomValidator1Validate(Sender: TObject;
  ValueToValidate: Variant; var Valid: Boolean);
begin
  ValidatorUsuarioSenha(ValueToValidate, Valid);
end;

procedure TFrmPrinc.JvCustomValidator2Validate(Sender: TObject;
  ValueToValidate: Variant; var Valid: Boolean);
begin
  ValidatorUsuarioSenha(ValueToValidate, Valid);
end;

procedure TFrmPrinc.ValidatorUsuarioSenha(ValueToValidate: Variant; var Valid: Boolean);
begin
  if (not cbxAutenticacaoWin.Checked) and (trim(ValueToValidate) = '') then
    Valid := false
  else Valid := true;
end;

procedure TFrmPrinc.rgpAcaoClick(Sender: TObject);
begin
  cbxAutenticacaoWin.Enabled := rgpAcao.ItemIndex = 0;
  if not cbxAutenticacaoWin.Enabled then
     cbxAutenticacaoWin.Checked := false;
end;

end.
