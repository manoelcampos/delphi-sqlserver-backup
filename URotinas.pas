unit URotinas;

interface

uses
   //DCP Crypt
   DCPcrypt2, DCPblockciphers, DCPdes, StdCtrls, DCPsha1,

   WinSock, JvValidators, 
   ExtCtrls, CheckLst, JPEG, Classes,
   ComCtrls, IniFiles, graphics, Controls, Windows,
   Forms, SysUtils, DB, ADODB,
   ShellApi, ShlObj,
   StrUtils, TypInfo{, Tools}
   {$IFDEF ClientDataSet}, DBClient{$ELSE}, DBTables{$ENDIF};


   {$IFNDEF ClientDataSet}
   function SomarCampo(var db: TADOConnection; TableName,
     expressao: String; where: String = ''): currency;
   {$ENDIF}
   {retorna o valor de uma propriedade de uma string
   de conexão}
   function GetConnectionStringParamValue(ConnStr, ParamName: String): String;

   function GetTableName(DataSet: TDataSet): String;
   function tbVazia(Mensagem: string; Table: TDataSet): boolean;
   procedure informacoes(tb: TDataSet; var lbRegAtual, lbNumRegs: TLabel);
   procedure OpenDS(DataSet: TDataSet);
   procedure CloseDS(DataSet: TDataSet);
   {$IFDEF ClientDataSet}
   function CdsBlobFieldToImage(BlobFieldOrigin: TBlobField; Image: TImage): Boolean;
   {$ENDIF}
   procedure ImageToBlobField(Image: TImage; Field: TBlobField);
   function tecla_atalho_dataset(
     dataset: {$IFDEF ClientDataSet}TClientDataSet{$ELSE}TDataSet{$ENDIF}; tecla: word;
     Shift: TShiftState; controle : TwinControl): boolean;

   function ShowModalForm(FormClass: TFormClass; var form): TModalResult;
   procedure ShowForm(FormClass: TFormClass; var Form; SetFormAsMDIChild: Boolean = true);
   function confirmar(texto: string): boolean;
   procedure ShowMsg(texto: string);
   function removeSimbolos(texto: String): String;
   function ChecaCPF(CPF: String): Boolean;
   function ChecaCNPJ(CNPJ: String):Boolean;
   function ChecaCPF_CNPJ(CPF_CNPJ: String): Boolean;
   function ZeroEsquerda(MaxLength: integer; Str: String): String;

   {verifica se uma tecla está pressionada. Use as constantes
   VK_DELETE, VK_ESCAPE, ...., como parâmetro. Para as teclas
   especiais use VK_F1, VK_F2 ... VK_SHIFT, ....
   }
   function KeyIsDown(const Key: integer): boolean;

   {retorna o Path do Executável (é utilizada a função ExtractFilePath(Application.ExeName)
   criei esta função para facilitar a obtenção do Path do EXE pois, isto é uma coisa que se usa
   muito e a sintaxe da função que retorna este dado e muito grande, logo criei esta para facilitar
   o meu trabalho   }
   function ExePath: String;


   function ExecuteAndWait(App, Params: string): Cardinal;
   function ValidateIniFilePath(const ConfigFilePath: String): String;
   
   function DateIsNull(DataStr: String): Boolean;
   function EMailValido(EMail: String): Boolean;
   function SiteValido(Site: String): Boolean;

   procedure EnableDisableSubControls(Control: TWinControl; Enable: Boolean);


   {Valida um campo ano verificando se ele está numa faixa permitida a partir
   do ano atual. O parâmetro DescricaoAno é como o ano deve ser
   mostrado na mensagem de erro. Caso o ano seja um campo "Ano de Fabricação"
   então, esta string será o valor do primeiro parâmetro.

   Exemplo: se o ano passado em Ano for 1800 e o ano da data atual
   for 2006, o TotalAnosAntesAnoAtual for 100 e TotalAnosAposAnoAtual
   for 150, então, a rotina informará que o ano é inválido
   pois não pode ser menor do que 100 anos do ano atual. Se o ano
   informado fosse 3000 a rotina informaria que ele é inválido
   pois não pode ser maior que 150 anos após o ano atual.

   Se o parâmetro TotalAnosAposAnoAtual for menor que zero, indica
   que o ano deve ser menor que o ano atual. Se o valor do parâmetro
   for -2, por exemplo, então o valor máximo para o ano informado deve ser 2 anos
   menor que o ano atual.}
   procedure ValidaAno(DescricaoAno: ShortString; DataAtual: TDate; Ano,
     TotalAnosAntesDataAtual: Word; TotalAnosAposAnoAtual: Integer);

  {Esta rotina utiliza a mesma lógica da ValidaAno. Internamente
  ela apenas chama a ValidaAno}
   procedure ValidaData(DescricaoData: ShortString; DataAtual, Data: TDate;
     TotalAnosAntesDataAtual: Word; TotalAnosAposAnoAtual: Integer);

   {* Converte uma string passada em Str para TStringList e retorna a string da
   * linha na posição Index
   **}
   function SplitStr(Str: String; Separador: Char; Index: Word; ValorPadrao: ShortString = ''): String; overload;

   function SplitStr(const Text: String; const delimiter: Char): TStringList; overload;

   {*Converte uma string passada em Str para TStringList e retorna a posição da string
   * ItemProcurado dentro da TStringList gerada a partir de Str.
   **}
   function SplitStrIndex(Str: String; ItemProcurado: String; Separador: Char): Integer;


   
   procedure AngleTextOut(ACanvas: TCanvas; Angle, X, Y: Integer; Str: string);

   function CheckListBoxCheckedCount(CheckListBox: TCheckListBox): Integer;

   function SelectFolder(wnd: HWND; Title: String): String;
   function ComputerName: String;
   function TempDir: String;
   function WinDir : String;

   {***Formata um número de versão para que fique
   no formato 0.0.0.0. Se um número de versão não possuir
   um dos valores entre os pontos, são adicionados zeros
   nos valores que faltam. Por exemplo, se o número
   de versão for 2.1, o resultado da função será 2.1.0.0*}
   function FormatFileVersion(Version: String): String;

   function FileVersion(FilePath: string): String;
   (***Compara duas versões de softwares.
   Se a versão em FileVersion1 for menor que FileVersion2,
   retorn -1, se for igual retorna 0, se for maior, retorn 1*)
   function FileVersionCompare(FileVersion1, FileVersion2: String): Integer;

   {* Obtém o número de série de uma partição do HD ou de um
   * compartilhamento de rede.
   * Uso:
   *     S := VolSerial('A', nil);
   *                   ou
   *     S := VolSerial(#0, '\\computador\c\');
   **}
   function VolSerial(const Drive: Char; Path: PChar = nil): String;
   function ValidateFileName(FileName: String; IsDirectory: Boolean = false): TFileName;

   {* Função utilizada para executar o programa Update que eu desenvolvi para fazer
   *  atualização de algum sistema para um novo executável.
   *  Retorna true se o ShellExecute foi executado com êxito
   **}
   function Atualizar(UpdateProgram, NovoEXE: String;
      Opcao: String = 'Nao_Delete_EXE_Origem'):boolean;

   procedure ExecuteJvValidators(JvValidators: TJvValidators);
   procedure IniWriteString(IniFile, Section, Id, Value: String);
   procedure IniWriteInt(IniFile, Section, Id: String; Value: Integer);
   function IniReadString(IniFile, Section, Id: String; Default: String = ''): String;
   function IniReadInt(IniFile, Section, Id: String; Default: Integer = 0): Integer;
(***Executar programas e abrir arquivos,
com opção de download caso o arquivo não exista.

@param Caminho Caminho completo do aplicativo/arquivo a ser executado/aberto.
@param Parametros Parametros a serem passados ao aplicativo. Este parâmetro
é opcional.
@param UrlDownload Url para download do aplicativo/arquivo, caso o mesmo
não exista. O parâmetro é opcional.
@returns Retorna true se a aplicação foi executada com sucesso.*)
   function ExecutarPrograma(
      Caminho: String; Parametros: String = '';
      UrlDownload: String = ''): Boolean;

   {***Indica se o servidor de banco de dados, a partir do
   seu IP está localizado no próprio computador
   ou em um computador remoto.
   @param sIpOrServerDNS IP ou Nome DNS do servidor
   @param sLocalIP IP da máquina local
   @param sLocalDnsName Nome DNS da máquina local
   @returns Retorna true caso o servidor seja local.*}
   function DatabaseServerIsLocal(sIpOrServerDNS, sLocalIP, sLocalDnsName: String): Boolean;

   {***Retorna o IP local da primeira interface de rede
   @returns Retorna o IP local da primeira interface de rede*}
   function LocalIP: string;
   {***A partir do IP local, retorna o nome DNS da máquina.
   @param IPAddr IP Local
   @returns Retorna o nome DNS da máquina
   @see LocalIP*}
   function IPAddrToName(IPAddr: string): string;

   function Crypt(Text: String): String;
   function Decrypt(Text: String): String;

   function SemAcentos(Str: String; RemoveSpaces: Boolean = false; ReplaceAccentedCharsWithSqlPercent: Boolean = false): String;

   function IncI(var i: Integer): Integer;

const
  ColorEnabled: Array [boolean] of TColor = (clBtnFace, clWindow);

  ADOErros: array [1..4] of string =
    (
     ', pois a propriedade Required desse campo está definida como True.',

     ' no índice, chave primária ou relação. Altere os dados no ' +
     'campo ou campos que contêm os dados duplicados, remova o ' +
     'índice ou redefina o índice para possibilitar entradas ' +
     'duplicadas e tente novamente',

     'não pode ser uma seqüência de caracteres de comprimento nulo',
     'não pode conter um valor nulo'
    );

implementation

procedure AngleTextOut(ACanvas: TCanvas; Angle, X, Y: Integer; Str: string);
var
  LogRec: TLogFont;
  OldFontHandle,
  NewFontHandle: hFont;
begin
  GetObject(ACanvas.Font.Handle, SizeOf(LogRec), Addr(LogRec));
  LogRec.lfEscapement := Angle*10;
  NewFontHandle := CreateFontIndirect(LogRec);
  OldFontHandle := SelectObject(ACanvas.Handle, NewFontHandle);
  ACanvas.TextOut(X, Y, Str);
  NewFontHandle := SelectObject(ACanvas.Handle, OldFontHandle);
  DeleteObject(NewFontHandle);
end;

function SplitStr(Str: String; Separador: Char; Index: Word; ValorPadrao: ShortString = ''): String; overload;
var list: TStringList;
begin
  result:= '';
  list:= TStringList.Create;
  try
    list.Text := AnsiReplaceText(Str, Separador, #13);
    if Index > list.Count-1 then
       result:= ''
    else result:= list[Index];
  finally
    list.free;
  end;
end;

function SplitStrIndex(Str: String; ItemProcurado: String; Separador: Char): Integer;
var list: TStringList;
begin
  list:= TStringList.Create;
  try
    list.Text := AnsiReplaceText(Str, Separador, #13);
    result:= list.IndexOf(ItemProcurado);
  finally
    list.free;
  end;
end;

procedure OpenDS(DataSet: TDataSet);
begin
  DataSet.Tag := DataSet.Tag + 1;
  DataSet.Open;
end;

procedure CloseDS(DataSet: TDataSet);
begin
  DataSet.Tag:= DataSet.Tag - 1;
  if DataSet.Tag <= 0 then
     DataSet.Close;
end;

function ValidateFileName(FileName: String; IsDirectory: Boolean = false): TFileName;
begin
  if not IsDirectory then
  begin
    FileName:= AnsiReplaceText(FileName, '\',' ');
    FileName:= AnsiReplaceText(FileName, '/',' ');
  end;
  FileName:= AnsiReplaceText(FileName, ':',' ');
  FileName:= AnsiReplaceText(FileName, '*',' ');
  FileName:= AnsiReplaceText(FileName, '?',' ');
  FileName:= AnsiReplaceText(FileName, '"',' ');
  FileName:= AnsiReplaceText(FileName, '<',' ');
  FileName:= AnsiReplaceText(FileName, '>',' ');
  FileName:= AnsiReplaceText(FileName, '|',' ');
  result:= FileName;
end;

Function DateIsNull(DataStr: String): Boolean;
begin
  DataStr:= AnsiReplaceStr(DataStr,' ','');
  DataStr:= AnsiReplaceStr(DataStr,'/','');
  DataStr:= AnsiReplaceStr(DataStr,':','');
  DataStr:= trim(DataStr);
  result:= (DataStr = '');
end;

function VolSerial(const Drive: Char; Path: PChar): String;
  { Uso: S := VolSerial('A'); ou
  S := VolSerial(#0, '\\computador\c\'); }
var
  res, MaxCompLen, FileSysFlag, PrevErrorMode: Cardinal;
begin
  if Path = nil then
     Path := PChar(Drive + ':\');

  PrevErrorMode := SetErrorMode(SEM_FAILCRITICALERRORS);
  try
    if not GetVolumeInformation(PChar(Path), nil, 0,
    @Res, MaxCompLen, FileSysFlag, nil, 0) then
       Res := 0;
  finally
    result:= IntToHex(Res,8);
    SetErrorMode(PrevErrorMode);
  end;
end;

Function WinDir : String;
Var
  Buffer : Array[0..144] of Char;
Begin
  GetWindowsDirectory(Buffer,144);
  Result := StrPas(Buffer);
  result:= IncludeTrailingBackslash(result);
End;

function ExePath: String;
begin
  result:= ExtractFilePath(Application.ExeName);
end;

function ZeroEsquerda(MaxLength: integer; Str: String): String;
begin
   while length(str) < MaxLength do
     str:= '0' + str;
   result:= str;
end;

function TempDir: String;
var dir: PChar;
begin
  GetMem (dir,255);
  try
    if GetTempPath(255,dir) = 0 then
    begin
       if not DirectoryExists('c:\temp') then
          CreateDir('c:\temp');
       result:= 'c:\temp';
    end
    else result:= StrPas(dir);
    result:= IncludeTrailingBackslash(result);
  finally
    FreeMem(dir);
  end;
end;

Function ComputerName: String;
var
  lpBuffer : PChar;
  nSize    : DWord;
const
  Buff_Size = MAX_COMPUTERNAME_LENGTH + 1;
begin
  nSize := Buff_Size;
  lpBuffer := StrAlloc(Buff_Size);
  GetComputerName(lpBuffer,nSize);
  Result := String(lpBuffer);
  StrDispose(lpBuffer);
end;

function SelectFolder(wnd: HWND; Title: String): String;
var
  lpItemID: PItemIDList;
  BrowseInfo: TBrowseInfo;
  DisplayName: array[0..MAX_PATH] of char;
  TempPath: array[0..MAX_PATH] of char;
begin
  FillChar(BrowseInfo, sizeof(TBrowseInfo), #0);
  BrowseInfo.hwndOwner := wnd;
  BrowseInfo.pszDisplayName := @DisplayName;
  BrowseInfo.lpszTitle := PChar(Title);
  BrowseInfo.ulFlags := BIF_RETURNONLYFSDIRS;
  lpItemID := SHBrowseForFolder(BrowseInfo);
  if lpItemId <> nil then
  begin
    SHGetPathFromIDList(lpItemID, TempPath);
    Result := TempPath;
    GlobalFreePtr(lpItemID);
  end else
    Result := '';
end;

procedure informacoes(tb: TDataSet; var lbRegAtual, lbNumRegs: TLabel);
begin
   if (tb.recNo = -1) or (tb.recordCount = 0) then
      lbRegAtual.caption:= ''
   else lbRegAtual.caption:= 'Registro atual: ' + intToStr(tb.recNo);
   lbNumRegs.caption:= 'Nº de Registros: ' + intToStr(tb.recordCount);
end;

function ChecaCNPJ(CNPJ: String): Boolean;
Var
  d1,d4,d2,Conta,fator,sobra,digito1,digito2 : Integer;
  valor, Check : String;
begin
    result:= false;
    valor:= CNPJ;
    valor:= removeSimbolos(valor);
    if Length(valor) <> 14 then Exit;
    
    d1 := 0;  {valor padrao}
    d4 := 0;  {valor padrao}
    d2 := 1;  {valor padrao}
    for Conta := 1 to Length( Valor )-2 do
    begin
       if d2 < 5 then
          fator := 6 - d2
       else fator := 14 - d2;
       d1 := d1 + StrToInt(Copy(Valor,Conta,1))*fator;
       if d2 < 6 then
          fator := 7 - d2
       else fator := 15 - d2;
       d4 := d4 + StrToInt(Copy(Valor,Conta,1))*fator;
       d2 := d2+1;
    end;
    sobra := (d1 mod 11);
    if sobra < 2 then
       digito1 := 0
    else digito1 := 11 - sobra;
    d4 := d4 + 2 * digito1;
    sobra := (d4 mod 11);
    if sobra < 2 then
       digito2 := 0
    else digito2 := 11 - sobra;
    Check := IntToStr(Digito1) + IntToStr(Digito2);
    if Check <> copy(Valor,succ(length(Valor)-2),2) then
       Result := False
    else Result := True;
end;

function removeSimbolos(texto: String): String;
var i: byte;
begin
   i:= 0;
   repeat
     inc(i);
     if not CharInSet(texto[i], ['0'..'9']) then
     begin
        delete(texto,i,1);
        dec(i);
     end;
   until i = length(texto);
   result:= texto;
end;

function ChecaCPF(CPF: String): Boolean;
var
   S: String;
   Soma, iDig, iPos, Fator, i: Integer;

begin
   Result := False;
   S := cpf;
   s:= removeSimbolos(s);
   { verifica o CPF possui 11 digitos }
   if Length(S) <> 11 then Exit;

   { calcula os 2 últimos dígitos }
   for iPos := 9 to 10 do
   begin
      Soma := 0;
      Fator := 2;

      for i := iPos downto 1 do
      begin
        Soma := Soma + StrToInt(S[i]) * Fator;
        Inc(Fator);
      end;

      iDig := 11 - Soma mod 11;
      if iDig > 9 then iDig := 0;

      { verifica os digitos com o forncedido }
      if iDig <> StrToInt( S[iPos + 1]) then
        Exit;
   end;

   Result := True;
end;


procedure ShowMsg(texto: string);
begin
  application.messageBox(PChar(texto),
         PChar('Informação'),mb_YesNo+mb_iconInformation);
end;

function confirmar(texto: string): boolean;
begin
  result:= (application.messageBox(PChar(texto),
         PChar('Confirmação'),mb_iconQuestion + mb_YesNo) = mrYes);
end;

{$IFNDEF ClientDataSet}
function SomarCampo(var db: TADOConnection;
  TableName, expressao: String; where: String = ''): currency;
begin
    with TADOQuery.create(nil) do
    try
       Connection := db;
       sql.text:=
          'select sum(' + expressao + ') as Total from ' + TableName;
       if where <> '' then
          sql.add(' where ' + where);
       open;
       result:= Fields[0].asCurrency;
    finally
       close;
       free;
    end;
end;
{$ENDIF}

function GetTableName(DataSet: TDataSet): String;

function ExtractTableNameFromSql(sql: String): String;
var i: integer;
begin
  sql:= AnsiLowerCase(sql);
  i:= pos('from', sql);
  if i <> 0 then
     sql:= copy(sql,i+4,length(sql))
  else raise Exception.Create(
    'Não foi possível encontrar o nome da tabela dentro da Query');
  sql:= trim(sql);

  i:= pos(' ', sql);
  if i <> 0 then
    sql:= copy(sql,1,i-1);
  result:= sql;

  i:= pos(#13, sql);
  if i <> 0 then
    sql:= copy(sql,1,i-1);
  result:= sql;
end;

begin
  result:= '';
  if (DataSet is TADOTable) then
    result:= TADOTable(DataSet).TableName
  else if (DataSet is TADOQuery) then
    result:= ExtractTableNameFromSql(TADOQuery(DataSet).SQL.Text)
  else if (DataSet is TADODataSet) then
  begin
    case TADODataSet(DataSet).CommandType of
      cmdText:
        result:= ExtractTableNameFromSql(TADODataSet(DataSet).CommandText);
      else result:= TADODataSet(DataSet).CommandText;
    end;
  end;
  result:= trim(result);
end;

procedure ShowForm(FormClass: TFormClass; var Form; SetFormAsMDIChild: Boolean);
begin
    if TForm(Form) = nil then
    begin
       Application.CreateForm(FormClass, Form);
       if SetFormAsMDIChild then
          TForm(form).FormStyle := fsMDIChild;
    end;
    TForm(Form).Show;
end;

Function ShowModalForm(FormClass: TFormClass; var form): TModalResult;
begin
  try
    Screen.cursor := crHourGlass;
    Application.CreateForm(FormClass, form);
    TForm(form).FormStyle := fsNormal;
    TForm(form).Visible := false;
  finally
    screen.cursor := crDefault;
  end;
  
  try
    result := TForm(Form).ShowModal;
  finally
    if TForm(Form) <> nil then
       TForm(Form).Release;
    TForm(Form):= nil;
  end;
end;

function tbVazia(Mensagem: string; Table: TDataSet): boolean;
begin
   if Table.recordCount = 0 then
   begin
      tbVazia:= true;
      application.MessageBox(PChar(mensagem),PChar('Aviso'),mb_iconstop);
   end
   else tbVazia:= false;
end;

function FormatFileVersion(Version: String): String;
const
  //Total de pontos que um número de versão deve ter
  numPontosFileVerson = 3;
var
  i, pontos: integer;
  c: Char;
begin
   pontos:= 0;
   //Conta quantos pontos tem
   for c in Version do
     if c = '.' then
        pontos:= pontos + 1;

   //adiciona os .0 que faltam para que o número de versão fique como 0.0.0.0
   for I := pontos+1 to numPontosFileVerson do
      Version:= Version + '.0';

   result:= version;
end;

function FileVersion(FilePath: string): String;
var
  size, size2: DWord;
  pt, pt2: Pointer;
begin
  result:= '';//indicar que o arquivo especificado não tem versão
  size:= GetFileVersionInfoSize(PChar(FilePath),size2);
  if size > 0 then
  begin
     GetMem(pt, size);
     try
       GetFileVersionInfo(PChar(FilePath),0,size,pt);
       VerQueryValue(pt,'\',pt2,size2);
       with TVSFixedFileInfo(pt2^) do
       begin
           result:=
             IntToStr(HiWord(dwFileVersionMS)) + '.' +
             IntToStr(LoWord(dwFileVersionMS)) + '.' +
             IntToStr(HiWord(dwFileVersionLS)) + '.' +
             IntToStr(LoWord(dwFileVersionLS))
       end;
     finally
       FreeMem(pt);
     end;
  end;
end;

function SplitStr(const Text: String; const delimiter: Char): TStringList; overload;
begin
  result := TStringList.Create;
  result.Delimiter := delimiter;
  result.DelimitedText := Text;
end;

function FileVersionCompare(FileVersion1, FileVersion2: String): Integer;

type
  TIntArray = Array of Integer;

  function StringListToIntArray(sl: TStringList): TIntArray;
  var
    i: integer;
  begin
    SetLength(result, sl.count);
    for i:= 0 to sl.count -1 do
       result[i]:= StrToIntDef(sl[i], 0);
  end;

var
  version1, version2: TStringList;
  aVersion1, aVersion2: TIntArray;
  i: Integer;
begin
  result:= 0;
          
  if FileVersion1 = '' then
     raise Exception.Create('O parâmetro FileVersion1 não pode ser vazio');
  if FileVersion2 = '' then
     raise Exception.Create('O parâmetro FileVersion2 não pode ser vazio');

  if FileVersion1 = FileVersion2 then
  begin
    result:= 0;
    exit;
  end;

  try
    //Formata os números de versão para que os dois tenham o mesmo total de pontos,
    //estando no formato 0.0.0.0
    FileVersion1:= FormatFileVersion(FileVersion1);
    FileVersion2:= FormatFileVersion(FileVersion2);

    //Divide a string do número de versão em um TStringList
    version1:= SplitStr(FileVersion1, '.');
    version2:= SplitStr(FileVersion2, '.');

    //Gera um vetor de inteiros do TStringList contendo o número da versão
    aVersion1:= StringListToIntArray(Version1);
    aVersion2:= StringListToIntArray(Version2);

    //Compara as versões
    for i := 0 to high(aVersion1) do
    begin
       if aVersion1[i] < aVersion2[i] then
       begin
         result:= -1;
         exit;
       end
       else if aVersion1[i] > aVersion2[i] then
       begin
         result:= 1;
         exit;
       end;
       //se for igual, continua o for
    end;
  finally
    FreeAndNil(version1);
    FreeAndNil(version2);
    SetLength(aVersion1, 0);
    SetLength(aVersion2, 0);
  end;
end;


{parâmetros da função
  UpdateProgram - path do programa que faz a atualização (este só tem no servidor local)
  NovoEXE - path da nova versão do EXE do programa a ser atualizado
  Opcao - Os valores possíveis para este parâmetro são:
     Nao_Delete_EXE_Origem = indica que o programa informado no parâmetro NovoEXE NÃO deve ser deletado após a atualização
     Delete_EXE_Origem = indica que o programa informado no parâmetro NovoEXE deve ser deletado após a atualização
}
function Atualizar(UpdateProgram, NovoEXE: String; Opcao: String): boolean;
  {os parâmetros que devem ser passados para o
   programa que faz a atualização (update.exe)
   pra que ele execute seu trabalho são os mostrados abaixo

   NovoEXE : string;
   //paramStr(1)

   PathCliente: string;
   //paramStr(2)  // nome e caminho do executável no cliente.

   Opcao: ShortString;
   //paramStr(3)
}
var params: string;
begin
   params:= '"' + NovoEXE + '"' + ' ' +
            '"' +  Application.ExeName  + '" ' + opcao;
   result:=
     (ShellExecute(
      application.handle,'open',PChar(UpdateProgram),
      PChar(params),'',sw_showNormal) > 32);
end;


{abre uma Table, se ela não estiver aberta,
e retorna o números de formulários que a estão usando.
Sempre que um form é aberto, ele chama esta função
para abrir suas Tables, e a função incrementa o tag
da Table que foi passada como parâmetro.
Assim pode-se saber quantos forms estão usando esta Table.}
{Function AbrirTb(DataSet: TDataSet): Integer;
begin
   if DataSet.tag = 0 then
      DataSet.Open
   else if not DataSet.Active then
   begin
      DataSet.tag:= 0;
      DataSet.Open;
   end;
   DataSet.tag:= DataSet.tag + 1;
   result:= DataSet.tag;
end;}

{fecha uma Table, se ela não estiver sendo usada,
e retorna o números de formulários que a estão usando.
Sempre que um form é fechado, ele chama esta função
para fechar suas Tables, e a função decrementa o tag
da Table que foi passada como parâmetro.
Assim pode-se saber quantos forms estão usando esta Tabela.}
{function FecharTb(DataSet: TDataSet): Integer;
begin
   if DataSet.tag = 0 then
      DataSet.close;
   DataSet.tag:= DataSet.tag -1;
   result:= DataSet.tag;
end;}

function EMailValido(EMail: String): Boolean;
var
  i, cont, tamanho: integer;
  aux: String;
begin
  if email = '' then
  begin
    result:= true;
    exit;
  end;

  email:= AnsiLowerCase(EMail);
  tamanho:= length(EMail);
  //1 - verifica se o email contém somente caracteres válidos
  for i:= 1 to tamanho do
  begin
     if not CharInSet(email[i], ['a'..'z','0'..'9','_','-','.','@']) then
     begin
       result:= false;
       exit;
     end;
  end;

  //2 - verifica quantas @ tem no email
  cont:= 0;
  for i:= 1 to tamanho do
  begin
     if email[i] = '@' then
       cont:= cont + 1;
  end;
  if cont <> 1 then
  begin
    result:= false;
    exit;
  end;

  {3 - verifica se existe um texto antes da @ (pois se chegou até aqui é porque existe somente uma @)
   se o caractere na posição 1 do email for a @, então não há um texto antes deste caractere, log
   o email é inválido}
  if email[1] = '@' then
  begin
     result:= false;
     exit;
  end;

  {4 - verifica se o caractere antes da arroba é um ponto, se for, o email é inválido}
  i:= pos('@',email);
  if email[i-1] = '.' then
  begin
    result:= false;
    exit;
  end;

  {5 - verifica se existe um texto depois da @}
  //a variável I já está armazenando a posição da @ (isto foi feito no código acima)
  aux:= copy(email,i+1,tamanho);
  if aux = '' then
  begin
     result:= false;
     exit;
  end;

  {6 - verifica se o caractere seguinte a @ é um ponto, se for o email é inválido }
  if email[i+1] = '.' then
  begin
    result:= false;
    exit;
  end;

  //7 - ter pelos menos um ponto depois do texto após a @ (o ponto não pode ser o caractere seguinte a @)
  //copia o texto após a @
  aux:= copy(email,i+1,tamanho);
  //se não existir no texto após a @, o email é inválido 
  if pos('.',aux) = 0 then
  begin
    result:= false;
    exit;
  end;

  //verifica se o email termina com . (se terminar é inválido)
  if email[tamanho] =  '.' then
  begin
    result:= false;
    exit;
  end;

  //se chegar até aqui é porque tudo foi verificado e o email é válido
  result:= true;
end;

function SiteValido(Site: String): Boolean;
var
  i, cont, tamanho: integer;
begin
  if Site = '' then
  begin
    result:= true;
    exit;
  end;

  Site:= AnsiLowerCase(Site);
  tamanho:= length(Site);
  //1 - verifica se o site contém somente caracteres válidos
  for i:= 1 to tamanho do
  begin
     if not CharInSet(Site[i], ['a'..'z','0'..'9','_','-','.']) then
     begin
       result:= false;
       exit;
     end;
  end;

  //2 - verifica quantos . tem no site
  cont:= 0;
  for i:= 1 to tamanho do
  begin
     if Site[i] = '.' then
       cont:= cont + 1;
  end;
  if cont < 1 then
  begin
    result:= false;
    exit;
  end;

  {Não pode começar com .}
  if Site[1] = '.' then
  begin
     result:= false;
     exit;
  end;

  {Não pode terminar com .}
  if Site[tamanho] = '.' then
  begin
    result:= false;
    exit;
  end;

  {Não pode ter dois pontos consecutivos}
  if pos('..', site) > 0 then
  begin
     result:= false;
     exit;
  end;

  //se chegar até aqui é porque tudo foi verificado e o site é válido
  result:= true;
end;

function tecla_atalho_dataset(dataset: {$IFDEF ClientDataSet}TClientDataSet{$ELSE}TDataSet{$ENDIF}; tecla: word;
  Shift: TShiftState; controle : TwinControl): boolean;

procedure SetarFoco;
begin
  if (controle <> nil) AND controle.Enabled then
  begin
     if ((controle.Parent is TTabSheet)
     and TTabSheet(controle.Parent).Visible)
     or (not (controle.Parent is TTabSheet)) then
        controle.SetFocus;
  end;
end;

begin
  result:= true;
  {usando dataset.DisableControls e dataset.EnableControls
  nesta função causava erro "Grid Index Out of Bounds" }
    //showmessage(dataset.name);
    case tecla of
      vk_prior: dataset.Prior;
      vk_next: dataset.Next;
      vk_escape:
      begin
        dataset.Cancel;
        SetarFoco;
      end;
      vk_insert:
      begin
        { TODO -oManoel -cVerificar :
        o Append não estava funcionando, o registro atual sumia,
        por isso usei Insert }
        if Shift = [] then
        begin
          //dataset.DisableControls;
          dataset.Insert;
          SetarFoco;
        end
        else result:= false;
      end;
      vk_delete:
      begin
        if (Shift = [ssCTRL]) and
        DataSet.Active and (dataset.RecordCount > 0) then
        begin
          if Application.MessageBox('Tem certeza que deseja excluir o item?',
          'Confirmação', mb_iconQuestion + mb_OKCancel + mb_DefButton2) = mrOK then
          begin
             //dataset.DisableControls;
             dataset.Delete;
             SetarFoco;
             {$IFDEF ClientDataSet}
             if dataset.ProviderName <> '' then
             begin
               if dataset.ApplyUpdates(0) > 0 then
                  dataset.CancelUpdates;
             end;
             {$ENDIF}
          end
          else result:= false;
        end;
      end;
      else result:= false;
    end;
end;

{$IFDEF ClientDataSet}
function CdsBlobFieldToImage(BlobFieldOrigin: TBlobField; Image: TImage): Boolean;
var
  BlobStream: TClientBlobStream;
  JPEGImage: TJPEGImage;
begin
  Image.Picture := nil;
  result:= false;
  if BlobFieldOrigin.BlobSize > 0 then
  begin
    BlobStream := TClientBlobStream.Create(BlobFieldOrigin, bmRead);
    //BlobStream := cds.CreateBlobStream(BlobFieldOrigin, bmRead);
    JPEGImage := TJPEGImage.Create;
    try
      JPEGImage.LoadFromStream(BlobStream);
      Image.Picture.Assign(JPEGImage);
    finally
      BlobStream.Free;
      JPEGImage.Free;
    end;
    result:= true;
  end;
end;
{$ENDIF}

procedure ImageToBlobField(Image: TImage; Field: TBlobField);
var
  jpg: TJPEGImage;
  s: TMemoryStream;
begin
  jpg := TJPEGImage.Create;
  try
    jpg.Assign(Image.Picture.Bitmap);
    s:= TMemoryStream.Create;
    jpg.SaveToStream(s);
    Field.DataSet.Edit;
    Field.LoadFromStream(s);
  finally
    FreeAndNil(jpg);
    FreeAndNil(s);
  end;
end;


function CheckListBoxCheckedCount(
  CheckListBox: TCheckListBox): Integer;
var i: integer;
begin
  result:= 0;
  for i:= 0 to CheckListBox.Items.Count -1 do
    if CheckListBox.Checked[i] then
       result:= result + 1;
end;


procedure EnableDisableSubControls(Control: TWinControl; Enable: Boolean);
var
   i: integer;
begin
   for i:= 0 to Control.ControlCount -1 do
   begin
      if GetPropInfo(Control.Controls[i], 'Enabled', []) <> nil then
      begin
        SetOrdProp(Control.Controls[i], 'Enabled', ord(Enable));
        if GetPropInfo(Control.Controls[i], 'Color', []) <> nil then
           SetOrdProp(Control.Controls[i], 'Color', ColorEnabled[Enable]);
      end;
   end;
end;

procedure ValidaAno(DescricaoAno: ShortString; DataAtual: TDate; Ano,
  TotalAnosAntesDataAtual: Word; TotalAnosAposAnoAtual: Integer);
var AnoAtual, MenorAno, MaiorAno: Word;
begin
  AnoAtual := StrToInt(FormatDateTime('yyyy', DataAtual));
  if (TotalAnosAntesDataAtual = 0) and (TotalAnosAposAnoAtual = 0) then
      raise exception.CreateFmt('O %s deve ser igual ao ano atual (%d).',
         [DescricaoAno, AnoAtual]);

  MenorAno:= AnoAtual - TotalAnosAntesDataAtual;
  if Ano < MenorAno then
     raise exception.CreateFmt('O %s deve ser maior ou igual a %d.',
       [DescricaoAno, MenorAno]);
  MaiorAno:= AnoAtual + TotalAnosAposAnoAtual;
  if Ano > MaiorAno then
  begin
     if TotalAnosAposAnoAtual = 0 then
        raise exception.CreateFmt('O %s deve ser menor ou igual ao ano atual (%d).',
               [DescricaoAno, AnoAtual])
     else if TotalAnosAposAnoAtual = -1 then
        raise exception.CreateFmt('O %s deve ser menor que o ano atual (%d).',
               [DescricaoAno, AnoAtual])
     else if TotalAnosAposAnoAtual < -1 then
        raise exception.CreateFmt('O %s deve ser menor que %d.',
               [DescricaoAno, AnoAtual])
     else raise exception.CreateFmt('O %s deve ser menor ou igual a %d.',
       [DescricaoAno, MaiorAno]);
  end;
end;

procedure ValidaData(DescricaoData: ShortString; DataAtual, Data: TDate;
   TotalAnosAntesDataAtual: Word; TotalAnosAposAnoAtual: Integer);
var Ano: Word;
begin
  Ano := StrToInt(FormatDateTime('yyyy', Data));
  ValidaAno(DescricaoData, DataAtual, Ano, TotalAnosAntesDataAtual, TotalAnosAposAnoAtual);
end;

function ChecaCPF_CNPJ(CPF_CNPJ: String): Boolean;
begin
  result:= false;
  CPF_CNPJ := removeSimbolos(CPF_CNPJ);
  if length(CPF_CNPJ) = 11 then
     result:= ChecaCPF(CPF_CNPJ)
  else if length(CPF_CNPJ) = 14 then
     result:= ChecaCNPJ(CPF_CNPJ);
end;

function KeyIsDown(const Key: integer): boolean;
begin
  Result := GetKeyState(Key) and 128 > 0;
end;

function GetConnectionStringParamValue(ConnStr, ParamName: String): String;
var str: TStringList;
begin
  result:= '';
  ConnStr:= AnsiReplaceStr(ConnStr, ';', #13);
  str:= TStringList.Create;
  try
    str.Text := ConnStr;
    result:= str.Values[ParamName];
  finally
    FreeAndNil(str);
  end;
end;

procedure ExecuteJvValidators(JvValidators: TJvValidators);
var
  item: TJvBaseValidator;
  i: Integer;
begin
  if not JvValidators.Validate then
  begin
    for i:= 0 to JvValidators.Count -1 do
    begin
        item:= JvValidators.Items[i];
        if not item.Valid then
        begin
          if item.ControlToValidate is TWinControl then
             TWinControl(item.ControlToValidate).SetFocus;
          raise Exception.Create(item.ErrorMessage);
        end;
    end;
  end;
end;

procedure IniWriteString(IniFile, Section, Id, Value: String);
var
  ini: TIniFile;
begin
  ini:= TIniFile.Create(IniFile);
  try
    ini.WriteString(Section, Id, Value);
  finally
    ini.Free;
  end;
end;

procedure IniWriteInt(IniFile, Section, Id: String; Value: Integer);
var
  ini: TIniFile;
begin
  ini:= TIniFile.Create(IniFile);
  try
    ini.WriteInteger(Section, Id, Value);
  finally
    ini.Free;
  end;
end;

function IniReadString(IniFile, Section, Id, Default: String): String;
var
  ini: TIniFile;
begin
  ini:= TIniFile.Create(IniFile);
  try
    result:= ini.ReadString(Section, Id, Default);
  finally
    ini.Free;
  end;
end;

function IniReadInt(IniFile, Section, Id: String; Default: Integer): Integer;
var
  ini: TIniFile;
begin
  ini:= TIniFile.Create(IniFile);
  try
    result:= ini.ReadInteger(Section, Id, Default);
  finally
    ini.Free;
  end;
end;

function ExecutarPrograma(
  Caminho: String; Parametros: String;
  UrlDownload: String): Boolean;
var
  res: Cardinal;
  msg: String;
  baixar: Boolean;
begin
   res:= ShellExecute(
     Application.Handle, 'open', pchar(caminho),
     pchar(parametros), nil, SW_SHOWDEFAULT);
   result:= res > 32;
   case res of
      0: msg:= 'O sistema está sem memória ou recursos para executar esta aplicação.';
      ERROR_BAD_FORMAT: msg:= 'O arquivo executável "'+ caminho +'" é inválido.';
      ERROR_FILE_NOT_FOUND: msg:= 'O arquivo "' + caminho + '" não foi encontrado.';
      ERROR_PATH_NOT_FOUND: msg:= 'O caminho "'+ ExtractFilePath(caminho) +'" não existe.';
      SE_ERR_ACCESSDENIED: msg:= 'Acesso negado ao arquivo "'+caminho+'".';
      SE_ERR_NOASSOC: msg:= 'Não existe nenhuma aplicação '+
           'associada para a extensão ' + ExtractFileExt(Caminho);
      SE_ERR_OOM: msg:= 'Não existe memória suficiente para completar a operação.';
      SE_ERR_SHARE: msg:= 'O arquivo "'+caminho+'" já foi aberto em modo exclusivo.';
   end;

   baixar:= (res in [ERROR_BAD_FORMAT, ERROR_FILE_NOT_FOUND]) and (UrlDownload <> '');
   if baixar then
      msg:= msg + #13'O navegador será aberto para você baixar o arquivo.';

   if not result then
      Application.MessageBox(pchar(msg), 'Erro', MB_ICONERROR);

   if baixar then
      ExecutarPrograma(UrlDownload);
end;

function LocalIP: string;
type
  TaPInAddr = array[0..10] of PInAddr;
  PaPInAddr = ^TaPInAddr;
var
  phe: PHostEnt;
  pptr: PaPInAddr;
  Buffer: array[0..63] of AnsiChar;
  I: Integer;
  GInitData: TWSAData;
begin
  WSAStartup($101, GInitData);
  Result := '';
  GetHostName(Buffer, SizeOf(Buffer));
  phe := GetHostByName(buffer);
  if phe = nil then
     Exit;
  pPtr := PaPInAddr(phe^.h_addr_list);
  I := 0;
  while pPtr^[I] <> nil do
  begin
    Result := inet_ntoa(pptr^[I]^);
    Inc(I);
  end;
  WSACleanup;
end;

function IPAddrToName(IPAddr: string): string;
var
  SockAddrIn: TSockAddrIn;
  HostEnt: PHostEnt;
  WSAData: TWSAData;
begin
  WSAStartup($101, WSAData);
  SockAddrIn.sin_addr.s_addr := inet_addr(PAnsiChar(AnsiString(IPAddr)));
  HostEnt := gethostbyaddr(@SockAddrIn.sin_addr.S_addr, 4, AF_INET);
  if HostEnt <> nil then
     Result := StrPas(Hostent^.h_name)
  else Result := EmptyStr;
end;

function DatabaseServerIsLocal(sIpOrServerDNS, sLocalIP, sLocalDnsName: String): Boolean;
begin
  if sLocalIP = '' then
     sLocalIP:= LocalIP;
  if sLocalDnsName = '' then
     sLocalDnsName:= IPAddrToName(sLocalIP);
  
  result:=
    AnsiStartsText('127.0.0.1', sIpOrServerDNS) or
    AnsiStartsText('127.1', sIpOrServerDNS) or
    AnsiStartsText('.', sIpOrServerDNS) or
    AnsiStartsText('localhost', sIpOrServerDNS) or
    AnsiStartsText(sLocalIP, sIpOrServerDNS) or
    AnsiStartsText(sLocalDnsName, sIpOrServerDNS)
end;

function ExecuteAndWait(App, Params: string): Cardinal;
var
  StartupInfo: TStartupInfo;
  ProcessInfo: TProcessInformation;
  s: array[0..MAX_PATH] of char;
begin
  //Se a aplicação não tiver a extensão, dará erro na execução.
  //O nome deve ter completo, seja lá com qual extensão for: .com, .bat, .exe, etc
  //Se não houver uma extensão, considera-se que é .exe
  if ExtractFileExt(App) = '' then
     App:= App + '.exe';
     
  GetStartupInfo(Startupinfo);

  ExpandEnvironmentStrings(pChar(App), @s, MAX_PATH);
  App := string(pChar(@s));

  if CreateProcess(pChar(App),
    pChar(App + ' ' + Params),
    nil, nil, false, 0, nil,
    pchar(ExePath), StartupInfo, ProcessInfo) then
  begin
    CloseHandle(ProcessInfo.hThread);
    WaitForSingleObject(ProcessInfo.hProcess, INFINITE);
    GetExitCodeProcess(ProcessInfo.hProcess, result);
    CloseHandle(ProcessInfo.hProcess);
  end
  else
    raise Exception.CreateFmt(
      'Não foi possível criar o processo %s %s: %d', [App, Params, GetLastError]);
end;

function ValidateIniFilePath(const ConfigFilePath: String): String;
begin
   result:= ConfigFilePath;
   if ExtractFilePath(result) = '' then
      result:= ExePath + result;
end;

//-------------------------------------------------

function TripleDes(Text: String; CryptString: Boolean): String;
const key = '{FF7C9D93-868D-4D9B-BD3E-AE91D27E2169}';
var
  DCP_3des: TDCP_3des;
begin
  DCP_3des:= TDCP_3des.Create(nil);
  try
    DCP_3des.InitStr(key, TDCP_sha1);  // initialise the DCP_3des1 with the hash as key
    DCP_3des.CipherMode := cmCBC;   // use CBC chaining when encrypting
    if CryptString then
       result:= DCP_3des.EncryptString(Text) // encrypt the entire file
    else result:= DCP_3des.DecryptString(Text);
  finally
     //Desaloca as informações da chave de criptografia.
     //O Free faz isso automaticamente
     //DCP_3des1.Burn;

     DCP_3des.Free;
  end;
end;


function Crypt(Text: String): String;
begin
  result:= TripleDes(Text, true);
end;

function Decrypt(Text: String): String;
begin
  result:= TripleDes(Text, false);
end;

//-------------------------------------------------

function SemAcentos(Str: String; RemoveSpaces: Boolean; ReplaceAccentedCharsWithSqlPercent: Boolean): String;
type
  TTotalLetrasSet = 1..7;

const
  letrasSemAcento: array [TTotalLetrasSet] of Char = ('a', 'e', 'i', 'o', 'u', 'c', 'n');
  conjuntoAcentos: array [TTotalLetrasSet] of String =
    ('áàâãÁÀÂÃ', 'éèêÉÈÊ', 'íìîÍÌÎ', 'óòôõÓÒÔÕ', 'úùûÚÙÛ', 'çÇ', 'ñÑ');
var
  ch: Char;
  acentos: String;
  i, j: Integer;

begin
  result:= '';
  str:= trim(str);
  if RemoveSpaces then
     str:= AnsiReplaceStr(str, ' ', '');

  {Troca os caracteres acentuados por não acentuados}
  for i:= 1 to length(Str) do
  begin
     ch:= Str[i];
     for j:= 1 to length(conjuntoAcentos) do
     begin
       acentos:= conjuntoAcentos[j];
       if pos(ch, acentos) > 0 then
       begin
          if ReplaceAccentedCharsWithSqlPercent then
             ch:= '%'
          else ch:= letrasSemAcento[j];
          break;
       end;
     end;

     result:= result + ch;
  end;

  {Depois de trocar os acentos, percorre a string novamente.
  Se ainda sobraram caracteres não acentuados não identificados,
  estes são trocados ou pelo caractere de % da SQL
  ou são apagados.}
  Str:= result;
  result:= '';
  for i:= 1 to length(Str) do
  begin
    ch:= Str[i];
    if (not CharInSet(UpCase(ch), ['A'..'Z', '0'..'9', '/', '-', ':', ' '])) then
    begin
      if ReplaceAccentedCharsWithSqlPercent then
         ch:= '%'
      else ch:= #0;
    end;
    if ch <> #0 then
       result:= result + ch;
  end;
end;

function IncI(var i: Integer): Integer;
begin
  inc(i);
  result:= i;
end;

end.
