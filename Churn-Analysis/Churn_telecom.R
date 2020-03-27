library(caTools)
library(ROCR)
library('e1071')
library(car)
library(rpart)
set.seed(133)

data=read.csv("WA_Fn-UseC_-Telco-Customer-Churn.csv")
str(data)

########## Splitting dataset into training and test
ident<-sample.split(data$Churn,SplitRatio=.7)
datatr<-subset(data,ident==TRUE)
datatst<-subset(data,ident==FALSE)
nrow(datatr)
nrow(datatst)
str(datatr)


############## Data exploration ###########################

########### Churn split for female and male customers
df1 = as.data.frame(table(data[, c('gender', 'Churn' )]))
pct_male <- round(df1$Freq[df1$gender=="Male"]/sum(df1$Freq[df1$gender=="Male"])*100)
pct_female <- round(df1$Freq[df1$gender=="Female"]/sum(df1$Freq[df1$gender=="Female"])*100)
lbls_male <- paste(df1$Churn[df1$gender=="Male"], pct_male) # add percents to labels
lbls_male <- paste(lbls_male,"%",sep="") # add % to labels

lbls_female <- paste(df1$Churn[df1$gender=="Female"], pct_female) # add percents to labels
lbls_female <- paste(lbls_female,"%",sep="") # add % to labels

pie(df1$Freq[df1$gender=="Male"], labels = lbls_male, col=rainbow(length(df1$Freq[df1$gender=="Male"])), main = "Churn split for male customers")
pie(df1$Freq[df1$gender=="Female"], labels = lbls_female, col=rainbow(length(df1$Freq[df1$gender=="Female"])), main = "Churn split for female customers")


########### Churn split for senior and non-senior customers

df1 = as.data.frame(table(data[, c('SeniorCitizen', 'Churn' )]))
pct_senior <- round(df1$Freq[df1$SeniorCitizen==1]/sum(df1$Freq[df1$SeniorCitizen==1])*100)
pct_nonsenior <- round(df1$Freq[df1$SeniorCitizen==0]/sum(df1$Freq[df1$SeniorCitizen==0])*100)
lbls_senior <- paste(df1$Churn[df1$SeniorCitizen==1], pct_senior) # add percents to labels
lbls_senior <- paste(lbls_senior,"%",sep="") # add % to labels

lbls_nonsenior <- paste(df1$Churn[df1$SeniorCitizen==0], pct_nonsenior) # add percents to labels
lbls_nonsenior <- paste(lbls_nonsenior,"%",sep="") # add % to labels

pie(df1$Freq[df1$SeniorCitizen==1], labels = lbls_senior, col


########### Churn split for dependent and non-dependent customers

df1 = as.data.frame(table(data[, c('Dependents', 'Churn' )]))
pct_dpt <- round(df1$Freq[df1$Dependents=="Yes"]/sum(df1$Freq[df1$Dependents=="Yes"])*100)
pct_ndpt <- round(df1$Freq[df1$Dependents=="No"]/sum(df1$Freq[df1$Dependents=="No"])*100)
lbls_dpt <- paste(df1$Churn[df1$Dependents=="Yes"], pct_dpt) # add percents to labels
lbls_dpt <- paste(lbls_dpt,"%",sep="") # add % to labels

lbls_ndpt <- paste(df1$Churn[df1$Dependents=="No"], pct_ndpt) # add percents to labels
lbls_ndpt <- paste(lbls_ndpt,"%",sep="") # add % to labels

pie(df1$Freq[df1$Dependents=="Yes"], labels = lbls_dpt, col=rainbow(length(df1$Freq[df1$Dependents=="Yes"])), main = "Churn split for dependent customers")
pie(df1$Freq[df1$Dependents=="No"], labels = lbls_ndpt, col=rainbow(length(df1$Freq[df1$Dependents=="No"])), main = "Churn split for non-dependent customers")


########### Churn split for phoneservice and non-phoneservice customers
df1 = as.data.frame(table(data[, c('PhoneService', 'Churn' )]))
pct_ps <- round(df1$Freq[df1$PhoneService=="Yes"]/sum(df1$Freq[df1$PhoneService=="Yes"])*100)
pct_nops <- round(df1$Freq[df1$PhoneService=="No"]/sum(df1$Freq[df1$PhoneService=="No"])*100)
lbls_ps <- paste(df1$Churn[df1$PhoneService=="Yes"], pct_ps) # add percents to labels
lbls_ps <- paste(lbls_ps,"%",sep="") # add % to labels

lbls_nops <- paste(df1$Churn[df1$PhoneService=="No"], pct_nops) # add percents to labels
lbls_nops <- paste(lbls_nops,"%",sep="") # add % to labels

pie(df1$Freq[df1$PhoneService=="Yes"], labels = lbls_ps, col=rainbow(length(df1$Freq[df1$PhoneService=="Yes"])), main = "Churn split for PhoneService customers")
pie(df1$Freq[df1$PhoneService=="No"], labels = lbls_nops, col=rainbow(length(df1$Freq[df1$PhoneService=="No"])), main = "Churn split for non-PhoneService customers")



########### Logistic Regression Model ######################
mod_LR <- glm(Churn~., data=datatr, family="binomial")
summary(mod_LR)
vif(mod_LR)

pr_LR<-predict(mod_LR, datatst, type="response")
datal_p=data.frame(datatst,pr_LR)
cls<-ifelse(pr_LR>=.5,1,0)
tb_LR<-table(datatst$Churn,cls)
accuracy_LR<-sum(diag(tb_LR))/sum(tb_LR)  ##0.86
accuracy_LR
pred_L=prediction(cls,datal_p$Churn )
rocc_L=performance(pred_L,"tpr","fpr")
plot(rocc_L)
auc_L=performance(pred_L,"auc")
auc_L   ##0.6


########### Decision Tree Model
mod_CART <- rpart(Churn~., data=datatr, method="class")
summary(mod_CART)

pr_CART=predict(mod_CART, datatst, type="class")
pr_CART
datal_c=data.frame(datatst,pr_CART)
tb_C=table(datal_c$Churn, pr_CART)
tb_C
accuracy_C=sum(diag(tb_C))/sum(tb_C)
accuracy_C  #CART: 0.75
cl_c=predict(mod_CART, datatst, type="prob")
cl_c=cl_c[,2]
pred_C=prediction(cl_c,datatst$Churn )
rocc_C=performance(pred_C,"tpr","fpr")
plot(rocc_C)
auc_C=performance(pred_C,"auc")
auc_C   ##0.57


########### Bayesian model
mod_NB=naiveBayes(Churn~., data=datatr)
summary(mod_NB)

pr_NB=predict(mod_NB, datatst, type="class")
datal_n=data.frame(datatst,pr_NB)
tb_N=table(datatst$Churn, pr_NB)
tb_N
accuracy_N=sum(diag(tb_N))/sum(tb_N)
accuracy_N  #NB:72.5
cl_n=predict(mod_NB, datatst, type="raw")
cl_n=cl_n[,2]
pred_n=prediction(cl_n,datal_n$Churn )
rocc_n=performance(pred_n,"tpr","fpr")
plot(rocc_n)
auc_n=performance(pred_n,"auc")
auc_n   ###81.8
