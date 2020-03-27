Summary –

Customer churn or customer attrition is the loss of customers by the virtue of them no longer utilizing the product or the said services. Companies do a churn analysis/ retention analysis to find out their most vulnerable customers and focus their churn/winback marketing on this subset of customers most likely to churn. This project looks at the churn analysis mechanism by analyzing the customer dataset from a telecom service provider.


Data Source – 

The dataset consists of 7043 rows (customers) and 21 columns (features). Churn is the target column for prediction.
Each row represents a customer, each column contains customer’s attributes described on the column Metadata.
The data set includes information about:
•	Customers who left within the last month – the column is called Churn
•	Services that each customer has signed up for – phone, multiple lines, internet, online security, online backup, device protection, tech support, and streaming TV and movies
•	Customer account information – how long they’ve been a customer, contract, payment method, paperless billing, monthly charges, and total charges
•	Demographic info about customers – gender, age range, and if they have partners and dependents


Data Exploration - 

As part of data exploration, multiple analysis has been done – for eg churn split for female vs. male customers, churn split for senior vs. non-senior customers etc. These analyses help us to identify different user cohorts and how the trend is for each of these cohorts.

Model Building – 

1.	The dataset is tested for multi-collinearity and then logistic regression applied. On applying logistic regression to the dataset, the accuracy is 80%  and area under curve is 60%
2.	Post that, decision tree algorithm gives accuracy of 75% and area under curve is 57%
3.	The Bayesian classification algorithm gives accuracy of 72.5% and area under curve is 81.8%
4.	Since the area under curve (auc) is greatest for Bayesian classification algorithm amongst the three algorithms, that is the best model to predict churn in this case.
5.	The auc is plotted for all the three algorithms.


Conclusion – 

The analysis help in predicting the user churn and this can be further utilized by the marketing teams to customize specific marketing efforts towards these probable-churn users.
