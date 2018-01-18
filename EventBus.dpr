program EventBus;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  UBus in 'UBus.pas',
  UEvent in 'UEvent.pas',
  UChannel in 'UChannel.pas';

begin
  try
    { TODO -oUser -cConsole Main : Insérer du code ici }
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
