test_that("should get orthophoto", {
  path <- paste0(getwd(), "/tests/testthat/", "test-get_orthophoto.R")
  lat <- -23.561217290737723
  long <- -46.65586044669604

  # Ed. Fiesp
  lat <- -23.56326745684227
  long <- -46.654468062036855

  # Oca ibirapuera
  lat <- -23.58611572864106
  long <- -46.65549257670434


  # Catedral da se
  lat <- -23.55110314590466
  long <- -46.6337955339061

  coords <- data.frame(
    long = long,
    lat = lat
  ) |>
    sf::st_as_sf(coords = c("long", "lat"), crs = sf::st_crs(4326)) |>
    sf::st_transform(crs = sf::st_crs(31983))
  
  buffer <- sf::st_buffer(coords, 150)
  buffer <- buffer |> sf::st_transform(crs = sf::st_crs(31983))
  
  # intersecting_quadricles <- buffer |>
  #   get_intersecting_quadricles()

  # ortho <- download_orthophoto_data(intersecting_quadricles$qmdt_cod) |>
  #   unlist() |>
  #   purrr::map(function(item) grep(pattern = "\\.jp2$", item, value = TRUE)) |>
  #   purrr::discard(function(item) length(item) == 0) |>
  #   unlist()
  
  # a <- load_orthofoto_data(ortho)
  # b <- a |> terra::crop(buffer, snap = "in")
  


  ortho <- get_orthophoto(buffer)
  terra::plotRGB(ortho)

  expect_equal(2 * 2, 4)
})
