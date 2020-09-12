#### Dados COVID ####
# Tratados e adaptados pra SP
covid_sp %>%
  select(municipio, code_muni, data, populacao = populacaoTCU2019,
         casosAcumulado, obitosAcumulado, incidencia, mortalidade, letalidade) %>%
  mutate(mes = lubridate::month(data)) %>% #ano sempre será 2020
  select(-data) %>%
  View()



ggplot(mapping= aes(x = mes, y = quantidade, color = regiao)) +
  geom_line(show.legend = FALSE) +
  facet_wrap(~variavel, scales = "free") +
  labs(caption = element_blank())





# faz sentido tirar a letalidade, pois não é relacionada a população
