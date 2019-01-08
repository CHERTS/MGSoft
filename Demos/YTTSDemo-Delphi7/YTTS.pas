{ ################################################################################## }
{ #                                                                                # }
{ #  MGSoft Yandex TTS Demo v1.0.0 - Демонстрация синтез голоса через Yandex TTS   # }
{ #                                                                                # }
{ #  License: GPLv3                                                                # }
{ #                                                                                # }
{ #  MGSoft YTTS Demo                                                              # }
{ #                                                                                # }
{ #  Author: Mikhail Grigorev (icq: 161867489, email: sleuthhound@gmail.com)       # }
{ #                                                                                # }
{ ################################################################################## }

unit YTTS;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, GlobalYTTS, SHFolder, MGYandexTTS, TntStdCtrls, StdCtrls;

type
  TMainForm = class(TForm)
    ButtonSay: TButton;
    EditText: TTntEdit;
    MemoLog: TMemo;
    CBVoices: TTntComboBox;
    MGYandexTTS1: TMGYandexTTS;
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ButtonSayClick(Sender: TObject);
    procedure CBVoicesChange(Sender: TObject);
    procedure MGYandexTTS1Event(Sender: TObject; pInfo: TYTTSResultInfo);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

procedure TMainForm.FormShow(Sender: TObject);
begin
  // Голоса
  if not MGYandexTTS1.GetVoices(CBVoices.Items, True) then
  begin
    CBVoices.ItemIndex := -1;
    CBVoices.Enabled := False;
  end
  else
  begin
    CBVoices.ItemIndex := MGYandexTTS1.YTTSLanguageNum(CBVoices.Items, YandexTL);;
    CBVoicesChange(CBVoices);
  end;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  Caption := ProgramsName + ' v' + ProgramsVer + ' ' + PlatformType;
  ProgramsPath := IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName));
  WorkPath := IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(GetSpecialFolderPath(CSIDL_LOCAL_APPDATA))+ProgramsFolder);
  // Проверяем файл конфигурации
  if not DirectoryExists(WorkPath) then
    CreateDir(WorkPath);
  // Читаем настройки
  LoadINI(WorkPath);
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  SaveINI(WorkPath);
end;

procedure TMainForm.CBVoicesChange(Sender: TObject);
begin
  YandexTL := MGYandexTTS1.YTTSLanguageNameToCode((Sender as TComboBox).Items[(Sender as TComboBox).ItemIndex]);
  MGYandexTTS1.TTSLangCode := YandexTL;
  EditText.Text := MGYandexTTS1.YTTSGetTestPhrase();
end;

procedure TMainForm.MGYandexTTS1Event(Sender: TObject; pInfo: TYTTSResultInfo);
begin
  if pInfo.FStatus = ttsDone then
    MemoLog.Lines.Add(FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ': Результат синтеза сохранен в файл: ' + pInfo.FResult)
  else if pInfo.FStatus = ttsError then
    MemoLog.Lines.Add(FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ': Ошибка: ' + pInfo.FResult)
  else if pInfo.FStatus = ttsInfo then
    MemoLog.Lines.Add(FormatDateTime('dd.mm.yy hh:mm:ss', Now) + ': Информация: ' + pInfo.FResult)
end;

procedure TMainForm.ButtonSayClick(Sender: TObject);
begin
  MGYandexTTS1.TTSLangCode := YandexTL;
  MGYandexTTS1.OutFileName := ProgramsPath+'YandexTTS-'+MGYandexTTS1.TTSLangCode+'.mp3';
  MGYandexTTS1.HTTPTimeout := 3000;
  if EditText.Text <> '' then
    MGYandexTTS1.TTSString := EditText.Text
  else
    MGYandexTTS1.TTSString := MGYandexTTS1.YTTSGetTestPhrase();
  MGYandexTTS1.SpeakText;
end;

end.
