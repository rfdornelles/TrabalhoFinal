library(dplyr)
library(stringr)
library(ggplot2)

#### Ler a base Infopen ####
# https://carceropolis.org.br/metodologia/
infopen_original <- readr::read_csv2(file = "data-raw/infopen_2019_12.csv",
                                     guess_max = 10000)


#### Limpeza da base ####

# A base possui mais de 1300 variáveis. Vou selecionar as que fazem sentido
# que são aquelas que indicam capacidade, a atual população e a incidência
# por tipo penal, em que supostamente poderemos saber "porquê" as pessoas
# estão presas

# Vou ficar apenas com as sobre capacidade e lotação

infopen_limpo <- infopen_original %>%
  select(UF, `Nome do Estabelecimento`, CEP, `Código IBGE`,
         capacidade_mas = `1.3 Capacidade do estabelecimento | Masculino | Total`,
         capacidade_fem = `1.3 Capacidade do estabelecimento | Feminino | Total`,
         populacao = `4.1 População prisional | Total`) %>%
  janitor::clean_names()

# Nas capacidades preciso substituir NA por 0

infopen_limpo <- purrr::map_df(infopen, ~tidyr::replace_na(.x, replace = 0))

# Salvar e deixar o original como bakcup
infopen <- infopen_limpo
rm(infopen_limpo)

#### Arrumar ####

# Acrescentar taxa de ocupação: populacao/capacidade * 100

infopen <- infopen %>%
  mutate(
    tx.ocupacao = populacao/(capacidade_mas + capacidade_fem)*100
  ) %>%
  select(-codigo_ibge)


# Acrescentar perfil: masculina, feminina, mista

infopen <- infopen %>%
  mutate(
    perfil = case_when(
      capacidade_mas > 0 & capacidade_fem == 0 ~ "masculina",
      capacidade_fem > 0 & capacidade_mas == 0 ~ "feminina",
      capacidade_fem > 0 & capacidade_mas > 0 ~ "mista",
      TRUE ~ "outros"
    ))

#### Exploração ####



#### Análises ####


# Como é a superlotação por Estado?

infopen

# Como é a distribuição de vagas / pessoas presas por estado?

# Focando em SP:

  # Quantos municípios possuem unidades prisionais
  # Quantas pessoas presas


#### Para o futuro ####
# Para examinar os tipos penais pelos quais as pessoas estão presas, usar
#5.14 Quantidade de incidências por tipo penal

# Tipos normalmente mais úteis
# Homicídio simples
# Homicílio culposo
# Homicídio qualificado
# Lesão corporal
# Violência doméstica
# Crimes contra a pessoa | Outros
# Furto simples
# Furto qualificado
# Roubo simples
# Roubo qualificado
# Latrocínio


