## Mapas utilizados em todos os chunks

#### Funções e pacotes úteis ###################################

#### Mapa de SP
#mapa_sp <- geobr::read_municipality(code_muni = "SP", simplified = FALSE)
#readr::write_rds(mapa_sp, "data/mapa_sp.rds")

mapa_sp <- readr::read_rds("data/mapa_sp.rds")

#### Mapa do BR
#mapa_br <- geobr::read_state(simplified = FALSE)
#readr::write_rds(mapa_br, "data/mapa_br.rds")

mapa_br <- readr::read_rds("data/mapa_br.rds")

#### Funções de mapa

tema <- function() {

  theme(
    panel.background = element_rect(fill='transparent',
                                    colour='transparent'),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    axis.line=element_blank(),
    axis.text.x=element_blank(),
    axis.text.y=element_blank(),
    axis.ticks=element_blank(),
    axis.title.x=element_blank(),
    axis.title.y=element_blank()
  )
}

gera_mapa2 <- function(coluna, tabela = covid_sp, mapa = mapa_sp) {

  mapa %>%
    left_join(tabela) %>%
    ggplot(mapping = aes(fill = {{coluna}})) +
    geom_sf() +
    annotation_custom(img_norte, xmin = 35, ymin = 2) +
    tema()
}

### Norte

img_norte <- png::readPNG("data/norte.png") %>%
  grid::rasterGrob()


#### mapa_regioes ###################################################
# Mapa das regiões utilizadas

mapa_regioes <- mapa_sp %>%
  left_join(tabela_auxiliar) %>%
  ggplot(mapping = aes(fill = regiao)) +
  geom_sf(show.legend = FALSE, colour = "transparent", size = 1/100000) +
  scale_fill_brewer(palette = "Paired") +
  geom_sf_text(data = mapa_sp %>%
                 left_join(tabela_auxiliar) %>%
                 filter(municipio == regiao | municipio == "São Paulo" | municipio == "Carapicuiba"),
               aes(label = regiao),
               show.legend = FALSE, size = 3,
               nudge_x = 0.2, nudge_y = 0.1,check_overlap = T) +
  tema()

#### graficos_e_mapas-covid ####

# Incidência
mapa_incidencia_br <- mapa_br %>%
  left_join(covid_original %>%
              filter(regiao != "Brasil", !is.na(estado), is.na(codmun),
                     data == max(data)) %>%
              select(estado, populacaoTCU2019, casosAcumulado) %>%
              group_by(estado) %>%
              mutate(
                incidencia = (casosAcumulado/populacaoTCU2019)*100000
              ),
            by = c("abbrev_state" = "estado")) %>%
  ggplot() +
  geom_sf(aes(fill = incidencia), show.legend = F) +
  geom_sf_text(mapping = aes(label = abbrev_state), size = 2) +
  scale_fill_gradient(low = "#FFDFBD", high = "#914B00") +
  tema()

# Mortalidade
mapa_mortalidade_br <- mapa_br %>%
  left_join(covid_original %>%
              filter(regiao != "Brasil", !is.na(estado), is.na(codmun),
                     data == max(data)) %>%
              select(estado, populacaoTCU2019, obitosAcumulado) %>%
              group_by(estado) %>%
              mutate(
                obitos = (obitosAcumulado/populacaoTCU2019)*100000
              ),
            by = c("abbrev_state" = "estado")) %>%
  ggplot() +
  geom_sf(aes(fill = obitos), show.legend = F) +
  geom_sf_text(aes(label = abbrev_state), size = 2) +
  scale_fill_gradient(low = "#FAD7D7", high = "#7A1010") +
  tema()

#gganimate::animate(, end_pause = 40)

#### tabela_mapa_covid_incidencia_mortalidade ####

mapa_sp_incidencia <- mapa_sp %>%
  left_join(covid_sp %>% filter(mes == max(mes)),
            by = c("code_muni" = "code_muni")) %>%
  ggplot(mapping = aes(fill = incidencia)) +
  ggtitle(label = NULL, subtitle = "Incidência de casos") +
  geom_sf(show.legend = FALSE, color = "transparent", size = 1/100000) +
  scale_fill_gradient(low = "#FFDFBD", high = "#914B00") +
  tema()

mapa_sp_mortalidade <- mapa_sp %>%
  left_join(covid_sp %>%
              filter(mes == max(mes)), by = "code_muni") %>%
  ggplot(mapping = aes(fill = mortalidade)) +
  ggtitle(label = NULL, subtitle = "Mortalidade de casos") +
  geom_sf(show.legend = FALSE, color = "transparent", size = 1/100000) +
  scale_fill_gradient(low = "#FAD7D7", high = "#7A1010") +
  tema()

#### mapa_diferenças_CVLI ####

mapa_diferencas_CVLI <- mapa_sp %>%
  left_join(
    tabela_diferencas_CVLI %>%
      left_join(tabela_auxiliar, by = "regiao")) %>%
  ggplot() +
  geom_sf(aes(fill = `2019` > `2020`), show.legend = FALSE,
          color = "transparent", size = 1/100000) +
  scale_fill_manual(values = c("#FF0000", "#DED7D7", "#DED7D7")) +
  ggtitle(label = "Crescimento de CVLI nas regiões",
          subtitle = "Em destaque regiões que tiveram aumento") +
  tema()
