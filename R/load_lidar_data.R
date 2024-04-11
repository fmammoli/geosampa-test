source("./R/get_consts.R")
source("./R/create_dir.R")
load_lidar_data <- function(file_list, buffer, filter = "") {
  consts <- get_consts()
  
  buffer_folder <- buffer |>
    sf::st_centroid(buffer) |>
    sf::st_coordinates() |>
    as.character() |>
    paste0(collapse = "_")
  buffer_folder <- gsub("\\.", "-", buffer_folder)
  
  folder_path_opt_output <- create_dir(consts$data_base_folder, "lidR_opt_output", buffer_folder)
  
  
  folder_path <- dirname(unlist(file_list)[1])
  
  tmp_file_path <- tempfile(tmpdir = paste0(folder_path_opt_output, tempdir()))

  # The of read filter syntax, lidR uses the lastools
  # https://lastools.github.io/download/las2las_README.md
  filter <- paste0(
    "-first_only ",
    "-inside_circle ",
    buffer |> sf::st_centroid() |> sf::st_coordinates() |> as.list() |> paste0(collapse = " "),
    " ",
    sf::st_distance(sf::st_centroid(buffer), sf::st_boundary(buffer)) |> as.numeric() |> round(),
    " ",
    filter,
    collapse = " "
  )
  print(filter)

  #select <- "xyzuicRGB"
  select <- "xyzuc"
  catalog <- lidR::readLAScatalog(folder_path[1], select = select, filter = filter)

  # load lidar data from disk an not from memory
  # it can get too large, like 1gb in memory
  #lidR::opt_output_files(catalog) <- paste0(tmp_file_path, "")
  #lidR::opt_output_files(catalog) <- paste0(tmp_file_path, "/_{ID}")
  
  #Kind of undocumented way to make loading las and laz faster.
  # https://gis.stackexchange.com/questions/450210/r-lidr-catalog-laxindex-spatial-index-options
  catalog@output_options$drivers$LAS$param <- list(index = TRUE)
  
  #Another hidden behaviou
  #https://gis.stackexchange.com/questions/325367/configuring-lidr-catalog-to-overwrite-raster-output-with-different-extension/325369#325369 # nolint: line_length_linter.
  catalog@output_options$drivers$SpatRaster$params$overwrite <- TRUE

  # mds_catalog |> lidR::catalog_apply(function(chunk) {
  #   a <- lidR::readLAS(chunk)
  #   if (lidR::is.empty(a)) return(NULL)
  #   # the lidar data also has RGB values, so maybe I can plot it a little nicely
  #   #attributes(a) |> print()
  #   #print(a@data[["Classification"]] |> unique() |> sort())
  #   #a |> View()
  #   lidR::header(a) |> print()
  #   return(a)
  # })

  return(catalog)
}