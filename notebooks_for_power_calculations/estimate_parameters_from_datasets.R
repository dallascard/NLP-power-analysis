library(tidyverse)
library(lme4)
library(xtable)
library(here)

### To obtain the annotated datasets, please use the notebooks in data_import

# Try to use here() to specify the right directory
# This should return the project directroy/data/annotated_datasets/
processed_dir = here('data', 'annotated_datasets')

# fit a bunch of models to processed HUSE data

# WMT model
d.wmt = read_csv(file.path(processed_dir, "wmt19.csv")) %>%
  mutate(resp=score_scaled,
         model=model_code) %>%
  rename(worker=WorkerId,
         item=sid)
d.wmt$model = as.factor(as.numeric(as.factor(d.wmt$model)))
contrasts(d.wmt$model) = contr.sum(2)

l.wmt = d.wmt %>%
  lmer(data=.,
       resp ~ model + (model||item) + (model||worker),
       REML=F)
summary(l.wmt)

# Uber data
d.uber = read_csv(file.path(processed_dir, "uber_all.csv")) %>%
  mutate(resp=rating_scaled,
         model=model_code) %>%
  rename(worker=annotator,
         item=item_id) 

d.uber$model = as.factor(as.numeric(as.factor(d.uber$model)))
contrasts(d.uber$model) = contr.sum(length(unique(d.uber$model)))

group_by(d.uber, model) %>% 
  summarise(m=mean(resp), sd=sd(resp))


l.uber = d.uber %>%
  lmer(data=.,
       resp ~ model + (model||item) + (model||worker),
       REML=F)
summary(l.uber)  


# HUSE data
d.lm = read_csv(file.path(processed_dir, "huse_lm.csv")) %>%
  mutate(resp = response_val/max(response_val),
         model=model_code) %>%
  rename(item=input_id) 

group_by(d.lm, model_code) %>%
  summarise(m=mean(resp), sd=sd(resp))

d.lm$model = as.factor(as.numeric(as.factor(d.lm$model)))
contrasts(d.lm$model) = contr.sum(length(unique(d.lm$model)))

l.lm = d.lm %>%
  lmer(data=.,
         resp ~ model + (model||item) + (model||worker),
         REML=F)
summary(l.lm)

# reddit data
d.reddit.all = read_csv(file.path(processed_dir, "huse_reddit.csv")) %>%
  mutate(response_val = response_val/max(response_val),
         item = input_id)

d.reddit.all$model = as.factor(as.numeric(as.factor(d.reddit.all$model)))
contrasts(d.reddit.all$model) = contr.sum(length(unique(d.reddit.all$model)))


l.reddit.all = d.reddit.all %>%  lmer(data=.,
       response_val ~ model + (model||item) + (model||worker),
       REML=F)
summary(l.reddit.all)

# summarization data
d.summarization = read_csv(file.path(processed_dir, "huse_summarization.csv")) %>%
  mutate(response_val = response_val/max(response_val),
         item = input_id)

d.summarization$model = as.factor(as.numeric(as.factor(d.summarization$model)))
contrasts(d.summarization$model) = contr.sum(length(unique(d.summarization$model)))


l.summarization =  d.summarization %>%
  lmer(data=.,
       response_val ~ model + (model||item) + (model||worker),
       REML=F)
summary(l.summarization)


### Commented out because data is not public
#d.nucleus = read_csv(file.path(processed_dir, "nucleus.csv")) %>%
#  mutate(resp=response_val/max(response_val),
#         model=model_id,
#         item=text_id)
#d.nucleus$model = as.factor(as.numeric(as.factor(d.nucleus$model)))
#contrasts(d.nucleus$model) = contr.sum(length(unique(d.nucleus$model)))
#l.nucleus = d.nucleus %>%
#  lmer(data=.,
#       resp ~ model + (model|item) + (model|worker),
#       REML=F)
#summary(l.nucleus)

# make a summary data frame
d.summary = data.frame(rbind(cbind("huse.reddit", length(unique(d.reddit.all$worker)),
length(unique(d.reddit.all$item))),

#cbind("nucleus", length(unique(d.nucleus$worker_id)),
#length(unique(d.nucleus$item))),

cbind("wmt", length(unique(d.wmt$worker)),
length(unique(d.wmt$item))),

cbind("uber", length(unique(d.uber$worker)),
length(unique(d.uber$item))),

cbind("huse.lm", length(unique(d.lm$worker)),
length(unique(d.lm$item))),

cbind("huse.summarization", length(unique(d.summarization$worker)),
length(unique(d.summarization$item)))))

names(d.summary) = c("dataset", "num.workers", "num.items")
xtable(d.summary)

### aggregate parameters into a single data frame, to output nice latex tables
a = NULL
#ls = c(l.nucleus, l.wmt, l.uber, l.lm, l.reddit.all, l.summarization)
ls = c(l.wmt, l.uber, l.lm, l.reddit.all, l.summarization)
#lnames = c("nucleus", "wmt", "uber", "huse.lm", "huse.reddit", "huse.sum") 
lnames = c("wmt", "uber", "huse.lm", "huse.reddit", "huse.sum") 
for (l in 1:length(ls))  {
  
  a = bind_rows(a, bind_rows(tibble(sdcor = as.numeric(fixef(ls[[l]])), 
                                    grp=names(fixef(ls[[l]])),
                                    var1 = "fixed.effect"), 
                                    
                                    data.frame(VarCorr(ls[[l]])) %>% 
                                      filter(is.na(var2)) %>%
                                      select(grp, var1, sdcor)) %>%
                                    mutate(model = as.character(lnames[l])))
  
}

a$var1 = gsub("fixed.effect", "$\\\\beta$", a$var1)
a$var = paste(a$grp, a$var1, sep=".")
a$var = gsub("Residual.NA", "sigma", a$var)
a = select(a, dataset=model, var, value=sdcor)
a$var = gsub("\\(", "", a$var)
a$var = gsub("\\)", "", a$var)

# get fixed effect df
fe = filter(a, grepl("eta", var) | grepl("sigma", var)) %>% mutate(value = round(value, 2))

# get random effect df
re = filter(a, !grepl("beta", var)) %>% mutate(value = round(value, 2))
re = mutate(re, var = gsub("1\\.", "", var))
re = mutate(re, var = gsub("model", "", var))
re = mutate(re, var = gsub("Intercept", "int", var))

# Fixed effects, Table 13
spread(fe, var, value, fill="") %>%
  #mutate(index = c(1, 2, 1, 6, 2, 1)) %>%
  mutate(index = c(2, 1, 6, 2, 1)) %>%
  arrange(index) %>%
 select( -index) %>% 
  rename(`$\\sigma$`=sigma) %>% #intercept=Intercept.beta, model1.beta, model2.beta, model3.beta, model4.beta, model5.beta, model6.beta) %>%
  xtable(caption="Fixed effect coefficients for each model along with the residual model variance.", label="table:fixef") %>%
  print(include.rownames=FALSE, sanitize.colnames.function = identity)
  
# Random effects for worker, Table 14
spread(mutate(re, var=gsub("worker\\.", "model ", var)), var, value, fill="") %>% 
  #mutate(index = c(1, 2, 1, 6, 2, 1)) %>%
  mutate(index = c(2, 1, 6, 2, 1)) %>%
  arrange(index) %>%
  select(dataset, `model int`, `model 1`:`model 4`) %>%
  xtable(caption="Random effects standard deviations for worker. worker.int is the intercept and the rest of the parameters are slopes for each model.",
         label="table:worker") %>%
  print(include.rownames=FALSE)

# Random effects for item, Table 15
spread(mutate(re, var=gsub("item\\.", "model ", var)), var, value, fill="") %>% 
  #mutate(index = c(1, 2, 1, 6, 2, 1)) %>%
  mutate(index = c(2, 1, 6, 2, 1)) %>%
  arrange(index) %>%
  select(dataset, `model int`, `model 1`:`model 4`) %>%
  xtable(caption="Random effects standard deviations for item item.int is the intercept and the rest of the parameters are slopes for each model.",
         label="table:item") %>%
  print(include.rownames=FALSE)
