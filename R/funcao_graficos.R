#### carregando tema ----
grafico_barras <- function(data, x, Eixox, Titulo) {
  data %>%
    dplyr::count({{x}}) %>%
      dplyr::mutate(
        percentual = scales::percent(n/sum(n),accuracy = .1)
      ) %>%
        ggplot2::ggplot(ggplot2::aes(x = {{x}}, y = n)) +
          ggplot2::geom_col(fill = cores$azul_escuro) +
            ggplot2::geom_label(ggplot2::aes(x = {{x}}, y = n, label = percentual),
                                fill = cores$verde_claro, color = cores$azul_escuro) +
              ggplot2::labs(x = Eixox, title = Titulo) +
                tema_semest_barra_x()

}

