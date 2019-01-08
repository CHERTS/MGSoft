{ ############################################################################ }
{ #                                                                          # }
{ #  MGSoft Delphi Components v1.0.0                                         # }
{ #                                                                          # }
{ #  MGHotKeyManager v1.0.0 - �������� ������� ������                        # }
{ #                                                                          # }
{ #  License: GPLv3                                                          # }
{ #                                                                          # }
{ #  Author: Mikhail Grigorev (icq: 161867489, email: sleuthhound@gmail.com) # }
{ #                                                                          # }
{ ############################################################################ }

unit MGHotKeyManager;

{$I MGSoft.inc}
{$R+}
{$IFDEF BCB3} // C++ Builder 3
  {$ObjExportAll On}
{$ENDIF BCB3}

interface

uses
{$IFDEF HAS_UNITSCOPE}
  {$IFDEF MSWINDOWS}
  Winapi.Windows, Winapi.Messages,
  {$ENDIF MSWINDOWS}
  System.Classes, System.SysUtils
{$ELSE ~HAS_UNITSCOPE}
  {$IFDEF MSWINDOWS}
  Windows,
  {$ENDIF MSWINDOWS}
  {$IFNDEF FPC}Messages,{$ENDIF FPC}
  Classes, SysUtils
{$ENDIF ~HAS_UNITSCOPE};

const
  // �������������� ������� � Windows 2000/XP  (����� �� winuser.h � ������������� �� ��������� ����������)
  // �������� �����: http://msdn.microsoft.com/en-us/library/windows/desktop/dd375731%28v=vs.85%29.aspx
  _VK_BROWSER_BACK            = $A6;        // Browser Back key
  _VK_BROWSER_FORWARD         = $A7;        // Browser Forward key
  _VK_BROWSER_REFRESH         = $A8;        // Browser Refresh key
  _VK_BROWSER_STOP            = $A9;        // Browser Stop key
  _VK_BROWSER_SEARCH          = $AA;        // Browser Search key
  _VK_BROWSER_FAVORITES       = $AB;        // Browser Favorites key
  _VK_BROWSER_HOME            = $AC;        // Browser Start and Home key
  _VK_VOLUME_MUTE             = $AD;        // Volume Mute key
  _VK_VOLUME_DOWN             = $AE;        // Volume Down key
  _VK_VOLUME_UP               = $AF;        // Volume Up key
  _VK_MEDIA_NEXT_TRACK        = $B0;        // Next Track key
  _VK_MEDIA_PREV_TRACK        = $B1;        // Previous Track key
  _VK_MEDIA_STOP              = $B2;        // Stop Media key
  _VK_MEDIA_PLAY_PAUSE        = $B3;        // Play/Pause Media key
  _VK_LAUNCH_MAIL             = $B4;        // Start Mail key
  _VK_LAUNCH_MEDIA_SELECT     = $B5;        // Select Media key
  _VK_LAUNCH_APP1             = $B6;        // Start Application 1 key
  _VK_LAUNCH_APP2             = $B7;        // Start Application 2 key
  // ����� ��� ������
  NAME_VK_BROWSER_BACK        = 'Browser Back';
  NAME_VK_BROWSER_FORWARD     = 'Browser Forward';
  NAME_VK_BROWSER_REFRESH     = 'Browser Refresh';
  NAME_VK_BROWSER_STOP        = 'Browser Stop';
  NAME_VK_BROWSER_SEARCH      = 'Browser Search';
  NAME_VK_BROWSER_FAVORITES   = 'Browser Favorites';
  NAME_VK_BROWSER_HOME        = 'Browser Start/Home';
  NAME_VK_VOLUME_MUTE         = 'Volume Mute';
  NAME_VK_VOLUME_DOWN         = 'Volume Down';
  NAME_VK_VOLUME_UP           = 'Volume Up';
  NAME_VK_MEDIA_NEXT_TRACK    = 'Next Track';
  NAME_VK_MEDIA_PREV_TRACK    = 'Previous Track';
  NAME_VK_MEDIA_STOP          = 'Stop Media';
  NAME_VK_MEDIA_PLAY_PAUSE    = 'Play/Pause Media';
  NAME_VK_LAUNCH_MAIL         = 'Start Mail';
  NAME_VK_LAUNCH_MEDIA_SELECT = 'Select Media';
  NAME_VK_LAUNCH_APP1         = 'Start Application 1';
  NAME_VK_LAUNCH_APP2         = 'Start Application 2';

type
  TOnHotKeyPressed = procedure(HotKey: Cardinal; Index: Word) of object;

  PHotKeyRegistration = ^THotKeyRegistration;
  THotKeyRegistration = record
    HotKey: Cardinal;
    KeyIndex: Word;
  end;

  TMGHotKeyManager = class(TComponent)
  private
    FHandle: HWND;
    HotKeyList: TList;
    FOnHotKeyPressed: TOnHotKeyPressed;
  protected
    function DisposeHotKey(hkr: PHotKeyRegistration): Boolean;
    procedure HookProc(var Msg: TMessage); virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function AddHotKey(HotKey: Cardinal): Word;
    function ChangeHotKey(Index: Word; NewHotKey: Cardinal): Word;
    function RemoveHotKey(HotKey: Cardinal): Boolean;
    function RemoveHotKeyByIndex(Index: Word): Boolean;
    procedure ClearHotKeys;
    function HotKeyValid(HotKey: Cardinal): Boolean;
  published
    property OnHotKeyPressed: TOnHotKeyPressed read FOnHotKeyPressed write FOnHotKeyPressed;
  end;

function HotKeyAvailable(HotKey: Cardinal): Boolean;
function GetHotKey(Modifiers, Key: Word): Cardinal;
procedure SeparateHotKey(HotKey: Cardinal; var Modifiers, Key: Word);
function HotKeyToText(HotKey: Cardinal; Localized: Boolean): String;
function TextToHotKey(Text: String; Localized: Boolean): Cardinal;
function IsExtendedKey(Key: Word): Boolean;

implementation

uses
{$IFDEF HAS_UNITSCOPE}
  {$IFDEF MSWINDOWS}
  Vcl.Forms
  {$ENDIF MSWINDOWS}
{$ELSE ~HAS_UNITSCOPE}
  {$IFDEF MSWINDOWS}
  Forms
  {$ENDIF MSWINDOWS}
{$ENDIF ~HAS_UNITSCOPE};

const
  HotKeyAtomPrefix = 'MGHotKeyManagerHotKey';
  // ���������������� (!) ����� �������������
  ModName_Shift = 'Shift';
  ModName_Ctrl  = 'Ctrl';
  ModName_Alt   = 'Alt';
  ModName_Win   = 'Win';

var
  EnglishKeyboardLayout: HKL;
  ShouldUnloadEnglishKeyboardLayout: Boolean;
  // �������������� (!) ����� ������������� ��� ���������� ��������
  LocalModName_Shift: String = ModName_Shift;
  LocalModName_Ctrl: String  = ModName_Ctrl;
  LocalModName_Alt: String   = ModName_Alt;
  LocalModName_Win: String   = ModName_Win;

{ ����������� ������ }

// �������� ��������� � ������� �������� � �������������
function GetHotKey(Modifiers, Key: Word): Cardinal;
const
  VK2_SHIFT   =  32;
  VK2_CONTROL =  64;
  VK2_ALT     = 128;
  VK2_WIN     = 256;
var
  hk: Cardinal;
begin
  hk := 0;
  if (Modifiers and MOD_ALT) <> 0 then
    Inc(hk, VK2_ALT);
  if (Modifiers and MOD_CONTROL) <> 0 then
    Inc(hk, VK2_CONTROL);
  if (Modifiers and MOD_SHIFT) <> 0 then
    Inc(hk, VK2_SHIFT);
  if (Modifiers and MOD_WIN) <> 0 then
    Inc(hk, VK2_WIN);
  hk := hk shl 8;
  Inc(hk, Key);
  Result := hk;
end;

// Separate key and modifiers, so they can be used with RegisterHotKey
procedure SeparateHotKey(HotKey: Cardinal; var Modifiers, Key: Word);
const
  VK2_SHIFT   =  32;
  VK2_CONTROL =  64;
  VK2_ALT     = 128;
  VK2_WIN     = 256;
var
  Virtuals: Integer;
  V: Word;
  x: Word;
begin
  Key := Byte(HotKey);
  x := HotKey shr 8;
  Virtuals := x;
  V := 0;
  if (Virtuals and VK2_WIN) <> 0 then
    Inc(V, MOD_WIN);
  if (Virtuals and VK2_ALT) <> 0 then
    Inc(V, MOD_ALT);
  if (Virtuals and VK2_CONTROL) <> 0 then
    Inc(V, MOD_CONTROL);
  if (Virtuals and VK2_SHIFT) <> 0 then
    Inc(V, MOD_SHIFT);
  Modifiers := V;
end;

// Test if HotKey is available (test if it can be registered - by this or any app.)
function HotKeyAvailable(HotKey: Cardinal): Boolean;
var
  M, K: Word;
  Atom: Word;
begin
  Atom := GlobalAddAtom(PChar('HotKeyManagerHotKeyTest'));
  SeparateHotKey(HotKey, M, K);
  Result := RegisterHotKey({$IFNDEF FPC}Application.Handle{$ELSE}Application.MainFormHandle{$ENDIF}, Atom, M, K);
  if Result then
    UnregisterHotKey({$IFNDEF FPC}Application.Handle{$ELSE}Application.MainFormHandle{$ENDIF}, Atom);
  GlobalDeleteAtom(Atom);
end;

function IsExtendedKey(Key: Word): Boolean;
begin
  Result := ((Key >= _VK_BROWSER_BACK) and (Key <= _VK_LAUNCH_APP2));
end;

// Return localized(!) or English(!) string value from key combination
function HotKeyToText(HotKey: Cardinal; Localized: Boolean): String;

  function GetExtendedVKName(Key: Word): String;
  begin
    case Key of
      _VK_BROWSER_BACK:        Result := NAME_VK_BROWSER_BACK;
      _VK_BROWSER_FORWARD:     Result := NAME_VK_BROWSER_FORWARD;
      _VK_BROWSER_REFRESH:     Result := NAME_VK_BROWSER_REFRESH;
      _VK_BROWSER_STOP:        Result := NAME_VK_BROWSER_STOP;
      _VK_BROWSER_SEARCH:      Result := NAME_VK_BROWSER_SEARCH;
      _VK_BROWSER_FAVORITES:   Result := NAME_VK_BROWSER_FAVORITES;
      _VK_BROWSER_HOME:        Result := NAME_VK_BROWSER_HOME;
      _VK_VOLUME_MUTE:         Result := NAME_VK_VOLUME_MUTE;
      _VK_VOLUME_DOWN:         Result := NAME_VK_VOLUME_DOWN;
      _VK_VOLUME_UP:           Result := NAME_VK_VOLUME_UP;
      _VK_MEDIA_NEXT_TRACK:    Result := NAME_VK_MEDIA_NEXT_TRACK;
      _VK_MEDIA_PREV_TRACK:    Result := NAME_VK_MEDIA_PREV_TRACK;
      _VK_MEDIA_STOP:          Result := NAME_VK_MEDIA_STOP;
      _VK_MEDIA_PLAY_PAUSE:    Result := NAME_VK_MEDIA_PLAY_PAUSE;
      _VK_LAUNCH_MAIL:         Result := NAME_VK_LAUNCH_MAIL;
      _VK_LAUNCH_MEDIA_SELECT: Result := NAME_VK_LAUNCH_MEDIA_SELECT;
      _VK_LAUNCH_APP1:         Result := NAME_VK_LAUNCH_APP1;
      _VK_LAUNCH_APP2:         Result := NAME_VK_LAUNCH_APP2;
    else
      Result := '';
    end;
  end;

  function GetModifierNames: String;
  var
    S: String;
  begin
    S := '';
    if Localized then
    begin
      if (HotKey and $4000) <> 0 then       // scCtrl
        S := S + LocalModName_Ctrl + '+';
      if (HotKey and $2000) <> 0 then       // scShift
        S := S + LocalModName_Shift + '+';
      if (HotKey and $8000) <> 0 then       // scAlt
        S := S + LocalModName_Alt + '+';
      if (HotKey and $10000) <> 0 then
        S := S + LocalModName_Win + '+';
    end
    else
    begin
      if (HotKey and $4000) <> 0 then       // scCtrl
        S := S + ModName_Ctrl + '+';
      if (HotKey and $2000) <> 0 then       // scShift
        S := S + ModName_Shift + '+';
      if (HotKey and $8000) <> 0 then       // scAlt
        S := S + ModName_Alt + '+';
      if (HotKey and $10000) <> 0 then
        S := S + ModName_Win + '+';
    end;
    Result := S;
  end;

  function GetVKName(Special: Boolean): String;
  var
    ScanCode: Cardinal;
    KeyName: array[0..255] of Char;
    oldkl: HKL;
    Modifiers, Key: Word;
  begin
    Result := '';
    if Localized then        // Local language key names
    begin
      if Special then
        ScanCode := (MapVirtualKey(Byte(HotKey), 0) shl 16) or (1 shl 24)
      else
        ScanCode := (MapVirtualKey(Byte(HotKey), 0) shl 16);
      if ScanCode <> 0 then
      begin
        GetKeyNameText(ScanCode, KeyName, SizeOf(KeyName));
        Result := KeyName;
      end;
    end
    else                     // English key names
    begin
      if Special then
        ScanCode := (MapVirtualKeyEx(Byte(HotKey), 0, EnglishKeyboardLayout) shl 16) or (1 shl 24)
      else
        ScanCode := (MapVirtualKeyEx(Byte(HotKey), 0, EnglishKeyboardLayout) shl 16);
      if ScanCode <> 0 then
      begin
        oldkl := GetKeyboardLayout(0);
        if oldkl <> EnglishKeyboardLayout then
          ActivateKeyboardLayout(EnglishKeyboardLayout, 0);  // Set English kbd. layout
        GetKeyNameText(ScanCode, KeyName, SizeOf(KeyName));
        Result := KeyName;
        if oldkl <> EnglishKeyboardLayout then
        begin
          if ShouldUnloadEnglishKeyboardLayout then
            UnloadKeyboardLayout(EnglishKeyboardLayout);     // Restore prev. kbd. layout
          ActivateKeyboardLayout(oldkl, 0);
        end;
      end;
    end;

    if Length(Result) <= 1 then
    begin
      // Try the internally defined names
      SeparateHotKey(HotKey, Modifiers, Key);
      if IsExtendedKey(Key) then
        Result := GetExtendedVKName(Key);
    end;
  end;

var
  KeyName: String;
begin
  case Byte(HotKey) of
    // PgUp, PgDn, End, Home, Left, Up, Right, Down, Ins, Del
    $21..$28, $2D, $2E: KeyName := GetVKName(True);
  else
    KeyName := GetVKName(False);
  end;
  Result := GetModifierNames + KeyName;
end;

// Return key combination created from (non-localized!) string value
function TextToHotKey(Text: String; Localized: Boolean): Cardinal;
var
  Tokens: TStringList;

  function GetModifiersValue: Word;
  var
    I: Integer;
    M: Word;
    ModName: String;
  begin
    M := 0;
    for I := 0 to Tokens.Count -2 do
    begin
      ModName := Trim(Tokens[I]);
      if (AnsiCompareText(ModName, ModName_Shift) = 0) or
         (AnsiCompareText(ModName, LocalModName_Shift) = 0) then
        M := M or MOD_SHIFT
      else if (AnsiCompareText(ModName, ModName_Ctrl) = 0) or
              (AnsiCompareText(ModName, LocalModName_Ctrl) = 0) then
        M := M or MOD_CONTROL
      else if (AnsiCompareText(ModName, ModName_Alt) = 0) or
              (AnsiCompareText(ModName, LocalModName_Alt) = 0) then
        M := M or MOD_ALT
      else if (AnsiCompareText(ModName, ModName_Win) = 0) or
              (AnsiCompareText(ModName, LocalModName_Win) = 0) then
        M := M or MOD_WIN
      else
      begin
        // Unrecognized modifier encountered
        Result := 0;
        Exit;
      end;
    end;
    Result := M;
  end;

  function IterateVKNames(KeyName: String): Word;
  var
    I: Integer;
    K: Word;
  begin
    K := 0;
    for I := $08 to $FF do        // The brute force approach
      if AnsiCompareText(KeyName, HotKeyToText(I, Localized)) = 0 then
      begin
        K := I;
        Break;
      end;
    Result := K;
  end;

  function GetKeyValue: Word;
  var
    K: Word;
    KeyName: String;
    C: Char;
  begin
    K := 0;
    if Tokens.Count > 0 then
    begin
      KeyName := Trim(Tokens[Tokens.Count-1]);
      if Length(KeyName) = 1 then
      begin
        C := UpCase(KeyName[1]);
        case Byte(C) of
          $30..$39, $41..$5A:     // 0..9, A..Z
            K := Ord(C);
        else
          K := IterateVKNames(C);
        end;
      end
      else
      begin
        if KeyName = 'Num' then   // Special handling for 'Num +'
          KeyName := KeyName + ' +';
        if (KeyName <> ModName_Ctrl) and (KeyName <> LocalModName_Ctrl) and
           (KeyName <> ModName_Alt) and (KeyName <> LocalModName_Alt) and
           (KeyName <> ModName_Shift) and (KeyName <> LocalModName_Shift) and
           (KeyName <> ModName_Win) and (KeyName <> LocalModName_Win) then
        K := IterateVKNames(KeyName);
      end;
    end;
    Result := K;
  end;

var
  Modifiers, Key: Word;
begin
  Tokens := TStringList.Create;
  try
    ExtractStrings(['+'], [' '], PChar(Text), Tokens);
    Modifiers := GetModifiersValue;
    if (Modifiers = 0) and (Tokens.Count > 1) then
      // Something went wrong when translating the modifiers
      Result := 0
    else
    begin
      Key := GetKeyValue;
      if Key = 0 then
        // Something went wrong when translating the key
        Result := 0
      else
        Result := GetHotKey(Modifiers, Key);
    end;
  finally
    Tokens.Free;
  end;
end;

{ TMGHotKeyManager }

constructor TMGHotKeyManager.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  HotKeyList := TList.Create;

  if not (csDesigning in ComponentState) then
  begin
    // Create a virtual window with a callback method and use it as handle
{$IFDEF DELPHIXE2_UP}
    FHandle := System.Classes.AllocateHWnd(HookProc);
{$ELSE}
    FHandle := Classes.AllocateHWnd(HookProc);
{$ENDIF}
  end;
end;

destructor TMGHotKeyManager.Destroy;
begin
  ClearHotKeys;
  HotKeyList.Free;

  if not (csDesigning in ComponentState) then
  begin
    // Destroy our virtual window
{$IFDEF DELPHIXE2_UP}
    System.Classes.DeallocateHWnd(FHandle);
{$ELSE}
    Classes.DeallocateHWnd(FHandle);
{$ENDIF}
  end;

  inherited Destroy;
end;

function TMGHotKeyManager.AddHotKey(HotKey: Cardinal): Word;
var
  hkr: PHotKeyRegistration;
  Modifiers, Key: Word;
  Atom: Word;
begin
  SeparateHotKey(HotKey, Modifiers, Key);
  // Create unique id (global atom)
  Atom := GlobalAddAtom(PChar(HotKeyAtomPrefix + IntToStr(HotKey)));
  // Register
  if RegisterHotKey(FHandle, Atom, Modifiers, Key) then
  begin
    hkr := New(PHotKeyRegistration);
    hkr.HotKey := HotKey;
    hkr.KeyIndex := Atom;
    HotKeyList.Add(hkr);
    Result := Atom;
  end
  else
  begin
    GlobalDeleteAtom(Atom);
    Result := 0;
  end;
end;

function TMGHotKeyManager.ChangeHotKey(Index: Word; NewHotKey: Cardinal): Word;
var
  I: Integer;
  hkr: PHotKeyRegistration;
begin
  Result := 0;
  for I := 0 to HotKeyList.Count -1 do
  begin
    hkr := PHotKeyRegistration(HotKeyList[I]);
    if hkr.KeyIndex = Index then
    begin
      RemoveHotKeyByIndex(hkr.KeyIndex);
      Result := AddHotKey(NewHotKey);
      Exit;
    end;
  end;
end;

function TMGHotKeyManager.RemoveHotKey(HotKey: Cardinal): Boolean;
var
  I: Integer;
  hkr: PHotKeyRegistration;
begin
  Result := False;
  for I := 0 to HotKeyList.Count -1 do
  begin
    hkr := PHotKeyRegistration(HotKeyList[I]);
    if hkr.HotKey = HotKey then
    begin
      Result := DisposeHotKey(hkr);
      HotKeyList.Remove(hkr);
      Exit;
    end;
  end;
end;

function TMGHotKeyManager.RemoveHotKeyByIndex(Index: Word): Boolean;
var
  I: Integer;
  hkr: PHotKeyRegistration;
begin
  Result := False;
  for I := 0 to HotKeyList.Count -1 do
  begin
    hkr := PHotKeyRegistration(HotKeyList[I]);
    if hkr.KeyIndex = Index then
    begin
      Result := DisposeHotKey(hkr);
      HotKeyList.Remove(hkr);
      Exit;
    end;
  end;
end;

// Test if HotKey is valid (test if it can be registered even if this app. already registered it)
function TMGHotKeyManager.HotKeyValid(HotKey: Cardinal): Boolean;
var
  M, K: Word;
  WasRegistered: Boolean;
  Atom: Word;
begin
  Atom := GlobalAddAtom(PChar(HotKeyAtomPrefix + IntToStr(HotKey)));
  SeparateHotKey(HotKey, M, K);
  WasRegistered := UnregisterHotKey(FHandle, Atom);
  if WasRegistered then
  begin
    RegisterHotKey(FHandle, Atom, M, K);
    Result := True;
  end
  else
  begin
    Result := RegisterHotKey(FHandle, Atom, M, K);
    if Result then
      UnregisterHotKey(FHandle, Atom);
  end;
  GlobalDeleteAtom(Atom);
end;

procedure TMGHotKeyManager.ClearHotKeys;
var
  I: Integer;
  hkr: PHotKeyRegistration;
begin
  for I := HotKeyList.Count -1 downto 0 do
  begin
    hkr := PHotKeyRegistration(HotKeyList[I]);
    DisposeHotKey(hkr);
    HotKeyList.Remove(hkr);
  end;
end;

// Unregister using previously assigned id (global atom)
function TMGHotKeyManager.DisposeHotKey(hkr: PHotKeyRegistration): Boolean;
begin
  Result := UnregisterHotKey(FHandle, hkr.KeyIndex);
  GlobalDeleteAtom(hkr.KeyIndex);
  if Result then
    Dispose(hkr);
end;

procedure TMGHotKeyManager.HookProc(var Msg: TMessage);

  function HotKeyFound(HotKey: Cardinal): Boolean;
  var
    I: Integer;
  begin
    Result := False;
    for I := 0 to HotKeyList.Count -1 do
      if PHotKeyRegistration(HotKeyList[I]).HotKey = HotKey then
      begin
        Result := True;
        Break;
      end;
  end;

var
  Modifier: Cardinal;
begin
  case Msg.Msg of
    WM_HOTKEY:
      if Assigned(FOnHotKeyPressed) then
      begin
        // Get modifier keys status
        Modifier := 0;
        if (Msg.LParamLo and MOD_SHIFT) <> 0 then
          Inc(Modifier, $2000);        // scShift
        if (Msg.LParamLo and MOD_CONTROL) <> 0 then
          Inc(Modifier, $4000);        // scCtrl
        if (Msg.LParamLo and MOD_ALT) <> 0 then
          Inc(Modifier, $8000);        // scAlt
        if (Msg.LParamLo and MOD_WIN) <> 0 then
          Inc(Modifier, $10000);
        { Check if the hotkey is in the list (it's possible user has registered hotkeys
          without using this component and handles these hotkeys by himself). }
        if HotKeyFound(Msg.LParamHi + Modifier) then
          OnHotKeyPressed(Msg.LParamHi + Modifier, Msg.WParam);
      end;
  end;
  // Pass the message on
  Msg.Result := DefWindowProc(FHandle, Msg.Msg, Msg.wParam, Msg.lParam);
end;

function IsUpperCase(S: String): Boolean;
var
  I: Integer;
  C: Byte;
begin
  Result := True;
  for I := 1 to Length(S) do
  begin
    C := Ord(S[I]);
    if (C < $41) or (C > $5A) then
    begin
      Result := False;
      Exit;
    end;
  end;
end;

var
  Layouts: Cardinal;
  // kllist: array of HKL;
  kllist: array[0..100] of HKL;
  I: Integer;

initialization
  // Get localized names of modfiers
  LocalModName_Shift := HotKeyToText($10, True);
  LocalModName_Ctrl := HotKeyToText($11, True);
  LocalModName_Alt := HotKeyToText($12, True);
  if IsUpperCase(LocalModName_Alt) then
    LocalModName_Win := UpperCase(LocalModName_Win);

  { To get the non-localized (English) names of keys and modifiers we must load
    and activate the US English keyboard layout. However, we shouldn't change the
    user's current list of layouts, so the English layout should be unloaded
    after it is used (in HotKeyToText) in case it wasn't originally part of the
    user's list of layouts. It's a bit of a hack, but it's the only way I can
    think of to get the English names. }

  // Get all keyboard layouts
  // Layouts := GetKeyboardLayoutList(0, kllist);
  // SetLength(kllist, Layouts);
  Layouts := GetKeyboardLayoutList(100, kllist);

  // Load (but don't activate) US English keyboard layout for use in HotKeyToText
  EnglishKeyboardLayout := LoadKeyboardLayout(PChar('00000409'), KLF_NOTELLSHELL);

  // Examine if US English layout is already in user's list of keyboard layouts
  ShouldUnloadEnglishKeyboardLayout := True;
  for I := 0 to Layouts -1 do
  begin
    if kllist[I] = EnglishKeyboardLayout then
    begin
      ShouldUnloadEnglishKeyboardLayout := False;
      Exit;
    end;
  end;

finalization
  if ShouldUnloadEnglishKeyboardLayout then
    UnloadKeyboardLayout(EnglishKeyboardLayout);   // Restore prev. kbd. layout

end.

