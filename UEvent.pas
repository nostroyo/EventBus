unit UEvent;

interface
uses
  generics.collections,
  UChannel;
type

TEventMsg = class(TInterfacedObject)
  strict private
    FEventDescr: string;
    FChannel: TObjectList<TChannel>;
  public
    constructor Create(AChannel: TChannel);

    property Descrition: string read FEventDescr write FEventDescr;
end;

implementation

end.
