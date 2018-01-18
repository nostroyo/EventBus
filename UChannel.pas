unit UChannel;

interface

  TChanel = class
  strict private
    FName: string;
  public
    constructor Create(const AName: string);
  end;

  TChannelBroadCast = class(TChanel)

  end;

implementation

constructor TChanel.Create(const AName: string);
begin
  FName := AName;
end;

end.
