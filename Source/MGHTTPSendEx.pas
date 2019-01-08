{ ############################################################################ }
{ #                                                                          # }
{ #  MGSoft Delphi Components v1.0.0                                         # }
{ #                                                                          # }
{ #  THTTPSendEx v1.0.0                                                      # }
{ #                                                                          # }
{ #  License: GPLv3                                                          # }
{ #                                                                          # }
{ #  Author: Mikhail Grigorev (icq: 161867489, email: sleuthhound@gmail.com) # }
{ #                                                                          # }
{ ############################################################################ }

unit MGHTTPSendEx;

{$I MGSoft.inc}
{$R+}
{$IFDEF BCB3} // C++ Builder 3
  {$ObjExportAll On}
{$ENDIF BCB3}

interface

uses
{$IFDEF HAS_UNITSCOPE}
  System.Classes, System.SysUtils, System.StrUtils,
{$ELSE ~HAS_UNITSCOPE}
  Classes, SysUtils, StrUtils,
{$ENDIF ~HAS_UNITSCOPE}
{$IFNDEF DELPHI2005_UP}{$IFNDEF FPC}TntClasses,{$ENDIF FPC}{$ENDIF DELPHI2005_UP}
  synautil, blcksock, httpsend;

const
  HTTPVersion09 = '0.9';
  HTTPVersion10 = '1.0';
  HTTPVersion11 = '1.1';
  HTTPVersion20 = '2.0';
  DefaultUserAgent = 'Mozilla/5.0 (Windows NT 6.1; rv:17.0) Gecko/17.0 Firefox/17.0';

type
  THTTPSendEx = class(THTTPSend)
  private
    function HTTPMethodPost(const mURL: {$IFDEF DELPHIXE2_UP}String{$ELSE}WideString{$ENDIF}; mMethodReplacer: String = ''): Boolean;
    function HTTPMethodGet(const mURL: {$IFDEF DELPHIXE2_UP}String{$ELSE}WideString{$ENDIF}): Boolean;
    function GetDataLength: Int64;
    function GetDataLengthEx: Int64;
    function GetResponseCode: Integer;
  protected
    function GetIs200: Boolean;
    function GetIs202: Boolean;
    function GetIs404: Boolean;
  public
    constructor Create; overload;
    constructor Create(const mUserAgent: String); overload;
    constructor Create(const mUserAgent: String; const mHTTPVersion: String = HTTPVersion11); overload;
    destructor Destroy; override;
    procedure StringToStream(mStr: {$IFDEF DELPHIXE2_UP}String{$ELSE}WideString{$ENDIF});
    function StreamToString: {$IFDEF DELPHIXE2_UP}String{$ELSE}WideString{$ENDIF};
    function Post(mURL, mParams: {$IFDEF DELPHIXE2_UP}String{$ELSE}WideString{$ENDIF}; out mResponseStr: String): Boolean; overload;
    function Post(mURL, mParams: {$IFDEF DELPHIXE2_UP}String{$ELSE}WideString{$ENDIF}; const mResponseStream: TStream): Boolean; overload;
    function Post(mURL: {$IFDEF DELPHIXE2_UP}String{$ELSE}WideString{$ENDIF}; mParams: TStream; out mResponseStr: String): Boolean; overload;
    function Head(mURL: {$IFDEF DELPHIXE2_UP}String{$ELSE}WideString{$ENDIF}): Boolean;
    function Get(mURL: {$IFDEF DELPHIXE2_UP}String{$ELSE}WideString{$ENDIF}): Boolean; overload;
    function Get(mURL: {$IFDEF DELPHIXE2_UP}String{$ELSE}WideString{$ENDIF}; out mResponseStr: String): Boolean; overload;
    function Get(mURL: {$IFDEF DELPHIXE2_UP}String{$ELSE}WideString{$ENDIF}; const mResponseStream: TStream): Boolean; overload;
    function GetData(mURL: {$IFDEF DELPHIXE2_UP}String{$ELSE}WideString{$ENDIF}; out mResponseStr: String): Boolean;
    function SaveDocument(mFileName: String; mDeleteIfExist: Boolean): Boolean;
    procedure ClearAll;
    property ResponseCode: Integer read GetResponseCode;
    property Is200: Boolean read GetIs200; // Ok
    property Is202: Boolean read GetIs202; // Accepted
    property Is404: Boolean read GetIs404; // Not found
  published
    property Headers;
    property ResultCode;
    property ResultString;
    property Document;
  end;

implementation

{ THTTPSendEx }

constructor THTTPSendEx.Create;
begin
  inherited Create;
  Protocol := HTTPVersion11;
  UserAgent := DefaultUserAgent;
end;

constructor THTTPSendEx.Create(const mUserAgent: String);
begin
  Create;
  Protocol := HTTPVersion11;
  if not(mUserAgent = EmptyStr) then
    UserAgent := mUserAgent;
end;

constructor THTTPSendEx.Create(const mUserAgent: String; const mHTTPVersion: String);
begin
  Create;
  if not(mUserAgent = EmptyStr) then
    UserAgent := mUserAgent;
  if not(mHTTPVersion = EmptyStr) then
    Protocol := mHTTPVersion;
end;

destructor THTTPSendEx.Destroy;
begin
  inherited;
end;

procedure THTTPSendEx.StringToStream(mStr: {$IFDEF DELPHIXE2_UP}String{$ELSE}WideString{$ENDIF});
{$IFDEF DELPHI2009_UP}
var
  Buff: TBytes;
{$ENDIF}
begin
{$IFDEF DELPHI2009_UP}
  Buff := BytesOf(mStr);
  Document.Write(Buff, Length(Buff));
{$ELSE}
  synautil.WriteStrToStream(Document, mStr);
{$ENDIF}
end;

function THTTPSendEx.StreamToString: {$IFDEF DELPHIXE2_UP}String{$ELSE}WideString{$ENDIF};
var
  MS: {$IFDEF DELPHI2005_UP}TMemoryStream{$ELSE}{$IFNDEF FPC}TTntMemoryStream{$ELSE ~FPC}TMemoryStream{$ENDIF FPC}{$ENDIF};
begin
  Result := '';
  MS := {$IFDEF DELPHI2005_UP}TMemoryStream{$ELSE}{$IFNDEF FPC}TTntMemoryStream{$ELSE ~FPC}TMemoryStream{$ENDIF FPC}{$ENDIF}.Create;
  try
    MS.LoadFromStream(Document);
    SetString(Result, PAnsiChar(MS.Memory), MS.Size);
  finally
    MS.free;
  end;
end;

function THTTPSendEx.HTTPMethodPost(const mURL: {$IFDEF DELPHIXE2_UP}String{$ELSE}WideString{$ENDIF}; mMethodReplacer: String = ''): Boolean;
begin
  if (MIMEType = EmptyStr) or (MIMEType = 'text/html') then
    MIMEType := 'application/x-www-form-urlencoded';
  if (mMethodReplacer = EmptyStr) then
    Result := HTTPMethod('POST', mURL)
  else
    Result := HTTPMethod(mMethodReplacer, mURL);
end;

function THTTPSendEx.HTTPMethodGET(const mURL: {$IFDEF DELPHIXE2_UP}String{$ELSE}WideString{$ENDIF}): Boolean;
begin
  if (MIMEType = EmptyStr) or (MIMEType = 'application/x-www-form-urlencoded') then
    MIMEType := 'text/html';
  Result := HTTPMethod('GET', mURL);
end;

function THTTPSendEx.GetDataLength: Int64;
begin
  Headers.NameValueSeparator := ':';
  Result := StrToInt64Def(Headers.Values['Content-Length'], 0) + Length(Headers.Text);
  Headers.NameValueSeparator := '=';
end;

function THTTPSendEx.GetDataLengthEx: Int64;
begin
  HeadersToList(Headers);
  Result := StrToInt64Def(Headers.Values['Content-Length'], -1);
  if Result > -1 then
    Result := Result + Length(Headers.Text);
end;

function THTTPSendEx.GetResponseCode: Integer;
begin
  Result := ResultCode;
end;

function THTTPSendEx.GetIs200: Boolean;
begin
  Result := (ResponseCode = 200);
end;

function THTTPSendEx.GetIs202: Boolean;
begin
  Result := (ResponseCode = 202);
end;

function THTTPSendEx.GetIs404: Boolean;
begin
  Result := (ResponseCode = 404);
end;

function THTTPSendEx.Post(mURL, mParams: {$IFDEF DELPHIXE2_UP}String{$ELSE}WideString{$ENDIF}; out mResponseStr: String): Boolean;
var
  Stream: TStringStream;
begin
  Document.Clear;
  StringToStream(mParams);
  Result := HTTPMethodPOST(mURL);
{$IFDEF DELPHI2009_UP}
  Stream := TStringStream.Create;
{$ELSE}
  Stream := TStringStream.Create('');
{$ENDIF}
  try
{$IFDEF DELPHI2009_UP}
    Stream.LoadFromStream(Document);
{$ELSE}
    Stream.CopyFrom(Document, Document.Size);
{$ENDIF}
    mResponseStr := Stream.DataString;
  finally
    FreeAndNil(Stream);
  end;
end;

function THTTPSendEx.Post(mURL, mParams: {$IFDEF DELPHIXE2_UP}String{$ELSE}WideString{$ENDIF}; const mResponseStream: TStream): Boolean;
begin
  Document.Clear;
  StringToStream(mParams);
  Result := HTTPMethodPOST(mURL);
  mResponseStream.CopyFrom(Document, Document.Size);
end;

function THTTPSendEx.Post(mURL: {$IFDEF DELPHIXE2_UP}String{$ELSE}WideString{$ENDIF}; mParams: TStream; out mResponseStr: String): Boolean;
var
  Stream: TStringStream;
begin
  Document.Clear;
  Document.LoadFromStream(mParams);
  Result := HTTPMethodPOST(mURL);
{$IFDEF DELPHI2009_UP}
  Stream := TStringStream.Create;
{$ELSE}
  Stream := TStringStream.Create('');
{$ENDIF}
  try
{$IFDEF DELPHI2009_UP}
    Stream.LoadFromStream(Document);
{$ELSE}
    Stream.CopyFrom(Document, Document.Size);
{$ENDIF}
    mResponseStr := Stream.DataString;
  finally
    FreeAndNil(Stream);
  end;
end;

function THTTPSendEx.Head(mURL: {$IFDEF DELPHIXE2_UP}String{$ELSE}WideString{$ENDIF}): Boolean;
begin
  Result := False;
  Clear;
  Result := HTTPMethod('HEAD', mURL);
end;

function THTTPSendEx.Get(mURL: {$IFDEF DELPHIXE2_UP}String{$ELSE}WideString{$ENDIF}): Boolean;
begin
  Result := False;
  Clear;
  Result := HTTPMethodGet(mURL);
end;

function THTTPSendEx.Get(mURL: {$IFDEF DELPHIXE2_UP}String{$ELSE}WideString{$ENDIF}; out mResponseStr: String): Boolean;
var
  Stream: TStringStream;
begin
  Result := False;
  Clear;
  Result := HTTPMethodGet(mURL);
{$IFDEF DELPHI2009_UP}
  Stream := TStringStream.Create;
{$ELSE}
  Stream := TStringStream.Create('');
{$ENDIF}
  try
{$IFDEF DELPHI2009_UP}
    Stream.LoadFromStream(Document);
{$ELSE}
    Stream.CopyFrom(Document, Document.Size);
{$ENDIF}
    mResponseStr := Stream.DataString;
  finally
    FreeAndNil(Stream);
  end;
end;

function THTTPSendEx.Get(mURL: {$IFDEF DELPHIXE2_UP}String{$ELSE}WideString{$ENDIF}; const mResponseStream: TStream): Boolean;
begin
  Result := False;
  Clear;
  Result := HTTPMethodGet(mURL);
  mResponseStream.CopyFrom(Document, Document.Size);
end;

function THTTPSendEx.GetData(mURL: {$IFDEF DELPHIXE2_UP}String{$ELSE}WideString{$ENDIF}; out mResponseStr: String): Boolean;
var
  Stream: TStringStream;
begin
  Result := False;
  ClearAll;
  {$IFDEF DELPHI2009_UP}
  Stream := TStringStream.Create;
  {$ELSE}
  Stream := TStringStream.Create('');
  {$ENDIF}
  if Head(mURL) then
  begin
    if GetDataLength > 0 then
    begin
      ClearAll;
      Result := HTTPMethodGet(mURL);
    end;
  end;
  try
    {$IFDEF DELPHI2009_UP}
    Stream.LoadFromStream(Document);
    {$ELSE}
    Stream.CopyFrom(Document, Document.Size);
    {$ENDIF}
    mResponseStr := Stream.DataString;
  finally
    FreeAndNil(Stream);
  end;
end;

function THTTPSendEx.SaveDocument(mFileName: String; mDeleteIfExist: Boolean): Boolean;
begin
  Result := False;
  if GetIs200 then
  begin
    if mDeleteIfExist then
    begin
      if FileExists(mFileName) then
        DeleteFile(mFileName);
    end;
    Document.SaveToFile(mFileName);
    Result := FileExists(mFileName);
  end;
end;

procedure THTTPSendEx.ClearAll;
begin
  Clear;
  Cookies.Clear;
end;

end.
