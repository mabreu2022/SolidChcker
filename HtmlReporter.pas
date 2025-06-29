unit HtmlReporter;

interface

uses
  System.SysUtils, System.Classes, CodeAnalyzer;

procedure GenerateHtmlReport(const Violations: TViolationList; const OutputPath: string);

implementation

procedure GenerateHtmlReport(const Violations: TViolationList; const OutputPath: string);
var
  HTML: TStringList;
  V: TViolation;
begin
  HTML := TStringList.Create;
  try
    HTML.Add('<html><head><meta charset="utf-8"><style>');
    HTML.Add('table { border-collapse: collapse; width: 100%; }');
    HTML.Add('th, td { border: 1px solid #ccc; padding: 8px; font-family: Arial; }');
    HTML.Add('th { background-color: #f4f4f4; }');
    HTML.Add('</style></head><body>');
    HTML.Add('<h2>Relatório de Violações SOLID</h2>');
    HTML.Add('<table>');
    HTML.Add('<tr><th>Arquivo</th><th>Procedimento</th><th>Linha</th><th>Princípio</th><th>Descrição</th><th>Sugestão</th></tr>');

    for V in Violations do
    begin
      HTML.Add(Format('<tr><td>%s</td><td>%s</td><td>%d</td><td>%s</td><td>%s</td><td>%s</td></tr>',
        [V.FileName, V.ProcedureName, V.LineNumber, V.PrincipleViolated, V.Description, V.Suggestion]));
    end;

    HTML.Add('</table>');
    HTML.Add('</body></html>');
    ForceDirectories(ExtractFilePath(OutputPath));
    HTML.SaveToFile(OutputPath, TEncoding.UTF8);
  finally
    HTML.Free;
  end;
end;

end.
