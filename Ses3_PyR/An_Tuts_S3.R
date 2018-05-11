## ---
##title: "Sesion3_PyR"
##author: "Sergio Nieto"
##date: "7 de mayo de 2018"
##output: 
  ##html_document:
  ##keep_md: true
##---

## La Referencia principal es el libro siguiente: https://www.tidytextmining.com/

#El __análisis de texto__ que haremos será por frecuencias de palabras, las visualizaciones son estándar y para mejorarlas pueden revisar las opciones de la librería *ggplot2*.

#Inicialmente cargamos las librerías necesarias en R y los datos.

#```{r message=FALSE, error=FALSE, warning=FALSE, echo=FALSE}
library(dplyr)
library(stringr)
library(ggplot2)
library(lubridate)
library(readr)
library(tidyquant)
library(tidytext)
library(SnowballC)
library(wordcloud)
library(tm)
library(topicmodels)

archivo <- "dom_29_tuits.csv" #aquí ponen el nombre del archivo de tuits que usaran, si cambian de csv solo cambian el nombre aquí
fullTw <- read.csv(archivo, header=T, skip=0, sep=',',fileEncoding = "utf-16", as.is=TRUE)

#read.csv(file, header=F, skip=1, sep=',', nrow=1, fileEncoding = "utf-16")
#read.csv(file, header=T, skip=0, sep=',', nrow=1, fileEncoding = "utf-16")

stopwords_spanish <- read_csv("palabras_vacias.csv")

# Hasta este momento no se usarán aun los diccionarios de emociones y polaridad
#get_sentiments <- read.table("dicc_subjetividad.csv" ,fileEncoding = "UTF-8" ,header = TRUE, as.is= TRUE, sep = ',')
#get_emo <- read.table("dicc_emociones.csv" ,fileEncoding = "UTF-8" ,header = TRUE, as.is= TRUE, sep = ',')

colnames(fullTw)[3] <- "ide"
colnames(fullTw)[4] <- "tuit"

df_tuits <- fullTw %>% select(timestamp:tuit) %>% distinct(ide, .keep_all=TRUE)
str(df_tuits)
#```

#Vemos en el resultado anterior un resumen de los tuits recolectados ya distinguidos por el *id* para evitar repeticiones, aunque hemos observado que esto no siempre es el caso...

#Lo que sigue es hacer un Procesamiento de Lenguaje Natural que nos ayuda a analizar texto de manera más eficiente. Estos procedimientos se llaman *tokenización* y *lematización*.

#Las palabras más usadas por las cuentas que partician de los tópicos rastreados:
  
  
#  ```{r message=FALSE, error=FALSE, warning=FALSE}
reg_words <- "([^A-Za-z_\\d#@']|'(?![A-Za-z_\\d#@]))"

tuits_tokenizados <- fullTw %>%
  filter(!str_detect(tuit, "^RT")) %>%
  mutate(text = str_replace_all(tuit, "https://t.co/[A-Za-z\\d]+|http://[A-Za-z\\d]+|&amp;|&lt;|&gt;|RT|https", "")) %>%
  unnest_tokens(word, text, token = "regex", pattern = reg_words) %>% 
  filter(!word %in% palabras_vacias$word,
       str_detect(tuit, "[a-z]"))

tuits_tokenizados %>%
  count(word, sort=TRUE) %>%
  filter(substr(word, 1, 1) != '#', # omitir hashtags
         substr(word, 1, 1) != '@', # omitir Twitter handles
         n > 950) %>% # parámetro para mostrar las palabas más comunes
  mutate(word = reorder(word, n)) %>% # a partir de quí se lo pasamos a la función para graficar
  ggplot(aes(word, n, fill = word)) +
  geom_bar(stat = 'identity') +
  xlab(NULL) +
  ylab('Conteo de frecuencias') +
  #ggtitle() +
  theme(legend.position="none") +
  coord_flip()
#```

#Para visualizar mejor este análisis, veamos la nube de palabras. Esta herramienta es muy utilizada par aidentificar campañas. Representa, en cierto sentido, el parecer de los usuarios acerca de un tema y sus intereses.

#```{r message=FALSE, error=FALSE, warning=FALSE}

nube_pal <- fullTw %>%
  unnest_tokens(word, tuit) %>%
  mutate(word_stem = wordStem(word, language = "spanish")) %>% # aquí se aplica el stemming que vimos que falla en algunos casos
  anti_join(stopwords_spanish, by = "word") %>%
  filter(!grepl("\\.|http", word))

nube_pal %>% 
  count(word_stem) %>%
  mutate(word_stem = removeNumbers(word_stem)) %>%
  with(wordcloud(word_stem, n, max.words = 100, colors = palette_light()))

#```
#Ahora vamos a ver por pares, qué palabras aparecen juntas con mayor frecuencia. Esto ayuda a identificar tópicos que son acompañados por los intereses de los usuarios. Hemos limitado la cantidad de bigramas, pero este parámetro se puede cambiar.


#```{r message=FALSE, error=FALSE, warning=FALSE}
bigramas <- fullTw %>%
  unnest_tokens(bigram, tuit, token = "ngrams", n = 2) %>% # aquí pueden cambiar n para usar trigramas, etc.
  filter(!grepl("\\.|http", bigram)) %>%
  separate(bigram, c("word1", "word2"), sep = " ") %>%
  filter(!word1 %in% stopwords_spanish$word) %>%
  filter(!word2 %in% stopwords_spanish$word)

conteo_de_bigramas <- bigramas %>%
  count(word1, word2, sort = TRUE)

conteo_de_bigramas %>%
  filter(n > 450) %>%
  ggplot(aes(x = reorder(word1, -n), y = reorder(word2, -n), fill = n)) +
  geom_tile(alpha = 0.8, color = "white") +
  coord_flip() +
  theme_tq() +
  theme(legend.position = "right") +
  theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust = 1)) +
  labs(x = "primera palabra del par",
       y = "segunda palabra del par")
#```
