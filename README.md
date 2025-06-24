# 📊 Análise da Variação Populacional e Domiciliar em Maceió (2010–2022)

Este repositório reúne o código e as instruções para baixar, processar e visualizar os dados da **Grade Estatística** do IBGE, com foco na cidade de **Maceió**, comparando os Censos Demográficos de 2010 e 2022. A análise é baseada em geoprocessamento das grades censitárias com base territorial hexagonal e visa identificar variações espaciais da população e do total de domicílios ocupados.

---

## 🌍 Contexto

Maceió está contida na **grade estatística de 500x500 km de ID 58**, segundo a divisão espacial disponibilizada pelo IBGE.

### Como descobrir a grade para outras cidades:
- **Opção 1**: Acesse o [Portal de Mapas do IBGE](https://portaldemapas.ibge.gov.br/), busque por "grade estatística" e localize sua cidade.
- **Opção 2**: Consulte a [imagem de articulação das grades 500x500 km](https://geoftp.ibge.gov.br/recortes_para_fins_estatisticos/grade_estatistica/censo_2010/articulacao.jpg).

---

## 🛠️ Requisitos

Instale os pacotes R abaixo, caso ainda não os tenha:

```r
install.packages(c("tidyverse", "sf", "leaflet", "plotly"))
remotes::install_github("ipeaGIT/geobr")
```

## 📦 Download e Processamento dos Dados
O script realiza as seguintes etapas:

### Download das grades estatísticas para o ID 58:

Grade ID58 – Censo 2010

Grade ID58 – Censo 2022

Extração dos arquivos .shp e remoção dos arquivos .zip.

Leitura das grades e do município de Maceió via geobr.

### Geoprocessamento:

Interseção espacial entre as grades e o município (com buffer de 500m).

Junção das grades 2010 e 2022 pela chave ID_UNICO.

Cálculo das variações absolutas de população (varpop) e domicílios ocupados (vardom).

## 🗺️ Visualização
A visualização é feita com o pacote leaflet. O mapa interativo mostra a variação no número de domicílios ocupados (vardom) entre 2010 e 2022.

Tons de vermelho indicam redução.

Tons de azul indicam aumento.


