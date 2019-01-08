{ ############################################################################ }
{ #                                                                          # }
{ #  MGSoft Delphi Components v1.0.0                                         # }
{ #                                                                          # }
{ #  MGPlacement v1.0.0 - Сохранение состояния окна                          # }
{ #                                                                          # }
{ #  License: GPLv3                                                          # }
{ #                                                                          # }
{ #  Author: Mikhail Grigorev (icq: 161867489, email: sleuthhound@gmail.com) # }
{ #                                                                          # }
{ ############################################################################ }

unit MGPlacementFormStorageEditor;

{$I MGSoft.inc}

interface

uses
  SysUtils, Messages, Classes,
  {$IFDEF DELPHI16_UP}Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.Buttons, Vcl.ExtCtrls, Vcl.Consts,
  {$ELSE}Graphics, Controls, Forms, Dialogs, StdCtrls, Buttons, ExtCtrls, Consts,{$ENDIF}
  MGPlacement, MGPlacementProps,  MGVCLUtils,
  {$IFDEF DELPHI6_UP} DesignIntf, DesignEditors, VCLEditors {$ELSE} DsgnIntf {$ENDIF};

type

{$IFNDEF DELPHI4_UP}
  IDesigner = TDesigner;
{$ENDIF}

{ FormStorageDesigner }

  TFormStorageDesigner = class(TForm)
    Bevel1: TBevel;
    Label1: TLabel;
    Label3: TLabel;
    Label2: TLabel;
    UpButton: TSpeedButton;
    DownButton: TSpeedButton;
    StoredList: TListBox;
    PropertiesList: TListBox;
    ComponentsList: TListBox;
    FormBox: TGroupBox;
    ActiveCtrlBox: TCheckBox;
    PositionBox: TCheckBox;
    StateBox: TCheckBox;
    StringsBox: TCheckBox;
    AddButton: TButton;
    DeleteButton: TButton;
    ClearButton: TButton;
    OKButton: TButton;
    CancelButton: TButton;
    procedure StringsBoxClick(Sender: TObject);
    procedure AddButtonClick(Sender: TObject);
    procedure ClearButtonClick(Sender: TObject);
    procedure ListClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure DeleteButtonClick(Sender: TObject);
    procedure StoredListClick(Sender: TObject);
    procedure UpButtonClick(Sender: TObject);
    procedure DownButtonClick(Sender: TObject);
    procedure StoredListDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure StoredListDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure PropertiesListDblClick(Sender: TObject);
  private
    { Private declarations }
    FCompOwner: TComponent;
    FDesigner: IDesigner;
    procedure ListToIndex(List: TCustomListBox; Idx: Integer);
    procedure UpdateCurrent;
    procedure DeleteProp(I: Integer);
    function FindProp(const CompName, PropName: string; var IdxComp,
      IdxProp: Integer): Boolean;
    procedure ClearLists;
    procedure CheckAddItem(const CompName, PropName: string);
    procedure AddItem(IdxComp, IdxProp: Integer; AUpdate: Boolean);
    procedure BuildLists(StoredProps: TStrings; StringsOnly: Boolean);
    procedure CheckButtons;
    procedure SetStoredList(AList: TStrings);
  public
    { Public declarations }
  end;

{ TMGFormStorageEditor }

  TMGFormStorageEditor = class(TComponentEditor)
    procedure ExecuteVerb(Index: Integer); override;
    function GetVerb(Index: Integer): string; override;
    function GetVerbCount: Integer; override;
  end;

{ TMGStoredPropsProperty }

  TMGStoredPropsProperty = class(TClassProperty)
  public
    function GetAttributes: TPropertyAttributes; override;
    function GetValue: string; override;
    procedure Edit; override;
  end;

{ Show component editor }
function ShowStorageDesigner(ACompOwner: TComponent; ADesigner: IDesigner;
  AStoredList: TStrings; var Options: TPlacementOptions): Boolean;

procedure BoxMoveFocusedItem(List: TWinControl; DstIndex: Integer);
procedure BoxSetItem(List: TWinControl; Index: Integer);
procedure BoxDragOver(List: TWinControl; Source: TObject;
  X, Y: Integer; State: TDragState; var Accept: Boolean; Sorted: Boolean);

implementation

uses Windows, TypInfo;

{$R *.DFM}

{$IFNDEF DELPHI1}
 {$D-}
{$ENDIF}

{ TMGFormStorageEditor }

procedure TMGFormStorageEditor.ExecuteVerb(Index: Integer);
var
  Storage: TMGFormStorage;
  Opt: TPlacementOptions;
begin
  Storage := Component as TMGFormStorage;
  if Index = 0 then
  begin
    Opt := Storage.Options;
    if ShowStorageDesigner(TComponent(Storage.Owner), Designer, Storage.StoredProps, Opt) then
    begin
      Storage.Options := Opt;
      {$IFNDEF DELPHI1}
      Storage.SetNotification;
      {$ENDIF}
    end;
  end;
end;

function TMGFormStorageEditor.GetVerb(Index: Integer): string;
begin
  case Index of
    0: Result := 'Form Storage Designer...';
  else
    Result := '';
  end;
end;

function TMGFormStorageEditor.GetVerbCount: Integer;
begin
  Result := 1;
end;

{ TMGStoredPropsProperty }

function TMGStoredPropsProperty.GetAttributes: TPropertyAttributes;
begin
  Result := inherited GetAttributes + [paDialog] - [paSubProperties];
end;

function TMGStoredPropsProperty.GetValue: string;
begin
  if TStrings(GetOrdValue).Count > 0 then Result := inherited GetValue
  else Result := srNone;
end;

procedure TMGStoredPropsProperty.Edit;
var
  Storage: TMGFormStorage;
  Opt: TPlacementOptions;
begin
  Storage := GetComponent(0) as TMGFormStorage;
  Opt := Storage.Options;
  if ShowStorageDesigner(Storage.Owner as TComponent, Designer, Storage.StoredProps, Opt) then
  begin
    Storage.Options := Opt;
    {$IFNDEF DELPHI1}
    Storage.SetNotification;
    {$ENDIF}
  end;
end;

{ Show component editor }

function ShowStorageDesigner(ACompOwner: TComponent; ADesigner: IDesigner;
  AStoredList: TStrings; var Options: TPlacementOptions): Boolean;
begin
  with TFormStorageDesigner.Create(Application) do
  try
    FCompOwner := ACompOwner;
    FDesigner := ADesigner;
    Screen.Cursor := crHourGlass;
    try
      UpdateStoredList(ACompOwner, AStoredList, False);
      SetStoredList(AStoredList);
      ActiveCtrlBox.Checked := fpActiveControl in Options;
      PositionBox.Checked := fpPosition in Options;
      StateBox.Checked := fpState in Options;
    finally
      Screen.Cursor := crDefault;
    end;
    Result := ShowModal = mrOk;
    if Result then
    begin
      AStoredList.Assign(StoredList.Items);
      Options := [];
      if ActiveCtrlBox.Checked then Include(Options, fpActiveControl);
      if PositionBox.Checked then Include(Options, fpPosition);
      if StateBox.Checked then Include(Options, fpState);
    end;
  finally
    Free;
  end;
end;

{ Box Proc }

function BoxItems(List: TWinControl): TStrings;
begin
  if List is TCustomListBox then
    Result := TCustomListBox(List).Items
  else if List is TCustomListBox then
    Result := TCustomListBox(List).Items
  else Result := nil;
end;

function BoxGetItemIndex(List: TWinControl): Integer;
begin
  if List is TCustomListBox then
    Result := TCustomListBox(List).ItemIndex
  else if List is TCustomListBox then
    Result := TCustomListBox(List).ItemIndex
  else Result := LB_ERR;
end;

procedure BoxMoveFocusedItem(List: TWinControl; DstIndex: Integer);
begin
  if (DstIndex >= 0) and (DstIndex < BoxItems(List).Count) then
    if (DstIndex <> BoxGetItemIndex(List)) then begin
      BoxItems(List).Move(BoxGetItemIndex(List), DstIndex);
      BoxSetItem(List, DstIndex);
    end;
end;

function BoxMultiSelect(List: TWinControl): Boolean;
begin
  if List is TCustomListBox then
    Result := TListBox(List).MultiSelect
  else if List is TCustomListBox then
    Result := TListBox(List).MultiSelect
  else Result := False;
end;

procedure BoxSetSelected(List: TWinControl; Index: Integer; Value: Boolean);
begin
  if List is TCustomListBox then
    TCustomListBox(List).Selected[Index] := Value
  else if List is TCustomListBox then
    TCustomListBox(List).Selected[Index] := Value;
end;

procedure BoxSetItemIndex(List: TWinControl; Index: Integer);
begin
  if List is TCustomListBox then
    TCustomListBox(List).ItemIndex := Index
  else if List is TCustomListBox then
    TCustomListBox(List).ItemIndex := Index;
end;

procedure BoxSetItem(List: TWinControl; Index: Integer);
var
  MaxIndex: Integer;
begin
  if BoxItems(List) = nil then Exit;
  with List do begin
    if CanFocus then SetFocus;
    MaxIndex := BoxItems(List).Count - 1;
    if Index = LB_ERR then Index := 0
    else if Index > MaxIndex then Index := MaxIndex;
    if Index >= 0 then begin
      if BoxMultiSelect(List) then BoxSetSelected(List, Index, True)
      else BoxSetItemIndex(List, Index);
    end;
  end;
end;

function BoxItemRect(List: TWinControl; Index: Integer): TRect;
begin
  if List is TCustomListBox then
    Result := TCustomListBox(List).ItemRect(Index)
  else if List is TCustomListBox then
    Result := TCustomListBox(List).ItemRect(Index)
  else FillChar(Result, SizeOf(Result), 0);
end;

function BoxSelCount(List: TWinControl): Integer;
begin
  if List is TCustomListBox then
    Result := TCustomListBox(List).SelCount
  else if List is TCustomListBox then
    Result := TCustomListBox(List).SelCount
  else Result := 0;
end;

function BoxItemAtPos(List: TWinControl; Pos: TPoint;
  Existing: Boolean): Integer;
begin
  if List is TCustomListBox then
    Result := TCustomListBox(List).ItemAtPos(Pos, Existing)
  else if List is TCustomListBox then
    Result := TCustomListBox(List).ItemAtPos(Pos, Existing)
  else Result := LB_ERR;
end;

function BoxCanDropItem(List: TWinControl; X, Y: Integer;
  var DragIndex: Integer): Boolean;
var
  Focused: Integer;
begin
  Result := False;
  if (BoxSelCount(List) = 1) or (not BoxMultiSelect(List)) then begin
    Focused := BoxGetItemIndex(List);
    if Focused <> LB_ERR then begin
      DragIndex := BoxItemAtPos(List, Point(X, Y), True);
      if (DragIndex >= 0) and (DragIndex <> Focused) then begin
        Result := True;
      end;
    end;
  end;
end;

procedure BoxDragOver(List: TWinControl; Source: TObject;
  X, Y: Integer; State: TDragState; var Accept: Boolean; Sorted: Boolean);
var
  DragIndex: Integer;
  R: TRect;

  procedure DrawItemFocusRect(Idx: Integer);
{$IFNDEF VER80}
  var
    P: TPoint;
    DC: HDC;
{$ENDIF}
  begin
    R := BoxItemRect(List, Idx);
{$IFNDEF VER80}
    P := List.ClientToScreen(R.TopLeft);
    R := Bounds(P.X, P.Y, R.Right - R.Left, R.Bottom - R.Top);
    DC := GetDC(0);
    DrawFocusRect(DC, R);
    ReleaseDC(0, DC);
{$ELSE}
    BoxGetCanvas(List).DrawFocusRect(R);
{$ENDIF}
  end;

begin
  if Source <> List then
    Accept := (Source is TWinControl) or (Source is TCustomListBox)
  else begin
    if Sorted then Accept := False
    else begin
      Accept := BoxCanDropItem(List, X, Y, DragIndex);
      if ((List.Tag - 1) = DragIndex) and (DragIndex >= 0) then begin
        if State = dsDragLeave then begin
          DrawItemFocusRect(List.Tag - 1);
          List.Tag := 0;
        end;
      end
      else begin
        if List.Tag > 0 then DrawItemFocusRect(List.Tag - 1);
        if DragIndex >= 0 then DrawItemFocusRect(DragIndex);
        List.Tag := DragIndex + 1;
      end;
    end;
  end;
end;

{ FormStorageDesigner }

procedure TFormStorageDesigner.ListToIndex(List: TCustomListBox; Idx: Integer);

  procedure SetItemIndex(Index: Integer);
  begin
    if TListBox(List).MultiSelect then
      TListBox(List).Selected[Index] := True;
    List.ItemIndex := Index;
  end;

begin
  if Idx < List.Items.Count then
    SetItemIndex(Idx)
  else if Idx - 1 < List.Items.Count then
    SetItemIndex(Idx - 1)
  else if (List.Items.Count > 0) then
    SetItemIndex(0);
end;

procedure TFormStorageDesigner.UpdateCurrent;
var
  IdxProp: Integer;
  List: TStrings;
begin
  IdxProp := PropertiesList.ItemIndex;
  if IdxProp < 0 then IdxProp := 0;
  if ComponentsList.Items.Count <= 0 then
  begin
    PropertiesList.Clear;
    Exit;
  end;
  if (ComponentsList.ItemIndex < 0) then
    ComponentsList.ItemIndex := 0;
  List := TStrings(ComponentsList.Items.Objects[ComponentsList.ItemIndex]);
  if List.Count > 0 then PropertiesList.Items := List
  else PropertiesList.Clear;
  ListToIndex(PropertiesList, IdxProp);
  CheckButtons;
end;

procedure TFormStorageDesigner.DeleteProp(I: Integer);
var
  CompName, PropName: string;
  IdxComp, IdxProp, Idx: Integer;
  StrList: TStringList;
begin
  Idx := StoredList.ItemIndex;
  if ParseStoredItem(StoredList.Items[I], CompName, PropName) then
  begin
    StoredList.Items.Delete(I);
    if FDesigner <> nil then FDesigner.Modified;
    ListToIndex(StoredList, Idx);
    {I := ComponentsList.ItemIndex;}
    if not FindProp(CompName, PropName, IdxComp, IdxProp) then
    begin
      if IdxComp < 0 then
      begin
        StrList := TStringList.Create;
        try
          StrList.Add(PropName);
          ComponentsList.Items.AddObject(CompName, StrList);
          ComponentsList.ItemIndex := ComponentsList.Items.IndexOf(CompName);
        except
          StrList.Free;
          raise;
        end;
      end
      else
      begin
        TStrings(ComponentsList.Items.Objects[IdxComp]).Add(PropName);
      end;
      UpdateCurrent;
    end;
  end;
end;

function TFormStorageDesigner.FindProp(const CompName, PropName: string; var IdxComp,
  IdxProp: Integer): Boolean;
begin
  Result := False;
  IdxComp := ComponentsList.Items.IndexOf(CompName);
  if IdxComp >= 0 then
  begin
    IdxProp := TStrings(ComponentsList.Items.Objects[IdxComp]).IndexOf(PropName);
    if IdxProp >= 0 then Result := True;
  end;
end;

procedure TFormStorageDesigner.ClearLists;
var
  I: Integer;
begin
  for I := 0 to ComponentsList.Items.Count - 1 do
  begin
    ComponentsList.Items.Objects[I].Free;
  end;
  ComponentsList.Items.Clear;
  ComponentsList.Clear;
  PropertiesList.Clear;
  StoredList.Clear;
end;

procedure TFormStorageDesigner.AddItem(IdxComp, IdxProp: Integer; AUpdate: Boolean);
var
  Idx: Integer;
  StrList: TStringList;
  CompName, PropName: string;
  Component: TComponent;
begin
  CompName := ComponentsList.Items[IdxComp];
  Component := FCompOwner.FindComponent(CompName);
  if Component = nil then Exit;
  StrList := TStringList(ComponentsList.Items.Objects[IdxComp]);
  PropName := StrList[IdxProp];
  StrList.Delete(IdxProp);
  if StrList.Count = 0 then
  begin
    Idx := ComponentsList.ItemIndex;
    StrList.Free;
    ComponentsList.Items.Delete(IdxComp);
    ListToIndex(ComponentsList, Idx);
  end;
  StoredList.Items.AddObject(CreateStoredItem(CompName, PropName), Component);
  if FDesigner <> nil then FDesigner.Modified;
  StoredList.ItemIndex := StoredList.Items.Count - 1;
  if AUpdate then UpdateCurrent;
end;

procedure TFormStorageDesigner.CheckAddItem(const CompName, PropName: string);
var
  IdxComp, IdxProp: Integer;
begin
  if FindProp(CompName, PropName, IdxComp, IdxProp) then
    AddItem(IdxComp, IdxProp, True);
end;

procedure TFormStorageDesigner.BuildLists(StoredProps: TStrings; StringsOnly: Boolean);
var
  I, J: Integer;
  C: TComponent;
  List: TPropInfoList;
  StrList: TStrings;
  CompName, PropName: string;
begin
  ClearLists;
  if FCompOwner <> nil then
  begin
    for I := 0 to FCompOwner.ComponentCount - 1 do
    begin
      C := FCompOwner.Components[I];
      if (C is TMGFormPlacement) or (C.Name = '') then Continue;
      if StringsOnly then
         List := TPropInfoList.Create(C, [tkString,tkLString,tkWString{$IFDEF UNICODE},tkUString{$ENDIF}])
      else
      List := TPropInfoList.Create(C, tkProperties);
      try
        StrList := TStringList.Create;
        try
          TStringList(StrList).Sorted := True;
          for J := 0 to List.Count - 1 do
            if List.Items[J]^.Name <> 'Name' then       // corrected Rx bug !
              StrList.Add(string(List.Items[J]^.Name)); // do NOT store Name property
          ComponentsList.Items.AddObject(C.Name, StrList);
        except
          StrList.Free;
          raise;
        end;
      finally
        List.Free;
      end;
    end;
    if StoredProps <> nil then
    begin
      for I := 0 to StoredProps.Count - 1 do
      begin
        if ParseStoredItem(StoredProps[I], CompName, PropName) then
          CheckAddItem(CompName, PropName);
      end;
      ListToIndex(StoredList, 0);
    end;
  end
  else StoredList.Items.Clear;
  UpdateCurrent;
end;

procedure TFormStorageDesigner.SetStoredList(AList: TStrings);
begin
  BuildLists(AList,False);
  if ComponentsList.Items.Count > 0 then
    ComponentsList.ItemIndex := 0;
  CheckButtons;
end;

procedure TFormStorageDesigner.CheckButtons;
var
  Enable: Boolean;
begin
  AddButton.Enabled := (ComponentsList.ItemIndex >= 0) and
    (PropertiesList.ItemIndex >= 0);
  Enable := (StoredList.Items.Count > 0) and
    (StoredList.ItemIndex >= 0);
  DeleteButton.Enabled := Enable;
  ClearButton.Enabled := Enable;
  UpButton.Enabled := Enable and (StoredList.ItemIndex > 0);
  DownButton.Enabled := Enable and (StoredList.ItemIndex < StoredList.Items.Count - 1);
end;

procedure TFormStorageDesigner.AddButtonClick(Sender: TObject);
var
  I: Integer;
begin
  if PropertiesList.SelCount > 0 then
  begin
    for I := PropertiesList.Items.Count - 1 downto 0 do
    begin
      if PropertiesList.Selected[I] then
        AddItem(ComponentsList.ItemIndex, I, False);
    end;
    UpdateCurrent;
  end
  else AddItem(ComponentsList.ItemIndex, PropertiesList.ItemIndex, True);
  CheckButtons;
end;

procedure TFormStorageDesigner.ClearButtonClick(Sender: TObject);
begin
  if StoredList.Items.Count > 0 then
  begin
    SetStoredList(nil);
    if FDesigner <> nil then FDesigner.Modified;
  end;
end;

procedure TFormStorageDesigner.DeleteButtonClick(Sender: TObject);
begin
  DeleteProp(StoredList.ItemIndex);
end;

procedure TFormStorageDesigner.ListClick(Sender: TObject);
begin
  if Sender = ComponentsList then UpdateCurrent
  else CheckButtons;
end;

procedure TFormStorageDesigner.FormDestroy(Sender: TObject);
begin
  ClearLists;
end;

procedure TFormStorageDesigner.StoredListClick(Sender: TObject);
begin
  CheckButtons;
end;

procedure TFormStorageDesigner.UpButtonClick(Sender: TObject);
begin
  BoxMoveFocusedItem(StoredList, StoredList.ItemIndex - 1);
  if FDesigner <> nil then FDesigner.Modified;
  CheckButtons;
end;

procedure TFormStorageDesigner.DownButtonClick(Sender: TObject);
begin
  BoxMoveFocusedItem(StoredList, StoredList.ItemIndex + 1);
  if FDesigner <> nil then FDesigner.Modified;
  CheckButtons;
end;

procedure TFormStorageDesigner.StoredListDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
begin
  BoxDragOver(StoredList, Source, X, Y, State, Accept, StoredList.Sorted);
  CheckButtons;
end;

procedure TFormStorageDesigner.StoredListDragDrop(Sender, Source: TObject; X,
  Y: Integer);
begin
  BoxMoveFocusedItem(StoredList, StoredList.ItemAtPos(Point(X, Y), True));
  if FDesigner <> nil then FDesigner.Modified;
  CheckButtons;
end;

procedure TFormStorageDesigner.PropertiesListDblClick(Sender: TObject);
begin
  if AddButton.Enabled then AddButtonClick(nil);
end;

procedure TFormStorageDesigner.StringsBoxClick(Sender: TObject); // method added by eddy
var
  list: TStringList;
begin
  list := TStringList.Create;
  try
    list.AddStrings(StoredList.Items);
    BuildLists(TStrings(list),StringsBox.Checked);
  finally
    list.Free;
  end;
  Invalidate;
end;

end.