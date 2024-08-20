---
title: "Session 04: Transformation"
author: "326.212 전산통계 및 실습"
institute: "서울대학교 통계학과"
output: 
  html_document:
    keep_md: true
---



# Recap : `dplyr` package for data transformation

Before we move on, don’t forget to load `tidverse`:


```r
library(tidyverse)
```

```
## Warning: package 'tidyverse' was built under R version 4.0.4
```

```
## -- Attaching packages --------------------------------------- tidyverse 1.3.0 --
```

```
## √ ggplot2 3.3.3     √ purrr   0.3.4
## √ tibble  3.1.0     √ dplyr   1.0.5
## √ tidyr   1.1.3     √ stringr 1.4.0
## √ readr   1.4.0     √ forcats 0.5.1
```

```
## Warning: package 'ggplot2' was built under R version 4.0.4
```

```
## Warning: package 'tibble' was built under R version 4.0.4
```

```
## Warning: package 'tidyr' was built under R version 4.0.4
```

```
## Warning: package 'readr' was built under R version 4.0.4
```

```
## Warning: package 'purrr' was built under R version 4.0.4
```

```
## Warning: package 'dplyr' was built under R version 4.0.4
```

```
## Warning: package 'stringr' was built under R version 4.0.4
```

```
## Warning: package 'forcats' was built under R version 4.0.4
```

```
## -- Conflicts ------------------------------------------ tidyverse_conflicts() --
## x dplyr::filter() masks stats::filter()
## x dplyr::lag()    masks stats::lag()
```

## Example : `nycflights3`


```r
library(nycflights13)
```

```
## Warning: package 'nycflights13' was built under R version 4.0.5
```

336,776 flights that departed from New York City in 2013:


```r
head(flights)
```

```
## # A tibble: 6 x 19
##    year month   day dep_time sched_dep_time dep_delay arr_time sched_arr_time
##   <int> <int> <int>    <int>          <int>     <dbl>    <int>          <int>
## 1  2013     1     1      517            515         2      830            819
## 2  2013     1     1      533            529         4      850            830
## 3  2013     1     1      542            540         2      923            850
## 4  2013     1     1      544            545        -1     1004           1022
## 5  2013     1     1      554            600        -6      812            837
## 6  2013     1     1      554            558        -4      740            728
## # ... with 11 more variables: arr_delay <dbl>, carrier <chr>, flight <int>,
## #   tailnum <chr>, origin <chr>, dest <chr>, air_time <dbl>, distance <dbl>,
## #   hour <dbl>, minute <dbl>, time_hour <dttm>
```


```r
dim(flights)
```

```
## [1] 336776     19
```

# Key Idea of Data Transformation

It is rare that you get the data in exactly the right form you need.

`dplyr` package provides you with some key functions that allow you to solve the vast majority of your data manipulation challenges.

All verbs of `dplyr` work similarly:
    1. The first argument is a data frame.
    1. The subsequent arguments describe what to do with the data frame, using the variable names (without quotes).
    1. The result is a new data frame.

## Pipe operator: `%>%`

* [Book](http://r4ds.had.co.nz/transform.html#grouped-summaries-with-summarise)

Pipe operator `%>%` passes the result of the previous function to the next function where `.` is. If `.` does not exist, the result will be passed to the first argument of the next function. Hence, following 3 lines of codes are all equivalent.


```r
select(flights, year, month, day)
```

```
## # A tibble: 336,776 x 3
##     year month   day
##    <int> <int> <int>
##  1  2013     1     1
##  2  2013     1     1
##  3  2013     1     1
##  4  2013     1     1
##  5  2013     1     1
##  6  2013     1     1
##  7  2013     1     1
##  8  2013     1     1
##  9  2013     1     1
## 10  2013     1     1
## # ... with 336,766 more rows
```


```r
flights %>% select(., year, month, day)
```

```
## # A tibble: 336,776 x 3
##     year month   day
##    <int> <int> <int>
##  1  2013     1     1
##  2  2013     1     1
##  3  2013     1     1
##  4  2013     1     1
##  5  2013     1     1
##  6  2013     1     1
##  7  2013     1     1
##  8  2013     1     1
##  9  2013     1     1
## 10  2013     1     1
## # ... with 336,766 more rows
```


```r
flights %>% select(year, month, day)
```

```
## # A tibble: 336,776 x 3
##     year month   day
##    <int> <int> <int>
##  1  2013     1     1
##  2  2013     1     1
##  3  2013     1     1
##  4  2013     1     1
##  5  2013     1     1
##  6  2013     1     1
##  7  2013     1     1
##  8  2013     1     1
##  9  2013     1     1
## 10  2013     1     1
## # ... with 336,766 more rows
```

Using pipeline operator may make codes cleaner. Consider the difference between following 3 different styles of codes, which all prints out the same result.


```r
summarise(arrange(filter(group_by(mutate(filter(flights, !is.na(dep_delay), !is.na(arr_delay)), sched_dep_hour = sched_dep_time %/% 100), dest), n() > 10000), dep_delay), recommend_time=first(sched_dep_hour), delay=first(dep_delay))
```

```
## # A tibble: 9 x 3
##   dest  recommend_time delay
##   <chr>          <dbl> <dbl>
## 1 ATL               20   -23
## 2 BOS               21   -23
## 3 CLT                6   -19
## 4 FLL                9   -24
## 5 LAX                9   -16
## 6 MCO               21   -21
## 7 MIA                7   -17
## 8 ORD               13   -20
## 9 SFO                7   -20
```


```r
flights_notNA <- filter(flights, !is.na(dep_delay), !is.na(arr_delay))
flights_mutate <- mutate(flights_notNA, sched_dep_hour = sched_dep_time %/% 100)
flights_dest_filter <- filter(group_by(flights_mutate, dest), n() > 10000)
flights_summarise <- summarise(arrange(flights_dest_filter, dep_delay), recommend_time=first(sched_dep_hour), delay=first(dep_delay))
flights_summarise
```

```
## # A tibble: 9 x 3
##   dest  recommend_time delay
##   <chr>          <dbl> <dbl>
## 1 ATL               20   -23
## 2 BOS               21   -23
## 3 CLT                6   -19
## 4 FLL                9   -24
## 5 LAX                9   -16
## 6 MCO               21   -21
## 7 MIA                7   -17
## 8 ORD               13   -20
## 9 SFO                7   -20
```


```r
flights %>% 
  filter(!is.na(dep_delay), !is.na(arr_delay)) %>% 
  mutate(sched_dep_hour = sched_dep_time %/% 100) %>%
  group_by(dest) %>% filter(n() > 10000) %>%
  arrange(dep_delay) %>%
  summarise(recommend_time=first(sched_dep_hour), delay=first(dep_delay))
```

```
## # A tibble: 9 x 3
##   dest  recommend_time delay
##   <chr>          <dbl> <dbl>
## 1 ATL               20   -23
## 2 BOS               21   -23
## 3 CLT                6   -19
## 4 FLL                9   -24
## 5 LAX                9   -16
## 6 MCO               21   -21
## 7 MIA                7   -17
## 8 ORD               13   -20
## 9 SFO                7   -20
```

## Summary

* Select observations by their values: `filter()`
* Select variables by their name: `selection()`
* Grouping : `group_by()`
    * Grouping by multiple variables
    * Ungrouping : `ungroup()`
* Reordering : `arrange()`, `desc()`
* Create variables or summaries : `mutate()`, `transmute()`, `summarise()`
    * Counts : `n()`
* ETC
    * Rename a variable: `rename()`
    * Missing values: `NA`

---
### Selection

#### Pick observations by their values: `filter()`

* [Book](http://r4ds.had.co.nz/transform.html#filter-rows-with-filter)
* Filter __rows__ with `filter()`.


```r
filter(flights, month == 1, day == 1)
```

```
## # A tibble: 842 x 19
##     year month   day dep_time sched_dep_time dep_delay arr_time sched_arr_time
##    <int> <int> <int>    <int>          <int>     <dbl>    <int>          <int>
##  1  2013     1     1      517            515         2      830            819
##  2  2013     1     1      533            529         4      850            830
##  3  2013     1     1      542            540         2      923            850
##  4  2013     1     1      544            545        -1     1004           1022
##  5  2013     1     1      554            600        -6      812            837
##  6  2013     1     1      554            558        -4      740            728
##  7  2013     1     1      555            600        -5      913            854
##  8  2013     1     1      557            600        -3      709            723
##  9  2013     1     1      557            600        -3      838            846
## 10  2013     1     1      558            600        -2      753            745
## # ... with 832 more rows, and 11 more variables: arr_delay <dbl>,
## #   carrier <chr>, flight <int>, tailnum <chr>, origin <chr>, dest <chr>,
## #   air_time <dbl>, distance <dbl>, hour <dbl>, minute <dbl>, time_hour <dttm>
```

* How to select the observations
* Comparison operators: `>`, `>=`, `<`, `<=`, `!=`, `==`, `near()`
* Logical (boolean) operators : `&`, `|`, `!`, `xor()`


```r
flightsNovDec <- filter(flights, month == 11 | month == 12)
head(flightsNovDec)
```

```
## # A tibble: 6 x 19
##    year month   day dep_time sched_dep_time dep_delay arr_time sched_arr_time
##   <int> <int> <int>    <int>          <int>     <dbl>    <int>          <int>
## 1  2013    11     1        5           2359         6      352            345
## 2  2013    11     1       35           2250       105      123           2356
## 3  2013    11     1      455            500        -5      641            651
## 4  2013    11     1      539            545        -6      856            827
## 5  2013    11     1      542            545        -3      831            855
## 6  2013    11     1      549            600       -11      912            923
## # ... with 11 more variables: arr_delay <dbl>, carrier <chr>, flight <int>,
## #   tailnum <chr>, origin <chr>, dest <chr>, air_time <dbl>, distance <dbl>,
## #   hour <dbl>, minute <dbl>, time_hour <dttm>
```


```r
filter(flights, arr_delay <= 120, dep_delay <= 120)
```

```
## # A tibble: 316,050 x 19
##     year month   day dep_time sched_dep_time dep_delay arr_time sched_arr_time
##    <int> <int> <int>    <int>          <int>     <dbl>    <int>          <int>
##  1  2013     1     1      517            515         2      830            819
##  2  2013     1     1      533            529         4      850            830
##  3  2013     1     1      542            540         2      923            850
##  4  2013     1     1      544            545        -1     1004           1022
##  5  2013     1     1      554            600        -6      812            837
##  6  2013     1     1      554            558        -4      740            728
##  7  2013     1     1      555            600        -5      913            854
##  8  2013     1     1      557            600        -3      709            723
##  9  2013     1     1      557            600        -3      838            846
## 10  2013     1     1      558            600        -2      753            745
## # ... with 316,040 more rows, and 11 more variables: arr_delay <dbl>,
## #   carrier <chr>, flight <int>, tailnum <chr>, origin <chr>, dest <chr>,
## #   air_time <dbl>, distance <dbl>, hour <dbl>, minute <dbl>, time_hour <dttm>
```

#### Pick variables by their names: `select()`.
* [Book](https://r4ds.had.co.nz/transform.html#select)
* Select __columns__ by variable name


```r
tmp <- select(flights, year, month, day)
head(tmp)
```

```
## # A tibble: 6 x 3
##    year month   day
##   <int> <int> <int>
## 1  2013     1     1
## 2  2013     1     1
## 3  2013     1     1
## 4  2013     1     1
## 5  2013     1     1
## 6  2013     1     1
```

* Helper functions
    * `everything()`
    * `starts_with("abc")`
    * `ends_with("xyz")`
    * `contains("ijk")`
    * `matches("(.)\\1")`
    * `num_range("x", 1:3)`


```r
colnames(flights)
```

```
##  [1] "year"           "month"          "day"            "dep_time"      
##  [5] "sched_dep_time" "dep_delay"      "arr_time"       "sched_arr_time"
##  [9] "arr_delay"      "carrier"        "flight"         "tailnum"       
## [13] "origin"         "dest"           "air_time"       "distance"      
## [17] "hour"           "minute"         "time_hour"
```


```r
tmp <- select(flights, year:day, ends_with("time"), -starts_with("sched"), dim(flights)[2])
head(tmp)
```

```
## # A tibble: 6 x 7
##    year month   day dep_time arr_time air_time time_hour          
##   <int> <int> <int>    <int>    <int>    <dbl> <dttm>             
## 1  2013     1     1      517      830      227 2013-01-01 05:00:00
## 2  2013     1     1      533      850      227 2013-01-01 05:00:00
## 3  2013     1     1      542      923      160 2013-01-01 05:00:00
## 4  2013     1     1      544     1004      183 2013-01-01 05:00:00
## 5  2013     1     1      554      812      116 2013-01-01 06:00:00
## 6  2013     1     1      554      740      150 2013-01-01 05:00:00
```

---
### Grouping
#### Grouping by values
* [Book](http://r4ds.had.co.nz/transform.html#grouped-summaries-with-summarise)
* `group_by()` changes the unit of analysis from the complete dataset to individual groups.
* When you use the dplyr verbs on a grouped data frame they’ll be automatically applied “by group”.


```r
by_day <- group_by(flights, year, month, day)
head(by_day)
```

```
## # A tibble: 6 x 19
## # Groups:   year, month, day [1]
##    year month   day dep_time sched_dep_time dep_delay arr_time sched_arr_time
##   <int> <int> <int>    <int>          <int>     <dbl>    <int>          <int>
## 1  2013     1     1      517            515         2      830            819
## 2  2013     1     1      533            529         4      850            830
## 3  2013     1     1      542            540         2      923            850
## 4  2013     1     1      544            545        -1     1004           1022
## 5  2013     1     1      554            600        -6      812            837
## 6  2013     1     1      554            558        -4      740            728
## # ... with 11 more variables: arr_delay <dbl>, carrier <chr>, flight <int>,
## #   tailnum <chr>, origin <chr>, dest <chr>, air_time <dbl>, distance <dbl>,
## #   hour <dbl>, minute <dbl>, time_hour <dttm>
```

#### Grouping by multiple values (Ch 5.6.5)

* [Book](http://r4ds.had.co.nz/transform.html#grouping-by-multiple-variables)


```r
daily <- group_by(flights, year, month, day)
(per_day   <- summarise(daily, flights = n()))
```

```
## `summarise()` has grouped output by 'year', 'month'. You can override using the `.groups` argument.
```

```
## # A tibble: 365 x 4
## # Groups:   year, month [12]
##     year month   day flights
##    <int> <int> <int>   <int>
##  1  2013     1     1     842
##  2  2013     1     2     943
##  3  2013     1     3     914
##  4  2013     1     4     915
##  5  2013     1     5     720
##  6  2013     1     6     832
##  7  2013     1     7     933
##  8  2013     1     8     899
##  9  2013     1     9     902
## 10  2013     1    10     932
## # ... with 355 more rows
```


```r
(per_month <- summarise(per_day, flights = sum(flights)))
```

```
## `summarise()` has grouped output by 'year'. You can override using the `.groups` argument.
```

```
## # A tibble: 12 x 3
## # Groups:   year [1]
##     year month flights
##    <int> <int>   <int>
##  1  2013     1   27004
##  2  2013     2   24951
##  3  2013     3   28834
##  4  2013     4   28330
##  5  2013     5   28796
##  6  2013     6   28243
##  7  2013     7   29425
##  8  2013     8   29327
##  9  2013     9   27574
## 10  2013    10   28889
## 11  2013    11   27268
## 12  2013    12   28135
```


```r
(per_year  <- summarise(per_month, flights = sum(flights)))
```

```
## # A tibble: 1 x 2
##    year flights
##   <int>   <int>
## 1  2013  336776
```

* Be careful when progressively rolling up summaries:
    * we need to think about weighting means and variances
    * it’s not possible to do it exactly for rank-based statistics like the median.
    * the sum of groupwise sums is the overall sum, but the median of groupwise medians is not the overall median.

#### Ungrouping (Ch 5.6.6) : `ungroup()`
* [Book](http://r4ds.had.co.nz/transform.html#ungrouping)
* If you need to remove grouping, and return to operations on ungrouped data, use `ungroup()`


```r
daily <- group_by(flights, year, month, day)
head(daily)
```

```
## # A tibble: 6 x 19
## # Groups:   year, month, day [1]
##    year month   day dep_time sched_dep_time dep_delay arr_time sched_arr_time
##   <int> <int> <int>    <int>          <int>     <dbl>    <int>          <int>
## 1  2013     1     1      517            515         2      830            819
## 2  2013     1     1      533            529         4      850            830
## 3  2013     1     1      542            540         2      923            850
## 4  2013     1     1      544            545        -1     1004           1022
## 5  2013     1     1      554            600        -6      812            837
## 6  2013     1     1      554            558        -4      740            728
## # ... with 11 more variables: arr_delay <dbl>, carrier <chr>, flight <int>,
## #   tailnum <chr>, origin <chr>, dest <chr>, air_time <dbl>, distance <dbl>,
## #   hour <dbl>, minute <dbl>, time_hour <dttm>
```


```r
head(daily %>% summarise(flights = n()))
```

```
## `summarise()` has grouped output by 'year', 'month'. You can override using the `.groups` argument.
```

```
## # A tibble: 6 x 4
## # Groups:   year, month [1]
##    year month   day flights
##   <int> <int> <int>   <int>
## 1  2013     1     1     842
## 2  2013     1     2     943
## 3  2013     1     3     914
## 4  2013     1     4     915
## 5  2013     1     5     720
## 6  2013     1     6     832
```


```r
tmp<- daily %>% ungroup() 
head(tmp)
```

```
## # A tibble: 6 x 19
##    year month   day dep_time sched_dep_time dep_delay arr_time sched_arr_time
##   <int> <int> <int>    <int>          <int>     <dbl>    <int>          <int>
## 1  2013     1     1      517            515         2      830            819
## 2  2013     1     1      533            529         4      850            830
## 3  2013     1     1      542            540         2      923            850
## 4  2013     1     1      544            545        -1     1004           1022
## 5  2013     1     1      554            600        -6      812            837
## 6  2013     1     1      554            558        -4      740            728
## # ... with 11 more variables: arr_delay <dbl>, carrier <chr>, flight <int>,
## #   tailnum <chr>, origin <chr>, dest <chr>, air_time <dbl>, distance <dbl>,
## #   hour <dbl>, minute <dbl>, time_hour <dttm>
```


```r
tmp %>% summarise(flights = n())
```

```
## # A tibble: 1 x 1
##   flights
##     <int>
## 1  336776
```


---
### Reordering
#### Reorder the observations : `arrange()`
* [Book](http://r4ds.had.co.nz/transform.html#arrange-rows-with-arrange)
* `arrange()` changes the order of __rows__.
* It takes a data frame and a set of column names (or more complicated expressions) to order by.


```r
arrange(flights, year, month, day)
```

```
## # A tibble: 336,776 x 19
##     year month   day dep_time sched_dep_time dep_delay arr_time sched_arr_time
##    <int> <int> <int>    <int>          <int>     <dbl>    <int>          <int>
##  1  2013     1     1      517            515         2      830            819
##  2  2013     1     1      533            529         4      850            830
##  3  2013     1     1      542            540         2      923            850
##  4  2013     1     1      544            545        -1     1004           1022
##  5  2013     1     1      554            600        -6      812            837
##  6  2013     1     1      554            558        -4      740            728
##  7  2013     1     1      555            600        -5      913            854
##  8  2013     1     1      557            600        -3      709            723
##  9  2013     1     1      557            600        -3      838            846
## 10  2013     1     1      558            600        -2      753            745
## # ... with 336,766 more rows, and 11 more variables: arr_delay <dbl>,
## #   carrier <chr>, flight <int>, tailnum <chr>, origin <chr>, dest <chr>,
## #   air_time <dbl>, distance <dbl>, hour <dbl>, minute <dbl>, time_hour <dttm>
```


```r
arrange(flights, desc(arr_delay))
```

```
## # A tibble: 336,776 x 19
##     year month   day dep_time sched_dep_time dep_delay arr_time sched_arr_time
##    <int> <int> <int>    <int>          <int>     <dbl>    <int>          <int>
##  1  2013     1     9      641            900      1301     1242           1530
##  2  2013     6    15     1432           1935      1137     1607           2120
##  3  2013     1    10     1121           1635      1126     1239           1810
##  4  2013     9    20     1139           1845      1014     1457           2210
##  5  2013     7    22      845           1600      1005     1044           1815
##  6  2013     4    10     1100           1900       960     1342           2211
##  7  2013     3    17     2321            810       911      135           1020
##  8  2013     7    22     2257            759       898      121           1026
##  9  2013    12     5      756           1700       896     1058           2020
## 10  2013     5     3     1133           2055       878     1250           2215
## # ... with 336,766 more rows, and 11 more variables: arr_delay <dbl>,
## #   carrier <chr>, flight <int>, tailnum <chr>, origin <chr>, dest <chr>,
## #   air_time <dbl>, distance <dbl>, hour <dbl>, minute <dbl>, time_hour <dttm>
```


```r
x <- factor(letters)
arrange(tibble(x), desc(x))
```

```
## # A tibble: 26 x 1
##    x    
##    <fct>
##  1 z    
##  2 y    
##  3 x    
##  4 w    
##  5 v    
##  6 u    
##  7 t    
##  8 s    
##  9 r    
## 10 q    
## # ... with 16 more rows
```

* Missing values are always sorted at the end:


```r
df <- tibble(x = c(5, 2, NA))
arrange(df, x)
```

```
## # A tibble: 3 x 1
##       x
##   <dbl>
## 1     2
## 2     5
## 3    NA
```


```r
arrange(df, desc(x))
```

```
## # A tibble: 3 x 1
##       x
##   <dbl>
## 1     5
## 2     2
## 3    NA
```

---
### Change or Create variables

#### Create new variables with functions of existing variables: `mutate()`.

* [Book](http://r4ds.had.co.nz/transform.html#add-new-variables-with-mutate)


```r
flights_sml <- 
  select(flights, year:day, ends_with("delay"), distance, air_time) %>% 
  mutate(gain = arr_delay - dep_delay,
         hours = air_time / 60, gain_per_hour = gain / hours )
head(flights_sml)
```

```
## # A tibble: 6 x 10
##    year month   day dep_delay arr_delay distance air_time  gain hours
##   <int> <int> <int>     <dbl>     <dbl>    <dbl>    <dbl> <dbl> <dbl>
## 1  2013     1     1         2        11     1400      227     9  3.78
## 2  2013     1     1         4        20     1416      227    16  3.78
## 3  2013     1     1         2        33     1089      160    31  2.67
## 4  2013     1     1        -1       -18     1576      183   -17  3.05
## 5  2013     1     1        -6       -25      762      116   -19  1.93
## 6  2013     1     1        -4        12      719      150    16  2.5 
## # ... with 1 more variable: gain_per_hour <dbl>
```

#### Only keep the new variables: `transmute()`


```r
tmp <- select(flights, year:day, ends_with("delay"), distance, air_time) %>% 
  transmute(gain = arr_delay - dep_delay,
            hours = air_time / 60, gain_per_hour = gain / hours )
head(tmp)
```

```
## # A tibble: 6 x 3
##    gain hours gain_per_hour
##   <dbl> <dbl>         <dbl>
## 1     9  3.78          2.38
## 2    16  3.78          4.23
## 3    31  2.67         11.6 
## 4   -17  3.05         -5.57
## 5   -19  1.93         -9.83
## 6    16  2.5           6.4
```

#### Useful creation functions
* The function must be vectorised: it must take a vector of values as input, return a vector with the same number of values as output.
* Arithmetic operators: `+`, `-`, `*`, `/`, `^`.
* Modular arithmetic: `%/%` (integer division) and `%%` (remainder).
* Logs: `log()`, `log2()`, `log10()`.
* Offsets: `lead()`, `lag()`.
* Cumulative and rolling aggregates: `cumsum()`, `cumprod()`, `cummin()`, `cummax()`, and `dplyr::cummean()`.
* Logical comparisons: `<`, `<=`, `>`, `>=`, `!=`.
* Ranking: `min_rank()`

#### Collapse many values down to a single summary: `summarise()`
* [Book](http://r4ds.had.co.nz/transform.html#grouped-summaries-with-summarise)
* Grouped summaries with `summarise()`
* It collapses a data frame to a single row:


```r
summarise(flights, delay = mean(dep_delay, na.rm = TRUE))
```

```
## # A tibble: 1 x 1
##   delay
##   <dbl>
## 1  12.6
```

* Useful if paired with `group_by()`:


```r
by_day <- group_by(flights, year, month, day) %>% 
  summarise(delay = mean(dep_delay, na.rm = TRUE)) 
```

```
## `summarise()` has grouped output by 'year', 'month'. You can override using the `.groups` argument.
```

```r
head(by_day)
```

```
## # A tibble: 6 x 4
## # Groups:   year, month [1]
##    year month   day delay
##   <int> <int> <int> <dbl>
## 1  2013     1     1 11.5 
## 2  2013     1     2 13.9 
## 3  2013     1     3 11.0 
## 4  2013     1     4  8.95
## 5  2013     1     5  5.73
## 6  2013     1     6  7.15
```


```r
delays <- flights %>% 
  group_by(dest) %>% 
  summarise(
    count = n(), dist = mean(distance, na.rm = TRUE), delay = mean(arr_delay, na.rm = TRUE) ) %>% 
  filter(count > 20, dest != "HNL")
head(delays)
```

```
## # A tibble: 6 x 4
##   dest  count  dist delay
##   <chr> <int> <dbl> <dbl>
## 1 ABQ     254 1826   4.38
## 2 ACK     265  199   4.85
## 3 ALB     439  143  14.4 
## 4 ATL   17215  757. 11.3 
## 5 AUS    2439 1514.  6.02
## 6 AVL     275  584.  8.00
```


```r
ggplot(data = delays, mapping = aes(x = dist, y = delay)) +
  geom_point(aes(size = count), alpha = 1/3) + geom_smooth(se = FALSE)
```

```
## `geom_smooth()` using method = 'loess' and formula 'y ~ x'
```

![](lab_04_transformation_files/figure-html/unnamed-chunk-35-1.png)<!-- -->


```r
not_cancelled <- flights %>% 
  filter(!is.na(dep_delay), !is.na(arr_delay))

not_cancelled %>% 
  group_by(year, month, day) %>% 
  summarise(mean = mean(dep_delay))
```

```
## `summarise()` has grouped output by 'year', 'month'. You can override using the `.groups` argument.
```

```
## # A tibble: 365 x 4
## # Groups:   year, month [12]
##     year month   day  mean
##    <int> <int> <int> <dbl>
##  1  2013     1     1 11.4 
##  2  2013     1     2 13.7 
##  3  2013     1     3 10.9 
##  4  2013     1     4  8.97
##  5  2013     1     5  5.73
##  6  2013     1     6  7.15
##  7  2013     1     7  5.42
##  8  2013     1     8  2.56
##  9  2013     1     9  2.30
## 10  2013     1    10  2.84
## # ... with 355 more rows
```

#### Count: `n()` (Ch 5.6.3)

* [Book](http://r4ds.had.co.nz/transform.html#counts)
* Count: `n()`
* Count of non-missing values: `sum(!is.na(x))`
* Whenever you do any aggregation, you can check that you’re not drawing conclusions based on very small amounts of data by including __count__.
* The planes that have the highest average delays:

```r
not_cancelled <- flights %>% 
  filter(!is.na(dep_delay), !is.na(arr_delay))

delays <- not_cancelled %>% 
  group_by(tailnum) %>% 
  summarise(
    delay = mean(arr_delay)
  )

ggplot(data = delays, mapping = aes(x = delay)) + 
  geom_freqpoly(binwidth = 10)
```

![](lab_04_transformation_files/figure-html/unnamed-chunk-37-1.png)<!-- -->

* A scatterplot of number of flights vs. average delay:

```r
delays <- not_cancelled %>% 
  group_by(tailnum) %>% 
  summarise(
    delay = mean(arr_delay, na.rm = TRUE),
    n = n()
  )

ggplot(data = delays, mapping = aes(x = n, y = delay)) + 
  geom_point(alpha = 1/10)
```

![](lab_04_transformation_files/figure-html/unnamed-chunk-38-1.png)<!-- -->

* There is much greater variation in the average delay when there are few flights.
* The variation decreases as the sample size increases.
* It’s often useful to filter out the groups with the smallest numbers of observations, so you can see more of the pattern and less of the extreme variation in the smallest groups.


```r
delays %>% 
  filter(n > 25) %>% 
  ggplot(mapping = aes(x = n, y = delay)) + 
    geom_point(alpha = 1/10)
```

![](lab_04_transformation_files/figure-html/unnamed-chunk-39-1.png)<!-- -->

* Example : `Lahman`


```r
batting <- as_tibble(Lahman::Batting)
```

```
## Error in loadNamespace(name): there is no package called 'Lahman'
```

```r
head(batting)
```

```
## Error in head(batting): 객체 'batting'를 찾을 수 없습니다
```

* `ba`: the skill of the batter (measured by the batting average)
* `ab`: the number of opportunities to hit the ball (measured by at bat)


```r
batters <- batting %>% 
  group_by(playerID) %>% 
  summarise(
    ba = sum(H, na.rm = TRUE) / sum(AB, na.rm = TRUE),
    ab = sum(AB, na.rm = TRUE)
  )
```

```
## Error in group_by(., playerID): 객체 'batting'를 찾을 수 없습니다
```

```r
head(batters)
```

```
## Error in head(batters): 객체 'batters'를 찾을 수 없습니다
```


```r
batters %>% 
  filter(ab > 100) %>% 
  ggplot(mapping = aes(x = ab, y = ba)) +
    geom_point() + 
    geom_smooth(se = FALSE)
```

```
## Error in filter(., ab > 100): 객체 'batters'를 찾을 수 없습니다
```

* There’s a positive correlation between skill (`ba`) and opportunities to hit the ball (`ab`).
* If you naively sort on `desc(ba)`, the people with the best batting averages are clearly lucky, not skilled:

```r
batters %>% 
  arrange(desc(ba))
```

```
## Error in arrange(., desc(ba)): 객체 'batters'를 찾을 수 없습니다
```


#### Other summary functions
* [Book](http://r4ds.had.co.nz/transform.html#summarise-funs)
* Location: `mean(x)`, `median(x)`.
* Spread: `sd(x)`, `IQR(x)`, `mad(x)`.
* Rank: `min(x)`, `quantile(x, 0.25)`, `max(x)`.
* Position: `first(x)`, `nth(x, 2)`, `last(x)`.
* Count: `n(x)`, `sum(!is.na(x))`, `n_distinct(x)`, `count(x)`.
* Counts and proportions of logical values: `sum(x > 10)`, `mean(y == 0)`.

#### Grouped filters
* [Book](http://r4ds.had.co.nz/transform.html#grouped-mutates-and-filters)
* Combination of `group_by()` with `filter()` or `mutate()`.


```r
flights_sml <- 
  select(flights, year:day, ends_with("delay"), distance, air_time)
flights_sml %>% 
  group_by(year, month, day) %>%
  filter(rank(desc(arr_delay)) < 10)
```

```
## # A tibble: 3,306 x 7
## # Groups:   year, month, day [365]
##     year month   day dep_delay arr_delay distance air_time
##    <int> <int> <int>     <dbl>     <dbl>    <dbl>    <dbl>
##  1  2013     1     1       853       851      184       41
##  2  2013     1     1       290       338     1134      213
##  3  2013     1     1       260       263      266       46
##  4  2013     1     1       157       174      213       60
##  5  2013     1     1       216       222      708      121
##  6  2013     1     1       255       250      589      115
##  7  2013     1     1       285       246     1085      146
##  8  2013     1     1       192       191      199       44
##  9  2013     1     1       379       456     1092      222
## 10  2013     1     2       224       207      550       94
## # ... with 3,296 more rows
```


```r
popular_dests <- flights %>% 
  group_by(dest) %>% 
  filter(n() > 10000 )
dim(popular_dests)
```

```
## [1] 131440     19
```


```r
head(popular_dests)
```

```
## # A tibble: 6 x 19
## # Groups:   dest [5]
##    year month   day dep_time sched_dep_time dep_delay arr_time sched_arr_time
##   <int> <int> <int>    <int>          <int>     <dbl>    <int>          <int>
## 1  2013     1     1      542            540         2      923            850
## 2  2013     1     1      554            600        -6      812            837
## 3  2013     1     1      554            558        -4      740            728
## 4  2013     1     1      555            600        -5      913            854
## 5  2013     1     1      557            600        -3      838            846
## 6  2013     1     1      558            600        -2      753            745
## # ... with 11 more variables: arr_delay <dbl>, carrier <chr>, flight <int>,
## #   tailnum <chr>, origin <chr>, dest <chr>, air_time <dbl>, distance <dbl>,
## #   hour <dbl>, minute <dbl>, time_hour <dttm>
```

---

### ETC

#### Missing values: `NA`
* [Book](http://r4ds.had.co.nz/transform.html#missing-values)
* `NA` (not available) represents an unknown value so missing values are “contagious”: almost any operation involving an unknown value will also be unknowns:


```r
x <- c(1,3,5,NA)
mean(x)
```

```
## [1] NA
```


```r
mean(x, na.rm=TRUE)
```

```
## [1] 3
```


```r
NA == NA
```

```
## [1] NA
```


```r
is.na(x)
```

```
## [1] FALSE FALSE FALSE  TRUE
```


```r
df <- tibble(x = c(1, NA, 3))  # tibble is a data frame
filter(df, x > 1)
```

```
## # A tibble: 1 x 1
##       x
##   <dbl>
## 1     3
```


```r
filter(df, is.na(x) | x > 1)
```

```
## # A tibble: 2 x 1
##       x
##   <dbl>
## 1    NA
## 2     3
```

#### Rename a variable: `rename()`
* [Book](https://won-j.github.io/326_212-2018fall/lectures/03-transformation.html#select-columns-with-select)
* Rename a variable:


```r
tmp <- rename(flights, tail_num = tailnum)
head(tmp)
```

```
## # A tibble: 6 x 19
##    year month   day dep_time sched_dep_time dep_delay arr_time sched_arr_time
##   <int> <int> <int>    <int>          <int>     <dbl>    <int>          <int>
## 1  2013     1     1      517            515         2      830            819
## 2  2013     1     1      533            529         4      850            830
## 3  2013     1     1      542            540         2      923            850
## 4  2013     1     1      544            545        -1     1004           1022
## 5  2013     1     1      554            600        -6      812            837
## 6  2013     1     1      554            558        -4      740            728
## # ... with 11 more variables: arr_delay <dbl>, carrier <chr>, flight <int>,
## #   tail_num <chr>, origin <chr>, dest <chr>, air_time <dbl>, distance <dbl>,
## #   hour <dbl>, minute <dbl>, time_hour <dttm>
```

---

### Example
* For each popular destination (flight bigger than 10000), please show the best time of day to avoid (dep) delays as much as possible, when you consider departing between 9 am and 3 pm in the summer (July, August, and September).
* Consider only not cancelled flight.


```r
not_cancelled <- flights %>% 
  filter(!is.na(dep_delay), !is.na(arr_delay)) %>% 
  select(year:day, ends_with("dep_time"), ends_with("dep_delay"), dest) %>%
  mutate(sched_dep_hour = sched_dep_time %/% 100)
head(not_cancelled)
```

```
## # A tibble: 6 x 8
##    year month   day dep_time sched_dep_time dep_delay dest  sched_dep_hour
##   <int> <int> <int>    <int>          <int>     <dbl> <chr>          <dbl>
## 1  2013     1     1      517            515         2 IAH                5
## 2  2013     1     1      533            529         4 IAH                5
## 3  2013     1     1      542            540         2 MIA                5
## 4  2013     1     1      544            545        -1 BQN                5
## 5  2013     1     1      554            600        -6 ATL                6
## 6  2013     1     1      554            558        -4 ORD                5
```


```r
popular_flight <- not_cancelled %>% group_by(dest) %>% 
  filter(n() > 10000 )
```


```r
n_distinct(popular_flight$dest)
```

```
## [1] 9
```


```r
unique(popular_flight$dest)
```

```
## [1] "MIA" "ATL" "ORD" "FLL" "MCO" "LAX" "SFO" "BOS" "CLT"
```


```r
range(not_cancelled$sched_dep_hour)
```

```
## [1]  5 23
```


```r
recommend_times <- popular_flight %>%
  filter(month %in% c(6, 7, 8)) %>%
  filter(sched_dep_hour >= 9 & sched_dep_hour <= 15) %>%
  ungroup() %>%
  group_by(dest, year, month, day) %>% 
  arrange(dep_delay) %>%
  summarise(recommend_time=first(sched_dep_hour), delay=first(dep_delay))
```

```
## `summarise()` has grouped output by 'dest', 'year', 'month'. You can override using the `.groups` argument.
```


```r
recommend_times
```

```
## # A tibble: 827 x 6
## # Groups:   dest, year, month [27]
##    dest   year month   day recommend_time delay
##    <chr> <int> <int> <int>          <dbl> <dbl>
##  1 ATL    2013     6     1             13    -6
##  2 ATL    2013     6     2             13    -8
##  3 ATL    2013     6     3             14    -6
##  4 ATL    2013     6     4             10    -8
##  5 ATL    2013     6     5             12    -8
##  6 ATL    2013     6     6              9    -7
##  7 ATL    2013     6     7             15    -5
##  8 ATL    2013     6     8             15   -10
##  9 ATL    2013     6     9             10    -8
## 10 ATL    2013     6    10              9    -4
## # ... with 817 more rows
```


```r
recommend_times %>% group_by(recommend_time, dest) %>%
  summarize(m = mean(delay), sd = sd(delay),
            low_ci = m - 2*sd,
            high_ci = m + 2*sd,
            n = n()) %>%
  ggplot(aes(recommend_time, m, ymin = low_ci, ymax = high_ci)) +
  geom_pointrange() +
  facet_wrap(~ dest, nrow = 2)
```

```
## `summarise()` has grouped output by 'recommend_time'. You can override using the `.groups` argument.
```

```
## Warning: Removed 1 rows containing missing values (geom_segment).

## Warning: Removed 1 rows containing missing values (geom_segment).

## Warning: Removed 1 rows containing missing values (geom_segment).
```

![](lab_04_transformation_files/figure-html/unnamed-chunk-61-1.png)<!-- -->


```r
recommend_times %>% group_by(dest, recommend_time) %>%
  summarise(mean_delay=mean(delay), count=n()) %>% 
  arrange(mean_delay) %>% 
  summarise(recommend_time=first(recommend_time), mean_delay=first(mean_delay))
```

```
## `summarise()` has grouped output by 'dest'. You can override using the `.groups` argument.
```

```
## # A tibble: 9 x 3
##   dest  recommend_time mean_delay
##   <chr>          <dbl>      <dbl>
## 1 ATL               12      -8.6 
## 2 BOS               11     -11   
## 3 CLT               12      -9.83
## 4 FLL               10     -10.2 
## 5 LAX               14     -11   
## 6 MCO               13     -10.7 
## 7 MIA               11      -8.38
## 8 ORD               13     -10.9 
## 9 SFO               11      -8.33
```
### Exercise
We give you the following `lam_wf` data; This data set is the simplified version of the datasets that consists of the engineering variables from a LAM 9600 Metal Etcher over the course of etching 129 wafers. For more information about the original data set, please see: 

```
B.M. Wise, N.B. Gallagher, S.W. Butler, D.D. White, Jr. and G.G. Barna, \"A Comparison of Principal Components Analysis, Multi-way Principal Components Analysis, Tri-linear Decomposition and Parallel Factor Analysis for Fault Detection in a Semiconductor Etch Process\", J. Chemometrics, in press, 1999
```


```r
library(tidyverse)
lam_wf <- read.csv('lam_data.csv')
lam_wf %>% head
```

```
##      Time Step_Number RF_Btm_Pwr RF_Rfl_Pwr Pressure RF_Tuner TCP_Tuner
## 1 11.9460           4        132          0     1227     9408     20028
## 2 13.0280           4        134          0     1229     9431     20042
## 3 14.0490           4        134          0     1221     9389     20146
## 4 15.1329           4        133          0     1201     9445     20148
## 5 16.1390           4        132          0     1182     9456     20226
## 6 17.1589           4        134          0     1144     9406     19478
##   TCP_Top_Pwr Vat_Valve  batch_id
## 1         360        49 l2901.txm
## 2         350        49 l2901.txm
## 3         344        49 l2901.txm
## 4         352        50 l2901.txm
## 5         346        50 l2901.txm
## 6         350        49 l2901.txm
```


# Mean of pressure per each batch, each step -> step number that for maximum of the mean of the presure per each batch_id 
1. For each 'batch_id' we can calculate the list of the time differences from the nearest two measurement points using `Time` variables. Using the learned data transformation, calculate the mean of the time differences per each `batch_id`. What is the the maximum value from the list of the mean. Show the answer as in the table below.  (Hint: You have to remove `NA` for calculating the mean of the time differences.)


```
## [1] 1.060047
```

2. Using the learned data transformation, calculate the mean of the `Pressure` per each `Step_Number` of each `batch_id`. Find the `Step_Number` that showed maximum mean pressure per each `batch_id`. What is the most common step number that showed maximum mean pressure? Show the answer as `most_important_step` in the table below.


```
## `summarise()` has grouped output by 'batch_id'. You can override using the `.groups` argument.
```

```
## [1] 4
```

-----

**Acknowledgment** All contents in this note is based on the book “R for Data Science”, written by Grolemund & Wickham.
