library(tidyverse)
library(here)

# Try to use here() to specify the right directory
# This should return the project directroy/data/human_eval/
data_dir = here('data', 'human_eval')
data_dir

# overall, not just likert
s = read_csv(file.path(data_dir, "humaneval_master.csv"))
print(length(unique(s$Link)))
s.new = filter(s, `Probably not relevant to us` == 0)
print(length(unique(s.new$Link)))
print(nrow(s.new))

# mean with significance test
s.new$HasTest = as.numeric(s.new$HasTest)
mean(s.new$HasTest)

# print by response type
table(s.new$ResponseCategory)

# print bold
s.new[is.na(s.new$`Bold text in results table`), "Bold text in results table"] = "no"
mean(s.new$`Bold text in results table` == "yes")

s1 = read_csv(file.path(data_dir, "likert_ratings.csv"))

e = s1 %>%
  mutate(Response = gsub("likert", "Likert", `Response`)) %>%
  separate(Response, into=c("likert_min", "likert_max"), sep="_") %>%
  mutate(likert_max = as.numeric(likert_max),
         likert_min = as.numeric(likert_min) ,
         Value = as.numeric(Value),
         score = (Value - likert_min)/likert_max,
         Category = gsub("[0-9]", "", Category)) %>%
  filter(is.na(Value) == F) %>%
  group_by(Link, `Eval number`, Dataset, Metric, Category, Examples, Ann.Per.Ex, Tot.Ann) %>%
  summarise(max.in.cat = max(score)) %>% 
  ungroup() %>%
  mutate(id = as.integer(as.factor(paste(Link, `Eval number`, Dataset, Metric))))

e$Category = tolower(e$Category)
baseline.new = filter(e, Category %in% c("baseline", "new")) %>%
  spread(Category, max.in.cat) %>%
  mutate(diff = new - baseline,
         diffPos = diff > 0) %>%
  arrange(diff) %>%
  mutate(diffrank = 1:n())

metrics = read.csv(file.path(data_dir, "metrics.csv"))
baseline.new = left_join(baseline.new, metrics)
baseline.new$diffrank = as.factor(baseline.new$diffrank)

# filter those that don't have at least one baseline and one new
baseline.new = filter(baseline.new, is.na(diff) == F)

ggplot(filter(baseline.new, 
              is.na(baseline) == F,
              baseline != Inf), 
       aes(x=diffrank, y=new)) +  geom_point(colour="red") +
  geom_point(aes(x=diffrank, y=baseline, colour="black"), colour="black") +
  geom_segment(aes(x=diffrank, xend = diffrank, y = baseline, yend=new),  arrow = arrow(length = unit(0.4,"cm"))) +
  ggtitle("Likert ratings, change from best baseline to best new") + 
  xlab("Model comparison") + 
  ylab("normalized Likert rating") + 
  theme_bw(14) + 
  facet_grid(. ~ BigCategory, scales = "free_x")
ggsave("likert_comparisons.pdf", width=7, height=7)
  

length(unique(baseline.new$Link))
nrow(baseline.new)

filter(baseline.new, is.na(Examples) == F) %>%
  summarise(
    e.100 = sum(Examples<= 100)/n(),
    e.200 = sum(Examples == 200)/n(),
    e.morethan200 = sum(Examples > 200)/n())

# cor test for publication bias
cor.test(baseline.new$diff, baseline.new$Examples, method="kendall")

# print what's missing and median experimental characteristics
mean(is.na(baseline.new$Ann.Per.Ex))
mean(is.na(baseline.new$Examples))
mean(is.na(baseline.new$Tot.Ann))
mean(!is.na(baseline.new$Tot.Ann) & !is.na(baseline.new$Ann.Per.Ex) & !is.na(baseline.new$Examples))
median(baseline.new$Tot.Ann, na.rm=T)
median(baseline.new$Ann.Per.Ex, na.rm=T)
mean(baseline.new$Ann.Per.Ex == 3, na.rm=T)

# make plot number of items vs effect size
ggplot(baseline.new, aes(x=Examples, y=diff)) +
  theme_bw(12) + 
  xlab("number of items") + 
  ylab("effect size") + 
  ylim(-.5, .5) + geom_jitter( size=3,alpha=.4) + scale_x_log10() + 
  geom_smooth(method=lm) + 
  geom_hline(yintercept=0, colour='red')
ggsave("items_vs_effect_size.pdf", width=5, height=2.7)

