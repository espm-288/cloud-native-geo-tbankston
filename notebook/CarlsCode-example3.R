---
  title: "4: Biodiversity Intactness Index"
author: Carl Boettiger
date: "2024-02-07"
---
  
  ```{r message = FALSE}
library(rstac)
library(gdalcubes)
library(stars)
library(tmap)
library(dplyr)

```

```{r}
library(spData)
box_ca <- spData::us_states |> filter(NAME=="California") |> st_bbox()
```


```{r}
box <- c(xmin=-123, ymin=37, xmax=-121, ymax=39) 
box <- c(box_ca)
items <-  
  stac("https://planetarycomputer.microsoft.com/api/stac/v1")  |>
  stac_search(collections = "io-biodiversity",
              bbox = box,
              limit = 100)  |>
  post_request() |>
  items_sign(sign_planetary_computer())

```




```{r}
col <- stac_image_collection(items$features, asset_names = c("data"))

cube <- cube_view(srs ="EPSG:4326",
                  extent = list(t0 = "2017-01-01", t1 = "2017-12-31",
                                left = box[1], right = box[3],
                                top = box[4], bottom = box[2]),
                  dx = 0.005, dy = 0.005, dt = "P1Y")

data <-  raster_cube(col, cube)
```


```{r}
bii <- data |> slice_time("2017-01-01") |>  st_as_stars()
tm_shape(bii) + tm_raster()
```
