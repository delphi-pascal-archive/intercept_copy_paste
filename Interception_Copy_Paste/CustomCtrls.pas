{
  Unit Name : CustomCtrls;
  
  Autor     : Cirec, 14/11/2006

  veillez toujours � ce que cette unit� soit d�clar�
  apr�s StdCtrls

  15/11/2006  Modifications :
  Extention des interceptions de messages sur les propositions de F0xi
  Voir TEditOption et descriptif plus bas
  et l'ajout d'un �v�nnement OnPaste qui permet de r�cup�rer le contenu du ClipBoard
  et la possibilit� de modifier ce dernier sur une id�e de N_M_B

  Pour l'acc�s au ClipBoard j'utilise une m�thode directe puisque l'unit� ClipBrd.pas
  n'existe pas sous D4
}
unit CustomCtrls;

interface
uses
  Windows, Messages, SysUtils, Classes, StdCtrls{$IFNDEF VER120}, ClipBrd {$ENDIF};

Type
{$IFDEF VER120} // pour puvoir l'utiliser sous D4
  TWMContextMenu = packed record
    Msg: Cardinal;
    hWnd: HWND;
    case Integer of
      0: (
        XPos: Smallint;
        YPos: Smallint);
      1: (
        Pos: TSmallPoint;
        Result: Longint);
  end;
{$ENDIF}


  TEditOption  = (eoAllowEdit, eoAllowContextMenu, eoAllowCopy, eoAllowPaste,
                  eoAllowCut, eoAllowUndo, eoAllowEditClpBrd);
{
eoAllowEdit : permet d'activer ou non la saisie au clavier
eoAllowContextMenu : permet d'activer ou non le menu contextuel par defaut
eoAllowCopy : permet d'activer ou non le raccourcis CTRL+C (copier)
eoAllowPaste: permet d'activer ou non le raccourcis CTRL+V (coller)
eoAllowCut : permet d'activer ou non le raccourcis CTRL+X (couper)
eoAllowUndo: permet d'activer ou non le raccourcis CTRL+Z (annuler)
eoAllowEditClpBrd: permet "d'�diter" le contenu du ClipBoard
}
  TEditOptions = set of TEditOption;

  TNotifyPaste = procedure(Sender: TObject;Var S :String;
                           var AllowPaste:Boolean) of object ;

    TEdit = Class(StdCtrls.TEdit)
    private
      { D�clarations priv�es }
    FEditOptions : TEditOptions;
    FOnPaste     : TNotifyPaste;
    Procedure SetEditOptions(Value: TEditOptions);
    procedure WMChar(var Message: TWMChar); message WM_CHAR;
    procedure WMContextMenu(var Message: TWMContextMenu); message WM_CONTEXTMENU;
    procedure WMPaste(var Message); message WM_PASTE;
    procedure WMCopy(var Message); message WM_COPY;
    procedure WMCut(var Message); message WM_CUT;
    procedure WMUndo(var Message); message WM_UNDO;
    public
      { D�clarations publiques }
    constructor Create(AOwner : TComponent); override;
    Property EditOptions : TEditOptions Read FEditOptions  Write SetEditOptions
             default [eoAllowEdit, eoAllowContextMenu, eoAllowCopy,
                      eoAllowPaste, eoAllowCut, eoAllowUndo];
    Property OnPaste : TNotifyPaste Read FOnPaste Write FOnPaste;
    End;

    TMemo = Class(StdCtrls.TMemo)
    private
      { D�clarations priv�es }
      FSafeMode : Boolean;
      procedure WMPaste(var Message); message WM_PASTE;
    public
      { D�clarations publiques }
      Property SafeMode : Boolean Read FSafeMode Write FSafeMode;
    End;
implementation


{permet de r�injecter du texte dans le ClipBoard}
procedure SetBuffer(Format: Word; var Buffer; Size: Integer);
var
  Data: THandle;
  DataPtr: Pointer;
begin
  OpenClipBoard(0);
  try
    Data := GlobalAlloc(GMEM_MOVEABLE+GMEM_DDESHARE, Size);
    try
      DataPtr := GlobalLock(Data);
      try
        Move(Buffer, DataPtr^, Size);
        SetClipboardData(Format, Data);
      finally
        GlobalUnlock(Data);
      end;
    except
      GlobalFree(Data);
      raise;
    end;
  finally
    CloseClipBoard;
  end;
end;

{ TEdit }

constructor TEdit.Create(AOwner: TComponent);
begin
  inherited create(AOwner);
  FOnPaste := Nil;
  FEditOptions := [eoAllowEdit, eoAllowContextMenu, eoAllowCopy, eoAllowPaste,
                   eoAllowCut, eoAllowUndo];
end;

{Cette procedure corrige le bug de la touche Suppr
 Probl�me soulev� par N_M_B}
procedure TEdit.SetEditOptions(Value: TEditOptions);
begin
  If Value <> FEditOptions Then Begin
    FEditOptions := Value;
    ReadOnly := Not (eoAllowEdit in FEditOptions);
  End;
end;

{Interception et traitement du Message WM_Char}
procedure TEdit.WMChar(var Message: TWMChar);
begin
  if eoAllowEdit in FEditOptions Then
     Inherited;
end;

{Interception et traitement du Message WM_ContextMenu}
procedure TEdit.WMContextMenu(var Message: TWMContextMenu);
begin
  if eoAllowContextMenu in FEditOptions Then
     Inherited;
end;

{Interception et traitement du Message WM_Copy}
procedure TEdit.WMCopy(var Message);
begin
  if eoAllowCopy in FEditOptions Then
     Inherited;
end;

{Interception et traitement du Message WM_Cut}
procedure TEdit.WMCut(var Message);
begin
  if eoAllowCut in FEditOptions Then
     Inherited;
end;

{Interception et traitement du Message WM_Paste}
{$WARNINGS OFF}
{$IFDEF VER120} // pour pouvoir l'utiliser sous D4
procedure TEdit.WMPaste(var Message);
var
  Data: THandle;
  Buffer: PChar;
  AllowPaste, ClipChanged: Boolean;
  ClpBrd, MemClpBrd : String;
begin
  {Si on autorise le collage}
  If eoAllowPaste in FEditOptions Then
  Begin
    AllowPaste  := True;
    ClipChanged := False;
  {Si l'�vennement OnPaste est assign�}
    If Assigned(FOnPaste) Then
    Begin
      Try
        {On alloue suffisement de m�moire}
        GetMem(Buffer, 255);
        {On ouvre le presse-papier}
        OpenClipBoard(0);
        {On r�cup�re le Handle des donn�es}
        Data := GetClipboardData(CF_TEXT);
        If Data = 0 then Exit else
        begin
          {On copie les donn�es 255 caract�res Max}
          StrLCopy(Buffer, GlobalLock(Data), 255);
          GlobalUnlock(Data);
        end;
      Finally
        {On ferme le presse-papier}
        CloseClipBoard;
        {On lib�re la m�moire}
        ClpBrd := String(Buffer);
        FreeMem(Buffer);
      End;
       MemClpBrd := ClpBrd;
      {On d�clanche l'�vennement}
      FOnPaste(Self, ClpBrd, AllowPaste);
      {Si le texte � chang� on modifie le contenu du ClipBoard}
      If (eoAllowEditClpBrd in FEditOptions) And AllowPaste And
        (AnsiCompareStr(ClpBrd, Buffer)<> 0) Then
      Begin
        EmptyClipboard;
        SetBuffer(CF_TEXT, PChar(ClpBrd)^, Length(ClpBrd) + 1);
        ClipChanged := True;
      End;
    End;  // If Assigned
    If AllowPaste Then Inherited;
  End;
  {Si le contenu du ClipBoard a chang� on le restitue}
  If ClipChanged Then
  Begin
    EmptyClipboard;
    SetBuffer(CF_TEXT, PChar(MemClpBrd)^, Length(MemClpBrd) + 1);
  End;
end;
{$ELSE}
{Pour les versions de Delphi apr�s D4}
procedure TEdit.WMPaste(var Message);
var
  AllowPaste, ClipChanged: Boolean;
  ClpBrd, MemClpBrd : String;
begin
  {Si on autorise le collage}
  If eoAllowPaste in FEditOptions Then
  Begin
    AllowPaste  := True;
    ClipChanged := False;
  {Si l'�vennement OnPaste est assign�}
    If Assigned(FOnPaste) Then
    Begin
      ClpBrd := ClipBoard.AsText;
      {On d�clanche l'�vennement}
      FOnPaste(Self, ClpBrd, AllowPaste);
      {Si le texte � chang� on modifie le contenu du ClipBoard}
      If (eoAllowEditClpBrd in FEditOptions) And AllowPaste And
        (AnsiCompareStr(ClpBrd, ClipBoard.AsText)<> 0) Then
      Begin
        MemClpBrd := ClipBoard.AsText;
        ClipBoard.Clear;
        ClipBoard.AsText := ClpBrd;
        ClipChanged := True;
      End;
    End;  // If Assigned
    If AllowPaste Then Inherited;
  End;
  {Si le contenu du ClipBoard a chang� on le restitue}
  If ClipChanged Then
  Begin
    ClipBoard.Clear;
    ClipBoard.AsText := MemClpBrd;
  End;
end;
{$ENDIF}
{$WARNINGS ON}

{Interception et traitement du Message WM_Undo}
procedure TEdit.WMUndo(var Message);
begin
  if eoAllowUndo in FEditOptions Then
     Inherited;
end;


{ TMemo
ici c'est l'anci�nne m�thode si vous cherchez la simplicit� ...
y a pas plus simple :)
}
procedure TMemo.WMPaste(var Message);
begin
{Si on est pas en SafeMode le message sera trait�}
  If Not FSafeMode Then Inherited;
end;

end.
