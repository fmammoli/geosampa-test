create_dir <- function(...) {
  
  path <- c(
    ...
  ) |>
    paste0(collapse = "/")
  
  if (!dir.exists(path)) {
    dir.create(path, recursive = TRUE)
  }

  return(path)
}
