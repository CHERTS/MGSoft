{ ############################################################################ }
{ #                                                                          # }
{ #  MGSoft Delphi Components v1.0.0                                         # }
{ #                                                                          # }
{ #  License: GPLv3                                                          # }
{ #                                                                          # }
{ #  Author: Mikhail Grigorev (icq: 161867489, email: sleuthhound@gmail.com) # }
{ #                                                                          # }
{ ############################################################################ }

unit MGThread;

{$I MGSoft.inc}

interface

uses
{$IFDEF HAS_UNITSCOPE}
  {$IFDEF MSWINDOWS}
  Winapi.Windows,
  {$ENDIF MSWINDOWS}
  System.Classes, System.SysUtils, System.SyncObjs,
  {$IFDEF HAS_VCL}
  Vcl.Controls, Vcl.Forms
  {$ELSE}
  FMX.Controls, FMX.Forms
  {$ENDIF}
{$ELSE ~HAS_UNITSCOPE}
  {$IFDEF MSWINDOWS}
  Windows,
  {$ENDIF MSWINDOWS}
  Classes, SysUtils, Controls, Forms, SyncObjs
{$ENDIF ~HAS_UNITSCOPE};

type
  TMGThread = class;
  TMGThreadCancelEvent = procedure(CurrentThread: TMGThread) of object;
  TMGThreadExceptionEvent = procedure (Sender: TObject; E: Exception; EAddr: Pointer) of object;
  TMGNotifyParamsEvent = procedure(Sender: TObject; Params: Pointer) of object;

  TMGCustomThread = class(TThread)
  private
    FThreadName: String;
    function GetThreadName: String; virtual;
    procedure SetThreadName(const Value: String); virtual;
  public
    {$IFNDEF DELPHI2010_UP}
    procedure NameThreadForDebugging(AThreadName: AnsiString; AThreadID: LongWord = $FFFFFFFF);
    {$ENDIF}
    procedure NameThread(AThreadName: AnsiString; AThreadID: LongWord = $FFFFFFFF); {$IFDEF SUPPORTS_UNICODE_STRING} overload; {$ENDIF} virtual;
    {$IFDEF SUPPORTS_UNICODE_STRING}
    procedure NameThread(AThreadName: String; AThreadID: LongWord = $FFFFFFFF); overload;
    {$ENDIF}
    property ThreadName: String read GetThreadName write SetThreadName;
  end;

  TMGPausableThread = class(TMGCustomThread)
  private
    FPauseSection: TCriticalSection;
    FPaused: Boolean;
    procedure SetPaused(const Value: Boolean);
  protected
    procedure EnterUnpauseableSection;
    procedure LeaveUnpauseableSection;
  public
    constructor Create(CreateSuspended: Boolean);
    destructor Destroy; override;
    property Paused: Boolean read FPaused write SetPaused;
  end;

  TMGBaseThread = class(TMGPausableThread)
  private
    FException: Exception;
    FExceptionAddr: Pointer;
    FInternalTerminate: Boolean;
    FExecuteEvent: TMGNotifyParamsEvent;
    FOnResumeDone: Boolean;
    FExecuteIsActive: Boolean;
    FFinished: Boolean;
    FOnException: TMGThreadExceptionEvent;
    FParams: Pointer;
    FSender: TObject;
    FSynchHelpCtx: Longint;
    FSynchMsg: string;
    procedure ExceptionHandler;
  public
    constructor Create(Sender: TObject; Event: TMGNotifyParamsEvent; Params: Pointer); virtual;
    {$IFNDEF COMPILER14_UP}
    procedure Resume;
    {$ENDIF ~COMPILER14_UP}
    procedure ResumeThread;
    procedure Execute; override;
    procedure Synchronize(Method: TThreadMethod);
    property Container: TObject read FSender;
    property ExecuteIsActive: Boolean read FExecuteIsActive;
    property Finished: Boolean read FFinished;
    property Terminated;
    property Params: Pointer read FParams;
    property ReturnValue;
    property OnException: TMGThreadExceptionEvent read FOnException write FOnException;
  end;

  {$IFDEF RTL230_UP}
  [ComponentPlatformsAttribute(pidWin32 or pidWin64 or pidOSX32)]
  {$ENDIF RTL230_UP}
  TMGThread = class(TComponent)
  private
    FBeforeResume: TNotifyEvent;
    FThreads: TThreadList;
    FListLocker: TCriticalSection;
    FLockedList: TList;
    FExclusive: Boolean;
    FMaxCount: Integer;
    FRunOnCreate: Boolean;
    FOnBegin: TNotifyEvent;
    FOnExecute: TMGNotifyParamsEvent;
    FOnFinish: TNotifyEvent;
    FOnFinishAll: TNotifyEvent;
    FFreeOnTerminate: Boolean;
    FOnCancelExecute: TMGThreadCancelEvent;
    FOnException: TMGThreadExceptionEvent;
    {$IFDEF MSWINDOWS}
    FPriority: TThreadPriority;
    {$ENDIF MSWINDOWS}
    FThreadName: String;
    procedure DoBegin;
    procedure DoTerminate(Sender: TObject);
    function GetCount: Integer;
    function GetThreads(Index: Integer): TMGBaseThread;
    function GetTerminated: Boolean;
    procedure SetReturnValue(RetVal: Integer);
    function GetReturnValue: Integer;
    function GetCurrentThread: TMGBaseThread;
    procedure SetThreadName(const Value: String);
  protected
    function GetOneThreadIsRunning: Boolean;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure CancelExecute; virtual;
    function Execute(P: Pointer): TMGBaseThread;
    procedure ExecuteAndWait(P: Pointer);
    procedure ExecuteThreadAndWait(P: Pointer);
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure Synchronize(Method: TThreadMethod);
    procedure Lock;
    procedure Unlock;
    property Count: Integer read GetCount;
    property Threads[Index: Integer]: TMGBaseThread read GetThreads;
    property LastThread: TMGBaseThread read GetCurrentThread;
    property Terminated: Boolean read GetTerminated;
    property ReturnValue: Integer read GetReturnValue write SetReturnValue;
    property OneThreadIsRunning: Boolean read GetOneThreadIsRunning;
    function CalcThreadName(ThreadPos: Integer): String;
    {$IFDEF MSWINDOWS}
    procedure SetPriority(NewPriority: TThreadPriority);
    {$ENDIF MSWINDOWS}
    procedure Resume(BaseThread: TMGBaseThread); overload;
    procedure Resume; overload;
    procedure Suspend;
    procedure Terminate;
    procedure WaitFor;
    procedure RemoveZombie(BaseThread: TMGBaseThread); overload;
    procedure RemoveZombie; overload;
    procedure TerminateWaitFor(iRemoveZombies: Boolean = true);
  published
    property Exclusive: Boolean read FExclusive write FExclusive;
    property MaxCount: Integer read FMaxCount write FMaxCount;
    property RunOnCreate: Boolean read FRunOnCreate write FRunOnCreate;
    property FreeOnTerminate: Boolean read FFreeOnTerminate write FFreeOnTerminate;
    {$IFDEF MSWINDOWS}
    property Priority: TThreadPriority read FPriority write FPriority default tpNormal;
    {$ENDIF MSWINDOWS}
    property ThreadName: String read FThreadName write SetThreadName;
    property BeforeResume: TNotifyEvent read FBeforeResume write FBeforeResume;
    property OnBegin: TNotifyEvent read FOnBegin write FOnBegin;
    property OnCancelExecute: TMGThreadCancelEvent read FOnCancelExecute write FOnCancelExecute;
    property OnExecute: TMGNotifyParamsEvent read FOnExecute write FOnExecute;
    property OnFinish: TNotifyEvent read FOnFinish write FOnFinish;
    property OnFinishAll: TNotifyEvent read FOnFinishAll write FOnFinishAll;
    property OnException: TMGThreadExceptionEvent read FOnException write FOnException;
  end;

implementation

var
  MGCustomThreadNamingProc: procedure (AThreadName: AnsiString; AThreadID: LongWord);

{ TMGCustomThread }

{$IFNDEF DELPHI2010_UP}
procedure TMGCustomThread.NameThreadForDebugging(AThreadName: AnsiString; AThreadID: LongWord = $FFFFFFFF);
type
  TThreadNameInfo = record
    FType: LongWord;     // must be 0x1000
    FName: PAnsiChar;    // pointer to name (in user address space)
    FThreadID: LongWord; // thread ID (-1 indicates caller thread)
    FFlags: LongWord;    // reserved for future use, must be zero
  end;
var
  ThreadNameInfo: TThreadNameInfo;
begin
  //if IsDebuggerPresent then
  begin
    ThreadNameInfo.FType := $1000;
    ThreadNameInfo.FName := PAnsiChar(AThreadName);
    ThreadNameInfo.FThreadID := AThreadID;
    ThreadNameInfo.FFlags := 0;
    try
      RaiseException($406D1388, 0, sizeof(ThreadNameInfo) div sizeof(LongWord), @ThreadNameInfo);
    except
    end;
  end;
end;
{$ENDIF DELPHI2010_UP}

function TMGCustomThread.GetThreadName: String;
begin
  if FThreadName = '' then
    Result := ClassName
  else
    Result := FThreadName+' {'+ClassName+'}';
end;

procedure TMGCustomThread.NameThread(AThreadName: AnsiString; AThreadID: LongWord = $FFFFFFFF);
begin
  if AThreadID = $FFFFFFFF then
    AThreadID := ThreadID;
  NameThreadForDebugging(aThreadName, AThreadID);
  if Assigned(MGCustomThreadNamingProc) then
    MGCustomThreadNamingProc(aThreadName, AThreadID);
end;

{$IFDEF SUPPORTS_UNICODE_STRING}
procedure TMGCustomThread.NameThread(AThreadName: String; AThreadID: LongWord = $FFFFFFFF);
begin
  NameThread(AnsiString(AThreadName), AThreadId);
end;
{$ENDIF}

procedure TMGCustomThread.SetThreadName(const Value: String);
begin
  FThreadName := Value;
end;

{ TMGPausableThread }

constructor TMGPausableThread.Create(CreateSuspended: Boolean);
begin
  FPauseSection := TCriticalSection.Create;
  inherited Create(CreateSuspended);
end;

destructor TMGPausableThread.Destroy;
begin
  if Paused then
  begin
    Terminate;
    Paused := False;
  end;

  inherited Destroy;
  FPauseSection.Free;
end;

procedure TMGPausableThread.EnterUnpauseableSection;
begin
  FPauseSection.Acquire;
end;

procedure TMGPausableThread.LeaveUnpauseableSection;
begin
  FPauseSection.Release;
end;

procedure TMGPausableThread.SetPaused(const Value: Boolean);
begin
  if FPaused <> Value then
  begin
    FPaused := Value;
    if FPaused then
      FPauseSection.Acquire
    else
      FPauseSection.Release;
  end;
  if Suspended and not Paused then
    Suspended := False;
end;

{ TMGBaseThread }

constructor TMGBaseThread.Create(Sender: TObject; Event: TMGNotifyParamsEvent; Params: Pointer);
begin
  inherited Create(True);
  FSender := Sender;
  FExecuteEvent := Event;
  FParams := Params;
end;

procedure TMGBaseThread.ExceptionHandler;
begin
  ShowException(FException, FExceptionAddr);
end;

procedure TMGBaseThread.ResumeThread;
begin
  if not FOnResumeDone then
  begin
    FOnResumeDone := True;
    if (FSender is TMGThread) and Assigned(TMGThread(FSender).BeforeResume) then
      try
        TMGThread(FSender).BeforeResume(Self);
      except
        // Self.Terminate;
        FInternalTerminate := True;
      end;
    FExecuteIsActive := True;
  end;
  {$WARNINGS OFF}
  inherited Resume;     // after suspend too
  {$WARNINGS ON}
end;

{$IFNDEF COMPILER14_UP}
procedure TMGBaseThread.Resume;
begin
  ResumeThread;
end;
{$ENDIF ~COMPILER14_UP}

procedure TMGBaseThread.Execute;
begin
  try
    FExecuteIsActive := True;
    NameThread(ThreadName);
    if FInternalTerminate then
      Terminate;
    FExecuteEvent(Self, FParams);
  except
    on E: Exception do
    if Assigned(OnException) then
      OnException(self, E, ExceptAddr)
    else
    begin
      FException := E;
      FExceptionAddr := ExceptAddr;
      Synchronize(ExceptionHandler);
    end;
  end;
end;

procedure TMGBaseThread.Synchronize(Method: TThreadMethod);
begin
  inherited Synchronize(Method);
end;

{ TMGThread }

constructor TMGThread.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FRunOnCreate := True;
  FExclusive := True;
  FFreeOnTerminate := True;
  FThreads := TThreadList.Create;
  FListLocker := TCriticalSection.Create;
  {$IFDEF MSWINDOWS}
  FPriority := tpNormal;
  {$ENDIF MSWINDOWS}
end;

destructor TMGThread.Destroy;
begin
  Terminate;
  while OneThreadIsRunning do
  begin
    Sleep(1);
    CheckSynchronize;
  end;
  FThreads.Free;
  FListLocker.Free;
  inherited Destroy;
end;

function TMGThread.CalcThreadName(ThreadPos: Integer): String;
begin
  if ThreadName = '' then
    Result := Name
  else
    Result := ThreadName;
  if Result = '' then
    Result := ClassName;
  if ThreadPos > 0 then
    Result := Result + ' ['+Inttostr(ThreadPos)+']';
end;

procedure TMGThread.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
end;

function TMGThread.Execute(P: Pointer): TMGBaseThread;
var
  BaseThread: TMGBaseThread;
begin
  BaseThread := nil;
  if not ((Exclusive and OneThreadIsRunning) or ((FMaxCount > 0) and (Count >= FMaxCount))) and
     Assigned(FOnExecute) then
  begin
    try
      BaseThread := TMGBaseThread.Create(Self, FOnExecute, P);
      BaseThread.FreeOnTerminate := FFreeOnTerminate;
      BaseThread.OnException := OnException;
      {$IFDEF MSWINDOWS}
      BaseThread.Priority := Priority;
      {$ENDIF MSWINDOWS}
      BaseThread.OnTerminate := DoTerminate;
      BaseThread.ThreadName := CalcThreadName(Count);
      FThreads.Add(BaseThread);
      DoBegin;
    except
      if Assigned(BaseThread) then
        BaseThread.FInternalTerminate := True;
    end;

    if FRunOnCreate and Assigned(BaseThread) then
      Resume(BaseThread);
  end;
  Result := BaseThread;
end;

procedure TMGThread.DoBegin;
begin
  if Assigned(FOnBegin) then
    FOnBegin(Self);
end;

procedure TMGThread.ExecuteAndWait(P: Pointer);
var
  B: Boolean;
  Thread: TMGBaseThread;
begin
  B := FRunOnCreate;
  FRunOnCreate := True;
  try
    Thread := Execute(P);
  finally
    FRunOnCreate := B;
  end;

  if Assigned(Thread) then
    WaitFor;
end;

procedure TMGThread.ExecuteThreadAndWait(P: Pointer);
var
  B: Boolean;
  Thread: TMGBaseThread;
begin
  B := FRunOnCreate;
  FRunOnCreate := True;
  try
    Thread := Execute(P);
  finally
    FRunOnCreate := B;
  end;
  if Assigned(Thread) then
    while (not Thread.Finished) do
      Application.HandleMessage;
end;

procedure TMGThread.Resume(BaseThread: TMGBaseThread);
{var
  B: Boolean;}
begin
  if Assigned(BaseThread) then
  begin
    //B := BaseThread.FOnResumeDone;
    BaseThread.ResumeThread;
  end
  else
    Resume;
end;

procedure TMGThread.Resume;
var
  List: TList;
  I: Integer;
  Thread: TMGBaseThread;
begin
  List := FThreads.LockList;
  try
    for I := 0 to List.Count - 1 do
    begin
      Thread := TMGBaseThread(List[I]);
      while Thread.Suspended do
        Resume(Thread);
    end;
  finally
    FThreads.UnlockList;
  end;
end;

procedure TMGThread.Suspend;
var
  List: TList;
  I: Integer;
  Thread: TMGBaseThread;
begin
  Thread := GetCurrentThread;
  if Assigned(Thread) then
    Thread.Suspended := True
  else
  begin
    List := FThreads.LockList;
    try
      for I := 0 to List.Count - 1 do
        try
          Thread := TMGBaseThread(List[I]);
          if not Thread.Finished then
            Thread.Suspended := True
        except
        end;
    finally
      FThreads.UnlockList;
    end;
  end;
end;

procedure TMGThread.Terminate;
var
  List: TList;
  I: Integer;
begin
  List := FThreads.LockList;
  try
    for I := 0 to List.Count - 1 do
      TMGBaseThread(List[I]).Terminate;
    Resume;
  finally
    FThreads.UnlockList;
  end;
end;

procedure TMGThread.CancelExecute;
begin
  if Assigned(fOnCancelExecute) then
    fOnCancelExecute (Self)
  else
    Terminate;
end;

procedure TMGThread.DoTerminate(Sender: TObject);
begin
  TMGBaseThread(Sender).FExecuteIsActive := False;
  if Assigned(FOnFinish) then
    try
      FOnFinish(Sender);
    except
    end;
  if TMGBaseThread(Sender).FreeOnTerminate then
    FThreads.Remove(Sender);
  TMGBaseThread(Sender).FFinished := True;

  if Count = 0 then
  begin
    if Assigned(FOnFinishAll) then
      try
        FOnFinishAll(Self);
      except
      end;
  end;
end;

procedure TMGThread.RemoveZombie(BaseThread: TMGBaseThread);
begin
  if Assigned(BaseThread) then
  begin
    if BaseThread.FFinished and (not BaseThread.FreeOnTerminate) then
    begin
      FThreads.Remove(BaseThread);
      BaseThread.Free;
    end;
  end
  else
    RemoveZombie;
end;

procedure TMGThread.RemoveZombie;
var
  List: TList;
  I: Integer;
  Thread: TMGBaseThread;
begin
  List := FThreads.LockList;
  try
    for I := List.Count - 1 downto 0 do
    begin
      Thread := TMGBaseThread(List[I]);
      if Thread.FFinished and (not Thread.FreeOnTerminate) then
      begin
        FThreads.Remove(Thread);
        Thread.Free;
      end;
    end;
  finally
    FThreads.UnlockList;
  end;
end;

function TMGThread.GetTerminated: Boolean;
var
  H: DWORD;
  List: TList;
  I: Integer;
  Thread: TMGBaseThread;
begin
  H := GetCurrentThreadID;
  Result := True;
  List:=FThreads.LockList;
  try
    for I := 0 to List.Count - 1 do
    begin
      Thread := TMGBaseThread(List[I]);
      if Thread.ThreadID = H then
      begin
        Result := Thread.Terminated;
        Break;
      end
      else
        Result := Result and Thread.Terminated;
    end;
  finally
    FThreads.UnlockList;
  end;
end;

procedure TMGThread.WaitFor;
begin
  while OneThreadIsRunning do
    Application.HandleMessage;
end;

procedure TMGThread.SetReturnValue(RetVal: Integer);
var
  Thread: TMGBaseThread;
begin
  Thread := GetCurrentThread;
  if Assigned(Thread) then
    Thread.ReturnValue := RetVal;
end;

function TMGThread.GetReturnValue: Integer;
var
  Thread: TMGBaseThread;
begin
  Thread := GetCurrentThread;
  if Assigned(Thread) then
    Result := Thread.ReturnValue
  else
    Result := 0;
end;

function TMGThread.GetCount: Integer;
var
  List: TList;
begin
  List := FThreads.LockList;
  try
    Result := List.Count;
  finally
    FThreads.UnlockList;
  end;
end;

function TMGThread.GetCurrentThread: TMGBaseThread;
var
  H: DWORD;
  List: TList;
  I: Integer;
  Thread: TMGBaseThread;
begin
  Result := nil;
  H := GetCurrentThreadID;
  List := FThreads.LockList;
  try
    for I := 0 to List.Count - 1 do
    begin
      Thread := TMGBaseThread(List[I]);
      if Thread.ThreadID = H then
      begin
        Result := Thread;
        Break;
      end;
    end;
  finally
    FThreads.UnlockList;
  end;
end;

function TMGThread.GetOneThreadIsRunning: Boolean;
var
  I: Integer;
  List: TList;
begin
  Result := False;
  List := FThreads.LockList;
  try
    for I := 0 to List.Count - 1 do
    begin
      Result := not TMGBaseThread(List[I]).Finished;
      if Result then
        Break;
    end;
  finally
    FThreads.UnlockList;
  end;
end;

procedure TMGThread.Lock;
begin
 FListLocker.Acquire;
 try
   if not Assigned(FLockedList) then
     FLockedList := FThreads.LockList;
 except
   FListLocker.Release;
   raise;
 end;
end;

function TMGThread.GetThreads(Index: Integer): TMGBaseThread;
begin
  FListLocker.Acquire;
  try
    if Assigned(FLockedList) then
      Result := TMGBaseThread(FLockedList[Index])
    else
      Result := nil;
  finally
   FListLocker.Release;
 end;
end;

procedure TMGThread.Unlock;
begin
 try
   if Assigned(FLockedList) then
   begin
     FThreads.UnlockList;
     FLockedList := nil;
   end;
 finally
   FListLocker.Release;
 end;
end;

procedure TMGThread.Synchronize(Method: TThreadMethod);
var
  Thread: TMGBaseThread;
begin
  Thread := GetCurrentThread;
  if Assigned(Thread) then
    Thread.Synchronize(Method)
  else
    Method;
end;

{$IFDEF MSWINDOWS}
procedure TMGThread.SetPriority(NewPriority: TThreadPriority);
var
  List: TList;
  Thread: TMGBaseThread;
  I: Integer;
begin
  List := FThreads.LockList;
  try
    Thread := GetCurrentThread;
    if Assigned(Thread) then
      Thread.Priority := NewPriority
    else
    begin
      for I := 0 to List.Count - 1 do
        TMGBaseThread(List[I]).Priority := NewPriority;
      Priority := NewPriority;
    end;
  finally
    FThreads.UnlockList;
  end;
end;
{$ENDIF MSWINDOWS}

procedure TMGThread.SetThreadName(const Value: String);
var
  i: Integer;
begin
  FThreadName := Value;
  Lock;
  try
    for i := 0 to Count -1 do
      if Assigned(Threads[i]) then
        Threads[i].ThreadName := CalcThreadName(i);
  finally
    UnLock;
  end;
end;

procedure TMGThread.TerminateWaitFor(iRemoveZombies: Boolean = true);
begin
  Terminate;
  WaitFor;
  if iRemoveZombies then
    RemoveZombie;
end;

begin
end.
