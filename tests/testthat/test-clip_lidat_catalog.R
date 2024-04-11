test_that("should clip a las catalog based on a sf point", {
  files <- c(
    paste0(getwd(), "/temp", "/data", "/lidar", "/MDS_3324-164_1000.laz"),
    paste0(getwd(),  "/temp", "/data", "/lidar", "/MDS_3324-243_1000.laz")
  )
  print(files)
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
  expect_equal(0, 0)
})
