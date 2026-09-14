[Setup]
AppName=Resident Evil 6 Persian Patch
AppVersion=1.0
AppPublisher=Sensei
DefaultDirName=C:\Program Files (x86)\Steam\steamapps\common\Resident Evil 6
AppendDefaultDirName=no
OutputDir=C:\RE6_Setup_Output
OutputBaseFilename=RE6_Persian_Setup
Compression=lzma2/ultra64
SolidCompression=yes
WizardStyle=modern
PrivilegesRequired=admin

; --- آیکون ستاپ ---
SetupIconFile=icon.ico

; --- پوسترها و توضیحات ---
WizardImageFile=banner.bmp
WizardSmallImageFile=small_logo.bmp
InfoBeforeFile=info.txt

[Files]
Source: "bg.bmp"; Flags: dontcopy
Source: "info.txt"; Flags: dontcopy
Source: "PatchFiles\*.arc"; DestDir: "{app}\nativePC\arc\DX9"; Flags: ignoreversion uninsneveruninstall

[Code]
function GetSystemMetrics(nIndex: Integer): Integer;
  external 'GetSystemMetrics@user32.dll stdcall';

function SetTimer(hWnd: HWND; nIDEvent: UINT_PTR; uElapse: UINT; lpTimerFunc: Longint): UINT_PTR;
  external 'SetTimer@user32.dll stdcall';

function KillTimer(hWnd: HWND; uIDEvent: UINT_PTR): BOOL;
  external 'KillTimer@user32.dll stdcall';

var
  BackgroundForm: TForm;
  BackgroundImage: TBitmapImage;
  CustomMemo: TMemo;
  BGTimerID: UINT_PTR;

procedure CloseBackgroundTimer(H: HWND; Msg: UINT; IdEvent: UINT_PTR; Time: DWORD);
begin
  KillTimer(0, BGTimerID);
  if BackgroundForm <> nil then
  begin
    BackgroundForm.Hide;
    BackgroundForm.Free;
    BackgroundForm := nil;
  end;
  WizardForm.BringToFront;
end;

procedure CreateFullBackground();
var
  BGPath: String;
begin
  BGPath := ExpandConstant('{tmp}\bg.bmp');

  try
    ExtractTemporaryFile('bg.bmp');
  except
  end;

  if FileExists(BGPath) then
  begin
    BackgroundForm := TForm.Create(nil);
    BackgroundForm.BorderStyle := bsNone;
    BackgroundForm.Left := 0;
    BackgroundForm.Top := 0;
    BackgroundForm.Width := GetSystemMetrics(0);
    BackgroundForm.Height := GetSystemMetrics(1);

    BackgroundImage := TBitmapImage.Create(BackgroundForm);
    BackgroundImage.Parent := BackgroundForm;
    BackgroundImage.Align := alClient;
    BackgroundImage.Stretch := True;

    try
      BackgroundImage.Bitmap.LoadFromFile(BGPath);
    except
    end;

    BackgroundForm.Show;
    BGTimerID := SetTimer(0, 0, 2000, CreateCallback(@CloseBackgroundTimer));
  end;
end;

procedure ForceWhiteLabels(Control: TWinControl);
var
  i: Integer;
begin
  for i := 0 to Control.ControlCount - 1 do
  begin
    if Control.Controls[i] is TLabel then
    begin
      TLabel(Control.Controls[i]).Font.Color := clWhite;
    end
    else if Control.Controls[i] is TWinControl then
    begin
      ForceWhiteLabels(TWinControl(Control.Controls[i]));
    end;
  end;
end;

procedure InitializeWizard();
var
  InfoPath: String;
  Lines: TArrayOfString;
  i: Integer;
begin
  CreateFullBackground();

  // تم تیره
  WizardForm.Color := $1E1E1E;
  WizardForm.InnerPage.Color := $1E1E1E;
  WizardForm.MainPanel.Color := $1E1E1E;

  // سفید کردن مستقیم تمامی لیبل‌های هدر و صفحات
  WizardForm.PageNameLabel.Font.Color := clWhite;
  WizardForm.PageDescriptionLabel.Font.Color := clSilver;
  WizardForm.InfoBeforeClickLabel.Font.Color := clWhite;
  
  // صفحه انتخاب مسیر
  WizardForm.SelectDirLabel.Font.Color := clWhite;
  WizardForm.SelectDirBrowseLabel.Font.Color := clWhite;
  WizardForm.DiskSpaceLabel.Font.Color := clWhite;

  // صفحه آماده‌سازی برای نصب
  WizardForm.ReadyLabel.Font.Color := clWhite;

  // صفحات در حال نصب و پایان
  WizardForm.FilenameLabel.Font.Color := clWhite;
  WizardForm.StatusLabel.Font.Color := clWhite;
  WizardForm.FinishedHeadingLabel.Font.Color := clWhite;
  WizardForm.FinishedLabel.Font.Color := clWhite;
  
  ForceWhiteLabels(WizardForm);

  // کادر متنی سفارشی
  WizardForm.InfoBeforeMemo.Visible := False;

  CustomMemo := TMemo.Create(WizardForm);
  CustomMemo.Parent := WizardForm.InfoBeforePage;
  CustomMemo.Left := WizardForm.InfoBeforeMemo.Left;
  CustomMemo.Top := WizardForm.InfoBeforeMemo.Top;
  CustomMemo.Width := WizardForm.InfoBeforeMemo.Width;
  CustomMemo.Height := WizardForm.InfoBeforeMemo.Height;
  CustomMemo.ScrollBars := ssVertical;
  CustomMemo.ReadOnly := True;
  CustomMemo.Color := $2A2A2A;
  CustomMemo.Font.Name := 'Tahoma';
  CustomMemo.Font.Color := clWhite;
  CustomMemo.Font.Size := 9;

  InfoPath := ExpandConstant('{tmp}\info.txt');
  try
    ExtractTemporaryFile('info.txt');
    if LoadStringsFromFile(InfoPath, Lines) then
    begin
      CustomMemo.Lines.Clear;
      for i := 0 to GetArrayLength(Lines) - 1 do
        CustomMemo.Lines.Add(Lines[i]);
    end;
  except
  end;

  WizardForm.BringToFront;
end;

procedure CurPageChanged(CurPageID: Integer);
begin
  // اجبار سفید ماندن تمام متون متغیر در تمامی صفحات هنگام پیمایش
  WizardForm.PageNameLabel.Font.Color := clWhite;
  WizardForm.PageDescriptionLabel.Font.Color := clSilver;
  WizardForm.InfoBeforeClickLabel.Font.Color := clWhite;
  
  WizardForm.SelectDirLabel.Font.Color := clWhite;
  WizardForm.SelectDirBrowseLabel.Font.Color := clWhite;
  WizardForm.DiskSpaceLabel.Font.Color := clWhite;

  WizardForm.ReadyLabel.Font.Color := clWhite;

  WizardForm.FilenameLabel.Font.Color := clWhite;
  WizardForm.StatusLabel.Font.Color := clWhite;
  WizardForm.FinishedHeadingLabel.Font.Color := clWhite;
  WizardForm.FinishedLabel.Font.Color := clWhite;
  
  ForceWhiteLabels(WizardForm);

  WizardForm.BringToFront;
end;

procedure DeinitializeSetup();
begin
  if BackgroundForm <> nil then
  begin
    KillTimer(0, BGTimerID);
    BackgroundForm.Free;
  end;
end;

function GetFileList: TArrayOfString;
begin
  SetArrayLength(Result, 19);
  Result[0]  := 'Collection_eng.arc';
  Result[1]  := 'Core.arc';
  Result[2]  := 'Credit.arc';
  Result[3]  := 'Credit_eng.arc';
  Result[4]  := 'Custom_eng.arc';
  Result[5]  := 'Cutscenes_eng.arc';
  Result[6]  := 'EndLogo.arc';
  Result[7]  := 'Game.arc';
  Result[8]  := 'Game_eng.arc';
  Result[9]  := 'Load_eng.arc';
  Result[10] := 'Menu.arc';
  Result[11] := 'Menu_eng.arc';
  Result[12] := 'Merce_eng.arc';
  Result[13] := 'MerceUI_eng.arc';
  Result[14] := 'Msg_eng.arc';
  Result[15] := 'Record_eng.arc';
  Result[16] := 'Result_eng.arc';
  Result[17] := 'Title.arc';
  Result[18] := 'Title_eng.arc';
end;

procedure CurStepChanged(CurStep: TSetupStep);
var
  i: Integer;
  FileList: TArrayOfString;
  TargetFolder, OrigPath, BakPath: String;
begin
  if CurStep = ssInstall then
  begin
    TargetFolder := AddBackslash(ExpandConstant('{app}')) + 'nativePC\arc\DX9\';
    FileList := GetFileList();

    for i := 0 to GetArrayLength(FileList) - 1 do
    begin
      OrigPath := TargetFolder + FileList[i];
      BakPath := OrigPath + '.bak';

      if FileExists(OrigPath) and not FileExists(BakPath) then
      begin
        RenameFile(OrigPath, BakPath);
      end;
    end;
  end;
end;

procedure CurUninstallStepChanged(UninstallStep: TUninstallStep);
var
  i: Integer;
  FileList: TArrayOfString;
  TargetFolder, FarsiPath, BakPath: String;
begin
  if UninstallStep = usUninstall then
  begin
    TargetFolder := AddBackslash(ExpandConstant('{app}')) + 'nativePC\arc\DX9\';
    FileList := GetFileList();

    for i := 0 to GetArrayLength(FileList) - 1 do
    begin
      FarsiPath := TargetFolder + FileList[i];
      BakPath := FarsiPath + '.bak';

      if FileExists(FarsiPath) then
      begin
        DeleteFile(FarsiPath);
      end;

      if FileExists(BakPath) then
      begin
        RenameFile(BakPath, FarsiPath);
      end;
    end;
  end;
end;