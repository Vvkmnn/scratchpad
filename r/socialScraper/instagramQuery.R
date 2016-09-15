## Instagram API Scraper #######
## By Vivek Menon ##############
## v.0.0.2 #####################

# Todo --------------------------------------------------------------------

# - Sandbox mode?

# Setup --------------------------------------------------------------------


#devtools::install_github("pablobarbera/instaR/instaR")
#install_github("pablobarbera/instaR/instaR")

install.packages('instaR')
#update.packages("instaR")
library("instaR")
library('httpuv')


# Functions ---------------------------------------------------------------

# User Functions
# Function to convert Facebook date format to R date format
format.facebook.date <- function(datestring) {
date <- as.POSIXct(datestring, format = "%Y-%m-%dT%H:%M:%S+0000", tz = "GMT")
}


df <- searchInstagram(tag="<redacted>", n=1000, token=my_oauth, verbose = TRUE)#, folder = folder)


roof = "2015-12-01" # Sys.Date()+1
floor = "2015-12-31"

# scope = public_content basic
my_oauth <- instaOAuth(app_id="<redacted>", app_secret="<redacted>", scope="basic public_content follower_list")

accounts <- c("<redacted>")

for (account in 1:length(accounts)) {

    username=accounts[account]

    posts <- getUserMedia(username=accounts[account],token=my_oauth, n=500)

    #,n = 1)#, n=200, verbose = TRUE)
    #user <- getUser(accounts[account], token=my_oauth)
    #df <- getFollowers('womenchampions', token=my_oauth)

    df <- posts

    if ((is.null(df$datetime[1]) & is.null(df$month[1]) & is.null(df$day[1])) == TRUE) {
    df$datetime <- format.facebook.date(df$created_time)
    df$month <- format(df$datetime, "%Y-%m")
    df$day <- format(df$datetime, "%Y-%m-%d")
    } else {
    print("Date fields already exist.")
    }


    df <- df[df$day > floor,]
    df <- df[df$day < roof,]

    follows <- NULL
    impressions <- NULL
    impressionusers <- NULL
    count <- 0
    jump <- 1 # Loop paramater
    weight <- 0.1 # 10%

    for (post in 1:nrow(df)) {

    try(impressionusers <- c(
      getComments(df$id[post], token=my_oauth, verbose = FALSE)$from_username,
        getLikes(df$id[post], token=my_oauth, verbose = FALSE)$username
      )
      ,silent = TRUE)
    impression <- 0

    if (is.null(impressionusers) == TRUE){
      impressions[post] <- 0
    } else {
    impressionusers <- unique(impressionusers[seq(1, length((impressionusers)), by = jump)])

    for (user in 1:length(impressionusers)){
      #print(user)
      #print(impression)
      userdata <- NULL

      try(userdata <- getUser(impressionusers[user], token=my_oauth))

      if (is.null(userdata)) {
        newimpression <- 0
        impression <- as.numeric(newimpression) + as.numeric(impression)
        next
        } else {
        newimpression <- + userdata$follows + userdata$followed_by
        impression <- as.numeric(impression) + as.numeric(newimpression)
        }
    }

    impression = ceiling(weight * impression)

    impressions[post] <- impression
    }

    print(impressions[post])
    count = count + 1
    percentcomplete <- paste0((round(count/nrow(df), digits = 2)*100),"%")
    print(paste("Getting impressions for user",df$user_fullname[post],"[",percentcomplete,"] Complete."))
    }

    impressions.store <- impressions
    #impressions <- round(impressions/5,0)

    df <- cbind(df, impressions)

    df.store <- df

    df[is.na(df)] <- ""

    name <- paste(df$user_fullname[1],"Instagram", Sys.Date())

    datafolder <- "/Data"

    dir.create(file.path(getwd(), datafolder), showWarnings = FALSE)

    write.csv(df, paste0(getwd(),"/",datafolder,"/",paste0(name,".csv")))#, row.names=FALSE)
    }

    #write.xlsx(df, paste0(getwd(),"/",datafolder,"/",paste0(name,".xlsx")), row.names=FALSE)
