library(lme4)
library(tidyverse)

# taken in part from https://rstudio-pubs-static.s3.amazonaws.com/11703_21d1c073558845e1b56ec921c6e0931e.html
simulate_power_params <- function(num.iter, nannotators, nitems, nperitem, intercept, beta,
                           item.model, item.Intercept, worker.model, worker.Intercept, sigma) {
  
  # make a data set with a full factorial of annotators, items
  # 2 conditions for model: 1 or 0
  expdat <- expand.grid(worker = factor(1:nannotators),
                        item = factor(1:nitems),
                        model = c(-1, 1)
  ) %>%
    group_by(item, model) %>%
    sample_n(nperitem)
  
  set.seed(101)
  beta <- c(intercept, beta) # intercept effect
  names(beta) = c("(Intercept)", "model")
  
  # specify sigma and theta in sd space
  theta <- c(item.model, item.Intercept, worker.model, worker.Intercept) #item.model, item.Intercept, worker.model, worker.Intercept
  names(theta) = c("item.model", "item.(Intercept)", "worker.model", "worker.(Intercept)")
  theta = theta/sigma # theta is specified scaled by sigma, so we divide to get it in the right space
  
  # simulate 
  ss <- simulate(~model + (1 + model || worker) + (1 + model || item),
                 nsim = num.iter,
                 family = "gaussian", 
                 newdata = expdat,
                 newparams = list(theta = theta, beta = beta, sigma=sigma),
                 REML=F)
  
  # assign responses
  expdat$resp <- ss[, 1]
  
  print(nrow(expdat))
  
  # fit a first model
  fit1 <- lmer(resp ~ model + (1 + model || worker) + (1 + model || item),
               data = expdat, REML=F)
  
  # fit a model for num.iter times, return time t value is greater than 1.96
  fitsim <- function(i) {
    coef(summary(refit(fit1, ss[[i]])))["model", ]
  }
  fitAll <- t(data.frame(sapply(seq(num.iter), function(i) fitsim(i))))
  return(mean(fitAll[, 't value'] > 1.96))
}



###########
################# lmer with low var parameters
lmer.overall.lowvar = NULL
for (diff in c(.05, .1, .15, .2)) {
  for (ex in c(50, 100, 500))  {
    for (num.workers in c(3, 10)) {
      power = simulate_power_params(200, num.workers, ex, num.workers, .5, diff, .13, .01, .04, .01, .16)
      print(c(power, diff))
      lmer.overall.lowvar = rbind(lmer.overall.lowvar, cbind(diff, ex, power, num.workers))
    }
  }
}
lmer.overall.lowvar = data.frame(lmer.overall.lowvar)
lmer.overall.lowvar$`Number of Items` = as.factor(lmer.overall.lowvar$ex)


lmer.overall.highvar = NULL
for (diff in c(.05, .1, .15, .2)) {
  for (ex in c(50, 100, 500))  {
    for (num.workers in c(3, 10)) {
      power = simulate_power_params(200, num.workers, ex, num.workers, .5, diff, .14, .04, .11, .01, .26)
      print(c(power, diff))
      lmer.overall.highvar = rbind(lmer.overall.highvar, cbind(diff, ex, power, num.workers))
    }
  }
}
lmer.overall.highvar = data.frame(lmer.overall.highvar)
lmer.overall.highvar$`Number of Items` = as.factor(lmer.overall.highvar$ex)



###
tot.lmer = bind_rows(mutate(lmer.overall.highvar, settings= "High var. settings"), 
                     mutate(lmer.overall.lowvar, settings = "Low var. settings"))

write.csv(tot.lmer, file="highvar_lowmer_lmer.csv")
ggplot(filter(tot.lmer, `Number of Items` != 200, num.workers %in% c(3, 10)) %>%
         mutate(`num.workers` = as.factor(paste("Num. Workers:", num.workers)),
                `num.workers` = fct_relevel(num.workers, "Num. Workers: 3", "Num. Workers: 10")), 
       aes(x=diff, y=power, group=`Number of Items`, colour=`Number of Items`)) + geom_line() + 
  facet_grid(settings ~ num.workers) +
  xlab("mean difference") + ylab("power") + theme_bw(10) + 
  xlim(0, .2) + geom_point(alpha=.2) +
  theme(legend.position = "bottom")
ggsave("power_var_settings_highlow.pdf", width=4.3, height=4)

