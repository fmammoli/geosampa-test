test_that("get geosampa lidar data", {
  pathx <- paste0(getwd(), "/tests/testthat/", "test-get_lidar.R")
  lat <- -23.561217290737723
  long <- -46.65586044669604
  
  coords <- data.frame(
    long = long,
    lat = lat
  ) |>
    sf::st_as_sf(coords = c("long", "lat"), crs = sf::st_crs(4326)) |>
    sf::st_transform(crs = sf::st_crs(31983))
  
  buffer <- sf::st_buffer(coords, 100)

  lidar <- get_lidar(buffer)
  
  expect_equal(2 * 2, 4)
})
