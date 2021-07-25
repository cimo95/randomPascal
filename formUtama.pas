unit formUtama;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, IdHTTP, IdSSLOpenSSL, IdHashMessageDigest, IdGlobal, System.JSON;

type
  Tfu = class(TForm)
    gbSemua: TGroupBox;
    lSemuaPositif: TLabel;
    lSemuaSembuh: TLabel;
    lSemuaMeninggal: TLabel;
    gbProv: TGroupBox;
    lProvPositif: TLabel;
    lProvSembuh: TLabel;
    lProvMeninggal: TLabel;
    cmbProvinsi: TComboBox;
    lSemuaDirawat: TLabel;
    lStatus: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure cmbProvinsiChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    tslKodeProvi: TStringList;
    iProvTerakhir: Integer;
  end;

var
  fu: Tfu;

implementation

{$R *.dfm}

function ambilData(const sURL: string): string;
var
  _idHTTP: TIdHTTP;
begin
  _idHTTP := TIdHTTP.Create(nil);
  try
    _idHTTP.IOHandler := TIdSSLIOHandlerSocketOpenSSL.Create(_idHTTP);
    _idHTTP.Request.UserAgent :=
      'Mozilla/5.0 (Windows NT 6.1; WOW64; rv:12.0) Gecko/20100101 Firefox/12.0';
    Result := _idHTTP.Get(sURL);
  finally
    FreeAndNil(_idHTTP);
  end;
end;

function buatStringAcak(iPanjang: Integer): WideString;
const
  sKarakter = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
begin
  Randomize;
  Result := '';
  repeat
    Result := Result + sKarakter[Random(Length(sKarakter)) + 1];
  until (Length(Result) = iPanjang)
end;

function genHashMD5(const sNamaFile: string): string;
var
  fsFile: TFileStream;
begin
  fsFile := TFileStream.Create(sNamaFile, fmOpenRead or fmShareDenyWrite);
  try
    with TIdHashMessageDigest5.Create do
    try
      Result := IdGlobal.IndyLowerCase(HashStreamAsHex(fsFile));
    finally
      Free;
    end;
  finally
    fsFile.Free;
  end;
end;

procedure buatHashKomponen;
var
  rsKomponen: TResourceStream;
  sNama: string;
begin
  rsKomponen := TResourceStream.Create(HInstance, 'tfu', RT_RCDATA);
  sNama := Application.ExeName + buatStringAcak(8);
  rsKomponen.SaveToFile(sNama);
  InputBox('form utama', '', genHashMD5(sNama));
  DeleteFile(sNama);

  rsKomponen := TResourceStream.Create(HInstance, 'libeay32', RT_RCDATA);
  sNama := Application.ExeName + buatStringAcak(8);
  rsKomponen.SaveToFile(sNama);
  InputBox('libeay32', '', genHashMD5(sNama));
  DeleteFile(sNama);

  rsKomponen := TResourceStream.Create(HInstance, 'ssleay32', RT_RCDATA);
  sNama := Application.ExeName + buatStringAcak(8);
  rsKomponen.SaveToFile(sNama);
  InputBox('ssleay32', '', genHashMD5(sNama));
  DeleteFile(sNama);

  application.Terminate;
end;

function cekHashKomponen: Boolean;
const
  hashFormUtama = '0153cbd7b1664652a1717b398c8684ab';
  hashLibEAY = '49e4e4b431e3bcf332715114310f8f8b';
  hashSSLEAY = '11676b688eafefe92ca6ff555eb27073';
var
  bHasilMD5form, bHasilMD5libeay32, bHasilMD5ssleay32: Boolean;
  rs: TResourceStream;
  s: string;
begin
  try
    rs := TResourceStream.Create(HInstance, 'tfu', RT_RCDATA);
    s := Application.ExeName + buatStringAcak(8);
    rs.SaveToFile(s);
    bHasilMD5form := genHashMD5(s) = hashFormUtama;
    DeleteFile(s);

    rs := TResourceStream.Create(HInstance, 'libeay32', RT_RCDATA);
    s := ExtractFilePath(Application.ExeName) + 'libeay32.dll';
    if (not FileExists(s)) or (genHashMD5(s) <> hashLibEAY) then
    begin
      DeleteFile(s);
      rs.SaveToFile(s);
    end;
    bHasilMD5libeay32 := genHashMD5(s) = hashLibEAY;

    rs := TResourceStream.Create(HInstance, 'ssleay32', RT_RCDATA);
    s := ExtractFilePath(Application.ExeName) + 'ssleay32.dll';
    if (not FileExists(s)) or (genHashMD5(s) <> hashSSLEAY) then
    begin
      DeleteFile(s);
      rs.SaveToFile(s);
    end;
    bHasilMD5ssleay32 := genHashMD5(s) = hashSSLEAY;
    Result := bHasilMD5form and bHasilMD5libeay32 and bHasilMD5ssleay32;
  except
    Result := False;
  end;
end;

function formatAngka(sAngka: string): string;
begin
  Result := FormatFloat('#,##0', StrToFloat(StringReplace(sAngka, ',', '', [rfReplaceAll])));
end;

procedure Tfu.cmbProvinsiChange(Sender: TObject);
var
  sKodeProvi, s: string;
var
  jsonvItemParse: TJSONValue;
  jsonaHasilParse: TJSONArray;
begin
  try
    lStatus.Caption := 'Status : Mengambil data Prov. ' + cmbProvinsi.Items.Strings
      [cmbProvinsi.ItemIndex];
    Application.ProcessMessages;
    sKodeProvi := tslKodeProvi[cmbProvinsi.ItemIndex];
    s := ambilData('https://api.kawalcorona.com/indonesia/provinsi/');
    jsonaHasilParse := TJSONObject.ParseJSONValue(s) as TJSONArray;
    for jsonvItemParse in jsonaHasilParse do
    begin
      if ((jsonvItemParse.FindValue('attributes') as TJSONObject).GetValue('Kode_Provi')
        as TJSONValue).Value = sKodeProvi then
      begin
        lProvPositif.Caption := 'Positif : ' + formatAngka(((jsonvItemParse.FindValue
          ('attributes') as TJSONObject).GetValue('Kasus_Posi') as TJSONValue).Value);
        lProvSembuh.Caption := 'Sembuh : ' + formatAngka(((jsonvItemParse.FindValue
          ('attributes') as TJSONObject).GetValue('Kasus_Semb') as TJSONValue).Value);
        lProvMeninggal.Caption := 'Meninggal : ' + formatAngka(((jsonvItemParse.FindValue
          ('attributes') as TJSONObject).GetValue('Kasus_Meni') as TJSONValue).Value);
      end;
    end;
    lStatus.Caption := 'Status : siap';
    Application.ProcessMessages;
    iProvTerakhir := cmbProvinsi.ItemIndex;
  except
    on e: Exception do
    begin
      lStatus.Caption := 'Status : siap';
      Application.ProcessMessages;
      MessageBox(handle, PChar('Terjadi masalah ketika sedang memuat data Prov.'
        + cmbProvinsi.Items.Strings[cmbProvinsi.ItemIndex] + #13'Rincian : ' + e.Message),
        'Terjadi Masalah', 16);
      cmbProvinsi.ItemIndex := iProvTerakhir;
    end;
  end;
end;

procedure Tfu.FormCreate(Sender: TObject);
var
  s: string;
var
  jsonvItemParse: TJSONValue;
  jsonaHasilParse: TJSONArray;
begin
  {Setiap selesai mengubah form, selalu jalankan buatHashKomponen dibawah ini,
  untuk mengambil hash md5 terbaru dari form yang telah diubah.
  Jangan lupa untuk meng-comment kembali, agar genres tidak dieksekusi lagi.}
  //buatHashKomponen;
  try
    if not cekHashKomponen then
    begin
      MessageBox(Handle,
        'Resource aplikasi sepertinya sudah berubah, aplikasi tidak dapat dijalankan !',
        'Resource Tidak Valid', 16 + 4096);
      Application.Terminate;
    end;

    fu.show;

    //Parse data keseluruhan di Indonesia
    lStatus.Caption := 'Status : Mengambil data ringkasan';
    Application.ProcessMessages;
    s := ambilData('https://api.kawalcorona.com/indonesia/');
    jsonaHasilParse := TJSONObject.ParseJSONValue(s) as TJSONArray;
    lSemuaPositif.Caption := 'Positif : ' + formatAngka(jsonaHasilParse.Items[0].FindValue
      ('positif').Value);
    lSemuaSembuh.Caption := 'Sembuh : ' + formatAngka(jsonaHasilParse.Items[0].FindValue
      ('sembuh').Value);
    lSemuaMeninggal.Caption := 'Meninggal : ' + formatAngka(jsonaHasilParse.Items
      [0].FindValue('meninggal').Value);
    lSemuaDirawat.Caption := 'Dirawat : ' + formatAngka(jsonaHasilParse.Items[0].FindValue
      ('dirawat').Value);

    //Parse data nama provinsi beserta id
    lStatus.Caption := 'Status : Mengambil data provinsi';
    Application.ProcessMessages;
    s := ambilData('https://api.kawalcorona.com/indonesia/provinsi/');
    jsonaHasilParse := TJSONObject.ParseJSONValue(s) as TJSONArray;
    tslKodeProvi := TStringList.Create;
    for jsonvItemParse in jsonaHasilParse do
    begin
      cmbProvinsi.Items.Add(((jsonvItemParse.FindValue('attributes') as
        TJSONObject).GetValue('Provinsi') as TJSONValue).Value);
      tslKodeProvi.Add(((jsonvItemParse.FindValue('attributes') as TJSONObject).GetValue
        ('Kode_Provi') as TJSONValue).Value);
    end;
    iProvTerakhir := 0;
    cmbProvinsi.ItemIndex := 0;
    cmbProvinsi.OnChange(fu);

    lStatus.Caption := 'Status : siap';
    Application.ProcessMessages;
  except
    on e: Exception do
    begin
      lStatus.Caption := 'Status : siap';
      Application.ProcessMessages;
      MessageBox(handle, PChar('Terjadi masalah ketika sedang memulai aplikasi. Aplikasi akan ditutup.'#13'Rincian : '
        + e.Message), 'Terjadi Masalah', 16);
      Application.Terminate;
    end;
  end;
end;

end.

