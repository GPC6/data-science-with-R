library(GenderInfer)
library(nycflights13)
library(tidyverse)


planes
list= planes %>% group_by(manufacturer) %>% summarise(count=n()) %>% filter(count>200)
cut_planes = planes %>% filter(manufacturer %in% list$manufacturer, !is.na(year)) %>% group_by(manufacturer, year) %>% summarise(made=n())

tail(arrange(cut_planes,year))
cut_planes %>% 
ggplot(aes(year,made, color=manufacturer)) +
geom_line() +
geom_point() +
theme(aspect.ratio = 1/2) +
xlim(1985,2013)

#답안
planes %>% group_by(manufacturer) %>% mutate(n=n()) %>% filter(n>200) %>%
ggplot(aes(x=year)) +
geom_freqpoly(aes(color=manufacturer), binwidth=10)
# 그룹화 + 뮤테이트 = 내가 원하는 그거 (그룹 요소수 세기)




authors_df <- assign_gender(data_df = authors, first_name_col = "first_name")
authors_df %>% 
    group_by(gender) %>% 
    mutate(counts=n()) %>%
    filter(gender!="U") %>%
    group_by(gender, publication_years) %>%
    summarise(publicaiton_count = n(), counts=first(counts)) %>%
    arrange(gender, desc(publicaiton_count)) %>%
    summarise(most_published_year=first(publication_years),counts=first(counts))


#답안
temp=authors_df %>%
    filter(gender != "U") %>%
    group_by(gender) %>%
    count(publication_years) %>% 
    summarise(most_published_year = publication_years[rank(n)==length(n)],count=sum(n))
#미친문법 count함수와 rank와 length를 이용해 1등만 골라먹기 하는 미친 테크닉
#count = 그룹핑 두개 + 요약


jobs=read_csv("F:\\data\\NYC_Jobs-1.csv")

jobs=jobs %>% 
    select(`Job Category`, `Salary`) %>% 
    filter(`Job Category` %in% c("Finance, Accounting, & Procurement", "Technology, Data & Innovation", "Health"), `Salary`>10000)


jobs %>%
    ggplot(aes(x=`Job Category`, y=`Salary`, color=`Job Category`)) +
    geom_boxplot() +
    geom_point(data= jobs %>% filter(`Salary`>200000), shape="triangle", size=3)
