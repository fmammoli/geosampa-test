test_that("download and load dtm quadricles shapefile", {
  resp <- get_quadricles_shapefile()
  expect_equal(is.data.frame(resp), TRUE)
})


test_that("return quadricles if it already exists", {
  resp <- get_quadricles_shapefile()
  expect_equal(is.data.frame(resp), TRUE)
})
