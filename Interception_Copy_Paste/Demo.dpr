program Demo;

uses
  Forms,
  UMain in 'UMain.pas' {frm_Main},
  UOptions in 'UOptions.pas' {frm_Options};

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'Controler Copier/Coller sur TEdit';
  Application.CreateForm(Tfrm_Main, frm_Main);
  Application.CreateForm(Tfrm_Options, frm_Options);
  Application.Run;
end.
