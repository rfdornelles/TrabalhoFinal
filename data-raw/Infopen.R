library(dplyr)
library(stringr)

# base Infopen
# https://carceropolis.org.br/metodologia/

infopen_original <- readr::read_csv2(file = "data-raw/infopen_2019_12.csv",
                                     guess_max = 10000)

# variaveis <- tibble::tibble(nome = names(infopen_original))
#
# variaveis %>%
#   tidyr::separate(col = nome, into = c("nome1", "nome2"),
#                   sep = "\\|",
#                   extra = "merge") %>%
#   select(nome1) %>%
#   unique() %>%
#   View()

# A base possui mais de 1300 variáveis. Vou selecionar as que fazem sentido
# que são aquelas que indicam capacidade, a atual população e a incidência
# por tipo penal, em que supostamente poderemos saber "porquê" as pessoas
# estão presas

infopen_limpo <- infopen_original %>%
  select(UF, `Nome do Estabelecimento`, CEP, `Código IBGE`,
         contains("Capacidade do estabelecimento"),
         contains("4.1 População prisional"),
         contains("5.14 Quantidade de incidências por tipo penal")
         )

# Começar tornando as colunas de capacidade do estabelecimento numeric (tava
# dando erro) e somando todas elas. Isso porque no Infopen eles dividem a
# capacidade em diversas colunas

infopen_limpo <- infopen_limpo %>%
  mutate(across(
    .cols = contains("Capacidade do estabelecimento"),
    .fns = as.numeric)) %>%
  rowwise() %>%
  mutate(
    capacidade = sum(c_across(contains("Capacidade do estabelecimento")))
  ) %>%
  select(-contains("Capacidade do estabelecimento"))

# Vou olhar melhor. Acho que tem coluna com totais e que se somadas pode dar
# erro

infopen_limpo %>%
  mutate(across(
    .cols = contains("Capacidade do estabelecimento"),
    .fns = as.numeric)) %>%
  select(contains("Capacidade do estabelecimento")) %>%
  names()

# Era isso mesmo. Preciso apenas de:
# 1.3 Capacidade do estabelecimento | Masculino | Total
# 1.3 Capacidade do estabelecimento | Feminino | Total

# fazer o mesmo com lotação
infopen_limpo <- infopen_limpo %>%
  mutate(across(
    .cols = contains("4.1 População prisional"),
    .fns = as.numeric)) %>%
  rowwise() %>%
  mutate(
    populacao = sum(c_across(contains("4.1 População prisional")))
  ) %>%
  select(-contains("4.1 População prisional"))

# Ver se tenho totais que possa usar:


infopen_original %>%
  mutate(across(
    .cols = contains("4.1 População prisional"),
    .fns = as.numeric)) %>%
  select(contains("4.1 População prisional")) %>%
  names()

# 4.1 População prisional | Total

infopen_limpo %>%
  select(UF:CEP, capacidade, populacao) %>%
  summary()

# Muitos NA, possivelmente por problemas na soma. Tentar outra abordagem seleci
#o nando as colunas com totais

infopen_original %>%
  select(UF, `Nome do Estabelecimento`, `Código IBGE`,
         capacidade_mas = `1.3 Capacidade do estabelecimento | Masculino | Total`,
         capacidade_fem = `1.3 Capacidade do estabelecimento | Feminino | Total`,
         lotacao = `4.1 População prisional | Total`)



# limpando tipos penais
infopen_limpo <- infopen_limpo %>%
  mutate(across(
    .cols = contains("5.14 Quantidade de incidências por tipo penal"),
    .fns = as.numeric))

names(infopen_limpo)

infopen_limpo_tipos <- infopen_limpo %>%
  tidyr::pivot_longer(
  cols = contains("5.14 Quantidade de incidências por tipo penal"),
  names_to = "artigo_tipo",
  values_to = "artigo_qnt")

infopen_limpo_tipos %>%
  pull(artigo_tipo) %>%
  unique()

infopen_limpo_tipos %>%
  filter(stringr::str_detect(artigo_tipo, pattern = "Total")) %>%
  mutate(artigo_tipo = stringr::str_remove(string = artigo_tipo,
                                           pattern = "5.14 Quantidade de incidências por tipo penal |  GRUPO: CÓDIGO PENAL | Grupo: ")) %>%
  pull(artigo_tipo) %>%
  unique()

infopen_tipos <- infopen_limpo_tipos %>%
  filter(stringr::str_detect(artigo_tipo, pattern = "Total")) %>%
  mutate(artigo_tipo = case_when(
 str_detect(artigo_tipo, "Crimes contra a pessoa") ~ "vida",
 str_detect(artigo_tipo, "Crimes contra o patrimônio") ~ "patrimônio",
 str_detect(artigo_tipo, "Crimes contra a dignidade sexual") ~ "dignidade sexual",
 str_detect(artigo_tipo, "Grupo: Drogas (Lei 6.368/76 e Lei 11.343/06)") ~ "drogas",
 str_detect(artigo_tipo, "Estatuto do Desarmamento") ~ "desarmamento",
 str_detect(artigo_tipo, "(Lei 8.069, de 13/01/1990)") ~ "criança/adolescente",
 TRUE ~ "outros"),
        artigo_tipo = forcats::as_factor(artigo_tipo)
 )

infopen_tipos %>%
  janitor::clean_names() %>%
  select(nome_do_estabelecimento, artigo_tipo, artigo_qnt) %>%
  summary()

infopen_limpo_tipos %>%
  janitor::clean_names() %>%
  select(nome_do_estabelecimento, artigo_tipo, artigo_qnt) %>%
    tidyr::pivot_wider(names_from = artigo_tipo,
                values_from = artigo_qnt)

# Homicídio simples
# Homicílio culposo
# Homicídio qualificado
# Lesão corporal
# Violência doméstica
# Crimes contra a pessoa | Outros
#
# Furto simples
# Furto qualificado
# Roubo simples
# Roubo qualificado
#
# Latrocínio


infopen_limpo %>%
  select(capacidade_cat, capacidade_qnt)

