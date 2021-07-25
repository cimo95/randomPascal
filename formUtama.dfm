object fu: Tfu
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'KawalCorona.com'
  ClientHeight = 224
  ClientWidth = 225
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object lStatus: TLabel
    Left = 8
    Top = 202
    Width = 60
    Height = 13
    Caption = 'Status : siap'
  end
  object gbSemua: TGroupBox
    Left = 8
    Top = 8
    Width = 209
    Height = 103
    Caption = 'Data Keseluruhan'
    TabOrder = 0
    object lSemuaPositif: TLabel
      Left = 8
      Top = 16
      Width = 48
      Height = 13
      Caption = 'Positif : 0 '
    end
    object lSemuaSembuh: TLabel
      Left = 8
      Top = 35
      Width = 54
      Height = 13
      Caption = 'Sembuh : 0'
    end
    object lSemuaMeninggal: TLabel
      Left = 8
      Top = 54
      Width = 64
      Height = 13
      Caption = 'Meninggal : 0'
    end
    object lSemuaDirawat: TLabel
      Left = 8
      Top = 74
      Width = 53
      Height = 13
      Caption = 'Dirawat : 0'
    end
  end
  object gbProv: TGroupBox
    Left = 8
    Top = 117
    Width = 209
    Height = 81
    Caption = 'Data Provinsi : '
    TabOrder = 2
    object lProvPositif: TLabel
      Left = 8
      Top = 20
      Width = 48
      Height = 13
      Caption = 'Positif : 0 '
    end
    object lProvSembuh: TLabel
      Left = 8
      Top = 39
      Width = 54
      Height = 13
      Caption = 'Sembuh : 0'
    end
    object lProvMeninggal: TLabel
      Left = 8
      Top = 58
      Width = 64
      Height = 13
      Caption = 'Meninggal : 0'
    end
  end
  object cmbProvinsi: TComboBox
    Left = 89
    Top = 113
    Width = 120
    Height = 21
    Style = csDropDownList
    TabOrder = 1
    OnChange = cmbProvinsiChange
  end
end
