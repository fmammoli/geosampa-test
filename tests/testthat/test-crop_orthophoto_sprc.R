test_that("crop an terra sprc before creating a mosaic", {
  path <- paste0(getwd(), "/tests/testthat/", "test-crop_orthophoto_sprc.R")
  
  lat <- -23.561217290737723
  long <- -46.65586044669604
  
  coords <- data.frame(
    long = long,
    lat = lat
  ) |>
    sf::st_as_sf(coords = c("long", "lat"), crs = sf::st_crs(4326)) |>
    sf::st_transform(crs = sf::st_crs(31983))
  
  buffer <- sf::st_buffer(coords, 100)
  
  intersecting_quadricles <- get_intersecting_quadricles(buffer)
  
  orthophoto_data_files <- download_orthophoto_data(intersecting_quadricles$qmdt_cod)
  
  #I just need the .jp2 files
  jp2_files <- orthophoto_data_files |>
    unlist() |>
    purrr::map(function(item) grep(pattern = "\\.jp2$", item, value = TRUE)) |>
    purrr::discard(function(item) item |> length() == 0)

  
  orthophotos <- load_orthofoto_data(jp2_files)
  
  cropped_sprc <- crop_orthophoto_sprc(orthophotos, buffer = buffer)
  terra::plotRGB(cropped_sprc[1])
  terra::plotRGB(cropped_sprc[2])
  expect_equal(2 * 2, 4)
})
