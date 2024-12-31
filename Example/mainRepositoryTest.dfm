object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Test List&Label Respository'
  ClientHeight = 366
  ClientWidth = 564
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  TextHeight = 15
  object bPreview: TButton
    Left = 64
    Top = 56
    Width = 75
    Height = 25
    Caption = 'Design'
    TabOrder = 0
    OnClick = bPreviewClick
  end
  object Memo1: TMemo
    Left = 64
    Top = 112
    Width = 185
    Height = 89
    Lines.Strings = (
      'Memo1')
    TabOrder = 1
  end
  object bPrint: TButton
    Left = 168
    Top = 56
    Width = 75
    Height = 25
    Caption = 'Print'
    TabOrder = 2
    OnClick = bPrintClick
  end
  object ListLabel281: TListLabel28
    AutoProjectFile = 'Test'
    Debug = []
    DataController.DataSource = DataSource1
    DataController.DetailSources = <>
    Left = 304
    Top = 56
  end
  object dxMemData1: TdxMemData
    Indexes = <>
    Persistent.Data = {
      5665728FC2F5285C8FFE3F010000001400000001000500746573740001020000
      0031320104000000313231320106000000313231323132}
    SortOptions = []
    Left = 72
    Top = 288
    object dxMemData1test: TStringField
      FieldName = 'test'
    end
  end
  object DataSource1: TDataSource
    DataSet = dxMemData1
    Left = 72
    Top = 224
  end
  object DataSource2: TDataSource
    DataSet = osADODataSet1
    Left = 168
    Top = 224
  end
  object osADODataSet1: TADODataSet
    ConnectionString = 
      'Provider=SQLOLEDB.1;Integrated Security=SSPI;Persist Security In' +
      'fo=False;Initial Catalog=MiProDat;Data Source=SURFACE-STUDIO2\DE' +
      'V2022'
    CommandText = 'select * from LL$Repositry'
    Parameters = <>
    Left = 168
    Top = 288
  end
end
