{ ############################################################################ }
{ #                                                                          # }
{ #  MGSoft Delphi Components v1.0.0                                         # }
{ #                                                                          # }
{ #  License: GPLv3                                                          # }
{ #                                                                          # }
{ #  Author: Mikhail Grigorev (icq: 161867489, email: sleuthhound@gmail.com) # }
{ #                                                                          # }
{ ############################################################################ }

unit MGUtils;

{$I MGSoft.inc}
{$IFDEF EnableMGGoogleTTS}
{$R MGLangStrGoogle.res}
{$ENDIF EnableMGGoogleTTS}
{$IFDEF EnableMGYandexTTS}
{$R MGLangStrYandex.res}
{$ENDIF EnableMGYandexTTS}

{$RANGECHECKS OFF}

{$IFDEF BCB3} // C++ Builder 3
  {$ObjExportAll On}
{$ENDIF BCB3}

interface

uses
{$IFDEF HAS_UNITSCOPE}
  {$IFDEF MSWINDOWS}
  Winapi.Windows, Winapi.PsAPI,
  {$ENDIF MSWINDOWS}
  System.Classes, System.SysUtils,
  {$IFDEF HAS_VCL}
  Vcl.Controls
  {$ELSE}
  FMX.Controls
  {$ENDIF}
{$ELSE ~HAS_UNITSCOPE}
  {$IFDEF MSWINDOWS}
  Windows,
  {$IFDEF FPC}JwaPsApi,{$ELSE ~FPC}PsAPI,{$ENDIF FPC}
  {$ENDIF MSWINDOWS}
  Classes, SysUtils, Controls
{$ENDIF ~HAS_UNITSCOPE};

type
  EMGSoftError = class(Exception);
  EMGSoftStringConversionError = class(EMGSoftError);
  EMGSoftUnexpectedEOSequenceError = class (EMGSoftStringConversionError)
  public
    constructor Create;
  end;
  TListLCID = Array of LCID;
  TCardinalClass = class
  public
    Value: Cardinal;
    constructor Create(aValue: Cardinal);
  end;
  TUTF8String = AnsiString;
  {$IFDEF SUPPORTS_UNICODE_STRING}
  TUTF16String = UnicodeString;
  TUCS2String = UnicodeString;
  {$ELSE}
  TUTF16String = WideString;
  TUCS2String = WideString;
  {$ENDIF SUPPORTS_UNICODE_STRING}
  {$IFDEF CPU32}
  SizeInt = Integer;
  {$ENDIF CPU32}
  {$IFDEF CPU64}
  SizeInt = NativeInt;
  {$ENDIF CPU64}
  UCS4 = Cardinal;
{$IFNDEF DELPHI4_UP}
  TSysCharSet = set of Char;
{$ENDIF}
  TCharSet = TSysCharSet;
  TArithmeticMask = record
    FPU: Word;
    SSE: Word;
  end;

const
  MaximumUCS2: UCS4 = $0000FFFF;
  MaximumUCS4: UCS4 = $7FFFFFFF;
  MaximumUTF16: UCS4 = $0010FFFF;
  SurrogateHighStart = UCS4($D800);
  SurrogateHighEnd = UCS4($DBFF);
  SurrogateLowStart = UCS4($DC00);
  SurrogateLowEnd = UCS4($DFFF);
  HalfShift: Integer = 10;
  HalfBase: UCS4 = $0010000;
  HalfMask: UCS4 = $3FF;
  UCS4ReplacementCharacter: UCS4 = $0000FFFD;
  MaxBuffer = 255;
  IDR_MGLANG_GOOGLE = 'IDR_MGLANG_GOOGLE';
  IDR_MGLANG_YANDEX = 'IDR_MGLANG_YANDEX';
  // Google TTS
  IDR_MGLANG_GOOGLE_NAME = 1000;
  IDR_MGLANG_GOOGLE_TESTPHRASE = 1001;
  IDR_MGLANG_GOOGLE_CODE = 1002;
  // Yandex TTS
  IDR_MGLANG_YANDEX_NAME = 1010;
  IDR_MGLANG_YANDEX_TESTPHRASE = 1011;
  IDR_MGLANG_YANDEX_CODE = 1012;
  // iSpeech TTS
  IDR_MGLANG_ISPEECH_NAME = 1020;
  IDR_MGLANG_ISPEECH_TESTPHRASE = 1021;
  IDR_MGLANG_ISPEECH_CODE = 1022;
  { Command messages for TMGWindowHook }
  CM_RECREATEWINDOW  = CM_BASE + 82;
  CM_DESTROYHOOK     = CM_BASE + 83;
{$IFDEF DELPHI5} // Delphi 5
  PathDelim  = '\';
{$ENDIF}

resourcestring
  rsEUnexpectedEOSeq = 'Unexpected end of sequence';
  // TMGTessOCR
  rsOCRCannotInitializeLibrary = 'Cannot initialize Tesseract OCR library';
  rsOCRImageFileCannotBeUsed = 'Image file cannot be used';
  rsOCRInactiveComponent = 'Cannot perform this operation on an inactive %s component';
  rsOCRActiveComponent = 'Cannot perform this operation on an active %s component';
  rsOCRSelectTesseractDataDir = 'Select Tesseract OCR data directory:';
  // TMGRHVoice
  rsRHVoiceCannotInitializeLibrary = 'Cannot initialize RHVoice library';
  rsRHVoiceInactiveComponent = 'Cannot perform this operation on an inactive %s component';
  rsRHVoiceActiveComponent = 'Cannot perform this operation on an active %s component';
  rsRHVoiceSelectDataDir = 'Select RHVoice data directory:';
  rsRHVoiceSelectConfigDir = 'Select RHVoice config directory:';
  rsRHVoiceSelectResourceDir = 'Select RHVoice resource directory:';
  // TMGFileMapping
  rsCreateFileMapping = 'Failed to create FileMapping';
  rsCreateFileMappingView = 'Failed to create FileMappingView';
  rsLoadFromStreamSize = 'Not enough space in View in procedure LoadFromStream';
  rsFileMappingInvalidHandle = 'Invalid file handle';
  rsViewNeedsMapping = 'FileMap argument of TMGFileMappingView constructor cannot be nil';
  rsFailedToObtainSize = 'Failed to obtain size of file';
  // TMGMappedTextReader
  rsFileIndexOutOfRange = 'Index of out range';

{$IFNDEF RELEASE}
var
  TFDebugLog: TextFile;
  DebugLogOpened: Boolean = False;

const
  DebugLogPath = 'd:\';
  DebugLogName = 'mgsoft.log';
{$ENDIF}

function WideStringToUTF8(const S: WideString): TUTF8String; {$IFDEF SUPPORTS_INLINE} inline; {$ENDIF SUPPORTS_INLINE}
function UTF8ToWideString(const S: TUTF8String): WideString; {$IFDEF SUPPORTS_INLINE} inline; {$ENDIF SUPPORTS_INLINE}
function UTF16ToUTF8(const S: TUTF16String): TUTF8String;
function UTF8ToUTF16(const S: TUTF8String): TUTF16String;
function UTF16GetNextChar(const S: TUTF16String; var StrPos: SizeInt): UCS4;
function UTF8SetNextChar(var S: TUTF8String; var StrPos: SizeInt; Ch: UCS4): Boolean;
function UTF8GetNextChar(const S: TUTF8String; var StrPos: SizeInt): UCS4;
// UTF16SetNextChar = append an UTF16 sequence at StrPos
// returns False on error:
//    - if an UCS4 character cannot be stored to an UTF-16 string:
//        - if UNICODE_SILENT_FAILURE is defined, ReplacementCharacter is added
//        - if UNICODE_SILENT_FAILURE is not defined, StrPos is set to -1
//    - StrPos > -1 flags string being too small, callee did nothing and caller is responsible for allocating space
// StrPos will be incremented by the number of chars that were written
function UTF16SetNextChar(var S: TUTF16String; var StrPos: SizeInt; Ch: UCS4): Boolean; overload;
{$IFDEF SUPPORTS_UNICODE_STRING}
function UTF16SetNextChar(var S: WideString; var StrPos: SizeInt; Ch: UCS4): Boolean; overload;
{$ENDIF SUPPORTS_UNICODE_STRING}
procedure FlagInvalidSequence(var StrPos: SizeInt; Increment: SizeInt; out Ch: UCS4); overload;
procedure FlagInvalidSequence(var StrPos: SizeInt; Increment: SizeInt); overload;
procedure FlagInvalidSequence(out Ch: UCS4); overload;
procedure FlagInvalidSequence; overload;
{$IFNDEF RELEASE}
function OpenLogFile(LogPath: WideString): Boolean;
procedure WriteInLog(LogPath: WideString; TextString: String);
procedure CloseLogFile;
{$ENDIF}
{$IFNDEF NEXTGEN}
function GetStringFromStringTableRes(hLangLib: String; idString: DWORD; wLang: Word): {$IFDEF DELPHIXE2_UP}String{$ELSE}WideString{$ENDIF}; overload;
function GetStringFromStringTableRes(hLangLib: Cardinal; idString: DWORD; wLang: Word): {$IFDEF DELPHIXE2_UP}String{$ELSE}WideString{$ENDIF}; overload;
function HexToInt(HexStr : String) : Integer;
function LoadListLCID(lName: String): TListLCID;
function LoadListLCIDEx(lName, lDLLName: String): TListLCID;
function GetNameLocale(Locale: LCID; aLCType: Cardinal): {$IFDEF DELPHIXE2_UP}String{$ELSE}WideString{$ENDIF};
function GetFullPathApplication(hInstLib: Cardinal): {$IFDEF DELPHIXE2_UP}String{$ELSE}WideString{$ENDIF};
{$ENDIF NEXTGEN}

{$IFNDEF DELPHI12}
function CharInSet(C: Char; const CharSet: TSysCharSet): Boolean; {$IFDEF DELPHI9}inline;{$ENDIF}
{$ENDIF}
function ExtractWord(N: Integer; const S: string;
  const WordDelims: TCharSet): string; {$IFDEF DELPHI9_UP}inline;{$ENDIF}
{ ExtractWord given a set of word delimiters, return the N'th word in S. }
function WordPosition(const N: Integer; const S: string;
  const WordDelims: TCharSet): Integer; {$IFDEF DELPHI9_UP}inline;{$ENDIF}
{ Given a set of word delimiters, returns start position of N'th word in S. }
function IsWild(InputStr, Wilds: string; IgnoreCase: Boolean): Boolean;
{ IsWild compares InputString with WildCard string and returns True
  if corresponds. }
function FindPart(const HelpWilds, InputStr: string): Integer; {$IFDEF DELPHI9_UP}inline;{$ENDIF}
{ FindPart compares a string with '?' and another, returns the position of
  HelpWilds in InputStr. }
function XorEncode(const Key, Source: AnsiString): AnsiString; {$IFDEF DELPHI9_UP}inline;{$ENDIF}
function XorDecode(const Key, Source: AnsiString): AnsiString; {$IFDEF DELPHI9_UP}inline;{$ENDIF}

{$IFNDEF DELPHI12_UP}
function UTF8ToString(const S: PAnsiChar): WideString;
{$ENDIF DELPHI12_UP}
{$IFNDEF MOBILE}
function SetArithmeticMask: TArithmeticMask;
procedure RestoreArithmeticMask(Mask: TArithmeticMask);
{$ENDIF MOBILE}

implementation

function WideStringToUTF8(const S: WideString): TUTF8String;
begin
  Result := UTF16ToUTF8(S);
end;

function UTF8ToWideString(const S: TUTF8String): WideString;
begin
  Result := UTF8ToUTF16(S);
end;

function UTF16ToUTF8(const S: TUTF16String): TUTF8String;
var
  SrcIndex, SrcLength, DestIndex: SizeInt;
  Ch: UCS4;
begin
  if S = '' then
    Result := ''
  else
  begin
    SrcLength := Length(S);
    SetLength(Result, SrcLength * 3); // worste case
    SrcIndex := 1;
    DestIndex := 1;
    while SrcIndex <= SrcLength do
    begin
      Ch := UTF16GetNextChar(S, SrcIndex);
      if SrcIndex = -1 then
        raise EMGSoftUnexpectedEOSequenceError.Create;
      UTF8SetNextChar(Result, DestIndex, Ch);
    end;
    SetLength(Result, DestIndex - 1); // now fix up length
  end;
end;

function UTF8ToUTF16(const S: TUTF8String): TUTF16String;
var
  SrcIndex, SrcLength, DestIndex: SizeInt;
  Ch: UCS4;
begin
  if S = '' then
    Result := ''
  else
  begin
    SrcLength := Length(S);
    SetLength(Result, SrcLength); // create enough room
    SrcIndex := 1;
    DestIndex := 1;
    while SrcIndex <= SrcLength do
    begin
      Ch := UTF8GetNextChar(S, SrcIndex);
      if SrcIndex = -1 then
        raise EMGSoftUnexpectedEOSequenceError.Create;
      UTF16SetNextChar(Result, DestIndex, Ch);
    end;
    SetLength(Result, DestIndex - 1); // now fix up length
  end;
end;

// StrPos will be incremented by the number of chars that were read
function UTF16GetNextChar(const S: TUTF16String; var StrPos: SizeInt): UCS4;
var
  StrLength: SizeInt;
  Ch: UCS4;
begin
  StrLength := Length(S);
  if (StrPos <= StrLength) and (StrPos > 0) then
  begin
    Result := UCS4(S[StrPos]);
    case Result of
      SurrogateHighStart..SurrogateHighEnd:
        begin
          // 2 bytes to read
          if StrPos < StrLength then
          begin
            Ch := UCS4(S[StrPos + 1]);
            if (Ch >= SurrogateLowStart) and (Ch <= SurrogateLowEnd) then
            begin
              Result := ((Result - SurrogateHighStart) shl HalfShift) +  (Ch - SurrogateLowStart) + HalfBase;
              Inc(StrPos, 2);
            end
            else
              FlagInvalidSequence(StrPos, 1, Result);
          end
          else
            FlagInvalidSequence(StrPos, 1, Result);
        end;
      SurrogateLowStart..SurrogateLowEnd:
        FlagInvalidSequence(StrPos, 1, Result);
    else
      // 1 byte to read
      Inc(StrPos);
    end;
  end
  else
  begin
    // StrPos > StrLength
    Result := 0;
    FlagInvalidSequence(StrPos, 0, Result);
  end;
end;

// returns False on error:
//    - if an UCS4 character cannot be stored to an UTF-8 string:
//        - if UNICODE_SILENT_FAILURE is defined, ReplacementCharacter is added
//        - if UNICODE_SILENT_FAILURE is not defined, StrPos is set to -1
//    - StrPos > -1 flags string being too small, caller is responsible for allocating space
// StrPos will be incremented by the number of chars that were written
function UTF8SetNextChar(var S: TUTF8String; var StrPos: SizeInt; Ch: UCS4): Boolean;
var
  StrLength: SizeInt;
begin
  StrLength := Length(S);
  if Ch <= $7F then
  begin
    // 7 bits to store
    Result := (StrPos > 0) and (StrPos <= StrLength);
    if Result then
    begin
      S[StrPos] := AnsiChar(Ch);
      Inc(StrPos);
    end;
  end
  else
  if Ch <= $7FF then
  begin
    // 11 bits to store
    Result := (StrPos > 0) and (StrPos < StrLength);
    if Result then
    begin
      S[StrPos] := AnsiChar($C0 or (Ch shr 6));  // 5 bits
      S[StrPos + 1] := AnsiChar((Ch and $3F) or $80); // 6 bits
      Inc(StrPos, 2);
    end;
  end
  else
  if Ch <= $FFFF then
  begin
    // 16 bits to store
    Result := (StrPos > 0) and (StrPos < (StrLength - 1));
    if Result then
    begin
      S[StrPos] := AnsiChar($E0 or (Ch shr 12)); // 4 bits
      S[StrPos + 1] := AnsiChar(((Ch shr 6) and $3F) or $80); // 6 bits
      S[StrPos + 2] := AnsiChar((Ch and $3F) or $80); // 6 bits
      Inc(StrPos, 3);
    end;
  end
  else
  if Ch <= $1FFFFF then
  begin
    // 21 bits to store
    Result := (StrPos > 0) and (StrPos < (StrLength - 2));
    if Result then
    begin
      S[StrPos] := AnsiChar($F0 or (Ch shr 18)); // 3 bits
      S[StrPos + 1] := AnsiChar(((Ch shr 12) and $3F) or $80); // 6 bits
      S[StrPos + 2] := AnsiChar(((Ch shr 6) and $3F) or $80); // 6 bits
      S[StrPos + 3] := AnsiChar((Ch and $3F) or $80); // 6 bits
      Inc(StrPos, 4);
    end;
  end
  else
  if Ch <= $3FFFFFF then
  begin
    // 26 bits to store
    Result := (StrPos > 0) and (StrPos < (StrLength - 2));
    if Result then
    begin
      S[StrPos] := AnsiChar($F8 or (Ch shr 24)); // 2 bits
      S[StrPos + 1] := AnsiChar(((Ch shr 18) and $3F) or $80); // 6 bits
      S[StrPos + 2] := AnsiChar(((Ch shr 12) and $3F) or $80); // 6 bits
      S[StrPos + 3] := AnsiChar(((Ch shr 6) and $3F) or $80); // 6 bits
      S[StrPos + 4] := AnsiChar((Ch and $3F) or $80); // 6 bits
      Inc(StrPos, 5);
    end;
  end
  else
  if Ch <= MaximumUCS4 then
  begin
    // 31 bits to store
    Result := (StrPos > 0) and (StrPos < (StrLength - 3));
    if Result then
    begin
      S[StrPos] := AnsiChar($FC or (Ch shr 30)); // 1 bits
      S[StrPos + 1] := AnsiChar(((Ch shr 24) and $3F) or $80); // 6 bits
      S[StrPos + 2] := AnsiChar(((Ch shr 18) and $3F) or $80); // 6 bits
      S[StrPos + 3] := AnsiChar(((Ch shr 12) and $3F) or $80); // 6 bits
      S[StrPos + 4] := AnsiChar(((Ch shr 6) and $3F) or $80); // 6 bits
      S[StrPos + 5] := AnsiChar((Ch and $3F) or $80); // 6 bits
      Inc(StrPos, 6);
    end;
  end
  else
  begin
    {$IFDEF UNICODE_SILENT_FAILURE}
    // add ReplacementCharacter
    Result := (StrPos > 0) and (StrPos < (StrLength - 1));
    if Result then
    begin
      S[StrPos] := AnsiChar($E0 or (UCS4ReplacementCharacter shr 12)); // 4 bits
      S[StrPos + 1] := AnsiChar(((UCS4ReplacementCharacter shr 6) and $3F) or $80); // 6 bits
      S[StrPos + 2] := AnsiChar((UCS4ReplacementCharacter and $3F) or $80); // 6 bits
      Inc(StrPos, 3);
    end;
    {$ELSE ~UNICODE_SILENT_FAILURE}
    StrPos := -1;
    Result := False;
    {$ENDIF ~UNICODE_SILENT_FAILURE}
  end;
end;

// if UNICODE_SILENT_FAILURE is defined, invalid sequences will be replaced by ReplacementCharacter
// otherwise StrPos is set to -1 on return to flag an error (invalid UTF8 sequence)
// StrPos will be incremented by the number of chars that were read
function UTF8GetNextChar(const S: TUTF8String; var StrPos: SizeInt): UCS4;
var
  StrLength: SizeInt;
  Ch: UCS4;
  ReadSuccess: Boolean;
begin
  StrLength := Length(S);
  ReadSuccess := True;
  if (StrPos <= StrLength) and (StrPos > 0) then
  begin
    Result := UCS4(S[StrPos]);
    case Result of
      $00..$7F:
        // 1 byte to read
        Inc(StrPos);
      $C0..$DF:
        begin
          // 2 bytes to read
          if StrPos < StrLength then
          begin
            Ch := UCS4(S[StrPos + 1]);
            if (Ch and $C0) = $80 then
            begin
              Result := ((Result and $1F) shl 6) or (Ch and $3F);
              Inc(StrPos, 2);
            end
            else
              FlagInvalidSequence(StrPos, 1, Result);
          end
          else
            ReadSuccess := False;
        end;
      $E0..$EF:
        begin
          // 3 bytes to read
          if (StrPos + 1) < StrLength then
          begin
            Ch := UCS4(S[StrPos + 1]);
            if (Ch and $C0) = $80 then
            begin
              Result := ((Result and $0F) shl 12) or ((Ch and $3F) shl 6);
              Ch := UCS4(S[StrPos + 2]);
              if (Ch and $C0) = $80 then
              begin
                Result := Result or (Ch and $3F);
                Inc(StrPos, 3);
              end
              else
                FlagInvalidSequence(StrPos, 2, Result);
            end
            else
              FlagInvalidSequence(StrPos, 1, Result);
          end
          else
            ReadSuccess := False;
        end;
      $F0..$F7:
        begin
          // 4 bytes to read
          if (StrPos + 2) < StrLength then
          begin
            Ch := UCS4(S[StrPos + 1]);
            if (Ch and $C0) = $80 then
            begin
              Result := ((Result and $07) shl 18) or ((Ch and $3F) shl 12);
              Ch := UCS4(S[StrPos + 2]);
              if (Ch and $C0) = $80 then
              begin
                Result := Result or ((Ch and $3F) shl 6);
                Ch := UCS4(S[StrPos + 3]);
                if (Ch and $C0) = $80 then
                begin
                  Result := Result or (Ch and $3F);
                  Inc(StrPos, 4);
                end
                else
                  FlagInvalidSequence(StrPos, 3, Result);
              end
              else
                FlagInvalidSequence(StrPos, 2, Result);
            end
            else
              FlagInvalidSequence(StrPos, 1, Result);
          end
          else
            ReadSuccess := False;
        end;
      $F8..$FB:
        begin
          // 5 bytes to read
          if (StrPos + 3) < StrLength then
          begin
            Ch := UCS4(S[StrPos + 1]);
            if (Ch and $C0) = $80 then
            begin
              Result := ((Result and $03) shl 24) or ((Ch and $3F) shl 18);
              Ch := UCS4(S[StrPos + 2]);
              if (Ch and $C0) = $80 then
              begin
                Result := Result or ((Ch and $3F) shl 12);
                Ch := UCS4(S[StrPos + 3]);
                if (Ch and $C0) = $80 then
                begin
                  Result := Result or ((Ch and $3F) shl 6);
                  Ch := UCS4(S[StrPos + 4]);
                  if (Ch and $C0) = $80 then
                  begin
                    Result := Result or (Ch and $3F);
                    Inc(StrPos, 5);
                  end
                  else
                    FlagInvalidSequence(StrPos, 4, Result);
                end
                else
                  FlagInvalidSequence(StrPos, 3, Result);
              end
              else
                FlagInvalidSequence(StrPos, 2, Result);
            end
            else
              FlagInvalidSequence(StrPos, 1, Result);
          end
          else
            ReadSuccess := False;
        end;
      $FC..$FD:
        begin
          // 6 bytes to read
          if (StrPos + 4) < StrLength then
          begin
            Ch := UCS4(S[StrPos + 1]);
            if (Ch and $C0) = $80 then
            begin
              Result := ((Result and $01) shl 30) or ((Ch and $3F) shl 24);
              Ch := UCS4(S[StrPos + 2]);
              if (Ch and $C0) = $80 then
              begin
                Result := Result or ((Ch and $3F) shl 18);
                Ch := UCS4(S[StrPos + 3]);
                if (Ch and $C0) = $80 then
                begin
                  Result := Result or ((Ch and $3F) shl 12);
                  Ch := UCS4(S[StrPos + 4]);
                  if (Ch and $C0) = $80 then
                  begin
                    Result := Result or ((Ch and $3F) shl 6);
                    Ch := UCS4(S[StrPos + 5]);
                    if (Ch and $C0) = $80 then
                    begin
                      Result := Result or (Ch and $3F);
                      Inc(StrPos, 6);
                    end
                    else
                      FlagInvalidSequence(StrPos, 5, Result);
                  end
                  else
                    FlagInvalidSequence(StrPos, 4, Result);
                end
                else
                  FlagInvalidSequence(StrPos, 3, Result);
              end
              else
                FlagInvalidSequence(StrPos, 2, Result);
            end
            else
              FlagInvalidSequence(StrPos, 1, Result);
          end
          else
            ReadSuccess := False;
        end;
    else
      FlagInvalidSequence(StrPos, 1, Result);
    end;
    if not ReadSuccess then
      FlagInvalidSequence(StrPos, 1, Result);
  end
  else
  begin
    // StrPos > StrLength
    Result := 0;
    FlagInvalidSequence(StrPos, 0, Result);
  end;
end;

// returns False on error:
//    - if an UCS4 character cannot be stored to an UTF-8 string:
//        - if UNICODE_SILENT_FAILURE is defined, ReplacementCharacter is added
//        - if UNICODE_SILENT_FAILURE is not defined, StrPos is set to -1
//    - StrPos > -1 flags string being too small, caller is responsible for allocating space
// StrPos will be incremented by the number of chars that were written
function UTF16SetNextChar(var S: TUTF16String; var StrPos: SizeInt; Ch: UCS4): Boolean;
var
  StrLength: SizeInt;
begin
  StrLength := Length(S);
  if Ch <= MaximumUCS2 then
  begin
    // 16 bits to store in place
    Result := (StrPos > 0) and (StrPos <= StrLength);
    if Result then
    begin
      S[StrPos] := WideChar(Ch);
      Inc(StrPos);
    end;
  end
  else
  if Ch <= MaximumUTF16 then
  begin
    // stores a surrogate pair
    Result := (StrPos > 0) and (StrPos < StrLength);
    if Result then
    begin
      Ch := Ch - HalfBase;
      S[StrPos] := WideChar((Ch shr HalfShift) or SurrogateHighStart);
      S[StrPos + 1] := WideChar((Ch and HalfMask) or SurrogateLowStart);
      Inc(StrPos, 2);
    end;
  end
  else
  begin
    {$IFDEF UNICODE_SILENT_FAILURE}
    // add ReplacementCharacter
    Result := (StrPos > 0) and (StrPos <= StrLength);
    if Result then
    begin
      S[StrPos] := WideChar(UCS4ReplacementCharacter);
      Inc(StrPos, 1);
    end;
    {$ELSE ~UNICODE_SILENT_FAILURE}
    StrPos := -1;
    Result := False;
    {$ENDIF ~UNICODE_SILENT_FAILURE}
  end;
end;

{$IFDEF SUPPORTS_UNICODE_STRING}
function UTF16SetNextChar(var S: WideString; var StrPos: SizeInt; Ch: UCS4): Boolean;
var
  StrLength: SizeInt;
begin
  StrLength := Length(S);

  if Ch <= MaximumUCS2 then
  begin
    // 16 bits to store in place
    Result := (StrPos > 0) and (StrPos <= StrLength);
    if Result then
    begin
      S[StrPos] := WideChar(Ch);
      Inc(StrPos);
    end;
  end
  else
  if Ch <= MaximumUTF16 then
  begin
    // stores a surrogate pair
    Result := (StrPos > 0) and (StrPos < StrLength);
    if Result then
    begin
      Ch := Ch - HalfBase;
      S[StrPos] := WideChar((Ch shr HalfShift) + SurrogateHighStart);
      S[StrPos + 1] := WideChar((Ch and HalfMask) + SurrogateLowStart);
      Inc(StrPos, 2);
    end;
  end
  else
  begin
    {$IFDEF UNICODE_SILENT_FAILURE}
    // add ReplacementCharacter
    Result := (StrPos > 0) and (StrPos <= StrLength);
    if Result then
    begin
      S[StrPos] := WideChar(UCS4ReplacementCharacter);
      Inc(StrPos, 1);
    end;
    {$ELSE ~UNICODE_SILENT_FAILURE}
    StrPos := -1;
    Result := False;
    {$ENDIF ~UNICODE_SILENT_FAILURE}
  end;
end;
{$ENDIF SUPPORTS_UNICODE_STRING}

procedure FlagInvalidSequence(var StrPos: SizeInt; Increment: SizeInt; out Ch: UCS4); overload;
begin
  {$IFDEF UNICODE_SILENT_FAILURE}
  Ch := UCS4ReplacementCharacter;
  Inc(StrPos, Increment);
  {$ELSE ~UNICODE_SILENT_FAILURE}
  StrPos := -1;
  {$ENDIF ~UNICODE_SILENT_FAILURE}
end;

procedure FlagInvalidSequence(var StrPos: SizeInt; Increment: SizeInt); overload;
begin
  {$IFDEF UNICODE_SILENT_FAILURE}
  Inc(StrPos, Increment);
  {$ELSE ~UNICODE_SILENT_FAILURE}
  StrPos := -1;
  {$ENDIF ~UNICODE_SILENT_FAILURE}
end;

procedure FlagInvalidSequence(out Ch: UCS4); overload;
begin
  {$IFDEF UNICODE_SILENT_FAILURE}
  Ch := UCS4ReplacementCharacter;
  {$ELSE ~UNICODE_SILENT_FAILURE}
  raise EMGSoftUnexpectedEOSequenceError.Create;
  {$ENDIF ~UNICODE_SILENT_FAILURE}
end;

procedure FlagInvalidSequence; overload;
begin
  {$IFNDEF UNICODE_SILENT_FAILURE}
  raise EMGSoftUnexpectedEOSequenceError.Create;
  {$ENDIF ~UNICODE_SILENT_FAILURE}
end;

constructor EMGSoftUnexpectedEOSequenceError.Create;
begin
  inherited CreateRes(@rsEUnexpectedEOSeq);
end;

{$IFNDEF RELEASE}
function OpenLogFile(LogPath: WideString): Boolean;
var
  Path: WideString;
begin
  Path := LogPath + DebugLogName;
  {$I-}
  try
    Assign(TFDebugLog, Path);
    if FileExists(Path) then
      Append(TFDebugLog)
    else
      Rewrite(TFDebugLog);
    Result := True;
  except
    on e :
      Exception do
      begin
        CloseLogFile;
        Result := False;
        Exit;
      end;
  end;
  {$I+}
end;

procedure WriteInLog(LogPath: WideString; TextString: String);
var
  Path: WideString;
  TF: TextFile;
begin
  if not DebugLogOpened then
    DebugLogOpened := OpenLogFile(LogPath);
  Path := LogPath + DebugLogName;
  {$I-}
  try
    WriteLn(TFDebugLog, TextString);
  except
    on e :
      Exception do
      begin
        CloseLogFile;
        Exit;
      end;
  end;
  {$I+}
end;

procedure CloseLogFile;
begin
  {$I-}
  CloseFile(TFDebugLog);
  DebugLogOpened := False;
  {$I+}
end;
{$ENDIF}

{ TCardinalClass }

constructor TCardinalClass.Create(aValue: Cardinal);
begin
  Value := aValue;
end;

{$IFNDEF NEXTGEN}
function GetStringFromStringTableRes(hLangLib: String; idString: DWORD; wLang: Word): {$IFDEF DELPHIXE2_UP}String{$ELSE}WideString{$ENDIF}; overload;
var
  hDll: Cardinal;
begin
  hDll := 0;
  if hLangLib <> '' then
    hDll := LoadLibrary(PChar(hLangLib));
  if hDll = 0 then
  begin
    Result := GetStringFromStringTableRes(HInstance, idString, wLang);
    Exit;
  end;
  Result := GetStringFromStringTableRes(hDll, idString, wLang);
  FreeLibrary(hDll);
end;

function GetStringFromStringTableRes(hLangLib: Cardinal; idString: DWORD; wLang: Word): {$IFDEF DELPHIXE2_UP}String{$ELSE}WideString{$ENDIF}; overload;
var
  hFindRes: Cardinal;
  hLoadRes: Cardinal;
  nBlockID, nItemID: DWORD;
  pRes: Pointer;
  {$IFDEF CPUX64}
  dRes: DWord;
  {$ENDIF}
  i, j: Integer;
  dwSize: Cardinal;
  nLen: Integer;
  iStr: Cardinal;
const
  RT_STRINGW = {$IFDEF DELPHIXE2_UP}MakeIntResource{$ELSE}MakeIntResourceW{$ENDIF}(6);
  NO_OF_STRINGS_PER_BLOCK = 16;
begin
  Result := '';
  nBlockID := (idString shr 4) + 1;
  nItemID := 16 - (nBlockID shl 4 - idString);
  hFindRes := FindResourceExW(hLangLib, RT_STRINGW, MAKEINTRESOURCEW(nBlockID), wLang);
  if hFindRes = 0 then
    Exit;
  hLoadRes := LoadResource(hLangLib, hFindRes);
  if hLoadRes = 0 then
    Exit;
  pRes := LockResource(hLoadRes);
  if pRes = nil then
    Exit;
  dwSize := SizeofResource(hLangLib, hFindRes);
  if dwSize = 0 then
    Exit;
  iStr := 0;
  for i := 0 to NO_OF_STRINGS_PER_BLOCK - 1 do
  begin
    nLen := PWord(pRes)^;
    {$IFDEF CPUX64}
    dRes := DWord(pRes);
    Inc(dRes, 2);
    pRes := Pointer(dRes);
    {$ELSE}
    Inc(DWord(pRes), 2);
    {$ENDIF}
    if pRes = nil then
      Exit;
    if iStr = nItemID then
    begin
      SetLength(Result, nLen);
      for j := 1 to nLen do
      begin
        Result[j] := {$IFDEF DELPHIXE2_UP}PChar{$ELSE}PWideChar{$ENDIF}(pRes)^;
        {$IFDEF CPUX64}
        dRes := DWord(pRes);
        Inc(dRes, 2);
        pRes := Pointer(dRes);
        {$ELSE}
        Inc(DWord(pRes), 2);
        {$ENDIF}
      end;
      Exit;
    end
    else
      {$IFDEF CPUX64}
      begin
      dRes := DWord(pRes);
      Inc(dRes, nLen * 2);
      pRes := Pointer(dRes);
      end;
      {$ELSE}
      Inc(DWord(pRes), nLen * 2);
      {$ENDIF}
    Inc(iStr);
  end;
end;

function GetFullPathApplication(hInstLib: Cardinal): {$IFDEF DELPHIXE2_UP}String{$ELSE}WideString{$ENDIF};
var
  hProc: THandle;
  Buffer: Array [0..MAX_PATH] of {$IFDEF DELPHIXE2_UP}Char{$ELSE}WideChar{$ENDIF};
  Res: DWORD;
begin
  hProc := GetCurrentProcess;
  Res := GetModuleFileNameExW(hProc, hInstLib, {$IFDEF DELPHIXE2_UP}PChar{$ELSE}PWideChar{$ENDIF}(@Buffer), MAX_PATH);
  if res <> 0 then
    SetString(Result, Buffer, res)
  else
    Result := '';
end;

function LoadListLCID(lName: String): TListLCID;
var
  hFindRes: THandle;
  hLoadRes: THandle;
  pRes: Pointer;
  dwSize: Cardinal;
  i: Integer;
  {$IFDEF CPUX64}
  dRes: Cardinal;
  {$ENDIF}
begin
  SetLength(Result, 0);
  hFindRes := FindResource(HInstance, PChar(lName), RT_RCDATA);
  if hFindRes = 0 then
    Exit;
  hLoadRes := LoadResource(HInstance, hFindRes);
  if hLoadRes = 0 then
    Exit;
  pRes := LockResource(hLoadRes);
  if pRes = nil then
    Exit;
  dwSize := SizeofResource(HInstance, hFindRes);
  if dwSize = 0 then
    Exit;
  dwSize := dwSize div sizeof(Cardinal);
  SetLength(Result, dwSize);
  for i := 0 to dwSize - 1 do
  begin
    Result[i] := PCardinal(pRes)^;
    {$IFDEF CPUX64}
    dRes := Cardinal(pRes);
    Inc(dRes, sizeof(Cardinal));
    pRes := Pointer(dRes);
    {$ELSE}
    Inc(Cardinal(pRes), sizeof(Cardinal));
    {$ENDIF}
  end;
end;

function LoadListLCIDEx(lName, lDLLName: String): TListLCID;
var
  hFindRes: THandle;
  hLoadRes: THandle;
  pRes: Pointer;
  dwSize: Cardinal;
  i: Integer;
  {$IFDEF CPUX64}
  dRes: Cardinal;
  {$ENDIF}
  hDll: Cardinal;
begin
  hDll := LoadLibrary(PChar(lDLLName));
  if hDll = 0 then
  begin
    Result := LoadListLCID(lName);
    Exit;
  end;
  SetLength(Result, 0);
  hFindRes := FindResource(hDll, PChar(lName), RT_RCDATA);
  if hFindRes = 0 then
    Exit;
  hLoadRes := LoadResource(hDll, hFindRes);
  if hLoadRes = 0 then
    Exit;
  pRes := LockResource(hLoadRes);
  if pRes = nil then
    Exit;
  dwSize := SizeofResource(hDll, hFindRes);
  if dwSize = 0 then
    Exit;
  dwSize := dwSize div sizeof(Cardinal);
  SetLength(Result, dwSize);
  for i := 0 to dwSize - 1 do
  begin
    Result[i] := PCardinal(pRes)^;
    {$IFDEF CPUX64}
    dRes := Cardinal(pRes);
    Inc(dRes, sizeof(Cardinal));
    pRes := Pointer(dRes);
    {$ELSE}
    Inc(Cardinal(pRes), sizeof(Cardinal));
    {$ENDIF}
  end;
  FreeLibrary(hDll);
end;

function GetNameLocale(Locale: LCID; aLCType: Cardinal): {$IFDEF DELPHIXE2_UP}String{$ELSE}WideString{$ENDIF};
var
  Buf: Array[0..255] of {$IFDEF DELPHIXE2_UP}Char{$ELSE}WideChar{$ENDIF};
begin
  if GetLocaleInfoW(Locale, aLCType, Buf, 255) = 0 then
    Result := ''
  else
    Result := buf;
end;

function HexToInt(HexStr : String) : Integer;
var
  Cnt: Byte;
begin
  HexStr := UpperCase(HexStr);
  if HexStr[length(HexStr)] = 'H' then
     Delete(HexStr,length(HexStr),1);
  Result := 0;

  for Cnt := 1 to length(HexStr) do
  begin
    Result := Result shl 4;
    if HexStr[Cnt] in ['0'..'9'] then
       Result := Result + (byte(HexStr[Cnt]) - 48)
    else
       if HexStr[Cnt] in ['A'..'F'] then
          Result := Result + (byte(HexStr[Cnt]) - 55)
       else begin
          Result := 0;
          break;
       end;
  end;
end;
{$ENDIF NEXTGEN}

{$IFNDEF DELPHI12}
function CharInSet(C: Char; const CharSet: TSysCharSet): Boolean;
begin
  Result := C in CharSet;
end;
{$ENDIF}

function ExtractWord(N: Integer; const S: string;
  const WordDelims: TCharSet): string;
var
  I: Integer;
  Len: Integer;
begin
  Len := 0;
  I := WordPosition(N, S, WordDelims);
  if I <> 0 then
    { find the end of the current word }
    while (I <= Length(S)) and not CharInSet(S[I], WordDelims) do
    begin
      { add the I'th character to result }
      Inc(Len);
      SetLength(Result, Len);
      Result[Len] := S[I];
      Inc(I);
    end;
  SetLength(Result, Len);
end;

function WordPosition(const N: Integer; const S: string;
  const WordDelims: TCharSet): Integer;
var
  Count, I: Integer;
begin
  Count := 0;
  I := 1;
  Result := 0;
  while (I <= Length(S)) and (Count <> N) do
  begin
    { skip over delimiters }
    while (I <= Length(S)) and CharInSet(S[I], WordDelims) do Inc(I);
    { if we're not beyond end of S, we're at the start of a word }
    if I <= Length(S) then Inc(Count);
    { if not finished, find the end of the current word }
    if Count <> N then
      while (I <= Length(S)) and not CharInSet(S[I], WordDelims) do Inc(I)
    else Result := I;
  end;
end;

function IsWild(InputStr, Wilds: string; IgnoreCase: Boolean): Boolean;

 function SearchNext(var Wilds: string): Integer;
 { looking for next *, returns position and string until position }
 begin
   Result := Pos('*', Wilds);
   if Result > 0 then Wilds := Copy(Wilds, 1, Result - 1);
 end;

var
  CWild, CInputWord: Integer; { counter for positions }
  I, LenHelpWilds: Integer;
  MaxInputWord, MaxWilds: Integer; { Length of InputStr and Wilds }
  HelpWilds: string;
begin
  if Wilds = InputStr then
  begin
    Result := True;
    Exit;
  end;
  repeat { delete '**', because '**' = '*' }
    I := Pos('**', Wilds);
    if I > 0 then
      Wilds := Copy(Wilds, 1, I - 1) + '*' + Copy(Wilds, I + 2, MaxInt);
  until I = 0;
  if Wilds = '*' then
  begin { for fast end, if Wilds only '*' }
    Result := True;
    Exit;
  end;
  MaxInputWord := Length(InputStr);
  MaxWilds := Length(Wilds);
  if IgnoreCase then
  begin { upcase all letters }
    InputStr := AnsiUpperCase(InputStr);
    Wilds := AnsiUpperCase(Wilds);
  end;
  if (MaxWilds = 0) or (MaxInputWord = 0) then
  begin
    Result := False;
    Exit;
  end;
  CInputWord := 1;
  CWild := 1;
  Result := True;
  repeat
    if InputStr[CInputWord] = Wilds[CWild] then
    begin { equal letters }
      { goto next letter }
      Inc(CWild);
      Inc(CInputWord);
      Continue;
    end;
    if Wilds[CWild] = '?' then
    begin { equal to '?' }
      { goto next letter }
      Inc(CWild);
      Inc(CInputWord);
      Continue;
    end;
    if Wilds[CWild] = '*' then
    begin { handling of '*' }
      HelpWilds := Copy(Wilds, CWild + 1, MaxWilds);
      I := SearchNext(HelpWilds);
      LenHelpWilds := Length(HelpWilds);
      if I = 0 then
      begin
        { no '*' in the rest, compare the ends }
        if HelpWilds = '' then Exit; { '*' is the last letter }
        { check the rest for equal Length and no '?' }
        for I := 0 to LenHelpWilds - 1 do
        begin
          if (HelpWilds[LenHelpWilds - I] <> InputStr[MaxInputWord - I]) and
            (HelpWilds[LenHelpWilds - I]<> '?') then
          begin
            Result := False;
            Exit;
          end;
        end;
        Exit;
      end;
      { handle all to the next '*' }
      Inc(CWild, 1 + LenHelpWilds);
      I := FindPart(HelpWilds, Copy(InputStr, CInputWord, MaxInt));
      if I= 0 then
      begin
        Result := False;
        Exit;
      end;
      CInputWord := I + LenHelpWilds;
      Continue;
    end;
    Result := False;
    Exit;
  until (CInputWord > MaxInputWord) or (CWild > MaxWilds);
  { no completed evaluation }
  if CInputWord <= MaxInputWord then Result := False;
  if (CWild <= MaxWilds) and (Wilds[MaxWilds] <> '*') then Result := False;
end;

function FindPart(const HelpWilds, InputStr: string): Integer;
var
  I, J: Integer;
  Diff: Integer;
begin
  I := Pos('?', HelpWilds);
  if I = 0 then
  begin
    { if no '?' in HelpWilds }
    Result := Pos(HelpWilds, InputStr);
    Exit;
  end;
  { '?' in HelpWilds }
  Diff := Length(InputStr) - Length(HelpWilds);
  if Diff < 0 then
  begin
    Result := 0;
    Exit;
  end;
  { now move HelpWilds over InputStr }
  for I := 0 to Diff do begin
    for J := 1 to Length(HelpWilds) do
    begin
      if (InputStr[I + J] = HelpWilds[J]) or (HelpWilds[J] = '?') then
      begin
        if J = Length(HelpWilds) then
        begin
          Result := I + 1;
          Exit;
        end;
      end
      else Break;
    end;
  end;
  Result := 0;
end;

function XorEncode(const Key, Source: AnsiString): AnsiString;
var
  I: Integer;
  B: Byte;
begin
  Result := '';
  for I := 1 to Length(Source) do
  begin
    if Length(Key) > 0 then
      B := Byte(Key[1 + ((I - 1) mod Length(Key))]) xor Byte(Source[I])
    else
      B := Byte(Source[I]);
    Result := Result + AnsiString(AnsiLowerCase(IntToHex(B, 2)));
  end;
end;

function XorDecode(const Key, Source: AnsiString): AnsiString;
var
  I: Integer;
  B: Byte;
begin
  Result := '';
  for I := 0 to Length(Source) div 2 - 1 do
  begin
    B := StrToIntDef('$' + string(Copy(Source, (I * 2) + 1, 2)), Ord(' '));
    if Length(Key) > 0 then
      B := Byte(Key[1 + (I mod Length(Key))]) xor B;
    Result := Result + AnsiChar(B);
  end;
end;

{$IFDEF DELPHI5} // Delphi 5
function IncludeTrailingPathDelimiter(const S: string): string;
begin
  Result := S;
  if not IsPathDelimiter(Result, Length(Result)) then
    Result := Result + PathDelim;
end;

function Get8087CW: Word;
asm
        PUSH    0
        FNSTCW  [ESP].Word
        POP     EAX
end;
{$ENDIF DELPHI5}

{$IFNDEF DELPHI12_UP}
function UnicodeFromLocaleChars(CodePage, Flags: Cardinal; LocaleStr: PAnsiChar;
  LocaleStrLen: Integer; UnicodeStr: PWideChar; UnicodeStrLen: Integer): Integer;
begin
  Result := MultiByteToWideChar(CodePage, Flags, LocaleStr, LocaleStrLen, UnicodeStr, UnicodeStrLen);
end;

function UTF8ToUnicode(Dest: PWideChar; MaxDestChars: Cardinal; Source: PAnsiChar; SourceBytes: Cardinal): Cardinal;
begin
  Result := 0;
  if Source = nil then Exit;
  if (Dest <> nil) and (MaxDestChars > 0) then
  begin
    Result := Cardinal(UnicodeFromLocaleChars(CP_UTF8, 0, Source, Integer(SourceBytes), Dest, Integer(MaxDestChars)));
    if (Result > 0) and (Result <= MaxDestChars) then
    begin
      if (SourceBytes = Cardinal(-1)) and (Dest[Result - 1] = #0) then Exit;

      if Result = MaxDestChars then
      begin
        if (Result > 1) and (Word(Dest[Result - 1]) >= $DC00) and (Word(Dest[Result - 1]) <= $DFFF) then
          Dec(Result);
      end else
        Inc(Result);
      Dest[Result - 1] := #0;
    end;
  end else
    Result := Cardinal(UnicodeFromLocaleChars(CP_UTF8, 0, Source, Integer(SourceBytes), nil, 0));
end;

function UTF8ToUnicodeString(const S: PAnsiChar): WideString;
var
  L: Integer;
  Temp: WideString;
begin
  Result := '';
  if S = '' then Exit;
  L := Length(S);
  SetLength(Temp, L);

  L := UTF8ToUnicode(PWideChar(Temp), L + 1, S, L);
  if L > 0 then
    SetLength(Temp, L - 1)
  else
    Temp := '';
  Result := Temp;
end;

function UTF8ToString(const S: PAnsiChar): WideString;
begin
  Result := UTF8ToUnicodeString(S);
end;
{$ENDIF DELPHI12_UP}

{$IFNDEF MOBILE}
function SetArithmeticMask: TArithmeticMask;
var
   ControlWord: Word;
begin
  ControlWord := Get8087CW;
  Result.Fpu := ControlWord and $3F;
  Set8087CW(ControlWord or $3F);
{$IFDEF FPC}
  ControlWord := GetSSECSR;
  Result.SSE := ControlWord and $1F80;
  SetSSECSR(ControlWord or $1F80);
{$ELSE}
  {$IFDEF CPUX64}
  ControlWord := GetMXCSR;
  Result.SSE := ControlWord and $1F80;
  SetMXCSR(ControlWord or $1F80);
  {$ENDIF CPUX64}
{$ENDIF FPC}
end;

procedure RestoreArithmeticMask(Mask: TArithmeticMask);
var
   ControlWord: Word;
begin
  ControlWord := Get8087CW;
  Set8087CW((ControlWord and (not $3F)) or Mask.FPU);
{$IFDEF FPC}
  ControlWord := GetSSECSR;
  SetSSECSR((ControlWord and (not $1F80)) or Mask.SSE);
{$ELSE}
  {$IFDEF CPUX64}
  ControlWord := GetMXCSR;
  SetMXCSR((ControlWord and (not $1F80)) or Mask.SSE);
  {$ENDIF CPUX64}
{$ENDIF FPC}
end;
{$ENDIF MOBILE}

begin
end.
