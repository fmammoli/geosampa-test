get_consts <- function() {
  base_folder <- paste0(getwd(), "/temp")
  download_base_folder <- paste0(base_folder, "/geosampa_downloads")
  data_base_folder <- paste0(base_folder, "/data")
  rasters_base_folder <- paste0(base_folder, "/rasters")
  config <- list(
    "base_folder" = base_folder,
    "download_base_folder" = download_base_folder,
    "data_base_folder" = data_base_folder,
    "rasters_base_folder" = rasters_base_folder
  )
  return(config)
}