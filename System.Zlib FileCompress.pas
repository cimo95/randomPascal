(*
* Judul : Prosedur compress / decompress beberapa file
* Catatan : tambahkan System.ZLib pada uses
*)

procedure buatArsip(_daftarFile: TStrings; const _Hasil: string);
var
  a: TBytes;
  b, c: TFileStream;
  d: TCompressionStream;
  e, f, g, h: Integer;
  i: Byte;
begin
  c := TFileStream.Create(_Hasil, fmCreate or fmShareExclusive);
  try
    d := TCompressionStream.Create(clMax, c);
    try
      e := _daftarFile.Count;
      d.Write(e, SizeOf(Integer));
      for f := 0 to (e - 1) do
      begin
        b := TFileStream.Create(_daftarFile[f], fmOpenRead and fmShareExclusive);
        try
          a := TEncoding.UTF8.GetBytes(ExtractFileName(_daftarFile[f]));
          g := Length(a);
          d.Write(g, SizeOf(Integer));
          d.Write(PByte(a)^, g);
          h := b.Size;
          d.Write(h, SizeOf(Integer));
          d.CopyFrom(b, b.Size);
          i := 0;
          d.Write(i, SizeOf(Byte));
        finally
          b.Free;
        end;
      end;
    finally
      FreeAndNil(d);
    end;
  finally
    FreeAndNil(c);
  end;
end;

procedure bongkarArsip(_namaFile, _folderHasil: string);
var
  a: TBytes;
  b: string;
  c, d: TFileStream;
  e: TDecompressionStream;
  f, g, h, i: Integer;
  j: Byte;
begin
  d := TFileStream.Create(_namaFile, fmOpenRead and fmShareExclusive);
  try
    e := TDecompressionStream.Create(d);
    try
      e.ReadBuffer(f, SizeOf(Integer));
      for g := 0 to (f - 1) do
      begin
        e.ReadBuffer(h, SizeOf(Integer));
        SetLength(a, h);
        e.ReadBuffer(PByte(a)^, h);
        b := TEncoding.UTF8.GetString(a);
        b := ExtractFileName(b);
        c := TFileStream.Create(IncludeTrailingBackslash(_folderHasil) +
          b, fmCreate or fmShareExclusive);
        try
          e.ReadBuffer(i, SizeOf(Integer));
          if i > 0 then
            c.CopyFrom(e, i);
        finally
          c.Free;
        end;
        e.Read(j, SizeOf(Byte));
      end;
    finally
      FreeAndNil(e);
    end;
  finally
    FreeAndNil(d);
  end;
end;
