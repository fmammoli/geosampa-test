test_that("should build a rayshader diorama", {
  
  path <- paste0(getwd(), "/tests/testthat/", "test-geosampa_diorama.R")

  # Masp
  lat <- -23.561217290737723
  long <- -46.65586044669604
  
  #Catedral da se
  lat <- -23.55110314590466
  long <- -46.6337955339061

  # Oca ibirapuera
  lat <- -23.58611572864106
  long <- -46.65549257670434

  # Ed. Fiesp
  lat <- -23.56326745684227
  long <- -46.654468062036855

  #Copan
  lat <- -23.546398318752424
  long <- -46.64484057116479

  #Geonoma
  lat <- -23.56947281901911
  long <- -46.64909903238793

  coords <- data.frame(
    long = long,
    lat = lat
  ) |>
    sf::st_as_sf(coords = c("long", "lat"), crs = sf::st_crs(4326)) |>
    sf::st_transform(crs = sf::st_crs(31983))
  
  buffer <- sf::st_buffer(coords, 70)

  build_diorama(buffer)
  expect_equal(2 * 2, 4)
})
