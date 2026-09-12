#!/bin/bash

# 1. Ativa nullglob ANTES de preencher os arrays
shopt -s nullglob nocaseglob extglob

WIN_USER=$(cmd.exe /c "echo %USERNAME%" 2>/dev/null | tr -d '\r')

dir="/mnt/c/Users/$WIN_USER"

## dir="/mnt/c/Users/$USER" Linux

DIR_DOWNLOADS="$dir/Downloads"
DIR_IMAGENS="$DIR_DOWNLOADS/Pictures/"
DIR_COMPACTADOS="$DIR_DOWNLOADS/Pasta_Compactada"
DIR_PDF="$DIR_DOWNLOADS/pdf"
DIR_EXE="$DIR_DOWNLOADS/executavel"
DIR_TODOS="$DIR_DOWNLOADS/outros/"

logalerta="$DIR_DOWNLOADS/logsdownloads.txt"

arquivos_compactados=( "$DIR_DOWNLOADS"/*.{rar,zip,7z} )
arquivos_imagens=( "$DIR_DOWNLOADS"/*.{jpg,png,gif,jpeg,webp,svg} )
arquivos_pdf=( "$DIR_DOWNLOADS"/*.pdf )
arquivos_exe=( "$DIR_DOWNLOADS"/*.exe )

mkdir -p "$DIR_DOWNLOADS"
: > "$logalerta"

echo "=== Início da Execução: $(date '+%Y-%m-%d %H:%M:%S') ===" > "$logalerta"

# Mensagem de alerta
armazenalog() {
	echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$logalerta"
}

## funcao para lidar com duplicatas
mover_arquivo() {
    local origem="$1"
    local destino_dir="$2"
    local nome base ext contador destino

    nome=$(basename "$origem")

    # Separa o nome base da extensão
    if [[ "$nome" == *.* ]]; then
        base="${nome%.*}"
        ext=".${nome##*.}"
    else
        base="$nome"
        ext=""
    fi

    destino="$destino_dir/$nome"

    # Se já existir, incrementa o sufixo (1), (2)... até achar um nome vago
    if [[ -e "$destino" ]]; then
        contador=1
        while [[ -e "$destino_dir/${base}(${contador})${ext}" ]]; do
            ((contador++))
        done
        destino="$destino_dir/${base}(${contador})${ext}"
    fi

    mv "$origem" "$destino"
}

# 2. Garante que os destinos existam de forma limpa (-p)

mkdir -p "$DIR_TODOS" "$DIR_IMAGENS" "$DIR_COMPACTADOS" "$DIR_PDF" "$DIR_EXE" 


# 3. Processa imagens
armazenalog " Imagens "
if (( ${#arquivos_imagens[@]} > 0 )); then
    for arq in "${arquivos_imagens[@]}"; do
        mover_arquivo "$arq" "$DIR_IMAGENS"
    done
    armazenalog "Arquivos de imagens movidos com sucesso!"
else
    armazenalog "Não há arquivos de imagens para mover."
fi

# 4. Processa compactados
armazenalog " Compactados "
if (( ${#arquivos_compactados[@]} > 0 )); then
    for arq in "${arquivos_compactados[@]}"; do
        mover_arquivo "$arq" "$DIR_COMPACTADOS"
    done
    armazenalog " Arquivos compactados movidos com sucesso! "
else
    armazenalog " Não há arquivos compactados para mover. "
fi

# 5. Processa PDFs
armazenalog " PDF "
if (( ${#arquivos_pdf[@]} > 0 )); then
    for arq in "${arquivos_pdf[@]}"; do
        mover_arquivo "$arq" "$DIR_PDF"
    done
    armazenalog "Arquivos PDF movidos com sucesso!"
    
else
    armazenalog " Não há arquivos PDF para mover. "
fi

# 6. Processa Executaveis
armazenalog " EXE "
if (( ${#arquivos_exe[@]} > 0 )); then
    for arq in "${arquivos_exe[@]}"; do
        mover_arquivo "$arq" "$DIR_EXE"
    done
    armazenalog "Arquivos .EXE movidos com sucesso!"
    
else
    armazenalog " Não há arquivos .EXE para mover. "
fi

#7 Processa outros

armazenalog "Outros"

candidatos_outros=( "$DIR_DOWNLOADS"/!(logsdownloads.txt|organizador.sh|organizador.bat) )
arquivos_finais=()

for item in "${candidatos_outros[@]}"; do
	[[ -f "$item" ]] && arquivos_finais+=( "$item" )
done


if (( ${#arquivos_finais[@]} > 0 )); then
    for arq in "${arquivos_finais[@]}"; do
        mover_arquivo "$arq" "$DIR_TODOS"
    done
    armazenalog "Arquivos movidos com sucesso!"

else
    armazenalog " Não há arquivos para mover. "
fi


# Desativa a opção de globbing
shopt -u nullglob nocaseglob extglob
