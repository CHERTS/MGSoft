// http://www.webdelphi.ru/2010/10/class-helper-dlya-synapse/

unit SynapseHelper;

interface

uses Classes, SysUtils,httpsend;

type
 THTTPSend_ = class helper for THTTPSend
 public
   function HeaderByName(const HeaderName:string):string;
   function HeaderNameByIndex(index:integer):string;
   function HTTPMethod(const Method, URL: string): Boolean;
 end;

implementation

{ THTTPSend_ }

function THTTPSend_.HeaderByName(const HeaderName: string): string;
var i:integer;
begin
  for i:=0 to Headers.Count-1 do
    begin
      if LowerCase(HeaderNameByIndex(i))=lowercase(HeaderName) then
        begin
          Result:=copy(Headers[i],pos(':',
                       LowerCase(Headers[i]))+2,
                       Length(Headers[i])-length(HeaderName));
          break;
        end;
    end;
end;

function THTTPSend_.HeaderNameByIndex(index: integer): string;
begin
  if (index>(Headers.Count-1))or(index<0) then Exit;
  Result:=copy(Headers[index],0, pos(':',Headers[index])-1)
end;

function THTTPSend_.HTTPMethod(const Method, URL: string): Boolean;
var Heads: TStringList;
    Cooks: TStringList;
    Redirect: string;
    Doc:TMemoryStream;
begin
  try
    Heads:=TStringList.Create;
    Cooks:=TStringList.Create;
    Doc:=TMemoryStream.Create;
    Doc.LoadFromStream(Document);
    Cooks.Assign(Cookies);
    Heads.Assign(Headers);
    Result:=inherited HTTPMethod(Method,URL);
    if (ResultCode=301)or(ResultCode=302) then
      begin
        Redirect:=HeaderByName('location');
        Headers.Assign(Heads);
        Document.Clear;
        Document.LoadFromStream(Doc);
        Cookies.Assign(Cooks);
        Result:=inherited HTTPMethod(Method,Redirect);
       end;
  finally
    FreeAndNil(Heads);
    FreeAndNil(Cooks);
    FreeAndNil(Doc)
  end;
end;

end.
