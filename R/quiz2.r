library(nycflights13)
library(tidyverse)
library(stringr)

holidays=read_csv("F:\\data\\holiday.csv")

holidays %>%
    filter(str_detect(name, "Birthday")) %>%
    summarise(num_birthday = n())

federal_flight = holidays %>%
    filter(type=="Federal Holiday") %>%
    left_join(flights)

federal_flight

federal_flight %>%
    select(name, tailnum) %>%
    group_by(name) %>%
    summarise(n=n()) %>%
    arrange(desc(n))


raw_mbti = read_table("F:\\data\\raw_MBTI.txt",col_names = FALSE)
data=tibble(
    mbti_pair=str_split(raw_mbti[[1]],",")[[1]]
    ) 

data2=summarise(
    data, 
    Man=str_sub(mbti_pair, 1,4), 
    Woman=str_sub(mbti_pair, -4,-1)
    )

mbti=c("ISTJ","ISTP","ESTP","ESTJ","ISFJ","ISFP","ESFP","ESFJ","INFJ","INFP","ENFP","ENFJ","INTJ","INTP","ENTJ","ENTP")

couple_MBTI = data2 %>%
    summarise(
        Man = factor(Man, levels=mbti),
        Woman = factor(Woman,levels=mbti)
        )

head(couple_MBTI,5)



couple_MBTI %>%
    count(Man, Woman) %>%
    ggplot(aes(Man, Woman)) +
    geom_tile(aes(fill=n)) +
    theme(aspect.ratio = 1/1)

counted_mbti=couple_MBTI %>%
    count(Man, Woman) %>%
    mutate(matched = is.na(Man)*1)


str_sub(counted_mbti[[i, 1]],j,j)  == str_sub(counted_mbti[[i, 2]],j,j)
for(i in 1:256)
{
    n=0
    for(j in 1:4)
    {
        n = n + (str_sub(counted_mbti[[i, 1]],j,j) == str_sub(counted_mbti[[i, 2]],j,j))*1
    }
    counted_mbti$matched[i]=n
} #상남자식 반복문

counted_mbti %>% 
    group_by(matched) %>%
    summarise(n=sum(n))


#답안
couple_MBTI %>%
    rowwise() %>%
    mutate(matched = length(intersect(unlist(str_split(Man,"")), unlist(str_split(Woman,""))))) %>%
    group_by(matched) %>%
    summarise(n=n())

#rowwise 함수는 각 행을 다 그룹화 시킨다
#마치 행별로 전부 브로드캐스팅하는 느낌


starwars %>%
    select(name) %>%
    filter(!is.na(parse_number(name)))

is_vowel=starwars %>%
    select(name) %>%
    mutate(vowel=str_count(name,"[aeiouAEIOU]")) %>%
    arrange(vowel)
is_vowel

is_vowel %>%
    group_by(vowel) %>%
    summarise(mean_vowel = mean(str_length(name)))


#답안 (패턴만들기)

num=c(as.character(0:9)) #문자열
num_pattern=str_c(num,collapse = "|")
starwars %>%
    select(name) %>%
    filter(str_detect(name,num_pattern))

