
df_avioes <- dados::avioes

# dplyr+ ----


# across


#stringr
library(stringr)

# tamamho
str_length()

# maiuscula
str_to_upper()

# minuscula
str_to_lower()

# substituir
str_replace(pattern = ,replacement = )

# remover
str_remove()

# seoparar
str_split()

# remove espaços
str_squish()

#extra
#stringi::stri_trans_general(, "Latin-ASCII")


# ggplo2+ ----
library(ggplot2)

# function theme
theme(

)


#function ggplot


#geobr e geom_sf
library(geobr)
#base_estados <- read_state(code_state = "PA")

# base_estados %>%
#   ggplot() +
#     geom_sf()

# lubridate ----
library(lubridate)

df_bebes <- dados::bebes

minute()

wday()

month()

year()

today()

