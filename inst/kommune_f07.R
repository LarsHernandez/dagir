
library(rmapshaper)
library(tidyverse)
library(sf)
library(dagir)

# Indlæse gammle kommuner geo ---------------------------------------------
geo_f07_raw <- st_read(dsn=".", layer = "kommune_2007")
geo_f07 <- ms_simplify(input = as(geo_f07_raw, 'Spatial')) %>%
  st_as_sf() %>%
  st_transform(4326)


# Placere centroider ------------------------------------------------------
centroids <- st_transform(geo_f07, 4326) %>%
  st_centroid() %>%
#  st_transform(., '+proj=longlat +ellps=GRS80 +no_defs') %>%
  st_geometry() %>%
  st_coordinates() %>% as_tibble()

geo_f07$visueltcenter_x <- centroids$X
geo_f07$visueltcenter_y <- centroids$Y


# Udregne ny kommune ------------------------------------------------------
pnts_sf <- do.call("st_sfc",c(lapply(1:nrow(centroids),
 function(i) {st_point(as.numeric(centroids[i, ]))}), list("crs" = 4326)))

pnts_trans <- st_transform(pnts_sf, 2163) # apply transformation to pnts sf
tt1_trans <- st_transform(geo_kommuner, 2163)      # apply transformation to polygons sf

lst <- apply(st_intersects(tt1_trans, pnts_trans, sparse = FALSE), 2,
                     function(col) { tt1_trans[which(col), ]$navn})

lst[sapply(lst, is_empty)] <- NA

kom_tabel <- tibble(centroids,
                    kommune = lst %>% unlist(),
                    kommune_f07 = geo_f07$NAVN,
                    kode_f07 = geo_f07$ADM_KODE) %>%
  mutate(kommune = case_when(kode_f07==315~ "Holbæk",
                             kode_f07==411~ "Christiansø",
                             kode_f07==621~ "Kolding",
                             kode_f07==659~ "Ringkøbing-Skjern",
                             kode_f07==779~ "Skive",
                             kode_f07==831~ "Aalborg",
                             TRUE ~ kommune))


save(kom_tabel, file="kom_tabel.rdata")
save(geo_f07, file="geo_f07.rdata")


ggplot(geo_f07) +
  geom_sf(color = "red", fill = NA, size = 0.05) +
  theme_void() +
  geom_point(aes(visueltcenter_x,visueltcenter_y), color="red")

ggplot(geo_kommuner) +
  geom_sf(color = "blue", fill = NA, size = 0.05) +
  theme_void() +
  geom_point(aes(visueltcenter_x,visueltcenter_y), color="blue")

ggplot(geo_f07) +
  geom_sf(color = "red", fill = NA, size = 0.05) +
  geom_sf(data=geo_kommuner, color = "blue", fill = "blue", size = 0.05, alpha=0.3) +
  theme_void() +
  geom_point(aes(visueltcenter_x,visueltcenter_y), color="red")




