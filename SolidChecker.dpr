program SolidChecker;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  System.IOUtils,
  CodeAnalyzer,
  HtmlReporter,
  JsonReporter in 'JsonReporter.pas';

function ParseArgs: TDictionary<string, string>;
var
  I: Integer;
  Key, Value: string;
begin
  Result := TDictionary<string, string>.Create;
  I := 2;
  while I <= ParamCount do
  begin
    if ParamStr(I).StartsWith('--') then
    begin
      Key := ParamStr(I).Substring(2).ToLower;
      if (I + 1 <= ParamCount) and (not ParamStr(I + 1).StartsWith('--')) then
      begin
        Value := ParamStr(I + 1);
        Inc(I);
      end
      else
        Value := 'true';
      Result.AddOrSetValue(Key, Value);
    end;
    Inc(I);
  end;
end;

var
  Violations: TViolationList;
  Params: TDictionary<string, string>;
  FolderPath, OutputFile, JsonFile: string;
begin
  try
    if ParamCount < 1 then
    begin
      Writeln('Uso: SolidChecker.exe <caminho> [--output arquivo.html] [--json] [--ci]');
      Halt(1);
    end;

    FolderPath := ParamStr(1);
    Params := ParseArgs;
    Violations := TViolationList.Create;

    try
      AnalyzeFolder(FolderPath, Violations);

      if not Params.TryGetValue('output', OutputFile) then
        OutputFile := 'report\solid_report.html';

      ForceDirectories(ExtractFilePath(OutputFile));
      GenerateHtmlReport(Violations, OutputFile);
      Writeln('[+] Relatório HTML gerado em: ' + OutputFile);

      if Params.ContainsKey('json') then
      begin
        JsonFile := ChangeFileExt(OutputFile, '.json');
        ForceDirectories(ExtractFilePath(JsonFile));
        GenerateJsonReport(Violations, JsonFile);
        Writeln('[+] Relatório JSON gerado em: ' + JsonFile);
      end;

      if Params.ContainsKey('ci') and (Violations.Count > 0) then
        Halt(1);
    finally
      Violations.Free;
      Params.Free;
    end;
  except
    on E: Exception do
    begin
      Writeln('Erro: ', E.Message);
      Halt(2);
    end;
  end;
end.
