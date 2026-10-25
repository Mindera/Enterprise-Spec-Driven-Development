# Smoke test for the PowerShell CLI: init, new, validate, list, update, and the worked example.
$ErrorActionPreference = 'Stop'
$Root = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$Work = Join-Path ([System.IO.Path]::GetTempPath()) ('espec-smoke-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $Work | Out-Null
try {
  & (Join-Path $Root 'bin/espec.ps1') init $Work | Out-Null
  $cli = Join-Path $Work 'espec/bin/espec.ps1'
  if (-not (Test-Path -LiteralPath $cli)) { throw 'init did not copy espec/bin/espec.ps1' }
  if (-not (Test-Path -LiteralPath (Join-Path $Work '.github/workflows/espec-validate.yml'))) { throw 'init did not copy the validate workflow' }
  $prompts = @(Get-ChildItem -LiteralPath (Join-Path $Work '.github/prompts') -File)
  if ($prompts.Count -ne 7) { throw "expected 7 prompt files, got $($prompts.Count)" }

  Push-Location $Work
  try {
    # A fresh change still holds template placeholders, so validate must fail on it.
    & $cli new proj-1-smoke --ticket PROJ-1 --title Smoke | Out-Null
    $global:LASTEXITCODE = 0
    & $cli validate proj-1-smoke | Out-Null
    if ($LASTEXITCODE -eq 0) { throw 'expected validate to fail on a blank change' }
    Remove-Item -Recurse -Force (Join-Path $Work 'espec/changes/proj-1-smoke')

    # The worked example must pass.
    Copy-Item -Recurse -LiteralPath (Join-Path $Root 'examples/changes/bill-142-invoice-csv-export') -Destination (Join-Path $Work 'espec/changes')
    Get-ChildItem -LiteralPath (Join-Path $Root 'examples/specs') -Directory | ForEach-Object {
      Copy-Item -Recurse -LiteralPath $_.FullName -Destination (Join-Path $Work 'espec/specs')
    }
    $global:LASTEXITCODE = 1
    & $cli validate
    if ($LASTEXITCODE -ne 0) { throw 'worked example failed validation' }
    $list = (& $cli list) -join "`n"
    if ($list -notmatch 'bill-142-invoice-csv-export\s+implemented') { throw "list did not show the example:`n$list" }

    # init and update refuse to run from inside a project.
    $global:LASTEXITCODE = 0
    & $cli update . 2>$null | Out-Null
    if ($LASTEXITCODE -eq 0) { throw 'expected update from inside a project to refuse' }
  } finally { Pop-Location }

  # update from the toolkit is idempotent right after init.
  $global:LASTEXITCODE = 1
  $upd = (& (Join-Path $Root 'bin/espec.ps1') update $Work) -join "`n"
  if ($LASTEXITCODE -ne 0) { throw "update from the toolkit failed:`n$upd" }
  if ($upd -notmatch 'unchanged') { throw "update did not report unchanged files:`n$upd" }

  Write-Output 'PowerShell CLI smoke test passed'
} catch {
  Write-Output "FAILED: $($_.Exception.Message)"
  Write-Output $_.InvocationInfo.PositionMessage
  Write-Output $_.ScriptStackTrace
  throw
} finally {
  Remove-Item -Recurse -Force $Work -ErrorAction SilentlyContinue
}
