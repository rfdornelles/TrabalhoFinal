#### Início ####
# O objetivo é analisar os dados da SSP e de COVID
# Vermos se existe uma "pandemia" de criminalidade

library(dplyr)
library(ggplot2)

#### Dados SSP ####

ssp <- readr::read_rds("data/ssp-arrumada.rds")

ssp %>%
  select(-delegacia_nome, -regiao_nome)

#### Dados COVID ####
# Tratados e adaptados pra SP

covid_sp <- readr::read_rds("data/")


#### COVID - Análise ####


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

