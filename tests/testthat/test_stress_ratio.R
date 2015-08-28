context('Stress ratio')

test_that("stress ratio is related to shape factor",{
  sr <- stress_ratio(3,2,1)
  phi <- shape_factor(3,2,1)
  expect_true(sr == 1 - phi)
})

test_that("stress ratio is bounded",{

  sr <- stress_ratio(3,2,1)
  expect_true(sr >= 0 & sr <= 1)

  expect_error(stress_ratio(3,2,NA))
  sr <- stress_ratio(3,2,NA, check.order=FALSE)
  expect_true(is.na(sr))

  expect_error(stress_ratio(3,NA,1))
  sr <- stress_ratio(3,NA,1, check.order=FALSE)
  expect_true(is.na(sr))

  expect_error(stress_ratio(NA,2,1))
  sr <- stress_ratio(NA,2,1, check.order=FALSE)
  expect_true(is.na(sr))

  sr <- stress_ratio(1,1,1)
  expect_true(is.nan(sr))

  expect_warning(stress_ratio(2,1,2))
  sr <- stress_ratio(2,1,2, check.order=FALSE)
  expect_true(is.infinite(sr))

  expect_warning(stress_ratio(1,2,1))
  sr <- stress_ratio(1,2,1, check.order=FALSE)
  expect_true(is.infinite(sr))

})
