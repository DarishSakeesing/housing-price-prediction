library(VIM)
library(dplyr)
library(mice)
library(caret)
library(ggplot2)
library(Hmisc)
library(car)

ames_house_price=read.csv("./data/Ames_Housing_Price_data.csv")
ames_house_price=ames_house_price %>% select(-1)
missing_na_masvnrarea = sum(is.na(ames_house_price$MasVnrArea))
missing_na_masvnrarea_type = sum(ames_house_price$MasVnrType=="" & is.na(ames_house_price$MasVnrArea))
ames_house_price[ames_house_price$MasVnrType=="" & is.na(ames_house_price$MasVnrArea),] %>% select(MasVnrType, MasVnrArea)
#plot for MaxVnrArea - clear linear relationship - cannot throw out
ggplot(ames_house_price,aes(x=MasVnrArea,y=SalePrice)) + geom_point()+ geom_smooth(method = "lm")
#Recommendation - either impute with Type of None and Area 0
