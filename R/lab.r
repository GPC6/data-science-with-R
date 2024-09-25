library(tidyverse)


wine=read_csv("F:\\data\\wine.csv")

ggplot(wine,aes(volatile_acidity,residual_sugar)) +
geom_point(aes(color=quality)) +
scale_x_log10()+
scale_y_log10()+
facet_wrap(~type, nrow=2) +
theme(aspect.ratio = 1/2)


ggplot(wine) +
geom_bar(aes(y=type,fill=quality),position="dodge") +
labs(x="",y="",title="Summary on wine qualities",subtitle="119 red wines, 224 white wines") +
theme(legend.position = "top",aspect.ratio = 1/2)
