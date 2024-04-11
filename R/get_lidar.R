source("./R/get_intersecting_quadricles.R")
source("./R/download_geosampa_data.R")
source("./R/load_lidar_data.R")

get_lidar <- function(buffer, filter = "") {
  intersecting_quadricles <- buffer |>
    get_intersecting_quadricles()
   
  print(paste0("\nIntersecting quadricles: ", intersecting_quadricles$qmdt_cod, collapse = " "))
  
  print("Loading lidar data")
  clipped_lidar_data <- download_lidar_data(intersecting_quadricles$qmdt_cod) |>
    load_lidar_data(buffer, filter) |>
    lidR::clip_roi(buffer)
  print("Loading lidar data -- done")

  return(clipped_lidar_data)
}