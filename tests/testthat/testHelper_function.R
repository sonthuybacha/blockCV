library(blockCV)

context("external helper functions fully")

awt <- raster::brick(system.file("extdata", "awt.grd", package = "blockCV"))
awt_wgs <- raster::projectRaster(awt, crs = sp::CRS("+init=epsg:4326"))
PA <- read.csv(system.file("extdata", "PA.csv", package = "blockCV"))
pa_data <- sf::st_as_sf(PA, coords = c("x", "y"), crs = crs(awt))

test_that("helper function with no CRS", {

  raster::crs(awt_wgs) <- NA

  expect_warning(
    net <- blockCV:::rasterNet(x = awt_wgs, resolution = 70000, mask = TRUE)
  )

  expect_true(exists("net"))
  expect_is(net, "sf")

})

test_that("helper function with no species data", {

  net <- blockCV:::rasterNet(x = pa_data, resolution = 70000, mask = TRUE)

  expect_true(exists("net"))
  expect_is(net, "sf")

})

test_that("helper function error with no block size", {

  expect_error(
    blockCV:::rasterNet(x = awt, mask = TRUE)
  )

})

test_that("helper function error with wrong ofset", {

  expect_error(
    blockCV:::rasterNet(x = pa_data, xOffset = 3)
  )

  expect_error(
    blockCV:::rasterNet(x = pa_data, yOffset = 3)
  )

})
