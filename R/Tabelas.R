# Tabelas

ssp_sumarizada_projecao %>%
  filter (!is.na(regiao)) %>%
  pull(regiao) %>%
  unique() %>%
  gridExtra::tableGrob(cols = "Regiões")

covid_sumarizada %>%
  filter(mes == max(mes)) %>%
  tidyr::pivot_wider(
    names_from = "variavel",
    values_from = "quantidade"
  )

# COVID
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
    # letalidade = sum(obitosAcumulado) / (sum(casosAcumulado) * 100)
  )

covid_sp %>%
  filter(mes == max(mes)) %>%
  select(-code_muni, -data, -dia, -obitosAcumulado, -mes, -mortalidade) %>%
  arrange(-incidencia) %>%
  select(Município = municipio, `Tx. Incidência` = incidencia,
           `Casos Acumulados` = casosAcumulado, População = populacao,
           Região = regiao)



