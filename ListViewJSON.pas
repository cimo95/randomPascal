(*
* Judul : Prosedur simpan muat listview dari dan ke JSON
* Catatan : tambahkan System.JSON pada uses
*)

procedure simpanListViewKeJSON(_listview: TListView; _namaFile: string; _pakaiNamaKolom: Boolean = False);
var
  a, b: Integer;
  c: TJSONArray;
  d: TJSONObject;
  e: TStringList;
begin
  try
    c := TJSONArray.Create;
    for a := 0 to _listview.Items.Count - 1 do
    begin
      d := TJSONObject.Create;
      c.AddElement(d);
      if not _pakaiNamaKolom then
      begin
        d.AddPair('0', _listview.Items.Item[a].Caption);
        for b := 1 to _listview.Columns.Count - 1 do
          d.AddPair(b.ToString, _listview.Items.Item[a].SubItems.Strings[b - 1]);
      end
      else
      begin
        d.AddPair(_listview.Columns.Items[0].Caption, _listview.Items.Item[a].Caption);
        for b := 1 to _listview.Columns.Count - 1 do
          d.AddPair(_listview.Columns.Items[b].Caption, _listview.Items.Item[a].SubItems.Strings
            [b - 1]);
      end;
      e := TStringList.Create;
      e.Text := c.Format(4);
      e.SaveToFile(_namaFile);
      e.Free;
    end;
  except
    on e: Exception do
    begin
      raise Exception.Create('Terjadi masalah ketika meng-generate data dari ListView'#13'Kesalahan : '
        + e.Message);
    end;
  end;
end;

procedure muatListViewDariJSON(_listview: TListView; _namaFile: string; _pakaiNamaKolom: Boolean = False);
var
  a, b: Integer;
  c: TJSONArray;
  d: TJSONObject;
  e: TStringList;
  f: TListItem;
begin
  e := TStringList.Create;
  e.LoadFromFile(_namaFile);
  c := TJSONObject.ParseJSONValue(e.Text) as TJSONArray;
  d := c.Items[0] as TJSONObject;
  if d.Count <> _listview.Columns.Count then
    raise Exception.Create('Jumlah kolom ListView dengan data tidak sesuai ! ');
  try
    for a := 0 to c.Count - 1 do
    begin
      f := _listview.Items.Add;
      d := c.Items[a] as TJSONObject;
      if not _pakaiNamaKolom then
      begin
        f.Caption := d.GetValue('0').Value;
        for b := 1 to _listview.Columns.Count - 1 do
          f.SubItems.Add(d.GetValue(b.ToString).Value);
      end
      else
      begin
        f.Caption := d.GetValue(_listview.Columns.Items[0].Caption).Value;
        for b := 1 to _listview.Columns.Count - 1 do
          f.SubItems.Add(d.GetValue(_listview.Columns.Items[b].Caption).Value);
      end;
    end;
  except
    on e: Exception do
    begin
      raise Exception.Create('Terjadi masalah ketika mem-parse data ke ListView'#13'Kesalahan : '
        + e.Message);
    end;
  end;
end;
