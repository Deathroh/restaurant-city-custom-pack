# Aplica os itens recriados no servidor local do jogo:
#  1. na primeira vez, guarda os originais (indoor_asset.swf, restaurant.xml/.bin, game.swf, lang_en.bin) em recriados/base/;
#  2. copia para o SWF original a arte da build de julho/2010 que falta nele (copiar_julho2010.cjs) e injeta
#     a arte recriada -> public/swf/indoor_asset.swf;
#  3. acrescenta as linhas ao XML original -> public/data/restaurant.xml + restaurant.bin;
#  4. recompila no game.swf original as classes de recriados/codigo/ (funcoes novas, ex. PetalGenerator) com o FFDec;
#  5. acrescenta os textos da janela de informacao (descricao/efeito do manifesto) -> public/data/lang_en.bin.
# Como sempre parte dos originais, pode rodar de novo apos editar o manifesto ou o codigo.
# Desfazer: scripts/aplicar_itens.ps1 -Restaurar
#
# UMA FONTE SO: todos os itens recriados (de qualquer agente) ficam em recriados/manifesto.json.
# Este script reconstroi o servidor a partir dos originais + esse manifesto; o que nao estiver nele some.
# Trava: depois de aplicar, grava o hash dos arquivos do servidor em recriados/.estado_servidor.json.
# Se alguem mexer neles por fora, a proxima execucao para e avisa (use -Forcar so depois de levar a
# mudanca para o manifesto ou para recriados/codigo/).
# -Servidor: pasta public/ do servidor (padrao: o desta maquina). -Node: node.exe (padrao: o do Hermes, senao o do PATH).
# -SemTroca: game.swf sem o botao de troca de ingredientes no proprio restaurante (para servidor sem o patch
#   obrigatorio_troca_de_ingredientes; sem ele a troca sempre falha).
param([switch]$Restaurar, [switch]$Forcar, [switch]$SemTroca,
  [string]$Servidor = 'C:\Users\Nashira\OneDrive\Documentos\Antigravity\restaurant-city-server\public',
  [string]$Node = 'C:\Users\Nashira\AppData\Local\hermes\node\node.exe')
$ErrorActionPreference = 'Stop'
$proj = Split-Path $PSScriptRoot -Parent
$srv  = $Servidor
$baseDir = Join-Path $proj 'recriados\base'
$codigo = Join-Path $proj 'recriados\codigo'
$ffdec = Join-Path $proj 'ferramentas\ffdec\ffdec-cli.jar'
$node = if (Test-Path $Node) { $Node } else { 'node' }
$Manifesto = Join-Path $proj 'recriados\manifesto.json'
# uma trava por servidor: aplicar numa copia (ex. para montar o pacote) nao mexe na trava do servidor desta maquina
$padrao = 'C:\Users\Nashira\OneDrive\Documentos\Antigravity\restaurant-city-server\public'
$sufixo = if ($Servidor.TrimEnd('\') -eq $padrao) { '' } else {
  '_' + [BitConverter]::ToString([Security.Cryptography.SHA1]::Create().ComputeHash([Text.Encoding]::UTF8.GetBytes($Servidor.TrimEnd('\').ToLower()))).Replace('-', '').Substring(0, 8) }
$estado = Join-Path $proj "recriados\.estado_servidor$sufixo.json"

$arquivos = @{
  'indoor_asset.swf' = "$srv\swf\indoor_asset.swf"; 'game.swf' = "$srv\swf\game.swf"
  'restaurant.xml' = "$srv\data\restaurant.xml"; 'restaurant.bin' = "$srv\data\restaurant.bin"; 'lang_en.bin' = "$srv\data\lang_en.bin"
}
function Hashes { $h = [ordered]@{}; foreach ($n in ($arquivos.Keys | Sort-Object)) { $h[$n] = (Get-FileHash $arquivos[$n] -Algorithm SHA256).Hash }; $h }
if ((Test-Path $estado) -and -not $Forcar) {
  $antes = Get-Content $estado -Raw | ConvertFrom-Json
  $agora = Hashes
  $mexidos = @($agora.Keys | Where-Object { $antes.$_ -and $antes.$_ -ne $agora[$_] })
  if ($mexidos.Count) {
    throw "Arquivos do servidor mudaram por fora desde a ultima aplicacao: $($mexidos -join ', ').`nAplicar agora apagaria essa mudanca. Leve-a para recriados/manifesto.json (itens) ou recriados/codigo/ (game.swf) e rode de novo com -Forcar."
  }
}
New-Item -ItemType Directory -Force $baseDir | Out-Null
foreach ($nome in $arquivos.Keys) {
  $copia = Join-Path $baseDir $nome
  if (-not (Test-Path $copia)) { Copy-Item $arquivos[$nome] $copia; "original guardado: $copia" }
}
if ($Restaurar) {
  foreach ($nome in $arquivos.Keys) { Copy-Item (Join-Path $baseDir $nome) $arquivos[$nome] -Force; "restaurado: $($arquivos[$nome])" }
  Hashes | ConvertTo-Json | Out-File -Encoding utf8 $estado
  return
}

# arte da build de julho/2010 (etapa 2 da raspagem): copia para uma copia do original os simbolos que faltam
# nele, dos .swf do Restaurant Origins; o injetor parte dessa copia. recriados/base/ continua intacto.
$ro = Join-Path $proj 'recuperado\restaurant_origins'
$baseInjetor = Join-Path $proj 'recriados\.indoor_asset_com_julho2010.swf'
# (2026-11-03) + so as comidas das receitas de sushi do game_asset2.swf, para os pratos do Sushi Bar
$comidasSushi = (Join-Path $ro 'game_asset2.swf') + '=FoodItem108,FoodItem109,FoodItem110,FoodItem111,FoodItem112,FoodItem113,FoodItem114'
# (2026-11-04) + o ingrediente Salmon do ingredient_asset.swf de julho (receitas de sushi; o Seaweed ja tem arte)
$ingredientesJulho = (Join-Path $ro 'ingredient_asset.swf') + '=Salmon'
& $node (Join-Path $PSScriptRoot 'copiar_julho2010.cjs') (Join-Path $baseDir 'indoor_asset.swf') $baseInjetor (Join-Path $ro 'indoor_asset.swf') (Join-Path $ro 'indoor_asset2.swf') $comidasSushi $ingredientesJulho
if ($LASTEXITCODE) { throw "copiar_julho2010 falhou ($LASTEXITCODE)" }

# manifesto temporario com entrada = original guardado (com a arte de julho), saida = servidor
$m = Get-Content $Manifesto -Raw -Encoding UTF8 | ConvertFrom-Json
$m | Add-Member -Force -NotePropertyName entrada -NotePropertyValue ($baseInjetor -replace '\\', '/')
$m | Add-Member -Force -NotePropertyName saida -NotePropertyValue ($arquivos['indoor_asset.swf'] -replace '\\', '/')
$tmp = Join-Path (Split-Path $Manifesto -Parent) '.manifesto_aplicar.json'
$m | ConvertTo-Json -Depth 6 | Out-File -Encoding utf8 $tmp
try {
  & $node (Join-Path $PSScriptRoot 'injetar_itens.cjs') $tmp
  if ($LASTEXITCODE) { throw "injetar_itens falhou ($LASTEXITCODE)" }
  & $node (Join-Path $PSScriptRoot 'aplicar_catalogo.cjs') $Manifesto (Join-Path $baseDir 'restaurant.xml') "$srv\data"
  if ($LASTEXITCODE) { throw "aplicar_catalogo falhou ($LASTEXITCODE)" }
  # (2026-11-04) receitas de sushi e ingredientes Salmon/Seaweed de julho (recipe.xml/.bin, ingredient.xml/.bin)
  & $node (Join-Path $PSScriptRoot 'aplicar_receitas_julho.cjs') "$srv\data"
  if ($LASTEXITCODE) { throw "aplicar_receitas_julho falhou ($LASTEXITCODE)" }
} finally { Remove-Item $tmp -ErrorAction SilentlyContinue }

# classes AS3 modificadas: recriados/codigo/<pacote>/<Classe>.as -> nome qualificado do script
# (recriados/codigo/original/ guarda as versoes decompiladas de antes, so para comparar)
$classes = @(Get-ChildItem $codigo -Recurse -Filter *.as | Where-Object { $_.FullName -notmatch '\\original\\' })
$semTrocaDir = $null
if ($SemTroca) {
  # sem troca: o painel volta ao original (nao entra na lista) e o WorldRestaurantPlay nao cria o botao
  $classes = @($classes | Where-Object { $_.Name -ne 'WorldTradePanel.as' })
  $semTrocaDir = Join-Path $env:TEMP "rcr_sem_troca_$PID"
  New-Item -ItemType Directory -Force $semTrocaDir | Out-Null
  $wrp = $classes | Where-Object { $_.Name -eq 'WorldRestaurantPlay.as' }
  $texto = Get-Content $wrp.FullName -Raw -Encoding UTF8
  if ($texto -notmatch 'this\.initOwnExchangeButton\(\);') { throw 'SemTroca: chamada initOwnExchangeButton nao encontrada no WorldRestaurantPlay.as' }
  $copiaWrp = Join-Path $semTrocaDir 'WorldRestaurantPlay.as'
  [IO.File]::WriteAllText($copiaWrp, ($texto -replace 'this\.initOwnExchangeButton\(\);', '// sem troca (aplicar_itens -SemTroca)'), (New-Object Text.UTF8Encoding $false))
}
if ($classes.Count) {
  $repl = @()
  foreach ($c in $classes) {
    $nome = $c.FullName.Substring($codigo.Length + 1) -replace '\.as$', '' -replace '\\', '.'
    $arqClasse = if ($semTrocaDir -and $c.Name -eq 'WorldRestaurantPlay.as') { $copiaWrp } else { $c.FullName }
    $repl += $nome, $arqClasse
  }
  $saidaTmp = Join-Path $env:TEMP "rcr_game_$PID.swf"
  $log = & java -jar $ffdec -replace (Join-Path $baseDir 'game.swf') $saidaTmp @repl 2>&1 | Out-String
  if ($LASTEXITCODE -or -not (Test-Path $saidaTmp) -or $log -match 'Exception|rror') { throw "FFDec falhou ao compilar:`n$log" }
  Move-Item $saidaTmp $arquivos['game.swf'] -Force
  "game.swf: $($classes.Count) classe(s) recompilada(s) ($(($classes | ForEach-Object BaseName) -join ', '))$(if ($SemTroca) { ', sem a troca de ingredientes' })"
  if ($semTrocaDir) { Remove-Item $semTrocaDir -Recurse -Force -ErrorAction SilentlyContinue }
}

& $node (Join-Path $PSScriptRoot 'aplicar_textos.cjs') $Manifesto (Join-Path $baseDir 'lang_en.bin') $arquivos['lang_en.bin']
if ($LASTEXITCODE) { throw "aplicar_textos falhou ($LASTEXITCODE)" }
Hashes | ConvertTo-Json | Out-File -Encoding utf8 $estado
"Pronto. Reinicie o servidor (o catalogo fica em cache) e recarregue o jogo."
