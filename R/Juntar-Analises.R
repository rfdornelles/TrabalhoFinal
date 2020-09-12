#### Início ####
# O objetivo é analisar os dados da SSP e de COVID
# Vermos se existe uma "pandemia" de criminalidade

library(dplyr)
library(ggplot2)
options(scipen = 9999999999999)

# Carregar SSP
ssp <- readr::read_rds("data/ssp-arrumada.rds")

# Carregar COVID-SP
covid_sp <- readr::read_rds("data/COVID-sp.rds")

#### Tabela auxiliar ####

tabela_auxiliar <- ssp %>%
  select(municipio = municipio_nome, regiao = regiao_nome) %>%
  unique() %>%
  left_join(covid_sp %>%
              select(municipio, populacao = populacaoTCU2019) %>%
              unique) %>%
  mutate(
    populacao = if_else(is.na(populacao), 0, populacao)
  )

#### COVID Sumarizada ####
# Vou organziar a tabela de COVID para facilitar a comparação com a SSP
# Entre outras coisas, fazer a equivalência pelas mesmas regiões usadas lá

covid_sumarizada <- covid_sp %>%
  select(municipio,code_muni, data,
         populacao = populacaoTCU2019, casosAcumulado,
         obitosAcumulado) %>%
# 1. reunir com a tabela auxiliar para obter a mesma região que vai ser
# usada na SSP - reduz para 12+NA regiões
  left_join(tabela_auxiliar %>%
              select(-populacao)) %>%
  relocate(regiao) %>%
# 2. organizo por mês (ano vai ser sempre 2020), sendo que o último dia do
# mês representa aquele total (afinal, os dados são acumulados)
  mutate(mes = lubridate::month(data),
         dia = lubridate::day(data)) %>% #ano sempre será 2020
# 3. vou agrupar por região/mês e selecionar o último dia de cada mês
   group_by(regiao, mes) %>%
  filter(dia == max(dia)) %>%
# 4. sumarizar por incidência de casos e por mortes relativas para cada
# região
  summarise(
    incidencia = (sum(casosAcumulado) / sum(populacao)) * 100000,
    mortalidade = (sum(obitosAcumulado) / sum(populacao)) * 100000,
    # letalidade = sum(obitosAcumulado) / (sum(casosAcumulado) * 100)
  ) %>%
# 5. pivotar para facilitar o manuseio do gráfico com facet_wrap
  tidyr::pivot_longer(cols = incidencia:mortalidade,
                      names_to = "variavel",
                      values_to = "quantidade") %>%
# 6. desagrupar pra ficar bonito
  ungroup()

#### SSP Sumarizada ####
## Aqui vou usar a tabela auxiliar pra me permitir usar a mesma população por
# região que a base do COVID usa

## Além disso, vou agrupar os crimes em 4 categorias, segundo sua natureza
    # CVLI - CVLI (já agrupado)
    # patrimônio - roubo + furto
    # contra_pessoa = estupro + lesão corporal
    # acidentes = transito + hom_culposo

ssp_sumarizada <- ssp %>%
# 1. remover coluna inútil e renomear para facilitar o join
  select(-delegacia_nome) %>%
  rename(regiao = regiao_nome) %>%
# 2. agrupar por ano e região
  group_by(ano, regiao) %>%
# 3. sumarizar pelos tipos de crime, de acordo com o bem jurídico
    summarise(
    CVLI = sum(CVLI),
    patrimonio = sum(roubos, furto),
    contra_pessoa = sum(estupro, lesaocorporal),
    acidentes = sum(transito, homicidio_culposo)) %>%
# 4. pivotar para facilitar o facet_wrap
  tidyr::pivot_longer(cols = CVLI:acidentes,
                      names_to = "tipo_crime",
                      values_to = "quantidade") %>%
# 5. join com a tabela auxiliar para obter a população
  left_join(tabela_auxiliar %>%
              group_by(regiao) %>%
              summarise(populacao = sum(populacao))) %>%
# 6. acrescentar a quantidade relativa, ou seja crime/100k hab
  mutate(
    qnt_relativa = (quantidade/populacao)*100000
  ) %>%
# 7. retirar a coluna de populacao e desagrupar
  select(-populacao) %>%
  ungroup()



#### PRA FAZER ####
# mostrar onde são as regiões

## ver incidencia de crimes por habitantes
## ver se faz sentido juntar por regiões - se há semelhança com covid
##
