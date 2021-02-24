library(dplyr)
library(ggplot2)
library(GGally)
library(mice)
library(car) 
library(forcats)

data = read.csv('./data/Ames_Housing_Price_Data.csv')


mice::md.pattern(data)


colnames(data)[colSums(is.na.data.frame(data)) > 0] #Which columns have Na

sum(!complete.cases(data))



GarageVars = data[,grepl("Garage", colnames(data))] #extract Garage variables

GarageVars = cbind(GarageVars, Price = data$SalePrice) #add price
GarageVars = GarageVars %>%
  mutate(PriceByArea = data$SalePrice/data$GrLivArea) #add PriceByArea
GarageVars = cbind(GarageVars, X = data$X) #added X as ID to latter merge this dataset

#Replace empty fields with None so the rows will be taken into account in the regression models
GarageVars[GarageVars == '']= "None"


#Replace Na with mean YrBlt, its the only var with NA. We can use random or kNN if prefered.

GarageVars$GarageYrBlt[is.na(GarageVars$GarageYrBlt)]= round(mean(GarageVars$GarageYrBlt, na.rm = TRUE ), digits = 0)

GarageVars[is.na(GarageVars$GarageCars),]#for some reason this row has NA instead of 0 in Cars and Area
GarageVars$GarageCars[434] = 0 
GarageVars$GarageArea[434] = 0


#Convert categorical to factors

GarageVars$GarageType = as.factor(GarageVars$GarageType)
GarageVars$GarageFinish = as.factor(GarageVars$GarageFinish)
GarageVars$GarageQual = as.factor(GarageVars$GarageQual)
GarageVars$GarageCond= as.factor(GarageVars$GarageCond)


#Visualizations of PriceByArea and GarageType. How big of an impact does having a Garage has?

plot = GarageVars %>%
  mutate(GarageType = fct_reorder(GarageType, desc(PriceByArea), .fun='median')) %>%
  ggplot() +
  geom_boxplot(aes(GarageType, PriceByArea, fill = GarageType))

plot

# analysis of variance
res.aov <- aov(PriceByArea ~ GarageType, data = GarageVars)
# Summary of the analysis. ***
summary(res.aov)

#Visualizations of GarageArea vs GarageCars

plot2 = GarageVars %>%
  ggplot() +
  geom_boxplot(aes(GarageArea, x = as.factor(GarageCars), fill = GarageCars))

plot2 # highly correlated



ggpairs(GarageVars) #look at scatterplots and correlations. Correlation btw GarageCars and Garage Area is 0.89


GarageModel = glm(PriceByArea ~.-Price,
                  data = GarageVars)

summary(GarageModel)

vif(GarageModel)

avPlots(GarageModel)





#normalize the data

library(caret)

preproc1 <- preProcess(GarageVars[,c(4,5,2,9)], method=c("center", "scale"))

norm1 <- predict(preproc1, GarageVars[,c(4,5,2,9)])

summary(norm1)

GarageVarsNorm = cbind(GarageVars[,c(1,3,6,7,10)], norm1)



#try lasso to reduce dimensions

library(glmnet)

x = model.matrix(PriceByArea~ . -X, GarageVarsNorm)[, -1] #Dropping the intercept column.
y = GarageVarsNorm$PriceByArea

lasso.models = glmnet(x, y, alpha = 1)

dim(coef(lasso.models)) #23 different coefficients, estimated 95 times --
#once each per lambda value.
coef(lasso.models)

plot(lasso.models, xvar = "lambda", label = TRUE, main = "Lasso Regression")

set.seed(0)
train = sample(1:nrow(x), 7*nrow(x)/10)
test = (-train)
y.test = y[test]

length(train)/nrow(x)
length(y.test)/nrow(x)

cv.lasso.out = cv.glmnet(x[train, ], y[train], alpha = 1, nfolds = 10)
plot(cv.lasso.out, main = "Lasso Regression\n")
bestlambda.lasso = cv.lasso.out$lambda.min
bestlambda.lasso
log(bestlambda.lasso)

lasso.models.train = glmnet(x[train, ], y[train], alpha = 1)
lasso.bestlambdatrain = predict(lasso.models.train, s = bestlambda.lasso, newx = x[test, ])
mean((lasso.bestlambdatrain - y.test)^2)

lasso.models$lambda[42]
coef(lasso.models)[, 42] #Most estimates not close to 0.
sum(abs(coef(lasso.models)[-1, 42])) #L1 norm is 228.1008.


#based on the lasso model I'll make a model that does not include the Garage cars nor the Garage Condition

GarageModel.red = glm(PriceByArea ~.-GarageCars -GarageCond - X,
                      data = GarageVarsNorm)
summary(GarageModel.red)

#none of the Qual were significant, so reduce the features further

GarageModel.red2 = glm(PriceByArea ~.-GarageCars -GarageCond - GarageQual -X,
                      data = GarageVarsNorm)
summary(GarageModel.red2)
vif(GarageModel.red2)

avPlots(GarageModel.red2)

#Saturated model
GarageModel.saturated = glm(PriceByArea ~.,
                      data = GarageVarsNorm)


BIC(GarageModel.saturated,    #Model with all variables.
    GarageModel.red,        
    GarageModel.red2)
AIC(GarageModel.saturated,    #Model with all variables.
    GarageModel.red,        
    GarageModel.red2)


anova(GarageModel.red2, GarageModel.saturated, test = "Chisq") #no significant difference

#Best model GarageModel.red2 does not include GarageCars, GarageCond, nor GarageQual. 
#With normalized the numerical data and using priceByArea as the dependent variable



