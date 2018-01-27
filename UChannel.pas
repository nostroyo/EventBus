unit UChannel;

interface
type

  TChannel = class
  strict private
    FName: string;
  public
    constructor Create(const AName: string);
    property Name: string read FName write FName;
  end;

  TChannelBroadCast = class(TChannel)

  end;

implementation

constructor TChannel.Create(const AName: string);
begin
  FName := AName;
end;

end.
