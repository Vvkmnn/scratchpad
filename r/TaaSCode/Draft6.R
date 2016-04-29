# TaaS 
# MRR Calculator 

# Variables 
# --------------------- 

# Input
MRR <- 30 #Monthly Revenue of $30 
AvgDuration <- mean(1:2) #Average Contract Duration between 1 and 2 months 
Months <- 12 #Months of simulation 
Customers <- 60 #Initial influx of Customers (Month 1)
Margin <- 0.45 #Average sale margin
R <- 0.10 # Discount/Interest rate
  
# Churn and Growth

Churn <- rnorm(1:Months, mean = 0.10, sd = 0.05) # Expected churn rate mean and deviation (%)
Growth <- abs(rnorm(1:Months, mean = 0.05, sd = 0.05)) # Expected growth rate mean and deviation (%)

MRR_Churn <- rnorm(1:Months, mean = 0.10, sd = 0.05) # Expected churn rate mean and deviation (%)
MRR_Expansion <- abs(rnorm(1:Months, mean = 0.05, sd = 0.05)) 

# Generator
# --------------------- 

# Customers

Churned_Customers <- 0
New_Customers <- 0
Net_Customers <- 0

for (i in 1:Months) {
  Churned_Customers[i] <- Customers[i]*Churn[i]
  New_Customers[i] <- Customers[i]*Growth[i]
  Net_Customers[i] <- -Churned_Customers[i] + New_Customers[i]
  Customers[i+1] <- Customers[i] + Net_Customers[i]
}

# MRR

Total_MRR <- MRR * Customers
Churned_MRR <- 0
Expanded_MRR <- 0
Net_MRR <- 0

for (i in 1:Months) {
  Churned_MRR[i] <- MRR[i]*MRR_Churn[i]
  Expanded_MRR[i] <- MRR[i]*MRR_Expansion[i]
  Net_MRR[i] <- -Churned_MRR[i] + Expanded_MRR[i]
  MRR[i + 1] <- MRR[i] + Net_MRR[i]
  Total_MRR[i] = MRR[i] * Customers[i]
}

# ARPA

ARPA <- (MRR[1] * AvgDuration * Customers[1])/Customers[1]

for (i in 1:Months) {
  ARPA[i+1] <- (MRR[i+1]*AvgDuration*Customers[i+1])/Customers[i+1]
}

# LTV and CAC

# LTV
Cumulative_Churn <- cumsum(Churn[1:Months])

LTV <- (ARPA[1] * Margin * (1-Cumulative_Churn[1]) * Months)/((1+R/Months)^(Months))

for (i in 1:Months) {
  LTV <- (ARPA[i] * Margin * (1-Cumulative_Churn[i]) * Months)/((1+R/Months)^(Months))
}

LTV <- (ARPA[1-12] * Margin * Months[1-12] * (1-Churn[1-12]))/((1+R)^(Months[1-12]))
CAC[1:12] <- 1000/(mean(MRR) * Margin) #$1000 monthly ad budget 
Recover_CAC <- CAC[1:12]/mean(MRR)
LTV_CAC[1:12] <- LTV[1:12]/CAC[1:12]

#Cohort Tables

#Customers
Customer_Matrix <- matrix(0:0,nrow=Months,ncol=Months)
Customer_Matrix[1,1] <- Customers[1]

for (i in 1:(Months-1)) {
  Customer_Matrix[i + 1, i + 1] <- New_Customers[i+1]
  Customer_Matrix[,i+1] <- Customer_Matrix[,i] * (1 - Churn[i])
  Customer_Matrix[i + 1, i + 1] <- New_Customers[i+1]
}

print(round(Customer_Matrix))


#MRR
MRR_Matrix <- matrix(0:0,nrow=Months,ncol=Months)

for (i in 1:(Months-1)) {
  MRR_Matrix[,i] <- Customer_Matrix[,i] * MRR[i]
}


# Storage
MRR_Data <- data.frame(1:12, Customers[1:12], Churned_Customers[1:12], New_Customers[1:12], Net_Customers[1:12], MRR[1:12], Churned_MRR[1:12], New_MRR[1:12], Net_MRR[1:12], Total_MRR[1:12], ARPA[1:12], LTV[1:12], CAC[1:12], Recover_CAC[1:12], LTV_CAC[1:12],  
                       row.names = c("January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"))
names(MRR_Data) <- c("Months","Customers", "Churned Customers", "New Customers", "Net Customers", "MRR", "Churned MRR", "New MRR", "Net MRR", "Total MRR", "ARPA", "LTV", "CAC", "Recover CAC" , "LTV/CAC")

write.csv(MRR_Data, file="MRR_Data_Test.csv")

# References
# mean(MRR_Data$LTV)

# Plots 
# --------------------------------


# Customer Graph (All cases)
# MRR Graph (All cases)
# ARPA graph (All Cases)
# ARPA vs Churn rate and growth rate graph ARPA matrix vs g vs c