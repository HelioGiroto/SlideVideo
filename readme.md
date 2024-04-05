# Script que cria um vídeo de Slideshow com áudio

**slideVideo.sh**

Autor: Helio Giroto
Data : 05/04/2024

O script slideVideo.sh é um utilitário escrito em BASH para criar rapidamente um vídeo a partir de um áudio e imagens (do mesmo tamanho). 

O primeiro passo é editar o áudio que será usado no vídeo e salvá-lo com o nome de: audio-completo.mp3.

Em seguida, reuna todas as imagens que serão usadas. Ou os slides que serão mostrados no vídeo. (Se uma imagem tenha que aparecer várias vezes no vídeo, *não* é necessário salvar a imagem várias vezes, mas apenas uma).

O próximo passo é criar o roteiro do vídeo, ou seja, a partir de uma planilha (arquivo csv) se coloca na primeira coluna os nomes das imagens com extensão, e na segunda coluna o momento exato que tal imagem deve aparecer no vídeo, como mostra o exemplo abaixo:

```
	img1.jpg;00:00
	img2.jpg;00:05
	img4.jpg;00:10
	img2.jpg;00:12
	imgB.jpg;00:50
	...
```

O arquivo deve ser chamado de roteiro.csv e o delimitador que separa as colunas deve ser o ponto-e-vírgula (;).

O formato do nome dos arquivos de imagem (seja png ou jpg), definido na 1ª. coluna do arquivo csv, *não* devem ter espaços, e se recomenda um nome sugestivo (ao invés de img1, img2...) para que o operador se organize melhor no momento de criar o roteiro.

Uma mesma imagem pode aparecer várias outras vezes no vídeo, e no arquivo de roteiro deve estar descritas cada vez que for repetida, com seu devido momento exato que reaparecerá no vídeo.

O formato do tempo (definido na 2ª. coluna) deve ser: mm:ss ou hh:mm:ss (Qualquer dos dois formatos funciona).

Não é necessário descrever o momento do fim do vídeo, porque o programa fará isso por si mesmo.

Nesse repositório, você tem o exemplo do arquivo roteiro.csv para criação de vídeo de música com letra.

Após ter preparado o áudio do vídeo, reunido as imagens que serão usadas (todas do mesmo tamanho) e ter criado o arquivo de roteiro (salvo em CSV com delimitador ";"), bastará executar na linha de comando de Terminal no Linux:

```
bash slideVideo.sh
```

E automáticamente será gerado o vídeo encaixando todas as imagens nos devidos tempos sobre o áudio. O vídeo gerado terá o nome de video-versao-final.mp4, e estará na mesma pasta em que estão as imagens e áudio, o script e o roteiro.

No exemplo deste projeto, o vídeo produzido está na pasta resultado. Tem 5.6 Megabytes e levou **apenas 2.5 segundos para ser produzido!** Nenhum editor de vídeo consegue produzir (renderizar que seja) um vídeo em apenas 2 segundos!

Para que o script slideVideo.sh rode perfeitamente na sua máquina, recomendo que tenha instalado na sua máquina os seguintes programas:

- ffmpeg
- bc
- mp3info
- mpv

Disfrute!
Hélio



