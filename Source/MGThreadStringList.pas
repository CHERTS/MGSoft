{ ############################################################################ }
{ #                                                                          # }
{ #  MGSoft Delphi Components v1.0.0                                         # }
{ #                                                                          # }
{ #  License: GPLv3                                                          # }
{ #                                                                          # }
{ #  Author: Mikhail Grigorev (icq: 161867489, email: sleuthhound@gmail.com) # }
{ #                                                                          # }
{ ############################################################################ }

unit MGThreadStringList;

{$I MGSoft.inc}

interface

uses
{$IFDEF HAS_UNITSCOPE}
  {$IFDEF MSWINDOWS}
  Winapi.Windows,
  {$ENDIF MSWINDOWS}
  System.Classes
{$ELSE ~HAS_UNITSCOPE}
  {$IFDEF MSWINDOWS}
  Windows,
  {$ENDIF MSWINDOWS}
  Classes
{$ENDIF ~HAS_UNITSCOPE};

type
  TMGThreadStringList = class
  private
    FStringList: TStringList;
    FLock: TRTLCriticalSection;
    function GetDuplicates: TDuplicates;
    procedure SetDuplicates(dup: TDuplicates);
    function GetCapacity: Integer;
    procedure SetCapacity(capa: Integer);
    function GetCommaText: String;
    procedure SetCommaText(const S: String);
    function GetCount: Integer;
    function GetDelimiter: Char;
    procedure SetDelimiter(delim: Char);
    function GetDelimitedText: String;
    procedure SetDelimitedText(const S: String);
    function GetNames(Index: Integer): String;
    function GetValues(const Name: String): String;
    procedure SetValues(const Name: String; S: String);
    function GetStrings(Index: Integer): String;
    procedure SetStrings(Index: Integer; S: String);
    function GetAsText: String;
    procedure SetAsText(S: String);
  public
    constructor Create;
    destructor Destroy; override;
    function LockList: TStringList;
    procedure UnlockList;
    function Add(const S: String): Integer;
    procedure AddStrings(Strings: TStrings);
    procedure Delete(Index: Integer);
    procedure Clear;
    procedure Exchange(Index1, Index2: Integer);
    function Find(const S: String; var Index: Integer): Boolean;
    procedure Insert(Index: Integer; const S: String);
    function IndexOf(const S: String): Integer;
    function IndexOfName(const Name: String): Integer;
    procedure Sort;
    function GetText: {$IFDEF DELPHI2009_UP}PWideChar{$ELSE}PChar{$ENDIF};
    procedure LoadFromFile(const FileName: String);
    procedure LoadFromStream(Stream: TStream);
    procedure SaveToFile(const FileName: String);
    procedure SaveToStream(Stream: TStream);
    property Duplicates: TDuplicates read GetDuplicates write SetDuplicates;
    property Capacity: Integer read GetCapacity write SetCapacity;
    property CommaText: String read GetCommaText write SetCommaText;
    property Count: Integer read GetCount;
    property Delimiter: Char read GetDelimiter write SetDelimiter;
    property DelimitedText: String read GetDelimitedText write SetDelimitedText;
    property Names[Index: Integer]: String read GetNames;
    property Values[const Name: String]: String read GetValues write SetValues;
    property Strings[Index: Integer]: String read GetStrings write SetStrings; default;
    property Text: String read GetAsText write SetAsText;
  end;

implementation

{ TMGThreadStringList }

constructor TMGThreadStringList.Create;
begin
  inherited Create;
  InitializeCriticalSection(FLock);
  FStringList := TStringList.Create;
  FStringList.Duplicates := dupIgnore;
end;

destructor TMGThreadStringList.Destroy;
begin
  LockList;
  try
    FStringList.Free;
    inherited Destroy;
  finally
    UnlockList;
    DeleteCriticalSection(FLock);
  end;
end;

function TMGThreadStringList.LockList: TStringList;
begin
  EnterCriticalSection(FLock);
  Result := FStringList;
end;

procedure TMGThreadStringList.UnlockList;
begin
  LeaveCriticalSection(FLock);
end;

function TMGThreadStringList.Add(const S: String): Integer;
begin
  Result := -1;
  LockList;
  try
    Result := FStringList.Add(S);
  finally
    UnlockList;
  end;
end;

procedure TMGThreadStringList.AddStrings(Strings: TStrings);
begin
  LockList;
  try
    FStringList.AddStrings(Strings);
  finally
    UnlockList;
  end;
end;

procedure TMGThreadStringList.Delete(Index: Integer);
begin
  LockList;
  try
    FStringList.Delete(Index);
  finally
    UnlockList;
  end;
end;

procedure TMGThreadStringList.Clear;
begin
  LockList;
  try
    FStringList.Clear;
  finally
    UnlockList;
  end;
end;

procedure TMGThreadStringList.Exchange(Index1, Index2: Integer);
begin
  LockList;
  try
    FStringList.Exchange(Index1, Index2);
  finally
    UnlockList;
  end;
end;

function TMGThreadStringList.Find(const S: String; var Index: Integer): Boolean;
begin
  LockList;
  try
    Result := FStringList.Find(S, Index);
  finally
    UnlockList;
  end;
end;

procedure TMGThreadStringList.Insert(Index: Integer; const S: String);
begin
  LockList;
  try
    FStringList.Insert(Index, S);
  finally
    UnlockList;
  end;
end;

function TMGThreadStringList.IndexOf(const S: String): Integer;
begin
  Result := -1;
  LockList;
  try
    Result := FStringList.IndexOf(S);
  finally
    UnlockList;
  end;
end;

function TMGThreadStringList.IndexOfName(const Name: String): Integer;
begin
  Result := -1;
  LockList;
  try
    Result := FStringList.IndexOfName(Name);
  finally
    UnlockList;
  end;
end;

procedure TMGThreadStringList.Sort;
begin
  LockList;
  try
    FStringList.Sort;
  finally
    UnlockList;
  end;
end;

function TMGThreadStringList.GetText: {$IFDEF DELPHI2009_UP}PWideChar{$ELSE}PChar{$ENDIF};
begin
  LockList;
  try
    Result := FStringList.GetText;
  finally
    UnlockList;
  end;
end;

procedure TMGThreadStringList.LoadFromFile(const FileName: String);
begin
  LockList;
  try
    FStringList.LoadFromFile(FileName);
  finally
    UnlockList;
  end;
end;

procedure TMGThreadStringList.LoadFromStream(Stream: TStream);
begin
  LockList;
  try
    FStringList.LoadFromStream(Stream);
  finally
    UnlockList;
  end;
end;

procedure TMGThreadStringList.SaveToFile(const FileName: String);
begin
  LockList;
  try
    FStringList.SaveToFile(FileName);
  finally
    UnlockList;
  end;
end;

procedure TMGThreadStringList.SaveToStream(Stream: TStream);
begin
  LockList;
  try
    FStringList.SaveToStream(Stream);
  finally
    UnlockList;
  end;
end;

function TMGThreadStringList.GetDuplicates: TDuplicates;
begin
  LockList;
  try
    Result := FStringList.Duplicates;
  finally
    UnlockList;
  end;
end;

procedure TMGThreadStringList.SetDuplicates(dup: TDuplicates);
begin
  LockList;
  try
    FStringList.Duplicates := dup;
  finally
    UnlockList;
  end;
end;

function TMGThreadStringList.GetCapacity: Integer;
begin
  LockList;
  try
    Result := FStringList.Capacity;
  finally
    UnlockList;
  end;
end;

procedure TMGThreadStringList.SetCapacity(capa: Integer);
begin
  LockList;
  try
    FStringList.Capacity := capa;
  finally
    UnlockList;
  end;
end;

function TMGThreadStringList.GetCommaText: String;
begin
  LockList;
  try
    Result := FStringList.CommaText;
  finally
    UnlockList;
  end;
end;

procedure TMGThreadStringList.SetCommaText(const S: String);
begin
  LockList;
  try
    FStringList.CommaText := S;
  finally
    UnlockList;
  end;
end;

function TMGThreadStringList.GetCount: Integer;
begin
  LockList;
  try
    Result := FStringList.Count;
  finally
    UnlockList;
  end;
end;

function TMGThreadStringList.GetDelimiter: Char;
begin
  LockList;
  try
    Result := FStringList.Delimiter;
  finally
    UnlockList;
  end;
end;

procedure TMGThreadStringList.SetDelimiter(delim: Char);
begin
  LockList;
  try
    FStringList.Delimiter := delim;
  finally
    UnlockList;
  end;
end;

function TMGThreadStringList.GetDelimitedText: String;
begin
  LockList;
  try
    Result := FStringList.DelimitedText;
  finally
    UnlockList;
  end;
end;

procedure TMGThreadStringList.SetDelimitedText(const S: String);
begin
  LockList;
  try
    FStringList.DelimitedText := S;
  finally
    UnlockList;
  end;
end;

function TMGThreadStringList.GetNames(Index: Integer): String;
begin
  LockList;
  try
    Result := FStringList.Names[Index];
  finally
    UnlockList;
  end;
end;

function TMGThreadStringList.GetValues(const Name: String): String;
begin
  LockList;
  try
    Result := FStringList.Values[Name];
  finally
    UnlockList;
  end;
end;

procedure TMGThreadStringList.SetValues(const Name: String; S: String);
begin
  LockList;
  try
    FStringList.Values[Name] := S;
  finally
    UnlockList;
  end;
end;

function TMGThreadStringList.GetStrings(Index: Integer): String;
begin
  LockList;
  try
    Result := FStringList.Strings[Index];
  finally
    UnlockList;
  end;
end;

procedure TMGThreadStringList.SetStrings(Index: Integer; S: String);
begin
  LockList;
  try
    FStringList.Strings[Index] := S;
  finally
    UnlockList;
  end;
end;

function TMGThreadStringList.GetAsText: String;
begin
  LockList;
  try
    Result := FStringList.Text;
  finally
    UnlockList;
  end;
end;

procedure TMGThreadStringList.SetAsText(S: String);
begin
  LockList;
  try
    FStringList.Text := S;
  finally
    UnlockList;
  end;
end;

end.
