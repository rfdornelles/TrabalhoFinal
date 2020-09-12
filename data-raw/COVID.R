#### Ler arquivo ####

#covid_original <- readxl::read_xlsx("data-raw/HIST_PAINEL_COVIDBR_06set2020.xlsx")

library(dplyr)
library(ggplot2)
library(sf)

covid_original <- readr::read_rds(path = "data/covid.rds")


#### Organizar ####

# Dados do covid.saude.gov.br / Sobre:

# Incidência = Estima o risco de ocorrência de casos de COVID-19 na população
# casos confirmados / populacao * 100.000

# Mortalidade = Número de óbitos por doenças COVID-19, por 100 mil habitantes
# óbitos / população * 100.000

# Letalidade = N. de óbitos confirmados em relação ao total de casos confirmados
# óbitos / casos confirmados * 100

covid_original <- covid_original %>%
  select(-codRegiaoSaude, -nomeRegiaoSaude, -Recuperadosnovos,
         -emAcompanhamentoNovos, -obitosAcumulado_log2, -obitosNovos_log2) %>%
  mutate(
    incidencia = casosAcumulado / populacaoTCU2019 * 100000,
    mortalidade = obitosAcumulado / populacaoTCU2019 * 100000,
    letalidade = obitosAcumulado / casosAcumulado * 100,
  )


#### Dividir ####

# Nacional
covid_brasil <- covid_original %>%
  filter(regiao == "Brasil", is.na(estado), is.na(municipio))

# Por estado
covid_estado <- covid_original %>%
  filter(regiao != "Brasil", !is.na(estado), is.na(municipio))

# Por municipio
covid_municipio <- covid_original %>%
  filter(regiao != "Brasil", !is.na(estado), !is.na(municipio))

# Restringir SP

covid_sp <- covid_municipio %>%
  filter(estado == "SP")

#### Corrigir códigos ####

covid_sp <- covid_sp %>%
  left_join(y = select(abjData::cadmun, 1:2),
            by = c("codmun" = "MUNCOD"))

covid_sp <- covid_sp %>%
  mutate(code_muni = MUNCODDV) %>%
  select(-MUNCODDV, -codmun)

#### Análises ####

# incidência
covid_sp %>%
  group_by(data) %>%
  arrange(data) %>%
  summarise(data, soma = sum(incidencia)) %>%
  ggplot(aes(x = data, y = soma)) +
  geom_line()

# mortalidade
covid_sp %>%
  group_by(data) %>%
  arrange(data) %>%
  summarise(data, soma = sum(mortalidade)) %>%
  ggplot(aes(x = data, y = soma)) +
  geom_line()

# letalidade
covid_sp %>%
  filter(is.numeric(letalidade) & !is.na(letalidade)) %>%
  group_by(data) %>%
  arrange(data) %>%
  summarise(data, soma = sum(letalidade)) %>%
  ggplot(aes(x = data, y = soma)) +
  geom_line()

# Mapa SP
mapa_sp <- geobr::read_municipality(code_muni = "SP")

# Maior/menor mortalidade, letalidade, incidencia

# Função para gerar os mapas
gera_mapa <- function(tabela = covid_sp, mapa = mapa_sp) {

  mapa %>%
    left_join(tabela) %>%
    ggplot()

}

gera_mapa2 <- function(coluna, tabela = covid_sp, mapa = mapa_sp) {

  mapa %>%
    left_join(tabela) %>%
    ggplot(mapping = aes(fill = {{coluna}})) +
    geom_sf() +
    tema()


}



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

gera_mapa2(incidencia)




### Analisar por município as respectivas taxas de incidência
options(scipen = 999999)

covid_sp %>%
  group_by(municipio) %>%
  ggplot(aes(x = data, y = incidencia, color = municipio)) +
  geom_jitter() +


  covid_sp %>%
  filter(data == max(data)) %>%
  gera_mapa2(cut(incidencia, 5), tabela = .)

covid_sp %>%
  filter(data == max(data)) %>%
  arrange(-incidencia) %>%
  relocate(municipio, incidencia)


# Teste animação

mapa_sp %>%
  left_join(covid_sp) %>%
  ggplot(mapping = aes(fill = cut(incidencia,5))) +
  geom_sf() +
  labs(caption = element_blank()) +


  transition_states(semanaEpi)



