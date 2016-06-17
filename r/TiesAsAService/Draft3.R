# TaaS 
# MRR Calculator 

# Variables 
# --------------------- 

# Input
MRR <- 30 #Monthly Revenue of $30 
AvgDuration <- mean(1:2) #Average Contract Duration between 1 and 2 months 
Months <- 12 #Months of simulation 
Customers <- 60 #Initial influx of Customers (Month 1)
MRR <- 30 #Monthly Revenue of $30 
AvgDuration <- mean(1:2) #Average Contract Duration between 1 and 2 months 
Margin = 0.45 #Average sale margin

# Churn and Growth

Ch <- rnorm(1, mean = 0.10, sd = 0.05) # Expected churn rate mean and deviation (%)
G <- rnorm(1, mean = 0.05, sd = 0.05) # Expected growth rate mean and deviation (%)


# Generator
# --------------------- 

# Customers

Churned_Customers <- 0
New_Customers <- 0
Net_Customers <- 0

for (i in 1:Months) {
  Churned_Customers[i] <- Customers[i]*Ch 
  New_Customers[i] <- Customers[i]*G
  Net_Customers[i] <- -Churned_Customers[i] + New_Customers[i]
  Customers[i+1] <- Customers[i] + Net_Customers[i]
}

# MRR

Total_MRR <- MRR * Customers
Churned_MRR <- 0
New_MRR <- 0
Net_MRR <- 0

for (i in 1:Months) {
  Churned_MRR[i] <- MRR[i]*Ch
  New_MRR[i] <- MRR[i]*G
  Net_MRR[i] <- -Churned_MRR[i] + New_MRR[i]
  MRR[i + 1] <- MRR[i] + Net_MRR[i]
  Total_MRR[i+1] = MRR[i+1] * Customers[i+1]
}

# ARPA

ARPA <- (MRR[1] * AvgDuration * Customers[1])/Customers[1]

for (i in 1:(Months)) {
  ARPA[i+1] <- (MRR[i+1]*AvgDuration*Customers[i+1])/Customers[i+1]
}


# Storage
MRR_Data <- data.frame(1:12, Customers[1:12], Churned_Customers[1:12], New_Customers[1:12], Net_Customers[1:12], MRR[1:12], Churned_MRR[1:12], New_MRR[1:12], Net_MRR[1:12], Total_MRR[1:12], ARPA[1:12], 
                       row.names = c("January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"))
names(MRR_Data) <- c("Months","Customers", "Churned Customers", "New Customers", "Net Customers", "MRR", "Churned MRR", "New MRR", "Net MRR", "Total MRR", "ARPA")
                       
write.csv(MRR_Data, file="MRR_Data_Test.csv")

# LTV and CAC
# ---------------------------------
 
LTV = (ARPA[1:12] * Margin)/Ch
CAC = 6000 #Expenses/New Customers, need lead generator
Months_Recover_CAC = CAC / mean(MRR)
LTV_CAC = LTV/CAC

# Plots 
# --------------------------------


# Customer Graph (All cases)
# MRR Graph (All cases)
# ARPA graph (All Cases)
# ARPA vs Churn rate and growth rate graph ARPA matrix vs g vs c