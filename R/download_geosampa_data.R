source("./R/get_consts.R")

create_reqs <- function(url_string) {
  req <- httr2::request(url_string) |>
    httr2::req_user_agent("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36") |> # nolint: line_length_linter.
    httr2::req_progress() |>
    httr2::req_cache(tempdir(), debug = TRUE)
  return(req)
}

#Download all cells in parallel
donwload_cells <- function(req_list, path_list) {
  try(resps <- req_list |>
    httr2::req_perform_parallel(
      paths = unlist(path_list),
      on_error = "stop",
      progress = TRUE
    )
  )
  return(resps)
}

build_lidar_url <- function(cell_code) {
  start <- "https://geosampa.prefeitura.sp.gov.br/PaginasPublicas/downloadArquivo.aspx?orig=DownloadMapaArticulacao&arq=MDS_2020%5C" # nolint: line_length_linter.
  end <- ".zip&arqTipo=MAPA_ARTICULACAO"
  url <- paste0(start, cell_code, end)
  return(url)
}

build_orthophoto_url <- function(cell_code) {
  start <- "https://geosampa.prefeitura.sp.gov.br/PaginasPublicas/downloadArquivo.aspx?orig=DownloadMapaArticulacao&arq=ORTOFOTOS_2020_RGB%5C" # nolint: line_length_linter.
  end <- ".zip&arqTipo=MAPA_ARTICULACAO"
  url <- paste0(start, cell_code, end)
  return(url)
}

download_lidar_data <- function(cell_codes) {
  local_data <- get_local_data(cell_codes, "lidar", "*.laz")
  if (length(local_data) > 0) return(local_data)

  resp <- get_geosampa_data(cell_codes = cell_codes, build_lidar_url, "lidar")
  return(resp)
}

download_orthophoto_data <- function(cell_codes, jp2_only = FALSE) {
  local_data <- get_local_data(cell_codes, "orthophoto", "*.jp2")
  if (length(local_data) > 0) return(local_data)

  resp <- get_geosampa_data(cell_codes = cell_codes, build_orthophoto_url, "orthophoto")

  if (jp2_only == TRUE) {
    jp2_files <- resp |>
      unlist() |>
      purrr::map(function(item) grep(pattern = "\\.jp2$", item, value = TRUE)) |>
      purrr::discard(function(item) item |> length() == 0)
    return(jp2_files)
  }
  return(resp)
}

get_local_data <- function(cell_codes, product_name, file_pattern) {
  consts <- get_consts()
  
  data_path <- paste0(getwd(), "/", consts$data_base_folder, "/", product_name)
  
  if (dir.exists(data_path)) {
    files <- list.files(
      path = data_path,
      pattern = file_pattern,
      full.names = TRUE
    )

    file_cell_ids <- files |> purrr::map(function(item) {
      res <- item |> stringr::str_match(pattern = "\\_([0-9]*-[0-9]*)_")
      return(res[, 2])
    })
    
    if (identical(cell_codes |> sort(), file_cell_ids |> unlist() |> sort()) == TRUE) {
      return(files)
    }
  }
  return(c())
}

#Downlaod a data product from geosampa and save it on disk
get_geosampa_data <- function(cell_codes, url_builder, product_name) {
  urls <- purrr::map(cell_codes, function(cell_code) url_builder(cell_code))
  reqs <- purrr::map(urls, create_reqs)

  consts <- get_consts()

  download_path <- create_dir(consts$download_base_folder, product_name)
  
  filenames <- purrr::map(cell_codes, function(cell_code) paste0(download_path, "/", cell_code, "_", product_name, ".zip")) # nolint: line_length_linter.
  
  unzip_path <- create_dir(consts$data_base_folder, "/", product_name)
  resps <- donwload_cells(req_list = reqs, path_list = filenames)
    
  unziped_files <- resps |>
    purrr::map(
      function(resp) unzip(resp$body[1], exdir = unzip_path)
    )

  return(unziped_files)
}