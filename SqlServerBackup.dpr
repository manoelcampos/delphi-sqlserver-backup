program SqlServerBackup;

uses
  Controls, StrUtils, Classes, Windows, SysUtils,
  Forms, IniFiles, AdoDb,
  UPrinc in 'UPrinc.pas' {FrmPrinc};

{$R *.res}

//restore: -r "C:\Arquivos de Programas\Sistema de Pesquisa de Opinião e Mercado\BackupSipom.bak"
var
  conn: TADOConnection;
  NomeBackup, server, database: String;
  sql, dirBackup, Usuario, Senha, Provider: String;
  AutenticacaoWin: Boolean;
  Action: TBackupAction;
begin
  Application.Initialize;

  //se não recebeu parâmetros, abre a interface gráfica
  if ParamCount = 0 then
  begin
     Application.Title := 'Gerenciador de Backup SQL Server';
     Application.CreateForm(TFrmPrinc, FrmPrinc);
  end
  else
  begin
    if ParamExists('?') or ParamExists('h') then
    begin
       ShowHelp;
       exit;
    end;

    if ParamExists('b') then
       Action:= baBackup
    else if ParamExists('r') then
       Action:= baRestore
    else Action:= baNone;

    if Action <> baNone then
    begin
      conn:= TADOConnection.Create(nil);
      try
         LerConfigConexao(
           Server, Database, NomeBackup,
           Usuario, Senha, Provider, AutenticacaoWin);
         BackupRestore(
           conn, Action, Server, Database, NomeBackup,
           Usuario, Senha, Provider, AutenticacaoWin);
      finally
        conn.Close;
        conn.free;
      end;
    end;
  end;
  Application.Run;
end.
