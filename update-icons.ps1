[CmdletBinding()]
param(
    [string]$SourceRoot = (Join-Path $PSScriptRoot "Icon-package-aws-temp"),
    [string]$DestinationRoot = (Join-Path $PSScriptRoot "icons"),
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

function Get-SourceDirectory {
    param(
        [string]$Root,
        [string]$Pattern,
        [string]$Label
    )

    $matches = @(Get-ChildItem -LiteralPath $Root -Directory -Filter $Pattern)
    if ($matches.Count -ne 1) {
        throw "Se esperaba exactamente una carpeta para $Label con el patrón '$Pattern'. Encontradas: $($matches.Count)."
    }

    return $matches[0]
}

function Copy-IconSection {
    param(
        [System.IO.DirectoryInfo]$Source,
        [string]$Destination
    )

    $files = @(Get-ChildItem -LiteralPath $Source.FullName -File -Filter "*.svg" -Recurse)
    if ($files.Count -eq 0) {
        throw "La sección '$($Source.Name)' no contiene archivos SVG."
    }

    foreach ($file in $files) {
        $relativePath = $file.FullName.Substring($Source.FullName.Length).TrimStart('\', '/')
        $targetFile = Join-Path $Destination $relativePath
        $targetDirectory = Split-Path -Parent $targetFile

        New-Item -ItemType Directory -Path $targetDirectory -Force | Out-Null
        Copy-Item -LiteralPath $file.FullName -Destination $targetFile -Force
    }

    return $files.Count
}

if (-not (Test-Path -LiteralPath $SourceRoot -PathType Container)) {
    throw "No se encuentra la carpeta fuente: $SourceRoot"
}

$sections = @(
    [PSCustomObject]@{ Label = "grupos"; Pattern = "Architecture-Group-Icons*"; Destination = "groups" }
    [PSCustomObject]@{ Label = "servicios"; Pattern = "Architecture-Service-Icons*"; Destination = "services" }
    [PSCustomObject]@{ Label = "categorías"; Pattern = "Category-Icons*"; Destination = "categories" }
    [PSCustomObject]@{ Label = "recursos"; Pattern = "Resource-Icons*"; Destination = "resources" }
)

Write-Host "Validando el paquete AWS..." -ForegroundColor Cyan
$sources = foreach ($section in $sections) {
    $source = Get-SourceDirectory -Root $SourceRoot -Pattern $section.Pattern -Label $section.Label
    $files = @(Get-ChildItem -LiteralPath $source.FullName -File -Filter "*.svg" -Recurse)
    if ($files.Count -eq 0) {
        throw "La sección '$($source.Name)' no contiene archivos SVG."
    }

    [PSCustomObject]@{
        Label = $section.Label
        Destination = $section.Destination
        Source = $source
        Count = $files.Count
    }
}

Write-Host "Paquete válido:" -ForegroundColor Green
$sources | ForEach-Object { Write-Host ("  {0}: {1} SVG" -f $_.Label, $_.Count) }

if ($DryRun) {
    Write-Host "`nDryRun activo: no se modificó la carpeta de destino." -ForegroundColor Yellow
    exit 0
}

$stagingRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("aws-service-icons-" + [guid]::NewGuid().ToString("N"))

try {
    New-Item -ItemType Directory -Path $stagingRoot -Force | Out-Null

    foreach ($section in $sources) {
        $destination = Join-Path $stagingRoot $section.Destination
        $copied = Copy-IconSection -Source $section.Source -Destination $destination
        if ($copied -ne $section.Count) {
            throw "La sección '$($section.Label)' no se copió completamente."
        }
    }

    $stagedFiles = @(Get-ChildItem -LiteralPath $stagingRoot -File -Filter "*.svg" -Recurse)
    $expectedFiles = ($sources | Measure-Object -Property Count -Sum).Sum
    if ($stagedFiles.Count -ne $expectedFiles) {
        throw "La salida preparada contiene $($stagedFiles.Count) SVG; se esperaban $expectedFiles."
    }

    if (Test-Path -LiteralPath $DestinationRoot) {
        Remove-Item -LiteralPath $DestinationRoot -Recurse -Force
    }

    Move-Item -LiteralPath $stagingRoot -Destination $DestinationRoot
    $stagingRoot = $null
    Write-Host "`nActualización completada. Se instalaron $expectedFiles archivos SVG en '$DestinationRoot'." -ForegroundColor Green
}
finally {
    if ($stagingRoot -and (Test-Path -LiteralPath $stagingRoot)) {
        Remove-Item -LiteralPath $stagingRoot -Recurse -Force
    }
}