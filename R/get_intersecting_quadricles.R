get_intersecting_quadricles <- function(sf_focus) {
  default_buffer <- 100
  dtm_quadricles <- get_quadricles_shapefile()

  focus <- sf_focus
  
  if (all.equal(sf_focus$geometry |> class(), c("sfc_POINT", "sfc")) == TRUE) {
    focus <- sf::st_buffer(sf_focus, dist = default_buffer)
  }

  resp <- sf::st_intersects(focus, dtm_quadricles)
  
  if (length(resp) == 0) return("coordinates are not in Sao Paulo")

  quadricles <- dtm_quadricles[resp[[TRUE]], ]
  return(quadricles)
}