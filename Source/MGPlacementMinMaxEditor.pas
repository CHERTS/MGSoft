{ ############################################################################ }
{ #                                                                          # }
{ #  MGSoft Delphi Components v1.0.0                                         # }
{ #                                                                          # }
{ #  MGPlacement v1.0.0 - Сохранение состояния окна                          # }
{ #                                                                          # }
{ #  License: GPLv3                                                          # }
{ #                                                                          # }
{ #  Author: Mikhail Grigorev (icq: 161867489, email: sleuthhound@gmail.com) # }
{ #                                                                          # }
{ ############################################################################ }

unit MGPlacementMinMaxEditor;

interface

{$I MGSoft.inc}

uses SysUtils, {$IFNDEF DELPHI1} Windows, {$ELSE} WinTypes, WinProcs, {$ENDIF}
  Messages, Classes, Graphics, Controls, Forms, Dialogs, StdCtrls, ExtCtrls,
  Buttons, Mask, MGVCLUtils, MGPlacement, Consts,
  {$IFDEF DELPHI6_UP} DesignIntf, DesignEditors{$ELSE} DsgnIntf{$ENDIF};

type
  TMGMinMaxInfoEditDialog = class(TForm)
    Bevel1: TBevel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    OKButton: TButton;
    CancelButton: TButton;
    MaxPosBtn: TSpeedButton;
    MaxSizeBtn: TSpeedButton;
    MaxTrackBtn: TSpeedButton;
    MinTrackBtn: TSpeedButton;
    MaxPosLeftEdit: TEdit;
    MaxPosTopEdit: TEdit;
    MaxSizeWidthEdit: TEdit;
    MaxSizeHeightEdit: TEdit;
    MaxTrackWidthEdit: TEdit;
    MaxTrackHeightEdit: TEdit;
    MinTrackWidthEdit: TEdit;
    MinTrackHeightEdit: TEdit;
    ClearButton: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure SetCurrentBtnClick(Sender: TObject);
    procedure OKButtonClick(Sender: TObject);
    procedure ClearButtonClick(Sender: TObject);
  private
    { Private declarations }
    FWinMinMaxInfo: TMGWinMinMaxInfo;
    FForm: TCustomForm;
    procedure SeTMGWinMinMaxInfo(Value: TMGWinMinMaxInfo);
    procedure UpdateMinMaxInfo;
  public
    { Public declarations }
    property WinMinMaxInfo: TMGWinMinMaxInfo read FWinMinMaxInfo write SeTMGWinMinMaxInfo;
  end;

{ TMGMinMaxProperty }

  TMGMinMaxProperty = class(TClassProperty)
  public
    function GetAttributes: TPropertyAttributes; override;
    function GetValue: string; override;
    procedure Edit; override;
  end;

function EditMinMaxInfo(AComponent: TMGFormPlacement): Boolean;

implementation

{$R *.dfm}

{$IFNDEF DELPHI1}
 {$D-}
{$ENDIF}

function EditMinMaxInfo(AComponent: TMGFormPlacement): Boolean;
begin
  Result := False;
  if AComponent = nil then Exit;
  with TMGMinMaxInfoEditDialog.Create(Application) do
  try
    WinMinMaxInfo := AComponent.MinMaxInfo;
    if AComponent.Owner is TCustomForm then
      FForm := TCustomForm(AComponent.Owner);
    if AComponent.Name <> '' then
      Caption := Format('%s.MinMaxInfo', [AComponent.Name]);
    Result := ShowModal = mrOk;
    if Result then AComponent.MinMaxInfo := WinMinMaxInfo;
  finally
    Free;
  end;
end;

{ TMGMinMaxProperty }

function TMGMinMaxProperty.GetValue: string;
var
  WinMinMaxInfo: TMGWinMinMaxInfo;
begin
  WinMinMaxInfo := TMGWinMinMaxInfo(GetOrdValue);
  with WinMinMaxInfo do begin
    if DefaultMinMaxInfo then Result := srNone
    else Result := Format('(%d,%d),(%d,%d),(%d,%d),(%d,%d)',
      [MaxPosLeft, MaxPosTop, MaxSizeWidth, MaxSizeHeight,
      MaxTrackWidth, MaxTrackHeight, MinTrackWidth, MinTrackHeight]);
  end;
end;

function TMGMinMaxProperty.GetAttributes: TPropertyAttributes;
begin
  Result := [paSubProperties, paDialog, paReadOnly];
end;

procedure TMGMinMaxProperty.Edit;
begin
  if EditMinMaxInfo(GetComponent(0) as TMGFormPlacement) then Modified;
end;

{ TMGMinMaxInfoEditDialog }

procedure TMGMinMaxInfoEditDialog.SeTMGWinMinMaxInfo(Value: TMGWinMinMaxInfo);
begin
  FWinMinMaxInfo.Assign(Value);
  with FWinMinMaxInfo do begin
    MaxPosLeftEdit.Text := IntToStr(MaxPosLeft);
    MaxPosTopEdit.Text := IntToStr(MaxPosTop);
    MaxSizeWidthEdit.Text := IntToStr(MaxSizeWidth);
    MaxSizeHeightEdit.Text := IntToStr(MaxSizeHeight);
    MaxTrackWidthEdit.Text := IntToStr(MaxTrackWidth);
    MaxTrackHeightEdit.Text := IntToStr(MaxTrackHeight);
    MinTrackWidthEdit.Text := IntToStr(MinTrackWidth);
    MinTrackHeightEdit.Text := IntToStr(MinTrackHeight);
  end;
end;

procedure TMGMinMaxInfoEditDialog.UpdateMinMaxInfo;
begin
  with FWinMinMaxInfo do begin
    MaxPosLeft := StrToInt(MaxPosLeftEdit.Text);
    MaxPosTop := StrToInt(MaxPosTopEdit.Text);
    MaxSizeWidth := StrToInt(MaxSizeWidthEdit.Text);
    MaxSizeHeight := StrToInt(MaxSizeHeightEdit.Text);
    MaxTrackWidth := StrToInt(MaxTrackWidthEdit.Text);
    MaxTrackHeight := StrToInt(MaxTrackHeightEdit.Text);
    MinTrackWidth := StrToInt(MinTrackWidthEdit.Text);
    MinTrackHeight := StrToInt(MinTrackHeightEdit.Text);
  end;
end;

procedure TMGMinMaxInfoEditDialog.FormCreate(Sender: TObject);
begin
  FWinMinMaxInfo := TMGWinMinMaxInfo.Create;
end;

procedure TMGMinMaxInfoEditDialog.FormDestroy(Sender: TObject);
begin
  FWinMinMaxInfo.Free;
end;

procedure TMGMinMaxInfoEditDialog.SetCurrentBtnClick(Sender: TObject);
begin
  if FForm <> nil then
    case TComponent(Sender).Tag of
      1: begin
           MaxPosLeftEdit.Text := IntToStr(TForm(FForm).Left);
           MaxPosTopEdit.Text := IntToStr(TForm(FForm).Top);
         end;
      2: begin
           MaxSizeWidthEdit.Text := IntToStr(TForm(FForm).Width);
           MaxSizeHeightEdit.Text := IntToStr(TForm(FForm).Height);
         end;
      3: begin
           MaxTrackWidthEdit.Text := IntToStr(TForm(FForm).Width);
           MaxTrackHeightEdit.Text := IntToStr(TForm(FForm).Height);
         end;
      4: begin
           MinTrackWidthEdit.Text := IntToStr(TForm(FForm).Width);
           MinTrackHeightEdit.Text := IntToStr(TForm(FForm).Height);
         end;
      else Exit;
    end;
end;

procedure TMGMinMaxInfoEditDialog.OKButtonClick(Sender: TObject);
begin
  UpdateMinMaxInfo;
end;

procedure TMGMinMaxInfoEditDialog.ClearButtonClick(Sender: TObject);
begin
  MaxPosLeftEdit.Text := '0';
  MaxPosTopEdit.Text := '0';
  MaxSizeWidthEdit.Text := '0';
  MaxSizeHeightEdit.Text := '0';
  MaxTrackWidthEdit.Text := '0';
  MaxTrackHeightEdit.Text := '0';
  MinTrackWidthEdit.Text := '0';
  MinTrackHeightEdit.Text := '0';
end;

end.
