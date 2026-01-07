object f_con: Tf_con
  Left = 0
  Top = 0
  Caption = 'filecontrol'
  ClientHeight = 441
  ClientWidth = 464
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  TextHeight = 15
  object btnSelectAndCleanup: TButton
    Left = 0
    Top = 391
    Width = 464
    Height = 25
    Align = alBottom
    Caption = 'RUN'
    TabOrder = 0
    OnClick = btnSelectAndCleanupClick
    ExplicitTop = 385
  end
  object MemoLog: TMemo
    Left = 0
    Top = 0
    Width = 464
    Height = 391
    Align = alClient
    ScrollBars = ssVertical
    TabOrder = 1
    ExplicitWidth = 624
    ExplicitHeight = 337
  end
  object btn_copy: TButton
    Left = 0
    Top = 416
    Width = 464
    Height = 25
    Align = alBottom
    Caption = 'LOG_COPY'
    TabOrder = 2
    OnClick = btn_copyClick
    ExplicitLeft = 224
    ExplicitTop = 368
    ExplicitWidth = 75
  end
  object FileOpenDialog1: TFileOpenDialog
    FavoriteLinks = <>
    FileTypes = <>
    Options = [fdoPickFolders]
    Left = 104
    Top = 256
  end
end
