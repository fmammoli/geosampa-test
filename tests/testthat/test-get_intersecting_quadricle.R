test_that("should return the intersecting quadricles based on coords", {
  dtm_quadricles <- get_quadricles_shapefile()
  
  lat <- -23.561217290737723
  long <- -46.65586044669604
  
  coords <- data.frame(
    long = long,
    lat = lat
  ) |>
    sf::st_as_sf(coords = c("long", "lat"), crs = sf::st_crs(4326)) |>
    sf::st_transform(crs = sf::st_crs(31983))
  
  # it is giving different results depending if I send coords of buffer
  intercepting_quadricles <- get_intersecting_quadricles(coords)
  
  #this plot stuff is still not working
  # not sure why, probably the crs is wrong somehow
  #plot(dtm_quadricles, col = "white")
  #plot(intercepting_quadricles, add = TRUE, col = "yellow")
  #plot(buffer,  add = TRUE, col = "blue")

  expect_equal(intercepting_quadricles$qmdt_cod, c("3314-243", "3314-164"))
})

test_that("should return the intersecting quadricles based on buffer", {
  dtm_quadricles <- get_quadricles_shapefile()
  
  lat <- -23.561217290737723
  long <- -46.65586044669604
  
  coords <- data.frame(
    long = long,
    lat = lat
  ) |>
    sf::st_as_sf(coords = c("long", "lat"), crs = sf::st_crs(4326)) |>
    sf::st_transform(crs = sf::st_crs(31983))
  
  # it is giving different results depending if I send coords of buffer
  buffer <- sf::st_buffer(coords, 100)
  intercepting_quadricles <- get_intersecting_quadricles(buffer)
  

  #this plot stuff is still not working
  # not sure why, probably the crs is wrong somehow
  #plot(dtm_quadricles, col = "white")
  #plot(intercepting_quadricles, add = TRUE, col = "yellow")
  #plot(buffer,  add = TRUE, col = "blue")

  expect_equal(intercepting_quadricles$qmdt_cod, c("3314-243", "3314-164"))
})
