library(tidyverse)

euler_method = function(de,ini,h,end) {
    t=seq(ini[1], end, by=h)
    y=vector(mode="double",length=length(t))
    y[1]=ini[2]
    n=length(t)-1
    for(i in 1:n){
        y[i+1]= de(t[i],y[i])*(t[i+1]-t[i]) + y[i]
    }
    return(tibble(t=t,y=y))
}

f1=function(t,y){
    return(1+t-y)
}

f2=function(t,y){
    return(2*t*y)
}

f3=function(t,y){
    return(t*exp(-y)+t/(1+t^2))
}

t=seq(0,1,by=0.0001)
y=log(1+t^2)
real=tibble(t=t,y=y)

euler_method(f3,c(0,0),0.0025,1) %>%
ggplot(aes(t,y)) + geom_line() + geom_line(data=real,color="red")

