# pacote utilizado
library(tidyverse)

# carregar base de dados ----
df <- readxl::read_excel("data-raw/BASE_ENTREGAS.xlsx")

# estrutura das variáveis ----
glimpse(df)

# detalhamento
library(skimr)

# mais informacões sobre as avriáveis
df %>%
  skim() %>%
    view()


# tipos de pagamento ----
df %>%
  count(TIPO_PAGAMENTO)

# reclassificando tipo de pagamento
df <- df %>%
  mutate(
    TIPO_PAGAMENTO = case_when(
      TIPO_PAGAMENTO == "Cartão de Crédito" ~ "Crédito",
      TIPO_PAGAMENTO == "Crédito" ~ "Crédito",
      TIPO_PAGAMENTO == "Cartão de Débito" ~ "Débito",
      TIPO_PAGAMENTO == "Débito" ~ "Débito",
      TIPO_PAGAMENTO == "Dinheiro" ~ "Dinheiro",
      TRUE ~ "Não informado"
    )
  )

# vendo com percentual - Relembrar
library(scales)

df %>%
  count(TIPO_PAGAMENTO) %>%
    mutate(
      percentual = n/sum(n),
      percentual = percent(percentual, accuracy = .1)
    )

# tipos de entrega ----
df %>%
  count(TIPO_ENTREGA) %>%
    mutate(
      percentual = n/sum(n),
      percentual = percent(percentual, accuracy = .1)
    )


# estados ----
df %>%
  count(ESTADO)

# nota da entrega ----
df %>%
  count(NOTA_ENTREGA) %>%
    mutate(
      percentual = n/sum(n),
      percentual = percent(percentual, accuracy = .2)
    )

# tranformar nota da entrega
df <- df %>%
  mutate(
    CLASSE = case_when(
      NOTA_ENTREGA >= 1 & NOTA_ENTREGA <= 3 ~ "Ruim",
      NOTA_ENTREGA == 4 ~ "Medio",
      NOTA_ENTREGA == 5 ~ "Bom",
      TRUE ~ "Sem Informação"
    ),
    CLASSE = factor(CLASSE, levels = c("Bom", "Medio", "Ruim", "Sem Informação"))
  )

df %>%
  count(CLASSE)

# data do pedido ---- VER
str(df$DATA_PEDIDO)

library(lubridate)

df <- df %>%
  mutate(
    MES_REF = paste(stringr::str_sub(DATA_PEDIDO, start = 1, end = 7), "-01", sep = ""),
    MES_REF = as.Date(MES_REF),
    MES = month(DATA_PEDIDO, label = TRUE, abbr = TRUE),
    DIA = wday(DATA_PEDIDO, label = TRUE, abbr = TRUE),
    TURNO = case_when(
      hour(DATA_PEDIDO) < 6 ~ "Madrugada",
      hour(DATA_PEDIDO) < 12 ~ "Manhã",
      hour(DATA_PEDIDO) < 18 ~ "Tarde",
      TRUE ~ "Noite"
    ),
    TURNO = factor(TURNO, levels = c("Manhã", "Tarde", "Noite", "Madrugada"))
  )

#### base para o mapa ----
estados <- geobr::read_state()

estados <- estados %>%
  left_join(
    (
      df %>%
        group_by(ESTADO) %>%
        summarise(
          qtd_entrega = n(),
          faturamento = sum(VALOR_PEDIDO, na.rm = TRUE),
          nota_media = mean(NOTA_ENTREGA, na.rm = TRUE)
        )
    ),
    by = c("abbrev_state" = "ESTADO")
  ) %>%
  mutate(
    contem_estado = case_when(
      is.na(qtd_entrega) ~ "NÃO",
      TRUE ~ "SIM"
    )
  )

write_rds(df, "data/df_entrega.rds")
write_rds(estados, "data/df_map.rds")
