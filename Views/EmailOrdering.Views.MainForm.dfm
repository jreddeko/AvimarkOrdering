object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 'Email Ordering'
  ClientHeight = 97
  ClientWidth = 256
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object TrayIcon1: TTrayIcon
    PopupMenu = PopupMenu1
    OnBalloonClick = TrayIcon1BalloonClick
    OnDblClick = TrayIcon1DblClick
    Left = 96
    Top = 24
  end
  object ApplicationEvents1: TApplicationEvents
    Left = 184
    Top = 24
  end
  object PopupMenu1: TPopupMenu
    Left = 32
    Top = 24
    object e1: TMenuItem
      Caption = 'Open'
      OnClick = e1Click
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object Exit2: TMenuItem
      Caption = 'Exit'
      OnClick = Exit2Click
    end
  end
end
