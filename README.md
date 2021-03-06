Resolvendo problema de Negócio
================
Rodrigo Almeida
07/07/2021

``` r
knitr::opts_chunk$set(echo = TRUE, message=FALSE, warning=FALSE, fig.align='center')
# pacotes utilizados
library(magrittr)
library(patchwork)
```

## Introdução

Esta análise dfoi destinada ao Curso de R para problemas de negócio,
ministrado na Semana da Estatística da Universidade Federal do Pará.
Para Acesso ao Documento no RPubs, [clique
aqui](https://rpubs.com/rodrigoest93/R4BusinessProblem).

## Demandante

Recebemos uma demanda de uma empresa de delivery que passa por um
momento de crescimento e também de melhoria no processo de análise de
dados. O time de Marketing fez um investimento em comerciais, para que a
empresa ficasse mais conhecida e consequentemente aumentasse o número de
pedidos. O Gestor da área entra em contato com nossa equipe para que
possamos ajudá-los no direcionamento de algumas medidas.

## Entendendo o Problema

Há um aumento na quantidade de entregas pelo APP da empresa, e
consequentemente um decaimento na avaliação dos clientes. Deseja-se
descobrir os motivos do decaimento e sugerir alguma melhoria baseada em
dados.

**Informações Importantes**

  - Todos os pedidos analisados são de 2017

  - As notas de avaliação variam de 1 a 5, sendo -1 os clientes que não
    responderam e NA os clientes que não receberam a avaliação

  - Existe uma classificação de acordo com as notas dos clientes, que
    seguem as seguintes regras:
    
      - Ruim: Notas entre 1 e 3
      - Medio: Notas igual a 4
      - Bom: Notas igual a 5

  - Houve um atualização no portal de entregas em meados de Junho/Julho

  - Houve um investimento em comeciais para a empresa ficar mais
    conhecida em meados de Julho/Agora

## Conhecendo a base

**Variáveis**

``` r
df_entregas <- readRDS("data/df_entrega.rds")

#paleta de cores
source("R/temas_graficos.R")
cores <- data.frame(azul_escuro = "#00398F", azul_medio = "#0790E3", azul_claro = "#14D7FA",
                       verde_bebe = "#07E3D1", verde_claro = "#08FBAC")
cordegrade <- colorRampPalette(c("#00398F", "#08FBAC"))

# caracteres
df_entregas %>%
  dplyr::select(where(is.character)) %>% 
    skimr::skim() %>%
      knitr::kable(caption = "Caractéres", format = "pipe")
```

| skim\_type | skim\_variable  | n\_missing | complete\_rate | character.min | character.max | character.empty | character.n\_unique | character.whitespace |
| :--------- | :-------------- | ---------: | -------------: | ------------: | ------------: | --------------: | ------------------: | -------------------: |
| character  | TIPO\_PAGAMENTO |          0 |              1 |             6 |            13 |               0 |                   4 |                    0 |
| character  | TIPO\_ENTREGA   |          0 |              1 |             7 |             7 |               0 |                   3 |                    0 |
| character  | ESTADO          |          0 |              1 |             2 |             2 |               0 |                   5 |                    0 |

Caractéres

``` r
# Fatores
df_entregas %>%
  dplyr::select(where(is.factor)) %>% 
    skimr::skim() %>%
      knitr::kable(caption = "Fatores", format = "pipe")
```

| skim\_type | skim\_variable | n\_missing | complete\_rate | factor.ordered | factor.n\_unique | factor.top\_counts                         |
| :--------- | :------------- | ---------: | -------------: | :------------- | ---------------: | :----------------------------------------- |
| factor     | CLASSE         |          0 |              1 | FALSE          |                4 | Bom: 5573, Sem: 4273, Rui: 687, Med: 641   |
| factor     | MES            |          0 |              1 | TRUE           |               10 | Out: 1734, Set: 1731, Jun: 1341, Ago: 1305 |
| factor     | DIA            |          0 |              1 | TRUE           |                7 | Sáb: 3259, Sex: 2342, Dom: 2056, Qui: 1269 |
| factor     | TURNO          |          0 |              1 | FALSE          |                4 | Noi: 5118, Tar: 4460, Man: 1074, Mad: 522  |

Fatores

``` r
# Quantittivas
df_entregas %>%
  dplyr::select(where(is.numeric)) %>% 
    skimr::skim() %>%
      knitr::kable(caption = "Quantitativas", format = "pipe")
```

| skim\_type | skim\_variable | n\_missing | complete\_rate | numeric.mean |  numeric.sd | numeric.p0 | numeric.p25 | numeric.p50 | numeric.p75 | numeric.p100 | numeric.hist |
| :--------- | :------------- | ---------: | -------------: | -----------: | ----------: | ---------: | ----------: | ----------: | ----------: | -----------: | :----------- |
| numeric    | ID\_PEDIDO     |          0 |       1.000000 | 1.884246e+05 | 58540.23929 |       45.0 |   117767.25 |  210567.500 |  233436.000 |   256243.000 | ▁▁▃▂▇        |
| numeric    | VALOR\_PEDIDO  |          0 |       1.000000 | 1.007173e+02 |   397.88371 |        2.2 |       29.88 |      35.904 |      59.488 |     6894.528 | ▇▁▁▁▁        |
| numeric    | ID\_ENTREGADOR |          0 |       1.000000 | 3.177895e+01 |    14.06820 |       17.0 |       21.00 |      26.000 |      39.000 |       74.000 | ▇▃▂▁▁        |
| numeric    | NOTA\_ENTREGA  |       3897 |       0.651244 | 4.368421e+00 |     1.47981 |      \-1.0 |        5.00 |       5.000 |       5.000 |        5.000 | ▁▁▁▁▇        |

Quantitativas

``` r
# data
df_entregas %>%
  dplyr::select(where(lubridate::is.POSIXct)) %>% 
    skimr::skim() %>%
      knitr::kable(caption = "Data", format = "pipe")
```

| skim\_type | skim\_variable | n\_missing | complete\_rate | POSIXct.min         | POSIXct.max         | POSIXct.median      | POSIXct.n\_unique |
| :--------- | :------------- | ---------: | -------------: | :------------------ | :------------------ | :------------------ | ----------------: |
| POSIXct    | DATA\_PEDIDO   |          0 |              1 | 2017-01-01 10:11:01 | 2017-10-31 23:42:43 | 2017-07-13 22:01:51 |             11138 |

Data

## Primeiras Análises

**Análise do Cenário da empresa**

Agora faremos as primeiras análises da nossa base, expondo o cenário que
temos da mesma:

``` r
# quantiddde de pedidos por mes
g1 <- df_entregas %>% 
  dplyr::count(MES_REF) %>% 
    ggplot2::ggplot() +
      ggplot2::geom_line(ggplot2::aes(x = MES_REF, y = n), color = cores$verde_claro, size = 0.8) +
        ggplot2::geom_label(ggplot2::aes(x = MES_REF, y = n, label = n),
                            size = 2.5,  fill = cores$azul_escuro, color = "white", show.legend = FALSE) +
          ggplot2::labs(title = "Volume de Pedidos por mês") +
            ggplot2::scale_x_date(date_labels = "%b", date_breaks = "1 month") +
              tema_semest_linha()


# faturamento por mês
g2 <- df_entregas %>% 
  dplyr::group_by(MES_REF) %>%
    dplyr::summarise(
      Faturamento_total = sum(VALOR_PEDIDO)
    ) %>% 
      ggplot2::ggplot() +
        ggplot2::geom_line(ggplot2::aes(x = MES_REF, y = Faturamento_total), color = cores$verde_claro, size = 0.8) +
          ggplot2::geom_label(ggplot2::aes(x = MES_REF, y = Faturamento_total, 
                                           label = paste("R$", round(Faturamento_total, 0), sep = " ")),
                              size = 2.5,  fill = cores$azul_escuro, color = "white", show.legend = FALSE) +
            ggplot2::labs(title = "Faturamento total por mês") +
              ggplot2::scale_x_date(date_labels = "%b", date_breaks = "1 month") +
                tema_semest_linha()


# nota avaliacao poe mes
g3 <- df_entregas %>%
  dplyr::filter(!NOTA_ENTREGA == -1) %>%
    dplyr::group_by(MES_REF) %>%
      dplyr::summarise(
        Media_nota = round(mean(NOTA_ENTREGA, na.rm = TRUE),1)
      ) %>% 
      ggplot2::ggplot() +
        ggplot2::geom_line(ggplot2::aes(x = MES_REF, y = Media_nota), color = cores$verde_claro, size = 0.8) +
          ggplot2::geom_label(ggplot2::aes(x = MES_REF, y = Media_nota, label = Media_nota),
                              size = 2.5,  fill = cores$azul_escuro, color = "white", show.legend = FALSE) +
            ggplot2::labs(title = "Media de Avaliação por mês") +
              ggplot2::scale_x_date(date_labels = "%b", date_breaks = "1 month") +
                tema_semest_linha()

# entregas por estado
df_map <- readRDS("data/df_map.rds")

g4 <- df_map %>% 
  ggplot2::ggplot() +
    ggplot2::geom_sf(ggplot2::aes(fill = qtd_entrega), size=.15) +
      ggplot2::geom_sf_text(ggplot2::aes(label = abbrev_state, color = qtd_entrega),
                  size = 2, show.legend = FALSE) +
        ggplot2::labs(title = "Volume de entregas por estado") +
          ggplot2::theme_void() +
            ggplot2::scale_fill_gradient(name = "Volume de Entregas",
                                         low = cores$verde_claro, high = cores$azul_escuro, na.value = "#d6d2d2") +
              ggplot2::scale_color_gradient(low = cores$azul_escuro, high = "white", na.value = "black")

g1 / g3 / g2 
```

<img src="README_files/figure-gfm/unnamed-chunk-2-1.png" style="display: block; margin: auto;" />

``` r
g4
```

<img src="README_files/figure-gfm/unnamed-chunk-2-2.png" style="display: block; margin: auto;" />

  - A partir de Junho, há um aumento considerável na quantidade de
    entregas, e a partir de Setembro, há um aumento repentino na
    quantidade de entregas

  - O faturamento da empresa está crescendo no decorrer dos meses, tendo
    um maior destaque no mês de Julho

  - Há uma queda brusca mês de Julho quanto as avaliações dos clientes

  - O Estado de São Paulo é onde ocorre a maioria das entregas, sendo
    que a empresa atua em outros quatro Estados (Ceará, Minas Gerais,
    Paraná e Rio de Janeiro)

Continuando as análises, vamos agora tratar de questões de processos de
entrega:

``` r
source("R/funcao_graficos.R")

#percentual notas de entrega
g1 <- df_entregas %>%
  dplyr::mutate(
    NOTA_ENTREGA = as.factor(NOTA_ENTREGA)
  ) %>%
  grafico_barras(data = ., NOTA_ENTREGA, "Notas", "Percentual por nota de avaliação")


# percentual por classe
g2 <- df_entregas %>% 
  grafico_barras(CLASSE, "Classes", " Percentua por Classe")  


# percentual por meio de pagamento
g3 <- df_entregas %>% 
  grafico_barras(TIPO_PAGAMENTO, "Meios de Pagamentos", "Percentual por meio de pagamento")

# turno da entrega
g4 <- df_entregas %>% 
  grafico_barras(TURNO, "Turnos", "Percentual por turnos de entrega")

# tipo de entrega
g5 <- df_entregas %>% 
  grafico_barras(TIPO_ENTREGA, "Tipo de Entrega", "Percentual por tipo de entrega")

# dia da semana 
g6 <- df_entregas %>% 
  grafico_barras(DIA, "Dias da semana", "Percentual por dia da semana")


(g1 + g2) / (g3 + g4) / (g5 + g6)
```

<img src="README_files/figure-gfm/unnamed-chunk-3-1.png" style="display: block; margin: auto;" />

Já conseguimos enxergar alguns ponstos de atenção no processo de
entregas, são estes:

  - Existe um percentual muito alto de pedidos que não receberam a
    avaliação após a entrega do produto

  - A maioria dos clientes respondentes classifica a entrega como Boa

  - Existe um grande percentual de meios de pagamentos não informados

  - Os turnos da tarde e noite são os que possuem maior volume de
    entrega

  - Quase 90% dos clientes **recebe** o pedido, sendo este o **tipo de
    entrega** mais frequente

  - Sexta, Sábado e Domingo são os dias de maior volume de entregas

Agora vamos tentar aprofundar nossa análise atacando os pontos
levantados anteriormente:

**Os problemas da não informação de avaliação e métodos de pagamento:**

``` r
df_entregas %>%
  dplyr::filter(CLASSE == 'Sem Informação') %>%
    grafico_barras(MES_REF, "Meses", "Percentual de pedidos que não receberam avaliação por mês") +
      ggplot2::scale_x_date(date_labels = "%b", date_breaks = "1 month")
```

<img src="README_files/figure-gfm/unnamed-chunk-4-1.png" style="display: block; margin: auto;" />

``` r
df_entregas %>%
  dplyr::filter(CLASSE == 'Sem Informação') %>%
    dplyr::count(ESTADO, MES) %>%
      ggplot2::ggplot(ggplot2::aes(x = MES, y = n)) +
        ggplot2::geom_col(ggplot2::aes(fill = ESTADO), show.legend = FALSE) +
          ggplot2::scale_fill_manual(values = cordegrade(5)) +
            ggplot2::theme(
              panel.background = ggplot2::element_blank(),
              panel.border = ggplot2::element_blank(),
              axis.title.y = ggplot2::element_blank(),
              axis.text.y = ggplot2::element_blank(),
              axis.ticks.y = ggplot2::element_blank()
            ) +
              ggplot2::facet_wrap(~ESTADO)
```

<img src="README_files/figure-gfm/unnamed-chunk-4-2.png" style="display: block; margin: auto;" />

``` r
df_entregas %>%
  dplyr::filter(CLASSE == 'Sem Informação') %>%
    dplyr::group_by(TIPO_PAGAMENTO, MES_REF) %>%
      dplyr::summarise(
        Quantidade = dplyr::n()
      ) %>%
        ggplot2::ggplot() +
          ggplot2::geom_line(ggplot2::aes(x = MES_REF, y = Quantidade, group = TIPO_PAGAMENTO, color = TIPO_PAGAMENTO)) +
            ggplot2::scale_color_manual(name = "Tipo de Pagamento",
                          values = cordegrade(4)) +
              ggplot2::scale_x_date(date_labels = "%b", date_breaks = "1 month") +
                tema_semest_linha()
```

<img src="README_files/figure-gfm/unnamed-chunk-4-3.png" style="display: block; margin: auto;" />

``` r
# O plotly não funcionou na versão do git.md
#  plotly::ggplotly(height = 250, width = 1000)

df_entregas %>%
  dplyr::filter(CLASSE == 'Sem Informação') %>%
    dplyr::group_by(TURNO, MES_REF) %>%
      dplyr::summarise(
        Quantidade = dplyr::n()
      ) %>%
        ggplot2::ggplot() +
          ggplot2::geom_line(ggplot2::aes(x = MES_REF, y = Quantidade, group = TURNO, color = TURNO)) +
            ggplot2::scale_color_manual(name = "Turno",
                          values = cordegrade(4)) +
              ggplot2::scale_x_date(date_labels = "%b", date_breaks = "1 month") +
                tema_semest_linha()
```

<img src="README_files/figure-gfm/unnamed-chunk-4-4.png" style="display: block; margin: auto;" />

``` r
# O plotly não funcionou na versão do git.md
#  plotly::ggplotly(height = 250, width = 1000)

df_entregas %>%
  dplyr::filter(CLASSE == 'Sem Informação') %>%
    dplyr::group_by(DIA, MES_REF) %>%
      dplyr::summarise(
        Quantidade = dplyr::n()
      ) %>%
        ggplot2::ggplot() +
          ggplot2::geom_line(ggplot2::aes(x = MES_REF, y = Quantidade, group = DIA, color = DIA)) +
            ggplot2::scale_color_manual(name = "Dia", values = cordegrade(7)) +
              ggplot2::scale_x_date(date_labels = "%b", date_breaks = "1 month") +
                tema_semest_linha()
```

<img src="README_files/figure-gfm/unnamed-chunk-4-5.png" style="display: block; margin: auto;" />

``` r
# O plotly não funcionou na versão do git.md
# plotly::ggplotly(height = 350, width = 1000)
```

Com os gráficos acima pudemos perceber:

  - A partir do mês de Junho, onde houve atualização de plataforma, o
    número de pedidos que não receberam avaliações cresceu

  - Os pedidos sem informação de pagamento foram resolvidos em Julho

  - Em momento e local de maior quantidade de pedidos, são onde se
    concentram também os volumes de pedidos sem recebeimento de
    avaliação, que são os turnos da tarde e noite, nos dias sexta,
    sábado e domingo e no estado de São Paulo.

**Avaliando os entregadores**

Agora vamos avaliar os indicadores quanto aos entregadores:

Ao todo, nossa base possui 51 entregadores.

``` r
df_entregas %>%
  dplyr::distinct(ID_ENTREGADOR, ESTADO) %>%
    dplyr::count(ESTADO) %>%
      dplyr::mutate(
        ESTADO = forcats::fct_reorder(ESTADO, n)
      ) %>%
        ggplot2::ggplot(ggplot2::aes(x = ESTADO, y = n)) +
          ggplot2::geom_col(fill = cores$azul_escuro) +
            ggplot2::geom_label(ggplot2::aes(x = ESTADO, y = n, label = n), fill = cores$verde_claro, color = cores$azul_escuro) +
              ggplot2::labs(x = "Estados", title  = "Quantidade de Entregadores por estado") +
                tema_semest_barra_x()
```

<img src="README_files/figure-gfm/unnamed-chunk-5-1.png" style="display: block; margin: auto;" />

``` r
df_entregas %>%
  dplyr::distinct(ID_ENTREGADOR, ESTADO) %>%
    dplyr::count(ESTADO) %>%
      dplyr::left_join(
        df_entregas %>%
          dplyr::group_by(ESTADO) %>%
            dplyr::summarise(
              media_nota = round(mean(NOTA_ENTREGA, na.rm = TRUE),1)
            ), by = c("ESTADO" = "ESTADO")
) %>%
              dplyr::mutate(
              ESTADO = forcats::fct_reorder(ESTADO, dplyr::desc(n))
            ) %>%
          ggplot2::ggplot(ggplot2::aes(x = media_nota, y = n, color = ESTADO)) +
            ggplot2::geom_point(size = 5) +
              ggplot2::theme_minimal() +
                ggplot2::labs(x = "Media da Nota de Avaliação da Entrega", y = "Quantidade de entregadores", title = "Quantidade de entregadores vs Média Nota Avaliação, por estado") +
                  ggplot2::scale_color_manual(values = cordegrade(5))
```

<img src="README_files/figure-gfm/unnamed-chunk-5-2.png" style="display: block; margin: auto;" />

Em relação a quantidade de entregadores por cada estado:

  - Não há uma relação evidente quanto entre a quantidade de
    entregadores e a média de nota de avaliação por estado

Porém, vamo verificar a quantidade de entregadores em relação ao volume
de pedidos de cada estado

``` r
df_entregas %>%
  dplyr::distinct(ID_ENTREGADOR, ESTADO) %>%
    dplyr::group_by(ESTADO) %>%
      dplyr::summarise(
        Qtd_entregadores = dplyr::n()
      ) %>%
dplyr::left_join(
      (df_entregas %>%
        dplyr::group_by(ESTADO) %>%
          dplyr::summarise(
            Vol_entregas = dplyr::n(),
            media_nota = round(mean(NOTA_ENTREGA, na.rm = TRUE),1)
          )), by = c("ESTADO" = "ESTADO")
) %>%
            dplyr::mutate(
              Media_entregador = round(Vol_entregas/Qtd_entregadores,1)
            ) %>%
              dplyr::arrange(dplyr::desc(Media_entregador)) %>% knitr::kable(format = "pipe")
```

| ESTADO | Qtd\_entregadores | Vol\_entregas | media\_nota | Media\_entregador |
| :----- | ----------------: | ------------: | ----------: | ----------------: |
| SP     |                24 |          7800 |         4.4 |             325.0 |
| RJ     |                11 |          2297 |         4.3 |             208.8 |
| MG     |                10 |           759 |         4.1 |              75.9 |
| PR     |                 3 |           164 |         4.4 |              54.7 |
| CE     |                 3 |           154 |         4.5 |              51.3 |

``` r
df_entregas %>%
  dplyr::distinct(ID_ENTREGADOR, ESTADO) %>%
    dplyr::group_by(ESTADO) %>%
      dplyr::summarise(
        Qtd_entregadores = dplyr::n()
      ) %>%
dplyr::left_join(
      (df_entregas %>%
        dplyr::filter(!NOTA_ENTREGA == -1) %>%
          dplyr::group_by(ESTADO) %>%
            dplyr::summarise(
              Vol_entregas = dplyr::n(),
              media_nota = round(mean(NOTA_ENTREGA, na.rm = TRUE),1)
            )), by = c("ESTADO" = "ESTADO")
) %>%
            dplyr::mutate(
              Media_entregador = round(Vol_entregas/Qtd_entregadores,1),
              ESTADO = forcats::fct_reorder(ESTADO, dplyr::desc(Media_entregador))
            ) %>%
          ggplot2::ggplot(ggplot2::aes(x = media_nota, y = Media_entregador, color = ESTADO)) +
            ggplot2::geom_point(size = 5) +
              ggplot2::theme_minimal() +
                ggplot2::labs(x = "Media da Nota de Avaliação da Entrega", y = "Media por Entregador", title = "Media por entregador vs Média Nota Avaliação, por estado") +
                  ggplot2::scale_color_manual(values = cordegrade(5))
```

<img src="README_files/figure-gfm/unnamed-chunk-6-1.png" style="display: block; margin: auto;" />

Agora já começa a fazer sentido o fato de que Ceará e Paraná possuem as
menores médias de entregas por entregadores (51.3 e 54.7,
respectivamente) e as maiores médias de avaliações, enquanto Minas
Gerais e Rio de Janeiro acontece o contrário. O fato a ser estudado é
São Paulo, pois possui a maior média de entregadores e a segunda maior
média de nota, além de ser o estado onde de concentram a maioria dos
pedidos. Dado isso, vamos olhar a evolução de notas de São Paulo:

``` r
df_entregas %>%
  dplyr::filter(ESTADO == "SP", !NOTA_ENTREGA == -1) %>%
    dplyr::group_by(MES_REF) %>%
      dplyr::summarise(
        Media_nota = round(mean(NOTA_ENTREGA, na.rm = TRUE),1)
      ) %>%
        ggplot2::ggplot(ggplot2::aes(x = MES_REF, y = Media_nota)) +
          ggplot2::geom_line(color = cores$azul_escuro) +
            ggplot2::geom_label(ggplot2::aes(x = MES_REF, y = Media_nota, label = Media_nota), fill = cores$verde_claro, color = cores$azul_escuro) +
              ggplot2::scale_x_date(date_labels = "%b", date_breaks = "1 month") +
                tema_semest_linha()
```

<img src="README_files/figure-gfm/unnamed-chunk-7-1.png" style="display: block; margin: auto;" />

São Paulo segue a tendência da base como um todo, ou, na verdade, puxa
essa tendência devido ser o principal estado quanto ao volume de
entregas. Se olharmos bem, São Paulo é responsável por um grande parte
do faturamento, por isso merece uma atenção especial na análise:

``` r
df_entregas %>%
  dplyr::mutate(
    Estado_SP = dplyr::case_when(
      ESTADO == "SP" ~ "SP",
      TRUE ~ "OUTROS"
    )
  ) %>%
    dplyr::group_by(Estado_SP, MES_REF) %>%
      dplyr::summarise(
        Faturamento_total = sum(VALOR_PEDIDO, na.rm = TRUE)
      ) %>%
        ggplot2::ggplot(ggplot2::aes(x = MES_REF, y = Faturamento_total, fill = Estado_SP)) +
          ggplot2::geom_col() +
            ggplot2::xlab("Meses") +
              ggplot2::scale_x_date(date_labels = "%b", date_breaks = "1 month") +
                tema_semest_barra_x() +
                  ggplot2::scale_fill_manual(name = "Estado", values = c(cores$azul_medio, cores$verde_bebe))
```

<img src="README_files/figure-gfm/unnamed-chunk-8-1.png" style="display: block; margin: auto;" />

Sabendo da grande representatividade no faturamento, vamos analisar onde
está o problema da baixa de notas em São Paulo:

**Entregadores**

Vimos que a média de entrega por entregadores não foi um quesito
relevante quando analisado com outros estados, porém vamos verificar a
média das notas por entregadores pra verificar se existe relevância:

``` r
df_entregas %>%
  dplyr::filter(ESTADO == "SP", !NOTA_ENTREGA == -1) %>%
    dplyr::group_by(ID_ENTREGADOR) %>%
      dplyr::summarise(
        media_nota = round(mean(NOTA_ENTREGA, na.rm = TRUE),1)
      ) %>%
        dplyr::mutate(
          ID_ENTREGADOR = as.factor(ID_ENTREGADOR),
          ID_ENTREGADOR = forcats::fct_reorder(ID_ENTREGADOR, media_nota)
        ) %>%
          ggplot2::ggplot(ggplot2::aes(x = ID_ENTREGADOR, y = media_nota, fill = ID_ENTREGADOR)) +
            ggplot2::geom_col(show.legend = FALSE) +
              ggplot2::geom_label(ggplot2::aes(x = ID_ENTREGADOR, y = media_nota, label = media_nota), size = 3.5, show.legend = FALSE) +
                ggplot2::theme_minimal() +
                  ggplot2::scale_fill_manual(values = cordegrade(24)) +
                    ggplot2::coord_flip()
```

<img src="README_files/figure-gfm/unnamed-chunk-9-2.png" style="display: block; margin: auto;" />

``` r
df_entregas %>%
  dplyr::filter(ESTADO == "SP", !NOTA_ENTREGA == -1) %>%
    dplyr::group_by(ID_ENTREGADOR, MES_REF) %>%
      dplyr::summarise(
        media_nota = round(mean(NOTA_ENTREGA, na.rm = TRUE),1),
        qtd_pedidos = dplyr::n()
      ) %>%
        ggplot2::ggplot(ggplot2::aes(x = media_nota, y = qtd_pedidos, color = qtd_pedidos)) +
          ggplot2::geom_point(size = 4) +
            ggplot2::scale_color_gradient(name = "Quantidade de Pedidos",low = cores$azul_escuro, high = cores$verde_claro) +
              ggplot2::labs(title = 'Data: {frame_time}') +
                ggplot2::theme_minimal() +
                  gganimate::transition_time(MES_REF)
```

<img src="README_files/figure-gfm/unnamed-chunk-9-1.gif" style="display: block; margin: auto;" />

Vamos separar os top 5 melhores e 5 piores entregadores pra enchegar o
comportamento dos mesmos:

``` r
entregadores <- rbind(
(df_entregas %>%
  dplyr::filter(!NOTA_ENTREGA == -1) %>%
    dplyr::group_by(ID_ENTREGADOR) %>%
      dplyr::summarise(
        media_nota = mean(NOTA_ENTREGA, na.rm = TRUE),
        qtd = dplyr::n()
      ) %>%
      dplyr::filter(qtd > 30) %>%
        dplyr::top_n(5, wt = media_nota) %>%
          dplyr::mutate(
            tipo = "top"
          ) %>%
            dplyr::select(ID_ENTREGADOR, tipo)),

(df_entregas %>%
  dplyr::filter(!NOTA_ENTREGA == -1) %>%
    dplyr::group_by(ID_ENTREGADOR) %>%
      dplyr::summarise(
        media_nota = mean(NOTA_ENTREGA, na.rm = TRUE),
        qtd = dplyr::n()
      ) %>%
      dplyr::filter(qtd > 30) %>%
        dplyr::top_n(-5, wt = media_nota) %>%
          dplyr::mutate(
            tipo = "bottom"
          ) %>%
            dplyr::select(ID_ENTREGADOR, tipo)))

df_entregas %>%
  dplyr::count(ID_ENTREGADOR, MES_REF) %>%
    dplyr::filter(ID_ENTREGADOR %in% entregadores$ID_ENTREGADOR) %>%
      dplyr::left_join(entregadores) %>%
      ggplot2::ggplot(ggplot2::aes(x = MES_REF, y = n, group = tipo)) +
        ggplot2::geom_line(ggplot2::aes(colour = tipo)) +
            ggplot2::facet_wrap(ID_ENTREGADOR~., ncol = 2) +
              ggplot2::scale_x_date(date_labels = "%b", date_breaks = "1 month") +
                ggplot2::theme_minimal() +
                  ggplot2::labs(title = "Comportamento dos Entregadores destaques", x = "Meses", y = "Quantidade de Entregas") +
                    ggplot2::scale_colour_manual(name = "Classe de Entregador",values = c(cores$azul_escuro, cores$verde_claro))
```

<img src="README_files/figure-gfm/unnamed-chunk-10-1.png" style="display: block; margin: auto;" />

Com esses gráficos podemos perceber que os pedidos não são direcionados
a entregadores de melhores ou piores avaliações, pois temos crescentes
de pedidos de alguns entregadores que possuem média de notas ruins, e
baixas de pedidos de alguns entregadores de com média de notas boas.

## Conclusão

A partir das análises feitas, pudemos verificar o cenário atual, fazer
algumas descobertas e sugerir algumas tomadas de decisões:

  - Deve-se verificar e ajustar as questões de atualização da plataforma
    para que todos os clientes possam avaliar os pedidos efetuados,
    principalmente nos horários e dias de pico

  - Para os estados de Minas Gerais e Rio de Janeiro, fazer um
    investimento no aumento da quantidade de entregadores, que
    notadamente afeta na avaliação dos clientes

  - Para os estados do Ceará e Paraná, deve-se investir no crescimento
    do corpo de entregadores junto ao crescimento da quantidade de
    pedidos para continuar garantindo uma boa avaliação

  - Já para o Estado de São Paulo, onde se concentram a maioria dos
    pedidos, deve-se, além de reciclar uma parte do corpo de
    entregadores, redirecionar uma quantidade de pedidos para aqueles
    que possuem notas de avaliação melhores

## Próximos passos

  - Ajuste a plataforma

  - Atuar junto aos entregadores do Estado de São Paulo, que possui
    quase 90% do volume de entregas

## Considerações Finais

Ainda completarei esta análise, com mais informações e com alguma parte
de modelagem estatística. Espero que tenham gostado\! Para sugestões e
críticas, podem entrar em contato pelo [meu
Linkedin](https://www.linkedin.com/in/rodrigoalmeidafigueira/).
