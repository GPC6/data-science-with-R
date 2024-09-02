library(tidyverse)
library(ggrepel)
library(quantmod)


colatz = function(n) {
    if((n-floor(n)) != 0) {  #1로나눈 나머지로 구현가능
        return("자연수를 입력하시오.")
    }

    trial=0
    number=c(n)
    while(n != 1) {
        if(n%%2==0) {
            n=n/2
        } else {
            n=3*n+1
        }
        trial = trial + 1
        number[trial+1]=n
    }
    result=tibble(number=number, trial= 0:trial)
    return(result)
}

big=colatz(436712387)
tail(big)


ggplot(big, aes(trial, number)) + 
    geom_line(color="blue") +
    geom_point(data=big[nrow(big),], color="red",size=3) +
    geom_label(data=big[nrow(big),],   label=paste(big[nrow(big),2],"번,",big[nrow(big),1]), nudge_y=max(big$number)*0.075) +
    theme(aspect.ratio = 1/2)

colatz(100.5)



point=lakers %>%
    select(1:10)

mean_point = point %>%
    group_by(opponent) %>%
    summarise(mean_get_score=mean(points)) %>%
    arrange(mean_get_score)

mean_point %>%
    ggplot(aes(reorder(opponent, mean_get_score), mean_get_score)) +
    geom_bar(stat="identity") +
    xlab("opponent") +
    theme(aspect.ratio = 1/2)
#답안

point=lakers %>%
    mutate_at(vars(1,2,3,5,6,7,8,9,11),as.factor) %>%
    select(1:10) %>%
    filter(team=="LAL") #데이터 EDA 잘하시오

score=point %>%
    group_by(opponent) %>%
    summarise(score=sum(points))


game_with_LAL = point %>%
    count(date, opponent) %>%
    count(opponent)

full_join(score,game_with_LAL) %>% 
    mutate(mean_score=score/n) %>% #평균 득점을 잘 해석하기
    ggplot(aes(mean_score, fct_reorder(opponent,mean_score))) + 
    geom_point() +
    theme(aspect.ratio = 1/2)




head(point)

point %>%
    filter(etype=="free throw") %>%
    group_by(player) %>%
    summarise(free_count=n()) %>%
    arrange(desc(free_count)) %>%
    head(10)

date_point=point %>%
    group_by(date) %>%
    summarise(points=sum(points))



date_point %>%
    mutate(date=as_date(as.character(date))) %>%
    ggplot(aes(date, points)) +
    geom_line() +
    geom_point(size=2) +
    theme(aspect.ratio = 1/2)




stockdata <-
  getSymbols(
    Symbols = "TSLA",
    src = "yahoo",
    from = Sys.Date() - 2000,
    to = Sys.Date(),
    auto.assign = FALSE
  )
stock_date <- as.character(index(stockdata))
stock_price <- coredata(stockdata)[, 4]
stock <- as.data.frame(cbind(stock_date, stock_price))
stock$stock_price <- as.numeric(stock$stock_price)

head(stock, 10)


invest = function(start_date, end_date) {
    start_date = as_date(start_date)
    end_date = as_date(end_date)
    if(end_date-start_date <50)
        return("Period input error")

    stockdata <-
    getSymbols(
        Symbols = "TSLA",
        src = "yahoo",
        from = Sys.Date() - 2000,
        to = Sys.Date(),
        auto.assign = FALSE
  )
    stock_date <- as.character(index(stockdata))
    stock_price <- coredata(stockdata)[, 4]
    stock <- as.data.frame(cbind(stock_date, stock_price))
    stock$stock_price <- as.numeric(stock$stock_price)

    target_stock = stock %>% 
        filter(stock_date >= start_date, stock_date <= end_date) %>%
        mutate(stock_date=as_date(stock_date))
    num=nrow(target_stock)
    data=vector("list",num-1)
    high_rate=vector("double",num-1)
    sell_date=vector("character",num-1)
    for(i in 1:(num-1)) {
        price=target_stock %>%
            filter(stock_date>stock_date[i]+49, stock_price > stock_price[i])
            if(!nrow(price)) {
                data[[i]]==NULL
                high_rate[[i]] = 1
                sell_date[[i]] = 0
            } else {
                data[[i]]=price %>% filter(stock_price==max(stock_price))
                high_rate[[i]]=data[[i]][1,2]/target_stock$stock_price[i]
                sell_date[[i]]=data[[i]][1,1]
            }
    }


    result=tibble(
        buy_date=target_stock$stock_date,
        high_rate = c(round((high_rate-1)*100,digits=2),0),
        sell_date=c(sell_date,0)
        ) %>%
        mutate(sell_date= as_date(as.numeric(sell_date))) %>%
        filter(high_rate==max(high_rate))
    if(result$high_rate[1]==0) {
        return("Do not invest")
    } else {
        return(paste0("Buy stock on ",result$buy_date[1],", and sell it on ", result$sell_date[1], " that earns ",result$high_rate[1],"%."))
    }
}


invest('2022-01-28','2023-08-31')
invest('2022-09-16','2023-01-06')
invest('2019-06-30','2022-06-30')
invest('2022-09-16','2022-10-30')
invest('2021-11-05','2023-01-06')
