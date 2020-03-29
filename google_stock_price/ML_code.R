library(tsfknn)
library(rpart)
library(forecast)
set.seed(133)

df = read.csv("Google_Stock_Price.csv")
str(df)
head(df)

########## Convert data into time-series format
tr.ts = ts(rev(df[,5]), start=c(2012,1), frequency = 12)

df=data.frame(closing=tr.ts, log_close=log(tr.ts))

plot(df$closing, main="Google Stock Price Trend", lwd=2, ylab="Closing price")

######### Decompose timeseries to remove seasonality ########
df.stl = stl(df$closing, s.window ="periodic")
plot(df.stl, main="Google stock prices")


############ Forecast stock price using ARIMA 
df.f = forecast(df.stl,method = "arima", h=24, level=95)
plot(df.f, ylab="Stock price", xlab="year", sub="forecast of stock prices")


############ Forecast stock price using k-nearest neighbours
predknn <- knn_forecasting(df$closing, h=24, lags = 1:40, k = 24, msas = "MIMO")
ro <- rolling_origin(predknn)
print(ro$global_accu)


############ Forecast stock price using basic neural networks
alpha <- 1.5^(-10)    #### hidden layer creation
hn <- length(df$log_close)/(alpha*(length(df$log_close)+10))
head(hn)

lambda <- BoxCox.lambda(df$log_close)   ### fitting nnetar
dnn_pred <- nnetar(df$log_close, size= hn, lambda = lambda, MaxNWts = 1700)

dnn_forecast <- forecast(dnn_pred, h=24, PI = TRUE)
plot(dnn_forecast)
