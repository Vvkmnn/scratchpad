## Twitter API Scraper #########
## By Vivek Menon ##############
## v.0.0.1 #####################

# Todo --------------------------------------------------------------------

# - Formalize
# - Use Brandwatch mnore, focus on Facebook

# Setup --------------------------------------------------------------------

library(twitteR)

setup_twitter_oauth(consumer_key = "<redacted>", consumer_secret = "<redacted>")

#loop through users, get description

users <- plcTweeters$V1
descriptions <- c()
#length(users)

for (user in 1:length(users)) {
  try(name <- getUser(users[user]))
  print(name)
  descriptions[user] <- name$description
}
