{
Version 1.0.0
create: santaDEL
description: This is a program that allows you to select a specific folder and delete it with only the last value left.
why made?: 서버 백업파일 관리하려고 만들었음
date          Version          remark
2026.01.07    1.0.0            created project
}

unit u_con;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  //addclass
  System.IOUtils,
  System.Types,
  System.Generics.Collections, // TList, TObjectDictionary 사용을 위해 필수
  System.Generics.Defaults,    // TComparer 사용을 위해 필수
  System.DateUtils, Vcl.StdCtrls,
  Winapi.ShellAPI; // <-- 휴지통 기능을 위해 필수 추가
  //여기까지 addclass

type
  Tf_con = class(TForm)
    btnSelectAndCleanup: TButton;
    FileOpenDialog1: TFileOpenDialog;
    MemoLog: TMemo;
    btn_copy: TButton;
    procedure CleanupMonthlyBakFiles(const ARootPath: string);
    procedure btnSelectAndCleanupClick(Sender: TObject);
    procedure AddLog(const AMsg: string);
    procedure btn_copyClick(Sender: TObject);
    function SendToRecycleBin(const AFileName: string): Boolean;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  f_con: Tf_con;

implementation

{$R *.dfm}

{ Tf_con }

procedure Tf_con.AddLog(const AMsg: string);
begin
  MemoLog.Lines.Add(FormatDateTime('[hh:nn:ss] ', Now) + AMsg);
end;

procedure Tf_con.btnSelectAndCleanupClick(Sender: TObject);
begin
FileOpenDialog1.Options := [fdoPickFolders];
  FileOpenDialog1.Title := '월말 .bak 파일만 남길 폴더를 선택하세요' +
                           '[Select the folder where you want to leave only the .bak file at the end of the month]';

  if FileOpenDialog1.Execute then
  begin
    MemoLog.Clear;
    AddLog('Start Work: ' + FileOpenDialog1.FileName);

    if MessageDlg('선택한 폴더에서 "*.bak" 파일 중 월말 파일만 남기고 모두 삭제합니다.' + #13#10 +
                  '계속하시겠습니까?' + #13#10 +
                  'Delete all of the "*.bak" files from the selected folder, leaving only the end-of-month files.' + #13#10 +
                  'Would you like to go on?', mtWarning, [mbYes, mbNo], 0) = mrYes then
    begin
      CleanupMonthlyBakFiles(FileOpenDialog1.FileName);
      AddLog('All operations have been completed.');
      ShowMessage('Done with the task!');
    end
    else
      AddLog('The operation was canceled by the user.');
  end;
end;

procedure Tf_con.btn_copyClick(Sender: TObject);
begin
if MemoLog.Lines.Count > 0 then
  begin
    MemoLog.SelectAll;             // 전체 선택
    MemoLog.CopyToClipboard;       // 클립보드로 복사
    MemoLog.SelLength := 0;        // 선택 해제 (블록 지정된 상태를 지움)

    ShowMessage('Logs have been copied to the clipboard.');
  end
  else
    ShowMessage('There are no logs to copy.');
end;

procedure Tf_con.CleanupMonthlyBakFiles(const ARootPath: string);
var
  LFiles: TArray<string>;
  LFilePath: string;
  LFileDate: TDateTime;
  LMonthKey: string;
  LFileMap: TObjectDictionary<string, TList<string>>;
  LPair: TPair<string, TList<string>>;
  I: Integer;
begin
  LFileMap := TObjectDictionary<string, TList<string>>.Create([doOwnsValues]);
  try
    // 1. *.bak 파일 탐색
    LFiles := TDirectory.GetFiles(ARootPath, '*.bak', TSearchOption.soAllDirectories);

    for LFilePath in LFiles do
    begin
      LFileDate := TFile.GetLastWriteTime(LFilePath);
      // "폴더경로 + 연월"을 키로 사용하면 폴더별로 독립적인 월말 파일이 유지됩니다. (가장 안전)
      LMonthKey := ExtractFilePath(LFilePath) + '_' + FormatDateTime('yyyy-MM', LFileDate);

      if not LFileMap.ContainsKey(LMonthKey) then
        LFileMap.Add(LMonthKey, TList<string>.Create);

      LFileMap[LMonthKey].Add(LFilePath);
    end;

    // 2. 월별 정렬 및 '휴지통' 삭제
    for LPair in LFileMap do
    begin
      if LPair.Value.Count <= 1 then Continue;

      LPair.Value.Sort(TComparer<string>.Construct(
        function(const Left, Right: string): Integer
        begin
          Result := CompareDateTime(TFile.GetLastWriteTime(Right), TFile.GetLastWriteTime(Left));
        end));

      for I := 1 to LPair.Value.Count - 1 do
      begin
        LFilePath := LPair.Value[I];
        // 중요: TFile.Delete 대신 휴지통 함수 호출
        if SendToRecycleBin(LFilePath) then
          AddLog('Go to Trash: ' + ExtractFileName(LFilePath))
        else
          AddLog('Failed to move: ' + ExtractFileName(LFilePath));
      end;
    end;
  finally
    LFileMap.Free;
  end;
end;

function Tf_con.SendToRecycleBin(const AFileName: string): Boolean;
var
  Struct: TSHFileOpStruct;
begin
  FillChar(Struct, SizeOf(Struct), 0);
  Struct.wFunc := FO_DELETE;
  // fFlags 설명:
  // FOF_ALLOWUNDO: 휴지통 사용
  // FOF_NOCONFIRMATION: 삭제 확인창 띄우지 않음
  // FOF_SILENT: 진행창 띄우지 않음
  Struct.fFlags := FOF_ALLOWUNDO or FOF_NOCONFIRMATION or FOF_SILENT;
  Struct.pFrom := PChar(AFileName + #0); // 널 문자로 끝나야 함
  Result := SHFileOperation(Struct) = 0;
end;

end.
