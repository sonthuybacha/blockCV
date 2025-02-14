library(blockCV)

context("Spatial Autocorrelation Finder")

expect_names <- c("range",
                  "rangeTable",
                  "plots",
                  "sampleNumber",
                  "variograms")

awt <- raster::brick(system.file("extdata", "awt.grd", package = "blockCV"))
awt <- awt[[1:5]]
nl <- raster::nlayers(awt)

awt2 <- raster::aggregate(awt, 5)
PA <- read.csv(system.file("extdata", "PA.csv", package = "blockCV"))
pa_data <- sf::st_as_sf(PA, coords = c("x", "y"), crs = raster::crs(awt))
awt_wgs <- raster::projectRaster(awt, crs = sp::CRS("+init=epsg:4326"))

test_that("test spatialAutoRange function with multi-layer raster in parallel", {

  range1 <- spatialAutoRange(rasterLayer = awt,
                             sampleNumber = 1000,
                             doParallel = TRUE,
                             nCores = NULL,
                             plotVariograms = TRUE,
                             showPlots = TRUE)

  expect_true(exists("range1"))
  expect_is(range1, "SpatialAutoRange")
  expect_equal(names(range1), expect_names)
  expect_equal(nrow(range1$rangeTable), nl)
  expect_equal(length(range1$variograms), nl)
  expect_equal(dim(range1$rangeTable), c(nl, 3))
  expect_is(range1$plots[[1]], "ggplot")
  expect_is(range1$variograms[[1]], "autofitVariogram")
  expect_is(range1$variograms, "list")
  expect_is(range1$rangeTable, "data.frame")
  expect_is(range1$sampleNumber, "numeric")
  expect_is(range1$range, "numeric")
  expect_true(range1$range >= 0)
  expect_true(!is.null(range1$variograms))
  expect_true(
    all(names(awt) %in% range1$rangeTable$layers)
  )

  expect_equal(print.SpatialAutoRange(range1), "SpatialAutoRange")
  expect_silent(plot.SpatialAutoRange(range1))
  expect_output(summary.SpatialAutoRange(range1))

})


test_that("test spatialAutoRange function with multi-layer raster without parallel processing", {

  raster::crs(awt) <- NA

  expect_warning(
    range2 <- spatialAutoRange(rasterLayer = awt,
                               sampleNumber = 1000,
                               progress = TRUE,
                               doParallel = FALSE,
                               plotVariograms = FALSE,
                               showPlots = FALSE)

  )
  expect_true(exists("range2"))

})

test_that("test spatialAutoRange function with single-layer raster", {

  range3 <- spatialAutoRange(rasterLayer = awt[[1]],
                             sampleNumber = 1000,
                             plotVariograms = TRUE,
                             showPlots = TRUE)

  expect_true(exists("range3"))
  expect_is(range3, "SpatialAutoRange")
  expect_is(range3$plots[[1]], "ggplot")
  expect_is(range3$variograms, "autofitVariogram")
  expect_is(range3$sampleNumber, "numeric")
  expect_is(range3$range, "numeric")
  expect_true(range3$range >= 0)
  expect_true(!is.null(range3$variograms))

  expect_equal(print.SpatialAutoRange(range3), "SpatialAutoRange")
  expect_silent(plot.SpatialAutoRange(range3))

})

test_that("test spatialAutoRange function with single-layer raster and species data", {

  range3 <- spatialAutoRange(rasterLayer = awt[[1]],
                             speciesData = pa_data,
                             plotVariograms = FALSE,
                             showPlots = FALSE)

  expect_true(exists("range3"))
  expect_is(range3, "SpatialAutoRange")
  expect_is(range3$plots[[1]], "ggplot")
  expect_is(range3$variograms, "autofitVariogram")
  expect_is(range3$sampleNumber, "integer")
  expect_is(range3$range, "numeric")
  expect_true(range3$range >= 0)
  expect_true(!is.null(range3$variograms))

  expect_equal(print.SpatialAutoRange(range3), "SpatialAutoRange")
  expect_silent(plot.SpatialAutoRange(range3))

})

test_that("test spatialAutoRange function with species data", {

  range3 <- spatialAutoRange(rasterLayer = awt,
                             speciesData = pa_data,
                             doParallel = TRUE)

  expect_true(exists("range3"))
  expect_is(range3, "SpatialAutoRange")
  expect_is(range3$plots[[1]], "ggplot")
  expect_is(range3$variograms[[1]], "autofitVariogram")
  expect_is(range3$sampleNumber, "integer")
  expect_is(range3$range, "numeric")
  expect_true(range3$range >= 0)
  expect_true(!is.null(range3$variograms))

  expect_equal(print.SpatialAutoRange(range3), "SpatialAutoRange")
  expect_silent(plot.SpatialAutoRange(range3))

})

test_that("test spatialAutoRange for low-resolution rasters", {

  range3 <- spatialAutoRange(rasterLayer = awt2,
                             sampleNumber = 5000,
                             doParallel = FALSE)

  expect_true(exists("range3"))
  expect_is(range3, "SpatialAutoRange")
  expect_is(range3$plots[[1]], "ggplot")
  expect_is(range3$variograms[[1]], "autofitVariogram")
  expect_is(range3$sampleNumber, "integer")
  expect_is(range3$range, "numeric")
  expect_true(range3$range >= 0)
  expect_true(!is.null(range3$variograms))

  expect_equal(print.SpatialAutoRange(range3), "SpatialAutoRange")
  expect_silent(plot.SpatialAutoRange(range3))

})

test_that("test spatialAutoRange with no parallel and species data", {

  range3 <- spatialAutoRange(rasterLayer = awt,
                             speciesData = pa_data,
                             doParallel = FALSE)

  expect_true(exists("range3"))
  expect_is(range3, "SpatialAutoRange")
  expect_is(range3$plots[[1]], "ggplot")
  expect_is(range3$variograms[[1]], "autofitVariogram")
  expect_is(range3$sampleNumber, "integer")
  expect_is(range3$range, "numeric")
  expect_true(range3$range >= 0)
  expect_true(!is.null(range3$variograms))

  expect_equal(print.SpatialAutoRange(range3), "SpatialAutoRange")
  expect_silent(plot.SpatialAutoRange(range3))

})

test_that("test spatialAutoRange function with WGS84 raster", {

  # pa_data_wgs <- sf::st_transform(pa_data, crs = raster::crs(awt_wgs))
  range1 <- spatialAutoRange(rasterLayer = awt_wgs,
                             # speciesData = pa_data_wgs,
                             doParallel = TRUE,
                             showPlots = FALSE)

  expect_true(exists("range1"))
  expect_is(range1, "SpatialAutoRange")
  expect_equal(names(range1), expect_names)
  expect_is(range1$range, "numeric")
  expect_true(range1$range >= 0)
  expect_true(!is.null(range1$variograms))
  expect_true(
    all(names(awt_wgs) %in% range1$rangeTable$layers)
  )

})

test_that("test spatialAutoRange function with WGS84 raster with NA crs", {

  raster::crs(awt_wgs) <- NA
  # pa_data_wgs <- sf::st_transform(pa_data, crs = raster::crs(awt_wgs))
  range1 <- spatialAutoRange(rasterLayer = awt_wgs,
                             # speciesData = pa_data_wgs,
                             doParallel = FALSE,
                             showPlots = FALSE)

  expect_true(exists("range1"))
  expect_is(range1, "SpatialAutoRange")
  expect_equal(names(range1), expect_names)
  expect_is(range1$range, "numeric")
  expect_true(range1$range >= 0)
  expect_true(!is.null(range1$variograms))
  expect_true(
    all(names(awt_wgs) %in% range1$rangeTable$layers)
  )

})

test_that("test spatialAutoRange for factor rasters", {

  awt2[[1]] <- raster::reclassify(awt2[[1]], c(-Inf, 20, 1, 20, Inf, 2))
  awt2 <- raster::stack(awt2)
  awt2[[1]] <- raster::ratify(awt2[[1]])
  expect_error(
    spatialAutoRange(rasterLayer = awt2[[1:3]],
                     sampleNumber = 1000)
  )

})

test_that("test spatialAutoRange for wrong input", {

  expect_error(spatialAutoRange(rasterLayer = "awt[[1]]",
                                sampleNumber = 1000))

  expect_error(spatialAutoRange(rasterLayer = awt[[1]],
                                speciesData = "pa_data"))


})
