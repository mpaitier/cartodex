# Recopie la version de Flutter installée sur cette machine dans
# pubspec.yaml (environment > flutter), où la CI la lit pour installer
# exactement la même version (voir .github/workflows/ci.yml).
#
# À relancer après chaque `flutter upgrade`, puis committer
# pubspec.yaml : tant que la ligne n'est pas à jour, `flutter pub get`
# refuse de tourner avec une autre version, ce qui évite d'oublier.
#
# Usage, depuis la racine du dépôt :
#   powershell -ExecutionPolicy Bypass -File tool\sync_flutter_version.ps1

$ErrorActionPreference = 'Stop'

$pubspec = Join-Path (Split-Path -Parent $PSScriptRoot) 'pubspec.yaml'
$utf8 = New-Object System.Text.UTF8Encoding $false

# `flutter --version --machine` renvoie du JSON, parfois précédé de
# messages (téléchargement, bannière) : on ne garde que l'objet JSON.
$output = (& flutter --version --machine) -join "`n"
$json = $output.Substring($output.IndexOf('{'), $output.LastIndexOf('}') - $output.IndexOf('{') + 1)
$version = ($json | ConvertFrom-Json).frameworkVersion
if (-not $version) { throw "Version de Flutter introuvable dans : $output" }

# Lu et réécrit en UTF-8 sans BOM, avec des fins de ligne LF : la
# description du pubspec contient des caractères accentués.
$lines = [System.Collections.Generic.List[string]][System.IO.File]::ReadAllLines($pubspec, $utf8)

$envIndex = $lines.IndexOf('environment:')
if ($envIndex -lt 0) { throw "Bloc 'environment:' introuvable dans $pubspec" }

# Parcourt le bloc environment (lignes indentées) à la recherche d'une
# ligne flutter déjà présente.
$flutterIndex = -1
$i = $envIndex + 1
while ($i -lt $lines.Count -and $lines[$i] -match '^\s+\S') {
  if ($lines[$i] -match '^\s+flutter:') { $flutterIndex = $i }
  $i++
}

$newLine = "  flutter: $version"
if ($flutterIndex -ge 0) {
  $lines[$flutterIndex] = $newLine
} else {
  $lines.Insert($i, '  # Version exacte de Flutter de la machine de dev, reprise par la CI.')
  $lines.Insert($i + 1, '  # Mise à jour : tool\sync_flutter_version.ps1')
  $lines.Insert($i + 2, $newLine)
}

[System.IO.File]::WriteAllText($pubspec, (($lines -join "`n") + "`n"), $utf8)
Write-Host "pubspec.yaml : flutter $version"
