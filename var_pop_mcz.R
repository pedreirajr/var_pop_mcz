# Importante:
## Maceió está compreendida na grade de 500 X 500 km de ID 58
### Como descobrir para outras cidades:
#### Opção (1):
##### Acesse https://portaldemapas.ibge.gov.br/, vá em "Busca" e digite "grade estatística"
#### Opção (2):
##### Link da articulação 500 X 500 km: https://geoftp.ibge.gov.br/recortes_para_fins_estatisticos/grade_estatistica/censo_2010/articulacao.jpg

# (0) Adicionando bibliotecas
## Obs.: instalar, caso ainda não as tenha
library(tidyverse); library(sf); library(leaflet); library(plotly); library(geobr)

# (1) Baixando os arquivos da grade estatística
## Links para baixar:
### Checar em "https://geoftp.ibge.gov.br/recortes_para_fins_estatisticos/grade_estatistica/"
#### Censo 2010:
url_id58_2010 <- 'https://geoftp.ibge.gov.br/recortes_para_fins_estatisticos/grade_estatistica/censo_2010/grade_id58.zip'
#### Censo 2022:
url_id58_2022 <- 'https://geoftp.ibge.gov.br/recortes_para_fins_estatisticos/grade_estatistica/censo_2022/grade_estatistica/grade_id58.zip'

## (1a) Fazendo o donwload das urls:
urls <- c(url_id58_2010,url_id58_2022)
names(urls) <- c('id58_2010','id58_2022')

### Criação de pastas para armazenamento dos arquivos
dir_data = 'data'; dir_geo = paste0(dir_data,'/ge_shp')
dir.create(dir_data)
dir.create(dir_geo)

### Download dos arquivos
sapply(urls, function(i) {
  download.file(i,
                destfile = paste0(dir_data,'/',
                                  names(which(i == urls)),
                                  '.zip'
                )
  )
}
)

## (1b) Extraindo os arquivos .shp dos arquivos .zip baixados
### Lista todos os arquivos .zip da pasta '/data'.
zips <- list.files(dir_data, pattern = 'zip')

### Cria diretórios específicos para os censos 2010 e 2022
dir.create(paste0(dir_geo,'/2010'))
dir.create(paste0(dir_geo,'/2022'))

### Extraindo os arquivos .shp
sapply(paste0(dir_data,'/',zips), function(i) {
  if(grepl('2010',i)){
    unzip(i, exdir = paste0(dir_geo,'/2010/'))
  } else
  {unzip(i, exdir = paste0(dir_geo,'/2022/'))}

}
)

### Deletando os arquivos .zip
file.remove(paste0(dir_data,'/',zips))

# (1) Lendo arquivos
## Grades estatísticas
ge58_2010 <- st_read(paste0(dir_geo,'/2010/grade_id58.shp'))
ge58_2022 <- st_read(paste0(dir_geo,'/2022/grade_id58.shp'))

## Mapa de maceió
mcz <- read_municipality(code_muni = geobr::lookup_muni(name_muni = 'Maceió')$code_muni,
                         simplified = F)

mcz <- st_transform(mcz, st_crs(ge58_2010)$epsg)

#(2) Geoprocessamento para obter grades estatísticas de Maceió (2010 e 2022)
## Interseção entre grades estatísticas e arquivo de município (com buffer de 500m)
mcz_ge2010 <- st_intersection(ge58_2010, st_buffer(mcz,500))
mcz_ge2022 <- st_intersection(ge58_2022, st_buffer(mcz,500))

# Produzindo único arquivo de GE com os dois períodos
## Obs.: População é 'POP' no arquivo de 2010 e 'TOTAL' no de 2022
## Obs.: Total de domicílios ocupados é 'DOM_OCU' no arquivo de 2010 e 'TOTAL_DOM' no de 2022
mcz_ge <- mcz_ge2010 %>% 
  select(ID_UNICO,POP,DOM_OCU) %>% 
  left_join(mcz_ge2022 %>% select(ID_UNICO, TOTAL, TOTAL_DOM) %>% 
              st_drop_geometry()) %>% 
  mutate(varpop = TOTAL - POP,
         vardom = TOTAL_DOM - DOM_OCU)

# (3) Visualização
## (3a) Leaflet:
### Criar paleta
max_abs <- max(abs(mcz_ge$vardom), na.rm = TRUE)

pal <- colorNumeric(
  palette = c("#a50f15", "white", "#08519c"),
  domain = c(-max_abs, max_abs),
  na.color = 'transparent'
)

### Visualizar:
leaflet(data = st_transform(mcz_ge,4326)) %>%
  addProviderTiles(providers$Stadia.StamenToner) %>% 
  addPolygons(fillColor = ~pal(vardom),
              fillOpacity = 0.7,
              color = "white",
              weight = 0.5,
              popup = ~paste("Var. Dom.:", 
                             formatC(vardom, format = "d", big.mark = "."))
  ) %>% 
  addLegend(
    pal = pal,
    values = ~vardom,
    title = "Var. Dom. 2010 a 2022",
    position = "bottomright"
  )