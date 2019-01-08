{ ############################################################################ }
{ #                                                                          # }
{ #  MGSoft Delphi Components v1.0.0                                         # }
{ #                                                                          # }
{ #  License: GPLv3                                                          # }
{ #                                                                          # }
{ #  Author: Mikhail Grigorev (icq: 161867489, email: sleuthhound@gmail.com) # }
{ #                                                                          # }
{ ############################################################################ }

unit MGTextReader;

{$I MGSoft.inc}

interface

uses
{$IFDEF HAS_UNITSCOPE}
  {$IFDEF MSWINDOWS}
  Winapi.Windows,
  {$ENDIF MSWINDOWS}
  System.Classes, System.SysUtils,
{$ELSE ~HAS_UNITSCOPE}
  {$IFDEF MSWINDOWS}
  Windows,
  {$ENDIF MSWINDOWS}
  Classes, SysUtils,
{$ENDIF ~HAS_UNITSCOPE}
  MGUtils;

const
  AnsiLineFeed          = AnsiChar(#10);
  AnsiCarriageReturn    = AnsiChar(#13);
  NativeLineFeed        = Char(#10);
  NativeCarriageReturn  = Char(#13);

type
  EMGFileMappingError = class(EMGSoftError);
  EMGFileMappingViewError = class(EMGSoftError);
  {$IFDEF CPU32}
  TMGAddr = Cardinal;
  {$ENDIF CPU32}
  {$IFDEF CPU64}
  TMGAddr = {$IFDEF DELPHI2007_UP}UInt64{$ELSE}Int64{$ENDIF};
  {$ENDIF CPU64}

  TMGFileMappingStream = class(TCustomMemoryStream)
  private
    FFileHandle: THandle;
    FMapping: THandle;
  protected
    procedure Close;
  public
    constructor Create(const FileName: String; FileMode: Word = fmOpenRead or fmShareDenyNone{fmShareDenyWrite});
    destructor Destroy; override;
    function Write(const Buffer; Count: Longint): Longint; override;
  end;

  TMGMappedTextReaderIndex = (tiNoIndex, tiFull);

  PPAnsiCharArray = ^TPAnsiCharArray;
  TPAnsiCharArray = Array [0..0] of PAnsiChar;

  TMGTextReaderA = class(TPersistent)
  private
    FContent: PAnsiChar;
    FEnd: PAnsiChar;
    FIndex: PPAnsiCharArray;
    FIndexOption: TMGMappedTextReaderIndex;
    FFreeStream: Boolean;
    FLastLineNumber: Integer;
    FLastPosition: PAnsiChar;
    FLineCount: Integer;
    FMemoryStream: TCustomMemoryStream;
    FPosition: PAnsiChar;
    FSize: Integer;
    function GetAsString: AnsiString;
    function GetEof: Boolean;
    function GetChars(Index: Integer): AnsiChar;
    function GetLineCount: Integer;
    function GetLines(LineNumber: Integer): AnsiString;
    function GetPosition: Integer;
    function GetPositionFromLine(LineNumber: Integer): Integer;
    procedure SetPosition(const Value: Integer);
  protected
    procedure AssignTo(Dest: TPersistent); override;
    procedure CreateIndex;
    procedure Init;
    function PtrFromLine(LineNumber: Integer): PAnsiChar;
    function StringFromPosition(var StartPos: PAnsiChar): AnsiString;
  public
    constructor Create(MemoryStream: TCustomMemoryStream; FreeStream: Boolean = True;
      const AIndexOption: TMGMappedTextReaderIndex = tiNoIndex); overload;
    constructor Create(const FileName: TFileName;
      const AIndexOption: TMGMappedTextReaderIndex = tiNoIndex); overload;
    destructor Destroy; override;
    procedure GoBegin;
    function Read: AnsiChar;
    function ReadLn: AnsiString;
    property AsString: AnsiString read GetAsString;
    property Chars[Index: Integer]: AnsiChar read GetChars;
    property Content: PAnsiChar read FContent;
    property Eof: Boolean read GetEof;
    property IndexOption: TMGMappedTextReaderIndex read FIndexOption;
    property Lines[LineNumber: Integer]: AnsiString read GetLines;
    property LineCount: Integer read GetLineCount;
    property PositionFromLine[LineNumber: Integer]: Integer read GetPositionFromLine;
    property Position: Integer read GetPosition write SetPosition;
    property Size: Integer read FSize;
  end;

  PPWideCharArray = ^TPWideCharArray;
  TPWideCharArray = Array [0..0] of PWideChar;

  TMGTextReaderW = class(TPersistent)
  private
    FContent: PWideChar;
    FEnd: PWideChar;
    FIndex: PPWideCharArray;
    FIndexOption: TMGMappedTextReaderIndex;
    FFreeStream: Boolean;
    FLastLineNumber: Integer;
    FLastPosition: PWideChar;
    FLineCount: Integer;
    FMemoryStream: TCustomMemoryStream;
    FPosition: PWideChar;
    FSize: Integer;
    function GetAsString: WideString;
    function GetEof: Boolean;
    function GetChars(Index: Integer): WideChar;
    function GetLineCount: Integer;
    function GetLines(LineNumber: Integer): WideString;
    function GetPosition: Integer;
    function GetPositionFromLine(LineNumber: Integer): Integer;
    procedure SetPosition(const Value: Integer);
  protected
    procedure AssignTo(Dest: TPersistent); override;
    procedure CreateIndex;
    procedure Init;
    function PtrFromLine(LineNumber: Integer): PWideChar;
    function StringFromPosition(var StartPos: PWideChar): WideString;
  public
    constructor Create(MemoryStream: TCustomMemoryStream; FreeStream: Boolean = True;
      const AIndexOption: TMGMappedTextReaderIndex = tiNoIndex); overload;
    constructor Create(const FileName: TFileName;
      const AIndexOption: TMGMappedTextReaderIndex = tiNoIndex); overload;
    destructor Destroy; override;
    procedure GoBegin;
    function Read: WideChar;
    function ReadLn: WideString;
    property AsString: WideString read GetAsString;
    property Chars[Index: Integer]: WideChar read GetChars;
    property Content: PWideChar read FContent;
    property Eof: Boolean read GetEof;
    property IndexOption: TMGMappedTextReaderIndex read FIndexOption;
    property Lines[LineNumber: Integer]: WideString read GetLines;
    property LineCount: Integer read GetLineCount;
    property PositionFromLine[LineNumber: Integer]: Integer read GetPositionFromLine;
    property Position: Integer read GetPosition write SetPosition;
    property Size: Integer read FSize;
  end;

  function CharIsReturn(const C: AnsiChar): Boolean; {$IFDEF SUPPORTS_INLINE} inline; {$ENDIF}{$IFDEF DELPHI2009_UP}overload;{$ENDIF DELPHI2009_UP}
  {$IFDEF DELPHI2009_UP}
  function CharIsReturn(const C: Char): Boolean; {$IFDEF SUPPORTS_INLINE} inline; {$ENDIF}overload;
  {$ENDIF DELPHI2009_UP}

implementation

{ TMGFileMappingStream }

constructor TMGFileMappingStream.Create(const FileName: String; FileMode: Word);
var
  Protect, Access, Size: DWORD;
  BaseAddress: Pointer;
begin
  inherited Create;
  FFileHandle := THandle(FileOpen(FileName, FileMode));
  if FFileHandle = INVALID_HANDLE_VALUE then
    RaiseLastOSError;
  if (FileMode and $0F) = fmOpenReadWrite then
  begin
    Protect := PAGE_WRITECOPY;
    Access := FILE_MAP_COPY;
  end
  else
  begin
    Protect := PAGE_READONLY;
    Access := FILE_MAP_READ;
  end;
  FMapping := CreateFileMapping(FFileHandle, nil, Protect, 0, 0, nil);
  if FMapping = 0 then
  begin
    Close;
    raise EMGFileMappingError.CreateRes(@rsCreateFileMapping);
  end;
  BaseAddress := MapViewOfFile(FMapping, Access, 0, 0, 0);
  if BaseAddress = nil then
  begin
    Close;
    raise EMGFileMappingViewError.CreateRes(@rsCreateFileMappingView);
  end;
  Size := GetFileSize(FFileHandle, nil);
  if Size = DWORD(-1) then
  begin
    UnMapViewOfFile(BaseAddress);
    Close;
    raise EMGFileMappingViewError.CreateRes(@rsFailedToObtainSize);
  end;
  SetPointer(BaseAddress, Size);
end;

destructor TMGFileMappingStream.Destroy;
begin
  Close;
  inherited Destroy;
end;

procedure TMGFileMappingStream.Close;
begin
  if Memory <> nil then
  begin
    UnMapViewOfFile(Memory);
    SetPointer(nil, 0);
  end;
  if FMapping <> 0 then
  begin
    CloseHandle(FMapping);
    FMapping := 0;
  end;
  if FFileHandle <> INVALID_HANDLE_VALUE then
  begin
    FileClose(FFileHandle);
    FFileHandle := INVALID_HANDLE_VALUE;
  end;
end;

function TMGFileMappingStream.Write(const Buffer; Count: Integer): Longint;
begin
  Result := 0;
  if (Size - Position) >= Count then
  begin
    System.Move(Buffer, Pointer(TMGAddr(Memory) + TMGAddr(Position))^, Count);
    Position := Position + Count;
    Result := Count;
  end;
end;

{ TMGTextReaderA }

constructor TMGTextReaderA.Create(MemoryStream: TCustomMemoryStream; FreeStream: Boolean;
  const AIndexOption: TMGMappedTextReaderIndex);
begin
  inherited Create;
  FMemoryStream := MemoryStream;
  FFreeStream := FreeStream;
  FIndexOption := AIndexOption;
  Init;
end;

constructor TMGTextReaderA.Create(const FileName: TFileName;
  const AIndexOption: TMGMappedTextReaderIndex);
begin
  inherited Create;
  {$IFDEF MSWINDOWS}
  FMemoryStream := TMGFileMappingStream.Create(FileName);
  {$ELSE ~ MSWINDOWS}
  FMemoryStream := TMemoryStream.Create;
  TMemoryStream(FMemoryStream).LoadFromFile(FileName);
  {$ENDIF ~ MSWINDOWS}
  FFreeStream := True;
  FIndexOption := AIndexOption;
  Init;
end;

destructor TMGTextReaderA.Destroy;
begin
  if FFreeStream then
    FMemoryStream.Free;
  FreeMem(FIndex);
  inherited Destroy;
end;

procedure TMGTextReaderA.AssignTo(Dest: TPersistent);
begin
  if Dest is TStrings then
  begin
    GoBegin;
    TStrings(Dest).BeginUpdate;
    try
      while not Eof do
        TStrings(Dest).Add(string(ReadLn));
    finally
      TStrings(Dest).EndUpdate;
    end;
  end
  else
    inherited AssignTo(Dest);
end;

procedure TMGTextReaderA.CreateIndex;
var
  P, LastLineStart: PAnsiChar;
  I: Integer;
begin
  {$RANGECHECKS OFF}
  P := FContent;
  I := 0;
  LastLineStart := P;
  while P < FEnd do
  begin
    // CRLF, CR, LF and LFCR are seen as valid sets of chars for EOL marker
    if CharIsReturn(Char(P^)) then
    begin
      if I and $FFFF = 0 then
        ReallocMem(FIndex, (I + $10000) * SizeOf(Pointer));
      FIndex[I] := LastLineStart;
      Inc(I);

      case P^ of
        NativeLineFeed:
          begin
            Inc(P);
            if (P < FEnd) and (P^ = NativeCarriageReturn) then
             Inc(P);
          end;
        NativeCarriageReturn:
          begin
            Inc(P);
            if (P < FEnd) and (P^ = NativeLineFeed) then
              Inc(P);
          end;
      end;
      LastLineStart := P;
    end
    else
      Inc(P);
  end;
  if P > LastLineStart then
  begin
    ReallocMem(FIndex, (I + 1) * SizeOf(Pointer));
    FIndex[I] := LastLineStart;
    Inc(I);
  end
  else
    ReallocMem(FIndex, I * SizeOf(Pointer));
  FLineCount := I;
  {$IFDEF RANGECHECKS_ON}
  {$RANGECHECKS ON}
  {$ENDIF RANGECHECKS_ON}
end;

function TMGTextReaderA.GetEof: Boolean;
begin
  Result := FPosition >= FEnd;
end;

function TMGTextReaderA.GetAsString: AnsiString;
begin
  SetString(Result, Content, Size);
end;

function TMGTextReaderA.GetChars(Index: Integer): AnsiChar;
begin
  if (Index < 0) or (Index >= Size) then
    raise EMGSoftError.CreateRes(@rsFileIndexOutOfRange);
  Result := AnsiChar(PByte(FContent + Index)^);
end;

function TMGTextReaderA.GetLineCount: Integer;
var
  P: PAnsiChar;
begin
  if FLineCount = -1 then
  begin
    FLineCount := 0;
    if FContent < FEnd then
    begin
      P := FContent;
      while P < FEnd do
      begin
        case P^ of
          NativeLineFeed:
            begin
              Inc(FLineCount);
              Inc(P);
              if (P < FEnd) and (P^ = NativeCarriageReturn) then
                Inc(P);
            end;
          NativeCarriageReturn:
            begin
              Inc(FLineCount);
              Inc(P);
              if (P < FEnd) and (P^ = NativeLineFeed) then
                Inc(P);
            end;
        else
          Inc(P);
        end;
      end;
      if (P = FEnd) and (P > FContent) and not CharIsReturn(Char((P-1)^)) then
        Inc(FLineCount);
    end;
  end;

  Result := FLineCount;
end;

function TMGTextReaderA.GetLines(LineNumber: Integer): AnsiString;
var
  P: PAnsiChar;
begin
  P := PtrFromLine(LineNumber);
  Result := StringFromPosition(P);
end;

function TMGTextReaderA.GetPosition: Integer;
begin
  Result := FPosition - FContent;
end;

procedure TMGTextReaderA.GoBegin;
begin
  Position := 0;
end;

procedure TMGTextReaderA.Init;
begin
  FContent := FMemoryStream.Memory;
  FSize := FMemoryStream.Size;
  FEnd := FContent + FSize;
  FPosition := FContent;
  FLineCount := -1;
  FLastLineNumber := 0;
  FLastPosition := FContent;
  if IndexOption = tiFull then
    CreateIndex;
end;

function TMGTextReaderA.GetPositionFromLine(LineNumber: Integer): Integer;
var
  P: PAnsiChar;
begin
  P := PtrFromLine(LineNumber);
  if P = nil then
    Result := -1
  else
    Result := P - FContent;
end;

function TMGTextReaderA.PtrFromLine(LineNumber: Integer): PAnsiChar;
var
  LineOffset: Integer;
begin
  Result := nil;
  {$RANGECHECKS OFF}
  if (IndexOption <> tiNoIndex) and (LineNumber < FLineCount) and (FIndex[LineNumber] <> nil) then
    Result := FIndex[LineNumber]
  {$IFDEF RANGECHECKS_ON}
  {$RANGECHECKS ON}
  {$ENDIF RANGECHECKS_ON}
  else
  begin
    LineOffset := LineNumber - FLastLineNumber;
    if (FLineCount <> -1) and (LineNumber > 0) then
    begin
      if -LineOffset > LineNumber then
      begin
        FLastLineNumber := 0;
        FLastPosition := FContent;
        LineOffset := LineNumber;
      end
      else
      if LineOffset > FLineCount - LineNumber then
      begin
        FLastLineNumber := FLineCount;
        FLastPosition := FEnd;
        LineOffset := LineNumber - FLineCount;
      end;
    end;
    if LineNumber <= 0 then
      Result := FContent
    else
    if LineOffset = 0 then
      Result := FLastPosition
    else
    if LineOffset > 0 then
    begin
      Result := FLastPosition;
      while (Result < FEnd) and (LineOffset > 0) do
      begin
        case Result^ of
          NativeLineFeed:
            begin
              Dec(LineOffset);
              Inc(Result);
              if (Result < FEnd) and (Result^ = NativeCarriageReturn) then
                Inc(Result);
            end;
          NativeCarriageReturn:
            begin
              Dec(LineOffset);
              Inc(Result);
              if (Result < FEnd) and (Result^ = NativeLineFeed) then
                Inc(Result);
            end;
        else
          Inc(Result);
        end;
      end;
    end
    else
    if LineOffset < 0 then
    begin
      Result := FLastPosition;
      while (Result > FContent) and (LineOffset < 1) do
      begin
        Dec(Result);
        case Result^ of
          NativeLineFeed:
            begin
              Inc(LineOffset);
              if LineOffset >= 1 then
                Inc(Result)
              else
              if (Result > FContent) and ((Result-1)^ = NativeCarriageReturn) then
                Dec(Result);
            end;
          NativeCarriageReturn:
            begin
              Inc(LineOffset);
              if LineOffset >= 1 then
                Inc(Result)
              else
              if (Result > FContent) and ((Result-1)^ = NativeLineFeed) then
                Dec(Result);
            end;
        end;
      end;
    end;
    FLastLineNumber := LineNumber;
    FLastPosition := Result;
  end;
end;

function TMGTextReaderA.Read: AnsiChar;
begin
  if FPosition >= FEnd then
    Result := #0
  else
  begin
    Result := FPosition^;
    Inc(FPosition);
  end;
end;

function TMGTextReaderA.ReadLn: AnsiString;
begin
  Result := StringFromPosition(FPosition);
end;

procedure TMGTextReaderA.SetPosition(const Value: Integer);
begin
  FPosition := FContent + Value;
end;

function TMGTextReaderA.StringFromPosition(var StartPos: PAnsiChar): AnsiString;
var
  P: PAnsiChar;
begin
  if (StartPos = nil) or (StartPos >= FEnd) then
    Result := ''
  else
  begin
    P := StartPos;
    while (P < FEnd) and (not CharIsReturn(Char(P^))) do
      Inc(P);
    SetString(Result, StartPos, P - StartPos);
    if P < FEnd then
    begin
      case P^ of
        NativeLineFeed:
          begin
            Inc(P);
            if (P < FEnd) and (P^ = NativeCarriageReturn) then
              Inc(P);
          end;
        NativeCarriageReturn:
          begin
            Inc(P);
            if (P < FEnd) and (P^ = NativeLineFeed) then
              Inc(P);
          end;
      end;
    end;
    StartPos := P;
  end;
end;

{ TMGTextReaderW }

constructor TMGTextReaderW.Create(MemoryStream: TCustomMemoryStream; FreeStream: Boolean;
  const AIndexOption: TMGMappedTextReaderIndex);
begin
  inherited Create;
  FMemoryStream := MemoryStream;
  FFreeStream := FreeStream;
  FIndexOption := AIndexOption;
  Init;
end;

constructor TMGTextReaderW.Create(const FileName: TFileName;
  const AIndexOption: TMGMappedTextReaderIndex);
begin
  inherited Create;
  {$IFDEF MSWINDOWS}
  FMemoryStream := TMGFileMappingStream.Create(FileName);
  {$ELSE ~ MSWINDOWS}
  FMemoryStream := TMemoryStream.Create;
  TMemoryStream(FMemoryStream).LoadFromFile(FileName);
  {$ENDIF ~ MSWINDOWS}
  FFreeStream := True;
  FIndexOption := AIndexOption;
  Init;
end;

destructor TMGTextReaderW.Destroy;
begin
  if FFreeStream then
    FMemoryStream.Free;
  FreeMem(FIndex);
  inherited Destroy;
end;

procedure TMGTextReaderW.AssignTo(Dest: TPersistent);
begin
  if Dest is TStrings then
  begin
    GoBegin;
    TStrings(Dest).BeginUpdate;
    try
      while not Eof do
        TStrings(Dest).Add(string(ReadLn));
    finally
      TStrings(Dest).EndUpdate;
    end;
  end
  else
    inherited AssignTo(Dest);
end;

procedure TMGTextReaderW.CreateIndex;
var
  P, LastLineStart: PWideChar;
  I: Integer;
begin
  {$RANGECHECKS OFF}
  P := FContent;
  I := 0;
  LastLineStart := P;
  while P < FEnd do
  begin
    // CRLF, CR, LF and LFCR are seen as valid sets of chars for EOL marker
    if CharIsReturn(Char(P^)) then
    begin
      if I and $FFFF = 0 then
        ReallocMem(FIndex, (I + $10000) * SizeOf(Pointer));
      FIndex[I] := LastLineStart;
      Inc(I);

      case P^ of
        NativeLineFeed:
          begin
            Inc(P);
            if (P < FEnd) and (P^ = NativeCarriageReturn) then
             Inc(P);
          end;
        NativeCarriageReturn:
          begin
            Inc(P);
            if (P < FEnd) and (P^ = NativeLineFeed) then
              Inc(P);
          end;
      end;
      LastLineStart := P;
    end
    else
      Inc(P);
  end;
  if P > LastLineStart then
  begin
    ReallocMem(FIndex, (I + 1) * SizeOf(Pointer));
    FIndex[I] := LastLineStart;
    Inc(I);
  end
  else
    ReallocMem(FIndex, I * SizeOf(Pointer));
  FLineCount := I;
  {$IFDEF RANGECHECKS_ON}
  {$RANGECHECKS ON}
  {$ENDIF RANGECHECKS_ON}
end;

function TMGTextReaderW.GetEof: Boolean;
begin
  Result := FPosition >= FEnd;
end;

function TMGTextReaderW.GetAsString: WideString;
begin
  SetString(Result, Content, Size);
end;

function TMGTextReaderW.GetChars(Index: Integer): WideChar;
begin
  if (Index < 0) or (Index >= Size) then
    raise EMGSoftError.CreateRes(@rsFileIndexOutOfRange);
  Result := WideChar(PByte(FContent + Index)^);
end;

function TMGTextReaderW.GetLineCount: Integer;
var
  P: PWideChar;
begin
  if FLineCount = -1 then
  begin
    FLineCount := 0;
    if FContent < FEnd then
    begin
      P := FContent;
      while P < FEnd do
      begin
        case P^ of
          NativeLineFeed:
            begin
              Inc(FLineCount);
              Inc(P);
              if (P < FEnd) and (P^ = NativeCarriageReturn) then
                Inc(P);
            end;
          NativeCarriageReturn:
            begin
              Inc(FLineCount);
              Inc(P);
              if (P < FEnd) and (P^ = NativeLineFeed) then
                Inc(P);
            end;
        else
          Inc(P);
        end;
      end;
      if (P = FEnd) and (P > FContent) and not CharIsReturn(Char((P-1)^)) then
        Inc(FLineCount);
    end;
  end;

  Result := FLineCount;
end;

function TMGTextReaderW.GetLines(LineNumber: Integer): WideString;
var
  P: PWideChar;
begin
  P := PtrFromLine(LineNumber);
  Result := StringFromPosition(P);
end;

function TMGTextReaderW.GetPosition: Integer;
begin
  Result := FPosition - FContent;
end;

procedure TMGTextReaderW.GoBegin;
begin
  Position := 0;
end;

procedure TMGTextReaderW.Init;
begin
  FContent := FMemoryStream.Memory;
  FSize := FMemoryStream.Size;
  FEnd := FContent + FSize;
  FPosition := FContent;
  FLineCount := -1;
  FLastLineNumber := 0;
  FLastPosition := FContent;
  if IndexOption = tiFull then
    CreateIndex;
end;

function TMGTextReaderW.GetPositionFromLine(LineNumber: Integer): Integer;
var
  P: PWideChar;
begin
  P := PtrFromLine(LineNumber);
  if P = nil then
    Result := -1
  else
    Result := P - FContent;
end;

function TMGTextReaderW.PtrFromLine(LineNumber: Integer): PWideChar;
var
  LineOffset: Integer;
begin
  Result := nil;
  {$RANGECHECKS OFF}
  if (IndexOption <> tiNoIndex) and (LineNumber < FLineCount) and (FIndex[LineNumber] <> nil) then
    Result := FIndex[LineNumber]
  {$IFDEF RANGECHECKS_ON}
  {$RANGECHECKS ON}
  {$ENDIF RANGECHECKS_ON}
  else
  begin
    LineOffset := LineNumber - FLastLineNumber;
    if (FLineCount <> -1) and (LineNumber > 0) then
    begin
      if -LineOffset > LineNumber then
      begin
        FLastLineNumber := 0;
        FLastPosition := FContent;
        LineOffset := LineNumber;
      end
      else
      if LineOffset > FLineCount - LineNumber then
      begin
        FLastLineNumber := FLineCount;
        FLastPosition := FEnd;
        LineOffset := LineNumber - FLineCount;
      end;
    end;
    if LineNumber <= 0 then
      Result := FContent
    else
    if LineOffset = 0 then
      Result := FLastPosition
    else
    if LineOffset > 0 then
    begin
      Result := FLastPosition;
      while (Result < FEnd) and (LineOffset > 0) do
      begin
        case Result^ of
          NativeLineFeed:
            begin
              Dec(LineOffset);
              Inc(Result);
              if (Result < FEnd) and (Result^ = NativeCarriageReturn) then
                Inc(Result);
            end;
          NativeCarriageReturn:
            begin
              Dec(LineOffset);
              Inc(Result);
              if (Result < FEnd) and (Result^ = NativeLineFeed) then
                Inc(Result);
            end;
        else
          Inc(Result);
        end;
      end;
    end
    else
    if LineOffset < 0 then
    begin
      Result := FLastPosition;
      while (Result > FContent) and (LineOffset < 1) do
      begin
        Dec(Result);
        case Result^ of
          NativeLineFeed:
            begin
              Inc(LineOffset);
              if LineOffset >= 1 then
                Inc(Result)
              else
              if (Result > FContent) and ((Result-1)^ = NativeCarriageReturn) then
                Dec(Result);
            end;
          NativeCarriageReturn:
            begin
              Inc(LineOffset);
              if LineOffset >= 1 then
                Inc(Result)
              else
              if (Result > FContent) and ((Result-1)^ = NativeLineFeed) then
                Dec(Result);
            end;
        end;
      end;
    end;
    FLastLineNumber := LineNumber;
    FLastPosition := Result;
  end;
end;

function TMGTextReaderW.Read: WideChar;
begin
  if FPosition >= FEnd then
    Result := #0
  else
  begin
    Result := FPosition^;
    Inc(FPosition);
  end;
end;

function TMGTextReaderW.ReadLn: WideString;
begin
  Result := StringFromPosition(FPosition);
end;

procedure TMGTextReaderW.SetPosition(const Value: Integer);
begin
  FPosition := FContent + Value;
end;

function TMGTextReaderW.StringFromPosition(var StartPos: PWideChar): WideString;
var
  P: PWideChar;
begin
  if (StartPos = nil) or (StartPos >= FEnd) then
    Result := ''
  else
  begin
    P := StartPos;
    while (P < FEnd) and (not CharIsReturn(Char(P^))) do
      Inc(P);
    SetString(Result, StartPos, P - StartPos);
    if P < FEnd then
    begin
      case P^ of
        NativeLineFeed:
          begin
            Inc(P);
            if (P < FEnd) and (P^ = NativeCarriageReturn) then
              Inc(P);
          end;
        NativeCarriageReturn:
          begin
            Inc(P);
            if (P < FEnd) and (P^ = NativeLineFeed) then
              Inc(P);
          end;
      end;
    end;
    StartPos := P;
  end;
end;

function CharIsReturn(const C: AnsiChar): Boolean;
begin
  Result := (C = AnsiLineFeed) or (C = AnsiCarriageReturn);
end;

{$IFDEF DELPHI2009_UP}
function CharIsReturn(const C: Char): Boolean;
begin
  Result := (C = NativeLineFeed) or (C = NativeCarriageReturn);
end;
{$ENDIF DELPHI2009_UP}

begin
end.
