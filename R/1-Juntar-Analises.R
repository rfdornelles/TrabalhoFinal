####################### ATENÇÃO #######################################
# ATENÇÃO: a primeira parte do tratamento dos dados já foi feita, dando
# origem às bases na pasta /data

# SSP: /data-raw/SSP.R         --->   /data/ssp-arrumada.rds
# COVID: /data-raw/COVID.R     --->   /data/COVID-sp.rds

#### Início ####

library(dplyr)
library(ggplot2)
library(sf)
library(patchwork)

options(scipen = 9999999999999)

# Carregar SSP
ssp <- readr::read_rds("data/ssp-arrumada.rds")

# Carregar COVID-SP
covid_sp <- readr::read_rds("data/COVID-sp.rds")

# Carregar bases originais
ssp_original <- readr::read_rds("data-raw/ssp.rds")
covid_original <- readr::read_rds("data-raw/covid.rds")


#### Tabela auxiliar ####

tabela_auxiliar <- ssp %>%
  select(municipio = municipio_nome, regiao = regiao_nome) %>%
  unique() %>%
  left_join(covid_sp %>%
              select(municipio, populacao = populacaoTCU2019, code_muni) %>%
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
              select(-populacao, -code_muni)) %>%
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
    # contra_pessoa = estupro + lesão corporal dolosa
    # acidentes = transito + hom_culposo + lesao corporal culposa

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
    acidentes = sum(transito, homicidio_culposo, lesaocorporal_culpa)) %>%
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

#### SSP - Problema ####
# Eu só tenho os dados de criminalidade até abril
# Farei uma projeção verificando o peso do primeiro quadrimestre (jan-abr)
# no total dos meses e depois multiplicando com uma regra de três essa
# quantidade, para projetar esses valores no fim do ano

## Calcular os pesos
peso_quadrimestres <- ssp %>%
# 1. Retiro o ano de 2020 da conta
  filter(ano < 2020) %>%
# 2. Agrupo por meses, em intervalos de 4 meses (quadrimestral)
  group_by(mes = ggplot2::cut_interval(mes, length = 4)) %>%
# 3. Somar a quantidade de ocorrências por quadrimestre
  summarise(
    CVLI = sum(CVLI),
    patrimonio = sum(roubos, furto),
    contra_pessoa = sum(estupro, lesaocorporal),
    acidentes = sum(transito, homicidio_culposo, lesaocorporal_culpa)) %>%
# 4. Ver o quanto cada quadrimestre representa do todo
  summarise(
    CVLI = CVLI/sum(CVLI),
    patrimonio = patrimonio/sum(patrimonio),
    contra_pessoa = contra_pessoa/sum(contra_pessoa),
    acidentes = acidentes/sum(acidentes)
  ) %>%
# 5. Selecionar apenas o primeiro quadrimestre
  head(1)

## Projetar o valor final de 2020 com base no primeiro quadrimestre
# Estou entendendo que posso fazer a conta com:
# valor_final_do_ano(Q3) = valor_do_Q1 / peso_do_Q1


ssp_sumarizada_projecao <- ssp_sumarizada %>%
# 1. Retirar a quantidade relativa para que ela volte ao final e não dê
# problemas na pivotagem
  select(-qnt_relativa) %>%
# 2. Pivotar de volta para poder trabalhar com as colunas
  tidyr::pivot_wider(names_from = tipo_crime,
                     values_from = quantidade) %>%
# 3. Agrupar por ano e região
  group_by(ano, regiao) %>%
# 4. Usar o mutate para, com if_else caso o ano seja 2020 recalcular o valor
# final com base na proporção do primeiro quadrimestre.
  mutate(
    CVLI = if_else(ano == 2020,
           CVLI / peso_quadrimestres$CVLI, CVLI),
    patrimonio = if_else(ano == 2020,
           patrimonio / peso_quadrimestres$patrimonio, patrimonio),
    contra_pessoa = if_else(ano == 2020,
          contra_pessoa / peso_quadrimestres$contra_pessoa, contra_pessoa),
    acidentes = if_else(ano == 2020,
          acidentes / peso_quadrimestres$acidentes, acidentes)
  ) %>%
# 5. Pivotar de volta, lembrando que perdi a população
  tidyr::pivot_longer(cols = CVLI:acidentes,
                      names_to = "tipo_crime",
                      values_to = "quantidade") %>%
# 6. join com a tabela auxiliar para obter a população de volta
  left_join(tabela_auxiliar %>%
              group_by(regiao) %>%
              summarise(populacao = sum(populacao))) %>%
# 7. acrescentar a quantidade relativa, ou seja crime/100k hab
  mutate(
    qnt_relativa = (quantidade/populacao)*100000
  ) %>%
# 8. retirar a coluna de populacao e desagrupar
  select(-populacao) %>%
  ungroup()
