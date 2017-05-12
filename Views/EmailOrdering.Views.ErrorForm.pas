unit EmailOrdering.Views.ErrorForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.Grids,
  Vcl.ExtCtrls;

type
  TErrorDForm = class(TForm)
    StringGrid1: TStringGrid;
    Button1: TButton;
    RichEdit1: TRichEdit;
    Panel1: TPanel;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure CreateParams(var Params: TCreateParams); override;
    procedure SetErrors(errors: string);
  end;

var
  ErrorDForm: TErrorDForm;

implementation

{$R *.dfm}

procedure TErrorDForm.Button1Click(Sender: TObject);
begin
  self.Close;
end;

procedure TErrorDForm.CreateParams(var Params: TCreateParams);
begin
  inherited;
  Params.ExStyle := Params.ExStyle or WS_EX_APPWINDOW;
  Params.WndParent := 0;
end;

procedure TErrorDForm.FormCreate(Sender: TObject);
var
  LIcon:TIcon;
begin
  LIcon:= TIcon.Create;
  try
    LIcon.LoadFromFile('symbol.ico');
    StringGrid1.ColCount := 2;
    StringGrid1.RowCount := 1;
    StringGrid1.ColWidths[1]:= 540;
    StringGrid1.Cells[0,0]:= 'Id';
    StringGrid1.Cells[1,0]:= 'Error';
    self.Icon:= LIcon;
    FormStyle:= fsStayOnTop;
    self.Constraints.MinHeight := 400;
    self.Constraints.MinWidth := 600;
  finally
    LIcon.Free;
  end;
end;

procedure TErrorDForm.SetErrors(errors: string);
var
  LStringList: TStringList;
  I: Integer;
begin
  LStringList := TStringList.Create;
  LStringList.Text:= Errors;
  try;
    self.RichEdit1.Text := format('Error sending email to WDDC due to the following errors:',[]);
    for I := 0 to LStringList.Count -1 do
    begin
      StringGrid1.Cells[0, I + 1] := inttostr(I + 1);
      StringGrid1.Cells[1, I + 1] := LStringList[I];
      StringGrid1.RowCount := I + 2;
      StringGrid1.Row := I + 1;
    end;
  finally
    LStringList.Free;
  end;
end;

end.
