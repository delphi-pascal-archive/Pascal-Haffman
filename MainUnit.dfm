object Form1: TForm1
  Left = 203
  Top = 180
  Width = 448
  Height = 353
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object StatusBar1: TStatusBar
    Left = 0
    Top = 281
    Width = 434
    Height = 19
    Panels = <
      item
        Width = 250
      end
      item
        Width = 50
      end>
  end
  object BitBtn1: TBitBtn
    Left = 8
    Top = 16
    Width = 75
    Height = 25
    Hint = #1054#1090#1082#1088#1099#1090#1100' '#1092#1072#1081#1083' '#1076#1083#1103' '#1089#1086#1089#1090#1072#1074#1083#1077#1085#1080#1103' '#1090#1072#1073#1083#1080#1094#1099' '#1082#1086#1076#1086#1074
    Caption = #1054#1090#1082#1088#1099#1090#1100
    TabOrder = 1
    OnClick = BitBtn1Click
  end
  object Button2: TButton
    Left = 0
    Top = 120
    Width = 105
    Height = 25
    Caption = #1056#1072#1079#1072#1088#1093#1080#1074#1080#1088#1086#1074#1072#1090#1100
    TabOrder = 2
    OnClick = Button2Click
  end
  object Button1: TButton
    Left = 8
    Top = 48
    Width = 75
    Height = 25
    Hint = #1057#1086#1093#1088#1072#1085#1080#1090#1100' '#1082#1086#1076#1080#1088#1086#1074#1072#1085#1085#1099#1081' '#1092#1072#1081#1083
    Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100
    TabOrder = 3
    OnClick = Button1Click
  end
  object ProgressBar1: TProgressBar
    Left = 0
    Top = 269
    Width = 434
    Height = 12
    Align = alBottom
    TabOrder = 4
    Visible = False
  end
  object StringGrid1: TStringGrid
    Left = 105
    Top = 0
    Width = 329
    Height = 269
    Align = alRight
    DefaultColWidth = 100
    FixedCols = 0
    RowCount = 2
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier New'
    Font.Style = []
    ParentFont = False
    ScrollBars = ssVertical
    TabOrder = 5
    ColWidths = (
      37
      41
      60
      53
      109)
  end
  object OD: TOpenDialog
    FilterIndex = 0
    Options = [ofHideReadOnly, ofPathMustExist, ofFileMustExist, ofEnableSizing]
    Left = 8
    Top = 272
  end
  object SD: TSaveDialog
    Options = [ofOverwritePrompt, ofHideReadOnly, ofEnableSizing]
    Left = 40
    Top = 272
  end
end
