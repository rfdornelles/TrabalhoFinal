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

mapa_sp %>%
  left_join(covid_sp %>%
               filter(data == max(data))) %>%
  ggplot() +
  geom_sf(aes(fill = incidencia))



gera_mapa <- function(tabela, mapa = mapa_sp) {

  mapa %>%
    left_join(tabela) %>%
    ggplot()

}


