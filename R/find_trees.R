find_trees <- function(las, buffer = NULL, verbose = FALSE) {
  f <- function(x) {
    y <- 2.6 * (-(exp(-0.08 * (x - 2)) - 1)) + 3
    y[x < 2] <- 3
    y[x > 20] <- 5
    return(y)
  }

  if (is(las, "LAS")) {
    normalized_las <- lidR::normalize_height(las, algorithm = lidR::knnidw())
    trees_poi <- lidR::filter_poi(normalized_las, Classification %in% c(3L, 4L, 5L) & Z <=30)
    tree_tops <- lidR::locate_trees(trees_poi, algorithm = lidR::lmf(ws = f))
    
    if (verbose == TRUE) {
      #Ploting tree top locations on top of a total dsm
      dsm <- my_rasterize_canopy(normalized_las, res = 0.25, keep_class = c(2, 3, 4, 5, 6, 9))
      lidR::plot(dsm, col = lidR::height.colors(50))
      
      tree_tops |>  sf::st_geometry() |> lidR::plot(add = TRUE, pch = 3)
      x <- normalized_las |> lidR::plot(bg = "black", size = 2, legend = TRUE)
      lidR::add_treetops3d(x, tree_tops)
    }
    return(tree_tops)
  } else {
    return("LAScatalog not suported yet")
  }
}