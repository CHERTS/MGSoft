{ ############################################################################ }
{ #                                                                          # }
{ #  MGSoft Delphi Components v1.0.0                                         # }
{ #                                                                          # }
{ #  MGTrayIcon v1.0.0 - Сворачивание программы в систрей                    # }
{ #                                                                          # }
{ #  License: GPLv3                                                          # }
{ #                                                                          # }
{ #  Author: Mikhail Grigorev (icq: 161867489, email: sleuthhound@gmail.com) # }
{ #                                                                          # }
{ ############################################################################ }

unit MGTrayIcon;

{$I MGSoft.inc}
{$T-}

{ I tried to hack around the problem that in some versions of NT4 the tray icon
  will not display properly upon logging off, then logging on. It appears to be
  a VCL problem. The solution is probably to substitute Delphi's AllocateHWnd
  method, but I haven't gotten around to experimenting with that.
  For now, leave WINNT_SERVICE_HACK undefined (no special NT handling). }
{$UNDEF WINNT_SERVICE_HACK}

interface

uses
{$IFDEF HAS_UNITSCOPE}
  {$IFDEF MSWINDOWS}
  Winapi.Windows, Winapi.Messages,
  {$ENDIF MSWINDOWS}
  System.Classes, System.SysUtils,
  {$IFDEF HAS_VCL}
  Vcl.Controls, Vcl.Forms, Vcl.Graphics, Vcl.ExtCtrls, Vcl.Menus,
  {$IFDEF DELPHI4_UP}Vcl.ImgList,{$ENDIF}
  {$ELSE}
  FMX.Controls, FMX.Forms, FMX.Graphics, FMX.ExtCtrls, FMX.Menus,
  {$IFDEF DELPHI4_UP}FMX.ImgList,{$ENDIF}
  {$ENDIF}
{$ELSE ~HAS_UNITSCOPE}
  {$IFDEF MSWINDOWS}
  Windows,
  {$ENDIF MSWINDOWS}
  {$IFNDEF FPC}Messages,{$ENDIF FPC}
  Classes, SysUtils, Controls, Forms, Graphics, ExtCtrls, Menus,
  {$IFDEF DELPHI4_UP}ImgList,{$ENDIF}
{$ENDIF ~HAS_UNITSCOPE}
  ShellApi,  MGSimpleTimer;

const
  // User-defined message sent by the trayicon
  WM_TRAYNOTIFY = WM_USER + 1024;

type
  TTimeoutOrVersion = record
    case Integer of          // 0: Before Win2000; 1: Win2000 and up
      0: (uTimeout: UINT);
      1: (uVersion: UINT);   // Only used when sending a NIM_SETVERSION message
  end;

{$IFDEF UNICODE}
  TNotifyIconDataEx = record
    cbSize: DWORD;
    hWnd: HWND;
    uID: UINT;
    uFlags: UINT;
    uCallbackMessage: UINT;
    hIcon: HICON;
    szTip: array [0..127] of WideChar;
    dwState: DWORD;
    dwStateMask: DWORD;
    szInfo: array [0..255] of WideChar;
    TimeoutOrVersion: TTimeoutOrVersion;
    szInfoTitle: array [0..63] of WideChar;
    dwInfoFlags: DWORD;
{$IFDEF _WIN32_IE_600}
    guidItem: TGUID;
{$ENDIF _WIN32_IE_600}
  end;
{$ELSE}
  TNotifyIconDataEx = record
    cbSize: DWORD;
    hWnd: HWND;
    uID: UINT;
    uFlags: UINT;
    uCallbackMessage: UINT;
    hIcon: HICON;
    szTip: array[0..127] of AnsiChar;
    dwState: DWORD;
    dwStateMask: DWORD;
    szInfo: array[0..255] of AnsiChar;
    TimeoutOrVersion: TTimeoutOrVersion;
    szInfoTitle: array[0..63] of AnsiChar;
    dwInfoFlags: DWORD;
{$IFDEF _WIN32_IE_600}
    guidItem: TGUID;
{$ENDIF _WIN32_IE_600}
{$IFDEF _NTDDI_VISTA}
    HICON hBalloonIcon;
{$ENDIF _NTDDI_VISTA}
  end;
{$ENDIF UNICODE}

  TBalloonHintIcon = (bitNone, bitInfo, bitWarning, bitError, bitCustom);
  TBalloonHintTimeOut = 10..60;
  TBehavior = (bhWin95, bhWin2000);
  THintString = String;

  TCycleEvent = procedure(Sender: TObject; NextIndex: Integer) of object;
  TStartupEvent = procedure(Sender: TObject; var ShowMainForm: Boolean) of object;

  TMGTrayIcon = class(TComponent)
  private
    FEnabled: Boolean;
    FIcon: TIcon;
    FIconID: Cardinal;
    FIconVisible: Boolean;
    FHint: THintString;
    FShowHint: Boolean;
    FPopupMenu: TPopupMenu;
    FLeftPopup: Boolean;
    FOnClick,
    FOnDblClick: TNotifyEvent;
    FOnCycle: TCycleEvent;
    FOnStartup: TStartupEvent;
    FOnMouseDown,
    FOnMouseUp: TMouseEvent;
    FOnMouseMove: TMouseMoveEvent;
    FOnMouseEnter: TNotifyEvent;
    FOnMouseExit: TNotifyEvent;
    FOnMinimizeToTray: TNotifyEvent;
    FOnBalloonHintShow,
    FOnBalloonHintHide,
    FOnBalloonHintTimeout,
    FOnBalloonHintClick: TNotifyEvent;
    FMinimizeToTray: Boolean;
    FClickStart: Boolean;
    FClickReady: Boolean;
    CycleTimer: TSimpleTimer;
    ClickTimer: TSimpleTimer;
    ExitTimer: TSimpleTimer;
    LastMoveX, LastMoveY: Integer;
    FDidExit: Boolean;
    FWantEnterExitEvents: Boolean;
    FBehavior: TBehavior;
    IsDblClick: Boolean;
    FIconIndex: Integer;
    FDesignPreview: Boolean;
    SettingPreview: Boolean;
    SettingMDIForm: Boolean;
{$IFDEF DELPHI4_UP}
    FIconList: TCustomImageList;
{$ELSE}
    FIconList: TImageList;
{$ENDIF}
    FCycleIcons: Boolean;
    FCycleInterval: Cardinal;
    OldWndProc, NewWndProc: Pointer;
    procedure SetDesignPreview(Value: Boolean);
    procedure SetCycleIcons(Value: Boolean);
    procedure SetCycleInterval(Value: Cardinal);
    function InitIcon: Boolean;
    procedure SetIcon(Value: TIcon);
    procedure SetIconVisible(Value: Boolean);
{$IFDEF DELPHI4_UP}
    procedure SetIconList(Value: TCustomImageList);
{$ELSE}
    procedure SetIconList(Value: TImageList);
{$ENDIF}
    procedure SetIconIndex(Value: Integer);
    procedure SetHint(Value: THintString);
    procedure SetShowHint(Value: Boolean);
    procedure SetWantEnterExitEvents(Value: Boolean);
    procedure SetBehavior(Value: TBehavior);
    procedure IconChanged(Sender: TObject);
{$IFDEF WINNT_SERVICE_HACK}
    function IsWinNT: Boolean;
{$ENDIF}
    function HookAppProc(var Msg: TMessage): Boolean;
    procedure HookForm;
    procedure UnhookForm;
    procedure HookFormProc(var Msg: TMessage);
    procedure ClickTimerProc(Sender: TObject);
    procedure CycleTimerProc(Sender: TObject);
    procedure MouseExitTimerProc(Sender: TObject);
  protected
    IconData: TNotifyIconDataEx;
    procedure Loaded; override;
    function LoadDefaultIcon: Boolean; virtual;
    function ShowIcon: Boolean; virtual;
    function HideIcon: Boolean; virtual;
    function ModifyIcon: Boolean; virtual;
    procedure Click; dynamic;
    procedure DblClick; dynamic;
    procedure CycleIcon; dynamic;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); dynamic;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); dynamic;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); dynamic;
    procedure MouseEnter; dynamic;
    procedure MouseExit; dynamic;
    procedure DoMinimizeToTray; dynamic;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    property Handle: HWND read IconData.hWnd;
    property Behavior: TBehavior read FBehavior write SetBehavior default bhWin95;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function Refresh: Boolean;
    function ShowBalloonHint(Title, Text: String; IconType: TBalloonHintIcon;
      TimeoutSecs: TBalloonHintTimeOut): Boolean;
    function ShowBalloonHintUnicode(Title, Text: WideString; IconType: TBalloonHintIcon;
      TimeoutSecs: TBalloonHintTimeOut): Boolean;
    function HideBalloonHint: Boolean;
    procedure Popup(X, Y: Integer);
    procedure PopupAtCursor;
    function BitmapToIcon(const Bitmap: TBitmap; const Icon: TIcon;
      MaskColor: TColor): Boolean;
    function GetClientIconPos(X, Y: Integer): TPoint;
    function GetTooltipHandle: HWND;
    function GetBalloonHintHandle: HWND;
    function SetFocus: Boolean;
    procedure HideTaskbarIcon;
    procedure ShowTaskbarIcon;
    procedure ShowMainForm;
    procedure HideMainForm;
  published
    property DesignPreview: Boolean read FDesignPreview write SetDesignPreview
      default False;
{$IFDEF DELPHI4_UP}
    property IconList: TCustomImageList read FIconList write SetIconList;
{$ELSE}
    property IconList: TImageList read FIconList write SetIconList;
{$ENDIF}
    property CycleIcons: Boolean read FCycleIcons write SetCycleIcons
      default False;
    property CycleInterval: Cardinal read FCycleInterval write SetCycleInterval;
    property Enabled: Boolean read FEnabled write FEnabled default True;
    property Hint: THintString read FHint write SetHint;
    property ShowHint: Boolean read FShowHint write SetShowHint default True;
    property Icon: TIcon read FIcon write SetIcon;
    property IconVisible: Boolean read FIconVisible write SetIconVisible
      default False;
    property IconIndex: Integer read FIconIndex write SetIconIndex;
    property PopupMenu: TPopupMenu read FPopupMenu write FPopupMenu;
    property LeftPopup: Boolean read FLeftPopup write FLeftPopup default False;
    property WantEnterExitEvents: Boolean read FWantEnterExitEvents
      write SetWantEnterExitEvents default False;
    property MinimizeToTray: Boolean read FMinimizeToTray write FMinimizeToTray
      default False;
    property OnClick: TNotifyEvent read FOnClick write FOnClick;
    property OnDblClick: TNotifyEvent read FOnDblClick write FOnDblClick;
    property OnMouseDown: TMouseEvent read FOnMouseDown write FOnMouseDown;
    property OnMouseUp: TMouseEvent read FOnMouseUp write FOnMouseUp;
    property OnMouseMove: TMouseMoveEvent read FOnMouseMove write FOnMouseMove;
    property OnMouseEnter: TNotifyEvent read FOnMouseEnter write FOnMouseEnter;
    property OnMouseExit: TNotifyEvent read FOnMouseExit write FOnMouseExit;
    property OnCycle: TCycleEvent read FOnCycle write FOnCycle;
    property OnBalloonHintShow: TNotifyEvent read FOnBalloonHintShow
      write FOnBalloonHintShow;
    property OnBalloonHintHide: TNotifyEvent read FOnBalloonHintHide
      write FOnBalloonHintHide;
    property OnBalloonHintTimeout: TNotifyEvent read FOnBalloonHintTimeout
      write FOnBalloonHintTimeout;
    property OnBalloonHintClick: TNotifyEvent read FOnBalloonHintClick
      write FOnBalloonHintClick;
    property OnMinimizeToTray: TNotifyEvent read FOnMinimizeToTray
      write FOnMinimizeToTray;
    property OnStartup: TStartupEvent read FOnStartup write FOnStartup;
  end;

implementation

{$IFDEF DELPHI4_UP}
uses
  {$IFDEF HAS_UNITSCOPE}
  Vcl.ComCtrls;
  {$ELSE ~HAS_UNITSCOPE}
  ComCtrls;
  {$ENDIF ~HAS_UNITSCOPE}
{$ENDIF}

const
  // Key select events (Space and Enter)
  NIN_SELECT           = WM_USER + 0;
  NINF_KEY             = 1;
  NIN_KEYSELECT        = NINF_KEY or NIN_SELECT;
  // Events returned by balloon hint
  NIN_BALLOONSHOW      = WM_USER + 2;
  NIN_BALLOONHIDE      = WM_USER + 3;
  NIN_BALLOONTIMEOUT   = WM_USER + 4;
  NIN_BALLOONUSERCLICK = WM_USER + 5;
  // Constants used for balloon hint feature
  NIIF_NONE            = $00000000;
  NIIF_INFO            = $00000001;
  NIIF_WARNING         = $00000002;
  NIIF_ERROR           = $00000003;
  NIIF_USER            = $00000004;
  NIIF_ICON_MASK       = $0000000F;    // Reserved for WinXP
  NIIF_NOSOUND         = $00000010;    // Reserved for WinXP
  // uFlags constants for TNotifyIconDataEx
  NIF_STATE            = $00000008;
  NIF_INFO             = $00000010;
  NIF_GUID             = $00000020;
  // dwMessage constants for Shell_NotifyIcon
  NIM_SETFOCUS         = $00000003;
  NIM_SETVERSION       = $00000004;
  NOTIFYICON_VERSION   = 3;            // Used with the NIM_SETVERSION message
  // Tooltip constants
  TOOLTIPS_CLASS       = 'tooltips_class32';
  TTS_NOPREFIX         = 2;

type
  TTrayIconHandler = class(TObject)
  private
    RefCount: Cardinal;
    FHandle: HWND;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Add;
    procedure Remove;
    procedure HandleIconMessage(var Msg: TMessage);
  end;

var
  TrayIconHandler: TTrayIconHandler = nil;
{$IFDEF WINNT_SERVICE_HACK}
  WinNT: Boolean = False;              // For Win NT
  HComCtl32: Cardinal = $7FFFFFFF;     // For Win NT
{$ENDIF}
  WM_TASKBARCREATED: Cardinal;
{$IFDEF DELPHI4_UP}
  SHELL_VERSION: Integer;
{$ENDIF}

{ TTrayIconHandler }

constructor TTrayIconHandler.Create;
begin
  inherited Create;
  RefCount := 0;
  FHandle := AllocateHWnd(HandleIconMessage);
end;

destructor TTrayIconHandler.Destroy;
begin
  DeallocateHWnd(FHandle);
  inherited Destroy;
end;

procedure TTrayIconHandler.Add;
begin
  Inc(RefCount);
end;

procedure TTrayIconHandler.Remove;
begin
  if RefCount > 0 then
    Dec(RefCount);
end;

procedure TTrayIconHandler.HandleIconMessage(var Msg: TMessage);

  function ShiftState: TShiftState;
  begin
    Result := [];
    if GetAsyncKeyState(VK_SHIFT) < 0 then
      Include(Result, ssShift);
    if GetAsyncKeyState(VK_CONTROL) < 0 then
      Include(Result, ssCtrl);
    if GetAsyncKeyState(VK_MENU) < 0 then
      Include(Result, ssAlt);
  end;

var
  Pt: TPoint;
  Shift: TShiftState;
  I: Integer;
  M: TMenuItem;
{$IFDEF WINNT_SERVICE_HACK}
  InitComCtl32: procedure;
{$ENDIF}
begin
  if Msg.Msg = WM_TRAYNOTIFY then
  begin
{$WARNINGS OFF}
    with TMGTrayIcon(Msg.wParam) do
{$WARNINGS ON}
    begin
      case Msg.lParam of

        WM_MOUSEMOVE:
          if FEnabled then
          begin
            if FWantEnterExitEvents then
              if FDidExit then
              begin
                MouseEnter;
                FDidExit := False;
              end;
            Shift := ShiftState;
            GetCursorPos(Pt);
            MouseMove(Shift, Pt.x, Pt.y);
            LastMoveX := Pt.x;
            LastMoveY := Pt.y;
          end;

        WM_LBUTTONDOWN:
          if FEnabled then
          begin
            if Assigned(FOnDblClick) then
            begin
              ClickTimer.Interval := GetDoubleClickTime;
              ClickTimer.Enabled := True;
            end;
            Shift := ShiftState + [ssLeft];
            GetCursorPos(Pt);
            MouseDown(mbLeft, Shift, Pt.x, Pt.y);
            FClickStart := True;
            if FLeftPopup then
              if (Assigned(FPopupMenu)) and (FPopupMenu.AutoPopup) then
              begin
                SetForegroundWindow(TrayIconHandler.FHandle);
                PopupAtCursor;
              end;
          end;

        WM_RBUTTONDOWN:
          if FEnabled then
          begin
            Shift := ShiftState + [ssRight];
            GetCursorPos(Pt);
            MouseDown(mbRight, Shift, Pt.x, Pt.y);
            if (Assigned(FPopupMenu)) and (FPopupMenu.AutoPopup) then
            begin
              SetForegroundWindow(TrayIconHandler.FHandle);
              PopupAtCursor;
            end;
          end;

        WM_MBUTTONDOWN:
          if FEnabled then
          begin
            Shift := ShiftState + [ssMiddle];
            GetCursorPos(Pt);
            MouseDown(mbMiddle, Shift, Pt.x, Pt.y);
          end;

        WM_LBUTTONUP:
          if FEnabled then
          begin
            Shift := ShiftState + [ssLeft];
            GetCursorPos(Pt);
            if FClickStart then
              FClickReady := True;
            if FClickStart and (not ClickTimer.Enabled) then
            begin
              FClickStart := False;
              FClickReady := False;
              Click;
            end;
            FClickStart := False;
            MouseUp(mbLeft, Shift, Pt.x, Pt.y);
          end;

        WM_RBUTTONUP:
          if FBehavior = bhWin95 then
            if FEnabled then
            begin
              Shift := ShiftState + [ssRight];
              GetCursorPos(Pt);
              MouseUp(mbRight, Shift, Pt.x, Pt.y);
            end;

        WM_CONTEXTMENU, NIN_SELECT, NIN_KEYSELECT:
          if FBehavior = bhWin2000 then
            if FEnabled then
            begin
              Shift := ShiftState + [ssRight];
              GetCursorPos(Pt);
              MouseUp(mbRight, Shift, Pt.x, Pt.y);
            end;

        WM_MBUTTONUP:
          if FEnabled then
          begin
            Shift := ShiftState + [ssMiddle];
            GetCursorPos(Pt);
            MouseUp(mbMiddle, Shift, Pt.x, Pt.y);
          end;

        WM_LBUTTONDBLCLK:
          if FEnabled then
          begin
            FClickReady := False;
            IsDblClick := True;
            DblClick;
            M := nil;
            if Assigned(FPopupMenu) then
              if (FPopupMenu.AutoPopup) and (not FLeftPopup) then
                for I := PopupMenu.Items.Count -1 downto 0 do
                begin
                  if PopupMenu.Items[I].Default then
                    M := PopupMenu.Items[I];
                end;
            if M <> nil then
              M.Click;
          end;

        NIN_BALLOONSHOW: begin
          if Assigned(FOnBalloonHintShow) then
            FOnBalloonHintShow(Self);
        end;

        NIN_BALLOONHIDE:
          if Assigned(FOnBalloonHintHide) then
            FOnBalloonHintHide(Self);

        NIN_BALLOONTIMEOUT:
          if Assigned(FOnBalloonHintTimeout) then
            FOnBalloonHintTimeout(Self);

        NIN_BALLOONUSERCLICK:
          if Assigned(FOnBalloonHintClick) then
            FOnBalloonHintClick(Self);

      end;
    end;
  end

  else
    case Msg.Msg of
      WM_CLOSE, WM_QUIT, WM_DESTROY, WM_NCDESTROY: begin
        Msg.Result := 1;
      end;
      WM_QUERYENDSESSION, WM_ENDSESSION: begin
        Msg.Result := 1;
      end;
{$IFDEF WINNT_SERVICE_HACK}
      WM_USERCHANGED:
        if WinNT then
        begin
          if HComCtl32 = 0 then
          begin
            HComCtl32 := LoadLibrary('comctl32.dll');
            InitComCtl32 := GetProcAddress(HComCtl32, 'InitCommonControls');
            InitComCtl32;
          end
          else
          begin
            if HComCtl32 <> $7FFFFFFF then
              FreeLibrary(HComCtl32);
            HComCtl32 := 0;
          end;
          Msg.Result := 1;
        end;
{$ENDIF}
    else
      Msg.Result := DefWindowProc(FHandle, Msg.Msg, Msg.wParam, Msg.lParam);
    end;
end;

{ Container management }

procedure AddTrayIcon;
begin
  if not Assigned(TrayIconHandler) then
    TrayIconHandler := TTrayIconHandler.Create;
  TrayIconHandler.Add;
end;

procedure RemoveTrayIcon;
begin
  if Assigned(TrayIconHandler) then
  begin
    TrayIconHandler.Remove;
    if TrayIconHandler.RefCount = 0 then
    begin
      TrayIconHandler.Free;
      TrayIconHandler := nil;
    end;
  end;
end;

{ SimpleTimer event methods }

procedure TMGTrayIcon.ClickTimerProc(Sender: TObject);
begin
  ClickTimer.Enabled := False;
  if (not IsDblClick) then
    if FClickReady then
    begin
      FClickReady := False;
      Click;
    end;
  IsDblClick := False;
end;

procedure TMGTrayIcon.CycleTimerProc(Sender: TObject);
begin
  if Assigned(FIconList) then
  begin
    FIconList.GetIcon(FIconIndex, FIcon);
    CycleIcon;
    if FIconIndex < FIconList.Count-1 then
      SetIconIndex(FIconIndex+1)
    else
      SetIconIndex(0);
  end;
end;

procedure TMGTrayIcon.MouseExitTimerProc(Sender: TObject);
var
  Pt: TPoint;
begin
  if FDidExit then
    Exit;
  GetCursorPos(Pt);
  if (Pt.x < LastMoveX) or (Pt.y < LastMoveY) or
     (Pt.x > LastMoveX) or (Pt.y > LastMoveY) then
  begin
    FDidExit := True;
    MouseExit;
  end;
end;

{ TMGTrayIcon }

constructor TMGTrayIcon.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  AddTrayIcon;
{$WARNINGS OFF}
  FIconID := Cardinal(Self);
{$WARNINGS ON}
  SettingMDIForm := True;
  FEnabled := True;
  FShowHint := True;
  SettingPreview := False;
  FIcon := TIcon.Create;
  FIcon.OnChange := IconChanged;
  FillChar(IconData, SizeOf(IconData), 0);
  IconData.cbSize := SizeOf(TNotifyIconDataEx);
  IconData.hWnd := TrayIconHandler.FHandle;
  IconData.uId := FIconID;
  IconData.uFlags := NIF_ICON or NIF_MESSAGE or NIF_TIP;
  IconData.uCallbackMessage := WM_TRAYNOTIFY;
  CycleTimer := TSimpleTimer.Create;
  CycleTimer.OnTimer := CycleTimerProc;
  ClickTimer := TSimpleTimer.Create;
  ClickTimer.OnTimer := ClickTimerProc;
  ExitTimer := TSimpleTimer.CreateEx(20, MouseExitTimerProc);
  FDidExit := True;
  SetDesignPreview(FDesignPreview);
  if not (csDesigning in ComponentState) then
  begin
    Application.HookMainWindow(HookAppProc);
    if Owner is TWinControl then
      HookForm;
  end;
end;

destructor TMGTrayIcon.Destroy;
begin
  try
    SetIconVisible(False);
    SetDesignPreview(False);
    CycleTimer.Free;
    ClickTimer.Free;
    ExitTimer.Free;
    try
      if FIcon <> nil then
        FIcon.Free;
    except
      on Exception do
    end;
  finally
    if not (csDesigning in ComponentState) then
    begin
      Application.UnhookMainWindow(HookAppProc);
      if Owner is TWinControl then
        UnhookForm;
    end;
    RemoveTrayIcon;
    inherited Destroy;
  end
end;

procedure TMGTrayIcon.Loaded;
var
  Show: Boolean;
begin
  inherited Loaded;
  if Owner is TWinControl then
    if not (csDesigning in ComponentState) then
    begin
      Show := True;
      if Assigned(FOnStartup) then
        FOnStartup(Self, Show);

      if not Show then
      begin
        Application.ShowMainForm := False;
        HideMainForm;
      end;
    end;
  ModifyIcon;
  SetIconVisible(FIconVisible);
  SetCycleIcons(FCycleIcons);
  SetWantEnterExitEvents(FWantEnterExitEvents);
  SetBehavior(FBehavior);
{$IFDEF WINNT_SERVICE_HACK}
  WinNT := IsWinNT;
{$ENDIF}
end;

function TMGTrayIcon.LoadDefaultIcon: Boolean;
begin
  Result := True;
end;

procedure TMGTrayIcon.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (AComponent = IconList) and (Operation = opRemove) then
  begin
    FIconList := nil;
    IconList := nil;
  end;
  if (AComponent = PopupMenu) and (Operation = opRemove) then
  begin
    FPopupMenu := nil;
    PopupMenu := nil;
  end;
end;

procedure TMGTrayIcon.IconChanged(Sender: TObject);
begin
  ModifyIcon;
end;

function TMGTrayIcon.HookAppProc(var Msg: TMessage): Boolean;
var
  Show: Boolean;
begin
  Result := False;
  case Msg.Msg of
    WM_SIZE:
      if Msg.wParam = SIZE_MINIMIZED then
      begin
        if FMinimizeToTray then
          DoMinimizeToTray;
      end;
    WM_WINDOWPOSCHANGED: begin
      if SettingMDIForm then
        if Application.MainForm <> nil then
        begin
          if Application.MainForm.FormStyle = fsMDIForm then
          begin
            Show := True;
            if Assigned(FOnStartup) then
              FOnStartup(Self, Show);
            if not Show then
              HideTaskbarIcon;
          end;
          SettingMDIForm := False;
        end;
    end;
    WM_SYSCOMMAND:
      if Msg.wParam = SC_RESTORE then
      begin
        if Application.MainForm.WindowState = wsMinimized then
          Application.MainForm.WindowState := wsNormal;
        Application.MainForm.Visible := True;
      end;

  end;
  if Msg.Msg = WM_TASKBARCREATED then
    if FIconVisible then
      ShowIcon;
end;

procedure TMGTrayIcon.HookForm;
begin
  if (Owner as TWinControl) <> nil then
  begin
    OldWndProc := Pointer(GetWindowLong((Owner as TWinControl).Handle, GWL_WNDPROC));
    NewWndProc := MakeObjectInstance(HookFormProc);
    SetWindowLong((Owner as TWinControl).Handle, GWL_WNDPROC, LongInt(NewWndProc));
  end;
end;

procedure TMGTrayIcon.UnhookForm;
begin
  if ((Owner as TWinControl) <> nil) and (Assigned(OldWndProc)) then
    SetWindowLong((Owner as TWinControl).Handle, GWL_WNDPROC, LongInt(OldWndProc));
  if Assigned(NewWndProc) then
    FreeObjectInstance(NewWndProc);
  NewWndProc := nil;
  OldWndProc := nil;
end;

procedure TMGTrayIcon.HookFormProc(var Msg: TMessage);

  function DoMinimizeEvents: Boolean;
  begin
    Result := False;
    if FMinimizeToTray then
      if Assigned(FOnMinimizeToTray) then
      begin
        FOnMinimizeToTray(Self);
        DoMinimizeToTray;
        Msg.Result := 1;
        Result := True;
      end;
  end;

begin
  case Msg.Msg of
    WM_SHOWWINDOW: begin
      if (Msg.wParam = 1) and (Msg.lParam = 0) then
      begin
        SetForegroundWindow(Application.Handle);
        SetForegroundWindow((Owner as TWinControl).Handle);
      end
      else if (Msg.wParam = 0) and (Msg.lParam = SW_PARENTCLOSING) then
      begin
        if not Application.Terminated then
          if DoMinimizeEvents then
            Exit;
      end;

    end;
    WM_SYSCOMMAND:
      if Msg.wParam = SC_MINIMIZE then
        if DoMinimizeEvents then
          Exit;
  end;
  Msg.Result := CallWindowProc(OldWndProc, (Owner as TWinControl).Handle,
                Msg.Msg, Msg.wParam, Msg.lParam);
end;

procedure TMGTrayIcon.SetIcon(Value: TIcon);
begin
  FIcon.OnChange := nil;
  FIcon.Assign(Value);      
  FIcon.OnChange := IconChanged;
  ModifyIcon;
end;

procedure TMGTrayIcon.SetIconVisible(Value: Boolean);
begin
  if Value then
    ShowIcon
  else
    HideIcon;
end;

procedure TMGTrayIcon.SetDesignPreview(Value: Boolean);
begin
  FDesignPreview := Value;
  SettingPreview := True;
  if (csDesigning in ComponentState) then
  begin
    if FIcon.Handle = 0 then
      if LoadDefaultIcon then
        FIcon.Handle := LoadIcon(0, IDI_WINLOGO);
    SetIconVisible(Value);
  end;
  SettingPreview := False;
end;

procedure TMGTrayIcon.SetCycleIcons(Value: Boolean);
begin
  FCycleIcons := Value;
  if Value then
  begin
    SetIconIndex(0);
    CycleTimer.Interval := FCycleInterval;
    CycleTimer.Enabled := True;
  end
  else
    CycleTimer.Enabled := False;
end;

procedure TMGTrayIcon.SetCycleInterval(Value: Cardinal);
begin
  if Value <> FCycleInterval then
  begin
    FCycleInterval := Value;
    SetCycleIcons(FCycleIcons);
  end;
end;

{$IFDEF DELPHI4_UP}
procedure TMGTrayIcon.SetIconList(Value: TCustomImageList);
{$ELSE}
procedure TMGTrayIcon.SetIconList(Value: TImageList);
{$ENDIF}
begin
  FIconList := Value;
  SetIconIndex(0);
end;

procedure TMGTrayIcon.SetIconIndex(Value: Integer);
begin
  if FIconList <> nil then
  begin
    FIconIndex := Value;
    if Value >= FIconList.Count then
      FIconIndex := FIconList.Count -1;
    FIconList.GetIcon(FIconIndex, FIcon);
  end
  else
    FIconIndex := 0;
  ModifyIcon;
end;

procedure TMGTrayIcon.SetHint(Value: THintString);
begin
  FHint := Value;
  ModifyIcon;
end;

procedure TMGTrayIcon.SetShowHint(Value: Boolean);
begin
  FShowHint := Value;
  ModifyIcon;
end;

procedure TMGTrayIcon.SetWantEnterExitEvents(Value: Boolean);
begin
  FWantEnterExitEvents := Value;
  ExitTimer.Enabled := Value;
end;

procedure TMGTrayIcon.SetBehavior(Value: TBehavior);
begin
  FBehavior := Value;
  case FBehavior of
    bhWin95:   IconData.TimeoutOrVersion.uVersion := 0;
    bhWin2000: IconData.TimeoutOrVersion.uVersion := NOTIFYICON_VERSION;
  end;
  Shell_NotifyIcon(NIM_SETVERSION, @IconData);
end;

function TMGTrayIcon.InitIcon: Boolean;
var
  ok: Boolean;
begin
  Result := False;
  ok := True;
  if (csDesigning in ComponentState) then
    ok := (SettingPreview or FDesignPreview);

  if ok then
  begin
    try
      IconData.hIcon := FIcon.Handle;
    except
      on EReadError do
      begin
        IconData.hIcon := 0;
      end;
    end;
    if (FHint <> '') and (FShowHint) then
    begin
      StrLCopy(IconData.szTip, PChar(String(FHint)), Length(IconData.szTip)-1);
      IconData.szTip[Length(IconData.szTip)-1] := #0;
    end
    else
      IconData.szTip := '';
    Result := True;
  end;
end;

function TMGTrayIcon.ShowIcon: Boolean;
begin
  Result := False;
  if not SettingPreview then
    FIconVisible := True;
  begin
    if (csDesigning in ComponentState) then
    begin
      if SettingPreview then
        if InitIcon then
          Result := Shell_NotifyIcon(NIM_ADD, @IconData);
    end
    else
      if InitIcon then
        Result := Shell_NotifyIcon(NIM_ADD, @IconData);
  end;
end;

function TMGTrayIcon.HideIcon: Boolean;
begin
  Result := False;
  if not SettingPreview then
    FIconVisible := False;
  begin
    if (csDesigning in ComponentState) then
    begin
      if SettingPreview then
        if InitIcon then
          Result := Shell_NotifyIcon(NIM_DELETE, @IconData);
    end
    else
    if InitIcon then
      Result := Shell_NotifyIcon(NIM_DELETE, @IconData);
  end;
end;

function TMGTrayIcon.ModifyIcon: Boolean;
begin
  Result := False;
  if InitIcon then
    Result := Shell_NotifyIcon(NIM_MODIFY, @IconData);
end;

function TMGTrayIcon.ShowBalloonHint(Title, Text: String;
  IconType: TBalloonHintIcon; TimeoutSecs: TBalloonHintTimeOut): Boolean;
const
  aBalloonIconTypes: array[TBalloonHintIcon] of Byte =
    (NIIF_NONE, NIIF_INFO, NIIF_WARNING, NIIF_ERROR, NIIF_USER);
begin
  HideBalloonHint;
  with IconData do
  begin
    uFlags := uFlags or NIF_INFO;
    StrLCopy(szInfo, PChar(Text), Length(szInfo)-1);
    StrLCopy(szInfoTitle, PChar(Title), Length(szInfoTitle)-1);
    TimeoutOrVersion.uTimeout := TimeoutSecs * 1000;
    dwInfoFlags := aBalloonIconTypes[IconType];
  end;
  Result := ModifyIcon;
  IconData.uFlags := NIF_ICON or NIF_MESSAGE or NIF_TIP;
end;

function TMGTrayIcon.ShowBalloonHintUnicode(Title, Text: WideString;
  IconType: TBalloonHintIcon; TimeoutSecs: TBalloonHintTimeOut): Boolean;
const
  aBalloonIconTypes: array[TBalloonHintIcon] of Byte =
    (NIIF_NONE, NIIF_INFO, NIIF_WARNING, NIIF_ERROR, NIIF_USER);
var
  I: Integer;
begin
  HideBalloonHint;
  with IconData do
  begin
    uFlags := uFlags or NIF_INFO;
    FillChar(szInfo, 0, SizeOf(szInfo));
    for I := 0 to Length(szInfo)-1 do
      szInfo[I] := Char(Text[I]);
    szInfo[0] := #1;
    FillChar(szInfoTitle, 0, SizeOf(szInfoTitle));
    for I := 0 to Length(szInfoTitle)-1 do
      szInfoTitle[I] := Char(Title[I]);
    szInfoTitle[0] := #1;
    TimeoutOrVersion.uTimeout := TimeoutSecs * 1000;
    dwInfoFlags := aBalloonIconTypes[IconType];
  end;
  Result := ModifyIcon;
  IconData.uFlags := NIF_ICON or NIF_MESSAGE or NIF_TIP;
end;

function TMGTrayIcon.HideBalloonHint: Boolean;
begin
  with IconData do
  begin
    uFlags := uFlags or NIF_INFO;
    StrPCopy(szInfo, '');
  end;
  Result := ModifyIcon;
end;

function TMGTrayIcon.BitmapToIcon(const Bitmap: TBitmap;
  const Icon: TIcon; MaskColor: TColor): Boolean;
var
  BitmapImageList: TImageList;
begin
  BitmapImageList := TImageList.CreateSize(16, 16);
  try
    Result := False;
    BitmapImageList.AddMasked(Bitmap, MaskColor);
    BitmapImageList.GetIcon(0, Icon);
    Result := True;
  finally
    BitmapImageList.Free;
  end;
end;

function TMGTrayIcon.GetClientIconPos(X, Y: Integer): TPoint;
const
  IconBorder = 1;
var
  H: HWND;
  P: TPoint;
  IconSize: Integer;
begin
  IconSize := GetSystemMetrics(SM_CYCAPTION) - 3;
  P.X := X;
  P.Y := Y;
  H := WindowFromPoint(P);
  ScreenToClient(H, P);
  P.X := (P.X mod ((IconBorder*2)+IconSize)) -1;
  P.Y := (P.Y mod ((IconBorder*2)+IconSize)) -1;
  Result := P;
end;

function TMGTrayIcon.GetTooltipHandle: HWND;
var
  wnd, lTaskBar: HWND;
  pidTaskBar, pidWnd: DWORD;
begin
  lTaskBar := FindWindowEx(0, 0, 'Shell_TrayWnd', nil);
  GetWindowThreadProcessId(lTaskBar, @pidTaskBar);
  wnd := FindWindowEx(0, 0, TOOLTIPS_CLASS, nil);
  while wnd <> 0 do
  begin
    GetWindowThreadProcessId(wnd, @pidWnd);
    if pidTaskBar = pidWnd then
      if (GetWindowLong(wnd, GWL_STYLE) and TTS_NOPREFIX) = 0 then
        Break;
    wnd := FindWindowEx(0, wnd, TOOLTIPS_CLASS, nil);
  end;
  Result := wnd;
end;

function TMGTrayIcon.GetBalloonHintHandle: HWND;
var
  wnd, lTaskBar: HWND;
  pidTaskBar, pidWnd: DWORD;
begin
  lTaskBar := FindWindowEx(0, 0, 'Shell_TrayWnd', nil);
  GetWindowThreadProcessId(lTaskBar, @pidTaskBar);
  wnd := FindWindowEx(0, 0, TOOLTIPS_CLASS, nil);
  while wnd <> 0 do
  begin
    GetWindowThreadProcessId(wnd, @pidWnd);
    if pidTaskBar = pidWnd then
      if (GetWindowLong(wnd, GWL_STYLE) and TTS_NOPREFIX) <> 0 then
        Break;
    wnd := FindWindowEx(0, wnd, TOOLTIPS_CLASS, nil);
  end;
  Result := wnd;
end;

function TMGTrayIcon.SetFocus: Boolean;
begin
  Result := Shell_NotifyIcon(NIM_SETFOCUS, @IconData);
end;

function TMGTrayIcon.Refresh: Boolean;
begin
  Result := ModifyIcon;
end;

procedure TMGTrayIcon.Popup(X, Y: Integer);
begin
  if Assigned(FPopupMenu) then
  begin
    SetForegroundWindow(Handle);
    Application.ProcessMessages;
    FPopupMenu.PopupComponent := Self;
    FPopupMenu.Popup(X, Y);
    if Owner is TWinControl then
      PostMessage((Owner as TWinControl).Handle, WM_NULL, 0, 0)
  end;
end;

procedure TMGTrayIcon.PopupAtCursor;
var
  CursorPos: TPoint;
begin
  if GetCursorPos(CursorPos) then
  begin
    Popup(CursorPos.X, CursorPos.Y);
  end;
end;

procedure TMGTrayIcon.Click;
begin
  if Assigned(FOnClick) then
    FOnClick(Self);
end;

procedure TMGTrayIcon.DblClick;
begin
  if Assigned(FOnDblClick) then
    FOnDblClick(Self);
end;

procedure TMGTrayIcon.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  if Assigned(FOnMouseDown) then
    FOnMouseDown(Self, Button, Shift, X, Y);
end;

procedure TMGTrayIcon.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  if Assigned(FOnMouseUp) then
    FOnMouseUp(Self, Button, Shift, X, Y);
end;

procedure TMGTrayIcon.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  if Assigned(FOnMouseMove) then
    FOnMouseMove(Self, Shift, X, Y);
end;

procedure TMGTrayIcon.MouseEnter;
begin
  if Assigned(FOnMouseEnter) then
    FOnMouseEnter(Self);
end;

procedure TMGTrayIcon.MouseExit;
begin
  if Assigned(FOnMouseExit) then
    FOnMouseExit(Self);
end;

procedure TMGTrayIcon.CycleIcon;
var
  NextIconIndex: Integer;
begin
  NextIconIndex := 0;
  if FIconList <> nil then
    if FIconIndex < FIconList.Count then
      NextIconIndex := FIconIndex +1;
  if Assigned(FOnCycle) then
    FOnCycle(Self, NextIconIndex);
end;

procedure TMGTrayIcon.DoMinimizeToTray;
begin
  HideMainForm;
  IconVisible := True;
end;

{$IFDEF WINNT_SERVICE_HACK}
function TMGTrayIcon.IsWinNT: Boolean;
var
  ovi: TOSVersionInfo;
  rc: Boolean;
begin
  rc := False;
  ovi.dwOSVersionInfoSize := SizeOf(TOSVersionInfo);
  if GetVersionEx(ovi) then
    rc := (ovi.dwPlatformId = VER_PLATFORM_WIN32_NT) and (ovi.dwMajorVersion <= 4);
  Result := rc;
end;
{$ENDIF}

procedure TMGTrayIcon.HideTaskbarIcon;
begin
  if IsWindowVisible(Application.Handle) then
    ShowWindow(Application.Handle, SW_HIDE);
end;

procedure TMGTrayIcon.ShowTaskbarIcon;
begin
  if not IsWindowVisible(Application.Handle) then
    ShowWindow(Application.Handle, SW_SHOW);
end;

procedure TMGTrayIcon.ShowMainForm;
begin
  if Owner is TWinControl then
    if Application.MainForm <> nil then
    begin
      Application.Restore;
      if Application.MainForm.WindowState = wsMinimized then
        Application.MainForm.WindowState := wsNormal;
      Application.MainForm.Visible := True;
      SetForegroundWindow(Application.Handle);
    end;
end;

procedure TMGTrayIcon.HideMainForm;
begin
  if Owner is TWinControl then
    if Application.MainForm <> nil then
    begin
      Application.MainForm.Visible := False;
      HideTaskbarIcon;
    end;
end;

initialization
{$IFDEF DELPHI4_UP}
  SHELL_VERSION := GetComCtlVersion;
  if SHELL_VERSION >= ComCtlVersionIE4 then
{$ENDIF}
    WM_TASKBARCREATED := RegisterWindowMessage('TaskbarCreated');

finalization
  if Assigned(TrayIconHandler) then
  begin
    TrayIconHandler.Free;
    TrayIconHandler := nil;
  end;

end.

