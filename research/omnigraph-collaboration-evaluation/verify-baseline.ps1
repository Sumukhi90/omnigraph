param(
  [Parameter(Mandatory = $true)]
  [ValidateNotNullOrEmpty()]
  [string]$PocPath
)

$ErrorActionPreference = 'Stop'
$cli = Join-Path $env:USERPROFILE '.local\bin\omnigraph.exe'
$graph = Join-Path $PocPath 'graph.omni'
$schema = Join-Path $PocPath 'schema.pg'
$query = Join-Path $PocPath 'queries.gq'
$params = Join-Path $PocPath 'params.json'

foreach ($required in @($cli, $graph, $schema, $query, $params)) {
  if (!(Test-Path -LiteralPath $required)) {
    throw "Required path is missing: $required"
  }
}

$target = 'file:///' + $graph.Replace('\', '/')
$current = Get-Location

try {
  Write-Output '--- Omnigraph version ---'
  & $cli version
  if ($LASTEXITCODE -ne 0) { throw 'Version command failed' }

  Write-Output '--- Visible branches ---'
  $branches = @(& $cli branch list --target $target)
  if ($LASTEXITCODE -ne 0) { throw 'Branch list failed' }
  $branches | ForEach-Object { Write-Output $_ }
  if ($branches.Count -ne 1 -or $branches[0].Trim() -ne 'main') {
    throw "Expected only main in this baseline; saw: $($branches -join ', ')"
  }

  Write-Output '--- Snapshot ---'
  $snapshotText = (& $cli snapshot --json --target $target | Out-String)
  if ($LASTEXITCODE -ne 0) { throw 'Snapshot command failed' }
  $snapshotText | Write-Output
  $snapshot = $snapshotText | ConvertFrom-Json
  if ($snapshot.graph_branch -ne 'main') {
    throw "Expected graph branch main, saw $($snapshot.graph_branch)"
  }

  Write-Output '--- Query ---'
  Set-Location $PocPath
  $queryText = (& $cli query sources_for_claim --query $query `
    --params-file $params --format json --target $target | Out-String)
  if ($LASTEXITCODE -ne 0) { throw 'Query command failed' }
  $queryText | Write-Output
  $result = $queryText | ConvertFrom-Json
  $actual = @($result.rows | ForEach-Object { $_.source })
  $expected = @('Synthetic benchmark A', 'Synthetic benchmark B')
  if (($actual -join "`n") -ne ($expected -join "`n")) {
    throw "Unexpected query rows: $($actual -join ', ')"
  }
} finally {
  Set-Location $current
}

Write-Output 'Baseline checks passed. This script performs read-only operations.'
