# SolidChecker

**SolidChecker** é uma ferramenta de análise estática para projetos Delphi que detecta violações dos princípios SOLID em arquivos `.pas`. Ele gera relatórios em HTML e JSON com detalhes sobre cada violação, incluindo sugestões de correção.

---

## 🚀 Funcionalidades

- Análise recursiva de arquivos `.pas`
- Detecção dos 5 princípios SOLID:
  - SRP (Single Responsibility Principle)
  - OCP (Open/Closed Principle)
  - LSP (Liskov Substitution Principle)
  - ISP (Interface Segregation Principle)
  - DIP (Dependency Inversion Principle)
- Relatório em HTML com tabela detalhada
- Relatório em JSON para integração com outras ferramentas
- Modo CI com código de saída 1 se houver violações
- Sugestões de correção para cada violação detectada

---

## 🧾 Uso

```bash
SolidChecker.exe <caminho> [--output arquivo.html] [--json] [--ci]

 Parâmetros disponíveis
| Parâmetro | Descrição | 
| <caminho> | Caminho da pasta com arquivos .pas a serem analisados | 
| --output <arquivo> | Caminho do arquivo HTML de saída (padrão: report\solid_report.html) | 
| --json | Gera também um relatório em JSON | 
| --ci | Modo silencioso com código de saída 1 se houver violações | 



📄 Estrutura do relatório
HTML
O relatório HTML contém uma tabela com as colunas:
- Arquivo
- Procedimento
- Linha
- Princípio violado
- Descrição
- Sugestão de correção
JSON
O relatório JSON contém os mesmos dados estruturados para uso em pipelines, dashboards ou ferramentas externas.

🤖 Integração com Jenkins
- Adicione o executável ao repositório ou artefato
- Configure um job com o seguinte comando:
SolidChecker.exe "src" --output "report\solid.html" --json --ci


- Use o plugin HTML Publisher para exibir o relatório
- Configure o build para falhar ou ficar instável se o código de saída for diferente de 0
📦 Requisitos- Delphi com suporte a Generics e System.IOUtils
- Windows com permissões de leitura nos arquivos analisados

📃 LicençaUso interno. Consulte o autor para distribuição externa.
---

