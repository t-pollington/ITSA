args <- commandArgs(trailingOnly = FALSE)
print(args)
flush.console()
thisistheseed = as.integer(args[6])
library(hhh4addon) # v0.0.0.0.9014 distributed lag
library(surveillance) # v1.19.1 poly2adjmat(), hhh4_spacetime classes
load("up to 564.RData")

# final model
intervention <- calcDxconst(37)
x <- list(
  ar = list(f = addSeason2formula(~ 1 + vaishali + intervention, period = ka.sts@freq)),
  end = list(f = addSeason2formula(~ 1 + end.HL, period = ka.sts@freq), offset = population(ka.sts)),
  ne = list(f = ~ 1, weights = neighbourhood(ka.sts) == 1),
  family = HL.factor,
  funct_lag = Dx_lag,
  par_lag = 1,
  min_lag = 1,
  max_lag = 12,
  subset = 13:nrow(ka.sts))
final.modelintjan15 <- hhh4_lag(stsObj = ka.sts, control = x)

# bootstrap the residuals
bstraprqst = 20
elm = matrix(nrow = 12, ncol = 2)
coef.list = rep(list(elm),bstraprqst)
set.seed(seed = thisistheseed)
epsilon = residuals(final.modelintjan15)
nbstrap = 1
tries = 0
while (nbstrap < (bstraprqst + 1)) {
  tries = tries + 1
  epsilon.bstrap = sample(epsilon, replace = TRUE)
  y.bstrap = round(fitted(final.modelintjan15) + epsilon.bstrap)
  y.bstrap[y.bstrap<0] = 0 # prevent negative values
  y.bstrap = rbind(ka.sts@observed[1:12,], y.bstrap)
  temp.ka.sts = ka.sts
  temp.ka.sts@observed = y.bstrap
  x <- list(
    ar = list(f = addSeason2formula(~ 1 + vaishali + intervention, period = temp.ka.sts@freq)),
    end = list(f = addSeason2formula(~ 1 + end.HL, period = temp.ka.sts@freq), offset = population(temp.ka.sts)),
    ne = list(f = ~ 1, weights = neighbourhood(temp.ka.sts) == 1),
    family = HL.factor,
    funct_lag = Dx_lag,
    par_lag = 1,
    min_lag = 1,
    max_lag = 12,
    subset = 13:nrow(temp.ka.sts)
  )
  temp.hhh4 = try(expr = summary(hhh4_lag(stsObj = temp.ka.sts, control = x))$fixef, silent = TRUE) # try prevents an nlminb error stopping things
  if (is.matrix(temp.hhh4)) {
    coef.list[[nbstrap]] = temp.hhh4
    print(paste0("nbstrap = ", nbstrap, ", out of ", tries, " tries"))
    nbstrap = nbstrap + 1
  }
}
save(coef.list, file = paste0("coef.list.bstrap",thisistheseed,".RData"))