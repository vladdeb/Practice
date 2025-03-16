program Practice;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils;

type   
  TMenu = (mnMain, mnList, mnTalonField, mnDocField);
  TWeekDay = (Mon, Tue, Wed, Thu, Fri, Sat, Sun);
  TWorkDay = Mon..Sat;
  TWorkHours = record
    start: TTime;
    finish: TTime;
  end;
  TSchedule = array[TWeekDay] of TWorkHours;
  TTalonListPt = ^TTalonlist;
  TTalon = Record
    date: Tdate;
    time: TTime;
    queuePos: integer;
    patientLastName: String;
    cabNum: Integer;
    docKey: Integer;
  End;
  TTalonList = record
    Talon: TTalon;
    next: TTalonListPt;
  end;
  TDocListPt = ^TDocList;
  TDoc = record
    docKey: Integer;
    specialisation: String;
    docLastName: String;
    Schedule: TSchedule;
  end;
  TDocList = record
    Doc: TDoc;
    next: TDocListPt;
  end;
  TTalonSearchComp = function(temp: TTalonListPt; const Value): boolean; 
  TDocSearchComp = function(temp: TDocListPt; const Value): boolean; 
  TTalonArr = array of TTalonListPt;                                 
  TDocArr = array of TDocListPt;

const
  WeekNames: array[TWeekDay] of String = ('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday');
  MonthDays: array[1..12] of integer = (31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);

function isDigit(c: char): boolean;
begin
  result := (c >= '0') and (c <= '9');
end;

function correctDate(s: string): boolean;
var
  D, M, Y: integer;
begin
  result := true;
  if length(s) <> 10 then
    result := false
  else if (s[3] <> '.') or (s[6] <> '.') then
    result := false
  else if not(isDigit(s[1]) and isDigit(s[2]) and isDigit(s[4]) and isDigit(s[5]) and
    isDigit(s[7]) and isDigit(s[8]) and isDigit(s[9]) and isDigit(s[10])) then
    result := false
  else
  begin
    D := StrToInt(Copy(S, 1, 2));
    M := StrToInt(Copy(S, 4, 2));
    Y := StrToInt(Copy(S, 7, 4));
    if (Y = 0) or (M = 0) or (D = 0) then
      result := false;
    if (Y < 1900) or (Y > 2025) then
      result := false;
    if M > 12 then
      result := false;
    if D > MonthDays[M] then
      if not ((M = 2) and ((Y mod 400 = 0) or ((Y mod 100 <> 0) and (Y mod 4 = 0))) and (D <= 29)) then
        result := false;
  end;
end;

function correctTime(s: string): boolean;
var
  H, M: integer;
begin
  result := true;
  if length(s) <> 5 then
    result := false
  else if (s[3] <> ':') then
    result := false
  else if not(isDigit(s[1]) and isDigit(s[2]) and isDigit(s[4]) and isDigit(s[5])) then
    result := false
  else
  begin
    H := StrToInt(Copy(S, 1, 2));
    M := StrToInt(Copy(S, 4, 2));
    if M > 59 then
      result := false;
    if H > 24 then
      result := false;
  end;
end;

procedure InputMenu(const n: Integer; var Chose: integer);
var
  flag: boolean;
  temp: string;
  code: Integer;
begin
  flag := false;
  repeat
    readln(temp);
    Val(temp, chose, code);
    if code <> 0 then
      writeln('������� �����')
    else
    begin
      if (chose < 1) or (chose > n) then
        writeln('������� ����� �� 1 �� ', n)
      else
        flag := true;
    end;
  until flag;
end;

procedure InputDate(AMessage, AWrongMessage: String; var Date: TDate);
var
  flag: boolean;
  temp: string;
begin
  flag := true;
  repeat
    write(AMessage);
    readln(temp);
    if not correctDate(temp) then
      writeln(AWrongMessage)
    else
      flag := false;
  until not flag;
  Date := StrToDate(temp);
end;

procedure InputTime(AMessage, AWrongMessage: String; var Time: TTime);
var
  flag: boolean;
  temp: string;
begin
  flag := true;
  repeat
    write(AMessage);
    readln(temp);
    if not correctTime(temp) then
      writeln(AWrongMessage)
    else
      flag := false;
  until not flag;
  Time := StrToTime(temp);
end;

procedure printTalon(temp: TTalon);
begin
  writeln('����: ', DateToStr(temp.date));
  writeln('�����: ', TimeToStr(temp.time));
  writeln('� � �������: ', temp.queuePos);
  writeln('��� ��������: ', temp.patientLastName);
  writeln('�������: ', temp.cabNum);
  writeln('��� �����: ', temp.docKey);
end;

procedure printDoc(temp: TDoc);
begin
  writeln('���: ', temp.docKey);
  writeln('�������������: ', temp.specialisation);
  writeln('��� �����: ', temp.docLastName);
  writeln('������ ������:');
  for var i := Mon to Sat do
    writeln('  ', WeekNames[i], ': ', TimeToStr(temp.Schedule[i].start), '-', TimeToStr(temp.Schedule[i].finish));
end;

procedure printTalonList(const Head: TTalonListPt);
var
  temp: TTalonListPt;
begin
  if Head^.next = nil then
    writeln('������ ����');
  temp := head.next;
  while temp <> nil do
  begin
    printTalon(temp^.Talon);
    writeln;
    temp := temp^.next;
  end;
end;

procedure printDocList(const Head: TDocListPt);
var
  temp: TDocListPt;
  i: TWeekDay;
begin
  if Head^.next = nil then
    writeln('������ ����');
  printDoc(temp^.Doc);
  temp := head.next;
  while temp <> nil do
  begin
    
    temp := temp^.next;
  end;
end;
//����������� ������ �������
function searchCompTalonDate(temp: TTalonListPt; const Value): boolean;
begin
  result := temp^.Talon.date = TDate(Value);
end;

function searchCompTalonTime(temp: TTalonListPt; const Value): boolean;
begin
  result := temp^.Talon.time = TTime(Value);  
end;

function searchCompTalonQueue(temp: TTalonListPt; const Value): boolean;
begin
  result := temp^.Talon.queuePos = Integer(Value);  
end;

function searchCompTalonPatientLastName(temp: TTalonListPt; const Value): boolean;
begin
  result := temp^.Talon.patientLastName = String(Value);  
end;

function searchCompTalonCabNum(temp: TTalonListPt; const Value): boolean;
begin
  result := temp^.Talon.cabNum = Integer(Value);  
end;
                                       
function searchCompTalonDocKey(temp: TTalonListPt; const Value): boolean;
begin
  result := temp^.Talon.docKey = Integer(Value);  
end;

function SearchTalon(const Head: TTalonListPt; const Comp: TTalonSearchComp; const Value): TTalonArr;
var
  temp: TTalonListPt;
begin
  SetLength(result, 0);
  temp := head.next;
  while temp <> nil do
  begin
    if comp(temp, Value) then
    begin
      SetLength(result, length(result) + 1);
      result[High(result)] := temp;
    end;
    temp := temp^.next;
  end;
end;

function searchCompDocKey(temp: TDocListPt; const Value): boolean;
begin
  result := temp^.Doc.docKey = Integer(Value);
end;

function searchCompDocSpecialisation(temp: TDocListPt; const Value): boolean;
begin
  result := temp^.Doc.specialisation = String(Value);
end;

function searchCompDocName(temp: TDocListPt; const Value): boolean;
begin
  result := temp^.Doc.doclastName = String(Value);
end;

function SearchDoc(const Head: TDocListPt; const Comp: TDocSearchComp; const Value): TDocArr;
var
  temp: TDocListPt;
begin
  SetLength(result, 0);
  temp := head.next;
  while temp <> nil do
  begin
    if comp(temp, Value) then
    begin
      SetLength(result, length(result) + 1);
      result[High(result)] := temp;
    end;
    temp := temp^.next;
  end;
end;

function MakeTalon(const TalonList: TTalonListPt; const docList: TDocListPt; const Date: TDate; const Time: TTime; const patient: String; const cabNum, docKey: Integer; var ErrorCode: Integer): TTalon;
var
  DocArr: TDocArr;
  TalonArr: TTalonArr;
  WeekDay: TWeekDay;
begin
  errorCode := 0;
  result.date := Date;
  result.time := Time;
  result.patientLastName := patient;
  result.cabNum := cabNum;
  result.docKey := docKey;
  DocArr := searchDoc(docList, searchCompDocKey, docKey);
  WeekDay := TWeekDay(DayOfWeek(Date) - 1);
  if length(DocArr) = 0 then
    errorCode := 1
  else if (Time < DocArr[0]^.Doc.Schedule[WeekDay].start) or (Time > DocArr[0]^.Doc.Schedule[WeekDay].finish) then
      errorCode := 2
  else
  begin
    TalonArr := searchTalon(TalonList, searchCompTalonDocKey, docKey);
    result.queuePos := 1;
    for var i := Low(TalonArr) to High(TalonArr) do
    begin
      if TalonArr[i]^.Talon.date = Date then
      begin
        if TalonArr[i]^.Talon.time = Time then
          errorCode := 3;
      end;
    end;
    if errorCode = 0 then
      for var i := Low(TalonArr) to High(TalonArr) do
      begin
        if TalonArr[i]^.Talon.date = Date then
        begin
          if TalonArr[i]^.Talon.time < Time then
            Inc(result.queuePos);
          if TalonArr[i]^.Talon.time > Time then
            Inc(TalonArr[i]^.Talon.queuePos);
        end;
      end;
  end;
end;

procedure addTalon(const Head: TTalonListPt; Talon: TTalon);
var
  temp: TTalonListPt;
begin
  temp := head^.next;
  while temp^.next <> nil do
    temp := temp^.next;
  New(temp^.next);
  temp^.next := nil;
  temp^.Talon := Talon;
end;

procedure addDoc(const Head: TDocListPt; Doc: TDoc);
var
  temp: TDocListPt;
begin
  temp := head^.next;
  while temp^.next <> nil do
    temp := temp^.next;
  New(temp^.next);
  temp^.next := nil;
  temp^.Doc := Doc;
end;

procedure MainMenu;
begin
  writeln('������� ����:');
  writeln('[1] - ������ ������ �� �����.');
  writeln('[2] - �������� ����� ������.');
  writeln('[3] - ���������� ������.');
  writeln('[4] - ����� ������.');
  writeln('[5] - ���������� ������ � ������.');
  writeln('[6] - �������� ������ �� ������.');
  writeln('[7] - �������������� ������.');
  writeln('[8] - ������ � ��������.');
  writeln('[9] - ����� ��� ���������� ���������.');
  writeln('[10] - ����� � ����������� ���������.');
end;

procedure chooseListMenu;
begin
  writeln('�������� ������');
  writeln('[1] - ������ �������.');
  writeln('[2] - ������ ������.');
  writeln('[3] - � ������� ����.');
end;

procedure TalonFields;
begin
  writeln('[1] - ����.');
  writeln('[2] - �����.');
  writeln('[3] - ������ � �������.');
  writeln('[4] - ��� ��������.');
  writeln('[5] - ����� ��������.');
  writeln('[6] - ��� �����.');
end;

procedure DocFields;
begin
  writeln('[1] - ��� �����.');
  writeln('[2] - �������������.');
  writeln('[3] - ��� �����.'); 
end;

procedure LookList(TalonList: TTalonListPt; DocList: TDocListPt);
var
  chose: integer;
begin
  chooseListMenu;
  InputMenu(3, chose);
  case chose of
  1:
    printTalonList(TalonList);
  2:
    printDocList(DocList);  
  end;
end;

procedure searchList(TalonList: TTalonListPt; DocList: TDocListPt);
var
  chose: integer;
  Date: TDate;
  Time: TTime;
  TalonArr: TTalonArr;
  DocArr: TDocArr;
  temp: String;
begin
  chooseListMenu;
  InputMenu(3, chose);
  case chose of
  1:
  begin
    TalonFields;
    InputMenu(6, chose);
    case chose of
    1:
    begin
      InputDate('������� ����(������ DD.MM.YYYY): ', '������������ ����', Date);
      TalonArr := searchTalon(TalonList, searchCompTalonDate, Date);
    end;
    2:
    begin
      InputTime('������� �����(������ HH:MM): ', '������������ �����', Time);
      TalonArr := searchTalon(TalonList, searchCompTalonDate, Time);
    end;
    3:
    begin
      writeln('������� ������� � �������: ');
      InputMenu(999, chose);
      TalonArr := searchTalon(TalonList, searchCompTalonQueue, chose);
    end;
    4:
    begin
      writeln('������� ��� ��������: ');
      readln(temp);
      TalonArr := searchTalon(TalonList, searchCompTalonPatientLastName, temp);
    end;
    5:
    begin
      writeln('������� ����� ��������: ');
      InputMenu(999, chose);
      TalonArr := searchTalon(TalonList, searchCompTalonCabNum, chose);
    end;
    6:
    begin
      writeln('������� ��� �����: ');
      InputMenu(999, chose);
      TalonArr := searchTalon(TalonList, searchCompTalonCabNum, chose);
    end;
    end;
    if length(TalonArr) = 0 then
      writeln('������ �� �������')
    else
    begin
      for var i := Low(TalonArr) to High(TalonArr) do
      begin
        printTalon(TalonArr[i]^.Talon);
        writeln;
      end;
    end;
  end;
  2:
  begin
    DocFields;
    InputMenu(3, chose);
    case chose of
    1:
    begin
      writeln('������� ��� �����: ');
      InputMenu(999, chose);
      DocArr := searchDoc(DocList, searchCompDocKey, chose);
    end;
    2:
    begin
      writeln('������� ������������� �����: ');
      readln(temp);
      DocArr := searchDoc(DocList, searchCompDocSpecialisation, temp);
    end;
    3:
    begin
      writeln('������� ���: ');
      readln(temp);
      DocArr := searchDoc(DocList, searchCompDocName, temp);
    end;
    end;
    
  end;
  end;
  if length(DocArr) = 0 then
    writeln('������ �� �������')
    else
    begin
      for var i := Low(DocArr) to High(DocArr) do
      begin
        printDoc(DocArr[i]^.Doc);
        writeln;
      end;
    end;
end;

procedure AddList(TalonList: TTalonListPt; DocList: TDocListPt);
var
  chose: integer;
  Date: TDate;
  Time: TTime;
  docKey: Integer;
  cabNum: Integer;
  Name: String;
  ErrorCode: Integer;
  Talon: TTalon;
  
begin
  chooseListMenu;
  InputMenu(3, chose);
  case chose of
  1:
  begin  
    InputDate('������� ����(������ DD.MM.YYYY): ', '������������ ����', Date);
    InputTime('������� �����(������ HH:MM): ', '������������ ����', Time);
    write('������� ��� ��������: ');
    readln(Name);
    write('������� ����� ��������: ');
    InputMenu(999, cabNum);
    write('������� ��� �����: ');
    InputMenu(999, docKey);
    Talon := makeTalon(TalonList, DocList, Date, Time, Name, cabNum, docKey, ErrorCode);
    case errorcode of
    1:   
      writeln('������ ����� �=�� ����������');
    2:
      writeln('� ��� ����� ���� �� ��������');
    3:
      writeln('����� � ����� ����� �� ������ ����� ��� �����');
    0:
      AddTalon(TalonList, Talon);
    end;
  end;
  end;
end;

var
  TalonList: TTalonListPt;
  DocList: TDocListPt;
  isOn: boolean;
  temp: integer;

begin
  New(TalonList);
  TalonList^.next := nil;
  New(DocList);          
  DocList^.next := nil;
  isOn := true;
  while isOn do
  begin
    MainMenu;
    InputMenu(10, temp);
    case temp of
    1:
      continue;
    2:
      LookList(TalonList, DocList);
    3:
      continue;
    4:
      SearchList(TalonList, DocList);
    5:
      AddList(TalonList, DocList);
    end;
  end;
  readln;
end.
