import pandas as pd

def find_neighbours(value, df, colname):
        lowerneighbour_ind = df[df[colname] < value][colname].idxmax()
        upperneighbour_ind = df[df[colname] > value][colname].idxmin()
        return [lowerneighbour_ind, upperneighbour_ind] 
    
def impute_with_closest_price(df,missingcol):
    for idx in df[pd.isnull(df[missingcol])].index:
        price=df.loc[idx,'SalePrice']
        neighbor=find_neighbours(price,df,'SalePrice')
        df.loc[idx,missingcol]=df.loc[neighbor[0],missingcol]
    return df

def impute_neighbor_with_closest_price(df,missingcol):
    for idx in df[pd.isnull(df[missingcol])].index:
        price=df.loc[idx,'SalePrice']
        neighbor=find_neighbours(price,df[df['Neighborhood']==df.loc[idx,'Neighborhood']],'SalePrice')
        df.loc[idx,missingcol]=df.loc[neighbor[0],missingcol]
    return df

def impute_with_closest_year(df,missingcol):
    for idx in df[pd.isnull(df[missingcol])].index:
        price=df.loc[idx,'YearBuilt']
        neighbor=find_neighbours(price,df,'YearBuilt')
        df.loc[idx,missingcol]=df.loc[neighbor[0],missingcol]
    return df