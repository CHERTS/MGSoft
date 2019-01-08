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

unit MGPlacement;

{$I MGSoft.inc}

interface

uses
{$IFDEF HAS_UNITSCOPE}
  {$IFDEF MSWINDOWS}
  Winapi.Windows, Winapi.Messages,
  {$ENDIF MSWINDOWS}
  System.Classes, System.SysUtils, System.Types, System.IniFiles,
  {$IFDEF HAS_VCL}
  Vcl.Controls, Vcl.Dialogs, Vcl.Forms,
  {$ELSE}
  FMX.Controls, FMX.Dialogs, FMX.Forms,
  {$ENDIF}
{$ELSE ~HAS_UNITSCOPE}
  {$IFDEF MSWINDOWS}
  Windows,
  {$ENDIF MSWINDOWS}
  {$IFNDEF FPC}Messages,{$ENDIF FPC}
  Classes, SysUtils, Controls, Dialogs, Types, Forms, IniFiles,
{$ENDIF ~HAS_UNITSCOPE}
  Registry, MGHook, MGUtils;

type
  TPlacementOption = (fpState, fpPosition, fpActiveControl);
  TPlacementOptions = set of TPlacementOption;
  TPlacementOperation = (poSave, poRestore);
{$IFNDEF DELPHI1}
  TPlacementRegRoot = (prCurrentUser, prLocalMachine, prCurrentConfig,
    prClassesRoot, prUsers, prDynData);
{$ENDIF}

  TIniLink = class;

{ TMGWinMinMaxInfo }

  TMGFormPlacement = class;

  TMGWinMinMaxInfo = class(TPersistent)
  private
    FOwner: TMGFormPlacement;
    FMinMaxInfo: TMinMaxInfo;
    function GetMinMaxInfo(Index: Integer): Integer;
    procedure SetMinMaxInfo(Index: Integer; Value: Integer);
  public
    function DefaultMinMaxInfo: Boolean;
    procedure Assign(Source: TPersistent); override;
  published
    property MaxPosLeft: Integer index 0 read GetMinMaxInfo write SetMinMaxInfo default 0;
    property MaxPosTop: Integer index 1 read GetMinMaxInfo write SetMinMaxInfo default 0;
    property MaxSizeHeight: Integer index 2 read GetMinMaxInfo write SetMinMaxInfo default 0;
    property MaxSizeWidth: Integer index 3 read GetMinMaxInfo write SetMinMaxInfo default 0;
    property MaxTrackHeight: Integer index 4 read GetMinMaxInfo write SetMinMaxInfo default 0;
    property MaxTrackWidth: Integer index 5 read GetMinMaxInfo write SetMinMaxInfo default 0;
    property MinTrackHeight: Integer index 6 read GetMinMaxInfo write SetMinMaxInfo default 0;
    property MinTrackWidth: Integer index 7 read GetMinMaxInfo write SetMinMaxInfo default 0;
  end;

{ TMGFormPlacement }

  TMGFormPlacement = class(TComponent)
  private
    FActive: Boolean;
{$IFDEF DELPHI4_UP}
    FIniFileName: String;
    FIniSection: String;
{$ELSE}
    FIniFileName: PString;
    FIniSection: PString;
{$ENDIF}
    FIniFile: TIniFile;
    FUseRegistry: Boolean;
{$IFNDEF DELPHI1}
    FRegIniFile: TRegIniFile;
    FRegistryRoot: TPlacementRegRoot;
{$ENDIF}
    FLinks: TList;
    FOptions: TPlacementOptions;
    FVersion: Integer;
    FSaved: Boolean;
    FRestored: Boolean;
    FDestroying: Boolean;
    FPreventResize: Boolean;
    FWinMinMaxInfo: TMGWinMinMaxInfo;
    FDefMaximize: Boolean;
    FWinHook: TMGWindowHook;
    FSaveFormShow: TNotifyEvent;
    FSaveFormDestroy: TNotifyEvent;
    FSaveFormCloseQuery: TCloseQueryEvent;
    FOnSavePlacement: TNotifyEvent;
    FOnRestorePlacement: TNotifyEvent;
    procedure SetEvents;
    procedure RestoreEvents;
    procedure SetHook;
    procedure ReleaseHook;
    procedure CheckToggleHook;
    function CheckMinMaxInfo: Boolean;
    procedure MinMaxInfoModified;
    procedure SeTMGWinMinMaxInfo(Value: TMGWinMinMaxInfo);
    function GetIniSection: string;
    procedure SetIniSection(const Value: string);
    function GetIniFileName: string;
    procedure SetIniFileName(const Value: string);
    function GetIniFile: TObject;
    procedure SetPreventResize(Value: Boolean);
    procedure UpdatePreventResize;
    procedure UpdatePlacement;
    procedure IniNeeded(ReadOnly: Boolean);
    procedure IniFree;
    procedure AddLink(ALink: TIniLink);
    procedure NotifyLinks(Operation: TPlacementOperation);
    procedure RemoveLink(ALink: TIniLink);
    procedure WndMessage(Sender: TObject; var Msg: TMessage; var Handled: Boolean);
    procedure FormShow(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormDestroy(Sender: TObject);
    function GetForm: TForm;
  protected
    procedure Loaded; override;
    procedure Save; dynamic;
    procedure Restore; dynamic;
    procedure SavePlacement; virtual;
    procedure RestorePlacement; virtual;
    function DoReadString(const Section, Ident, Default: string): string; virtual;
    procedure DoWriteString(const Section, Ident, Value: string); virtual;
    property Form: TForm read GetForm;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure SaveFormPlacement;
    procedure RestoreFormPlacement;
    function ReadString(const Ident, Default: string): string;
    procedure WriteString(const Ident, Value: string);
    function ReadInteger(const Ident: string; Default: Longint): Longint;
    procedure WriteInteger(const Ident: string; Value: Longint);
    procedure EraseSections;
    property IniFileObject: TObject read GetIniFile;
    property IniFile: TIniFile read FIniFile;
{$IFNDEF DELPHI1}
    property RegIniFile: TRegIniFile read FRegIniFile;
{$ENDIF}
  published
    property Active: Boolean read FActive write FActive default True;
    property IniFileName: string read GetIniFileName write SetIniFileName;
    property IniSection: string read GetIniSection write SetIniSection;
    property MinMaxInfo: TMGWinMinMaxInfo read FWinMinMaxInfo write SeTMGWinMinMaxInfo;
    property Options: TPlacementOptions read FOptions write FOptions default [fpState, fpPosition];
    property PreventResize: Boolean read FPreventResize write SetPreventResize default False;
{$IFNDEF DELPHI1}
    property RegistryRoot: TPlacementRegRoot read FRegistryRoot write FRegistryRoot default prCurrentUser;
{$ENDIF}
    property UseRegistry: Boolean read FUseRegistry write FUseRegistry default False;
    property Version: Integer read FVersion write FVersion default 0;
    property OnSavePlacement: TNotifyEvent read FOnSavePlacement
      write FOnSavePlacement;
    property OnRestorePlacement: TNotifyEvent read FOnRestorePlacement
      write FOnRestorePlacement;
  end;

{ TMGFormStorage }

{$IFDEF DELPHI3_UP}
  TStoredValues = class;
  TStoredValue = class;
{$ENDIF DELPHI3_UP}

  TMGFormStorage = class(TMGFormPlacement)
  private
    FStoredProps: TStrings;
{$IFDEF DELPHI3_UP}
    FStoredValues: TStoredValues;
{$ENDIF DELPHI3_UP}
    procedure SetStoredProps(Value: TStrings);
{$IFDEF DELPHI3_UP}
    procedure SetStoredValues(Value: TStoredValues);
    function GetStoredValue(const Name: string): Variant;
    procedure SetStoredValue(const Name: string; Value: Variant);
{$ENDIF DELPHI3_UP}
  protected
    procedure Loaded; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure SavePlacement; override;
    procedure RestorePlacement; override;
    procedure SaveProperties; virtual;
    procedure RestoreProperties; virtual;
    procedure WriteState(Writer: TWriter); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
{$IFNDEF DELPHI1}
    procedure SetNotification;
{$ENDIF}
{$IFDEF DELPHI3_UP}
    property StoredValue[const Name: string]: Variant read GetStoredValue write SetStoredValue;
{$ENDIF DELPHI3_UP}
  published
    property StoredProps: TStrings read FStoredProps write SetStoredProps;
{$IFDEF DELPHI3_UP}
    property StoredValues: TStoredValues read FStoredValues write SetStoredValues;
{$ENDIF DELPHI3_UP}
  end;

{ TIniLink }

  TIniLink = class(TPersistent)
  private
    FStorage: TMGFormPlacement;
    FOnSave: TNotifyEvent;
    FOnLoad: TNotifyEvent;
    FOnIniLinkDestroy: TNotifyEvent;
    function GetIniObject: TObject;
    function GetRootSection: string;
    procedure SetStorage(Value: TMGFormPlacement);
  protected
    procedure SaveToIni; virtual;
    procedure LoadFromIni; virtual;
  public
    destructor Destroy; override;
    property IniObject: TObject read GetIniObject;
    property Storage: TMGFormPlacement read FStorage write SetStorage;
    property RootSection: string read GetRootSection;
    property OnSave: TNotifyEvent read FOnSave write FOnSave;
    property OnLoad: TNotifyEvent read FOnLoad write FOnLoad;
    property OnIniLinkDestroy: TNotifyEvent read FOnIniLinkDestroy write FOnIniLinkDestroy;
  end;

{$IFDEF DELPHI3_UP}

{ TStoredValue }

  TStoredValueEvent = procedure(Sender: TStoredValue; var Value: Variant) of object;

  TStoredValue = class(TCollectionItem)
  private
    FName: string;
    FValue: Variant;
    FKeyString: AnsiString;
    FOnSave: TStoredValueEvent;
    FOnRestore: TStoredValueEvent;
    function IsValueStored: Boolean;
    function GetStoredValues: TStoredValues;
  protected
    function GetDisplayName: string; override;
    procedure SetDisplayName(const Value: string); override;
  public
    constructor Create(Collection: TCollection); override;
    procedure Assign(Source: TPersistent); override;
    procedure Clear;
    procedure Save; virtual;
    procedure Restore; virtual;
    property StoredValues: TStoredValues read GetStoredValues;
  published
    property Name: string read FName write SetDisplayName;
    property Value: Variant read FValue write FValue stored IsValueStored;
    property KeyString: AnsiString read FKeyString write FKeyString;
    property OnSave: TStoredValueEvent read FOnSave write FOnSave;
    property OnRestore: TStoredValueEvent read FOnRestore write FOnRestore;
  end;

{ TStoredValues }

  TStoredValues = class({$IFDEF DELPHI4_UP}TOwnedCollection{$ELSE}TCollection{$ENDIF})
  private
    FStorage: TMGFormPlacement;
    function GetValue(const Name: string): TStoredValue;
    procedure SetValue(const Name: string; StoredValue: TStoredValue);
    function GetStoredValue(const Name: string): Variant;
    procedure SetStoredValue(const Name: string; Value: Variant);
    function GetItem(Index: Integer): TStoredValue;
    procedure SetItem(Index: Integer; StoredValue: TStoredValue);
  public
{$IFDEF DELPHI4_UP}
    constructor Create(AOwner: TPersistent);
{$ELSE}
    constructor Create;
{$ENDIF}
    function IndexOf(const Name: string): Integer;
    procedure SaveValues; virtual;
    procedure RestoreValues; virtual;
    property Storage: TMGFormPlacement read FStorage write FStorage;
    property Items[Index: Integer]: TStoredValue read GetItem write SetItem; default;
    property Values[const Name: string]: TStoredValue read GetValue write SetValue;
    property StoredValue[const Name: string]: Variant read GetStoredValue write SetStoredValue;
  end;

{$ENDIF DELPHI3_UP}

{$IFNDEF DELPHI1}
var
  DefCompanyName: string = '';
  RegUseAppTitle: Boolean = False;

function GetDefaultIniRegKey: string;
{$ENDIF}
function GetDefaultIniName: string;
function GetDefaultSection(Component: TComponent): string;

{$IFNDEF DELPHI1}
  {$HINTS OFF}
{$ENDIF}

type
  TNastyForm = class(TScrollingWinControl)
  private
    FActiveControl: TWinControl;
    FFocusedControl: TWinControl;
    FBorderIcons: TBorderIcons;
    FBorderStyle: TFormBorderStyle;
{$IFDEF DELPHI4_UP}
    FSizeChanging: Boolean;
{$ENDIF}
    FWindowState: TWindowState; { !! }
  end;

  THackComponent = class(TComponent);

  TOnGetDefaultIniName = function: string;
{$IFNDEF DELPHI1}
  {$HINTS ON}
{$ENDIF}

const
  OnGetDefaultIniName: TOnGetDefaultIniName = nil;
  { The following strings should not be localized }
  siFlags     = 'Flags';
  siShowCmd   = 'ShowCmd';
  siMinMaxPos = 'MinMaxPos';
  siNormPos   = 'NormPos';
  siPixels    = 'PixelsPerInch';
  siMDIChild  = 'MDI Children';
  siListCount = 'Count';
  siItem      = 'Item%d';

{$IFNDEF DELPHI1}
procedure WriteFormPlacementReg(Form: TForm; IniFile: TRegIniFile;
  const Section: string);
procedure ReadFormPlacementReg(Form: TForm; IniFile: TRegIniFile;
  const Section: string; LoadState, LoadPosition: Boolean);
{$ENDIF}
procedure IniWriteInteger(IniFile: TObject; const Section, Ident: string;
  Value: Longint);
function IniReadInteger(IniFile: TObject; const Section, Ident: string;
  Default: Longint): Longint;
procedure InternalWriteFormPlacement(Form: TForm; IniFile: TObject;
  const Section: string);
procedure InternalReadFormPlacement(Form: TForm; IniFile: TObject;
  const Section: string; LoadState, LoadPosition: Boolean);
procedure WritePosStr(IniFile: TObject; const Section, Ident, Value: string);
function ReadPosStr(IniFile: TObject; const Section, Ident: string): string;
procedure IniWriteString(IniFile: TObject; const Section, Ident,
  Value: string);
function CrtResString: string;
procedure WriteFormPlacement(Form: TForm; IniFile: TIniFile;
  const Section: string);
function IniReadString(IniFile: TObject; const Section, Ident,
  Default: string): string;
procedure ReadFormPlacement(Form: TForm; IniFile: TIniFile;
  const Section: string; LoadState, LoadPosition: Boolean);
procedure IniReadSections(IniFile: TObject; Strings: TStrings);
procedure IniEraseSection(IniFile: TObject; const Section: string);

implementation

uses
{$IFDEF DELPHI3_UP}
  {$IFDEF HAS_UNITSCOPE}
  Vcl.Consts,
  {$ELSE ~HAS_UNITSCOPE}
  Consts,
  {$ENDIF ~HAS_UNITSCOPE}
{$ENDIF DELPHI3_UP}
{$IFDEF DELPHI6_UP}
  Variants, RTLConsts,
{$ENDIF}
  MGPlacementProps;

const
{ The following string should not be localized }
  siActiveCtrl = 'ActiveControl';
  siVisible = 'Visible';
  siVersion = 'FormVersion';

{ TMGFormPlacement }

constructor TMGFormPlacement.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF DELPHI4_UP}
  FIniFileName := EmptyStr;
  FIniSection := EmptyStr;
{$ELSE}
  FIniFileName := NullStr;
  FIniSection := NullStr;
{$ENDIF}
  FActive := True;
  if AOwner is TForm then FOptions := [fpState, fpPosition]
  else FOptions := [];
  FWinHook := TMGWindowHook.Create(Self);
  FWinHook.AfterMessage := WndMessage;
  FWinMinMaxInfo := TMGWinMinMaxInfo.Create;
  FWinMinMaxInfo.FOwner := Self;
  FLinks := TList.Create;
end;

destructor TMGFormPlacement.Destroy;
begin
  IniFree;
  while FLinks.Count > 0 do RemoveLink(FLinks.Last);
  FLinks.Free;
  if not (csDesigning in ComponentState) then
  begin
    ReleaseHook;
    RestoreEvents;
  end;
{$IFNDEF DELPHI4_UP}
  DisposeStr(FIniFileName);
  DisposeStr(FIniSection);
{$ENDIF}
  FWinMinMaxInfo.Free;
  inherited Destroy;
end;

procedure TMGFormPlacement.Loaded;
var
  Loading: Boolean;
begin
  Loading := csLoading in ComponentState;
  inherited Loaded;
  if not (csDesigning in ComponentState) then
  begin
    if Loading then SetEvents;
    CheckToggleHook;
  end;
end;

procedure TMGFormPlacement.AddLink(ALink: TIniLink);
begin
  FLinks.Add(ALink);
  ALink.FStorage := Self;
end;

procedure TMGFormPlacement.NotifyLinks(Operation: TPlacementOperation);
var
  I: Integer;
begin
  for I := 0 to FLinks.Count - 1 do
    with TIniLink(FLinks[I]) do
      case Operation of
        poSave: SaveToIni;
        poRestore: LoadFromIni;
      end;
end;

procedure TMGFormPlacement.RemoveLink(ALink: TIniLink);
begin
  ALink.FStorage := nil;
  FLinks.Remove(ALink);
end;

function TMGFormPlacement.GetForm: TForm;
begin
  if Owner is TCustomForm then Result := TForm(Owner as TCustomForm)
  else Result := nil;
end;

procedure TMGFormPlacement.SetEvents;
begin
  if Owner is TCustomForm then
  begin
    with TForm(Form) do
    begin
      FSaveFormShow := OnShow;
      OnShow := FormShow;
      FSaveFormCloseQuery := OnCloseQuery;
      OnCloseQuery := FormCloseQuery;
      FSaveFormDestroy := OnDestroy;
      OnDestroy := FormDestroy;
      FDefMaximize := (biMaximize in BorderIcons);
    end;
    if FPreventResize then UpdatePreventResize;
  end;
end;

procedure TMGFormPlacement.RestoreEvents;
begin
  if (Owner <> nil) and (Owner is TCustomForm) then
    with TForm(Form) do
    begin
      OnShow := FSaveFormShow;
      OnCloseQuery := FSaveFormCloseQuery;
      OnDestroy := FSaveFormDestroy;
    end;
end;

procedure TMGFormPlacement.SetHook;
begin
  if not (csDesigning in ComponentState) and (Owner <> nil) and
    (Owner is TCustomForm) then
    FWinHook.WinControl := Form;
end;

procedure TMGFormPlacement.ReleaseHook;
begin
  FWinHook.WinControl := nil;
end;

procedure TMGFormPlacement.CheckToggleHook;
begin
  if CheckMinMaxInfo or PreventResize then SetHook else ReleaseHook;
end;

function TMGFormPlacement.CheckMinMaxInfo: Boolean;
begin
  Result := not FWinMinMaxInfo.DefaultMinMaxInfo;
end;

procedure TMGFormPlacement.MinMaxInfoModified;
begin
  UpdatePlacement;
  if not (csLoading in ComponentState) then CheckToggleHook;
end;

procedure TMGFormPlacement.SeTMGWinMinMaxInfo(Value: TMGWinMinMaxInfo);
begin
  FWinMinMaxInfo.Assign(Value);
end;

procedure TMGFormPlacement.WndMessage(Sender: TObject; var Msg: TMessage;
  var Handled: Boolean);
begin
  if FPreventResize and (Owner is TCustomForm) then
  begin
    case Msg.Msg of
      WM_GETMINMAXINFO:
        if Form.HandleAllocated and IsWindowVisible(Form.Handle) then
        begin
          with TWMGetMinMaxInfo(Msg).MinMaxInfo^ do
          begin
            ptMinTrackSize := Point(Form.Width, Form.Height);
            ptMaxTrackSize := Point(Form.Width, Form.Height);
          end;
          Msg.Result := 1;
        end;
      WM_INITMENUPOPUP:
        if TWMInitMenuPopup(Msg).SystemMenu then
        begin
          if Form.Menu <> nil then
            Form.Menu.DispatchPopup(TWMInitMenuPopup(Msg).MenuPopup);
          EnableMenuItem(TWMInitMenuPopup(Msg).MenuPopup, SC_SIZE,
            MF_BYCOMMAND or MF_GRAYED);
          EnableMenuItem(TWMInitMenuPopup(Msg).MenuPopup, SC_MAXIMIZE,
            MF_BYCOMMAND or MF_GRAYED);
          Msg.Result := 1;
        end;
      WM_NCHITTEST:
        begin
          if Msg.Result in [HTLEFT, HTRIGHT, HTBOTTOM, HTBOTTOMRIGHT,
            HTBOTTOMLEFT, HTTOP, HTTOPRIGHT, HTTOPLEFT]
          then Msg.Result := HTNOWHERE;
        end;
    end;
  end
  else if (Msg.Msg = WM_GETMINMAXINFO) then
  begin
    if CheckMinMaxInfo then
    begin
      with TWMGetMinMaxInfo(Msg).MinMaxInfo^ do
      begin
         if FWinMinMaxInfo.MinTrackWidth <> 0 then
           ptMinTrackSize.X := FWinMinMaxInfo.MinTrackWidth;
         if FWinMinMaxInfo.MinTrackHeight <> 0 then
           ptMinTrackSize.Y := FWinMinMaxInfo.MinTrackHeight;
         if FWinMinMaxInfo.MaxTrackWidth <> 0 then
           ptMaxTrackSize.X := FWinMinMaxInfo.MaxTrackWidth;
         if FWinMinMaxInfo.MaxTrackHeight <> 0 then
           ptMaxTrackSize.Y := FWinMinMaxInfo.MaxTrackHeight;
         if FWinMinMaxInfo.MaxSizeWidth <> 0 then
           ptMaxSize.X := FWinMinMaxInfo.MaxSizeWidth;
         if FWinMinMaxInfo.MaxSizeHeight <> 0 then
           ptMaxSize.Y := FWinMinMaxInfo.MaxSizeHeight;
         if FWinMinMaxInfo.MaxPosLeft <> 0 then
           ptMaxPosition.X := FWinMinMaxInfo.MaxPosLeft;
         if FWinMinMaxInfo.MaxPosTop <> 0 then
           ptMaxPosition.Y := FWinMinMaxInfo.MaxPosTop;
      end;
    end
    else
    begin
      TWMGetMinMaxInfo(Msg).MinMaxInfo^.ptMaxPosition.X := 0;
      TWMGetMinMaxInfo(Msg).MinMaxInfo^.ptMaxPosition.Y := 0;
    end;
    Msg.Result := 1;
  end;
end;

procedure TMGFormPlacement.FormShow(Sender: TObject);
begin
  if Active then
    try
      RestoreFormPlacement;
    except
      Application.HandleException(Self);
    end;
  if Assigned(FSaveFormShow) then FSaveFormShow(Sender);
end;

procedure TMGFormPlacement.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if Assigned(FSaveFormCloseQuery) then
    FSaveFormCloseQuery(Sender, CanClose);
  if CanClose and Active and (Owner is TCustomForm) and (Form.Handle <> 0) then
    try
      SaveFormPlacement;
    except
      Application.HandleException(Self);
    end;
end;

procedure TMGFormPlacement.FormDestroy(Sender: TObject);
begin
  if Active and not FSaved then
  begin
    FDestroying := True;
    try
      SaveFormPlacement;
    except
      Application.HandleException(Self);
    end;
    FDestroying := False;
  end;
  if Assigned(FSaveFormDestroy) then FSaveFormDestroy(Sender);
end;

procedure TMGFormPlacement.UpdatePlacement;
const
{$IFNDEF DELPHI1}
  Metrics: array[bsSingle..bsSizeToolWin] of Word =
    (SM_CXBORDER, SM_CXFRAME, SM_CXDLGFRAME, SM_CXBORDER, SM_CXFRAME);
{$ELSE}
  Metrics: array[bsSingle..bsDialog] of Word =
    (SM_CXBORDER, SM_CXFRAME, SM_CXDLGFRAME);
{$ENDIF}
var
  Placement: TWindowPlacement;
begin
  if (Owner <> nil) and (Owner is TCustomForm) and Form.HandleAllocated and
    not (csLoading in ComponentState) then
    if not (FPreventResize or CheckMinMaxInfo) then
    begin
      Placement.Length := SizeOf(TWindowPlacement);
      GetWindowPlacement(Form.Handle, @Placement);
      if not IsWindowVisible(Form.Handle) then
        Placement.ShowCmd := SW_HIDE;
      if Form.BorderStyle <> bsNone then
      begin
        Placement.ptMaxPosition.X := -GetSystemMetrics(Metrics[Form.BorderStyle]);
        Placement.ptMaxPosition.Y := -GetSystemMetrics(Metrics[Form.BorderStyle] + 1);
      end
      else Placement.ptMaxPosition := Point(0, 0);
      SetWindowPlacement(Form.Handle, @Placement);
    end;
end;

procedure TMGFormPlacement.UpdatePreventResize;
var
  IsActive: Boolean;
begin
  if not (csDesigning in ComponentState) and (Owner is TCustomForm) then
  begin
    if FPreventResize then
      FDefMaximize := (biMaximize in Form.BorderIcons);
    IsActive := Active;
    Active := False;
    try
      if (not FPreventResize) and FDefMaximize and
        (Form.BorderStyle <> bsDialog) then
        Form.BorderIcons := Form.BorderIcons + [biMaximize]
      else Form.BorderIcons := Form.BorderIcons - [biMaximize];
    finally
      Active := IsActive;
    end;
    if not (csLoading in ComponentState) then CheckToggleHook;
  end;
end;

procedure TMGFormPlacement.SetPreventResize(Value: Boolean);
begin
  if (Form <> nil) and (FPreventResize <> Value) then
  begin
    FPreventResize := Value;
    UpdatePlacement;
    UpdatePreventResize;
  end;
end;

function TMGFormPlacement.GetIniFile: TObject;
begin
{$IFNDEF DELPHI1}
  if UseRegistry then Result := FRegIniFile
  else Result := FIniFile;
{$ELSE}
  Result := FIniFile;
{$ENDIF}
end;

function TMGFormPlacement.GetIniFileName: string;
begin
{$IFDEF DELPHI4_UP}
  Result := FIniFileName;
{$ELSE}
  Result := FIniFileName^;
{$ENDIF}
  if (Result = '') and not (csDesigning in ComponentState) then
  begin
{$IFNDEF DELPHI1}
    if UseRegistry then Result := GetDefaultIniRegKey
    else Result := GetDefaultIniName;
{$ELSE}
    Result := GetDefaultIniName;
{$ENDIF}
  end;
end;

procedure TMGFormPlacement.SetIniFileName(const Value: string);
begin
{$IFDEF DELPHI4_UP}
  FIniFileName := Value;
{$ELSE}
  AssignStr(FIniFileName, Value);
{$ENDIF}
end;

function TMGFormPlacement.GetIniSection: string;
begin
{$IFDEF DELPHI4_UP}
  Result := FIniSection;
{$ELSE}
  Result := FIniSection^;
{$ENDIF}
  if (Result = '') and not (csDesigning in ComponentState) then
    Result := GetDefaultSection(Owner);
end;

procedure TMGFormPlacement.SetIniSection(const Value: string);
begin
{$IFDEF DELPHI4_UP}
  FIniSection := Value;
{$ELSE}
  AssignStr(FIniSection, Value);
{$ENDIF}
end;

procedure TMGFormPlacement.Save;
begin
  if Assigned(FOnSavePlacement) then FOnSavePlacement(Self);
end;

procedure TMGFormPlacement.Restore;
begin
  if Assigned(FOnRestorePlacement) then FOnRestorePlacement(Self);
end;

procedure TMGFormPlacement.SavePlacement;
begin
  if Owner is TCustomForm then
  begin
{$IFNDEF DELPHI1}
    if UseRegistry then
    begin
      if (Options * [fpState, fpPosition] <> []) then
      begin
        WriteFormPlacementReg(Form, FRegIniFile, IniSection);
        FRegIniFile.WriteBool(IniSection, siVisible, FDestroying);
      end;
      if (fpActiveControl in Options) and (Form.ActiveControl <> nil) then
        FRegIniFile.WriteString(IniSection, siActiveCtrl, Form.ActiveControl.Name);
    end
    else
    begin
      if (Options * [fpState, fpPosition] <> []) then
      begin
        WriteFormPlacement(Form, FIniFile, IniSection);
        FIniFile.WriteBool(IniSection, siVisible, FDestroying);
      end;
      if (fpActiveControl in Options) and (Form.ActiveControl <> nil) then
        FIniFile.WriteString(IniSection, siActiveCtrl, Form.ActiveControl.Name);
    end;
{$ELSE}
    if (Options * [fpState, fpPosition] <> []) then
    begin
      WriteFormPlacement(Form, FIniFile, IniSection);
      FIniFile.WriteBool(IniSection, siVisible, FDestroying);
    end;
    if (fpActiveControl in Options) and (Form.ActiveControl <> nil) then
      FIniFile.WriteString(IniSection, siActiveCtrl, Form.ActiveControl.Name);
{$ENDIF}
  end;
  NotifyLinks(poSave);
end;

procedure TMGFormPlacement.RestorePlacement;
begin
  if Owner is TCustomForm then
  begin
{$IFNDEF DELPHI1}
    if UseRegistry then
      ReadFormPlacementReg(Form, FRegIniFile, IniSection, fpState in Options,
        fpPosition in Options)
    else
{$ENDIF}
      ReadFormPlacement(Form, FIniFile, IniSection, fpState in Options,
        fpPosition in Options);
  end;
  NotifyLinks(poRestore);
end;

procedure TMGFormPlacement.IniNeeded(ReadOnly: Boolean);
begin
  if IniFileObject = nil then
  begin
{$IFNDEF DELPHI1}
    if UseRegistry then
    begin
      FRegIniFile := TRegIniFile.Create(IniFileName);
{$IFDEF DELPHI5_UP}
      if ReadOnly then FRegIniFile.Access := KEY_READ;
{$ENDIF}
      case FRegistryRoot of
        prLocalMachine:
          FRegIniFile.RootKey := HKEY_LOCAL_MACHINE;
        prClassesRoot: 
          FRegIniFile.RootKey := HKEY_CLASSES_ROOT;
        prCurrentConfig: 
          FRegIniFile.RootKey := HKEY_CURRENT_CONFIG;
        prUsers: 
          FRegIniFile.RootKey := HKEY_USERS;
        prDynData:
          FRegIniFile.RootKey := HKEY_DYN_DATA;
      end;
      if FRegIniFile.RootKey <> HKEY_CURRENT_USER then
        FRegIniFile.OpenKey(FRegIniFile.FileName, not ReadOnly);
    end
    else
{$ENDIF}
    FIniFile := TIniFile.Create(IniFileName);
  end;
end;

procedure TMGFormPlacement.IniFree;
begin
  if IniFileObject <> nil then
  begin
    IniFileObject.Free;
    FIniFile := nil;
{$IFNDEF DELPHI1}
    FRegIniFile := nil;
{$ENDIF}
  end;
end;

function TMGFormPlacement.DoReadString(const Section, Ident,
  Default: string): string;
begin
  if IniFileObject <> nil then
    Result := IniReadString(IniFileObject, Section, Ident, Default)
  else
  begin
    IniNeeded(True);
    try
      Result := IniReadString(IniFileObject, Section, Ident, Default);
    finally
      IniFree;
    end;
  end;
end;

function TMGFormPlacement.ReadString(const Ident, Default: string): string;
begin
  Result := DoReadString(IniSection, Ident, Default);
end;

procedure TMGFormPlacement.DoWriteString(const Section, Ident, Value: string);
begin
  if IniFileObject <> nil then
    IniWriteString(IniFileObject, Section, Ident, Value)
  else
  begin
    IniNeeded(False);
    try
      IniWriteString(IniFileObject, Section, Ident, Value);
    finally
      IniFree;
    end;
  end;
end;

procedure TMGFormPlacement.WriteString(const Ident, Value: string);
begin
  DoWriteString(IniSection, Ident, Value);
end;

function TMGFormPlacement.ReadInteger(const Ident: string; Default: Longint): Longint;
begin
  if IniFileObject <> nil then
    Result := IniReadInteger(IniFileObject, IniSection, Ident, Default)
  else
  begin
    IniNeeded(True);
    try
      Result := IniReadInteger(IniFileObject, IniSection, Ident, Default);
    finally
      IniFree;
    end;
  end;
end;

procedure TMGFormPlacement.WriteInteger(const Ident: string; Value: Longint);
begin
  if IniFileObject <> nil then
    IniWriteInteger(IniFileObject, IniSection, Ident, Value)
  else
  begin
    IniNeeded(False);
    try
      IniWriteInteger(IniFileObject, IniSection, Ident, Value);
    finally
      IniFree;
    end;
  end;
end;

procedure TMGFormPlacement.EraseSections;
var
  Lines: TStrings;
  I: Integer;
begin
  if IniFileObject = nil then
  begin
    IniNeeded(False);
    try
      Lines := TStringList.Create;
      try
        IniReadSections(IniFileObject, Lines);
        for I := 0 to Lines.Count - 1 do
        begin
          if (Lines[I] = IniSection) or
            (IsWild(Lines[I], IniSection + '.*', False) or
            IsWild(Lines[I], IniSection + '\*', False)) then
            IniEraseSection(IniFileObject, Lines[I]);
        end;
      finally
        Lines.Free;
      end;
    finally
      IniFree;
    end;
  end;
end;

procedure TMGFormPlacement.SaveFormPlacement;
begin
  if FRestored or not Active then
  begin
    IniNeeded(False);
    try
      WriteInteger(siVersion, FVersion);
      SavePlacement;
      Save;
      FSaved := True;
    finally
      IniFree;
    end;
  end;
end;

procedure TMGFormPlacement.RestoreFormPlacement;
var
  cActive: TComponent;
begin
  FSaved := False;
  IniNeeded(True);
  try
    if ReadInteger(siVersion, 0) >= FVersion then
    begin
      RestorePlacement;
      FRestored := True;
      Restore;
      if (fpActiveControl in Options) and (Owner is TCustomForm) then
      begin
        cActive := Form.FindComponent(IniReadString(IniFileObject,
          IniSection, siActiveCtrl, ''));
        if (cActive <> nil) and (cActive is TWinControl) and
          TWinControl(cActive).CanFocus then
            Form.ActiveControl := TWinControl(cActive);
      end;
    end;
    FRestored := True;
  finally
    IniFree;
  end;
  UpdatePlacement;
end;

{ TMGWinMinMaxInfo }

procedure TMGWinMinMaxInfo.Assign(Source: TPersistent);
begin
  if Source is TMGWinMinMaxInfo then
  begin
    FMinMaxInfo := TMGWinMinMaxInfo(Source).FMinMaxInfo;
    if FOwner <> nil then FOwner.MinMaxInfoModified;
  end
  else inherited Assign(Source);
end;

function TMGWinMinMaxInfo.GetMinMaxInfo(Index: Integer): Integer;
begin
  with FMinMaxInfo do
  begin
    case Index of
      0: Result := ptMaxPosition.X;
      1: Result := ptMaxPosition.Y;
      2: Result := ptMaxSize.Y;
      3: Result := ptMaxSize.X;
      4: Result := ptMaxTrackSize.Y;
      5: Result := ptMaxTrackSize.X;
      6: Result := ptMinTrackSize.Y;
      7: Result := ptMinTrackSize.X;
      else Result := 0;
    end;
  end;
end;

procedure TMGWinMinMaxInfo.SetMinMaxInfo(Index: Integer; Value: Integer);
begin
  if GetMinMaxInfo(Index) <> Value then
  begin
    with FMinMaxInfo do
    begin
      case Index of
        0: ptMaxPosition.X := Value;
        1: ptMaxPosition.Y := Value;
        2: ptMaxSize.Y := Value;
        3: ptMaxSize.X := Value;
        4: ptMaxTrackSize.Y := Value;
        5: ptMaxTrackSize.X := Value;
        6: ptMinTrackSize.Y := Value;
        7: ptMinTrackSize.X := Value;
      end;
    end;
    if FOwner <> nil then FOwner.MinMaxInfoModified;
  end;
end;

function TMGWinMinMaxInfo.DefaultMinMaxInfo: Boolean;
begin
  with FMinMaxInfo do
  begin
    Result := not ((ptMinTrackSize.X <> 0) or (ptMinTrackSize.Y <> 0) or
      (ptMaxTrackSize.X <> 0) or (ptMaxTrackSize.Y <> 0) or
      (ptMaxSize.X <> 0) or (ptMaxSize.Y <> 0) or
      (ptMaxPosition.X <> 0) or (ptMaxPosition.Y <> 0));
  end;
end;

{ TMGFormStorage }

constructor TMGFormStorage.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FStoredProps := TStringList.Create;
{$IFDEF DELPHI3_UP}
  FStoredValues := TStoredValues.Create{$IFDEF DELPHI4_UP}(Self){$ENDIF DELPHI4_UP};
  FStoredValues.Storage := Self;
{$ENDIF DELPHI3_UP}
end;

destructor TMGFormStorage.Destroy;
begin
  FStoredProps.Free;
  FStoredProps := nil;
{$IFDEF DELPHI3_UP}
  FStoredValues.Free;
  FStoredValues := nil;
{$ENDIF DELPHI3_UP}
  inherited Destroy;
end;

{$IFNDEF DELPHI1}
procedure TMGFormStorage.SetNotification;
var
  I: Integer;
  Component: TComponent;
begin
  for I := FStoredProps.Count - 1 downto 0 do
  begin
    Component := TComponent(FStoredProps.Objects[I]);
    if Component <> nil then Component.FreeNotification(Self);
  end;
end;
{$ENDIF}

procedure TMGFormStorage.SetStoredProps(Value: TStrings);
begin
  FStoredProps.Assign(Value);
{$IFNDEF DELPHI1}
  SetNotification;
{$ENDIF}
end;

{$IFDEF DELPHI3_UP}
procedure TMGFormStorage.SetStoredValues(Value: TStoredValues);
begin
  FStoredValues.Assign(Value);
end;

function TMGFormStorage.GetStoredValue(const Name: string): Variant;
begin
  Result := StoredValues.StoredValue[Name];
end;

procedure TMGFormStorage.SetStoredValue(const Name: string; Value: Variant);
begin
  StoredValues.StoredValue[Name] := Value;
end;
{$ENDIF DELPHI3_UP}

procedure TMGFormStorage.Loaded;
begin
  inherited Loaded;
  UpdateStoredList(Owner, FStoredProps, True);
end;

procedure TMGFormStorage.WriteState(Writer: TWriter);
begin
  UpdateStoredList(Owner, FStoredProps, False);
  inherited WriteState(Writer);
end;

procedure TMGFormStorage.Notification(AComponent: TComponent; Operation: TOperation);
var
  I: Integer;
  Component: TComponent;
begin
  inherited Notification(AComponent, Operation);
  if not (csDestroying in ComponentState) and (Operation = opRemove) and
    (FStoredProps <> nil) then
    for I := FStoredProps.Count - 1 downto 0 do
    begin
      Component := TComponent(FStoredProps.Objects[I]);
      if Component = AComponent then FStoredProps.Delete(I);
    end;
end;

procedure TMGFormStorage.SaveProperties;
begin
  with TPropsStorage.Create do
  try
    Section := IniSection;
    OnWriteString := DoWriteString;
{$IFNDEF DELPHI1}
    if UseRegistry then OnEraseSection := FRegIniFile.EraseSection
    else OnEraseSection := FIniFile.EraseSection;
{$ELSE}
    OnEraseSection := FIniFile.EraseSection;
{$ENDIF}
    StoreObjectsProps(Owner, FStoredProps);
  finally
    Free;
  end;
end;

procedure TMGFormStorage.RestoreProperties;
begin
  with TPropsStorage.Create do
  try
    Section := IniSection;
    OnReadString := DoReadString;
    try
      LoadObjectsProps(Owner, FStoredProps);
    except
      { ignore any exceptions }
    end;
  finally
    Free;
  end;
end;

procedure TMGFormStorage.SavePlacement;
begin
  inherited SavePlacement;
  SaveProperties;
{$IFDEF DELPHI3_UP}
  StoredValues.SaveValues;
{$ENDIF}
end;

procedure TMGFormStorage.RestorePlacement;
begin
  inherited RestorePlacement;
  FRestored := True;
  RestoreProperties;
{$IFDEF DELPHI3_UP}
  StoredValues.RestoreValues;
{$ENDIF}
end;

{ TIniLink }

destructor TIniLink.Destroy;
begin
  if Assigned(FOnIniLinkDestroy) then
    FOnIniLinkDestroy(Self);
  FOnSave := nil;
  FOnLoad := nil;
  SetStorage(nil);
  inherited Destroy;
end;

function TIniLink.GetIniObject: TObject;
begin
  if Assigned(FStorage) then Result := FStorage.IniFileObject
  else Result := nil;
end;

function TIniLink.GetRootSection: string;
begin
  if Assigned(FStorage) then
{$IFDEF DELPHI4_UP}
    Result := FStorage.FIniSection
{$ELSE}
    Result := FStorage.FIniSection^
{$ENDIF}
  else Result := '';
  if Result <> '' then Result := Result + {$IFDEF DELPHI6_UP}PathDelim{$ELSE}'\'{$ENDIF};
end;

procedure TIniLink.SetStorage(Value: TMGFormPlacement);
begin
  if FStorage <> Value then
  begin
    if FStorage <> nil then FStorage.RemoveLink(Self);
    if Value <> nil then Value.AddLink(Self);
  end;
end;

procedure TIniLink.SaveToIni;
begin
  if Assigned(FOnSave) then FOnSave(Self);
end;

procedure TIniLink.LoadFromIni;
begin
  if Assigned(FOnLoad) then FOnLoad(Self);
end;

{$IFDEF DELPHI3_UP}

{ TStoredValue }

constructor TStoredValue.Create(Collection: TCollection);
begin
  inherited Create(Collection);
  FValue := Unassigned;
end;

procedure TStoredValue.Assign(Source: TPersistent);
begin
  if (Source is TStoredValue) and (Source <> nil) then
  begin
    if VarIsEmpty(TStoredValue(Source).FValue) then
      Clear
    else
      Value := TStoredValue(Source).FValue;
    Name := TStoredValue(Source).Name;
    KeyString := TStoredValue(Source).KeyString;
  end;
end;

function TStoredValue.GetDisplayName: string;
begin
  if FName = '' then
    Result := inherited GetDisplayName
  else
    Result := FName;
end;

procedure TStoredValue.SetDisplayName(const Value: string);
begin
  if (Value <> '') and (AnsiCompareText(Value, FName) <> 0) and
    (Collection is TStoredValues) and (TStoredValues(Collection).IndexOf(Value) >= 0) then
    raise Exception.Create(SDuplicateString);
  FName := Value;
  inherited;
end;

function TStoredValue.GetStoredValues: TStoredValues;
begin
  if Collection is TStoredValues then
    Result := TStoredValues(Collection)
  else
    Result := nil;
end;

procedure TStoredValue.Clear;
begin
  FValue := Unassigned;
end;

function TStoredValue.IsValueStored: Boolean;
begin
  Result := not VarIsEmpty(FValue);
end;

procedure TStoredValue.Save;
var
  SaveValue: Variant;
  SaveStrValue: string;
begin
  SaveValue := Value;
  if Assigned(FOnSave) then
    FOnSave(Self, SaveValue);
  SaveStrValue := VarToStr(SaveValue);
  if KeyString <> '' then
    SaveStrValue := string(XorEncode(KeyString, AnsiString(SaveStrValue)));
  StoredValues.Storage.WriteString(Name, SaveStrValue);
end;

procedure TStoredValue.Restore;
var
  RestoreValue: Variant;
  RestoreStrValue, DefaultStrValue: string;
begin
  DefaultStrValue := VarToStr(Value);
  if KeyString <> '' then
    DefaultStrValue := string(XorEncode(KeyString, AnsiString(DefaultStrValue)));
  RestoreStrValue := StoredValues.Storage.ReadString(Name, DefaultStrValue);
  if KeyString <> '' then
    RestoreStrValue := string(XorDecode(KeyString, AnsiString(RestoreStrValue)));
  RestoreValue := RestoreStrValue;
  if Assigned(FOnRestore) then
    FOnRestore(Self, RestoreValue);
  Value := RestoreValue;  
end;

{ TStoredValues }

{$IFDEF DELPHI4_UP}
constructor TStoredValues.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner, TStoredValue);
end;
{$ELSE}
constructor TStoredValues.Create;
begin
  inherited Create(TStoredValue);
end;
{$ENDIF}

function TStoredValues.IndexOf(const Name: string): Integer;
begin
  for Result := 0 to Count - 1 do
    if AnsiCompareText(Items[Result].Name, Name) = 0 then Exit;
  Result := -1;
end;

function TStoredValues.GetItem(Index: Integer): TStoredValue;
begin
  Result := TStoredValue(inherited Items[Index]);
end;

procedure TStoredValues.SetItem(Index: Integer; StoredValue: TStoredValue);
begin
  inherited SetItem(Index, TCollectionItem(StoredValue));
end;

function TStoredValues.GetStoredValue(const Name: string): Variant;
var
  StoredValue: TStoredValue;
begin
  StoredValue := GetValue(Name);
  if StoredValue = nil then Result := Null
  else Result := StoredValue.Value;
end;

procedure TStoredValues.SetStoredValue(const Name: string; Value: Variant);
var
  StoredValue: TStoredValue;
begin
  StoredValue := GetValue(Name);
  if StoredValue = nil then
  begin
    StoredValue := TStoredValue(Add);
    StoredValue.Name := Name; 
    StoredValue.Value := Value;
  end
  else StoredValue.Value := Value;
end;

function TStoredValues.GetValue(const Name: string): TStoredValue;
var
  I: Integer;
begin
  I := IndexOf(Name);
  if I < 0 then
    Result := nil
  else
    Result := Items[I];
end;

procedure TStoredValues.SetValue(const Name: string; StoredValue: TStoredValue);
var
  I: Integer;
begin
  I := IndexOf(Name);
  if I >= 0 then
    Items[I].Assign(StoredValue);
end;

procedure TStoredValues.SaveValues;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    Items[I].Save;
end;

procedure TStoredValues.RestoreValues;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    Items[I].Restore;
end;

{$ENDIF DELPHI3_UP}

{$IFNDEF DELPHI1}
function GetDefaultIniRegKey: string;
begin
  if RegUseAppTitle and (Application.Title <> '') then
    Result := Application.Title
  else Result := ExtractFileName(ChangeFileExt(Application.ExeName, ''));
  if DefCompanyName <> '' then
    Result := DefCompanyName + '\' + Result;
  Result := 'Software\' + Result;
end;
{$ENDIF}

function GetDefaultIniName: string;
begin
  if Assigned(OnGetDefaultIniName) then
    Result:= OnGetDefaultIniName
  else
    Result := ExtractFileName(ChangeFileExt(Application.ExeName, '.INI'));
end;

function GetDefaultSection(Component: TComponent): string;
var
  F: TCustomForm;
  Owner: TComponent;
begin
  if Component <> nil then begin
    if Component is TCustomForm then Result := Component.ClassName
    else begin
      Result := Component.Name;
      if Component is TControl then begin
        F := GetParentForm(TControl(Component));
        if F <> nil then Result := F.ClassName + Result
        else begin
          if TControl(Component).Parent <> nil then
            Result := TControl(Component).Parent.Name + Result;
        end;
      end
      else begin
        Owner := Component.Owner;
        if Owner is TForm then
          Result := Format('%s.%s', [Owner.ClassName, Result]);
      end;
    end;
  end
  else Result := '';
end;

{$IFNDEF DELPHI1}
procedure WriteFormPlacementReg(Form: TForm; IniFile: TRegIniFile;
  const Section: string);
begin
  InternalWriteFormPlacement(Form, IniFile, Section);
end;

procedure ReadFormPlacementReg(Form: TForm; IniFile: TRegIniFile;
  const Section: string; LoadState, LoadPosition: Boolean);
begin
  InternalReadFormPlacement(Form, IniFile, Section, LoadState, LoadPosition);
end;
{$ENDIF}

procedure IniWriteInteger(IniFile: TObject; const Section, Ident: string;
  Value: Longint);
begin
{$IFNDEF DELPHI1}
  if IniFile is TRegIniFile then
    TRegIniFile(IniFile).WriteInteger(Section, Ident, Value)
  else
{$ENDIF}
  if IniFile is TIniFile then
    TIniFile(IniFile).WriteInteger(Section, Ident, Value);
end;

function IniReadInteger(IniFile: TObject; const Section, Ident: string;
  Default: Longint): Longint;
begin
{$IFNDEF DELPHI1}
  if IniFile is TRegIniFile then
    Result := TRegIniFile(IniFile).ReadInteger(Section, Ident, Default)
  else
{$ENDIF}
  if IniFile is TIniFile then
    Result := TIniFile(IniFile).ReadInteger(Section, Ident, Default)
  else Result := Default;
end;

procedure InternalWriteFormPlacement(Form: TForm; IniFile: TObject;
  const Section: string);
var
  Placement: TWindowPlacement;
begin
  Placement.Length := SizeOf(TWindowPlacement);
  GetWindowPlacement(Form.Handle, @Placement);
  with Placement, TForm(Form) do begin
    if (Form = Application.MainForm) and IsIconic(Application.Handle) then
      ShowCmd := SW_SHOWMINIMIZED;
    if (FormStyle = fsMDIChild) and (WindowState = wsMinimized) then
      Flags := Flags or WPF_SETMINPOSITION;
    IniWriteInteger(IniFile, Section, siFlags, Flags);
    IniWriteInteger(IniFile, Section, siShowCmd, ShowCmd);
    IniWriteInteger(IniFile, Section, siPixels, Screen.PixelsPerInch);
    WritePosStr(IniFile, Section, siMinMaxPos, Format('%d,%d,%d,%d',
      [ptMinPosition.X, ptMinPosition.Y, ptMaxPosition.X, ptMaxPosition.Y]));
    WritePosStr(IniFile, Section, siNormPos, Format('%d,%d,%d,%d',
      [rcNormalPosition.Left, rcNormalPosition.Top, rcNormalPosition.Right,
      rcNormalPosition.Bottom]));
  end;
end;

procedure InternalReadFormPlacement(Form: TForm; IniFile: TObject;
  const Section: string; LoadState, LoadPosition: Boolean);
const
  Delims = [',',' '];
var
  PosStr: string;
  Placement: TWindowPlacement;
  WinState: TWindowState;
  DataFound: Boolean;
begin
  if not (LoadState or LoadPosition) then Exit;
  Placement.Length := SizeOf(TWindowPlacement);
  GetWindowPlacement(Form.Handle, @Placement);
  with Placement, TForm(Form) do begin
    if not IsWindowVisible(Form.Handle) then
      ShowCmd := SW_HIDE;
    if LoadPosition then begin
      DataFound := False;
      Flags := IniReadInteger(IniFile, Section, siFlags, Flags);
      PosStr := ReadPosStr(IniFile, Section, siMinMaxPos);
      if PosStr <> '' then begin
        DataFound := True;
        ptMinPosition.X := StrToIntDef(ExtractWord(1, PosStr, Delims), 0);
        ptMinPosition.Y := StrToIntDef(ExtractWord(2, PosStr, Delims), 0);
        ptMaxPosition.X := StrToIntDef(ExtractWord(3, PosStr, Delims), 0);
        ptMaxPosition.Y := StrToIntDef(ExtractWord(4, PosStr, Delims), 0);
      end;
      PosStr := ReadPosStr(IniFile, Section, siNormPos);
      if PosStr <> '' then begin
        DataFound := True;
        rcNormalPosition.Left := StrToIntDef(ExtractWord(1, PosStr, Delims), Left);
        rcNormalPosition.Top := StrToIntDef(ExtractWord(2, PosStr, Delims), Top);
        rcNormalPosition.Right := StrToIntDef(ExtractWord(3, PosStr, Delims), Left + Width);
        rcNormalPosition.Bottom := StrToIntDef(ExtractWord(4, PosStr, Delims), Top + Height);
      end;
      if Screen.PixelsPerInch <> IniReadInteger(IniFile, Section, siPixels,
        Screen.PixelsPerInch) then DataFound := False;
      if DataFound then begin
        if not (BorderStyle in [bsSizeable {$IFNDEF DELPHI1}, bsSizeToolWin {$ENDIF}]) then
          rcNormalPosition := Rect(rcNormalPosition.Left, rcNormalPosition.Top,
            rcNormalPosition.Left + Width, rcNormalPosition.Top + Height);
        if rcNormalPosition.Right > rcNormalPosition.Left then begin
          if (Position in [poScreenCenter {$IFDEF DELPHI4_UP}, poDesktopCenter {$ENDIF}]) and
            not (csDesigning in ComponentState) then
          begin
            THackComponent(Form).SetDesigning(True);
            try
              Position := poDesigned;
            finally
              THackComponent(Form).SetDesigning(False);
            end;
          end;
          SetWindowPlacement(Handle, @Placement);
        end;
      end;
    end;
    if LoadState then begin
      WinState := wsNormal;
      { default maximize MDI main form }
      if ((Application.MainForm = Form) {$IFDEF DELPHI4_UP} or
        (Application.MainForm = nil) {$ENDIF}) and ((FormStyle = fsMDIForm) or
        ((FormStyle = fsNormal) and (Position = poDefault))) then
        WinState := wsMaximized;
      ShowCmd := IniReadInteger(IniFile, Section, siShowCmd, SW_HIDE);
      case ShowCmd of
        SW_SHOWNORMAL, SW_RESTORE, SW_SHOW:
          WinState := wsNormal;
        SW_MINIMIZE, SW_SHOWMINIMIZED, SW_SHOWMINNOACTIVE:
          WinState := wsMinimized;
        SW_MAXIMIZE: WinState := wsMaximized;
      end;
{$IFNDEF DELPHI1}
      if (WinState = wsMinimized) and ((Form = Application.MainForm)
        {$IFDEF DELPHI4_UP} or (Application.MainForm = nil) {$ENDIF}) then
      begin
        TNastyForm(Form).FWindowState := wsNormal;
        PostMessage(Application.Handle, WM_SYSCOMMAND, SC_MINIMIZE, 0);
        Exit;
      end;
{$ENDIF}
      if FormStyle in [fsMDIChild, fsMDIForm] then
        TNastyForm(Form).FWindowState := WinState
      else WindowState := WinState;
    end;
    Update;
  end;
end;

procedure WritePosStr(IniFile: TObject; const Section, Ident, Value: string);
begin
  IniWriteString(IniFile, Section, Ident + CrtResString, Value);
  IniWriteString(IniFile, Section, Ident, Value);
end;

function ReadPosStr(IniFile: TObject; const Section, Ident: string): string;
begin
  Result := IniReadString(IniFile, Section, Ident + CrtResString, '');
  if Result = '' then Result := IniReadString(IniFile, Section, Ident, '');
end;

procedure IniWriteString(IniFile: TObject; const Section, Ident,
  Value: string);
var
  S: string;
begin
{$IFNDEF DELPHI1}
  if IniFile is TRegIniFile then
    TRegIniFile(IniFile).WriteString(Section, Ident, Value)
  else begin
{$ENDIF}
    S := Value;
    if S <> '' then begin
      if ((S[1] = '"') and (S[Length(S)] = '"')) or
        ((S[1] = '''') and (S[Length(S)] = '''')) then
        S := '"' + S + '"';
    end;
    if IniFile is TIniFile then
      TIniFile(IniFile).WriteString(Section, Ident, S);
{$IFNDEF DELPHI1}
  end;
{$ENDIF}
end;

function CrtResString: string;
begin
  Result := Format('(%dx%d)', [GetSystemMetrics(SM_CXSCREEN),
    GetSystemMetrics(SM_CYSCREEN)]);
end;

procedure WriteFormPlacement(Form: TForm; IniFile: TIniFile;
  const Section: string);
begin
  InternalWriteFormPlacement(Form, IniFile, Section);
end;

function IniReadString(IniFile: TObject; const Section, Ident,
  Default: string): string;
begin
{$IFNDEF DELPHI1}
  if IniFile is TRegIniFile then
    Result := TRegIniFile(IniFile).ReadString(Section, Ident, Default)
  else
{$ENDIF}
  if IniFile is TIniFile then
    Result := TIniFile(IniFile).ReadString(Section, Ident, Default)
  else Result := Default;
end;

procedure ReadFormPlacement(Form: TForm; IniFile: TIniFile;
  const Section: string; LoadState, LoadPosition: Boolean);
begin
  InternalReadFormPlacement(Form, IniFile, Section, LoadState, LoadPosition);
end;

procedure IniReadSections(IniFile: TObject; Strings: TStrings);
begin
{$IFNDEF DELPHI1}
  if IniFile is TIniFile then
    TIniFile(IniFile).ReadSections(Strings)
  else if IniFile is TRegIniFile then
    TRegIniFile(IniFile).ReadSections(Strings);
{$ELSE}
  if IniFile is TIniFile then
    IniFileReadSections(TIniFile(IniFile), Strings);
{$ENDIF}
end;

procedure IniEraseSection(IniFile: TObject; const Section: string);
begin
{$IFNDEF DELPHI1}
  if IniFile is TRegIniFile then
    TRegIniFile(IniFile).EraseSection(Section)
  else
{$ENDIF}
  if IniFile is TIniFile then
    TIniFile(IniFile).EraseSection(Section);
end;

end.
