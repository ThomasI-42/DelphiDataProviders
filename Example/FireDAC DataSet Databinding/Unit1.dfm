object Form1: TForm1
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'List & Label - VCL DataSet Sample'
  ClientHeight = 325
  ClientWidth = 612
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OnCreate = FormCreate
  TextHeight = 13
  object lblGermanDescription: TLabel
    Left = 63
    Top = 24
    Width = 474
    Height = 33
    AutoSize = False
    Caption = 
      'Dieses Beispiel zeigt die Verwendung der Daten'#252'bergabe f'#252'r die M' +
      'ethoden Print und Design im datengebundenen Modus.'
    WordWrap = True
  end
  object lblEnglishDescription: TLabel
    Left = 63
    Top = 63
    Width = 474
    Height = 33
    AutoSize = False
    Caption = 
      'This sample shows the usage of databinding for the methods Print' +
      ' and Design in the databind mode.'
    WordWrap = True
  end
  object lblGerman: TLabel
    Left = 16
    Top = 24
    Width = 25
    Height = 17
    AutoSize = False
    Caption = 'D: '
  end
  object lblEnglish: TLabel
    Left = 16
    Top = 63
    Width = 25
    Height = 17
    AutoSize = False
    Caption = 'US: '
  end
  object Label1: TLabel
    Left = 40
    Top = 224
    Width = 25
    Height = 17
    AutoSize = False
    Caption = 'D: '
  end
  object Label2: TLabel
    Left = 40
    Top = 263
    Width = 25
    Height = 17
    AutoSize = False
    Caption = 'US: '
  end
  object Label3: TLabel
    Left = 87
    Top = 263
    Width = 474
    Height = 33
    AutoSize = False
    Caption = 
      '"Use Repository'#8221' saves the report design in the database. When u' +
      'sing it for the first time, import the .lst file and save it aga' +
      'in'
    WordWrap = True
  end
  object Label4: TLabel
    Left = 87
    Top = 224
    Width = 474
    Height = 33
    AutoSize = False
    Caption = 
      'Mit "Use Repository" wird das Resport Design in der Datenbank ge' +
      'speichert. Bei erstmaliger Verwendung das .lst - File importiere' +
      'n und wieder speichern.'
    WordWrap = True
  end
  object groupInvoiceAndItemsList: TGroupBox
    Left = 16
    Top = 102
    Width = 249
    Height = 67
    Caption = 'Invoice && Items List'
    TabOrder = 0
    object btnDesignInvoiceAndItemsList: TButton
      Left = 14
      Top = 24
      Width = 75
      Height = 25
      Caption = 'Design...'
      TabOrder = 0
      OnClick = btnDesignInvoiceAndItemsListClick
    end
    object btnPrintInvoiceAndItemsList: TButton
      Left = 95
      Top = 24
      Width = 136
      Height = 25
      Caption = 'Print/Preview/Export...'
      TabOrder = 1
      OnClick = btnPrintInvoiceAndItemsListClick
    end
  end
  object groupInvoiceMerge: TGroupBox
    Left = 288
    Top = 102
    Width = 249
    Height = 67
    Caption = 'Invoice Merge'
    TabOrder = 1
    object btnDesignInvoiceMerge: TButton
      Left = 14
      Top = 24
      Width = 75
      Height = 25
      Caption = 'Design...'
      TabOrder = 0
      OnClick = btnDesignInvoiceMergeClick
    end
    object btnPrintInvoiceMerge: TButton
      Left = 95
      Top = 24
      Width = 136
      Height = 25
      Caption = 'Print/Preview/Export...'
      TabOrder = 1
      OnClick = btnPrintInvoiceMergeClick
    end
  end
  object cbUseRepository: TCheckBox
    Left = 30
    Top = 192
    Width = 195
    Height = 17
    Caption = 'Use Repository instead of Files'
    TabOrder = 2
    OnClick = cbUseRepositoryClick
  end
  object FDConnectionNorthwind: TFDConnection
    Params.Strings = (
      'DriverID=MSAcc')
    FetchOptions.AssignedValues = [evCursorKind]
    FetchOptions.CursorKind = ckStatic
    LoginPrompt = False
    Left = 176
    Top = 240
  end
  object FDQueryOrders: TFDQuery
    MasterFields = 'OrderID'
    Connection = FDConnectionNorthwind
    FetchOptions.AssignedValues = [evCache, evUnidirectional, evCursorKind]
    FetchOptions.CursorKind = ckStatic
    FetchOptions.Cache = [fiBlobs, fiMeta]
    SQL.Strings = (
      'Select * From Orders Where (OrderID > 11040)')
    Left = 240
    Top = 240
  end
  object DataSourceOrders: TDataSource
    DataSet = FDQueryOrders
    Left = 368
    Top = 240
  end
  object FDQueryOrderDetails: TFDQuery
    MasterSource = DataSourceOrders
    MasterFields = 'OrderID'
    DetailFields = 'OrderID'
    Connection = FDConnectionNorthwind
    FetchOptions.AssignedValues = [evCache, evUnidirectional, evCursorKind]
    FetchOptions.CursorKind = ckStatic
    FetchOptions.Cache = [fiBlobs, fiMeta]
    SQL.Strings = (
      
        'SELECT [Order Details].OrderID, [Order Details].Quantity, [Order' +
        ' Details].UnitPrice, [Order Details].ProductID, Products.Product' +
        'ID AS ProductsProductID, Products.CategoryID, Products.Discontin' +
        'ued, Products.ProductName, Products.QuantityPerUnit, Products.Re' +
        'orderLevel, Products.SupplierID, Products.UnitPrice AS ProductsU' +
        'nitPrice, Products.UnitsInStock, Products.UnitsOnOrder FROM [Ord' +
        'er Details] INNER JOIN Products ON [Order Details].ProductID = P' +
        'roducts.ProductID WHERE ([Order Details].OrderID = :OrderID)')
    Left = 304
    Top = 240
    ParamData = <
      item
        Name = 'ORDERID'
        DataType = ftString
        ParamType = ptInput
        Size = 8
        Value = '11041'
      end>
  end
  object DataSourceOrderDetails: TDataSource
    DataSet = FDQueryOrderDetails
    Left = 424
    Top = 240
  end
  object ListLabel: TListLabel30
    Debug = []
    DataController.DataSource = DataSourceOrders
    DataController.DetailSources = <
      item
        Name = 'Orders'
        DataSource = DataSourceOrders
        PrimaryKeyField = 'OrderID'
        InternalOwnItems = <
          item
            Name = 'Order Details'
            DataSource = DataSourceOrderDetails
            PrimaryKeyField = 'OrderID'
            DetailKeyField = 'OrderID'
            MasterKeyField = 'OrderID'
          end>
      end>
    Left = 24
    Top = 248
  end
  object DataSourceRepository: TDataSource
    DataSet = FDQueryRepository
    Left = 496
    Top = 240
  end
  object FDQueryRepository: TFDQuery
    IndexFieldNames = 'Id;InternalId'
    Connection = FDConnectionNorthwind
    FetchOptions.AssignedValues = [evCache, evUnidirectional, evCursorKind]
    SQL.Strings = (
      'select * from [LL$Repository]')
    Left = 560
    Top = 240
  end
end
