# Contributing to ExchangeNodeMaintenanceMode

Project Site: [https://github.com/jhochwald/PowerShell-collection](https://github.com/jhochwald/PowerShell-collection)

There are some important things to be aware of if you plan on contributing to this project.

## Documentation
All base project documentation changes should be made against the .\build\docs\Additional markdown files. These will populate and overwrite existing document files within the .\docs folder at build time. Additionally, if ReadTheDocs integration is enabled you should update the .\build\docs\ReadTheDocs markdown files. Note that each folder becomes its own section within ReadTheDocs and its own folder within the .\docs directory.

Finally, the Function documentation gets generated automatically based on the comment based help on each public/exported function. The function documentation markdown automatically gets populated within the .\docs\Functions folder as well as with the module release under its own docs folder. Private function CBH is not required but is encouraged.

## Development Environment
While any text editor will work well there are included task and setting json files explicitly for Visual Studio Code included with this project. The following tasks have been defined to make things a bit easier. First access the 'Pallette' (Shift+Ctrl+P or Shift+Cmd+P)  and start typing in any of the following tasks to find and run them:

- Clean -> Cleans out your scratch folder
- Build -> Runs the Build task (also can use Shift+Ctrl+B or Shift+Cmd+B)
- Analyze -> Runs PSScriptAnalyzer against the src/public files.
- CreateProjectHelp - Creates the project level help.
- Test - Runs Pester tests.
- InsertMissingCBH - Analyzes the existing public functions and inserts a template CBH if no CBH already exists and saves it into your scratch folder.
