test_that("multiplication works", {
  path <- paste0(getwd(), "/tests/testthat/", "test-non-geosampa.R")

  text <- "Campinas"
  lat <- -22.91195730335267
  long <- -47.08164484035647

  text <- "Itajuba"
  lat <- -22.425111623079008
  long <- -45.4628749050416

  text <- "Sao Jose dos Campos"
  lat <- -23.213524083221294
  long <- -45.90217699856378

  coord <- data.frame(
    long = long,
    lat = lat
  ) |>
    sf::st_as_sf(coords = c("long", "lat"), crs = sf::st_crs(4326)) |>
    sf::st_transform(crs = sf::st_crs(31983))

  muni_info <- geobr::lookup_muni(name = text)
  muni_data <- geobr::read_municipality(code_muni = muni_info$code_muni, year = 2020)

  elevation_rast <- elevatr::get_elev_raster(locations = muni_data, z = 10, clip = "tile")

  rast <- rayshader::raster_to_matrix(elevation_rast)

  tiles <- maptiles::get_tiles(buffer, crop = TRUE)
  maptiles::plot_tiles(tiles)
  mtext(text = maptiles::get_credit("OpenStreetMap"), side = 1, line = -1, adj = .99)
  
  raster <- terra::crop(tiles, buffer) |> terra::writeRaster("tile.png", overwrite = TRUE)
  overlay <- png::readPNG("tile.png")
  
  #dem <- elevatr::get_elev_raster(buffer, z = 12, clip = "location")

  #terra::plot(dem)
  #elmat <- rayshader::raster_to_matrix(dem)
  elmat <- rast

  lat_lon <- sf::st_coordinates(coord)
  ext <- terra::ext(buffer)


  elmat |>
    rayshader::height_shade() |>
    #rayshader::sphere_shade(texture = "imhof2") |>
    rayshader::plot_3d(
      heightmap = elmat,
      solid = TRUE,
      zscale = 10,
      zoom = .6,
      phi = 45,
      theta = -30,
      windowsize = 800
    )


  elmat |>
    rayshader::sphere_shade(texture = "imhof1") |>
    # rayshader::add_overlay(
    #   overlay,
    #   alphalayer = 0.9
    # ) |>
    # rayshader::add_overlay(
    #   rayshader::generate_label_overlay(
    #     label = text,
    #     x = lat_lon[1], y = lat_lon[2],
    #     extent = terra::ext(buffer),
    #     text_size = 5, color = "red", font = 2,
    #     halo_color = "white", halo_expand = 4, point_size = 2,
    #     seed = 1, heightmap = elmat
    #   )
    # ) |>
    #rayshader::add_shadow(rayshader::ray_shade(elmat, zscale = 3), 0.5) |>
    #rayshader::add_shadow(rayshader::ambient_shade(elmat), 0) |>
    rayshader::plot_3d(
      heightmap = elmat,
      solid = TRUE,
      zscale = 20,
      zoom = .6,
      phi = 45,
      theta = -30,
      windowsize = 800
    )




  rayshader::render_label(
    heightmap = elmat,
    text = "ALOOOOOOOOOOOO",
    lat = lat_lon[1],
    long = lat_lon[2],
    extent = ext,
    altitude = 110,
    clear_previous = TRUE,
    zscale = 3,
    textcolor = "#a13ac3",
    linecolor = "#a13ac3",
    offset = 1,
    linewidth = 4,
  )

  rayshader::render_scalebar(
    limits = c(0, 5, 10),
    label_unit = "km",
    position = "W",
    y = 50,
    scale_length = c(0.33, 1)
  )
})
