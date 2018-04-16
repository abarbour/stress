context("Elasticity computations")

nu <- 1/4
sm <- 1

ym.s <- shear_to_youngs(sm, nu)
bm <- shear_to_bulk(sm, nu)
ym.b <- bulk_to_youngs(bm, nu)
smi <- bulk_to_shear(bm, nu)

C.s <- elastic_compliance_tensor(nu, Youngs = ym.s)
C.b <- elastic_compliance_tensor(nu, Youngs = ym.b)

#print(c(sm,ym.s,bm,ym.b))

test_that("Conversion to bulk modulus",{
  expect_equal(ym.s, ym.b)
})

test_that("Conversion to shear modulus",{
  expect_equal(sm, smi)
})

test_that("Bulk modulus calculation",{
  expect_equal(bm, 2*sm*(1 + nu)/(3*(1 - 2*nu)))
})

test_that("Youngs modulus calculation",{
  expect_equal(ym.s, 2*sm*(1 + nu))
  expect_equal(ym.b, 3*bm*(1 - 2*nu))
})

test_that("Elasticity tensor formulation",{
  expect_equal(C.s, C.b)
  all.equal(lower.tri(C.s, diag=TRUE), !upper.tri(C.s))
  all.equal(!lower.tri(C.b, diag=TRUE), upper.tri(C.b))
})