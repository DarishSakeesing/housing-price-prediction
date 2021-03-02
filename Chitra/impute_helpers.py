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

def impute_with_mode(df,missingcol,groupingcol):
      for idx in df[pd.isnull(df[missingcol])].index:
            modevalue=df.groupby(groupingcol)[missingcol].agg(pd.Series.mode)
            df.loc[idx,missingcol]=modevalue[df.loc[idx,groupingcol]]

def impute_subset_neighbor_with_closest_price(df,subset,missingcol):
    for idx in subset.index:
        price=df.loc[idx,'SalePrice']
        neighbor=find_neighbours(price,df[df['Neighborhood']==df.loc[idx,'Neighborhood']],'SalePrice')
        df.loc[idx,missingcol]=df.loc[neighbor[0],missingcol]
    return df

def impute_subset_with_mode(df,subset,missingcol,groupingcol):
    neighborMode=df.groupby(groupingcol)[missingcol].agg(pd.Series.mode)
    for idx in subset.index:
        modevalue=neighborMode[df.loc[idx,groupingcol]]
        df.loc[idx,missingcol]=modevalue

def impute_with_neighbor_mean(df,missingcol):
    neighborMeans=df.groupby("Neighborhood")[missingcol].agg('mean')
    missingcolIndex=df[pd.isnull(df[missingcol])].index
    for idx in missingcolIndex:
        value=neighborMeans[df.loc[idx,'Neighborhood']]
        df.loc[idx,missingcol]=value