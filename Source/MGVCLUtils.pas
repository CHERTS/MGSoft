{ ############################################################################ }
{ #                                                                          # }
{ #  MGSoft Delphi Components v1.0.0                                         # }
{ #                                                                          # }
{ #  License: GPLv3                                                          # }
{ #                                                                          # }
{ #  Author: Mikhail Grigorev (icq: 161867489, email: sleuthhound@gmail.com) # }
{ #                                                                          # }
{ ############################################################################ }

unit MGVCLUtils;

{$I MGSoft.inc}
{$P+,W-,R-,V-}
{$IFDEF DELPHI6_UP}
{$WARN SYMBOL_PLATFORM OFF}
{$ENDIF}

interface

uses
{$IFDEF HAS_UNITSCOPE}
  {$IFDEF MSWINDOWS}
  Winapi.Windows, Winapi.Messages,
  {$ENDIF MSWINDOWS}
  System.Classes, System.SysUtils, System.Types,
  {$IFDEF HAS_VCL}
  Vcl.Controls, Vcl.Dialogs, Vcl.Forms
  {$ELSE}
  FMX.Controls, FMX.Dialogs, FMX.Forms
  {$ENDIF}
{$ELSE ~HAS_UNITSCOPE}
  {$IFDEF MSWINDOWS}
  Windows,
  {$ENDIF MSWINDOWS}
  {$IFNDEF FPC}Messages,{$ENDIF FPC}
  Classes, SysUtils, Types, Controls, Dialogs, Forms
{$ENDIF ~HAS_UNITSCOPE};

const
  WaitCursor: TCursor = crHourGlass;

var
  SaveCursor: TCursor = crDefault;
  WaitCount: Integer = 0;

procedure StartWait;
procedure StopWait;
procedure SwitchToWindow(Wnd: HWnd; Restore: Boolean);

implementation

procedure StartWait;
begin
  if WaitCount = 0 then
  begin
    SaveCursor := Screen.Cursor;
    Screen.Cursor := WaitCursor;
  end;
  Inc(WaitCount);
end;

procedure StopWait;
begin
  if WaitCount > 0 then
  begin
    Dec(WaitCount);
    if WaitCount = 0 then Screen.Cursor := SaveCursor;
  end;
end;

procedure SwitchToWindow(Wnd: HWnd; Restore: Boolean);
begin
  if IsWindowEnabled(Wnd) then
  begin
{$IFNDEF DELPHI1}
    SetForegroundWindow(Wnd);
    if Restore and IsWindowVisible(Wnd) then
    begin
      if not IsZoomed(Wnd) then
        SendMessage(Wnd, WM_SYSCOMMAND, SC_RESTORE, 0);
      SetFocus(Wnd);
    end;
{$ELSE}
    SwitchToThisWindow(Wnd, Restore);
{$ENDIF}
  end;
end;

initialization
end.
