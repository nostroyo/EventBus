unit UBus;

interface
uses
  Threading, SyncObjs, generics.collections, // RTL
  LoggerPro, LoggerPro.FileAppender, // Logger
  UEvent, UChannel; // Business

type

  IReceiver = interface
    ['{0BBA7853-1FB2-45E9-92AE-BE38091FE8EF}']
    procedure ReceiveMsg(AMsg: IEventMsg);
  end;

  TEventBus = class
  strict private
    FMailBoxCriticalSec: TCriticalSection;
    FMailBox: TQueue<IEventMsg>;
    // Get all receiver ordered by channel
    FReceivers: TDictionary<TChannel, TList<IReceiver>>;
    FChannels: TObjectList<TChannel>;
    FTerminated: Boolean;
    FFlagIncomingMessage: TEvent;
    FDispatchTask: ITask;

    procedure DispatchEvent;
  public
    constructor Create;
    destructor Destroy; override;

    procedure ConnectTo(const AMsgReceiver: IReceiver; AChannelsToSubscribe: TObjectList<TChannel>);
    procedure CreateNewChannel(const AName: string);
    // todo : encapsulate
    function GetChannels: TObjectList<TChannel>;
    procedure SendMessage(AMsg: IEventMsg);
    procedure StartBus;
    procedure StopBus;
  end;

var
  Log: ILogWriter;

implementation
uses
  Classes, {Sysutils};

procedure TEventBus.ConnectTo(const AMsgReceiver: IReceiver; AChannelsToSubscribe: TObjectList<TChannel>);
var
  LChannel: TChannel;
  LReceiverLst: TList<IReceiver>;
begin
  FReceivers.TryGetValue(FChannels[0], LReceiverLst);
  LReceiverLst.Add(AMsgReceiver);
  if Assigned(AChannelsToSubscribe) then
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
end;

constructor TEventBus.Create;
begin
  FMailBoxCriticalSec := TCriticalSection.Create;
  FMailBox := TQueue<IEventMsg>.Create;
  FFlagIncomingMessage := TEvent.Create(nil, False, False, 'Incomming Msg');
  FReceivers := TDictionary<TChannel, TList<IReceiver>>.Create;
  FChannels := TObjectList<TChannel>.Create;
  FChannels.Add(TChannelBroadCast.Create('WARNING Broadcast'));
  // FChannels[0] ALWAYS BroadcastChannel
  FReceivers.Add(FChannels[0], TList<IReceiver>.Create);
  Log := BuildLogWriter([TLoggerProFileAppender.Create]);
end;

procedure TEventBus.CreateNewChannel(const AName: string);
begin
  FChannels.Add(TChannel.Create(AName));
end;

destructor TEventBus.Destroy;
var
  LReciverList: TList<IReceiver>;
begin
  StopBus;
  if Assigned(FDispatchTask) then
    TTask.WaitForAll([FDispatchTask]);
  FChannels.Free;
  for LReciverList in FReceivers.Values do
  begin
    LReciverList.Free;
  end;
  FReceivers.Free;
  FFlagIncomingMessage.Free;
  FMailBox.Free;
  FMailBoxCriticalSec.Free;
  inherited;
end;

procedure TEventBus.DispatchEvent;
var
  LChannel: UChannel.TChannel;
  LMsg: IEventMsg;
  I: Integer;
  LReceiverLst: TList<IReceiver>;
  LReceiverPair: TPair<TChannel, TList<IReceiver>>;

  procedure SendMsg;
  var
    LReceiver: IReceiver;
  begin
    for LReceiver in LReceiverLst do
    begin
      LReceiver.ReceiveMsg(LMsg);
    end;
  end;

begin
  while not FTerminated do
  begin
    FFlagIncomingMessage.WaitFor;
    Log.Debug('Unlock Event', 'Dispatch');
    while true do
    begin
      FMailBoxCriticalSec.Enter;
      try
        //Sleep(1000); Test Slow BUS
        if (FMailBox.Count = 0) then
        begin
          Break;
        end;
        Log.Debug('Enter critical section', 'Dispatch');
        LMsg := FMailBox.Dequeue;
        Log.DebugFmt('Message dequeue : %s', [LMsg.GetDescription], 'Dispatch');
      finally
        Log.Debug('leave critical section', 'Dispatch');
        FMailBoxCriticalSec.Leave;
      end;
      for I := 0 to LMsg.GetChannelCount - 1 do
      begin
        LChannel := LMsg.GetChannelByIndex(I);
        Log.DebugFmt('Message %s on channel %s',
          [LMsg.GetDescription, LChannel.Name], 'Dispatch');
        if not (LChannel is TChannelBroadCast) then
        begin
          if FReceivers.TryGetValue(LChannel, LReceiverLst) then
          begin
            Log.DebugFmt('%d receiver on msg %s',
              [LReceiverLst.Count, LMsg.GetDescription], 'Dispatch');
            SendMsg;
          end;
        end
        else
        begin
          for LReceiverPair in FReceivers do
          begin
            LReceiverLst := LReceiverPair.Value;
            SendMsg;
          end;
        end;
      end;
    end;
  end;
end;

function TEventBus.GetChannels: TObjectList<TChannel>;
begin
  Result := FChannels;
end;

procedure TEventBus.SendMessage(AMsg: IEventMsg);
begin
  FMailBoxCriticalSec.Enter;
  try
    Log.Debug('Enter critical section', 'SendMsg');
    FMailBox.Enqueue(AMsg);
    Log.DebugFmt('Message send : %s', [AMsg.GetDescription], 'SendMsg');
    FFlagIncomingMessage.SetEvent;
  finally
    Log.Debug('Leave critical section', 'SendMsg');
    FMailBoxCriticalSec.Leave;
  end;

end;

procedure TEventBus.StartBus;
begin
  FDispatchTask := TTask.Create(DispatchEvent).Start;
end;

procedure TEventBus.StopBus;
begin
  FTerminated := True;
  FFlagIncomingMessage.SetEvent;  //  unlock the event to close the threaded dispatcher func
end;

end.
