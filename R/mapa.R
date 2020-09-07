filename <- system.file("shape/nc.shp", package="sf")
nc <- st_read(filename)

nc

covid_loc

coordenadas <- covid_loc[, 3:4]

my.sf.point <- st_as_sf(x = covid_loc,
                        coords = c("lat", "lon"),
                        crs = "+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0")

my.sf.point  %>%
  ggplot() +
  geom_sf()


st_join(my.sf.point, mapa_sp)
