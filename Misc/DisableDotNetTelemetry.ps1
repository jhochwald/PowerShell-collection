# Disable the .NET Telemetry on production servers and critical workstations
[Environment]::SetEnvironmentVariable('DOTNET_CLI_TELEMETRY_OPTOUT', '1', 'Machine')
[Environment]::SetEnvironmentVariable('MLDOTNET_CLI_TELEMETRY_OPTOUT', '1', 'Machine')

# Tweak the 1st run experience
[Environment]::SetEnvironmentVariable('DOTNET_SKIP_FIRST_TIME_EXPERIENCE', '1', 'Machine')
