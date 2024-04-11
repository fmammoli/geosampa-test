source("./R/get_consts.R")
source("./R/create_dir.R")

get_quadricles_shapefile <- function() {
  consts <- get_consts()
  path <- create_dir(consts$download_base_folder, "dtm_quadricle")
                            
  existing_shape_files <- list.files(path, pattern = ("\\.shp"))
  if (length(existing_shape_files) > 0) {
    dtm_quadricle <- sf::st_read(existing_shape_files[1], quiet = TRUE)
    return(dtm_quadricle)
  }

  dtm_grid_shapefile_url <- "https://geosampa.prefeitura.sp.gov.br/PaginasPublicas/downloadArquivo.aspx?orig=DownloadCamadas&arq=21_Articulacao%20de%20Imagens%5C%5CArticula%E7%E3o%20MDT%5C%5CShapefile%5C%5CSIRGAS_SHP_quadriculamdt&arqTipo=Shapefile" # nolint: line_length_linter.

  req <- httr2::request(dtm_grid_shapefile_url) |>
    httr2::req_user_agent("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36") |> # nolint: line_length_linter.
    httr2::req_progress() |>
    httr2::req_cache(tempdir(), debug = TRUE)
  resp <- req |> httr2::req_perform(path = paste0(path, "/dtm_quadricle.zip"))

  shape_file <- resp$body[1] |>
    unzip(exdir = path) |>
    purrr::pluck(function(item) grep(pattern = ("\\.shp"), x = item, value = TRUE))
  
  unlink(resp$body[1])
  # the shapefile comes with crs = NA, so we set to EPSG:31983 - SIRGAS 2000 / UTM zone 23S
  # since it is the same of the lidar and orthophoto crs
  dtm_quadricle <- sf::st_read(shape_file, crs = sf::st_crs(31983),  quiet = TRUE)
  return(dtm_quadricle)
}