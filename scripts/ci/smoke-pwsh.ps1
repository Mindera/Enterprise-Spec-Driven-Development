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
  Get-Content -Raw -LiteralPath (Join-Path $Work '.diffcompass.json') | ConvertFrom-Json | Out-Null
  $prompts = @(Get-ChildItem -LiteralPath (Join-Path $Work '.github/prompts') -File)
  if ($prompts.Count -ne 9) { throw "expected 9 prompt files, got $($prompts.Count)" }

  Push-Location $Work
  try {
    # A fresh change still holds template placeholders, so validate must fail on it.
    & $cli new proj-1-smoke --ticket PROJ-1 --title Smoke | Out-Null
    $global:LASTEXITCODE = 0
    & $cli validate proj-1-smoke | Out-Null
    if ($LASTEXITCODE -eq 0) { throw 'expected validate to fail on a blank change' }
    Remove-Item -Recurse -Force (Join-Path $Work 'espec/changes/proj-1-smoke')

    # init records the toolkit version and licence in the project.
    $version = ([System.IO.File]::ReadAllText((Join-Path $Root 'VERSION'))).Trim()
    if (([System.IO.File]::ReadAllText((Join-Path $Work 'espec/.toolkit-version'))).Trim() -ne $version) { throw 'init did not record the toolkit version' }
    if (-not (Test-Path -LiteralPath (Join-Path $Work 'espec/LICENSE.md'))) { throw 'init did not copy the licence' }
    if (((& $cli version) -join "`n") -notmatch [regex]::Escape("v$version")) { throw 'version did not print the toolkit version' }

    # A bug change starts from the bug template.
    & $cli new proj-2-bug --kind bug | Out-Null
    if ((Get-Content -Raw -LiteralPath (Join-Path $Work 'espec/changes/proj-2-bug/feature.md')) -notmatch '(?m)^# Bug:') { throw 'new --kind bug did not use the bug template' }
    if ((Get-Content -Raw -LiteralPath (Join-Path $Work 'espec/changes/proj-2-bug/.espec.yaml')) -notmatch '(?m)^kind: bug') { throw 'new --kind bug did not set kind' }
    Remove-Item -Recurse -Force (Join-Path $Work 'espec/changes/proj-2-bug')

    # The worked example must pass against the main specs it was written for (its delta is stamped).
    Copy-Item -Recurse -LiteralPath (Join-Path $Root 'examples/changes/bill-142-invoice-csv-export') -Destination (Join-Path $Work 'espec/changes')
    Get-ChildItem -LiteralPath (Join-Path $Root 'examples/specs-before') -Directory | ForEach-Object {
      Copy-Item -Recurse -LiteralPath $_.FullName -Destination (Join-Path $Work 'espec/specs')
    }
    $global:LASTEXITCODE = 1
    & $cli validate
    if ($LASTEXITCODE -ne 0) { throw 'worked example failed validation' }
    $list = (& $cli list) -join "`n"
    if ($list -notmatch 'bill-142-invoice-csv-export\s+implemented') { throw "list did not show the example:`n$list" }

    # Another change edits the same requirement in the main spec: validate and stamp refuse until --rebase.
    $listSpec = Join-Path $Work 'espec/specs/invoice-list/spec.md'
    $text = [System.IO.File]::ReadAllText($listSpec)
    $text = $text -replace '(- \*\*THEN\*\* the toolbar offers New invoice and Send reminders)(\r?\n)', '$1, in that order$2'
    [System.IO.File]::WriteAllText($listSpec, $text)
    $global:LASTEXITCODE = 0
    & $cli validate | Out-Null
    if ($LASTEXITCODE -eq 0) { throw 'expected validate to catch the changed base' }
    $global:LASTEXITCODE = 0
    & $cli stamp bill-142-invoice-csv-export | Out-Null
    if ($LASTEXITCODE -eq 0) { throw 'expected stamp to refuse without --rebase' }
    $global:LASTEXITCODE = 1
    & $cli stamp bill-142-invoice-csv-export --rebase | Out-Null
    if ($LASTEXITCODE -ne 0) { throw 'stamp --rebase failed' }
    $global:LASTEXITCODE = 1
    & $cli validate | Out-Null
    if ($LASTEXITCODE -ne 0) { throw 'validate failed after stamp --rebase' }

    # The stamps written by this CLI read the same in the bash CLI, so the hash must match it.
    $delta = [System.IO.File]::ReadAllText((Join-Path $Work 'espec/changes/bill-142-invoice-csv-export/specs/invoice-list/spec.md'))
    if ($delta -notmatch '<!-- espec:base 216d0db9ad3d -->') { throw "stamp hash differs from the bash CLI:`n$delta" }

    # Implementation on an unapproved proposal fails.
    $tp = Join-Path $Work 'espec/changes/bill-142-invoice-csv-export/tech-proposal.md'
    $approved = [System.IO.File]::ReadAllText($tp)
    [System.IO.File]::WriteAllText($tp, $approved.Replace('**Status:** Approved', '**Status:** In review'))
    $global:LASTEXITCODE = 0
    & $cli validate | Out-Null
    if ($LASTEXITCODE -eq 0) { throw 'expected validate to fail on an unapproved proposal' }
    [System.IO.File]::WriteAllText($tp, $approved)

    # After the archive the main specs hold the delta's text, which counts as already applied.
    Remove-Item -Recurse -Force (Join-Path $Work 'espec/specs/invoice-list'), (Join-Path $Work 'espec/specs/invoice-export') -ErrorAction SilentlyContinue
    Get-ChildItem -LiteralPath (Join-Path $Root 'examples/specs') -Directory | ForEach-Object {
      Copy-Item -Recurse -LiteralPath $_.FullName -Destination (Join-Path $Work 'espec/specs')
    }
    $global:LASTEXITCODE = 1
    & $cli validate | Out-Null
    if ($LASTEXITCODE -ne 0) { throw 'worked example failed validation against the archived specs' }

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
