# TaaS 
# MRR Calculator 

# Packages 
# --------------------- 

require(reshape)
require(ggplot2)

# Variables 
# --------------------- 

# Input
MRR <- 30 # Monthly subscription of $30 
AvrgDuration <- mean(1:2) # Average Contract Duration between 1 and 2 months 
ARPA <- MRR * AvrgDuration # Average Monthly Recurring Revenue per Account
Months <- 12 #Months of simulation 
Customers <- 60 #Initial influx of Customers (Month 1)
Margin <- 0.45 #Average sale margin
R <- 0.10 # Discount/Interest rate
Ad_Budget <- 200 # Amount spent acquiring customers monthly
  
# Customer Churn and Growth 

VariationTable <- matrix(0:0, nrow = 2, ncol = 2)
colnames(VariationTable) <- c("Mean","SD")
rownames(VariationTable) <- c("Churn","Growth")

VariationTable["Churn","Mean"] <- 0.10
VariationTable["Churn","SD"] <- 0.05
VariationTable["Growth","Mean"] <- 0.00
VariationTable["Growth","SD"] <- 0.001

VariationTable_s <- paste(VariationTable * 100,'%',sep=" ")
VariationTable_f <- matrix(0:0, nrow = 2, ncol = 2)
colnames(VariationTable_f) <- c("Mean","SD")
rownames(VariationTable_f) <- c("Churn","Growth")

VariationTable_f["Churn","Mean"] <- VariationTable_s[1]
VariationTable_f["Churn","SD"] <- VariationTable_s[2]
VariationTable_f["Growth","Mean"] <- VariationTable_s[3]
VariationTable_f["Growth","SD"] <- VariationTable_s[4]



Churn <- rnorm(1:Months, mean = 0.10, sd = 0.05) # Expected churn rate mean and deviation (%)
Growth <- abs(rnorm(1:Months, mean = 0.10, sd = 0.05)) # Expected growth rate mean and deviation (%)

# Revenue Churn and Growth 

Revenue_Churn <- rnorm(1:Months, mean = 0.00, sd = 0.001) # Expected Revenue churn rate mean and deviation (%) 
Revenue_Growth <- abs(rnorm(1:Months, mean = 0.00, sd = 0.001)) # Expected Revenue growth rate mean and deviation (%)

# Generator
# --------------------- 

# Initial Vectors 

Churned_Customers <- 0
New_Customers <- 0
Net_Customers <- 0

Total_MRR <- MRR * Customers
Churned_MRR <- 0
Expanded_MRR <- 0
Net_MRR <- 0
Moving_MRR <- MRR

Time <- c(1:Months)
Customer_Lifetime <- 1/mean(Churn)

LTV <- (ARPA[1] * Margin * Customer_Lifetime)/((1+R/(Customer_Lifetime))^(Customer_Lifetime))
CAC <- Ad_Budget/(MRR[1] * Margin) 
Recover_CAC <- 0


for (i in 1:Months) {
  # Customers
  Churned_Customers[i] <- Customers[i]*Churn[i]
  New_Customers[i] <- Customers[i]*Growth[i]
  Net_Customers[i] <- -Churned_Customers[i] + New_Customers[i]
  Customers[i+1] <- Customers[i] + Net_Customers[i]
  
  # MRR
  Total_MRR[i] = MRR * Customers[i]
  Churned_MRR <- Revenue_Churn * MRR
  Expanded_MRR <- Revenue_Growth * MRR
  Net_MRR <- -Churned_MRR + Expanded_MRR
  Moving_MRR[i + 1] <- MRR + Net_MRR[i]
  
  # ARPA
  ARPA[i+1] <- ((MRR * Customers[i]) + (MRR * Net_Customers[i]))/(Customers[i+1])

  #LTV
  LTV[i] <- (ARPA[i] * Margin * Customer_Lifetime)/((1+R/(Customer_Lifetime))^(Customer_Lifetime))
  
  #CAC
  CAC[1:12] <- Ad_Budget/mean(New_Customers)
  LTV_CAC <- LTV[1:12]/CAC[1:12]
  Recover_CAC[i] <- CAC[i]/(mean(MRR) * Margin)
}


#Cohort Tables
# --------------------- 

#Customers
Customer_Matrix <- matrix(0:0,nrow=Months,ncol=Months)
colnames(Customer_Matrix) <- c("January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December")
Customer_Matrix[1,1] <- Customers[1]

for (i in 1:(Months-1)) {
  Customer_Matrix[i + 1, i + 1] <- New_Customers[i+1]
  Customer_Matrix[,i+1] <- Customer_Matrix[,i] * (1 - Churn[i])
  Customer_Matrix[i + 1, i + 1] <- New_Customers[i+1]
}


#MRR
MRR_Matrix <- matrix(0:0,nrow=Months,ncol=(Months))
colnames(MRR_Matrix) <- c("January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December")
MRR_Matrix[1,1] <- Customers[1] * MRR

for (i in 1:(Months-1)) {
  MRR_Matrix[,i + 1] <- Customer_Matrix[,i + 1] * MRR
}

print(MRR_Matrix)


# Storage
MRR_Data <- data.frame(1:12, Customers[1:12], Churned_Customers[1:12], New_Customers[1:12], Net_Customers[1:12], MRR[1:12], Total_MRR[1:12], ARPA[1:12], LTV[1:12], CAC[1:12], Recover_CAC[1:12], LTV_CAC[1:12],  
                       row.names = c("January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"))
names(MRR_Data) <- c("Months","Customers", "Churned Customers", "New Customers", "Net Customers", "MRR", "Total MRR", "ARPA", "LTV", "CAC", "Recover CAC" , "LTV/CAC")

write.csv(MRR_Data, file="MRR_Data_Test.csv")

# References
# --------------------- 

# mean(MRR_Data$LTV)

# Plots 
# --------------------- 

library(ggplot2)

Customer_Frame <- data.frame(round(Customer_Matrix))
colnames(Customer_Frame) <- c(1:Months)
Customer_Frame["Cohort"] <- paste("Cohort", 1:Months, sep = " ")
Customer_Frame_M$Cohort_f = factor(Customer_Frame_M$Cohort, levels = paste("Cohort", 1:Months, sep = " ")) # Re order levels in right order
Customer_Frame_M <- melt(Customer_Frame, id="Cohort") #Reshape Data Frame
colnames(Customer_Frame_M) <- c("Cohort","Month","Customers")

fit <- glm(y~x)


# c1 <- ggplot(Customer_Frame_M, aes(x = Month, y = Customers, fill = Cohort))

Cu <- ggplot(Customer_Frame_M, aes(x = Month, y = Customers)) 

Cu + geom_bar(stat="identity") + facet_wrap(~ Cohort_f) + geom_point() + theme_bw()
# Cohorts, Facetted 

Cus <- 

# Customer Graph (All cases)
# MRR Graph (All cases)
# ARPA graph (All Cases)
# ARPA vs Customer churn/growth rate (c) vs MRR churn/growth rate (c)
  
  
  
