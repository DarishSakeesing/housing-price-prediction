import pandas as pd



import numpy as np



raw_data = pd.read_csv('data/Ames_Housing_Price_Data.csv', index_col=0)


def print_missing_stats(s):
    print('Missing Value:')
    print(s.isna().value_counts().to_string()) 
    percentage_missing = (s.isna().value_counts().loc[1] /(s.isna().value_counts().loc[0] + s.isna().value_counts().loc[1]) * 100)
    print('Percentage Missing: ', percentage_missing, '%\n')


import sys

original_stdout = sys.stdout # Save a reference to the original standard output

with open('descriptive_stats.txt', 'w') as f:
    sys.stdout = f # Change the standard output to the file we created.
    

    continuous_data = ['LotFrontage', 'LotArea', 'YearBuilt', 'YearRemodAdd','MasVnrArea', 'BsmtFinSF1', 'BsmtFinSF2', 'BsmtUnfSF', 'TotalBsmtSF', '1stFlrSF', '2ndFlrSF', 'LowQualFinSF', 'GrLivArea', 'BsmtFullBath', 'BsmtFullBath', 'FullBath', 'HalfBath', 'BedroomAbvGr', 'KitchenAbvGr', 'TotRmsAbvGrd', 'Fireplaces', 'GarageYrBlt', 'GarageCars', 'GarageArea', 'WoodDeckSF', 'OpenPorchSF', 'EnclosedPorch', '3SsnPorch', 'ScreenPorch', 'PoolArea', 'MiscVal' ]
    discrete_data = ['MSSubClass', 'MSZoning', 'Street', 'Alley', 'LotShape', 'LandContour', 'Utilities', 'LotConfig', 'LandSlope', 'Neighborhood', 'Condition1', 'Condition2', 'BldgType', 'HouseStyle', 'OverallQual', 'OverallCond', 'RoofStyle', 'RoofMatl', 'Exterior1st', 'Exterior2nd', 'MasVnrType', 'ExterQual', 'ExterCond', 'Foundation', 'BsmtQual', 'BsmtCond', 'BsmtExposure', 'BsmtFinType1', 'BsmtFinType2', 'Heating', 'HeatingQC', 'CentralAir', 'Electrical', 'KitchenQual', 'Functional',  'FireplaceQu', 'GarageType', 'GarageFinish', 'GarageQual', 'GarageCond', 'PavedDrive', 'PoolQC', 'Fence', 'MiscFeature', 'SaleType', 'SaleCondition']

    type_of_data = [continuous_data, discrete_data]

    for i in range(2):
        if i == 0:
            for data in type_of_data[i]:
                s = raw_data[data]
                print('==========  ', data, ' ==========\n')
                if s.isna().values.any() or None in s:
                    print_missing_stats(s)
                else:
                    print('No missing values\n')

                print(s.describe().to_string(), '\n')
        
        else:
            for data in type_of_data[i]:
                s = raw_data[data]
                print('==========  ', data, ' ==========\n')
                if s.isna().values.any() or None in s:
                    print_missing_stats(s)
                else:
                    print('No missing values\n')
                
                print(s.value_counts().to_string(), '\n')


    sys.stdout = original_stdout # Reset the standard output to its original value

    
