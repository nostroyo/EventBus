unit UChannel;

interface
type

  TChannel = class
  strict private
    FName: string;
    FDescription: string;
  public
    constructor Create(const AName: string);
    property Name: string read FName write FName;
    property Description: string read FDescription write FDescription;
  end;

  TChannelBroadCast = class(TChannel)
  const
    BROADCAST_NAME = 'BROADCAST';
  end;

implementation

constructor TChannel.Create(const AName: string);
begin
  FName := AName;
end;

end.
