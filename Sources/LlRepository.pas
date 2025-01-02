unit LlRepository;

interface

uses
  System.SysUtils, System.Variants, System.Classes,
  System.Generics.Collections,
  Winapi.Windows, Winapi.ActiveX,
  Data.DB;

type
  IRepositoryItem = interface
    ['{9FD3B4AA-3B08-4D96-8FC5-F827AA84B393}']
    function getInternalID: String;
    function getType: String;
    function getFolderId: String;
    function getDescriptor: String;
    function getLastModification: TDateTime;
    function getStream: TStream;

    procedure saveToIStream(dest: IStream);
    procedure loadFromIStream(source: IStream);
    procedure UpdateFrom(source: IRepositoryItem);

    property InternalID: String read getInternalID;
    property AType: String read getType;
    property FolderId: String read getFolderId;
    property Descriptor: String read getDescriptor;
    property LastModification: TDateTime read getLastModification;
    property Stream: TStream read getStream;
  end;
  TRepositoryAttributes = set of (raSingleThreadedAttribute, raNoHierarchyAttribute);
  IRepository = interface
    ['{7814C978-3341-46B7-BA18-3610D3510B25}']
    function getAllItems(): TDictionary<String, IRepositoryItem>.TValueCollection;
    function getItem(id: String): IRepositoryItem;
    procedure DeleteItem(id: String);
    function ContainsItem(id: String): Boolean;
    function LockItem(id: String): Boolean;
    procedure UnlockItem(id: String);
    function getAttributes: TRepositoryAttributes;
    procedure setAttributes(value: TRepositoryAttributes);
    procedure CreateOrUpdateItem(item: IRepositoryItem);
    procedure LoadAll;
//    LoadItem(id, destinationStream, _loadItemCancelTokenSource.Token);
    property Attributes: TRepositoryAttributes read getAttributes write setAttributes;
  end;

  TRepositoryItem = class(TInterfacedObject, IRepositoryItem)
  private
    FFolderId: String;
    FInternalId: String;
    FDescriptor: String;
    FType: String;
    FStream: TMemoryStream;
    FLastModification: TDateTime;
  public
    constructor Create(AId, AItemDescriptor, AType: String; ADate: TDateTime); overload;
    constructor Create(AId, AItemDescriptor, AType: String; ADate: TDateTime; AIStream: IStream); overload;
    constructor Create(AId, AItemDescriptor, AType: String; ADate: TDateTime; AStream: TStream); overload;
    destructor Destroy; override;
    function getFolderId: String;
    function getInternalID: String;
    function getDescriptor: String;
    function getType: String;
    function getLastModification: TDateTime;
    function getStream: TStream;
    procedure setStream(value: TStream);

    procedure saveToIStream(dest: IStream);
    procedure loadFromIStream(source: IStream);

    procedure UpdateFrom(source: IRepositoryItem);

    property InternalID: String read getInternalID;
    property AType: String read getType;
    property FolderId: String read getFolderId;
    property Descriptor: String read getDescriptor;
    property LastModification: TDateTime read getLastModification;
    property Stream: TStream read getStream;
  end;

  TBaseRepository = class(TInterfacedObject, IRepository)
  protected
    FItems: TDictionary<String, IRepositoryItem>;
    FAttributes: TRepositoryAttributes;
    procedure AfterCreateOrUpdateItem(item: IRepositoryItem); virtual;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    function getAllItems(): TDictionary<String, IRepositoryItem>.TValueCollection;
    function getItem(id: String): IRepositoryItem;
    procedure DeleteItem(id: String);
    function ContainsItem(id: String): Boolean;
    function LockItem(id: String): Boolean;
    procedure UnlockItem(id: String);
    function getAttributes: TRepositoryAttributes;
    procedure setAttributes(value: TRepositoryAttributes);
    procedure CreateOrUpdateItem(item: IRepositoryItem);
    procedure LoadAll; virtual;
    property Attributes: TRepositoryAttributes read getAttributes write setAttributes;
  end;

  TDBBaseRepository = class(TBaseRepository)
  private
  protected
    FDataSource: TDataSource;
    FFieldNameId: String;
    FFieldNameType: String;
    FFieldNameDescriptor: String;
    FFieldNameLastModification: String;
    FFieldNameStream: String;

    procedure AfterCreateOrUpdateItem(item: IRepositoryItem); override;
    procedure AddItem(ADataSet: TDataSet);
  public
    constructor Create; override;
    procedure LoadAll; override;
    property Datasource: TDataSource read FDataSource write FDataSource;
    property FieldNameId: String read FFieldNameId write FFieldNameId;
    property FieldNameType: String read FFieldNameType write FFieldNameType;
    property FieldNameDescriptor: String read FFieldNameDescriptor write FFieldNameDescriptor;
    property FieldNameLastModification: String read FFieldNameLastModification write FFieldNameLastModification;
    property FieldNameStream: String read FFieldNameStream write FFieldNameStream;
  end;

implementation

{ TRepositoryItem }

constructor TRepositoryItem.Create(AId, AItemDescriptor, AType: String;
  ADate: TDateTime; AIStream: IStream);
begin
  inherited Create;
  FStream := TMemoryStream.Create;
  FInternalId := AId;
  FDescriptor := AItemDescriptor;
  FType := AType;
  FLastModification := ADate;
  loadFromIStream(AIStream);
end;

constructor TRepositoryItem.Create(AId, AItemDescriptor, AType: String;
  ADate: TDateTime; AStream: TStream);
begin
  inherited Create;
  FStream := TMemoryStream.Create;
  FInternalId := AId;
  FDescriptor := AItemDescriptor;
  FType := AType;
  FLastModification := ADate;
  setStream(AStream);
end;

constructor TRepositoryItem.Create(AId, AItemDescriptor, AType: String;
  ADate: TDateTime);
begin
  inherited Create;
  FStream := TMemoryStream.Create;
  FInternalId := AId;
  FDescriptor := AItemDescriptor;
  FType := AType;
  FLastModification := ADate;
end;

destructor TRepositoryItem.Destroy;
begin
  FStream.Free;
  inherited Destroy;
end;

function TRepositoryItem.getDescriptor: String;
begin
  Result := FDescriptor;
end;

function TRepositoryItem.getFolderId: String;
begin
  Result := FFolderId;
end;

function TRepositoryItem.getInternalID: String;
begin
  Result := FInternalId;
end;

function TRepositoryItem.getLastModification: TDateTime;
begin
  Result := FLastModification;
end;

function TRepositoryItem.getStream: TStream;
begin
  Result := FStream;
end;

function TRepositoryItem.getType: String;
begin
  Result := FType;
end;

procedure TRepositoryItem.loadFromIStream(source: IStream);
const
  BufferSize = 4096;
var
  Buffer: array[0..BufferSize - 1] of Byte;
  BytesRead: LongInt;
begin
  FStream.Clear;
  if source <> nil then
  begin
    repeat
      Source.Read(@Buffer, BufferSize, @BytesRead);
      if BytesRead > 0 then
        FStream.Write(Buffer, BytesRead);
    until BytesRead < BufferSize;
  end;
  FStream.Position := 0;
end;

procedure TRepositoryItem.saveToIStream(dest: IStream);
var
  Buffer: array[0..4095] of Byte;
  BytesRead: Integer;
  BytesWritten: LongInt;
begin
  FStream.Position := 0; // Ensure the source stream is at the beginning
  repeat
    BytesRead := FStream.Read(Buffer, SizeOf(Buffer));
    if BytesRead > 0 then
    begin
      dest.Write(@Buffer, BytesRead, @BytesWritten);
      if BytesRead <> BytesWritten then
        raise Exception.Create('Error writing to IStream');
    end;
  until BytesRead = 0;
end;

procedure TRepositoryItem.setStream(value: TStream);
begin
  if value = nil then
  begin
    (FStream as TMemoryStream).Clear;
  end else
  begin
    (FStream as TMemoryStream).LoadFromStream(value);
  end;
end;

procedure TRepositoryItem.UpdateFrom(source: IRepositoryItem);
begin
  if SameText(FInternalId, source.InternalID) then
  begin
    FLastModification := source.LastModification;
    FDescriptor := source.Descriptor;
    FFolderId := source.FolderId;
    FType := source.AType;
    setStream(source.getStream);
  end;
end;

{ TBaseRepository }

procedure TBaseRepository.AfterCreateOrUpdateItem(item: IRepositoryItem);
begin
  // use in derivation
end;

function TBaseRepository.ContainsItem(id: String): Boolean;
begin
  Result := FItems.ContainsKey(id);
end;

constructor TBaseRepository.Create;
begin
  FItems := TDictionary<String, IRepositoryItem>.Create;
  FAttributes := [];
end;

procedure TBaseRepository.CreateOrUpdateItem(item: IRepositoryItem);
var
  repositoryItem: IRepositoryItem;
begin
  if FItems.ContainsKey(item.InternalID) then
  begin
    if FItems.TryGetValue(item.InternalID, repositoryItem) then
    begin
      repositoryItem.UpdateFrom(item);
      AfterCreateOrUpdateItem(repositoryItem);
    end;
  end else
  begin
    FItems.AddOrSetValue(item.InternalID, item);
    AfterCreateOrUpdateItem(item);
  end;
end;

procedure TBaseRepository.DeleteItem(id: String);
begin
  FItems.Remove(id);
end;

destructor TBaseRepository.Destroy;
begin
  FItems.Free;
end;

function TBaseRepository.getAllItems: TDictionary<String, IRepositoryItem>.TValueCollection;
begin
  Result := FItems.Values;
end;

function TBaseRepository.getAttributes: TRepositoryAttributes;
begin
  Result := FAttributes;
end;

function TBaseRepository.getItem(id: String): IRepositoryItem;
var
  repositoryItem: IRepositoryItem;
begin
  Result := nil;
  if FItems.TryGetValue(id, repositoryItem) then
  begin
    Result := repositoryItem;
  end;
end;

procedure TBaseRepository.LoadAll;
begin
  //
end;

function TBaseRepository.LockItem(id: String): Boolean;
begin
  //TODO
  // to be implemented
  Result := True;
end;

procedure TBaseRepository.setAttributes(value: TRepositoryAttributes);
begin
  FAttributes := value;
end;

procedure TBaseRepository.UnlockItem(id: String);
begin
  //TODO
  // to be implemented
end;

{ TDBBaseRepository }

procedure TDBBaseRepository.AddItem(ADataSet: TDataSet);
var
  item: IRepositoryItem;
  ms: TStream;
begin
  if ADataSet.FieldByName(FFieldNameStream).IsNull then
  begin
    item := TRepositoryItem.Create(
          ADataSet.FieldByName(FFieldNameId).AsString,
          ADataSet.FieldByName(FFieldNameDescriptor).AsString,
          ADataSet.FieldByName(FFieldNameType).AsString,
          ADataSet.FieldByName(FFieldNameLastModification).AsDateTime );
  end else
  begin
    ms := TMemoryStream.Create;
    try
      (ADataSet.FieldByName(FFieldNameStream)as TBlobField).SaveToStream(ms);
        item := TRepositoryItem.Create(
            ADataSet.FieldByName(FFieldNameId).AsString,
            ADataSet.FieldByName(FFieldNameDescriptor).AsString,
            ADataSet.FieldByName(FFieldNameType).AsString,
            ADataSet.FieldByName(FFieldNameLastModification).AsDateTime,
            ms);
    finally
      ms.Free;
    end;
  end;

  FItems.Add(ADataSet.FieldByName(FFieldNameId).AsString, item);
end;

procedure TDBBaseRepository.AfterCreateOrUpdateItem(item: IRepositoryItem);
var
  ds: TDataSet;
begin
  inherited;
  if FDataSource <> nil then
  begin
    if FDataSource.DataSet <> nil then
    begin
      ds := FDataSource.DataSet;
      if ds.Locate(FFieldNameId, item.InternalID, []) then
      begin
        ds.Edit;
      end else
      begin
        ds.Insert;
        ds.FieldByName(FFieldNameId).AsString := item.InternalID;
      end;
      ds.FieldByName(FFieldNameType).AsString := item.AType;
      ds.FieldByName(FFieldNameDescriptor).AsString := item.Descriptor;
      ds.FieldByName(FFieldNameLastModification).AsDateTime := item.LastModification;
      (ds.FieldByName(FFieldNameStream) as TBlobField).LoadFromStream(item.getStream);
      ds.Post;
    end else
    begin
      raise Exception.Create('Dataset is nil');
    end;
  end else
  begin
    raise Exception.Create('Datasource is nil');
  end;
end;

constructor TDBBaseRepository.Create;
begin
  inherited;

  FFieldNameId := 'InternalId';
  FFieldNameType := 'AType';
  FFieldNameDescriptor := 'ItemDescriptor';
  FFieldNameLastModification := 'LastModification';
  FFieldNameStream := 'Stream';
end;

procedure TDBBaseRepository.LoadAll;
begin
  if FDataSource <> nil then
  begin
    if FDataSource.DataSet <> nil then
    begin
      FDataSource.DataSet.Close;
      FDataSource.DataSet.Open;
      FItems.Clear;
      while not FDataSource.DataSet.Eof do
      begin
        AddItem(FDataSource.DataSet);
        FDataSource.DataSet.Next;
      end;
    end else
    begin
      raise Exception.Create('Dataset is nil');
    end;
  end else
  begin
    raise Exception.Create('Datasource is nil');
  end;
end;

end.
