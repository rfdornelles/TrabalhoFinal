library(dplyr)

# Tenho em oastas separadas os dados de mortes em decorrência de atividade
# policial separadas por PM em serviço e PM fora de serviço

# Ler ambas as pastas e adicionar coluna indicando a origem dele

dados_pm_emservico <- purrr::map_df(.x = fs::dir_ls("data-raw/PM-Servico/"),
           .f = readxl::read_excel)

dados_pm_emservico <- dados_pm_emservico %>%
  mutate(origem = "PM-Serviço") %>%
  relocate(origem)

dados_pm_fora <- purrr::map_df(.x = fs::dir_ls("data-raw/PM-Fora/"),
                               .f = readxl::read_excel)

dados_pm_fora <- dados_pm_fora %>%
  mutate(origem = "PM-Fora") %>%
  relocate(origem)


# Juntas as duas bases em uma só, com nomes arrumados

dados <- dplyr::bind_rows(dados_pm_emservico, dados_pm_fora) %>%
  janitor::clean_names()

# Limpar as variáveis não mais usadas

rm(dados_pm_fora, dados_pm_emservico)

