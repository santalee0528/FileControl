program p_filecontrol;

uses
  Vcl.Forms,
  u_con in 'u_con.pas' {f_con};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(Tf_con, f_con);
  Application.Run;
end.
