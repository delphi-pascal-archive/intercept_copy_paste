unit UMain;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, CustomCtrls;

type
  Tfrm_Main = class(TForm)
    GroupBox1: TGroupBox;
    Edit_Num: TEdit;
    GroupBox2: TGroupBox;
    Btn_Options1: TButton;
    Label1: TLabel;
    Edit_AlphaMin: TEdit;
    Edit_AlphaMaj: TEdit;
    Btn_Options2: TButton;
    Label2: TLabel;
    GroupBox3: TGroupBox;
    Edit_All: TEdit;
    Label4: TLabel;
    Btn_Options4: TButton;
    Btn_Options3: TButton;
    Label3: TLabel;
    Edit_Standard: TEdit;
    Label5: TLabel;
    GroupBox4: TGroupBox;
    Memo1: TMemo;
    cb_MemoSafeMode: TCheckBox;
    procedure cb_MemoSafeModeClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Edit_NumKeyPress(Sender: TObject; var Key: Char);
    procedure Btn_Options1Click(Sender: TObject);
  private
    { Déclarations privées }
    procedure Edit_NumOnPaste(Sender: TObject;Var S :String; var AllowPaste:Boolean);
    procedure Edit_AlphaMajOnPaste(Sender: TObject;Var S :String; var AllowPaste:Boolean);
    procedure Edit_AlphaMinOnPaste(Sender: TObject;Var S :String; var AllowPaste:Boolean);
  public
    { Déclarations publiques }
  end;

var
  frm_Main: Tfrm_Main;

implementation

uses UOptions;

{$R *.DFM}

procedure Tfrm_Main.FormCreate(Sender: TObject);
begin
  Edit_Num.OnPaste      := Edit_NumOnPaste;
  Edit_AlphaMaj.OnPaste := Edit_AlphaMajOnPaste;
  Edit_AlphaMin.OnPaste := Edit_AlphaMinOnPaste;
  Application.HintHidePause := 5000;
end;        

procedure Tfrm_Main.Edit_NumOnPaste(Sender: TObject;Var S: String; var AllowPaste: Boolean);
Var I : Integer; TmpStr : String;
begin
  {Si les options l'autorise on modifie le contenu du ClipBoard}
  If eoAllowEditClpBrd in (Sender as TEdit).EditOptions Then
  Begin
    TmpStr := EmptyStr;
    For I := 1 To Length(S) Do If S[I] in ['0'..'9'] Then TmpStr := TmpStr + S[I];
    S := TmpStr;
    AllowPaste := S <> EmptyStr;
  End
  Else
  {Sinon on autorise le collage que si le contenu du ClipBoard et de type numérique}
  AllowPaste := StrToIntDef(S, -1) <> -1;
end;

procedure Tfrm_Main.Edit_AlphaMajOnPaste(Sender: TObject;Var S: String;
  var AllowPaste: Boolean);
Var I : Integer; TmpStr : String;
begin
  {Si les options l'autorise on modifie le contenu du ClipBoard}
  If eoAllowEditClpBrd in (Sender as TEdit).EditOptions Then
  //S := AnsiUpperCase(S)
  Begin
    TmpStr := EmptyStr;
    For I := 1 To Length(S) Do If S[I] in [#32, 'A'..'z', #192..#252] Then TmpStr := TmpStr + S[I];
    S := AnsiUpperCase(TmpStr);
    AllowPaste := S <> EmptyStr;
  End
  Else {Sinon on teste chaque caractère}
  For I := 1 To Length(S) Do
    If Not (S[I] in [#32, 'A'..'Z']) Then Begin
    {Si on est pas dans l'interval on interdit le collage}
      AllowPaste := False;
      Exit;
    End;
end;

procedure Tfrm_Main.Edit_AlphaMinOnPaste(Sender: TObject;Var S: String; var AllowPaste: Boolean);
Var I : Integer; TmpStr : String;
begin
  {Si les options l'autorise on modifie le contenu du ClipBoard}
  If eoAllowEditClpBrd in (Sender as TEdit).EditOptions Then
  //S := AnsiLowerCase(S)
  Begin
    TmpStr := EmptyStr;
    For I := 1 To Length(S) Do If S[I] in [#32, 'A'..'z', #192..#252] Then TmpStr := TmpStr + S[I];
    S := AnsiLowerCase(TmpStr);
    AllowPaste := S <> EmptyStr;
  End
  Else {Sinon on teste chaque caractère}
  For I := 1 To Length(S) Do
    If Not (S[I] in [#32, 'a'..'z']) Then Begin
    {Si on est pas dans l'interval on interdit le collage}
      AllowPaste := False;
      Exit;
    End;
end;

procedure Tfrm_Main.Edit_NumKeyPress(Sender: TObject; var Key: Char);
begin
 case (Sender as TEdit).Tag of
   1 : If not (Key in [#8, #22, '0'..'9']) Then Key := #0;
   2 : If not (Key in [#8, #22, #32,  'A'..'Z', #192..#221]) Then Key := #0;
   3 : If not (Key in [#8, #22, #32,  'a'..'z', #224..#252]) Then Key := #0;
 end;  
end;

{Procedure pour la gestion des 4 boutons à droite des TEdits}
procedure Tfrm_Main.Btn_Options1Click(Sender: TObject);
begin
 case (Sender as TButton).Tag of
   1 : frm_Options.Execute(Edit_Num);
   2 : frm_Options.Execute(Edit_AlphaMaj);
   3 : frm_Options.Execute(Edit_AlphaMin);
   4 : frm_Options.Execute(Edit_All);
 end;
end;

{Pour les nostalgiques de l'ancienne méthode :) }
procedure Tfrm_Main.cb_MemoSafeModeClick(Sender: TObject);
begin
  Memo1.SafeMode := cb_MemoSafeMode.Checked;
end;

end.
 