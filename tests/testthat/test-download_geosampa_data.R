test_that("should download lidar data and return list of filename, or return just filenames", {  
  cells <- c("3314-243", "3314-164")

  consts <- get_consts()

  resp <- download_lidar_data(cells)
  lidar_data_files <- c(
    paste0(getwd(), "/", consts$data_base_folder, "/lidar", "/MDS_3314-164_1000.laz"),
    paste0(getwd(), "/", consts$data_base_folder, "/lidar", "/MDS_3314-243_1000.laz")
  )
  
  expect_equal(resp |> sort(), lidar_data_files |> sort())
})

test_that("should download orthophoto data and return list of filename, or return just filenames", {
  cells <- c("3314-243", "3314-164")

  consts <- get_consts()

  resp <- download_orthophoto_data(cells)
  orthophoto_data_files <- c(
    paste0(getwd(), "/", consts$data_base_folder, "/orthophoto", "/T_ORTO_3314-164_RGB_1000.jp2"),
    paste0(getwd(), "/", consts$data_base_folder, "/orthophoto", "/T_ORTO_3314-243_RGB_1000.jp2")
  )
  
  expect_equal(resp |> unlist() |> sort(), orthophoto_data_files |> sort())
})
