
library(tidyverse)

# DAGI Data ---------------------------------------------------------------
geo_sogne_raw                             <- sf::read_sf("https://api.dataforsyningen.dk/sogne/?format=geojson")
geo_regioner_raw                          <- sf::read_sf("https://api.dataforsyningen.dk/regioner/?format=geojson")
geo_kommuner_raw                          <- sf::read_sf("https://api.dataforsyningen.dk/kommuner/?format=geojson")
geo_postnumre_raw                         <- sf::read_sf("https://api.dataforsyningen.dk/postnumre/?format=geojson")
geo_opstillingskredse_raw                 <- sf::read_sf("https://api.dataforsyningen.dk/opstillingskredse/?format=geojson")
geo_afstemningsomraader_raw               <- sf::read_sf("https://api.dataforsyningen.dk/afstemningsomraader/?format=geojson")
geo_landsdele_raw                         <- sf::read_sf("https://api.dataforsyningen.dk/landsdele/?format=geojson")
geo_menighedsraadsafstemningsomraader_raw <- sf::read_sf("https://api.dataforsyningen.dk/menighedsraadsafstemningsomraader/?format=geojson")
geo_politikredse_raw                      <- sf::read_sf("https://api.dataforsyningen.dk/politikredse/?format=geojson")
geo_retskredse_raw                        <- sf::read_sf("https://api.dataforsyningen.dk/retskredse/?format=geojson")
#geo_storkredse_raw                        <- sf::read_sf("https://api.dataforsyningen.dk/storkredse/?format=geojson")
#geo_valglandsdele_raw                     <- sf::read_sf("https://api.dataforsyningen.dk/valglandsdele/?format=geojson")

geo_sogne_high                        <- sf::st_as_sf(rmapshaper::ms_simplify(keep=0.08,input = as(geo_sogne_raw, 'Spatial')))
geo_regioner                          <- sf::st_as_sf(rmapshaper::ms_simplify(keep=0.02,input = as(geo_regioner_raw, 'Spatial')))
geo_kommuner                          <- sf::st_as_sf(rmapshaper::ms_simplify(keep=0.03,input = as(geo_kommuner_raw, 'Spatial')))
geo_postnumre                         <- sf::st_as_sf(rmapshaper::ms_simplify(keep=0.02,input = as(geo_postnumre_raw, 'Spatial')))
geo_opstillingskredse                 <- sf::st_as_sf(rmapshaper::ms_simplify(keep=0.02,input = as(geo_opstillingskredse_raw, 'Spatial')))
geo_afstemningsomraader               <- sf::st_as_sf(rmapshaper::ms_simplify(keep=0.02,input = as(geo_afstemningsomraader_raw, 'Spatial')))
geo_landsdele                         <- sf::st_as_sf(rmapshaper::ms_simplify(keep=0.02,input = as(geo_landsdele_raw, 'Spatial')))
geo_menighedsraadsafstemningsomraader <- sf::st_as_sf(rmapshaper::ms_simplify(keep=0.015,input = as(geo_menighedsraadsafstemningsomraader_raw, 'Spatial')))
geo_politikredse                      <- sf::st_as_sf(rmapshaper::ms_simplify(keep=0.02,input = as(geo_politikredse_raw, 'Spatial')))
geo_retskredse                        <- sf::st_as_sf(rmapshaper::ms_simplify(keep=0.02,input = as(geo_retskredse_raw, 'Spatial')))

geo_sogne_high                        <- geo_sogne_high                             %>% rename(changed = ændret, geo_changed = geo_ændret)
geo_regioner                          <- geo_regioner                          %>% rename(changed = ændret, geo_changed = geo_ændret)
geo_kommuner                          <- geo_kommuner                          %>% rename(changed = ændret, geo_changed = geo_ændret)
geo_postnumre                         <- geo_postnumre                         %>% rename(changed = ændret, geo_changed = geo_ændret)
geo_opstillingskredse                 <- geo_opstillingskredse                 %>% rename(changed = ændret, geo_changed = geo_ændret)
geo_afstemningsomraader               <- geo_afstemningsomraader               %>% rename(changed = ændret, geo_changed = geo_ændret)
geo_landsdele                         <- geo_landsdele                         %>% rename(changed = ændret, geo_changed = geo_ændret)
geo_menighedsraadsafstemningsomraader <- geo_menighedsraadsafstemningsomraader %>% rename(changed = ændret, geo_changed = geo_ændret)
geo_politikredse                      <- geo_politikredse                      %>% rename(changed = ændret, geo_changed = geo_ændret)
geo_retskredse                        <- geo_retskredse                        %>% rename(changed = ændret, geo_changed = geo_ændret)


# Statistics Denmark Data -------------------------------------------------
SOGN1 <- statsDK::sdk_retrieve_data("SOGN1", Tid = "2021")
FOLK1A <- statsDK::sdk_retrieve_data("FOLK1A", Tid = "2021K1")


# Parrish -----------------------------------------------------------------
data_sogne <- SOGN1 %>%
  mutate(ALDER = as.numeric(str_extract(ALDER, "[:digit:]+"))) %>%
  separate(SOGN,into = c("kode","SOGN"),sep=" ",extra="merge") %>%
  separate(SOGN,into = c("sogn","area","last"),sep="[\\(\\)]",extra="merge") %>%
  group_by(sogn, kode, area) %>%
  summarize(population = sum(INDHOLD, na.rm=T),
            men        = sum(INDHOLD[KØN=="Men"]),
            women      = sum(INDHOLD[KØN=="Women"]),
            pct_men    = men/population*100,
            avg_age    = weighted.mean(ALDER, w = INDHOLD),
            stat_year  = first(TID)) %>% ungroup()


# County ------------------------------------------------------------------
data_kommuner <- FOLK1A %>%
  filter(KØN != "Total", CIVILSTAND=="Total", OMRÅDE != "All Denmark", ALDER != "Total") %>%
  filter(!(str_detect(OMRÅDE, "Region"))) %>%
  mutate(ALDER = as.numeric(str_extract(ALDER, "[:digit:]+")),
         area = OMRÅDE) %>%
  group_by(area) %>%
  summarize(population = sum(INDHOLD, na.rm=T),
            men        = sum(INDHOLD[KØN=="Men"]),
            women      = sum(INDHOLD[KØN=="Women"]),
            pct_men    = men/population*100,
            avg_age    = weighted.mean(ALDER, w = INDHOLD),
            stat_year  = first(TID))%>%
  mutate(navn = if_else(area == "Copenhagen","København",area))


# Region ------------------------------------------------------------------
data_regioner <- FOLK1A %>%
  filter(KØN != "Total", CIVILSTAND=="Total", OMRÅDE != "All Denmark", ALDER != "Total") %>%
  filter(str_detect(OMRÅDE, "Region")) %>%
  mutate(ALDER = as.numeric(str_extract(ALDER, "[:digit:]+")),
         navn = OMRÅDE) %>%
  group_by(navn) %>%
  summarize(population = sum(INDHOLD, na.rm=T),
            men        = sum(INDHOLD[KØN == "Men"]),
            women      = sum(INDHOLD[KØN == "Women"]),
            pct_men    = men/population * 100,
            avg_age    = weighted.mean(ALDER, w = INDHOLD),
            stat_year  = first(TID))


geo_sogne    <- left_join(geo_sogne, data_sogne, by="kode")
geo_regioner <- left_join(geo_regioner, data_regioner, by="navn")
geo_kommuner <- left_join(geo_kommuner, data_kommuner, by="navn")


save(geo_sogne,                             file="geo_sogne.rdata")
save(geo_regioner,                          file="geo_regioner.rdata")
save(geo_kommuner,                          file="geo_kommuner.rdata")
save(geo_postnumre,                         file="geo_postnumre.rdata")
save(geo_opstillingskredse,                 file="geo_opstillingskredse.rdata")
save(geo_afstemningsomraader,               file="geo_afstemningsomraader.rdata")
save(geo_landsdele,                         file="geo_landsdele.rdata")
save(geo_menighedsraadsafstemningsomraader, file="geo_menighedsraadsafstemningsomraader.rdata")
save(geo_politikredse,                      file="geo_politikredse.rdata")
save(geo_retskredse,                        file="geo_retskredse.rdata")


FOLK1A14 <- statsDK::sdk_retrieve_data("FOLK1A", Tid = "2014K1")
SOGN114 <- statsDK::sdk_retrieve_data("SOGN1", Tid = "2014")

std_kommuner <- FOLK1A14 %>%
  filter(KØN != "Total", CIVILSTAND == "Total", OMRÅDE != "All Denmark", ALDER != "Total") %>%
  filter(!(str_detect(OMRÅDE, "Region"))) %>%
  mutate(ALDER = as.numeric(str_extract(ALDER, "[:digit:]+")),
         area = OMRÅDE) %>%
  mutate(area = if_else(area == "Copenhagen","København",area)) %>%
  select(-CIVILSTAND,-OMRÅDE,-TID)

std_sogne <- SOGN114 %>%
  mutate(ALDER = as.numeric(str_extract(ALDER, "[:digit:]+"))) %>%
  separate(SOGN,into = c("kode","SOGN"),sep=" ",extra="merge") %>%
  separate(SOGN,into = c("sogn","area","last"),sep="[\\(\\)]", extra="merge") %>%
  select(-TID,-last,-area,-sogn)

save(std_kommuner,file="std_kommuner.rdata")
save(std_sogne,file="std_sogne.rdata")

save(geo_sogne_high,file="geo_sogne_high.rdata")
#flk <- FOLK1A14 %>%
#  filter(KØN != "Total", CIVILSTAND == "Total", OMRÅDE != "All Denmark", ALDER != "Total") %>%
#  filter(!(str_detect(OMRÅDE, "Region"))) %>%
#  mutate(ALDER = as.numeric(str_extract(ALDER, "[:digit:]+")),
#         area = OMRÅDE,
#         value = INDHOLD,
#         age_grp = cut(ALDER,breaks=seq(0,130,15),right=F)) %>%
#  pivot_wider(names_from=age_grp,values_from = value) %>%
#  select(-ALDER, -INDHOLD) %>%
#  group_by(area,KØN) %>%
#  summarize(across(where(is.numeric),sum, na.rm=T)) %>%
#  pivot_wider(names_from = KØN, values_from=where(is.numeric)) %>%
#  pivot_longer(names_to = "variable", values_to="num", cols=where(is.numeric)) %>%
#  ungroup()  %>%
#  mutate(num = if_else(num==0, 1,num))%>%
#  mutate(INCIDENS = round(runif(min = 0,max = 8,n = n())),
#         rate = INCIDENS/num) %>%
#  group_by(variable) %>%
#  mutate(ref_pop=sum(num)) %>%
#  group_by(area) %>%
#  summarize(incidens = sum(INCIDENS)/sum(num),
#            justeret_incidens = sum(rate*ref_pop)/sum(ref_pop))

