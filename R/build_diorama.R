source("./R/get_consts.R")
source("./R/create_dir.R")
source("./R/rasterize_lidar.R")
#options(rgl.useNULL = TRUE, rgl.printRglwidget = TRUE)

#GeoSampa is usually in Sirgas 2000 / something
geosampa_crs <- 31983



get_diorama <- function(buffer, ...) {
  dots <- rlang::list2(...)
  
  buffer <- sf::st_transform(crs = sf::st_crs(geosampa_crs))

  
  las <- get_lidar(buffer)
  
  print("rasterizing terrain")
  dtm <- my_rasterize_terrain(las, res = 0.25)
  print("rasterizing terrain -- done")

  #locating trees
  print("locating trees")
  treetops_poi <- find_trees(las, buffer)
  tree_locations <- sf::st_coordinates(treetops_poi)

  #locating buildings !TODO
  print("locating buldings #TODO - only rasterizing at the moment")
  #o keep class pro las não tá funcionando direito na rasterização, tem que filtrar antes de mandar
  buildings_poi <- lidR::filter_poi(las, Classification %in% c(6L))
  dsm_buildings <- my_rasterize_canopy(
    buildings_poi,
    keep_class = c(1L, 6L),
    res = 0.25,
    algorithm = lidR::p2r(subcircle = 0.3)
  )

  #Building Digital Elevation Model from Buildings and DTM Rasters
  resampled_dtm <- terra::resample(dtm, dsm_buildings)
  dem <- terra::cover(dsm_buildings, resampled_dtm)

  

}

build_diorama <- function(buffer) {
  transformed_buffer <- buffer |> sf::st_transform(crs = sf::st_crs(31983))

  print("\nLoading lidar data")
  lidar_rast1 <- get_lidar(transformed_buffer)
  #lidar_rast2 <- get_lidar(transformed_buffer)

  print("Rasterizing Digital Surface Module")
  dsm <- rasterize_lidar(
    lidar_rast1,
    keep_class = c(6L),
    res = 0.25,
    type = "canopy",
    algorithm = lidR::dsmtin(max_edge = 2)
  )
  #dsm <- rasterize_mds(lidar_rast1, keep_class = c(6L), res = 0.25)
  
  print("Rasterizing Digital Terrain Module")
  dtm <- rasterize_lidar(
    lidar_rast1,
    keep_class = c(2L),
    res = 0.25,
    type = "terrain",
    algorithm = lidR::tin()
  )
  #dtm <- rasterize_dtm(lidar_rast2, res = 0.25)
  
  print("Resampling DTM based on DSM")
  resampled_dtm <- terra::resample(dtm, dsm)
  
  print("Using DTM to cover DSM missing values")
  lidar <- terra::cover(dsm, resampled_dtm)
  
  #terra::plot(lidar)

  print("Getting Orthophoto")
  orthophoto <- get_orthophoto(transformed_buffer)
 
  consts <- get_consts()

  print("Resampling orthophoto based on lidar dimensions and resolution")
  ortho_resampled <- terra::resample(orthophoto, lidar)
  
  path <- create_dir("/", consts$rasters_base_folder, "/orthophoto")
  ortho_resampled_path <- paste0(path, "/ortho_resample.png")

  print("Saving resampled orthophoto")
  res <- terra::writeRaster(
    ortho_resampled,
    ortho_resampled_path,
    overwrite = TRUE
  )
  
  orthophoto_layer <- png::readPNG(ortho_resampled_path)

  lidar_matrix <- rayshader::raster_to_matrix(lidar)
  #lidar_matrix <- lidar_matrix |> rayshader::resize_matrix(scale = 0.5)
  
  print("Rendering lidar with rayshader")
  lidar_matrix |>
    #rayshader::height_shade() |>
    rayshader::sphere_shade() |>
    rayshader::add_overlay(
      orthophoto_layer,
      alphalayer = 0
    ) |>
    rayshader::add_overlay(
      rayshader::generate_label_overlay(
        label = "Ed. Copan",
        x = 332104.5, y = 7395029,
        #sf::st_centroid(buffer) |> sf::st_coordinates(),
        extent = terra::ext(buffer),
        text_size = 5, color = "red", font = 2,
        halo_color = "white", halo_expand = 4, point_size = 2,
        seed = 1, heightmap = lidar_matrix
      )
    ) |>
    #rayshader::add_shadow(rayshader::ray_shade(lidar_matrix, zscale = 0.5), 0.5) |>
    #rayshader::add_shadow(rayshader::ambient_shade(lidar_matrix), 0) |>
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

  # w <- rgl::rglwidget()
  # w
  # widget_fn <- "simple_3d_model.html"
  # htmlwidgets::saveWidget(w, widget_fn)
  # browseURL(widget_fn)
  # rayshader::render_label(
  #   heightmap = lidar_matrix, lat = -23.546398318752424, long = -46.64484057116479,
  #   x = 332104.5, y = 7395029,
  #   extent  = terra::ext(buffer), textcolor = "red", textsize = 2.5,
  #   altitude = 200, zscale = 0.4, text = "Santa Cruz"
  # )
  
  #rayshader::render_highquality(filename = "output.png", preview = TRUE, interactive = FALSE, parallel = TRUE)
}