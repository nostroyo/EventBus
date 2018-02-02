unit UEvent;

interface
uses
  generics.collections,
  UChannel;
type

  IEventMsg = Interface
  ['{662FBC7A-CA8A-41CC-A165-30E32D930843}']

    function GetChannelCount: Integer;
    procedure AddChannel(AChannel: TChannel);
    function GetChannelByIndex(AIndex: Integer): TChannel;
    function GetDescription: string;
  end;

  TEventMsg = class(TInterfacedObject, IEventMsg)
  strict private
    FEventDescr: string;
    FChannels: TObjectList<TChannel>;
  private
    function GetDescription: string;
  public
    constructor Create(AChannel: TChannel);
    destructor Destroy; override;

    function GetChannelCount: Integer;
    procedure AddChannel(AChannel: TChannel);
    function GetChannelByIndex(AIndex: Integer): TChannel;

    property Descrition: string read GetDescription write FEventDescr;

  end;

implementation

{ TEventMsg }

procedure TEventMsg.AddChannel(AChannel: TChannel);
begin
  FChannels.Add(AChannel);
end;

constructor TEventMsg.Create(AChannel: TChannel);
begin
  FChannels := TObjectList<TChannel>.Create(False);
  FChannels.Add(AChannel);
end;

destructor TEventMsg.Destroy;
begin
  FChannels.Free;
  inherited;
end;

function TEventMsg.GetChannelByIndex(AIndex: Integer): TChannel;
begin
  Result := nil;
  if (AIndex >= 0) and (AIndex < GetChannelCount) then
    Result := FChannels[AIndex];
end;

function TEventMsg.GetChannelCount: Integer;
begin
  Result := FChannels.Count;
end;

function TEventMsg.GetDescription: string;
begin
  Result := FEventDescr;
end;

end.
