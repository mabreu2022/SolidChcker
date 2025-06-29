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
          'Classe com muitos m�todos.', 'Divida a classe em responsabilidades menores.');

      // OCP
      if TRegEx.IsMatch(Line, '^(if|case)\s', [roIgnoreCase]) then
        AddViolation(Violations, FilePath, CurrentProcName, I + 1, 'OCP',
          'Uso de estruturas condicionais.', 'Use polimorfismo ou padr�o Strategy.');

      // DIP � instancia��o direta
      if TRegEx.IsMatch(Line, '\bCreate\b') and TRegEx.IsMatch(Line, '\bT[A-Z]\w*\b') then
        AddViolation(Violations, FilePath, CurrentProcName, I + 1, 'DIP',
          'Instancia��o direta de classe concreta.', 'Use interfaces e inje��o de depend�ncia.');

      // DIP � depend�ncia concreta via uses
      if TRegEx.IsMatch(Line, '^uses\s', [roIgnoreCase]) and Line.Contains('Infra') then
        AddViolation(Violations, FilePath, CurrentProcName, I + 1, 'DIP',
          'Depend�ncia de m�dulo concreto.', 'Dependa de abstra��es sempre que poss�vel.');

      // ISP
      if Line.ToLower.Contains('notimplemented') or Line.ToLower.Contains('notsupported') then
        AddViolation(Violations, FilePath, CurrentProcName, I + 1, 'ISP',
          'M�todo sinaliza que n�o foi implementado.', 'Extraia interfaces mais coesas.');

      // LSP
      if TRegEx.IsMatch(Line.ToLower, '\boverride\b') and TRegEx.IsMatch(Line.ToLower, '\braise\b') then
        AddViolation(Violations, FilePath, CurrentProcName, I + 1, 'LSP',
          'M�todo sobrescrito lan�a exce��o.', 'Evite alterar contratos herdados.');
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
