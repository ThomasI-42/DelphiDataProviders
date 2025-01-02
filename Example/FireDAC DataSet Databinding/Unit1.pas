unit Unit1;

interface

uses
  Registry, LlReport_Types,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys,
  FireDAC.VCLUI.Wait, Vcl.StdCtrls, Data.DB,
  FireDAC.Comp.Client,  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt,
  FireDAC.Comp.DataSet, FireDAC.Phys.MySQLDef, FireDAC.Phys.MySQL, FireDAC.Phys.MSAcc, FireDAC.Phys.MSAccDef,
  Vcl.ExtCtrls, Vcl.Grids, Vcl.DBGrids, ListLabel30, FireDAC.Phys.MSSQL,
  FireDAC.Phys.MSSQLDef, LlRepository, LlCoreRepository;

type
  TForm1 = class(TForm)
    lblGermanDescription: TLabel;
    lblEnglishDescription: TLabel;
    lblGerman: TLabel;
    lblEnglish: TLabel;
    groupInvoiceAndItemsList: TGroupBox;
    groupInvoiceMerge: TGroupBox;
    btnDesignInvoiceAndItemsList: TButton;
    btnPrintInvoiceAndItemsList: TButton;
    btnDesignInvoiceMerge: TButton;
    btnPrintInvoiceMerge: TButton;
    FDConnectionNorthwind: TFDConnection;
    FDQueryOrders: TFDQuery;
    DataSourceOrders: TDataSource;
    FDQueryOrderDetails: TFDQuery;
    DataSourceOrderDetails: TDataSource;
    ListLabel: TListLabel30;
    DataSourceRepository: TDataSource;
    FDQueryRepository: TFDQuery;
    cbUseRepository: TCheckBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure btnDesignInvoiceAndItemsListClick(Sender: TObject);
    procedure btnPrintInvoiceAndItemsListClick(Sender: TObject);
    procedure btnDesignInvoiceMergeClick(Sender: TObject);
    procedure btnPrintInvoiceMergeClick(Sender: TObject);
    procedure cbUseRepositoryClick(Sender: TObject);
  private
    { Private declarations }
    FRepository: IRepository;
    FCoreRepository: ILlRepository;
    procedure CreateRepositoryTable;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}
uses system.Generics.Collections, cmbtLL30x;

procedure TForm1.btnDesignInvoiceAndItemsListClick(Sender: TObject);
begin

  ListLabel.DataController.AutoMasterMode := TLlAutoMasterMode.mmAsFields;
  ListLabel.DataController.DataMember := '';
  if cbUseRepository.Checked then
  begin
    ListLabel.Core.LlSetOption(LL_OPTION_ILLREPOSITORY, NativeInt(FCoreRepository));
    // - To load the report-schema without the dialog, set AutoShowSelectFile to false
    // ListLabel.AutoShowSelectFile := False;
    // - use the repo id instead of the file name
    // ListLabel.AutoProjectFile := 'repository://{582C425A-CBC0-400C-9955-2774292F8861}';
  end else
  begin
    ListLabel.AutoProjectFile := 'inv_lst.lst';
  end;
  ListLabel.Design;

end;

procedure TForm1.btnDesignInvoiceMergeClick(Sender: TObject);
begin

  ListLabel.DataController.AutoMasterMode := TLlAutoMasterMode.mmAsVariables;
  ListLabel.DataController.DataMember := 'Orders';
  if cbUseRepository.Checked then
  begin
    ListLabel.Core.LlSetOption(LL_OPTION_ILLREPOSITORY, NativeInt(FCoreRepository));
  end else
  begin
    ListLabel.AutoProjectFile := 'inv_merg.lst';
  end;
  ListLabel.Design;

end;

procedure TForm1.btnPrintInvoiceAndItemsListClick(Sender: TObject);
begin

  ListLabel.DataController.AutoMasterMode := TLlAutoMasterMode.mmAsFields;
  ListLabel.DataController.DataMember := '';
  if cbUseRepository.Checked then
  begin
    ListLabel.Core.LlSetOption(LL_OPTION_ILLREPOSITORY, NativeInt(FCoreRepository));
  end else
  begin
    ListLabel.AutoProjectFile := 'inv_lst.lst';
  end;
  ListLabel.Print;

end;

procedure TForm1.btnPrintInvoiceMergeClick(Sender: TObject);
begin

  ListLabel.DataController.AutoMasterMode := TLlAutoMasterMode.mmAsVariables;
  ListLabel.DataController.DataMember := 'Orders';
  if cbUseRepository.Checked then
  begin
    ListLabel.Core.LlSetOption(LL_OPTION_ILLREPOSITORY, NativeInt(FCoreRepository));
  end else
  begin
    ListLabel.AutoProjectFile := 'inv_merg.lst';
  end;
  ListLabel.Print;

end;

procedure TForm1.cbUseRepositoryClick(Sender: TObject);
begin
  if cbUseRepository.Checked then
  begin
    FRepository := TDBBaseRepository.Create;
    FRepository.Attributes := [];
    (FRepository as TDBBaseRepository).Datasource := DataSourceRepository;
    FRepository.LoadAll;
    FCoreRepository := TLlCoreRepository.Create(FRepository);
  end else
  begin
    FRepository := nil;
    FCoreRepository := nil;
    ListLabel.Core.LlSetOption(LL_OPTION_ILLREPOSITORY, 0);
  end;
end;

procedure TForm1.CreateRepositoryTable;
var
  sl: TStrings;
  command: TFDCommand;
begin

  sl := TStringList.Create;
  try
    FDConnectionNorthwind.GetTableNames('', '', '', sl);
    if sl.IndexOf('[LL$Repository]') < 0 then
    begin
      // create Repository table
      sl.Clear;
      sl.Add('');
      sl.Add('CREATE TABLE [LL$Repository](');
      sl.Add('	Id COUNTER NOT NULL,');
      sl.Add('	InternalId TEXT(80) NOT NULL,');
      sl.Add('	FolderId TEXT(250) NULL,');
      sl.Add('	ItemDescriptor MEMO NULL,');
      sl.Add('	AType TEXT(80) NULL,');
      sl.Add('	LastModification date NULL,');
      sl.Add('	Stream image NULL,');
      sl.Add('  CONSTRAINT UK_LLRepositry UNIQUE(InternalId),');
      sl.Add('  CONSTRAINT PK_LLRepositry PRIMARY KEY (Id)');
      sl.Add(')');
      command := TFDCommand.Create(self);
      try
        command.Connection := FDConnectionNorthwind;
        command.Execute(sl.Text);
      finally
        command.Free;
      end;
    end;
  finally
    sl.Free;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
Var NWindDatabasePath: String;
Registry: TRegistry;
Error: Boolean;
ErrorMessage: String;
begin

   Error := False;
   ErrorMessage := 'Unable to find sample database. Make sure List & Label is installed correctly.';

   Registry := TRegistry.Create(KEY_READ);
   if (Registry.OpenKeyReadOnly('Software\combit\cmbtll')) then
   begin

      NWindDatabasePath := Registry.ReadString('NWINDPath');
      if (FileExists(NWindDatabasePath)) then
      begin

        try

          FDConnectionNorthwind.Connected := False;
          FDConnectionNorthwind.Params.Database := NWindDatabasePath;
          FDConnectionNorthwind.Connected := True;

          CreateRepositoryTable;
        Except

            on Ecx: Exception do
            begin

              Error := True;
              ErrorMessage := 'Unable to find sample database. Make sure List & Label is installed correctly.' + #13#10#13#10 + Ecx.ClassName + ' error raised, with message: ' + Ecx.Message;

            end;

        end;

      end
      else
      begin

        Error := True;

      end;

      Registry.CloseKey;

   end
   else
   begin

    Error := True;

   end;

   Registry.Free;

   if (Error) then
   begin

      MessageBox(self.Handle, PWideChar(ErrorMessage), 'List & Label', MB_OK);

      btnDesignInvoiceMerge.Enabled := False;
      btnPrintInvoiceMerge.Enabled := False;
      btnDesignInvoiceAndItemsList.Enabled := False;
      btnPrintInvoiceAndItemsList.Enabled := False;

   end;

end;

end.
