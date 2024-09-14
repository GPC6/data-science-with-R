library(tidyverse)
heart_disease_columns <- c(
  "age",      # age in years
  "sex",      # sex
              # - 1 = male
              # - 0 = female
  "cp",       # chest pain type
              # - 1 = typical angina
              # - 2 = atypical angina
              # - 3 = non-anginal pain
              # - 4 = asymptomatic
  "trestbps", # resting blood pressure (in mm Hg on admission to the hospital)
  "chol",     # serum cholestoral in mg/dl
  "fbs",      # fasting blood sugar > 120 mg/dl
              # - 1 = true
              # - 0 = false
  "restecg",  # resting electrocardiographic results
              # - 1 = normal
              # - 2 = having ST-T wave abnormality
              # - 3 = showing probable or definite left ventricular hypertrophy
  "thalach",  # maximum heart rate achieved
  "exang",    # exercise induced angina
              # - 1 = yes
              # - 0 = no
  "oldpeak",  # ST depression induced by exercise relative to rest
  "slope",    # the slope of the peak exercise ST segment
              # - 1 = upsloping
              # - 2 = flat
              # - 3 = downsloping
  "ca",       # number of major vessels (0-3) colored by flourosopy
  "thal",     # thal
              # - 3 = normal
              # - 6 = fixed defect
              # - 7 = reversable defect
  "num"       # diagnosis of heart disease (angiographic disease status)
              # - 0 = (< 50% diameter narrowing)
              # - 1 = (> 50% diameter narrowing)
              # - 2 = ?
              # - 3 = ?
              # - 4 = ?
)
heart_disease <- read_csv("F:\\data\\processed－1.cleveland.data", col_types = cols(),
  col_names = heart_disease_columns, na = c("?")) %>%
  mutate(
    sex = factor(sex),
    cp = factor(cp),
    fbs = fbs > 0.5,
    restecg = factor(restecg),
    exang = exang > 0.5,
    slope = factor(slope),
    ca = as.integer(ca),
    thal = factor(thal),
    num = factor(num)
  )
heart_disease

oldest=heart_disease %>%
 filter(heart_disease$num==4, heart_disease$thal==3, heart_disease$oldpeak==0)

ggplot(heart_disease, aes(trestbps,num)) + 
    geom_point(aes(color=cp)) +
    geom_point(data=oldest,color="black") +
    facet_wrap(~thal, nrow=2) +
    scale_x_reverse(breaks=seq(100,200,by=25)) + 
    labs(
        title="Don't forget to put the labels (including *this* text).",
        subtitle = "Also, you should find the oldest one and draw the point with 'black' color."
        ) +
    theme(aspect.ratio = 1/2,legend.position = "bottom")

heart_disease %>%
    group_by(sex,cp) %>%
    mutate(n_cp=n()) %>% 
    arrange(desc(n_cp)) %>%
    group_by(sex) %>%
    summarise(mean_age = mean(age), most_common_cp=first(cp),count=first(n_cp))


ggplot(heart_disease,aes(age,chol)) +
    geom_point(aes(color=num)) +
    geom_smooth(method="lm",color="black") +
    facet_wrap(~num,nrow=1) +
    theme(aspect.ratio = 3/1)



library(nycflights13)

load("F:\\data\\holiday.RData")
load("F:\\data\\trees.RData")

merge=left_join(flights, holiday)

ans1 = merge %>% 
    filter(!is.na(name)) %>%
    count(name,name="count") %>%
    arrange(desc(count))

ans1

my_ymd_hms = function(datetime_str) {
    #먼저 시간이랑 tz 쪼개기
    split=unlist(str_split(datetime_str, " "))
    names(split)=c("년","월","일","전후","시","분","초","tz")
    #오전 오후 구분 12시 고려
    if(split["시"]=="12시"){
        if(split["전후"]=="오전"){
            split["시"] = paste0("0", "시")
        }
    }else if(split["전후"]=="오후"){
        split["시"] = paste0(as.character(parse_number(split["시"]) + 12), "시")
    }
    #기반으로 새로운 데이트타임 만들기
    new_datetime = str_c(split[-c(4,8)],collapse = " ")
    #tz 만들기
    tz=c(KST="Asia/Seoul",JST="Asia/Tokyo",CST="Asia/Shanghai")
    return(ymd_hms(new_datetime,tz=tz[split["tz"]]))
}

my_ymd_hms("2017년 6월 3일 오전 3시 50분 52초 JST") ==
  ymd_hms("2017-06-03 03:50:52", tz="Asia/Tokyo")
my_ymd_hms("2018년 8월 16일 오후 11시 16분 56초 CST") ==
  ymd_hms("2018-08-16 23:16:56", tz="Asia/Shanghai")
my_ymd_hms("2014년 11월 12일 오전 12시 1분 0초 KST") ==
  ymd_hms("2014-11-12 00:01:00", tz="Asia/Seoul")
my_ymd_hms("2022년 11월 26일 오후 12시 4분 0초 KST") ==
  ymd_hms("2022-11-26 12:04:00", tz="Asia/Seoul")


get_age = function(age, n) {
    new_age=age+n
    new_age[new_age<1]=30-new_age[new_age<1]
    new_age[new_age>30]=new_age[new_age>30]-30
    return(new_age)
}

age.at.2.2 = trees %>% filter(area.x==2,area.y==2) %>% .$age

all(get_age(age.at.2.2, n=1) == c(27,1,23,24,5))
all(get_age(age.at.2.2, n=-4) == c(22,26,18,19,30))

