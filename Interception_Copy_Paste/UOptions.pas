unit UOptions;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, CustomCtrls, ExtCtrls;

type
  Tfrm_Options = class(TForm)
    gb_Options: TGroupBox;
    cb_AllowEdit: TCheckBox;
    cb_AllowPaste: TCheckBox;
    cb_AllowContextMenu: TCheckBox;
    cb_AllowCut: TCheckBox;
    cb_AllowCopy: TCheckBox;
    cb_AllowUndo: TCheckBox;
    BitBtnOk: TBitBtn;
    BitBtnCancel: TBitBtn;
    Bevel1: TBevel;
    cb_AllowEditClpBrd: TCheckBox;
    procedure gb_OptionsMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
  private
    { Déclarations privées }
    Procedure SetOptions(Ed: TEdit);
    Procedure GetOptions(Ed: TEdit);
  public
    { Déclarations publiques }
    Function Execute(Ed: TEdit) : Boolean;
  end;

var
  frm_Options: Tfrm_Options;

implementation

{$R *.DFM}

{ Tfrm_Options }
Const
  StrGroupBox = ' Sélectionner les Options pour %s ';
Var aRect : TRect;
    Pt    : TPoint;

function Tfrm_Options.Execute(Ed: TEdit): Boolean;
begin
  aRect := gb_Options.ClientRect;
  InFlateRect(aRect, -8, -8);
  GetCursorPos(Pt);
  Left := Pt.x + 10; Top := Pt.y + 10;
  GetOptions(Ed);             
  gb_Options.Caption := Format(StrGroupBox, [Ed.Name]);
  //SetCursorPos(Left + 20, Top + 20);
  ShowModal;
  Result := ModalResult = mrOk;
  If Result Then SetOptions(Ed);
  Ed.SetFocus;
end;

procedure Tfrm_Options.GetOptions(Ed: TEdit);
begin
  With Ed do Begin
    cb_AllowEdit.Checked := eoAllowEdit in EditOptions;
    cb_AllowContextMenu.Checked := eoAllowContextMenu in EditOptions;
    cb_AllowCopy.Checked := eoAllowCopy in EditOptions;
    cb_AllowPaste.Checked := eoAllowPaste in EditOptions;
    cb_AllowCut.Checked := eoAllowCut in EditOptions;
    cb_AllowUndo.Checked := eoAllowUndo in EditOptions;
    cb_AllowEditClpBrd.Checked := eoAllowEditClpBrd in EditOptions;
  End;
end;

procedure Tfrm_Options.SetOptions(Ed: TEdit);
begin
  With Ed do Begin
    EditOptions := [];
    If cb_AllowEdit.Checked Then EditOptions := EditOptions + [eoAllowEdit];
    If cb_AllowContextMenu.Checked Then EditOptions := EditOptions + [eoAllowContextMenu];
    If cb_AllowCopy.Checked Then EditOptions := EditOptions + [eoAllowCopy];
    If cb_AllowPaste.Checked Then EditOptions := EditOptions + [eoAllowPaste];
    If cb_AllowCut.Checked Then EditOptions := EditOptions + [eoAllowCut];
    If cb_AllowUndo.Checked Then EditOptions := EditOptions + [eoAllowUndo];
    If cb_AllowEditClpBrd.Checked Then EditOptions := EditOptions + [eoAllowEditClpBrd];
  End;
end;

procedure Tfrm_Options.gb_OptionsMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  Pt := Point(X, Y);
  If Not PtInRect(aRect, Pt) Then //BitBtnCancel.Click;
end;

end.
