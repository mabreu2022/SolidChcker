unit JsonReporter;

interface

uses
  System.SysUtils, System.Classes, CodeAnalyzer;

procedure GenerateJsonReport(const Violations: TViolationList; const OutputPath: string);

implementation

uses
  System.JSON;

procedure GenerateJsonReport(const Violations: TViolationList; const OutputPath: string);
var
  JSONArray: TJSONArray;
  JSONObj: TJSONObject;
  V: TViolation;
  JSONText: TStringList;
begin
  JSONArray := TJSONArray.Create;
  try
    for V in Violations do
    begin
      JSONObj := TJSONObject.Create;
      JSONObj.AddPair('file', V.FileName);
      JSONObj.AddPair('procedure', V.ProcedureName);
      JSONObj.AddPair('line', TJSONNumber.Create(V.LineNumber));
      JSONObj.AddPair('principle', V.PrincipleViolated);
      JSONObj.AddPair('description', V.Description);
      JSONObj.AddPair('suggestion', V.Suggestion);
      JSONArray.AddElement(JSONObj);
    end;

    JSONText := TStringList.Create;
    try
      JSONText.Text := JSONArray.Format(2); // Indentado
      ForceDirectories(ExtractFilePath(OutputPath));
      JSONText.SaveToFile(OutputPath, TEncoding.UTF8);
    finally
      JSONText.Free;
    end;
  finally
    JSONArray.Free;
  end;
end;

end.
