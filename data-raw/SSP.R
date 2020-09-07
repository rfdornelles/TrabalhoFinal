## correlação espacial
# https://www.bigbookofr.com/geospatial.html

# https://geocompr.robinlovelace.net/geometric-operations.html
#remotes::install_github("Nowosad/spDataLarge")

ssp <- readr::read_rds("data/ssp.rds")
covid <- readr::read_rds("data/covid.rds")

library(dplyr)

covid <- covid %>%
  filter(estado == "SP", !is.na(municipio), data == max(data))

mapa_sp <- geobr::read_municipality(code_muni = "SP")

library(ggplot2)

mapa_sp %>%
  ggplot() +
  geom_sf()

mapa_sp

?sf::st_join

sf::st_join

library(sf)
library(raster)
library(dplyr)
library(spData)

covid_loc <- covid %>%
  dplyr::select(municipio, codmun, lat, lon)

st_join(mapa_sp, covid_loc)


