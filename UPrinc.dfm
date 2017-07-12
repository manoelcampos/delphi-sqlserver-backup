object FrmPrinc: TFrmPrinc
  Left = 0
  Top = 0
  ActiveControl = lbEdtServidor
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Gerenciador de Backup SQL Server'
  ClientHeight = 359
  ClientWidth = 428
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 169
    Width = 192
    Height = 13
    Caption = 'Nome do Arquivo de &Backup no Servidor'
    FocusControl = edtNomeBackup
  end
  object Label2: TLabel
    AlignWithMargins = True
    Left = 3
    Top = 340
    Width = 422
    Height = 16
    Align = alBottom
    Alignment = taCenter
    Caption = 'Desenvolvido por Manoel Campos - http://manoelcampos.com'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    ExplicitWidth = 404
  end
  object Label3: TLabel
    Left = 104
    Top = 44
    Width = 315
    Height = 26
    Alignment = taRightJustify
    Caption = 
      'Para restaurar um backup, o sistema que utiliza o banco de dados' +
      #13#10'deve estar fechado em todas as m'#225'quinas da rede'
  end
  object rgpAcao: TRadioGroup
    Left = 8
    Top = 1
    Width = 412
    Height = 41
    Caption = '&A'#231#227'o'
    Columns = 2
    ItemIndex = 0
    Items.Strings = (
      'Executar Backup'
      'Restaurar Backup')
    TabOrder = 0
    OnClick = rgpAcaoClick
  end
  object lbEdtBanco: TLabeledEdit
    Left = 8
    Top = 142
    Width = 377
    Height = 21
    EditLabel.Width = 122
    EditLabel.Height = 13
    EditLabel.Caption = 'Nome do &Banco de Dados'
    TabOrder = 2
  end
  object lbEdtServidor: TLabeledEdit
    Left = 8
    Top = 98
    Width = 377
    Height = 21
    EditLabel.Width = 180
    EditLabel.Height = 13
    EditLabel.Caption = 'Nome do &Servidor do Banco de Dados'
    TabOrder = 1
  end
  object cbxAutenticacaoWin: TJvCheckBox
    Left = 8
    Top = 219
    Width = 335
    Height = 17
    Caption = 'Usar Autentica'#231#227'o do &Windows para conectar ao Banco de Dados'
    Checked = True
    State = cbChecked
    TabOrder = 4
    LinkedControls = <
      item
        Control = lbEdtUsuario
        Options = [loLinkChecked, loInvertChecked]
      end
      item
        Control = lbEdtSenha
        Options = [loLinkChecked, loInvertChecked]
      end>
    HotTrackFont.Charset = DEFAULT_CHARSET
    HotTrackFont.Color = clWindowText
    HotTrackFont.Height = -11
    HotTrackFont.Name = 'Tahoma'
    HotTrackFont.Style = []
  end
  object lbEdtUsuario: TLabeledEdit
    Left = 8
    Top = 262
    Width = 89
    Height = 21
    EditLabel.Width = 36
    EditLabel.Height = 13
    EditLabel.Caption = '&Usu'#225'rio'
    Enabled = False
    TabOrder = 5
  end
  object lbEdtSenha: TLabeledEdit
    Left = 143
    Top = 262
    Width = 137
    Height = 21
    EditLabel.Width = 30
    EditLabel.Height = 13
    EditLabel.Caption = '&Senha'
    Enabled = False
    PasswordChar = '*'
    TabOrder = 6
  end
  object btnExecutar: TBitBtn
    Left = 8
    Top = 292
    Width = 75
    Height = 25
    Caption = '&Executar'
    DoubleBuffered = True
    Kind = bkOK
    NumGlyphs = 2
    ParentDoubleBuffered = False
    TabOrder = 7
    OnClick = btnExecutarClick
  end
  object btnFechar: TBitBtn
    Left = 345
    Top = 292
    Width = 75
    Height = 25
    Caption = '&Fechar'
    DoubleBuffered = True
    Kind = bkClose
    NumGlyphs = 2
    ParentDoubleBuffered = False
    TabOrder = 9
  end
  object edtNomeBackup: TJvFilenameEdit
    Left = 8
    Top = 185
    Width = 377
    Height = 21
    DefaultExt = '.bak'
    Filter = 
      'Arquivo de Backup do SQL Server (*.bak)|*.bak|Todos os Arquivos ' +
      '(*.*)|*.*'
    DialogTitle = 'Localizar Arquivo de Backup'
    TabOrder = 3
    Text = 'edtNomeBackup'
  end
  object btnParametros: TBitBtn
    Left = 104
    Top = 292
    Width = 225
    Height = 25
    Caption = '&Par'#226'metros de Linha de Comando'
    DoubleBuffered = True
    Kind = bkHelp
    NumGlyphs = 2
    ParentDoubleBuffered = False
    TabOrder = 8
    OnClick = btnParametrosClick
  end
  object conn: TADOConnection
    CommandTimeout = 600
    ConnectionString = 
      'Provider=SQLOLEDB.1;Password=kamikaze;Persist Security Info=True' +
      ';User ID=sa;Initial Catalog=sipom;Data Source=.\sqlexpress'
    LoginPrompt = False
    Provider = 'SQLOLEDB.1'
    Left = 352
    Top = 80
  end
  object JvErrorIndicator1: TJvErrorIndicator
    ImageIndex = 0
    Left = 368
    Top = 240
  end
  object JvValidators1: TJvValidators
    ErrorIndicator = JvErrorIndicator1
    Left = 328
    Top = 240
    object JvRequiredFieldValidator1: TJvRequiredFieldValidator
      ControlToValidate = lbEdtServidor
      PropertyToValidate = 'Text'
      ErrorMessage = 'Informe o Nome do Servidor'
    end
    object JvRequiredFieldValidator2: TJvRequiredFieldValidator
      ControlToValidate = lbEdtBanco
      PropertyToValidate = 'Text'
      ErrorMessage = 'Informe o Nome do Banco de Dados'
    end
    object JvRequiredFieldValidator3: TJvRequiredFieldValidator
      ControlToValidate = edtNomeBackup
      PropertyToValidate = 'Text'
      ErrorMessage = 'Informe o Nome do Arquivo de Backup'
    end
    object JvCustomValidator1: TJvCustomValidator
      ControlToValidate = lbEdtUsuario
      PropertyToValidate = 'Text'
      ErrorMessage = 'Informe o Nome do Usu'#225'rio do Banco de Dados'
      OnValidate = JvCustomValidator1Validate
    end
    object JvCustomValidator2: TJvCustomValidator
      ControlToValidate = lbEdtSenha
      PropertyToValidate = 'Text'
      ErrorMessage = 'Informe a Senha do Banco de Dados'
      OnValidate = JvCustomValidator2Validate
    end
  end
end
