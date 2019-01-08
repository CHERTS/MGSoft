object MainForm: TMainForm
  Left = 592
  Top = 317
  Width = 432
  Height = 312
  Caption = 'Yandex TTS Demo'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  DesignSize = (
    416
    274)
  PixelsPerInch = 96
  TextHeight = 13
  object ButtonSay: TButton
    Left = 271
    Top = 35
    Width = 137
    Height = 25
    Caption = #1055#1088#1086#1080#1079#1085#1077#1089#1090#1080' '#1090#1077#1082#1089#1090
    TabOrder = 2
    OnClick = ButtonSayClick
  end
  object EditText: TTntEdit
    Left = 8
    Top = 37
    Width = 257
    Height = 21
    TabOrder = 1
    Text = #1055#1088#1086#1074#1077#1088#1082#1072' '#1089#1080#1085#1090#1077#1079#1072' '#1088#1077#1095#1080
  end
  object MemoLog: TMemo
    Left = 8
    Top = 66
    Width = 400
    Height = 200
    Anchors = [akLeft, akTop, akRight, akBottom]
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 3
  end
  object CBVoices: TTntComboBox
    Left = 8
    Top = 8
    Width = 257
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    TabOrder = 0
    OnChange = CBVoicesChange
  end
  object MGYandexTTS1: TMGYandexTTS
    OutFileName = 'Out.mp3'
    TTSLangResType = ttsLangResInternal
    TTSLangCode = 'en_GB'
    TTSString = 'Checking speech synthesis on English language.'
    ProxyAddress = '192.168.0.1'
    ProxyPort = '3128'
    OnEvent = MGYandexTTS1Event
    Left = 320
    Top = 80
  end
end
