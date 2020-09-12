#### Mapa de SP ####
mapa_sp <- geobr::read_municipality(code_muni = "SP")

#### Funções de mapa ####

tema <- function() {

  theme(panel.background =
          element_rect(fill='#00001C',colour='#00001C'),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        axis.line=element_blank(),axis.text.x=element_blank(),
        axis.text.y=element_blank(),axis.ticks=element_blank(),
        axis.title.x=element_blank(),
        axis.title.y=element_blank())
}

gera_mapa2 <- function(coluna, tabela = covid_sp, mapa = mapa_sp) {

  mapa %>%
    left_join(tabela) %>%
    ggplot(mapping = aes(fill = {{coluna}})) +
    geom_sf() +
    tema()
}

