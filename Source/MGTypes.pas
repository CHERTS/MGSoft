{ ############################################################################ }
{ #                                                                          # }
{ #  MGSoft Delphi Components v1.0.0                                         # }
{ #                                                                          # }
{ #  License: GPLv3                                                          # }
{ #                                                                          # }
{ #  Author: Mikhail Grigorev (icq: 161867489, email: sleuthhound@gmail.com) # }
{ #                                                                          # }
{ ############################################################################ }

unit MGTypes;

{$I MGSoft.inc}

interface

uses
{$IFDEF HAS_UNITSCOPE}
  System.Classes, System.SysUtils
{$ELSE ~HAS_UNITSCOPE}
  Classes, SysUtils
{$ENDIF ~HAS_UNITSCOPE};

{$IFNDEF CLR}
{$IFDEF NEXTGEN}
type
  AnsiString = record
  private type
    TDisposer = class
    private
      FInline: array[0..3] of Pointer;
      FOverflow: TArray<Pointer>;
      FCount: Integer;
      procedure AddDispose(P: Pointer);
      procedure Flush;
    public
      destructor Destroy; override;
    end;

  private
    FPtr: MarshaledAString;
    FLength: integer;
    FDisposer: TDisposer;

    procedure AddDispose(P: Pointer);
    function GetChars(Index: Integer): MarshaledAString; inline;
    procedure SetChars(Index: Integer; Value: MarshaledAString); inline;
    procedure SetPtr(Value: MarshaledAString);
  public
    procedure SetLength(NewLength: integer);
    function Length: integer; inline;

    class operator Equal(const Left, Right: AnsiString): Boolean;
    class operator NotEqual(const Left, Right: AnsiString): Boolean; inline;

    class operator Implicit(const Val: AnsiString): MarshaledAString;
    class operator Explicit(const Ptr: MarshaledAString): AnsiString;

    class operator Implicit(const Val: AnsiString): string;
    class operator Implicit(const Str: string): AnsiString;

    class operator Implicit(const Val: AnsiString): Variant;
    class operator Explicit(const v: Variant): AnsiString;

    class operator Implicit(const Val: AnsiString): TBytes;
    class operator Explicit(const b: TBytes): AnsiString;

    property Chars[index: Integer]: MarshaledAString read GetChars write SetChars; default;
    property Ptr: MarshaledAString read FPtr write SetPtr;
  end;

  WideString = string;

  AnsiChar = byte;
  PAnsiChar = MarshaledAString;
{$ENDIF NEXTGEN}
{$ELSE}
  PChar = String;
  PAnsiChar = AnsiString;
  PWideChar = WideString;
{$ENDIF}

implementation

{$IFDEF NEXTGEN}
uses
  Math;
{$ENDIF}

{$IFDEF NEXTGEN}

{ AnsiString.TDisposer }

destructor AnsiString.TDisposer.Destroy;
begin
  Flush;
  inherited;
end;

procedure AnsiString.TDisposer.AddDispose(P: Pointer);
var
  c: Integer;
begin
  if FCount < System.Length(FInline) then
    FInline[FCount] := P
  else begin
    c := FCount - System.Length(FInline);
    if c = System.Length(FOverflow) then begin
      if System.Length(FOverflow) < 4 then
        System.SetLength(FOverflow, 4)
      else
        System.SetLength(FOverflow, System.Length(FOverflow) * 2);
    end;
    FOverflow[c] := P;
  end;

  Inc(FCount);
end;

procedure AnsiString.TDisposer.Flush;
var
  i: Integer;
begin
  if FCount <= System.Length(FInline) then begin
    for i := 0 to FCount - 1 do
      System.FreeMem(FInline[i]);
  end
  else begin
    for i := 0 to System.Length(FInline) - 1 do
      System.FreeMem(FInline[i]);
    for i := 0 to FCount - System.Length(FInline) - 1 do
      System.FreeMem(FOverflow[i]);
  end;
  FCount := 0;
  System.SetLength(FOverflow, 0);
end;

{ AnsiString }

procedure AnsiString.AddDispose(P: Pointer);
begin
  if FDisposer = nil then
    FDisposer := TDisposer.Create;
  FDisposer.AddDispose(P);
end;

procedure AnsiString.SetLength(NewLength: integer);
var
  NewPtr: Pointer;
begin
  if NewLength <= 0 then begin
    FPtr := nil;
    FLength := 0;
    Exit;
  end;

  NewPtr := System.AllocMem(NewLength + 1);
  if (FDisposer <> nil) and (FPtr <> nil) then
    Move(FPtr^, NewPtr^, Min(FLength, NewLength));

  AddDispose(NewPtr);
  FPtr := NewPtr;
  FPtr[NewLength] := #0;
  FLength := NewLength;
end;

function AnsiString.Length: integer;
begin
  if (FDisposer <> nil) and (FPtr <> nil) then
    Result := FLength
  else
    Result := 0;
end;

class operator AnsiString.Equal(const Left, Right: AnsiString): Boolean;
var
  Len: integer;
  P1, P2: PAnsiChar;
begin
  Len := Left.Length;
  Result := Len = Right.Length;
  if Result then begin
    P1 := Left.FPtr;
    P2 := Right.Ptr;
    while Len > 0 do begin
      if P1^ <> P2^ then
        Exit(False);
      Inc(P1);
      Inc(P2);
      Dec(Len);
    end;
  end;
end;

class operator AnsiString.NotEqual(const Left, Right: AnsiString): Boolean;
begin
  Result := not (Left = Right);
end;

class operator AnsiString.Implicit(const Val: AnsiString): MarshaledAString;
begin
  if Val.FPtr = nil then
    Result := #0
  else
    Result := Val.FPtr;
end;

class operator AnsiString.Explicit(const Ptr: MarshaledAString): AnsiString;
begin
  if Result.FPtr <> Ptr then begin
    Result.FLength := System.Length(Ptr);

    if Result.FLength = 0 then
      Result.FPtr := nil
    else begin
      Result.FPtr := System.AllocMem(Result.FLength + 1);
      Result.AddDispose(Result.FPtr);

      Move(Ptr^, Result.FPtr^, Result.FLength);
      Result.FPtr[Result.FLength] := #0;
    end;
  end;
end;

class operator AnsiString.Implicit(const Val: AnsiString): string;
begin
  Result := string(Val.FPtr);
end;

class operator AnsiString.Implicit(const Str: string): AnsiString;
begin
  Result.FLength := LocaleCharsFromUnicode(DefaultSystemCodePage, 0, PWideChar(Str), System.Length(Str) + 1, nil, 0, nil, nil);
  if Result.FLength > 0 then begin
    Result.FPtr := System.AllocMem(Result.FLength);
    Result.AddDispose(Result.FPtr);
    LocaleCharsFromUnicode(DefaultSystemCodePage, 0, PWideChar(Str), System.Length(Str) + 1,
      Result.FPtr, Result.FLength, nil, nil);
    Dec(Result.FLength);
  end
  else
    Result.FPtr := nil;
end;

class operator AnsiString.Implicit(const Val: AnsiString): Variant;
begin
  Result := string(Val.FPtr);
end;

class operator AnsiString.Explicit(const v: Variant): AnsiString;
begin
  Result := AnsiString(string(v));
end;

class operator AnsiString.Implicit(const Val: AnsiString): TBytes;
var
  Len: integer;
begin
  Len := Val.Length;
  System.SetLength(Result, Len);
  if Len > 0 then
    Move(Val.FPtr^, Result[0], Len);
end;

class operator AnsiString.Explicit(const b: TBytes): AnsiString;
begin
  Result.FLength := System.Length(b);

  if Result.FLength = 0 then
    Result.FPtr := nil
  else begin
    Result.FPtr := System.AllocMem(Result.FLength + 1);
    Result.AddDispose(Result.FPtr);

    Move(b[0], Result.FPtr^, Result.FLength);
    Result.FPtr[Result.FLength] := #0;
  end;
end;

function AnsiString.GetChars(Index: Integer): MarshaledAString;
begin
  Result := @FPtr[Index - 1];
end;

procedure AnsiString.SetChars(Index: Integer; Value: MarshaledAString);
begin
  FPtr[Index - 1] := Value[0];
end;

procedure AnsiString.SetPtr(Value: MarshaledAString);
begin
  if FDisposer = nil then
    FDisposer := TDisposer.Create;

  FPtr := Value;
  FLength := System.Length(Value);
end;

{$ENDIF}

end.
