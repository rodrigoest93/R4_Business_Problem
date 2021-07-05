#### temas de gráficos ----

tema_semest_linha <- function(){
  ggplot2::theme(
    panel.border = ggplot2::element_blank(),
    panel.spacing.x = ggplot2::element_blank(),
    panel.grid.major.y = ggplot2::element_blank(),
    panel.grid.major.x = ggplot2::element_line(colour = "grey", size = 0.1),
    panel.background = ggplot2::element_blank(),
    axis.text.y = ggplot2::element_blank(),
    axis.title = ggplot2::element_blank(),
    axis.ticks = ggplot2::element_blank()

  )
}

tema_semest_barra_x <- function(){
  ggplot2::theme(
    panel.border = ggplot2::element_blank(),
    panel.spacing.x = ggplot2::element_blank(),
    panel.grid.major.y = ggplot2::element_blank(),
    panel.grid.major.x = ggplot2::element_blank(),
    panel.background = ggplot2::element_blank(),
    axis.text.y = ggplot2::element_blank(),
    axis.title.y = ggplot2::element_blank(),
    axis.ticks = ggplot2::element_blank()
  )
}

