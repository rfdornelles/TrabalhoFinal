## Gráficos utilizados em todos os chunks

#### graficos_e_mapas-covid ####

# Criar os gráficos
casos_nacional <- covid_original %>%
  filter(regiao != "Brasil", !is.na(estado), is.na(municipio)) %>%
  group_by(data, regiao) %>%
  summarise(casosAcumulado = sum(casosAcumulado)) %>%
  ggplot(aes(x = data, y = casosAcumulado,
             color = regiao)) +
  geom_line(show.legend = FALSE) +
  scale_y_log10() +
  ylab(NULL) +
  xlab(NULL) +
  theme_classic() +
  ggtitle("Casos acumulados")

obitos_nacional <- covid_original %>%
  filter(regiao != "Brasil", !is.na(estado), is.na(municipio)) %>%
  group_by(data, regiao) %>%
  summarise(obitosAcumulado = sum(obitosAcumulado)) %>%
  ggplot(aes(x = data, y = obitosAcumulado,
             color = regiao)) +
  geom_line() +
  scale_y_log10() +
  ylab(NULL) +
  xlab(NULL) +
  theme_classic() +
  ggtitle("Óbitos acumulados")

incidencia <- covid_sumarizada %>%
  filter(variavel == "incidencia") %>%
  group_by(mes) %>%
  summarise(soma = sum(quantidade)) %>%
  ggplot(aes(x = mes, y = soma)) +
  geom_line(size = 2) +
  ylab(NULL) +
  xlab(NULL) +
  theme_classic()

mortalidade <- covid_sumarizada %>%
  filter(variavel == "mortalidade") %>%
  group_by(mes) %>%
  summarise(soma = sum(quantidade)) %>%
  ggplot(aes(x = mes, y = soma)) +
  geom_line(size = 2) +
  ylab(NULL) +
  xlab(NULL) +
  theme_classic()

#### grafico_tendencia_crime ####

grafico_tendencia_crime <- ssp_sumarizada_projecao %>%
  ggplot(mapping = aes(x = ano, y = qnt_relativa, fill = tipo_crime)) +
  scale_x_continuous(breaks = ssp_sumarizada_projecao$ano) +
  geom_col(position = "stack") +
  theme_classic() +
  labs(title = "Evolução geral de ocorrências criminais em SP",
       subtitle = "De 2002 a 2020*",
       caption = "*estimativa") +
  ylab(label = "Ocorrências por 100mil/hab") +
  xlab(label = NULL) +
  theme(axis.text.x = element_text(angle=65, vjust=0.6))

#### grafico_crimes_evolucao ####

grafico_crimes_evolucao <- ssp_sumarizada_projecao %>%
  ggplot(mapping = aes(x = ano, y = qnt_relativa, fill = ano)) +
  scale_fill_gradient(low="#945E00", high="#00948C") +
  scale_x_continuous(breaks = ssp_sumarizada_projecao$ano) +
  geom_col(position = "dodge", show.legend = F) +
  facet_grid(factor(tipo_crime,
                    labels = c("Acidentes", "Pessoa",
                               "CVLI",
                               "Patrimônio")) ~ ., scales = "free_y") +
  theme_classic() +
  labs(title = "Evolução por categorias de crimes",
       subtitle = "De 2002 a 2020*",
       caption = "*estimativa") +
  ylab(label = "Ocorrências por 100mil/hab") +
  xlab(label = NULL) +
  theme(axis.text.x = element_text(angle=65, vjust=0.6))

#### grafico_crimes_SP ####

grafico_crimes_SP <- ssp_sumarizada_projecao %>%
  ggplot(mapping = aes(x = ano, y = qnt_relativa, color = regiao)) +
  geom_line() +
  facet_grid(factor(tipo_crime,
                    labels = c("Acidentes", "Pessoa",
                               "CVLI", "Patrimônio")) ~ .,
             scales = "free_y") +
  geom_point() +
  theme_classic() +
  scale_color_brewer(palette = "Paired") +
  gganimate::transition_reveal(ano)

