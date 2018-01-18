unit UBus;

interface
uses
  Threading, SyncObjs, generics.collections,
  UEvent, UChannel;
type

  IReceiver = interface
    ['{0BBA7853-1FB2-45E9-92AE-BE38091FE8EF}']
    procedure ReceiveMsg(AMsg: TEventMsg);

    function GetSubscribedChannelCount: Integer;
    procedure SubscribedChannel(AChannel: TChannel);
    function GetSubscribedChannelByIndex(AIndex: Integer): TChannel;
  end;

  TEventBus = class

  strict private
    FMailBoxCriticalSec: TCriticalSection;
    FMailBox: TQueue<TEventMsg>;
    FReceivers: TList<IReceiver>;
    FTerminated: Boolean;
    FFlagIncomingMessage: TEvent;

    procedure DispatchEvent;
  public
    constructor Create;
    destructor Destroy; override;
    // TODO impl
    //procedure ConnectTo(const AMsgReceiver: IReceiver);


end;

implementation

constructor TEventBus.Create;
begin
  FMailBoxCriticalSec := TCriticalSection.Create;
  FMailBox := TQueue<TEventMsg>.Create;
  FFlagIncomingMessage := TEvent.Create(nil, False, False, 'Incomming Msg');
  FReceivers := TList<IReceiver>.Create;
end;

destructor TEventBus.Destroy;
begin
  FReceivers.Free;
  FFlagIncomingMessage.Free;
  FMailBox.Free;
  FMailBoxCriticalSec.Free;
  inherited;
end;

procedure TEventBus.DispatchEvent;
var
  LMsg: TEventMsg;
  I: Integer;
begin
  while not FTerminated do
  begin
    FMailBoxCriticalSec.Enter;
    try
      LMsg := FMailBox.Dequeue;
      for I := 0 to LMsg.GetChannelCount - 1 do
      begin
        LMsg.GetChannelByIndex(I)
      end;


    finally
      FMailBoxCriticalSec.Leave;
    end;

  end;
end;

end.
