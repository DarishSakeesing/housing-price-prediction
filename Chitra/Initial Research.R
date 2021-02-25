#Missingness
library(VIM)
library(dplyr)
library(mice)
library(caret)
library(ggplot2)
library(Hmisc)
library(car)

ames_house_price=read.csv("./data/Ames_Housing_Price_data.csv")
ames_house_price=ames_house_price %>% select(-1)
n=nrow(ames_house_price)

target <- 'SalePrice'
predictors <- setdiff(colnames(ames_house_price), target)

summary(ames_house_price)
cols_with_na=colSums(is.na(ames_house_price))
cols_with_na=cols_with_na[cols_with_na>0]
VIM::aggr(ames_house_price, numbers = TRUE, prop = c(FALSE, FALSE), sortVars=TRUE)
mice::md.pattern(ames_house_price)

# impute median for all missing values using HMisc
pre = caret::preProcess(ames_house_price, method = "medianImpute") 
ames_modified_caret_median = predict(pre, ames_house_price)

#impute mean for only column  using HMisc
imputed.BsmtFinSF1 = impute(ames_house_price$BsmtFinSF1, mean)
ames_modified_HMisc_mean = data.frame(ames_house_price) %>% mutate(BsmtFinSF1 = imputed.BsmtFinSF1)
VIM::aggr(ames_modified_HMisc_mean, numbers = TRUE, prop = c(FALSE, FALSE), sortVars=TRUE)
imputed.BsmtFinSF1[is.imputed(imputed.BsmtFinSF1)]

#impute random value for only column
set.seed(0)
imputed.GarageArea = impute(ames_house_price$GarageArea, "random") 
ames_modified_HMisc_random = data.frame(ames_house_price) %>% mutate(GarageArea = imputed.GarageArea)
VIM::aggr(ames_modified_HMisc_random, numbers = TRUE, prop = c(FALSE, FALSE), sortVars=TRUE)
imputed.GarageArea[is.imputed(imputed.GarageArea)]

#impute 1NN using VIM
imputed.1nn = kNN(ames_house_price,variable=c("TotalBsmtSF"), k=1)
VIM::aggr(imputed.1nn, numbers = TRUE, prop = c(FALSE, FALSE), sortVars=TRUE)

complete = ames_house_price[complete.cases(ames_house_price),]
missing = ames_house_price[!complete.cases(ames_house_price),]


cor(ames_house_price[sapply(ames_house_price,is.numeric)])

#Single Linear Regression with GrLivArea
model = lm(log(SalePrice) ~ log(GrLivArea), data = ames_house_price)
summary(model)
model2 = lm(SalePrice ~ GrLivArea-1, data = ames_house_price) # remove constant
summary(model2)
confint(model2)
hist(ames_house_price$GrLivArea)
plot(ames_house_price$GrLivArea,ames_house_price$SalePrice)
model3 = lm(SalePrice ~ GrLivArea^2, data = ames_house_price) # remove constant
summary(model3)
plot(model$fitted, model$residuals,
     xlab = "Fitted Values", ylab = "Residual Values",
     main = "Residual Plot for Ames Dataset")
abline(h = 0, lty = 2)
qqnorm(model$residuals)
qqline(model$residuals)
plot(model3) 
influencePlot(model2) 
newdata=data.frame(GrLivArea=c(1001,1246,889))
predict(model,newdata,interval="confidence")
model$fitted.values # y values 
bc = boxCox(model2)
lambda = bc$x[which(bc$y == max(bc$y))]
SalePrice.bc = (ames_house_price$SalePrice^lambda - 1)/lambda
hist(SalePrice.bc, xlab = "Sale Price box cox", main = "Histogram of Sale Price")
model.bc = lm(SalePrice.bc ~ ames_house_price$GrLivArea)
summary(model.bc)
plot(model.bc)
plot(log(ames_house_price$GrLivArea),log(ames_house_price$SalePrice))
model.saturated = lm(log(SalePrice) ~ ., data=ames_house_price)
summary(model.saturated)
plot(model.saturated)
influencePlot(model.saturated)
vif(model.saturated)
avPlots(model.saturated)
AIC(model,    
    model2,      
    model3)
BIC(model,   
    model2,       
    model3)
