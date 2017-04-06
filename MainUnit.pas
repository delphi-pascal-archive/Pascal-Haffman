{$A+,B-,C+,D+,E-,F-,G+,H+,I+,J-,K-,L+,M-,N+,O+,P+,Q-,R-,S-,T-,U-,V+,W-,X+,Y+,Z1}
{$MINSTACKSIZE $00004000}
{$MAXSTACKSIZE $10000000}
{$IMAGEBASE $00400000}
{$APPTYPE GUI}
unit MainUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, Grids, ComCtrls, ValEdit;

type
  TEl = Record
    Count  : DWord;
    E      : DWord;
    Length : Integer;
    Link   : Integer;
    Code   : Word;
  end;
  TForm1 = class(TForm)
    OD: TOpenDialog;
    StringGrid1: TStringGrid;
    ProgressBar1: TProgressBar;
    StatusBar1: TStatusBar;
    BitBtn1: TBitBtn;
    Button1: TButton;
    SD: TSaveDialog;
    Button2: TButton;
    procedure BitBtn1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
  El :array[0..255] of TEl;
  procedure ClearTree;
  procedure ShowHint(Sender :TObject);
  function BitsToStr(b: Word;Length: byte):string;
  function BitToByte(var Code:string):Byte;
  function ByteToStr(c:byte):string;
  procedure CreateTree(FS:DWord);
  function Check(str1,str2:string):boolean;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  const BufSize=2048;
implementation

{$R *.dfm}

function TForm1.BitToByte(var Code:string):Byte;
var
j:integer;
begin
if length(code)<8 then
  code:=concat('00000000',code);
result:=0;
for j:=0 to 7 do
  begin
  result:=result+(StrToInt(code[Length(code)])mod 2);
  if j<7 then result:=result shl 1;
  delete(code,Length(code),1);
  end;
end;

function TForm1.Check(str1,str2:string):boolean;
begin
if str1=copy(str2,Length(str2)-Length(str1)+1,Length(str1)) then result:=true
else result:=false;
end;

function TForm1.ByteToStr(c:byte):string;
var
i:integer;
tmp:string;
begin
result:='';
for i:=0 to 7 do
  begin
  tmp:=tmp+inttostr(c mod 2);
  c:=c shr 1;
  end;
for i:=0 to 7 do
  result:=concat(result,tmp[Length(tmp)-i]);
//result:=tmp;
end;

function TForm1.BitsToStr(b: Word;Length: byte):string;
var
  i:byte;
begin
  result:='';
  i:=0;
  while i<Length do
    begin
    result:=concat(result,IntToStr(b mod 2));
    b:=b shr 1;
    inc(i);
    end;
end;

procedure TForm1.ShowHint(Sender :TObject);
begin
//StatusBar1.Panels[0].Text:=Application.Hint;
end;

procedure TForm1.ClearTree;
var
  i:byte;
begin
  for i:=0 to 255 do
    begin
      El[i].Count:=0;
      El[i].Length:=0;
      El[i].Link:=-1;
      El[i].E:=0;
      El[i].Code:=0;
    end;
end;

procedure TForm1.CreateTree(FS:DWord);
var
  n:DWord;
  m1, m2: Byte;
  n1:Cardinal;
  i:Integer;
begin
  n:=0;
  while n<FS do
    begin
      m1:=48;
      n1:=high(Cardinal);
      for i:=0 to 255 do
        if (El[i].Count<>0) and (El[i].Count < n1) then
           begin
             n1 := El[i].Count;
             m1:=i;
           end;
      n1:=high(Cardinal);
      m2:=m1;
      for i:=0 to 256 do
        begin
        if (m2=m1)and(i=256) then
          begin
          if m1>0 then
            m2:=m1-1
          else
            m2:=m1+1;
          break;
          end;
        if (i<256)and(El[i].Count <> 0) and (El[i].Count <= n1) and (i<>m1) then
          begin
            n1 := El[i].Count;
            m2:=i;
          end;
        end;
      El[m1].Count:=El[m1].Count + El[m2].Count;
      n:=El[m1].Count;
      El[m1].Code:=El[m1].Code shl 1;
      El[m2].Count:=0;
      El[m1].Length:=El[m1].Length+1;
      while El[m1].Link>=0 do
        begin
        El[El[m1].Link].Length:=El[El[m1].Link].Length+1;
        El[El[m1].Link].Code:=El[El[m1].Link].Code shl 1;
        m1:=El[m1].Link;
        end;
      El[m1].Link:=m2;
      El[m2].Code:=(El[m2].Code shl 1)+1;
      while El[m1].Link>=0 do
        begin
        El[El[m1].Link].Length:=El[El[m1].Link].Length+1;
        m1:=El[m1].Link;
        El[El[m1].Link].Code:=(El[El[m1].Link].Code shl 1)+1;
        end;
    end;
end;

procedure TForm1.BitBtn1Click(Sender: TObject);
var
  i, k, FS : DWord;
  FInput: file;
  Buf: array[0..BufSize-1] of Char;
  NumRead:Integer;
begin        
//OD.Filter:='';
if not OD.Execute then exit;
  StatusBar1.Panels[1].Text:=OD.FileName;
  for i:=0 to StringGrid1.ColCount-1 do
    StringGrid1.Cells[i,1]:='';
  StringGrid1.RowCount:=2;
  AssignFile(FInput,OD.FileName);
  Reset(FInput,1);
  if FileSize(FInput)=0 then
    begin
    ShowMessage('Файл пуст...');
    exit;
    end;
  ProgressBar1.Position:=0;
  ProgressBar1.Max:=(FileSize(FInput) div BufSize);
  ProgressBar1.Visible:=true;
  ClearTree;
  repeat
  BlockRead(FInput,Buf,SizeOf(Buf),NumRead);
  Application.ProcessMessages;
  if NumRead>0 then
    for i:=0 to NumRead-1 do
      begin
      inc(El[ord(Buf[i])].Count);
      inc(El[ord(Buf[i])].E);
      end;
  ProgressBar1.Position:=ProgressBar1.Position+1;
  until (NumRead<SizeOf(Buf));
  FS:=FileSize(FInput);
  CreateTree(FS);
  k:=0;
  for i:=0 to 255 do
    if El[i].Length<>0 then
      begin
      StringGrid1.RowCount:=StringGrid1.RowCount+1;
      StringGrid1.Cells[0,i+1-k]:=IntToStr(i);
      StringGrid1.Cells[1,i+1-k]:=Chr(i);
      StringGrid1.Cells[2,i+1-k]:=IntToStr(El[i].E);
      StringGrid1.Cells[3,i+1-k]:=IntToStr(El[i].Length);
      StringGrid1.Cells[4,i+1-k]:=BitsToStr(El[i].Code,El[i].Length);
      end
    else k:=k+1;
  StringGrid1.RowCount:=StringGrid1.RowCount-1;
  CloseFile(FInput);
  ProgressBar1.Visible:=false;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
Application.OnHint:=ShowHint;
StringGrid1.Cells[0,0]:='Код';
StringGrid1.Cells[1,0]:='Символ';
StringGrid1.Cells[2,0]:='Частота';
StringGrid1.Cells[3,0]:='Длинна';
StringGrid1.Cells[4,0]:='Код Хаффмана';
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  Code,tmp:String;
  FInput, FOutput: file;
  Ost: Word;
  Buf: array[0..BufSize-1] of Char;
  NumRead:Integer;
  i,j,k:integer;
  FS:DWord;
begin
  AssignFile(FInput,OD.FileName);
  AssignFile(FOutput,OD.FileName+'.asd');
  Rewrite(FOutput,1);
  Reset(FInput,1);
  Seek(FInput,0);
  repeat
  BlockRead(FInput,Buf,BufSize,Numread);
  if NumRead>0 then
    for i:=0 to Numread-1 do
    begin
    tmp:='';
    Ost:=El[ord(Buf[i])].Code;
    for j:=0 to El[ord(Buf[i])].Length-1 do
      begin
      Code:=Concat(Code,IntToStr(Ost mod 2));
      Ost:=Ost shr 1;
      end;
    end;
  until (NumRead<SizeOf(Buf));

  j:=0;
  for i:=0 to 255 do
    if El[i].E>0 then
      inc(j);
  if j=256 then j:=0;
  Buf[0]:=chr(j);
  k:=1;
  for i:=0 to 255 do
    if El[i].E>0 then
      begin
      Buf[k]:=chr(i);
      inc(k);
      FS:=El[i].E;
      for j:=1 downto 0 do
        begin
        Buf[k+j]:=chr(FS mod 256);
        FS:=FS shr 8;
        end;
      inc(k,2);
      end;

  BlockWrite(FOutput,Buf,k);
  tmp:=code;
  code:='';
  for i:=0 to length(tmp)-1 do
    begin
    code:=concat(code,tmp[Length(tmp)]);
    delete(tmp,Length(tmp),1);
    end;
  if Length(Code)mod 8>0 then
    j:=Length(Code)div 8 +1
  else j:=Length(Code)div 8;
  i:=0;
  while i<j do
    begin
    while (i<SizeOf(Buf))and(i<j) do
      begin
      buf[i]:=Chr(BitToByte(Code));
      inc(i);
      end;
    BlockWrite(FOutput,Buf,i);
    if i<j then
      begin
      dec(j,i);
      i:=0;
      end;
    end;

  ProgressBar1.Visible:=false;
  CloseFile(FOutput);
  CloseFile(FInput);
  ShowMessage('Архивация завершена.');
end;

procedure TForm1.Button2Click(Sender: TObject);
type
  TE=record
    Code:string;
    byte:byte;
  end;
var
archiv,normal:File;
FS:DWord;
Buf: array[0..BufSize-1] of Char;
i,j:integer;
NumRead:integer;
Code:string;
E:array of TE;
tmp:string;
T:Word;
k:integer;
CountBits:DWord;
begin
//OD.Filter:='Archive file|*.asd';
if not OD.Execute then exit;
if not SD.Execute then exit;
ClearTree;
AssignFile(archiv,OD.FileName);
AssignFile(normal,SD.FileName);
Reset(archiv,1);
ReWrite(normal,1);
FS:=filesize(archiv);
if FS>SizeOf(Buf) then
  FS:=SizeOf(Buf);
BlockRead(archiv,buf,FS);
j:=1;
FS:=0;
k:=ord(Buf[0]);
if k=0 then k:=256;
SetLength(E,k);
for i:=0 to k-1 do
  begin
  E[i].byte:=ord(Buf[j]);
  El[ord(Buf[j])].Count:=ord(buf[j+1])*256 + ord(buf[j+2]);
  El[ord(Buf[j])].E:=El[ord(Buf[j])].Count;
  inc(FS,El[ord(Buf[j])].Count);
  inc(j,3);
  end;
CreateTree(FS);

for i:=0 to Length(E)-1 do
  begin
  T:=El[E[i].byte].Code;
  tmp:='';
  for j:=0 to El[E[i].byte].Length-1 do
    begin
    tmp:=tmp+IntToStr(T mod 2);
    T:=T shr 1;
    end;
//  for j:=0 to Length(tmp)-1 do
    begin
    E[i].Code:=tmp;//concat(E[i].Code,tmp[Length(tmp)-j]);
    end;
  end;
Seek(archiv,k*3+1);
repeat
BlockRead(archiv,Buf,SizeOf(Buf),NumRead);
if NumRead>0 then
  begin
  i:=0;
  while i<NumRead do
    begin
    Code:=concat(Code,ByteToStr(ord(Buf[i])));
    inc(i);
    end;
  end;
until NumRead<SizeOf(Buf);
CloseFile(archiv);
tmp:=code;
code:='';
for i:=1 to Length(tmp) do
  Code:=concat(code,tmp[Length(tmp)-i+1]);
for j:=0 to Length(E)-1 do
  begin
  tmp:=E[j].Code;
  E[j].Code:='';
  for i:=1 to length(tmp) do
    E[j].Code:=E[j].Code+tmp[Length(tmp)-i+1];
  end;

i:=0;
k:=0;
while i<FS do
  begin
  for j:=0 to Length(E)-1 do
    if Check(E[j].Code,Code) then
      begin
      buf[k]:=chr(E[j].byte);
      Delete(Code,Length(Code)-Length(E[j].Code)+1,Length(E[j].Code));
      if j mod 100 =0 then
        begin
        StatusBar1.Panels[1].Text:=IntToStr(Length(Code));
        Application.ProcessMessages;
        end;
      inc(k);
      break;
      end;
  if k=SizeOf(Buf) then
    begin
    BlockWrite(normal,buf,sizeof(buf));
    k:=0;
    end;
  inc(i);
  end;
BlockWrite(normal,buf,k);
CloseFile(Normal);
ShowMessage('Файл создан...');
end;

end.