unit UBus;

interface
uses
  Threading, SyncObjs, generics.collections,
  UEvent;
type

IReceiver = interface
  ['{0BBA7853-1FB2-45E9-92AE-BE38091FE8EF}']
  procedure ReceiveMsg(AMsg: TEventMsg);
end;

TEventBus = class

strict private
  FMailBoxCriticalSec: TCriticalSection;
  FMailBox: TQueue<TEventMsg>;
  FTerminated: Boolean;
  FFlagIncomingMessage: TEvent;
public
  constructor Create;
  destructor Destroy; override;

  procedure DispatchEvent;
end;

implementation

constructor TEventBus.Create;
begin
  FMailBoxCriticalSec := TCriticalSection.Create;
  FMailBox := TQueue<TEventMsg>.Create;
  FFlagIncomingMessage := TEvent.Create(nil, False, False, 'Incomming Msg');
end;

destructor TEventBus.Destroy;
begin
  inherited;
  FFlagIncomingMessage.Free;
  FMailBox.Free;
  FMailBoxCriticalSec.Free;
end;

procedure TEventBus.DispatchEvent;
var
  LMsg: TEventMsg;
begin
  while not FTerminated do
  begin
    FMailBoxCriticalSec.Enter;
    try
      LMsg := FMailBox.Dequeue;

    finally
      FMailBoxCriticalSec.Leave;
    end;

  end;
end;

end.
