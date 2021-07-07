
df_diamante <- dados::diamante
library(tidyverse)
#glimpse(df_diamante)

# dplyr+ ----
# across

df_diamante %>%
  summarise(
    across(
      .cols = c(preco, quilate, profundidade),
      .fns = mean,
      na.rm = TRUE
    )
  )

df_diamante %>%
  group_by(corte) %>%
    summarise(
      across(
        .cols = c(preco, quilate, profundidade),
        .fns = mean,
        na.rm = TRUE
      )
    )

# stringr ----
library(stringr)

# tamamho
str_length(df_diamante$corte)

df_diamante %>%
  filter(str_length(corte) == 5)

# maiuscula
df_bebes <- dados::bebes
str_to_upper(df_bebes$nome)

# minuscula
str_to_lower(df_bebes$nome)

# substituir
df_bebes %>%
  filter(nome == "Ed") %>%
  mutate(
    nome = str_replace(nome ,pattern = "Ed",replacement = "kkk")
  )

# remover
df_bebes %>%
  filter(nome == "Ed") %>%
    mutate(
      nome = str_remove(nome, pattern = "d")
    )

# separar

vetor <- c("Rodrigo | Miguel | Alice | Thiago")
str_split(vetor, pattern = "|", )

# remove espaços
vetor_2 <- c("    Rodrigo     ")
str_squish(vetor_2)

#extra
stringi::stri_trans_general("MûnìLã", "Latin-ASCII")


# ggplo2+ ----
library(ggplot2)

df_diamante %>%
  count(cor) %>%
    ggplot(aes(x = cor, y = n)) +
      geom_col(show.legend = FALSE, fill = "tomato") +
        geom_label(aes(x = cor, y = n, label = n, fill = "red"),show.legend = FALSE) +
        theme(
        axis.title = element_blank(),
        axis.text.y = element_blank(),
        panel.background = element_blank(),
        panel.border = element_blank(),
        panel.grid = element_line(color = "red"),
        axis.ticks = element_line(color = "blue")
        )

# function theme
tema_semest <- function(){
  theme(
    axis.title = element_blank(),
    axis.text.y = element_blank(),
    panel.background = element_blank(),
    panel.border = element_blank(),
    panel.grid = element_line(color = "red"),
    axis.ticks = element_line(color = "blue")
  )
}

df_diamante %>%
  count(corte) %>%
    ggplot(aes(x = corte, y = n)) +
      geom_col(show.legend = FALSE, fill = "tomato") +
        geom_label(aes(x = corte, y = n, label = n,
                       fill = "red"),show.legend = FALSE) +
          tema_semest()


#function ggplot

grafico_barra <- function(df, x) {
  df %>%
    count({{x}}) %>%
      ggplot(aes(x = {{x}}, y = n)) +
        geom_col(fill = "tomato") +
          tema_semest()
}

df_diamante %>%
  grafico_barra(corte)

df_diamante %>%
  grafico_barra(cor)

#geobr e geom_sf
library(geobr)
base_estados <- read_state(code_state = "PA")

base_estados %>%
  ggplot() +
    geom_sf()

# lubridate ----
library(lubridate)
today()

now()

minute(now())

wday(now(), label = TRUE, abbr = TRUE)

month(today(), label = TRUE, abbr = FALSE)

year(today())

