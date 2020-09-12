#### Ambas - Regiões ####

gera_mapa2(regiao, tabela = tabela_auxiliar)


#### COVID - Análise ####

# nacional

casos_nacional <- covid_original %>%
  filter(regiao != "Brasil", !is.na(estado), is.na(municipio)) %>%
  group_by(data, regiao) %>%
  summarise(casosAcumulado = sum(casosAcumulado)) %>%
  ggplot(aes(x = data, y = casosAcumulado,
             color = regiao)) +
  geom_line() +
  scale_y_log10()

obitos_nacional <- covid_original %>%
  filter(regiao != "Brasil", !is.na(estado), is.na(municipio)) %>%
  group_by(data, regiao) %>%
  summarise(obitosAcumulado = sum(obitosAcumulado)) %>%
  ggplot(aes(x = data, y = obitosAcumulado,
             color = regiao)) +
  geom_line() +
  scale_y_log10()

# Criar os mapas

mapa_br <- sf::st_simplify(geobr::read_state(), dTolerance = 0.2)

covid_original <- covid_original %>%
  filter(regiao != "Brasil", !is.na(estado), is.na(municipio))

covid_original <- covid_original %>%
    select(-codRegiaoSaude, -Recuperadosnovos,
           -emAcompanhamentoNovos, -obitosAcumulado_log2, -obitosNovos_log2) %>%
    mutate(
      incidencia = (casosAcumulado / populacaoTCU2019) * 100000,
      mortalidade = (obitosAcumulado / populacaoTCU2019) * 100000,
      letalidade = (obitosAcumulado / casosAcumulado) * 100,
    )

library(gganimate)
casos_acumulados_BR <- mapa_br %>%
  left_join(covid_original,
       by = c("abbrev_state" = "estado")) %>%
  ggplot(aes(fill = casosAcumulado)) +
  geom_sf() +
  gganimate::transition_time(semanaEpi)

gganimate::animate(casos_acumulados_BR + gganimate::ease_aes('cubic-in-out'),
        fps = 10,
        end_pause = 25,
        height = 800,
        width = round(800/1.61803398875))

# em SP
incidencia <- covid_sumarizada %>%
  filter(variavel == "incidencia") %>%
  group_by(mes) %>%
  summarise(soma = sum(quantidade)) %>%
  ggplot(aes(x = mes, y = soma)) +
  geom_line()

mortalidade <- covid_sumarizada %>%
  filter(variavel == "mortalidade") %>%
  group_by(mes) %>%
  summarise(soma = sum(quantidade)) %>%
  ggplot(aes(x = mes, y = soma)) +
  geom_line()

# gráfico de aumento das taxas

covid_sumarizada %>%
  ggplot(mapping= aes(x = mes, y = quantidade, color = regiao)) +
  geom_line(show.legend = FALSE) +
  facet_wrap(~variavel, scales = "free_y") +
  labs(caption = element_blank())


#### SSP ####

ssp_sumarizada %>%
  ggplot(mapping = aes(x = ano, y = quantidade, color = regiao)) +
  geom_line() +
  facet_wrap(~tipo_crime, scales = "free_y") +
  xlim(2002, 2019)

ssp_sumarizada %>%
  ggplot(mapping = aes(x = ano, y = quantidade, color = regiao)) +
  geom_line() +
  facet_wrap(~tipo_crime, scales = "free_y")

ssp_sumarizada %>%
  ggplot(mapping = aes(x = ano, y = qnt_relativa, color = regiao)) +
  geom_line() +
  facet_wrap(~tipo_crime, scales = "free_y")

ssp_sumarizada_projecao %>%
ggplot(mapping = aes(x = ano, y = qnt_relativa, color = regiao)) +
  geom_line() +
  facet_wrap(~tipo_crime, scales = "free_y")
