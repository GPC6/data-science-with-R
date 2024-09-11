library(tidyverse)
library(stringr)

por=read_delim("F:\\data\\student-por.csv")
mat=read_delim("F:\\data\\student-mat.csv")

##1
cnms=colnames(por)
keys=cnms[!str_detect(cnms,"G|paid")]

grade_score=left_join(por,mat,by=keys,suffix=c(".por",".mat"))

sum(!is.na(grade_score$G1.mat))


##2
grade_score2=grade_score
is_char=unlist(map(grade_score2,is.character))
grade_score2[,is_char] = grade_score2[,is_char] %>% 
    map(as_factor) %>%
    as.data.frame(
        col.names=colnames(grade_score2[,is_char])
        )


grade_score2=grade_score2 %>% 
    mutate(
        age=cut(
            grade_score2$age,
            breaks=c(-Inf, 15, 16, 17, Inf),
            labels=c("15","16","17","over 18")
            )
) %>% rename(age.grp = age)

grade_score2 = grade_score2 %>%
    mutate(
        G3.por = cut(
                grade_score2$G3.por,
                breaks=c(-Inf,9,11,13,15,20),
                labels=c("F","D","C","B","A")
                )
) %>% rename(G3.por.grp = G3.por)

table(grade_score2$age.grp, grade_score2$G3.por.grp)

prop_A = grade_score2 %>%
    mutate(grade=(G3.por.grp=="A")*1) %>%
    group_by(school,age.grp,sex) %>%
    summarise(prop_A = mean(grade)) %>%
    arrange(desc(prop_A)) %>%
    mutate(group=str_c(school,age.grp,sex, sep="-"))

prop_A

ggplot(prop_A, aes(prop_A,reorder(group, prop_A))) +
geom_point(size=2) +
theme(aspect.ratio = 3/4)


##3

welfare = function(df, G3.por.limit, Dalc.limit, extra.cost, alchol.cost, welfare.type) {
    if(
        !is.numeric(G3.por.limit) |
        !is.numeric(Dalc.limit) | 
        !is.numeric(extra.cost) | 
        !is.numeric(G3.por.limit) | 
        !str_detect(welfare.type, "^extra$|^alchol$|^both$")
        ) return("error")


wel_data=df

wel_data = wel_data %>% 
    mutate(extra=(G3.por <= G3.por.limit & higher=="yes")) %>%
    mutate(alchol=(Walc == 5 & Dalc>=Dalc.limit))
    

if(welfare.type == "extra") {
    count=sum(wel_data$extra)
    cat("    ",count,"students will benefit from the",welfare.type,"walfare(s), and the required cost is",count*extra.cost,"WON.")
    }

if(welfare.type == "alchol") {
    count=sum(wel_data$alchol)
    cat("    ",count,"students will benefit from the",welfare.type,"walfare(s), and the required cost is",count*alchol.cost,"WON.")
    }

if(welfare.type=="both") {
    count=sum(wel_data$extra & wel_data$alchol)
    cat("    ",count,"students will benefit from the",welfare.type,"walfare(s), and the required cost is",count*(extra.cost+alchol.cost),"WON.")
}

invisible(wel_data)
        
}

welfare(df, G3.por.limit, Dalc.limit, extra.cost, alchol.cost, welfare.type)

df=grade_score
G3.por.limit=13
Dalc.limit=2
extra.cost=2
alchol.cost=3
welfare.type="extra"
