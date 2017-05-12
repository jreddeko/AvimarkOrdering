object ErrorDForm: TErrorDForm
  Left = 0
  Top = 0
  Caption = 'Error Form'
  ClientHeight = 299
  ClientWidth = 635
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
  object Panel1: TPanel
    Left = 8
    Top = 8
    Width = 619
    Height = 283
    TabOrder = 0
    DesignSize = (
      619
      283)
    object RichEdit1: TRichEdit
      Left = 24
      Top = 16
      Width = 577
      Height = 33
      TabStop = False
      BorderStyle = bsNone
      Color = clBtnFace
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      ReadOnly = True
      TabOrder = 0
      Zoom = 100
    end
    object Button1: TButton
      Left = 526
      Top = 240
      Width = 75
      Height = 25
      Caption = 'Ok'
      TabOrder = 1
      OnClick = Button1Click
    end
    object StringGrid1: TStringGrid
      Left = 8
      Top = 72
      Width = 603
      Height = 153
      Anchors = [akLeft, akTop, akRight, akBottom]
      TabOrder = 2
    end
  end
end
