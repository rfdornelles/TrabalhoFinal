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
  select(`Nome do Estabelecimento`, Município, UF, CEP, `Código IBGE`,
         capacidade_mas = `1.3 Capacidade do estabelecimento | Masculino | Total`,
         capacidade_fem = `1.3 Capacidade do estabelecimento | Feminino | Total`,
         populacao = `4.1 População prisional | Total`) %>%
  janitor::clean_names()

# Nas capacidades preciso substituir NA por 0

infopen_limpo <- purrr::map_df(infopen_limpo,
                               ~tidyr::replace_na(.x, replace = 0))

# Salvar e deixar o original como bakcup
infopen <- infopen_limpo
rm(infopen_limpo)

#### Arrumar ####

# Acrescentar taxa de ocupação: populacao/capacidade * 100

infopen <- infopen %>%
  mutate(
    tx.ocupacao = populacao/(capacidade_mas + capacidade_fem)*100
  )

# Acrescentar capacidade_tot

infopen <- infopen %>%
  mutate(
    capacidade_tot = capacidade_fem + capacidade_mas
  )

# Acrescentar perfil: masculina, feminina, mista

infopen <- infopen %>%
  mutate(
    perfil = case_when(
      capacidade_mas > 0 & capacidade_fem == 0 ~ "masculina",
      capacidade_fem > 0 & capacidade_mas == 0 ~ "feminina",
      capacidade_fem > 0 & capacidade_mas > 0 ~ "mista",
      TRUE ~ "outros"
    ))

# Acrescentar se é superlotada ou não

infopen <- infopen %>%
  mutate(
    superlotada = if_else(tx.ocupacao <= 100, FALSE, TRUE)
  )

#### Exploração ####

infopen %>% summary()

graf_infopen <- infopen %>%
  ggplot(aes(x = capacidade_tot,
             y = populacao))

ggplot(infopen) +
  geom_histogram(aes(x = capacidade_tot))

graf_infopen +
  geom_point(aes(color = superlotada)) +
  geom_smooth(method = "lm", se = FALSE) +
  facet_wrap(~perfil)


#### Análises ####

# Como é a superlotação por Estado?


# Como é a distribuição de vagas / pessoas presas por estado?

infopen %>%
  group_by(uf) %>%
  mutate(
    capacidade = capacidade_mas + capacidade_fem
  ) %>%
  summarise(
    capacidade_total = sum(capacidade),
    capacidade_media = mean(capacidade),
    capacidade_mediana = mean(capacidade),
    populacao_total = sum(populacao),
    populacao_media = mean(populacao),
    populacao_mediana = median(populacao)
  )

# Quantas unidades são superlotadas / diferença nessas unidades

# Quanto da pop está em superlotação

infopen %>%
  group_by(superlotada) %>%
  summarise(soma = sum(populacao))

# Focando em SP:

infopen_sp <- infopen %>%
  filter(uf == "SP")

graf_infopen_sp <- infopen_sp %>%
  ggplot(aes(x = (capacidade_mas+capacidade_fem),
             y = populacao))

ggplot(infopen_sp) +
  geom_histogram(aes(x = (capacidade_mas+capacidade_fem)))

graf_infopen_sp +
  geom_point(aes(color = superlotada)) +
  geom_smooth(method = "lm", se = FALSE) +
  facet_wrap(~perfil)

infopen_sp %>%
  ggplot(aes(x = )) +
  geom_histogram()

  # Quantos municípios possuem unidades prisionais

infopen_sp %>%
  group_by() %>%



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


