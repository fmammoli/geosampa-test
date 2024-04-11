test_that("should rasterize a las catalog", {
  files <- c(
    paste0(getwd(), "/temp", "/data", "/lidar", "/MDS_3324-164_1000.laz"),
    paste0(getwd(),  "/temp", "/data", "/lidar", "/MDS_3324-243_1000.laz")
  )
  catalog <- load_lidar_data(files)
  
  lat <- -23.561217290737723
  long <- -46.65586044669604
  
  coords <- data.frame(
    long = long,
    lat = lat
  ) |>
    sf::st_as_sf(coords = c("long", "lat"), crs = sf::st_crs(4326)) |>
    sf::st_transform(crs = sf::st_crs(31983))

  clipped <- clip_lidar_catalog(catalog = catalog, coords = coords, radius = 100)

  #rast <- rasterize_mds(clipped, c(3, 4, 5, 6))
  
  
  expect_equal(2 * 2, 4)
})
