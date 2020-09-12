#### Carregar base ####
library(dplyr)

ssp <- readr::read_rds("data-raw/ssp.rds")

base <- ssp

#### Arrumar ####

# A tabela contem coluna "total" para roubo e estupro. Vou mantê-la no lugar
# das sub-espécies, então vou usar estupro_total e roubo_total

# Havia um erro em cerca de 24k delas, em que o total era inferior a
# soma dos demais. Coloquei um if_else para resolver isso nos casos em que
# ocorria o problema

# Primeiro com roubo
base <- base %>%
  rowwise(mes:delegacia_nome) %>%
  rename(total_roubo = roubo_total) %>% #muda para poder usar starts_with
  mutate(
    roubo_teste = total_roubo >= sum(c_across(starts_with("roubo"))),
    total_roubo = if_else(
       roubo_teste, total_roubo, sum(c_across(starts_with("roubo"))))
    ) %>%
  ungroup() %>%
  select(-starts_with("roubo")) %>%
  rename(roubos = total_roubo)


# Agora com estupro
base <- base %>%
  rowwise(mes:delegacia_nome) %>%
  rename(total_estupro = estupro_total) %>% #muda para poder usar starts_with
  mutate(
    estupro_teste = total_estupro >= sum(c_across(starts_with("estupro"))),
    total_estupro = if_else(
      estupro_teste, total_estupro, sum(c_across(starts_with("estupro"))))
  ) %>%
  ungroup() %>%
  select(-starts_with("estupro")) %>%
  rename(estupro = total_estupro)


# Agora quero corrigir o problema de mais vítimas que ocorrências. Isso
# deve ter acontecido pois algumas ocorrências tiveram múltiplas vítimas.
# Vou alterar com if_else para que, caso haja mais vítimas que o número
# de ocorrências, prevalecer o número de vítimas. Ao final, removemos as
# colunas de vítima para não haver distorção com outros crimes

#base %>% select(contains('vit'))

base <- base %>%
  mutate(
    hom_doloso = if_else(
      vit_hom_doloso > hom_doloso,
      vit_hom_doloso, hom_doloso),
    hom_doloso_acidente_transito = if_else(
      vit_hom_doloso_acidente_transito > hom_doloso_acidente_transito,
      vit_hom_doloso_acidente_transito,
      hom_doloso_acidente_transito),
    latrocinio = if_else(
      vit_latrocinio > latrocinio,
      vit_latrocinio, latrocinio)
  ) %>%
  select(-contains("vit"))


# Reunir furtos
base <- base %>%
  mutate(
    furto = furto_outros + furto_veiculos
  ) %>%
  select(-starts_with("furto_"))

# Reunir CVLI - Crimes violentos letais intencionais
# homicídio doloso, latrocínio, lesão corporal seg. morte
# Isso faz sentido pois em todos os casos a vida foi vulnerada intencional
# mente, mesmo em caso de tentativa (que, por definição, é sempre dolosa)

base <- base %>%
  mutate(
    CVLI = hom_doloso + hom_tentativa + latrocinio + lesao_corp_seg_morte
  )  %>%
  select(-hom_doloso, -hom_tentativa, -latrocinio, -lesao_corp_seg_morte)

# Reunir os crimes de trânsito. Embora existam modalidades tidas como
# dolosas, em realidade estas são oriundas de dolo eventual. Portanto,
# podem receber o mesmo tratamento por terem um elemento de
# não-intencionalidade

base <- base %>%
  rowwise(mes:delegacia_nome) %>%
  mutate(
    transito = sum(c_across(contains("_transito")))
  ) %>%
  ungroup() %>%
  select(-contains("_transito"))

# Renomear lesão corporal dolosa. A culposa será incorporada aos acidentes

base <- base %>%
  rename(lesaocorporal = lesao_corp_dolosa,
         lesaocorporal_culpa = lesao_corp_culposa_outras)

# Renomear homicídios culposos
base <- base %>%
  rename(homicidio_culposo = hom_culposo_outros)


# Salvar no /data
readr::write_rds(base, path = "data/ssp-arrumada.rds")

rm(ssp, base)
