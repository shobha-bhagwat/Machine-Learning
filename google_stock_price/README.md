Summary – 

One of the highly used application of Machine Learning techniques is in the forecasting of stock prices. It is a very art and hence many traders and analysts are keenly interested in finding new and improved methods to accurately predict stock prices or stock movements. In this project the Goggle stock prices is forecasted using multiple methods and the results are compared.


Data Analysis - 

The dataset consists of 6 fields and 1278 observations. 
The fields are – 

•	Date – The recorded business date
•	Open – The opening price of the stock for that business date
•	High – The highest price of the stock for that day
•	Low – The lowest price of the stock for that day
•	Close – The closing price of the stock for that day
•	Volume – The number of stocks of Google traded that day



Data Preparation - 

The data is available in a discrete value format. We convert it into a timeseries format which is more conducive for the forecasting. The “Close” field is used for forecasting.  The timeseries is plotted to see the historical trends for the stock price. To see the effects of seasonality, general trend and remainder components we decompose the timeseries using stl() function. The seasonal component is removed and thus only general trend remains for analysis. 

Model Building - 

The stock price is predicted using ARIMA, k-nearest neighbors and basic neural network models.

With the forecast method we predict the stock prices for next 2 years with 95% confidence interval.

In this project we use KNN model for forecasting. For predicting new values, KNN uses “feature similarity” i.e. it assigns new point to a value based on how closely it resembles the points on the training dataset. We use the rolling_origin() function to assess the model accuracy. 

We use the nnetar function, which is the single layer neural network function from the forecast package to create simple neural network. A single hidden layer neural network model is fitted to the timeseries data. 
