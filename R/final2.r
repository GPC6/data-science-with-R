library(tidyverse)

obesity = read_csv("F:\\data\\Obesity.csv")

obesity$Age = round(obesity$Age, digits=0)
obesity$Height = round(obesity$Height, digits=2)
obesity$Weight = round(obesity$Weight, digits=2)

obesity$FCVC = as_factor(round(obesity$FCVC, digits=0))
obesity$NCP = as_factor(round(obesity$NCP, digits=0))
obesity$CH2O = as_factor(round(obesity$CH2O, digits=0))
obesity$FAF = as_factor(round(obesity$FAF, digits=0))
obesity$TUE = as_factor(round(obesity$TUE, digits=0))

is_char=unlist(map(obesity,is_character))

obesity[,is_char] = as.data.frame(map(obesity[,is_char], as_factor))

obesity$CAEC = fct_relevel(obesity$CAEC, "no","Sometimes","Frequently","Always")
obesity$CALC = fct_relevel(obesity$CALC, "no","Sometimes","Frequently","Always")
obesity$family_history_with_overweight = fct_relevel(obesity$family_history_with_overweight, "no","yes")
obesity$NObeyesdad = fct_relevel(obesity$NObeyesdad, "Insufficient_Weight", "Normal_Weight", "Overweight_Level_I", "Overweight_Level_II", "Obesity_Type_I", "Obesity_Type_II", "Obesity_Type_III")


summary(obesity)


bmi=obesity %>%
    mutate(bmi=Weight/(Height^2)) %>%
    mutate(weight_category = cut(bmi,breaks=c(-Inf,18.5,25,30,Inf),labels=c("underweight","normal weight","overweight","obesity")))

bmi %>% select(NObeyesdad,weight_category) %>%
    group_by(NObeyesdad, weight_category) %>% mutate(count=n()) %>%
ggplot(aes(NObeyesdad, weight_category)) +
    geom_point(size=5) +
    geom_jitter(alpha=0.7, color="grey") +
    theme(aspect.ratio = 1/2)


ggplot(bmi, aes(NCP,FAF)) + geom_line() + theme(aspect.ratio = 1/1)

