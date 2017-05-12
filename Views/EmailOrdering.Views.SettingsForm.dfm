object SettingsForm: TSettingsForm
  Left = 0
  Top = 0
  Caption = 'Settings'
  ClientHeight = 396
  ClientWidth = 621
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  DesignSize = (
    621
    396)
  PixelsPerInch = 96
  TextHeight = 13
  object PageControlSettings: TPageControl
    Left = 8
    Top = 8
    Width = 605
    Height = 380
    ActivePage = Member
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 0
    object Member: TTabSheet
      Caption = 'Member'
      ImageIndex = 2
      DesignSize = (
        597
        352)
      object ValueListEditorSettingsMember: TValueListEditor
        Left = 3
        Top = 3
        Width = 591
        Height = 346
        Anchors = [akLeft, akTop, akRight, akBottom]
        TabOrder = 0
        ColWidths = (
          150
          435)
      end
    end
    object Email: TTabSheet
      Caption = 'Email'
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      DesignSize = (
        597
        352)
      object ValueListEditorSettingsEmail: TValueListEditor
        Left = 3
        Top = 3
        Width = 591
        Height = 262
        Anchors = [akLeft, akTop, akRight, akBottom]
        TabOrder = 0
      end
      object Button1: TButton
        Left = 480
        Top = 296
        Width = 99
        Height = 25
        Caption = 'Change Password'
        TabOrder = 1
        OnClick = Button1Click
      end
    end
    object API: TTabSheet
      Caption = 'API'
      ImageIndex = 1
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      DesignSize = (
        597
        352)
      object ValueListEditorSettingsApi: TValueListEditor
        Left = 3
        Top = 3
        Width = 591
        Height = 346
        Anchors = [akLeft, akTop, akRight, akBottom]
        TabOrder = 0
      end
    end
    object TabSheet1: TTabSheet
      Caption = 'Application'
      ImageIndex = 3
      DesignSize = (
        597
        352)
      object ValueListEditorApplication: TValueListEditor
        Left = 3
        Top = 3
        Width = 591
        Height = 346
        Anchors = [akLeft, akTop, akRight, akBottom]
        TabOrder = 0
        ColWidths = (
          150
          435)
      end
    end
  end
end
