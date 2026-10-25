<#
.SYNOPSIS
  espec: helper CLI for Enterprise Spec Driven Development (spec-driven development) projects.
.DESCRIPTION
  Same behaviour as bin/espec. Works on Windows PowerShell 5.1 and PowerShell 7. No dependencies.
.EXAMPLE
  .\espec.ps1 init
  .\espec.ps1 new add-invoice-csv-export --ticket PROJ-123 --title "Export invoices as CSV"
  .\espec.ps1 validate
#>
[CmdletBinding()]
param(
  [Parameter(Position = 0)] [string] $Command = 'help',
  [Parameter(Position = 1, ValueFromRemainingArguments = $true)] [string[]] $Rest = @(),
  [string] $Ticket = '',
  [string] $Title = '',
  [Alias('h')] [switch] $Help
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# This script lives at <root>/espec/bin/espec.ps1. In the toolkit checkout <root> is template/,
# which init and update copy from. In a project it is the project itself.
$TemplateDir = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$ToolkitRoot = Split-Path -Parent $TemplateDir
$Marker = '<!-- espec:feature-definition v1 -->'
$Tick = [string][char]0x2714
$Cross = [string][char]0x2716
$WarnSign = [string][char]0x26A0
$script:Checks = 0
$script:Fails = 0

function Show-Usage {
  Write-Output @'
espec: spec-driven development helper (Enterprise Spec Driven Development)

Usage: espec.ps1 <command> [arguments]

  init [dir]                 Copy the espec template into a repository (never overwrites existing files)
  update [dir]               Refresh the managed files: prompts, instructions, workflow, AGENTS.md, templates, espec/bin
                             (init and update run from the toolkit checkout; the other commands work from espec/bin in a project)
  new <name> [options] [dir] Start a change under espec/changes/<name> (options: --ticket KEY, --title "Title")
  list [dir]                 Show active changes with status, ticket and task progress
  validate [name] [dir]      Check one change, or every active change, plus the main specs
  help                       Show this help

[dir] defaults to the current directory. An espec/ folder marks an initialised project.
'@
}

function Fail([string]$Message) { [Console]::Error.WriteLine("error: $Message"); exit 1 }
function Require-Template([string]$Command) {
  $isToolkit = ((Split-Path -Leaf $TemplateDir) -eq 'template') -and (Test-Path -LiteralPath (Join-Path $TemplateDir 'espec/AGENTS.md') -PathType Leaf)
  if (-not $isToolkit) { Fail "init and update run from the toolkit checkout: <toolkit>\bin\espec.ps1 $Command <dir>" }
}
function Require-Project([string]$Dir) {
  if (-not (Test-Path -LiteralPath (Join-Path $Dir 'espec') -PathType Container)) {
    Fail "$Dir is not a espec project (no espec/ folder). Run: espec.ps1 init $Dir"
  }
}
function Get-Lines([string]$File) {
  $raw = [System.IO.File]::ReadAllText((Resolve-Path -LiteralPath $File).Path)
  return @(($raw -replace "`r", '') -split "`n")
}
function Get-RelativePath([string]$Base, [string]$Path) {
  $b = $Base.TrimEnd('\', '/')
  if ($Path.Length -gt $b.Length -and $Path.StartsWith($b, [System.StringComparison]::OrdinalIgnoreCase)) {
    return $Path.Substring($b.Length).TrimStart('\', '/').Replace('\', '/')
  }
  return $Path.Replace('\', '/')
}
function Get-FirstOrDot([string[]]$Arguments) { if ($Arguments.Count -gt 0) { $Arguments[0] } else { '.' } }
function Get-ChangeDirs([string]$Dir) {
  $root = Join-Path $Dir 'espec/changes'
  if (-not (Test-Path -LiteralPath $root)) { return @() }
  return @(Get-ChildItem -LiteralPath $root -Directory | Where-Object { $_.Name -ne 'archive' } | Sort-Object Name)
}
function Get-YamlValue([string]$File, [string]$Key) {
  if (-not (Test-Path -LiteralPath $File)) { return '' }
  foreach ($line in @(Get-Lines $File)) {
    if ($line.StartsWith($Key + ':', [System.StringComparison]::Ordinal)) {
      return (($line -replace ('^' + [regex]::Escape($Key) + ':'), '') -replace '\s+#.*$', '').Trim()
    }
  }
  return ''
}

# ---------------------------------------------------------------- init / update

function Invoke-Init([string]$Dir) {
  Require-Template 'init'
  New-Item -ItemType Directory -Force -Path $Dir | Out-Null
  $base = (Resolve-Path -LiteralPath $TemplateDir).Path
  Write-Output "Initialising espec in $Dir"
  foreach ($file in @(Get-ChildItem -LiteralPath $base -Recurse -File -Force | Sort-Object FullName)) {
    $rel = Get-RelativePath $base $file.FullName
    $dest = Join-Path $Dir $rel
    if (Test-Path -LiteralPath $dest) {
      Write-Output "  skipped (exists)  $rel"
    } else {
      New-Item -ItemType Directory -Force -Path (Split-Path -Parent $dest) | Out-Null
      Copy-Item -LiteralPath $file.FullName -Destination $dest
      Write-Output "  created           $rel"
    }
  }
  Write-Output @"

Next steps:
  1. Edit espec/project.md and espec/config.yaml: product, stack, conventions, ticket system.
  2. Commit the new files. The workflow in .github/workflows/espec-validate.yml runs
     espec/bin/espec validate on pull requests that touch espec/.
  3. Restart your IDE so GitHub Copilot picks up the prompt files in .github/prompts.
  4. Point product managers to the product-ai pack (Rovo and M365 Copilot) in $(Join-Path $ToolkitRoot 'product-ai')
"@
}

# Files that update may overwrite, relative to the project root.
function Get-ManagedFiles {
  $base = (Resolve-Path -LiteralPath $TemplateDir).Path
  $files = @()
  $files += @(Get-ChildItem -LiteralPath (Join-Path $base '.github/prompts') -File -Filter 'espec-*.prompt.md')
  $files += @(Get-ChildItem -LiteralPath (Join-Path $base '.github/instructions') -File -Filter 'espec.instructions.md')
  $files += @(Get-ChildItem -LiteralPath (Join-Path $base '.github/workflows') -File -Filter 'espec-*.yml')
  $files += @(Get-Item -LiteralPath (Join-Path $base 'espec/AGENTS.md'))
  $files += @(Get-ChildItem -LiteralPath (Join-Path $base 'espec/templates') -File)
  $files += @(Get-ChildItem -LiteralPath (Join-Path $base 'espec/bin') -File)
  return @($files | ForEach-Object { Get-RelativePath $base $_.FullName } | Sort-Object)
}

function Invoke-Update([string]$Dir) {
  Require-Template 'update'
  Require-Project $Dir
  Write-Output "Updating managed espec files in $Dir"
  foreach ($rel in @(Get-ManagedFiles)) {
    $src = Join-Path $TemplateDir $rel
    $dest = Join-Path $Dir $rel
    if (-not (Test-Path -LiteralPath $dest)) {
      New-Item -ItemType Directory -Force -Path (Split-Path -Parent $dest) | Out-Null
      Copy-Item -LiteralPath $src -Destination $dest
      Write-Output "  created    $rel"
    } elseif ((Get-FileHash -LiteralPath $src).Hash -eq (Get-FileHash -LiteralPath $dest).Hash) {
      Write-Output "  unchanged  $rel"
    } else {
      Copy-Item -LiteralPath $src -Destination $dest -Force
      Write-Output "  updated    $rel"
    }
  }
  Write-Output 'Done. copilot-instructions.md, project.md, config.yaml, specs/ and changes/ were not touched.'
}

# ---------------------------------------------------------------- new / list

function Invoke-New([string[]]$Arguments) {
  $name = ''; $dir = '.'; $ticket = $Ticket; $title = $Title; $i = 0
  while ($i -lt $Arguments.Count) {
    $a = $Arguments[$i]
    if ($a -eq '--ticket' -and ($i + 1) -lt $Arguments.Count) { $ticket = $Arguments[$i + 1]; $i += 2 }
    elseif ($a -eq '--title' -and ($i + 1) -lt $Arguments.Count) { $title = $Arguments[$i + 1]; $i += 2 }
    elseif ($a -like '--ticket=*') { $ticket = $a -replace '^--ticket=', ''; $i++ }
    elseif ($a -like '--title=*') { $title = $a -replace '^--title=', ''; $i++ }
    elseif ($a -like '-*') { Fail "unknown option: $a" }
    elseif (-not $name) { $name = $a; $i++ }
    else { $dir = $a; $i++ }
  }
  if (-not $name) { Fail 'usage: espec.ps1 new <change-name> [--ticket KEY] [--title "Title"] [dir]' }
  if ($name -cnotmatch '^[a-z0-9]+(-[a-z0-9]+)*$') { Fail "change name must be kebab-case (lowercase letters, digits, dashes): $name" }
  Require-Project $dir
  $tpl = Join-Path $dir 'espec/templates'
  foreach ($f in 'feature.md', 'tech-proposal.md', 'tasks.md', 'espec.yaml') {
    if (-not (Test-Path -LiteralPath (Join-Path $tpl $f))) { Fail "$tpl/$f is missing. Run: espec.ps1 update $dir" }
  }
  $change = Join-Path $dir "espec/changes/$name"
  if (Test-Path -LiteralPath $change) { Fail "$change already exists" }

  $today = Get-Date -Format 'yyyy-MM-dd'
  New-Item -ItemType Directory -Force -Path (Join-Path $change 'specs') | Out-Null
  foreach ($f in 'feature.md', 'tech-proposal.md', 'tasks.md') {
    Copy-Item -LiteralPath (Join-Path $tpl $f) -Destination (Join-Path $change $f)
  }
  $yaml = foreach ($line in @(Get-Lines (Join-Path $tpl 'espec.yaml'))) {
    if ($ticket -and $line -cmatch '^ticket:') { "ticket: $ticket" }
    elseif ($title -and $line -cmatch '^title:') { "title: $title" }
    elseif ($line -cmatch '^created:') { "created: $today" }
    else { $line }
  }
  $target = Join-Path (Resolve-Path -LiteralPath $change).Path '.espec.yaml'
  [System.IO.File]::WriteAllText($target, (@($yaml) -join "`n").TrimEnd("`n") + "`n")

  Write-Output "Created $change"
  Write-Output '  feature.md  tech-proposal.md  tasks.md  specs/  .espec.yaml'
  Write-Output ''
  Write-Output "Next: in Copilot Chat run  /espec-feature-definition $name"
  Write-Output '      or paste the feature definition from the ticket into feature.md and set status: defined'
}

function Get-TaskCounts([string]$File) {
  $lines = @(Get-Lines $File)
  $total = @($lines | Where-Object { $_ -cmatch '^\s*- \[.\]' }).Count
  $done = @($lines | Where-Object { $_ -cmatch '^\s*- \[[xX]\]' }).Count
  return "$done/$total"
}

function Invoke-List([string]$Dir) {
  Require-Project $Dir
  $fmt = '{0,-36} {1,-13} {2,-18} {3}'
  Write-Output ($fmt -f 'NAME', 'STATUS', 'TICKET', 'TASKS')
  $changes = @(Get-ChangeDirs $Dir)
  foreach ($c in $changes) {
    $meta = Join-Path $c.FullName '.espec.yaml'
    $status = Get-YamlValue $meta 'status'; if (-not $status) { $status = '?' }
    $ticket = Get-YamlValue $meta 'ticket'; if (-not $ticket) { $ticket = '-' }
    $tasksFile = Join-Path $c.FullName 'tasks.md'
    $tasks = if (Test-Path -LiteralPath $tasksFile) { Get-TaskCounts $tasksFile } else { 'no tasks' }
    Write-Output ($fmt -f $c.Name, $status, $ticket, $tasks)
  }
  if ($changes.Count -eq 0) { Write-Output '(no active changes)' }
  $archiveDir = Join-Path $Dir 'espec/changes/archive'
  $archived = 0
  if (Test-Path -LiteralPath $archiveDir) { $archived = @(Get-ChildItem -LiteralPath $archiveDir -Directory).Count }
  Write-Output ''
  Write-Output "$($changes.Count) active change(s), $archived archived."
}

# ---------------------------------------------------------------- validate

function Add-Pass([string]$Message) { $script:Checks++; Write-Output "  $Tick $Message" }
function Add-Fail([string]$Message) { $script:Checks++; $script:Fails++; Write-Output "  $Cross $Message" }
function Add-Warning([string]$Message) { Write-Output "  $WarnSign warning: $Message" }
function Assert-Check([bool]$Condition, [string]$Message) { if ($Condition) { Add-Pass $Message } else { Add-Fail $Message } }

# Lines of one "## Heading" section, up to the next ## heading.
function Get-Section([string[]]$Lines, [string]$Heading) {
  $on = $false; $out = @()
  foreach ($l in $Lines) {
    if ($l -cmatch '^## ') { $on = ($l.TrimEnd() -ceq $Heading) }
    if ($on) { $out += $l }
  }
  return $out
}
# True when a section has a line that is neither blank nor an HTML comment.
function Test-SectionContent([string[]]$Section) {
  $inComment = $false
  foreach ($l in @($Section | Select-Object -Skip 1)) {
    if ($inComment) { if ($l.Contains('-->')) { $inComment = $false }; continue }
    if ($l -cmatch '^\s*<!--') { if (-not $l.Contains('-->')) { $inComment = $true }; continue }
    if ($l.Trim() -ne '') { return $true }
  }
  return $false
}
function Get-Placeholders([string[]]$Lines) {
  $out = @()
  for ($i = 0; $i -lt $Lines.Count; $i++) {
    if ($Lines[$i] -cmatch '<[A-Za-z][A-Za-z0-9 -]*>' -and $Lines[$i] -cnotmatch '^\s*<!--') { $out += "line $($i + 1): $($Lines[$i])" }
  }
  return $out
}

function Test-Feature([string]$Change) {
  $f = Join-Path $Change 'feature.md'
  if (-not (Test-Path -LiteralPath $f)) { Add-Fail 'feature.md missing'; return }
  $lines = @(Get-Lines $f)
  Assert-Check ($lines[0].TrimEnd() -ceq $Marker) "feature.md: starts with the marker $Marker"
  foreach ($h in '## Why', '## What', '## Use cases', '## Edge cases', '## Out of scope', '## Acceptance criteria') {
    if (@($lines | Where-Object { $_.TrimEnd() -ceq $h }).Count -gt 0) {
      Assert-Check (Test-SectionContent @(Get-Section $lines $h)) "feature.md: '$h' present and not empty"
    } else {
      Add-Fail "feature.md: '$h' missing"
    }
  }
  foreach ($p in 'UC', 'EC', 'AC') {
    Assert-Check (@($lines | Where-Object { $_ -cmatch ('^### ' + $p + '-[0-9]') }).Count -gt 0) "feature.md: at least one ### $p-n"
  }
  $ac = @(Get-Section $lines '## Acceptance criteria') -join "`n"
  $ids = @($lines | ForEach-Object { if ($_ -cmatch '^### ([UE]C-[0-9]+)') { $Matches[1] } } | Sort-Object -Unique)
  foreach ($id in $ids) {
    if ($ac -cnotmatch ('(^|[^A-Za-z0-9])' + $id + '([^0-9]|$)')) { Add-Warning "feature.md: $id is not referenced in the Acceptance criteria section" }
  }
  if (@($lines | Where-Object { $_ -cmatch '^## Forced technical notes' }).Count -gt 0) {
    $forced = @(Get-Section $lines '## Forced technical notes') -join "`n"
    Assert-Check ($forced.Contains($WarnSign)) 'feature.md: Forced technical notes carry the warning marker'
  }
  $left = @(Get-Placeholders $lines)
  if ($left.Count -eq 0) { Add-Pass 'feature.md: no template placeholders left' }
  else { foreach ($p in $left) { Add-Fail "feature.md: placeholder: $p" } }
}

# Structural checks shared by delta specs (Mode delta) and main specs (Mode main).
function Test-Spec([string]$File, [string]$Mode, [string]$Label) {
  $lines = @(Get-Lines $File)
  $allowed = @('## Purpose', '## ADDED Requirements', '## MODIFIED Requirements', '## REMOVED Requirements', '## RENAMED Requirements')
  $problems = @(); $blocks = @(); $seen = @{}; $sec = ''; $cur = $null; $purpose = $false; $reqs = $false
  for ($i = 0; $i -lt $lines.Count; $i++) {
    $l = $lines[$i]
    if ($l -cmatch '<[A-Za-z][A-Za-z0-9 -]*>' -and $l -cnotmatch '^\s*<!--') { $problems += "template placeholder left on line $($i + 1): $l" }
    if ($l -cmatch '^## ') {
      $sec = $l.TrimEnd(); $cur = $null
      if ($Mode -eq 'delta') { if ($allowed -cnotcontains $sec) { $problems += "heading not allowed in a delta spec: $sec" } }
      elseif ($sec -ceq '## Purpose') { $purpose = $true }
      elseif ($sec -ceq '## Requirements') { $reqs = $true }
      else { $problems += "heading not allowed in a main spec: $sec" }
    } elseif ($l -cmatch '^### Requirement:(.*)$') {
      $name = $Matches[1].Trim()
      if ($seen.ContainsKey($name)) { $problems += "duplicate requirement name: $name" }
      $seen[$name] = $true
      $cur = [pscustomobject]@{ Name = $name; Section = $sec; Scenarios = 0; Reason = $false }
      $blocks += $cur
    } elseif ($l -cmatch '^### Scenario:' -or $l -cmatch '^##### Scenario:') {
      $problems += "scenarios need exactly four #: $l"
    } elseif ($l -cmatch '^### ') {
      $cur = $null
    } elseif ($l -cmatch '^#### Scenario:') {
      if ($null -ne $cur) { $cur.Scenarios++ }
    } elseif ($l.Contains('**Reason:**')) {
      if ($null -ne $cur) { $cur.Reason = $true }
    }
  }
  foreach ($b in $blocks) {
    $needScenario = ($Mode -eq 'main') -or ($b.Section -ceq '## ADDED Requirements') -or ($b.Section -ceq '## MODIFIED Requirements')
    if ($needScenario -and $b.Scenarios -eq 0) { $problems += "requirement has no #### Scenario: $($b.Name)" }
    if ($b.Section -ceq '## REMOVED Requirements' -and -not $b.Reason) { $problems += "REMOVED requirement has no **Reason:**: $($b.Name)" }
  }
  if ($Mode -eq 'main' -and -not $purpose) { $problems += 'missing ## Purpose' }
  if ($Mode -eq 'main' -and -not $reqs) { $problems += 'missing ## Requirements' }
  if ($problems.Count -eq 0) { Add-Pass "${Label}: structure ok" } else { foreach ($p in $problems) { Add-Fail "${Label}: $p" } }
}

function Test-Tasks([string]$Change) {
  $f = Join-Path $Change 'tasks.md'
  if (-not (Test-Path -LiteralPath $f)) { Write-Output '  - tasks.md not present yet (skipped)'; return }
  $lines = @(Get-Lines $f)
  $re = '^\s*- \[[ xX]\] [A-Za-z0-9]+\.[0-9]+(\s|$)'
  Assert-Check (@($lines | Where-Object { $_ -cmatch $re }).Count -gt 0) 'tasks.md: at least one task'
  $badLines = @()
  for ($i = 0; $i -lt $lines.Count; $i++) {
    if ($lines[$i] -cmatch '^\s*- \[' -and $lines[$i] -cnotmatch $re) { $badLines += "line $($i + 1): $($lines[$i])" }
  }
  if ($badLines.Count -eq 0) { Add-Pass 'tasks.md: every checkbox is well formed' }
  else { foreach ($b in $badLines) { Add-Fail "tasks.md: use '- [ ] 1.2 ...' or '- [x] 1.2 ...': $b" } }
}

function Test-Meta([string]$Change) {
  $f = Join-Path $Change '.espec.yaml'
  if (-not (Test-Path -LiteralPath $f)) { Add-Fail '.espec.yaml missing'; return }
  $status = Get-YamlValue $f 'status'
  if (@('defined', 'proposed', 'in-progress', 'implemented', 'archived') -ccontains $status) { Add-Pass ".espec.yaml: status is '$status'" }
  else { Add-Fail ".espec.yaml: status '$status' must be one of defined, proposed, in-progress, implemented, archived" }
}

function Test-PullRequest([string]$Change) {
  $f = Join-Path $Change 'pull-request.md'
  $meta = Join-Path $Change '.espec.yaml'
  $status = ''
  if (Test-Path -LiteralPath $meta) { $status = Get-YamlValue $meta 'status' }
  if (Test-Path -LiteralPath $f) {
    $text = Get-Content -LiteralPath $f -Raw
    $missing = @()
    foreach ($h in @('## Summary', '## Proposal versus implementation', '## Behaviour delivered', '## Deviations and deferred work', '## How to review', '## Verification', '## Rollout', '## Release note')) {
      if ($text -notmatch ('(?m)^' + [regex]::Escape($h))) { $missing += $h }
    }
    if ($missing.Count -eq 0) { Add-Pass 'pull-request.md: all sections present' }
    else { Add-Fail ('pull-request.md: missing section(s): ' + ($missing -join ', ')) }
  } elseif (@('implemented', 'archived') -ccontains $status) {
    Add-Fail "pull-request.md: missing (required once status is $status)"
  } else {
    Write-Output '  - no pull-request.md yet (written at the end of implementation)'
  }
}

function Test-Change([string]$Change) {
  Write-Output "Change: $(Split-Path -Leaf $Change)"
  Test-Meta $Change
  Test-PullRequest $Change
  Test-Feature $Change
  $base = (Resolve-Path -LiteralPath $Change).Path
  $specDir = Join-Path $Change 'specs'
  $specs = @()
  if (Test-Path -LiteralPath $specDir) { $specs = @(Get-ChildItem -LiteralPath $specDir -Recurse -File -Filter 'spec.md' | Sort-Object FullName) }
  if ($specs.Count -eq 0 -and (Get-YamlValue (Join-Path $Change '.espec.yaml') 'skip_specs') -ne 'true') {
    Write-Output '  - no delta specs yet (expected after the tech proposal)'
  }
  foreach ($s in $specs) { Test-Spec $s.FullName 'delta' (Get-RelativePath $base $s.FullName) }
  Test-Tasks $Change
}

function Test-MainSpecs([string]$Dir) {
  $root = Join-Path $Dir 'espec/specs'
  $specs = @()
  if (Test-Path -LiteralPath $root) {
    $base = (Resolve-Path -LiteralPath $root).Path
    $specs = @(Get-ChildItem -LiteralPath $base -Recurse -File -Filter 'spec.md' |
      Where-Object { $depth = (Get-RelativePath $base $_.FullName).Split('/').Count; $depth -ge 2 -and $depth -le 3 } |
      Sort-Object FullName)
  }
  if ($specs.Count -eq 0) { Write-Output 'Main specs: none yet'; return }
  Write-Output 'Main specs:'
  $projectBase = (Resolve-Path -LiteralPath $Dir).Path
  foreach ($s in $specs) { Test-Spec $s.FullName 'main' (Get-RelativePath $projectBase $s.FullName) }
}

function Invoke-Validate([string[]]$Arguments) {
  $name = ''; $dir = '.'
  if ($Arguments.Count -ge 2) { $name = $Arguments[0]; $dir = $Arguments[1] }
  elseif ($Arguments.Count -eq 1) {
    if (Test-Path -LiteralPath (Join-Path $Arguments[0] 'espec') -PathType Container) { $dir = $Arguments[0] } else { $name = $Arguments[0] }
  }
  Require-Project $dir
  if ($name) {
    $change = Join-Path $dir "espec/changes/$name"
    if (-not (Test-Path -LiteralPath $change -PathType Container)) { Fail "change not found: $change" }
    Test-Change $change
  } else {
    foreach ($c in @(Get-ChangeDirs $dir)) { Test-Change $c.FullName }
  }
  Test-MainSpecs $dir
  Write-Output ''
  Write-Output "$($script:Checks) checks, $($script:Fails) failures"
  if ($script:Fails -gt 0) { exit 1 }
}

# ---------------------------------------------------------------- dispatch

$arguments = @($Rest)
if ($Help) { $Command = 'help' }
switch ($Command.ToLowerInvariant()) {
  'init'     { Invoke-Init (Get-FirstOrDot $arguments) }
  'update'   { Invoke-Update (Get-FirstOrDot $arguments) }
  'new'      { Invoke-New $arguments }
  'list'     { Invoke-List (Get-FirstOrDot $arguments) }
  'validate' { Invoke-Validate $arguments }
  'help'     { Show-Usage }
  '--help'   { Show-Usage }
  default    { Show-Usage; Fail "unknown command: $Command" }
}
# Every command that reaches this point succeeded. Set the exit code explicitly, because
# $LASTEXITCODE otherwise keeps the value of the previous command or script.
exit 0
