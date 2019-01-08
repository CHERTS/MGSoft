{ ############################################################################ }
{ #                                                                          # }
{ #  MGSoft Delphi Components v1.0.0                                         # }
{ #                                                                          # }
{ #  License: GPLv3                                                          # }
{ #                                                                          # }
{ #  Author: Mikhail Grigorev (icq: 161867489, email: sleuthhound@gmail.com) # }
{ #                                                                          # }
{ ############################################################################ }

unit RegisterMGSoft;

{$I MGSoft.inc}
{$R MGSoft.dcr}

interface

procedure Register;
{$IFNDEF FPC}
{$IFNDEF CLR}
{$IFDEF DELPHI2005_UP}
procedure RegisterSplashScreen(ProductName, ProductVersion, LicensedType: String; HProductICON: LongWord; IsTrial: Boolean);
procedure RegisterAboutBox(ProductName, ProductVersion, ProductEdition, AboutDescription, LicensedType: String; HProductICON: LongWord; IsTrial: Boolean);
procedure UnregisterAboutBox;
{$ENDIF DELPHI2005_UP}
{$ENDIF CLR}
{$ENDIF FPC}

implementation

uses
{$IFDEF HAS_UNITSCOPE}
  {$IFDEF MSWINDOWS}
  Winapi.Windows,
  {$ENDIF MSWINDOWS}
  System.Classes, System.SysUtils,
  {$IFDEF HAS_VCL}
  Vcl.Controls,
  {$ELSE}
  FMX.Controls,
  {$ENDIF}
{$ELSE ~HAS_UNITSCOPE}
  {$IFDEF MSWINDOWS}
  Windows,
  {$ENDIF MSWINDOWS}
  Classes, SysUtils, Controls,
{$ENDIF ~HAS_UNITSCOPE}
{$IFDEF CLR}
  Borland.Vcl.Design.DesignEditors, Borland.Vcl.Design.DesignIntf,
{$ELSE}
  {$IFDEF FPC}
    PropEdits, ComponentEditors, LResources,
  {$ELSE}
    {$IFDEF DELPHI6_UP}RTLConsts, DesignEditors, DesignIntf, {$ELSE}DsgnIntf,{$ENDIF DELPHI6_UP}
  {$ENDIF FPC}
{$ENDIF CLR}
{$IFNDEF FPC}
{$IFNDEF CLR}
{$IFDEF DELPHI2005_UP}
  ToolsAPI, Graphics,
{$ENDIF DELPHI2005_UP}
{$ENDIF CLR}
{$ENDIF FPC}
  MGUtils,{$IFDEF EnableMGSAPI} MGSAPI,{$ENDIF EnableMGSAPI}{$IFDEF EnableMGGoogleTTS} MGGoogleTTS,{$ENDIF EnableMGGoogleTTS}{$IFDEF EnableMGYandexTTS} MGYandexTTS,{$ENDIF EnableMGYandexTTS}{$IFDEF EnableMGNuanceTTS} MGNuanceTTS,{$ENDIF EnableMGNuanceTTS} MGHotKeyManager,{$IFDEF EnableMGSMTP} MGSMTP,{$ENDIF EnableMGSMTP} MGHook, MGPlacement,
  MGPlacementMinMaxEditor, MGPlacementFormStorageEditor,{$IFDEF EnableMGTessOCR} MGTessOCR,{$ENDIF EnableMGTessOCR} MGThread, MGTrayIcon,{$IFDEF EnableMGOSInfo} MGOSInfo,{$ENDIF EnableMGOSInfo}
{$IFDEF DELPHI2005_UP}{$IFDEF EnableMGISpeechTTS}MGISpeechTTS, {$ENDIF EnableMGISpeechTTS}{$IFNDEF FPC}MGButtonGroup,{$ENDIF FPC}{$ENDIF DELPHI2005_UP}
{$IFDEF MSWINDOWS}
  FileCtrl, ExtDlgs,
{$ENDIF MSWINDOWS}
  TypInfo, Dialogs;

type
{$IFDEF EnableMGGoogleTTS}
  TGTTSFileNameProperty = class(TStringProperty)
  public
    procedure Edit; override;
    function GetAttributes: TPropertyAttributes; override;
  end;
{$ENDIF EnableMGGoogleTTS}
{$IFDEF EnableMGYandexTTS}
  TYTTSFileNameProperty = class(TStringProperty)
  public
    procedure Edit; override;
    function GetAttributes: TPropertyAttributes; override;
  end;
{$ENDIF EnableMGYandexTTS}
{$IFDEF DELPHI2005_UP}
{$IFDEF EnableMGISpeechTTS}
  TISpeechTTSFileNameProperty = class(TStringProperty)
  public
    procedure Edit; override;
    function GetAttributes: TPropertyAttributes; override;
  end;
{$ENDIF EnableMGISpeechTTS}
{$ENDIF DELPHI2005_UP}
{$IFDEF EnableMGNuanceTTS}
  TNuanceTTSFileNameProperty = class(TStringProperty)
  public
    procedure Edit; override;
    function GetAttributes: TPropertyAttributes; override;
  end;
{$ENDIF EnableMGNuanceTTS}
  TMGComponentFormProperty = class(TComponentProperty)
  public
    procedure GetValues(Proc: TGetStrProc); override;
    procedure SetValue(const Value: string); override;
  end;
{$IFDEF EnableMGTessOCR}
  TMGTessOCRDataPathProperty = class(TStringProperty)
  public
    function GetAttributes: TPropertyAttributes; override;
    procedure Edit; override;
  end;
  TMGTessOCRPictureFileNameProperty = class(TStringProperty)
  public
    function GetAttributes: TPropertyAttributes; override;
    procedure Edit; override;
  end;
{$ENDIF EnableMGTessOCR}

{$IFNDEF FPC}
{$IFDEF DELPHI2005_UP}
const
  MGVersion = '1.0.5';

resourcestring
  resPackageName = 'MGSoft Delphi Components';
  resPackageVersion = MGVersion;
  resAboutDescription = 'MGSoft Delphi Components';
  resAboutURL = 'Web: http://programs74.ru/';
  resAboutCopyright = 'Copyright 2014-2019 by Mikhail Grigorev. All rights reserved.';
{$IFDEF TRIAL}
  resLicense = 'Trial';
{$ELSE}
  resLicense = 'Licensed';
{$ENDIF TRIAL}
  resProductEdition = {$IFDEF STD}'Standard edition'{$ELSE}'Professional edition'{$ENDIF};

var
  AboutBoxServices: IOTAAboutBoxServices = nil;
  AboutBoxIndex: Integer = 0;
{$ENDIF}
{$ENDIF FPC}

{ TMGGTTS }
{$IFDEF EnableMGGoogleTTS}
function TGTTSFileNameProperty.GetAttributes: TPropertyAttributes;
begin
  Result := [paDialog, paRevertable];
end;

procedure TGTTSFileNameProperty.Edit;
const
  OpenFilter = 'MP3 files (*.mp3)|*.mp3|All files (*.*)|*.*';
begin
  with TOpenDialog.Create(nil) do
  try
    FileName := ExtractFileName(GetValue);
    InitialDir := ExtractFilePath(GetValue);
    Filter := OpenFilter;
    Options := Options + [ofPathMustExist, ofFileMustExist];
    if Execute then
      SetValue(FileName);
  finally
    Free;
  end;
end;
{$ENDIF EnableMGGoogleTTS}

{ TMGYTTS }
{$IFDEF EnableMGYandexTTS}
function TYTTSFileNameProperty.GetAttributes: TPropertyAttributes;
begin
  Result := [paDialog, paRevertable];
end;

procedure TYTTSFileNameProperty.Edit;
const
  OpenFilter = 'MP3 files (*.mp3)|*.mp3|All files (*.*)|*.*';
begin
  with TOpenDialog.Create(nil) do
  try
    FileName := ExtractFileName(GetValue);
    InitialDir := ExtractFilePath(GetValue);
    Filter := OpenFilter;
    Options := Options + [ofPathMustExist, ofFileMustExist];
    if Execute then
      SetValue(FileName);
  finally
    Free;
  end;
end;
{$ENDIF EnableMGYandexTTS}

{ TMGISpeechTTS }

{$IFDEF EnableMGISpeechTTS}
function TISpeechTTSFileNameProperty.GetAttributes: TPropertyAttributes;
begin
  Result := [paDialog, paRevertable];
end;

procedure TISpeechTTSFileNameProperty.Edit;
const
  OpenFilter = 'AIFF files (*.aiff)|*.aiff|MP3 files (*.mp3)|*.mp3|OGG files (*.ogg)|*.ogg|WMA files (*.wma)|*.wma|'+
                'FLAC files (*.flac)|*.flac|WAV files (*.wav)|*.wav|ALAW files (*.alaw)|*.law|ULAW files (*.ulaw)|*.ulaw|'+
                'VOX files (*.vox)|*.vox|MP4 files (*.mp4)|*.mp4|All files (*.*)|*.*';
begin
  with TOpenDialog.Create(nil) do
  try
    FileName := ExtractFileName(GetValue);
    InitialDir := ExtractFilePath(GetValue);
    Filter := OpenFilter;
    Options := Options + [ofPathMustExist, ofFileMustExist];
    if Execute then
      SetValue(FileName);
  finally
    Free;
  end;
end;
{$ENDIF EnableMGISpeechTTS}

{ TMGNuanceTTS }

{$IFDEF EnableMGNuanceTTS}
function TNuanceTTSFileNameProperty.GetAttributes: TPropertyAttributes;
begin
  Result := [paDialog, paRevertable];
end;

procedure TNuanceTTSFileNameProperty.Edit;
const
  OpenFilter = 'WAV files (*.wav)|*.wav|SPEEX files (*.speex)|*.speex|AMR files (*.amr)|*.amr|'+
                'QCELP files (*.qcelp)|*.qcelp|EVRC files (*.evrc)|*.evrc|All files (*.*)|*.*';
begin
  with TOpenDialog.Create(nil) do
  try
    FileName := ExtractFileName(GetValue);
    InitialDir := ExtractFilePath(GetValue);
    Filter := OpenFilter;
    Options := Options + [ofPathMustExist, ofFileMustExist];
    if Execute then
      SetValue(FileName);
  finally
    Free;
  end;
end;
{$ENDIF EnableMGNuanceTTS}

{ TMGComponentFormProperty }

procedure TMGComponentFormProperty.GetValues(Proc: TGetStrProc);
begin
  inherited GetValues(Proc);
{$IFDEF DELPHI6_UP}
  if (Designer.Root is GetTypeData(GetPropType)^.ClassType) and
    (Designer.Root.Name <> '') then Proc(Designer.Root.Name);
{$ELSE}
  if (Designer.Form is GetTypeData(GetPropType)^.ClassType) and
    (Designer.Form.Name <> '') then Proc(Designer.Form.Name);
{$ENDIF}
end;

procedure TMGComponentFormProperty.SetValue(const Value: string);
var
  Component: TComponent;
begin
{$IFNDEF DELPHI1}
  Component := Designer.GetComponent(Value);
{$ELSE}
  Component := Designer.Form.FindComponent(Value);
{$ENDIF}
{$IFDEF DELPHI6_UP}
  if ((Component = nil) or not (Component is GetTypeData(GetPropType)^.ClassType))
    and (CompareText(Designer.Root.Name, Value) = 0) then
  begin
    if not (Designer.Root is GetTypeData(GetPropType)^.ClassType) then
      raise EPropertyError.Create(SInvalidPropertyValue);
    SetOrdValue(Longint(Designer.Root));
{$ELSE}
  if ((Component = nil) or not (Component is GetTypeData(GetPropType)^.ClassType))
    and (CompareText(Designer.Form.Name, Value) = 0) then
  begin
    if not (Designer.Form is GetTypeData(GetPropType)^.ClassType) then
      raise EPropertyError.Create(ResStr(SInvalidPropertyValue));
    SetOrdValue(Longint(Designer.Form));
{$ENDIF}
  end
  else
    inherited SetValue(Value);
end;

{ TMGTessOCR }

{$IFDEF EnableMGTessOCR}
procedure TMGTessOCRDataPathProperty.Edit;
var
  OCR: TMGTessOCR;
  Directory: String;
begin
  OCR := GetComponent(0) as TMGTessOCR;
  Directory := OCR.DataPath;
  if SelectDirectory(rsOCRSelectTesseractDataDir, '', Directory) then
  begin
    OCR.DataPath := Directory;
    Modified;
  end;
end;

function TMGTessOCRDataPathProperty.GetAttributes: TPropertyAttributes;
begin
  Result := [paDialog];
end;

procedure TMGTessOCRPictureFileNameProperty.Edit;
var
  OCR: TMGTessOCR;
begin
  OCR := GetComponent(0) as TMGTessOCR;
  with TOpenPictureDialog.Create(nil) do
  try
    FileName := OCR.PictureFileName;
    if Execute then
    begin
      OCR.PictureFileName := FileName;
      Modified;
    end
  finally
    Free;
  end
end;

function TMGTessOCRPictureFileNameProperty.GetAttributes: TPropertyAttributes;
begin
  Result := [paDialog];
end;
{$ENDIF EnableMGTessOCR}

{$IFNDEF FPC}
{$IFNDEF CLR}
{$IFDEF DELPHI2005_UP}
procedure RegisterSplashScreen(ProductName, ProductVersion, LicensedType: String; HProductICON: LongWord; IsTrial: Boolean);
begin
  SplashScreenServices.AddPluginBitmap(ProductName + ' ' + ProductVersion, HProductICON, IsTrial, LicensedType);
end;

procedure RegisterAboutBox(ProductName, ProductVersion, ProductEdition, AboutDescription, LicensedType: String; HProductICON: LongWord; IsTrial: Boolean);
begin
  Supports(BorlandIDEServices,IOTAAboutBoxServices, AboutBoxServices);
  AboutBoxIndex := AboutBoxServices.AddPluginInfo(ProductName + ' ' + ProductVersion, AboutDescription, HProductICON, IsTrial, LicensedType, ProductEdition);
end;

procedure UnregisterAboutBox;
begin
  if (AboutBoxIndex <> 0) and Assigned(AboutBoxServices) then
  begin
    AboutBoxServices.RemovePluginInfo(AboutBoxIndex);
    AboutBoxIndex := 0;
    AboutBoxServices := nil;
  end;
end;
{$ENDIF DELPHI2005_UP}
{$ENDIF CLR}
{$ENDIF FPC}

{ Register }

procedure Register;
begin
  RegisterComponents('MGSoft', [{$IFDEF EnableMGSAPI}TMGSAPI, {$ENDIF EnableMGSAPI}{$IFDEF EnableMGGoogleTTS}TMGGoogleTTS, {$ENDIF EnableMGGoogleTTS}{$IFDEF EnableMGYandexTTS}TMGYandexTTS, {$ENDIF EnableMGYandexTTS}{$IFDEF EnableMGNuanceTTS}TMGNuanceTTS, {$ENDIF EnableMGNuanceTTS}TMGHotKeyManager,{$IFDEF EnableMGSMTP} TMGSMTP,{$ENDIF EnableMGSMTP}
                   TMGWindowHook, TMGFormStorage, TMGFormPlacement,{$IFDEF EnableMGTessOCR} TMGTessOCR,{$ENDIF EnableMGTessOCR} TMGThread, TMGTrayIcon{$IFDEF EnableMGOSInfo}, TMGOSInfo{$ENDIF EnableMGOSInfo}]);
  {$IFDEF DELPHI2005_UP}
  {$IFDEF EnableMGISpeechTTS}RegisterComponents('MGSoft', [TMGISpeechTTS]);{$ENDIF EnableMGISpeechTTS}
  {$IFNDEF FPC}RegisterComponents('MGSoft', [TMGButtonGroup]);{$ENDIF FPC}
  {$ENDIF}

{ TMGGTTS }
{$IFDEF EnableMGGoogleTTS}
  RegisterPropertyEditor(TypeInfo(String), TMGGoogleTTS, 'OutFileName', TGTTSFileNameProperty);
{$ENDIF EnableMGGoogleTTS}

{ TMGYTTS }
{$IFDEF EnableMGYandexTTS}
  RegisterPropertyEditor(TypeInfo(String), TMGYandexTTS, 'OutFileName', TYTTSFileNameProperty);
{$ENDIF EnableMGYandexTTS}

{ TMGISpeechTTS }
{$IFDEF DELPHI2005_UP}
{$IFDEF EnableMGISpeechTTS}
  RegisterPropertyEditor(TypeInfo(String), TMGISpeechTTS, 'OutFileName', TISpeechTTSFileNameProperty);
{$ENDIF EnableMGISpeechTTS}
{$ENDIF}

{ TMGNuanceTTS }
{$IFDEF EnableMGNuanceTTS}
  RegisterPropertyEditor(TypeInfo(String), TMGNuanceTTS, 'OutFileName', TNuanceTTSFileNameProperty);
{$ENDIF EnableMGNuanceTTS}

{ TMGFormPlacement }
  RegisterPropertyEditor(TypeInfo(TMGWinMinMaxInfo), TMGFormPlacement, 'MinMaxInfo', TMGMinMaxProperty);

{ TMGFormStorage }
  RegisterComponentEditor(TMGFormStorage, TMGFormStorageEditor);
  RegisterPropertyEditor(TypeInfo(TStrings), TMGFormStorage, 'StoredProps', TMGStoredPropsProperty);

{ TMGWindowHook }
  RegisterPropertyEditor(TypeInfo(TWinControl), TMGWindowHook, 'WinControl', TMGComponentFormProperty);

{$IFDEF EnableMGTessOCR}
{ TMGTessOCR }
  RegisterPropertyEditor(TypeInfo(String), TMGTessOCR, 'DataPath', TMGTessOCRDataPathProperty);
  RegisterPropertyEditor(TypeInfo(String), TMGTessOCR, 'PictureFileName', TMGTessOCRPictureFileNameProperty);
{$ENDIF EnableMGTessOCR}

{$IFDEF DELPHI3_UP}
  RegisterNonActiveX([TMGFormPlacement, TMGFormStorage, TMGWindowHook], axrComponentOnly);
{$ENDIF DELPHI3_UP}
end;

initialization
{$IFNDEF FPC}
{$IFNDEF CLR}
{$IFDEF DELPHI2005_UP}
  RegisterSplashScreen(resPackageName,
                       resPackageVersion,
                       resLicense,
                       LoadBitmap(HInstance, {$IFDEF DELPHI2005}'SPLASHGR'{$ENDIF}
                                             {$IFDEF DELPHI10}'SPLASHBL'{$ENDIF}
                                             {$IFDEF DELPHI11}'SPLASHWH'{$ENDIF}
                                             {$IFDEF DELPHI12}'SPLASHWH'{$ENDIF}
                                             {$IFDEF DELPHI14_UP}'SPLASHBL'{$ENDIF}),
                       {$IFDEF TRIAL}True{$ELSE}False{$ENDIF});
  RegisterAboutBox(resPackageName,
                   resPackageVersion,
                   resProductEdition,
                   resAboutDescription + sLineBreak +
                   resAboutCopyright + sLineBreak +
                   resAboutURL,
                   resLicense,
                   LoadBitmap(HInstance, 'ABOUT'),
                   {$IFDEF TRIAL}True{$ELSE}False{$ENDIF});
{$ENDIF DELPHI2005_UP}
{$ENDIF CLR}
{$ENDIF FPC}
{$IFDEF FPC}
  {$I MGSoft.lrs}
{$ENDIF FPC}

{$IFNDEF FPC}
{$IFNDEF CLR}
{$IFDEF DELPHI2005_UP}
finalization
  UnregisterAboutBox;
{$ENDIF DELPHI2005_UP}
{$ENDIF CLR}
{$ENDIF FPC}

end.
