Set-StrictMode -Version Latest
Import-Module (Join-Path $PSScriptRoot 'NarrationPacket.psm1') -Force

function Read-NarrationExemplars {
    param([Parameter(Mandatory)][string]$Path,[int]$ExpectedCount=8)
    if (-not (Test-Path -LiteralPath $Path)) { throw "Exemplar file not found: $Path" }
    $items = @(Get-Content -Raw -LiteralPath $Path | ConvertFrom-Json)
    if ($items.Count -ne $ExpectedCount) { throw "Exactly $ExpectedCount exemplars are required; found $($items.Count)." }
    $items
}

function Build-NarrationPrompt {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]$Packet,
        [Parameter(Mandatory)][ValidateSet('facts','literary')][string]$Format,
        [object[]]$Exemplars = @()
    )
    $builder = [Text.StringBuilder]::new()
    foreach ($exemplar in $Exemplars) {
        $examplePacket = ConvertTo-NarrationPacket $exemplar.packet
        [void]$builder.Append((Format-NarrationPacket $examplePacket $Format))
        [void]$builder.AppendLine($exemplar.narration.Substring(3))
        [void]$builder.AppendLine()
        [void]$builder.AppendLine()
    }
    [void]$builder.Append((Format-NarrationPacket $Packet $Format))
    $builder.ToString()
}

Export-ModuleMember -Function Read-NarrationExemplars,Build-NarrationPrompt
