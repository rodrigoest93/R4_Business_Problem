source("R/funcao_graficos.R")
source("R/temas_graficos.R")

library(magrittr)
library(patchwork)

df_entregas <- readRDS("data/df_entrega.rds")

cores <- data.frame(azul_escuro = "#00398F", azul_medio = "#0790E3", azul_claro = "#14D7FA",
                    verde_bebe = "#07E3D1", verde_claro = "#08FBAC")
cordegrade <- colorRampPalette(c("#00398F", "#08FBAC"))

df_entregas %>%
  dplyr::count(MES_REF) %>%
  ggplot2::ggplot() +
  ggplot2::geom_line(ggplot2::aes(x = MES_REF, y = n), color = cores$verde_claro, size = 0.8) +
  ggplot2::geom_label(ggplot2::aes(x = MES_REF, y = n, label = n),
                      size = 4,  fill = cores$azul_escuro, color = "white", show.legend = FALSE) +
#  ggplot2::labs(title = "Volume de Pedidos por mês") +
  ggplot2::scale_x_date(date_labels = "%b", date_breaks = "1 month") +
  tema_semest_linha()

#ggplot2::ggsave("Imagens/volume_pedidos.png", height = 3, width = 10)

df_entregas %>%
  dplyr::group_by(MES_REF) %>%
  dplyr::summarise(
    Faturamento_total = sum(VALOR_PEDIDO)
  ) %>%
  ggplot2::ggplot() +
  ggplot2::geom_line(ggplot2::aes(x = MES_REF, y = Faturamento_total), color = cores$verde_claro, size = 0.8) +
  ggplot2::geom_label(ggplot2::aes(x = MES_REF, y = Faturamento_total,
                                   label = paste("R$", round(Faturamento_total, 0), sep = " ")),
                      size = 4,  fill = cores$azul_escuro, color = "white", show.legend = FALSE) +
#  ggplot2::labs(title = "Faturamento total por mês") +
  ggplot2::scale_x_date(date_labels = "%b", date_breaks = "1 month") +
  tema_semest_linha()

#ggplot2::ggsave("Imagens/faturamento.png", height = 3, width = 10)

df_entregas %>%
  dplyr::filter(!NOTA_ENTREGA == -1) %>%
  dplyr::group_by(MES_REF) %>%
  dplyr::summarise(
    Media_nota = round(mean(NOTA_ENTREGA, na.rm = TRUE),1)
  ) %>%
  ggplot2::ggplot() +
  ggplot2::geom_line(ggplot2::aes(x = MES_REF, y = Media_nota), color = cores$verde_claro, size = 0.8) +
  ggplot2::geom_label(ggplot2::aes(x = MES_REF, y = Media_nota, label = Media_nota),
                      size = 4,  fill = cores$azul_escuro, color = "white", show.legend = FALSE) +
#  ggplot2::labs(title = "Media de Avaliação por mês") +
  ggplot2::scale_x_date(date_labels = "%b", date_breaks = "1 month") +
  tema_semest_linha()

#ggplot2::ggsave("Imagens/avaliacao.png", height = 3, width = 10)

df_map <- readRDS("data/df_map.rds")

df_map %>%
  ggplot2::ggplot() +
  ggplot2::geom_sf(ggplot2::aes(fill = qtd_entrega), size=.15) +
  ggplot2::geom_sf_text(ggplot2::aes(label = abbrev_state, color = qtd_entrega),
                        size = 4, show.legend = FALSE) +
#  ggplot2::labs(title = "Volume de entregas por estado") +
  ggplot2::theme_void() +
  ggplot2::scale_fill_gradient(name = "Volume de Entregas",
                               low = cores$verde_claro, high = cores$azul_escuro, na.value = "#d6d2d2") +
  ggplot2::scale_color_gradient(low = cores$azul_escuro, high = "white", na.value = "black")

#ggplot2::ggsave("Imagens/mapa.png", height = 10, width = 10)


df_entregas %>%
  grafico_barras_2(CLASSE, "", "")

ggplot2::ggsave("Imagens/barras_classe.png", height = 10, width = 10)

df_entregas %>%
  grafico_barras(DIA, "Dias da semana", "Percentual por dia da semana")

ggplot2::ggsave("Imagens/barras_DIA.png", height = 10, width = 10)


