# Thin wrapper: the real CLI lives in the template so that every project set up with
# `espec init` carries its own copy at espec\bin\espec.ps1.
& (Join-Path (Split-Path -Parent $PSScriptRoot) 'template\espec\bin\espec.ps1') @args
exit $LASTEXITCODE
