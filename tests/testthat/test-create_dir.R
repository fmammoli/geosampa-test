test_that("create a dir inside the temp folder", {
  value1 <- "test_dir"
  value2 <- "test_dir2"
  path <- create_dir(value1, value2)

  expect_equal(dir.exists(paste0(getwd(), "/", value1, "/", value2)), TRUE)
})
