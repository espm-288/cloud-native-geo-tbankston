---
  title: "6: duckdb"
author: Carl Boettiger
date: "2024-03-06"
---
  
  ```{r message = FALSE}
library(duckdbfs)
library(dplyr)
library(sf)
```


```{r}
# SQL

pad <- open_dataset("https://data.source.coop/cboettig/pad-us-3/pad-us3-combined.parquet")

pad_meta <- duckdbfs::st_read_meta("https://data.source.coop/cboettig/pad-us-3/pad-us3-combined.fgb", tblname = "pad_meta")
pad_meta
```


```{r}
pad |> 
  filter(State_Nm == "CA") |> 
  group_by(FeatClass) |> 
  summarise(total_area = sum(SHAPE_Area),
            n = n()) |>
  collect()
```

```{r}
duckdbfs::load_spatial()
```


Reading in as a normal tibble, and then converting to a spatial object:
  
  ```{r}
ca_fee <- pad |> 
  filter(State_Nm == "CA", FeatClass == "Fee") |> 
  collect()

ca_fee |> st_as_sf(sf_column_name = "geometry", crs = pad_meta$wkt)
```

Similarly, any normal data frame can be coerced to a spatial `sf` object, e.g.:
  ```{r}
data.frame(lon = c(1,2), lat=c(0,0)) |> st_as_sf(coords = c("lon", "lat"), crs=4326)
```


```{r}
spatial_ex <- paste0("https://raw.githubusercontent.com/cboettig/duckdbfs/",
                     "main/inst/extdata/spatial-test.csv") |>
  open_dataset(format = "csv") 

spatial_ex |>
  mutate(geometry = st_point(longitude, latitude)) |>
  to_sf(crs = 4326)
```
```{r}
ca_fee <- pad |> 
  filter(State_Nm == "CA", FeatClass == "Fee") |> 
  group_by(Own_Type) |>
  summarise(total = sum(SHAPE_Area)) |> head(1000) |> collect()

```

```{r}
before_fire_tifs <- "/vsicurl/https://huggingface.co/spaces/cboettig/shiny-app/resolve/main/before_fire/cube_d36238205702022-05-25.tif"
after_fire_tifs <- "/vsicurl/https://huggingface.co/spaces/cboettig/shiny-app/resolve/main/after_fire/cube_d36482e5462022-05-30.tif"
before_fire_nbr <- read_stars(before_fire_tifs)
after_fire_nbr <- read_stars(after_fire_tifs)
dnbr <- before_fire_nbr - after_fire_nbr
```
