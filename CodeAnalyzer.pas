unit CodeAnalyzer;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections;

type
  TViolation = record
    FileName: string;
    ProcedureName: string;
    LineNumber: Integer;
    PrincipleViolated: string;
    Description: string;
    Suggestion: string;
  end;

  TViolationList = TList<TViolation>;

procedure AnalyzeFolder(const FolderPath: string; Violations: TViolationList);

implementation

uses
  System.IOUtils, System.RegularExpressions;

procedure AddViolation(const Violations: TViolationList; const FileName, ProcName: string;
  LineNumber: Integer; const Principle, Description, Suggestion: string);
var
  V: TViolation;
begin
  V.FileName := FileName;
  V.ProcedureName := ProcName;
  V.LineNumber := LineNumber;
  V.PrincipleViolated := Principle;
  V.Description := Description;
  V.Suggestion := Suggestion;
  Violations.Add(V);
end;

procedure AnalyzeFile(const FilePath: string; Violations: TViolationList);
var
  Lines: TStringList;
  I: Integer;
  Line: string;
  CurrentProcName: string;
begin
  Lines := TStringList.Create;
  try
    Lines.LoadFromFile(FilePath);
    CurrentProcName := '';

    for I := 0 to Lines.Count - 1 do
    begin
      Line := Trim(Lines[I]);

      if TRegEx.IsMatch(Line, '^(procedure|function)\s+\w+\.\w+', [roIgnoreCase]) then
        CurrentProcName := TRegEx.Match(Line, '\w+\.\w+').Value
      else if Line = 'end;' then
        CurrentProcName := '';

      // SRP (exemplo simplificado)
      if TRegEx.IsMatch(Line, '^procedure\s') and (Lines.Count > 100) then
        AddViolation(Violations, FilePath, CurrentProcName, I + 1, 'SRP',
          'Classe com muitos métodos.', 'Divida a classe em responsabilidades menores.');

      // OCP
      if TRegEx.IsMatch(Line, '^(if|case)\s', [roIgnoreCase]) then
        AddViolation(Violations, FilePath, CurrentProcName, I + 1, 'OCP',
          'Uso de estruturas condicionais.', 'Use polimorfismo ou padrão Strategy.');

      // DIP – instanciação direta
      if TRegEx.IsMatch(Line, '\bCreate\b') and TRegEx.IsMatch(Line, '\bT[A-Z]\w*\b') then
        AddViolation(Violations, FilePath, CurrentProcName, I + 1, 'DIP',
          'Instanciação direta de classe concreta.', 'Use interfaces e injeção de dependência.');

      // DIP – dependência concreta via uses
      if TRegEx.IsMatch(Line, '^uses\s', [roIgnoreCase]) and Line.Contains('Infra') then
        AddViolation(Violations, FilePath, CurrentProcName, I + 1, 'DIP',
          'Dependência de módulo concreto.', 'Dependa de abstrações sempre que possível.');

      // ISP
      if Line.ToLower.Contains('notimplemented') or Line.ToLower.Contains('notsupported') then
        AddViolation(Violations, FilePath, CurrentProcName, I + 1, 'ISP',
          'Método sinaliza que não foi implementado.', 'Extraia interfaces mais coesas.');

      // LSP
      if TRegEx.IsMatch(Line.ToLower, '\boverride\b') and TRegEx.IsMatch(Line.ToLower, '\braise\b') then
        AddViolation(Violations, FilePath, CurrentProcName, I + 1, 'LSP',
          'Método sobrescrito lança exceção.', 'Evite alterar contratos herdados.');
    end;
  finally
    Lines.Free;
  end;
end;

procedure AnalyzeFolder(const FolderPath: string; Violations: TViolationList);
var
  FileName: string;
begin
  for FileName in TDirectory.GetFiles(FolderPath, '*.pas', TSearchOption.soAllDirectories) do
    AnalyzeFile(FileName, Violations);
end;

end.
