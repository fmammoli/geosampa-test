test_that("should load a lidR las catalog based on a file list", {
  files <- c(
    paste0(getwd(), "/temp", "/data", "/lidar", "/MDS_3324-164_1000.laz"),
    paste0(getwd(),  "/temp", "/data", "/lidar", "/MDS_3324-243_1000.laz")
  )
  print(files)
  catalog <- load_lidar_data(files)
  
  expect_equal(0, 0)
})
