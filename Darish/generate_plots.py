import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.backends.backend_pdf

pd.set_option('display.max_columns', 100)

raw_data = pd.read_csv('data/Ames_Housing_Price_Data.csv', index_col=0)

pdf = matplotlib.backends.backend_pdf.PdfPages("plots/plots.pdf")

continuous_data = raw_data[['SalePrice','LotFrontage', 'LotArea', 'YearBuilt', 'YearRemodAdd','MasVnrArea', 'BsmtFinSF1', 'BsmtFinSF2', 'BsmtUnfSF', 'TotalBsmtSF', '1stFlrSF', '2ndFlrSF', 'LowQualFinSF', 'GrLivArea', 'BsmtFullBath', 'FullBath', 'HalfBath', 'BedroomAbvGr', 'KitchenAbvGr', 'TotRmsAbvGrd', 'Fireplaces', 'GarageYrBlt', 'GarageCars', 'GarageArea', 'WoodDeckSF', 'OpenPorchSF', 'EnclosedPorch', '3SsnPorch', 'ScreenPorch', 'PoolArea', 'MiscVal' ]]

fig_list = []
for feature in continuous_data:
    figure = data_no_id.loc[:,[feature, 'SalePrice']].plot(kind='scatter', x=feature,y='SalePrice').figure
    figure.set_size_inches([8, 8])
    fig_list.append(figure)

for fig in fig_list:
    pdf.savefig(fig)

pdf.close()

