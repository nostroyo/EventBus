unit UBus;

interface
uses
  Threading, SyncObjs, generics.collections,
  UEvent, UChannel;
type

  IReceiver = interface
    ['{0BBA7853-1FB2-45E9-92AE-BE38091FE8EF}']
    procedure ReceiveMsg(AMsg: TEventMsg);

  end;

  TEventBus = class

  strict private
    FMailBoxCriticalSec: TCriticalSection;
    FMailBox: TQueue<TEventMsg>;
    // Get all receiver ordered by channel
    FReceivers: TDictionary<TChannel, TList<IReceiver>>;
    FChannels: TObjectList<TChannel>;
    FTerminated: Boolean;
    FFlagIncomingMessage: TEvent;

    procedure DispatchEvent;
  public
    constructor Create;
    destructor Destroy; override;

    procedure ConnectTo(const AMsgReceiver: IReceiver; AChannelsToSubscribe: TObjectList<TChannel>);
//    procedure CreateNewChannel

end;

implementation

procedure TEventBus.ConnectTo(const AMsgReceiver: IReceiver; AChannelsToSubscribe: TObjectList<TChannel>);
var
  I: Integer;

  LChannel: TChannel;
  LReceiverLst: TList<IReceiver>;
begin
  for LChannel in AChannelsToSubscribe do
  begin
    if FReceivers.TryGetValue(LChannel, LReceiverLst) then
      LReceiverLst.Add(AMsgReceiver)
    else
    begin
      LReceiverLst := TList<IReceiver>.Create;
      LReceiverLst.Add(AMsgReceiver);
      FReceivers.Add(LChannel, LReceiverLst);
    end;
  end;
end;

constructor TEventBus.Create;
begin
  FMailBoxCriticalSec := TCriticalSection.Create;
  FMailBox := TQueue<TEventMsg>.Create;
  FFlagIncomingMessage := TEvent.Create(nil, False, False, 'Incomming Msg');
  FReceivers := TDictionary<TChannel, TList<IReceiver>>.Create;
  FChannels := TObjectList<TChannel>.Create;
end;

destructor TEventBus.Destroy;
begin
  FChannels.Free;
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
  LReceiverLst: TList<IReceiver>;
begin
  while not FTerminated do
  begin
    FMailBoxCriticalSec.Enter;
    try
      LMsg := FMailBox.Dequeue;
    finally
      FMailBoxCriticalSec.Leave;
    end;

    for I := 0 to LMsg.GetChannelCount - 1 do
    begin
      if FReceivers.TryGetValue(LMsg.GetChannelByIndex(I), LReceiverLst) then
      begin

      end;
    end;
  end;
end;

end.
