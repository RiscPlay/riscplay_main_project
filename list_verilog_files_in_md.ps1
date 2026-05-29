param(
    [string]$Diretorio = ".",
    [string]$ArquivoSaida = "arquivos_verilog.md"
)

$output = ""

Get-ChildItem -Path $Diretorio -Recurse -File | Where-Object {
    $_.Extension -in ".v", ".sv", ".vh"
} | ForEach-Object {

    $output += "###$($_.Name)`n"
    $output += '```verilog' + "`n"

    $output += Get-Content $_.FullName -Raw

    $output += "`n"
    $output += '```'
    $output +="`n"
}

$output | Out-File -FilePath $ArquivoSaida -Encoding utf8