#!/bin/bash 
#
# slideVideo.sh
# Script que cria vídeo de Slideshow com áudio
#
# Autor: Helio Giroto
# Data : 05/04/2024


# PREPARATIVOS:
# Edita áudio com nome: audio-completo.mp3
# Reune imagens que serão usadas (exemplo: como estão nomeadas em roteiro.csv)

# SCRIPT:
## Cria CSV chamado roteiro.csv- com imagens e tempo de início que essas aparecerão no vídeo
	# Formato:
		# [arq-img ; tempo-inicio]
		# img1.jpg;00:00
		# img2.jpg;00:05
		# img4.jpg;00:10
		# img3.jpg;00:12
		# imgB.jpg;00:50


## Cria outros arqs que serão utilizados no processamento do script:
: > imagens.csv
: > arq2.csv
: > arq-col-3.csv
: > arq-intervalos.csv
: > duracao.csv
: > img-duracao.csv
: > file.txt

## Função - Obtem nomes das imagens usadas (da lista ordenada)
cut -d";" -f1 roteiro.csv > imagens.csv 

	# Formato do imagens.csv:
		# [arq-img]
		# img1.jpg
		# img2.jpg
		# img4.jpg
		# img3.jpg
		# imgB.jpg


## Função - Converte tempo em segundos:
	# itera cada linha de roteiro.csv em que:
		# o-fogo.png;00:04

for CADALINHA in $(cat roteiro.csv)
do
	# coluna1 = conteudo da 1a coluna
	COLUNA1=$(echo $CADALINHA | cut -d';' -f1)
	# coluna2 = pega (cut, awk) conteúdo da 2a coluna
	COLUNA2=$(echo $CADALINHA | cut -d';' -f2)

	# verifica se o valor é 01:00:00 ou apenas 01:00
	PONTOS=$(echo $COLUNA2 | grep -o ":" | wc -l)
	
	# Se tem 1 ":"
	if [ $PONTOS -eq 1 ]; then
		HORAS=0
		MINUTOS=$(echo $COLUNA2 | cut -d':' -f1)
		SEGUNDOS=$(echo $COLUNA2 | cut -d':' -f2)

	# Se tem 2 ":"
	elif [ $PONTOS -eq 2 ]; then
		HORAS=$(echo $COLUNA2 | cut -d':' -f1)
		MINUTOS=$(echo $COLUNA2 | cut -d':' -f2)
		SEGUNDOS=$(echo $COLUNA2 | cut -d':' -f3)
			
	else 
		echo "Erro na definição do tempo em: $CADALINHA"
	fi
	
	# calcula a duração em segundos:
	DURACAO=$(echo "($HORAS * 3600) + ($MINUTOS * 60) + $SEGUNDOS" | bc)

	# imprime (appenda) em novo arq2.csv = coluna1;tempo_segundos
	echo "$COLUNA1;$DURACAO" >> arq2.csv

	# Formato do arq2.csv:
		# [arq-img ; tempo-inicio-em-segundos]
		# img1.jpg;0
		# img2.jpg;5
		# img4.jpg;10
		# img3.jpg;12
		# imgB.jpg;50
			
	# cria arq com valores apenas da 3a coluna:
	# imprime (appenda) em arq-col-3.csv << tempo_segundos
	echo "$DURACAO" >> arq-col-3.csv

	# Formato do arq-col-3.csv:
		# [tempo-inicio-em-segundos]
		# 0
		# 5
		# 10
		# 12
		# 50
done


## Função - Edita arq 3a. coluna 
# apaga 1a linha (que normalmente é: 0):
sed -i '1d' arq-col-3.csv

# obtem lenght EM SEGUNDOS do áudio:
DURACAO_TOTAL_AUDIO=$(mp3info -p "%S" audio-completo.mp3)
# appenda valor em arq-col-3.csv:
echo $DURACAO_TOTAL_AUDIO >> arq-col-3.csv
	

# Cria um outro arquivo csv com as 3 colunas (img; segundos-inicio; segundos-final):
paste -d";" arq2.csv  arq-col-3.csv > arq-intervalos.csv

	# Formato do arq-intervalos.csv:
		# [arq-img ; tempo-inicio-em-segundos; tempo-final-em-segundos]
		# (img1.jpg;0;5
		# img2.jpg;5;10
		# img4.jpg;10;12
		# img3.jpg;12;50
		# imgB.jpg;50;55
		

## Função - Calcula o tempo de duração de cada imagem em segundos:
# Itera a cada linha de arq-intervalos.csv e:
for CADAITEM in $(cat arq-intervalos.csv)
do 
	COLUNA2=$(echo $CADAITEM | cut -d';' -f2)
	COLUNA3=$(echo $CADAITEM | cut -d';' -f3)
	DURACAO=$(echo $COLUNA3 - $COLUNA2 | bc)
	echo $DURACAO >> duracao.csv

done


## Função - gera arquivo.csv (paste) final
paste -d";" imagens.csv duracao.csv > img-duracao.csv
	
	# Formato do img-duracao.csv:
		# [arq-img ; duracao-em-segundos]
		# img1.jpg;5
		# img2.jpg;5
		# img4.jpg;2
		# img3.jpg;38
		# imgB.jpg;5
	
	# (agora temos em cada linha: nome-da-imagem e qto tempo (em seg.) ela permanece no vídeo - falta editar em formato txt para ffmpeg)


## Função - Gera file.txt com duration's
for CADALINHA in $(cat img-duracao.csv)
do
	# deste formato: img1.jpg;5

	# coluna1 = conteudo da 1a coluna
	COLUNA1=$(echo $CADALINHA | cut -d';' -f1)
	# coluna2 = pega (cut, awk) conteúdo da 2a coluna
	COLUNA2=$(echo $CADALINHA | cut -d';' -f2)

	# para este:

	# file 'img1.jpg'
	echo "file '$COLUNA1'" >> file.txt
	# duration 5
	echo "duration $COLUNA2" >> file.txt

done

# Repetir na última linha de file.txt o conteúdo da penúltima:
PENULTIMA_LINHA=$(tail -n2 file.txt | head -n1)
echo $PENULTIMA_LINHA >> file.txt

	# Formato de file.txt terá que ser:
		# file 'img1.jpg'
		# duration 5
		# file 'img2.jpg'
		# duration 5
		# file 'img4.jpg'
		# duration 2
		# file 'img3.jpg'
		# duration 38
		# file 'imgB.jpg'
		# duration 5
		# file 'imgB.jpg'   # [!]
		

## Roda comando ffmpeg para criar vídeo:
ffmpeg -f concat -i file.txt -i audio-completo.mp3 -r 1 -c:a copy -shortest video-saida.mp4
	

## Corta vídeo conforme tempo de áudio (trim do pós-excesso):
DURACAOAUDIO=$(ffmpeg -i audio-completo.mp3 -f null - |& sed 's/,/\n/g' | grep Duration | cut -d' ' -f4)

ffmpeg -ss 00 -i video-saida.mp4 -c copy -t $DURACAOAUDIO video-versao-final.mp4

## Deleta csv´s não mais necessários:
rm video-saida.mp4
rm imagens.csv
rm arq2.csv
rm arq-col-3.csv
rm arq-intervalos.csv
rm duracao.csv
rm img-duracao.csv
rm file.txt

# abre video:
mpv video-versao-final.mp4


# Jesus é o Amor!
