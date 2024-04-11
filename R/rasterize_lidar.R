source("./R/get_consts.R")
source("./R/create_dir.R")


rasterize_lidar <- function(
  catalog,
  keep_class,
  res,
  algorithm,
  type
) {
  print(keep_class)
  if (class(catalog) == "LAScatalog") {
    chunk_size <- 0
    chunk_buffer <- 10

    #configuring overlap and subdivisions
    lidR::opt_chunk_size(catalog) <- chunk_size  # chunk de 350 x 350 metros; zero é o valor padrão # nolint: line_length_linter.
    lidR::opt_chunk_buffer(catalog) <- chunk_buffer # sobreposição de 10 metros entre cada chunk; 30 é o valor padrão # nolint: line_length_linter.

    #Another hidden behaviou
    #https://gis.stackexchange.com/questions/325367/configuring-lidr-catalog-to-overwrite-raster-output-with-different-extension/325369#325369 # nolint: line_length_linter.
    catalog@output_options$drivers$SpatRaster$params$overwrite <- TRUE

    #lidR::opt_output_files(catalog) <- tempfile(tmpdir = folder_path_opt_output)
    #lidR::opt_output_files(catalog) <- paste0(tempdir(), "/rasterize/{XCENTER}_{YCENTER}_{ID}")

    # You can load only just some data to make it less memmory intensive
    lidR::opt_filter(catalog) <- paste0("-first_only -keep_class ", paste0(keep_class, collapse = " "))
  }

  consts <- get_consts()
  folder_path_opt_output <- create_dir(
    consts$data_base_folder, "lidar", type, paste0("_", keep_class, collapse = "-"), "opt_output"
  )

  if (type == "canopy") {
    if (identical(algorithm, NULL)) {
      algorithm <- lidR::p2r(subcircle = 0.3)
    }
    digital_surface_model <- lidR::rasterize_canopy(
      las = catalog,
      res = res,
      use_class = keep_class,
      algorithm = algorithm,
      parallel = TRUE,
      pkg = "terra"
    )
    return(digital_surface_model)
  }
  if (type == "terrain") {
    digital_terrain_model <- lidR::rasterize_terrain(
      las = catalog,
      res = res,
      algorithm = algorithm,
      parallel = TRUE,
      pkg = "terra"
    )
    return(digital_terrain_model)
  }
  stop("Unsuported rasterization type, please try 'canopy' or 'terrain'.")
}

my_rasterize_terrain <- function(
  catalog,
  keep_class = c(2L, 9L),
  res = 0.5,
  algorithm = lidR::tin()
) {
  res <- rasterize_lidar(
    catalog = catalog,
    keep_class = keep_class,
    res = res,
    algorithm = algorithm,
    type = "terrain"
  )
  return(res)
}

my_rasterize_canopy <- function(
  catalog,
  keep_class = c(3L, 4L, 5L, 6L),
  res = 0.5,
  algorithm = lidR::p2r(subcircle = 0.3)
) {
  res <- rasterize_lidar(
    catalog = catalog,
    keep_class = keep_class,
    res = res,
    algorithm = algorithm,
    type = "canopy"
  )
  return(res)
}