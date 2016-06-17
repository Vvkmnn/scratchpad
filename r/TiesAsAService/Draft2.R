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

# Churn and Growth

Ch <- c(0.03,0.01) # Expected churn rate (3%) and deviation (1%)
names(Ch) <- c("mean","sd")
G <- c(0.05,0.1) # Expected growth rate and (5%) deviation (10%)
names(G) <- c("mean","sd")

# Growth and Churn Vectors

Churn <- c(rnorm(Months, mean = Ch["mean"], sd = Ch["sd"]))
Growth <- c(abs(rnorm(Months, mean = G["mean"], sd = G["sd"])))

# Processes 
# --------------------- 

#Loop for 1000 samples

for (k in 1:1000) {
  
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

Simulated_Churned_Customers[k] <- Churned_Customers
# MRR

Total_MRR <- MRR * Customers
Churned_MRR <- 0
New_MRR <- 0
Net_MRR <- 0

for (i in 1:Months) {
  Churned_MRR[i] <- MRR[i]*Churn[i] 
  New_MRR[i] <- MRR[i]*Growth[i]
  Net_MRR[i] <- -Churned_MRR[i] + New_MRR[i]
  MRR[i + 1] <- MRR[i] + Net_MRR[i]
  Total_MRR[i+1] = MRR[i+1] * Customers[i+1]
}

# ARPA

New_ARPA <- (MRR[1] * AvgDuration * Customers[1])/Customers[1]
Total_ARPA <- (ARPA[1] * Customers[1])/Customers[1]

for (i in 1:(Months)) {
  New_ARPA[i+1] <- (MRR[i+1]*AvgDuration*Net_Customers[i+1])/Net_Customers[i+1]
  Total_ARPA[i+1] <- (Total_ARPA[i]*Customers[i] + New_ARPA[i+1]*Net_Customers[i])/Customers[i+1]
}


#Sample Collection
New

}