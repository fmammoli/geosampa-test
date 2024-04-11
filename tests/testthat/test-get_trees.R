test_that("should find and render trees", {
  print_mem_size <- function(obj) {
    print(paste("Size in MB: ", format(object.size(b), units = "Mb")))
  }
  local_load <- function() {
    path <- paste0(getwd(), "/tests/testthat/", "test-get_trees.R")

    #NOT WORKING
    # Masp
    lat <- -23.561217290737723
    long <- -46.65586044669604
    text <- "MASP"
    
    # # Catedral da se
    # lat <- -23.55110314590466
    # long <- -46.6337955339061
    # text <- "Catedral da Sé"

    # # Oca ibirapuera
    # lat <- -23.58611572864106
    # long <- -46.65549257670434

    # # Ed. Fiesp
    # lat <- -23.56326745684227
    # long <- -46.654468062036855

    #Copan
    lat <- -23.546398318752424
    long <- -46.64484057116479
    text <- "Ed. Copan"

    #Geonoma
    # lat <- -23.56947281901911
    # long <- -46.64909903238793
    # text <- "Geonoma"

    coords <- data.frame(
      long = long,
      lat = lat
    ) |>
      sf::st_as_sf(coords = c("long", "lat"), crs = sf::st_crs(4326))
      
    
    def_buffer <- sf::st_buffer(coords, 100)
    buffer <- coords |> sf::st_transform(crs = sf::st_crs(31983)) |> sf::st_buffer(100)
    return(list(buffer, text, def_buffer))
  }

  initial_data <- local_load()
  buffer <- initial_data[[1]]
  text <- initial_data[[2]]
  def_buffer <- initial_data[[3]]

  print("Getting lidar data")
  las <- get_lidar(buffer)
  
  #transform las catalog into in memory LAS, just to simplify operations
  if (is(las, "LAScatalog")) {
    las <- las |> lidR::readLAS()
  }
  terra::plot(las)
  print("Getting lidar data --- done")
  
  #print("normalizing height")
  #maybe we dont need it, bacause we have the UserData, that is the normalized Heigth of each point
  #ncatalog <- lidR::normalize_height(catalog, lidR::knnidw())
  #print("normalizing height -- done")
  
  print("finding trees")
  print(las)
  treetops_poi <- find_trees(las, buffer, verbose = FALSE)
  print("finding trees -- done")
  
  print("rasterizing terrain")
  dtm <- my_rasterize_terrain(las, res = 0.25)
  print("rasterizing terrain -- done")
  

  print("Rasterizing buildings")
  #o keep class pro las não tá funcionando direito na rasterização, tem que filtrar antes de mandar
  buildings_poi <- lidR::filter_poi(las, Classification %in% c(6L))
  dsm_buildings <- my_rasterize_canopy(
    buildings_poi,
    keep_class = c(1L, 6L),
    res = 0.25,
    algorithm = lidR::p2r(subcircle = 0.3)
  )

  # terra::plot(dsm_buildings)
  # lidR::plot(dsm_buildings, col = lidR::height.colors(50))
  dsm_buildings
  dtm
  resampled_dtm <- terra::resample(dtm, dsm_buildings)
  dem <- terra::cover(dsm_buildings, resampled_dtm)
  # terra::plot(dem)

  #lidR::plot(dsm, col = lidR::height.colors(50))

  #treetops_poi |>  sf::st_geometry() |> lidR::plot(add = TRUE, pch = 3)
  
  print("Getting Orthophoto")
  orthophoto <- get_orthophoto(buffer)
  
  consts <- get_consts()

  print("Resampling orthophoto based on lidar dimensions and resolution")
  ortho_resampled <- terra::resample(orthophoto, dem)
  
  path <- create_dir("/", consts$rasters_base_folder, "/orthophoto")
  ortho_resampled_path <- paste0(path, "/ortho_resample.png")

  print("Saving resampled orthophoto")
  res <- terra::writeRaster(
    ortho_resampled,
    ortho_resampled_path,
    overwrite = TRUE
  )
  
  orthophoto_layer <- png::readPNG(ortho_resampled_path)
  # terra::plot(resampled_dtm, col = lidR::height.colors(50))
  # Sys.sleep(3)
  # terra::plot(dsm_buildings, add = TRUE, col = lidR::height.colors(50))
  #terra::plot(dem,  col = lidR::height.colors(50))
  #treetops_poi |>  sf::st_geometry() |> lidR::plot(add = TRUE, pch = 3)
  
  # Open data hightway
  bbox <- sf::st_bbox(def_buffer)
  resp <- osmdata::opq(bbox = bbox) |>
    osmdata::add_osm_feature(key = "highway") |>
    osmdata::osmdata_sf()
  resp
  resp$osm_lines
  ggplot2::ggplot() +
    ggplot2::geom_sf(data = resp$osm_lines)

  roads <- sf::st_transform(resp$osm_lines, crs = sf::st_crs(buffer))

  ggplot2::ggplot() +
    ggplot2::geom_sf(data = roads)


  resp2 <- osmdata::opq(bbox = bbox) |>
    osmdata::add_osm_feature(key = "building") |>
    osmdata::osmdata_sf()

  resp2
   ggplot2::ggplot() +
    ggplot2::geom_sf(data = resp2$osm_polygons) +
    ggplot2::geom_sf(data = roads)

  buildings <- sf::st_transform(resp2$osm_polygons, crs = sf::st_crs(buffer))

  lidar_matrix <- rayshader::raster_to_matrix(dem)
  lidar_matrix <- rayshader::raster_to_matrix(dtm)

  lidar_matrix |>
    rayshader::height_shade() |>
    #rayshader::sphere_shade() |>
    rayshader::add_overlay(
      orthophoto_layer,
      alphalayer = 1
    ) |>
    rayshader::add_overlay(
      rayshader::generate_label_overlay(
        label = "Ed. Copan",
        x = 332104.5, y = 7395029,
        extent = terra::ext(buffer),
        text_size = 5, color = "red", font = 2,
        halo_color = "white", halo_expand = 4, point_size = 2,
        seed = 1, heightmap = lidar_matrix
      ), 0
    ) |>
    #rayshader::add_shadow(rayshader::ray_shade(lidar_matrix, zscale = 0.6), 0.5) |>
    #rayshader::add_shadow(rayshader::ambient_shade(lidar_matrix), 0) |>
    rayshader::add_overlay(
      rayshader::generate_line_overlay(
        buffer,
        buffer,
        heightmap = lidar_matrix,
        color = "red"
      ), 0
    ) |>
    rayshader::add_overlay(
      rayshader::generate_line_overlay(
        roads,
        buffer,
        heightmap = lidar_matrix,
        color = "blue",
        linewidth = 3
      ), 1
    ) |>
    rayshader::plot_3d(
      lidar_matrix,
      baseshape = "circle",
      solid = TRUE,
      zscale = 1,
      zoom = .6,
      phi = 45,
      theta = -30,
      windowsize = 800
    )

  rayshader::render_buildings(
    buildings,
    extent = buffer,
    heightmap = lidar_matrix

  )

  tree_locations <- sf::st_coordinates(treetops_poi)
  dem_extent <- terra::ext(dem)
  
  render_my_trees <- function() {
    rayshader::render_tree(
      lat = tree_locations[, 2],
      long = tree_locations[, 1],
      crown_width_ratio = 0.5,
      tree_height = tree_locations[, 3],
      crown_color = "#1d7f1d",
      trunk_height_ratio = 0.2 + 0.1 * runif(nrow(tree_locations)),
      extent = terra::ext(dem),
      clear_previous = TRUE,
      heightmap = lidar_matrix,
      zscale = 1
    )
  }
  
  

  render_my_trees()
  buffer_coords <- buffer |> sf::st_centroid() |> sf::st_coordinates()
  
  render_my_label <- function() {
    return(
      rayshader::render_label(
        heightmap = lidar_matrix,
        lat = buffer_coords[2],
        long = buffer_coords[1],
        extent = dem_extent,
        zscale = 1,
        text = text,
        textsize = 3,
        textcolor = "#a13ac3",
        linecolor = "#a13ac3",
        offset = 1,
        altitude = 140,
        linewidth = 2,
        clear_previous = TRUE,
        freetype = FALSE
      )
    )
  }
  render_my_label()

  rayshader::save_obj()
  # from https://wcmbishop.github.io/rayshader-demo/
  # calculate input vectors for gif frames
  # n_frames <- 84
  # thetas <- transition_values(from = 0, to = 160, steps = n_frames)
  # phis <- transition_values(from = 90, to = 40, steps = n_frames * (2 / 5), one_way = TRUE)
  # phis <- c(phis, rep(40, n_frames * (3 / 5)))
  # print(length(thetas))
  # print(length(phis))
  # # generate gif
  # zscale <- 0.5
  # lidar_matrix |>
  #   rayshader::height_shade() |>
  #   #rayshader::sphere_shade(zscale = zscale) |>
  #   rayshader::add_overlay(
  #     orthophoto_layer,
  #     alphalayer = 1
  #   ) |>
  #   rayshader::add_shadow(ambient_shade(lidar_matrix, zscale = zscale), 0.5) |>
  #   rayshader::add_shadow(ray_shade(lidar_matrix, zscale = zscale, lambert = TRUE), 0.5) |>
  #   save_3d_gif(lidar_matrix, file = "output_label_trees4.gif", duration = 6,
  #               solid = TRUE, shadow = TRUE, water = TRUE, zscale = zscale,
  #               theta = thetas, phi = phis, render_label = render_my_label,
  #               render_trees = render_my_trees, zoom = 0.7)

  # #Remove existing lights and add our own with rgl
  # rgl::pop3d("lights")
  # rgl::light3d(phi=35,theta=90, viewpoint.rel=F, diffuse="#ffffff", specular="#000000")
  # rgl::light3d(phi=-45,theta=-40, viewpoint.rel=F, diffuse="#aaaaaa", specular="#000000")
  expect(2 * 2 == 4)
})
