### Montar as tabelas que serão usadas

#### tabela_mapa_covid_incidencia_mortalidade #########

# Banco dos casos em SP
covid_sp <- readr::read_rds("data/COVID-sp.rds") %>%
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
  filter(dia == max(dia)) %>%
  # 4. sumarizar por incidência de casos e por mortes relativas para cada
  # região
  mutate (
    incidencia = (casosAcumulado / populacao) * 100000,
    mortalidade = (obitosAcumulado / populacao) * 100000,
    incidencia = tidyr::replace_na(incidencia, 0),
    mortalidade = tidyr::replace_na(incidencia, 0)
  )


tabela_mapa_covid_incidencia_mortalidade <- covid_sumarizada %>%
  filter(mes == max(mes), !is.na(regiao)) %>%
  tidyr::pivot_wider(
    names_from = "variavel",
    values_from = "quantidade"
  ) %>%
  select(-mes, Região = regiao, `Tx. Incidência` = incidencia,
         `Tx. Mortalidade` = mortalidade)

#### tabela_quarentena ##########

tabela_quarentena <- ssp_sumarizada_projecao %>%
  left_join(tabela_auxiliar %>%
              group_by(regiao) %>%
              summarise(populacao = sum(populacao))
  ) %>%
  select(-qnt_relativa) %>%
  tidyr::pivot_wider(
    names_from = tipo_crime,
    values_from = quantidade
  ) %>%
  select(-regiao) %>%
  group_by(ano) %>%
  summarise(
    CVLI = (sum(CVLI)/sum(populacao))*100000,
    patrimonio = (sum(patrimonio)/sum(populacao))*100000,
    contra_pessoa = (sum(contra_pessoa)/sum(populacao))*100000,
    acidentes = (sum(acidentes)/sum(populacao))*100000
  ) %>%
  filter(ano >= 2015) %>%
  tidyr::pivot_longer(
    cols = CVLI:acidentes,
    names_to = "Crime",
    values_to = "Taxa"
  ) %>%
  tidyr::pivot_wider(
    values_from = Taxa,
    names_from = ano
  )

#### tabela_diferenças_CVLI ####

tabela_diferencas_CVLI <- ssp_sumarizada_projecao %>%
  left_join(tabela_auxiliar %>%
              group_by(regiao) %>%
              summarise(populacao = sum(populacao))
  ) %>%
  filter(ano >= 2019, tipo_crime == "CVLI", !is.na(regiao)) %>%
  tidyr::pivot_wider(
    names_from = tipo_crime,
    values_from = quantidade
  ) %>%
  #select(-regiao) %>%
  group_by(regiao, ano, populacao) %>%
  summarise(
    CVLI = (sum(CVLI)/sum(populacao))*100000,
  ) %>%
  tidyr::pivot_wider(
    names_from = "ano",
    values_from = "CVLI"
  ) %>%
  mutate(
    diferenca = (`2020`-`2019`)/`2019`*100
  )

#### tabela_cidades_mais_covid  ######

tabela_cvli_mortalidade <- covid_sp %>%
  filter(mes == max(mes), obitosAcumulado > 0) %>%
  left_join(ssp_sumarizada %>%
              filter(ano == 2020, tipo_crime == "CVLI")) %>%
  group_by(municipio, populacao) %>%
  summarise(
    CVLI = (quantidade/populacao)*100000,
    obito_covid = (obitosAcumulado/populacao)*100000,
    causa_maior = as.factor(if_else(CVLI > obito_covid,
                                    "crime",
                                    "covid"))) %>%
  unique()

tabela_cvli_mortalidade <- tabela_cvli_mortalidade %>%
  filter(causa_maior == "covid") %>%
  arrange(-populacao)

####
