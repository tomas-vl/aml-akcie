import matplotlib
matplotlib.use('TkAgg')
import talib
import pandas as pd
import matplotlib.pyplot as plt
import statsmodels.api as sm
import seaborn as sns
import numpy as np

alldata_df = pd.read_csv('ORCL_all.csv')


# Create 1-day % changes of Adj_Close for the current day, and 5 days in the future
alldata_df['1d_future_close'] = alldata_df['adjusted_close'].shift(-1)
alldata_df['1d_close_future_pct'] = alldata_df['1d_future_close'].pct_change(1, fill_method=None)
alldata_df['1d_close_pct'] = alldata_df['adjusted_close'].pct_change(1, fill_method=None)


feature_names = ['1d_close_pct']  # a list of the feature names for later

# Create moving averages and rsi for timeperiods of 14, 30, 50, and 200
for n in [14, 30, 50, 200]:
    # Create the moving average indicator and divide by Adj_Close
    alldata_df['ma' + str(n)] = talib.SMA(alldata_df['adjusted_close'].values,
                                      timeperiod=n) / alldata_df['adjusted_close']
    # Create the RSI indicator
    alldata_df['rsi' + str(n)] = talib.RSI(alldata_df['adjusted_close'].values, timeperiod=n)

    # Add rsi and moving average to the feature name list
    feature_names = feature_names + ['ma' + str(n), 'rsi' + str(n)]
print(feature_names)

# Drop all na values
alldata_df = alldata_df.dropna()

# Create features and targets
# use feature_names for features; '5d_close_future_pct' for targets
features = alldata_df[feature_names]
targets = alldata_df['1d_close_future_pct']

# Create DataFrame from target column and feature columns
feature_and_target_cols = ['1d_close_future_pct'] + feature_names
feat_targ_df = alldata_df[feature_and_target_cols]

# Calculate correlation matrix
corr = feat_targ_df.corr()
print(corr)

# Add a constant to the features
linear_features = sm.add_constant(features)

# Create a size for the training set that is 85% of the total number of samples
train_size = int(0.85 * targets.shape[0])
train_features = linear_features[:train_size]
train_targets = targets[:train_size]
test_features = linear_features[train_size:]
test_targets = targets[train_size:]
print(linear_features.shape, train_features.shape, test_features.shape)

# Create the linear model and complete the least squares fit
model = sm.OLS(train_targets, train_features)
results = model.fit()  # fit the model
print(results.summary())

# examine pvalues
# Features with p <= 0.05 are typically considered significantly different from 0
print(results.pvalues)

# Make predictions from our model for train and test sets
train_predictions = results.predict(train_features)
test_predictions = results.predict(test_features)

# Scatter the predictions vs the targets with 20% opacity
plt.scatter(train_predictions, train_targets, alpha=0.2, color='b', label='train')
plt.scatter(test_predictions, test_targets, alpha=0.2, color='r', label='test')

# Plot the perfect prediction line
xmin, xmax = plt.xlim()
plt.plot(np.arange(xmin, xmax, 0.01), np.arange(xmin, xmax, 0.01), c='k')

# Set the axis labels and show the plot
plt.xlabel('predictions')
plt.ylabel('actual')
plt.legend()  # show the legend
plt.show()

