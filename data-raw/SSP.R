e #### Carregar base ####
library(dplyr)

ssp <- readr::read_rds("data/ssp.rds")

####
ssp %>% View()


sobra <- anti_join(ssp %>%
   select(municipio_nome) %>%
  unique(), covid_sp %>%
  select(municipio) %>%
  unique(),
  by = c("municipio_nome" = "municipio"))

ssp %>%
  select(-delegacia_nome, -regiao_nome) %>%
  rowwise(mes, ano, municipio_nome) %>%
  mutate(
    estupro = sum(c_across(contains("estupro")))
    homicidio =
         ) %>% View()

ssp %>%
  rowwise(mes, ano, municipio_nome) %>%
  mutate(
    checa_estupro = estupro_total == (estupro + estupro_vulneravel)
  ) %>%
  filter(!checa_estupro, (estupro != 0 | estupro_vulneravel != 0)) %>%
  select(ano, mes, municipio_nome, contains("estupro")) %>%
  View()

ssp %>%
  select(ano, mes, municipio_nome, contains("total"))

# Vou usar estupro_total e roubo_total

base <- ssp %>%
  select(-delegacia_nome, -regiao_nome, roubo = roubo_total) %>%
  mutate(
    estupro = estupro_total
      ) %>%
  select(-estupro_total, -estupro_vulneravel, -contains("roubo_"))

base %>%
rowwise(mes, ano, municipio_nome) %>%
  mutate(
    furto = sum(c_across(contains("furto"))),
    homicidio = sum(c_across(contains("hom_"))),
    lesao_corporal = sum(c_across(contains("lesao_corp"))),

    )


    %>% View()

names(ssp)
