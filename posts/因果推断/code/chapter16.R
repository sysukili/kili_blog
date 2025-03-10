##################################################################
# Program 16.1
# Estimating the average causal using the standard IV estimator
# via the calculation of sample averages
# Data from NHEFS
##################################################################

#install.packages("readxl") # install package if required
library("readxl")
nhefs <- read_excel("F:/Homework/Textbooks/Hernan - Causal Inferences/nhefs.xls")

# some preprocessing of the data
nhefs$cens <- ifelse(is.na(nhefs$wt82), 1, 0)
summary(nhefs$price82)

# for simplicity, ignore subjects with missing outcome or missing instrument
nhefs.iv <- nhefs[which(!is.na(nhefs$wt82) & !is.na(nhefs$price82)),]
nhefs.iv$highprice <- ifelse(nhefs.iv$price82>=1.5, 1, 0)

table(nhefs.iv$highprice, nhefs.iv$qsmk)

t.test(wt82_71 ~ highprice, data=nhefs.iv)

######################################################################
# PROGRAM 16.2
# Estimating the average causal effect using the standard IV estimator 
# via two-stage-least-squares regression
# Data from NHEFS
######################################################################

#install.packages ("sem") # install package if required
library(sem) 

model1 <- tsls(wt82_71 ~ qsmk, ~ highprice, data = nhefs.iv)
summary(model1)
confint(model1)  # note the wide confidence intervals


######################################################################
# Program 16.3
# Estimating the average causal using the standard IV estimator
# via additive marginal structural models
# Data from NHEFS
######################################################################

########################################################
# G-estimation: Checking one possible value of psi      
# See Chapter 14 for program that checks several values 
# and computes 95% confidence intervals                 
########################################################

nhefs.iv$psi <- 2.396
nhefs.iv$Hpsi <- nhefs.iv$wt82_71-nhefs.iv$psi*nhefs.iv$qsmk

#install.packages("geepack") # install package if required
library("geepack")
g.est <- geeglm(highprice ~ Hpsi, data=nhefs.iv, id=seqn, family=binomial(),
                corstr="independence")
summary(g.est)

beta <- coef(g.est)
SE <- coef(summary(g.est))[,2]
lcl <- beta-qnorm(0.975)*SE 
ucl <- beta+qnorm(0.975)*SE
cbind(beta, lcl, ucl)


######################################################################
# Program 16.4
# Estimating the average causal using the standard IV estimator
# with altnerative proposed instruments
# Data from NHEFS
######################################################################

summary(tsls(wt82_71 ~ qsmk, ~ ifelse(price82 >= 1.6, 1, 0), data = nhefs.iv))
summary(tsls(wt82_71 ~ qsmk, ~ ifelse(price82 >= 1.7, 1, 0), data = nhefs.iv))
summary(tsls(wt82_71 ~ qsmk, ~ ifelse(price82 >= 1.8, 1, 0), data = nhefs.iv))
summary(tsls(wt82_71 ~ qsmk, ~ ifelse(price82 >= 1.9, 1, 0), data = nhefs.iv))


######################################################################
# Program 16.5
# Estimating the average causal using the standard IV estimator
# Conditional on baseline covariates
# Data from NHEFS
######################################################################

model2 <- tsls(wt82_71 ~ qsmk + sex + race + age + smokeintensity + smokeyrs + 
                      as.factor(exercise) + as.factor(active) + wt71,
             ~ highprice + sex + race + age + smokeintensity + smokeyrs + as.factor(exercise) +
               as.factor(active) + wt71, data = nhefs.iv)
summary(model2)