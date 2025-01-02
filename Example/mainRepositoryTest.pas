unit mainRepositoryTest;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ListLabel28, Vcl.StdCtrls, Data.DB,
  dxmdaset, LlRepository, cxGraphics, cxLookAndFeels, cxLookAndFeelPainters,
  Vcl.Menus, cxButtons, Data.Win.ADODB, osADOTables;

type
  TForm1 = class(TForm)
    bPreview: TButton;
    ListLabel281: TListLabel28;
    dxMemData1: TdxMemData;
    DataSource1: TDataSource;
    dxMemData1test: TStringField;
    Memo1: TMemo;
    bPrint: TButton;
    DataSource2: TDataSource;
    osADODataSet1: TADODataSet;
    Label1: TLabel;
    eRepo: TEdit;
    procedure bPreviewClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure bPrintClick(Sender: TObject);
  private
    { Private-Deklarationen }
    FRepository: IRepository;

  public
    { Public-Deklarationen }
  end;

var
  Form1: TForm1;

implementation

uses LlCoreRepository, cmbtLL28x;

{$R *.dfm}

procedure TForm1.bPreviewClick(Sender: TObject);
var
  repo: ILlRepository;
begin
  repo := TLlCoreRepository.Create(Frepository);
  ListLabel281.Core.LlSetOption(LL_OPTION_ILLREPOSITORY, NativeInt(repo));
  if Length(eRepo.Text) > 0 then
  begin
    ListLabel281.AutoProjectFile := eRepo.Text;
  end;
//  ListLabel281.AutoDialogTitle := 'Test';
//  FRepository.Attributes := [raNoHierarchyAttribute];
  ListLabel281.Design;
end;

procedure TForm1.bPrintClick(Sender: TObject);
var
  repo: ILlRepository;
begin
  repo := TLlCoreRepository.Create(Frepository);
  ListLabel281.Core.LlSetOption(LL_OPTION_ILLREPOSITORY, NativeInt(repo));

  ListLabel281.Print;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  // with db
  FRepository := TDBBaseRepository.Create;
  (FRepository as TDBBaseRepository).Datasource := DataSource2;
  FRepository.LoadAll;


  // memory only
//  FRepository := TBaseRepository.Create;
end;

end.
