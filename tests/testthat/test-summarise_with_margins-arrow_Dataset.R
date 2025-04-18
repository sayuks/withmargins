test_that(".margin works", {
  data <- get_data_dummy()

  tmp <- tempfile(fileext = ".parquet")
  on.exit(unlink(tmp, recursive = TRUE, force = TRUE))

  arrow::write_parquet(x = data, sink = tmp)

  data <- arrow::open_dataset(tmp)

  actual <- summarize_with_margins(
    .data = data,
    n = dplyr::n(),
    mean = mean(value, na.rm = TRUE),
    .rollup = c(g1, g2, g3),
    .check_margin_name = TRUE,
    .sort = TRUE
  )

  expected <- list(
    dplyr::ungroup(
      dplyr::summarize(
        .data = data,
        n = dplyr::n(),
        mean = mean(value, na.rm = TRUE),
        g1 = "(all)",
        g2 = "(all)",
        g3 = "(all)"
      )
    ),
    dplyr::ungroup(
      dplyr::summarize(
        .data = dplyr::group_by(data, g1),
        n = dplyr::n(),
        mean = mean(value, na.rm = TRUE),
        g2 = "(all)",
        g3 = "(all)",
      )
    ),
    dplyr::ungroup(
      dplyr::summarize(
        .data = dplyr::group_by(data, g1, g2),
        n = dplyr::n(),
        mean = mean(value, na.rm = TRUE),
        g3 = "(all)",
      )
    ),
    dplyr::ungroup(
      dplyr::summarize(
        .data = dplyr::group_by(data, g1, g2, g3),
        n = dplyr::n(),
        mean = mean(value, na.rm = TRUE),
      )
    )
  )
  expected <- lapply(
    expected,
    function(df) {
      relocate_before_union_all.Dataset(df, c("g1", "g2", "g3"))
    }
  )
  expected <- Reduce(dplyr::union_all, expected)
  expected <- dplyr::relocate(.data = expected, g1, g2, g3)
  expected <- dplyr::arrange(.data = expected, g1, g2, g3)

  actual <- dplyr::collect(actual)
  expected <- dplyr::collect(expected)

  expect_identical(actual, expected)
})

test_that(".by works", {
  data <- get_data_dummy()

  tmp <- tempfile(fileext = ".parquet")
  on.exit(unlink(tmp, recursive = TRUE, force = TRUE))

  arrow::write_parquet(x = data, sink = tmp)

  data <- arrow::open_dataset(tmp)

  actual <- summarize_with_margins(
    .data = data,
    n = dplyr::n(),
    mean = mean(value, na.rm = TRUE),
    .rollup = c(g1, g2, g3),
    .by = year,
    .check_margin_name = TRUE,
    .sort = TRUE
  )

  expected <- list(
    dplyr::ungroup(
      dplyr::summarize(
        .data = dplyr::group_by(data, year),
        n = dplyr::n(),
        mean = mean(value, na.rm = TRUE),
        g1 = "(all)",
        g2 = "(all)",
        g3 = "(all)",
      )
    ),
    dplyr::ungroup(
      dplyr::summarize(
        .data = dplyr::group_by(data, year, g1),
        n = dplyr::n(),
        mean = mean(value, na.rm = TRUE),
        g2 = "(all)",
        g3 = "(all)",
      )
    ),
    dplyr::ungroup(
      dplyr::summarize(
        .data = dplyr::group_by(data, year, g1, g2),
        n = dplyr::n(),
        mean = mean(value, na.rm = TRUE),
        g3 = "(all)",
      )
    ),
    dplyr::ungroup(
      dplyr::summarize(
        .data = dplyr::group_by(data, year, g1, g2, g3),
        n = dplyr::n(),
        mean = mean(value, na.rm = TRUE)
      )
    )
  )
  expected <- lapply(
    expected,
    function(df) {
      relocate_before_union_all.Dataset(
        df,
        c("year", "g1", "g2", "g3")
      )
    }
  )
  expected <- Reduce(dplyr::union_all, expected)
  expected <- dplyr::relocate(.data = expected, year, g1, g2, g3)
  expected <- dplyr::arrange(.data = expected, year, g1, g2, g3)

  actual <- dplyr::collect(actual)
  expected <- dplyr::collect(expected)

  expect_identical(actual, expected)
})

test_that(".cube works", {
  data <- get_data_dummy()

  tmp <- tempfile(fileext = ".parquet")
  on.exit(unlink(tmp, recursive = TRUE, force = TRUE))

  arrow::write_parquet(x = data, sink = tmp)

  data <- arrow::open_dataset(tmp)

  actual <- summarize_with_margins(
    .data = data,
    n = dplyr::n(),
    mean = mean(value, na.rm = TRUE),
    .rollup = c(g1, g2, g3),
    .by = year,
    .cube = c(h1, k1),
    .check_margin_name = TRUE,
    .sort = TRUE
  )

  expected <- list(
    # all g1, g2, g3
    dplyr::ungroup(
      dplyr::summarize(
        .data = dplyr::group_by(data, year),
        n = dplyr::n(),
        mean = mean(value, na.rm = TRUE),
        g1 = "(all)",
        g2 = "(all)",
        g3 = "(all)",
        h1 = "(all)",
        k1 = "(all)"
      )
    ),
    dplyr::ungroup(
      dplyr::summarize(
        .data = dplyr::group_by(data, year, k1),
        n = dplyr::n(),
        mean = mean(value, na.rm = TRUE),
        g1 = "(all)",
        g2 = "(all)",
        g3 = "(all)",
        h1 = "(all)"
      )
    ),
    dplyr::ungroup(
      dplyr::summarize(
        .data = dplyr::group_by(data, year, h1),
        n = dplyr::n(),
        mean = mean(value, na.rm = TRUE),
        g1 = "(all)",
        g2 = "(all)",
        g3 = "(all)",
        k1 = "(all)"
      )
    ),
    dplyr::ungroup(
      dplyr::summarize(
        .data = dplyr::group_by(data, year, h1, k1),
        n = dplyr::n(),
        mean = mean(value, na.rm = TRUE),
        g1 = "(all)",
        g2 = "(all)",
        g3 = "(all)"
      )
    ),
    # by g1, all g2, g3
    dplyr::ungroup(
      dplyr::summarize(
        .data = dplyr::group_by(data, year, g1),
        n = dplyr::n(),
        mean = mean(value, na.rm = TRUE),
        g2 = "(all)",
        g3 = "(all)",
        h1 = "(all)",
        k1 = "(all)"
      )
    ),
    dplyr::ungroup(
      dplyr::summarize(
        .data = dplyr::group_by(data, year, g1, k1),
        n = dplyr::n(),
        mean = mean(value, na.rm = TRUE),
        g2 = "(all)",
        g3 = "(all)",
        h1 = "(all)"
      )
    ),
    dplyr::ungroup(
      dplyr::summarize(
        .data = dplyr::group_by(data, year, g1, h1),
        n = dplyr::n(),
        mean = mean(value, na.rm = TRUE),
        g2 = "(all)",
        g3 = "(all)",
        k1 = "(all)"
      )
    ),
    dplyr::ungroup(
      dplyr::summarize(
        .data = dplyr::group_by(data, year, g1, h1, k1),
        n = dplyr::n(),
        mean = mean(value, na.rm = TRUE),
        g2 = "(all)",
        g3 = "(all)"
      )
    ),
    # by g1, g2, all g3
    dplyr::ungroup(
      dplyr::summarize(
        .data = dplyr::group_by(data, year, g1, g2),
        n = dplyr::n(),
        mean = mean(value, na.rm = TRUE),
        g3 = "(all)",
        h1 = "(all)",
        k1 = "(all)"
      )
    ),
    dplyr::ungroup(
      dplyr::summarize(
        .data = dplyr::group_by(data, year, g1, g2, k1),
        n = dplyr::n(),
        mean = mean(value, na.rm = TRUE),
        g3 = "(all)",
        h1 = "(all)"
      )
    ),
    dplyr::ungroup(
      dplyr::summarize(
        .data = dplyr::group_by(data, year, g1, g2, h1),
        n = dplyr::n(),
        mean = mean(value, na.rm = TRUE),
        g3 = "(all)",
        k1 = "(all)"
      )
    ),
    dplyr::ungroup(
      dplyr::summarize(
        .data = dplyr::group_by(data, year, g1, g2, h1, k1),
        n = dplyr::n(),
        mean = mean(value, na.rm = TRUE),
        g3 = "(all)"
      )
    ),
    # by g1, g2, g3
    dplyr::ungroup(
      dplyr::summarize(
        .data = dplyr::group_by(data, year, g1, g2, g3),
        n = dplyr::n(),
        mean = mean(value, na.rm = TRUE),
        h1 = "(all)",
        k1 = "(all)"
      )
    ),
    dplyr::ungroup(
      dplyr::summarize(
        .data = dplyr::group_by(data, year, g1, g2, g3, k1),
        n = dplyr::n(),
        mean = mean(value, na.rm = TRUE),
        h1 = "(all)"
      )
    ),
    dplyr::ungroup(
      dplyr::summarize(
        .data = dplyr::group_by(data, year, g1, g2, g3, h1),
        n = dplyr::n(),
        mean = mean(value, na.rm = TRUE),
        k1 = "(all)"
      )
    ),
    dplyr::ungroup(
      dplyr::summarize(
        .data = dplyr::group_by(data, year, g1, g2, g3, h1, k1),
        n = dplyr::n(),
        mean = mean(value, na.rm = TRUE)
      )
    )
  )
  expected <- lapply(
    expected,
    function(df) {
      relocate_before_union_all.Dataset(
        df,
        c("year", "g1", "g2", "g3", "h1", "k1")
      )
    }
  )
  expected <- Reduce(dplyr::union_all, expected)
  expected <- dplyr::relocate(.data = expected, year, g1, g2, g3, h1, k1)
  expected <- dplyr::arrange(.data = expected, year, g1, g2, g3, h1, k1)

  actual <- dplyr::collect(actual)
  expected <- dplyr::collect(expected)

  expect_identical(actual, expected)
})

test_that(".margin_name basic (non-NA)", {
  data <- get_data_dummy()

  tmp <- tempfile(fileext = ".parquet")
  on.exit(unlink(tmp, recursive = TRUE, force = TRUE))

  arrow::write_parquet(x = data, sink = tmp)

  data <- arrow::open_dataset(tmp)

  actual <- summarize_with_margins(
    .data = data,
    n = dplyr::n(),
    mean = mean(value, na.rm = TRUE),
    .rollup = g3,
    .margin_name = "total",
    .check_margin_name = TRUE,
    .sort = TRUE
  )

  expected <- list(
    dplyr::ungroup(
      dplyr::summarize(
        .data = data,
        n = dplyr::n(),
        mean = mean(value, na.rm = TRUE),
        g3 = "total"
      )
    ),
    dplyr::ungroup(
      dplyr::summarize(
        .data = dplyr::group_by(data, g3),
        n = dplyr::n(),
        mean = mean(value, na.rm = TRUE)
      )
    )
  )
  expected <- lapply(
    expected,
    function(df) {
      relocate_before_union_all.Dataset(df, "g3")
    }
  )

  expected <- Reduce(dplyr::union_all, expected)
  expected <- dplyr::relocate(.data = expected, g3)
  expected <- dplyr::arrange(.data = expected, g3)

  actual <- dplyr::collect(actual)
  expected <- dplyr::collect(expected)

  expect_identical(actual, expected)
})

test_that(".margin_name basic (NA)", {
  data <- get_data_dummy()

  tmp <- tempfile(fileext = ".parquet")
  on.exit(unlink(tmp, recursive = TRUE, force = TRUE))

  arrow::write_parquet(x = data, sink = tmp)

  data <- arrow::open_dataset(tmp)

  actual <- summarize_with_margins(
    .data = data,
    n = dplyr::n(),
    mean = mean(value, na.rm = TRUE),
    .rollup = g2,
    .margin_name = NA_character_,
    .check_margin_name = TRUE,
    .sort = TRUE
  )

  expected <- list(
    dplyr::ungroup(
      dplyr::summarize(
        .data = data,
        n = dplyr::n(),
        mean = mean(value, na.rm = TRUE),
        g2 = NA_character_
      )
    ),
    dplyr::ungroup(
      dplyr::summarize(
        .data = dplyr::group_by(data, g2),
        n = dplyr::n(),
        mean = mean(value, na.rm = TRUE)
      )
    )
  )
  expected <- lapply(
    expected,
    function(df) {
      relocate_before_union_all.Dataset(df, "g2")
    }
  )
  expected <- Reduce(dplyr::union_all, expected)
  expected <- dplyr::relocate(.data = expected, g2)
  expected <- dplyr::arrange(.data = expected, g2)

  actual <- dplyr::collect(actual)
  expected <- dplyr::collect(expected)

  expect_identical(actual, expected)
})

test_that(".margin_name conflict error", {
  data <- get_data_dummy()

  tmp <- tempfile(fileext = ".parquet")
  on.exit(unlink(tmp, recursive = TRUE, force = TRUE))

  arrow::write_parquet(x = data, sink = tmp)

  data <- arrow::open_dataset(tmp)

  expect_error(
    summarize_with_margins(
      .data = data,
      n = dplyr::n(),
      mean = mean(value, na.rm = TRUE),
      .rollup = g3,
      .margin_name = "RD360",
      .check_margin_name = TRUE
    ),
    "not allowed as a margin name"
  )

  expect_error(
    summarize_with_margins(
      .data = data,
      n = dplyr::n(),
      mean = mean(value, na.rm = TRUE),
      .rollup = g3,
      .margin_name = NA_character_,
      .check_margin_name = TRUE
    ),
    "not allowed as a margin name"
  )
})

test_that("Can not use the margin variable before calculating", {
  # for easier debugging, extract the sample that has more than one row
  data <- get_data_dummy()

  tmp <- tempfile(fileext = ".parquet")
  on.exit(unlink(tmp, recursive = TRUE, force = TRUE))

  arrow::write_parquet(x = data, sink = tmp)

  data <- arrow::open_dataset(tmp)

  data <- dplyr::filter(data, id == "108")

  expect_error(
    summarize_with_margins(
      .data = data,
      n = dplyr::n(),
      g3s = stringr::str_flatten(g3, collapse = "/"),
      .rollup = c(g2, g3),
      .by = year,
      .cube = h1,
      .check_margin_name = TRUE,
      .sort = TRUE
    ),
    "Expression not supported in Arrow"
  )
})
