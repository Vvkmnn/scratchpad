
# Load necessary packages 
install.packages("neuralnet")
library("neuralnet")

# Load dataset
head(iris)
summary(iris)

# Frame dataset

# Build index vector to find every 5th element in the length of the series.
testidx <- which(1:length(iris[,1])%%5 == 0)

# Build training set; use negative index to find every value but the 5th.
iristrain <- iris[-testidx,]

# Use every 5th value as the test set to check the accuracy of the model. 
iristest <- iris[testidx,]

# Load temporary neuralnet dataset
nnet_iristrain <-iristrain

# Binarize the categorical output, by using boolean statements. 
nnet_iristrain <- cbind(nnet_iristrain, iristrain$Species == 'setosa')
nnet_iristrain <- cbind(nnet_iristrain, iristrain$Species == 'versicolor')
nnet_iristrain <- cbind(nnet_iristrain, iristrain$Species == 'virginica')

# Rename the columns from the cbind true false so that they make sense. 
names(nnet_iristrain)[6] <- 'setosa'
names(nnet_iristrain)[7] <- 'versicolor'
names(nnet_iristrain)[8] <- 'virginica'

# Train network by examining input variables onto the quantitative variables, using the training dataset and 3 hidden layers. Use column names found inside the training dataset. 
nn <- neuralnet(setosa+versicolor+virginica ~ Sepal.Length + Sepal.Width + Petal.Length + Petal.Width, data=nnet_iristrain, hidden=c(8))

# Plot the network
plot(nn)

# Use feedforward to compute results from the test set. 
mypredict <- compute(nn, iristest[-5])$net.result

# Consolidate multiple binary output back to categorical output

maxidx <- function(arr) {
  return(which(arr == max(arr)))
  }

idx <- apply(mypredict, c(1), maxidx)

prediction <- c('setosa', 'versicolor', 'virginica')[idx]

table(prediction, iristest$Species)
