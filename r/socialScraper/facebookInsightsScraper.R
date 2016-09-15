## Facebook Insights API Scraper #
## By Vivek Menon ################
## v.1.5.0 #######################


# Todo --------------------------------------------------------------------

# - Run script for all major brands
# - Create 'participation rate' function

# Setup -------------------------------------------------------------------
# Load and install all necessary packages for the script

# Required Packages for dataframes, forecasting, graphical visualization, and development
# Use 'install.packages()' if unavailable.
#library(zoo)
#library(forecast)
library(ggplot2)
#library(scales)
library(devtools)
library(compare)
library(xlsx)

require(httr)
require(rjson)
require(RCurl)


# Pull most up to date Github repositories for relevant packages
# Not frequently updated; does not need to be run every time.
#install_github("pablobarbera/Rfacebook/Rfacebook")
#install_github("pablobarbera/instaR/instaR")

# Required packags for plugging into Facebook API
#library(twitteR)
#install.packages('Rfacebook')
library(Rfacebook)

#library(instaR)
# https://github.com/pablobarbera/instaR/blob/master/examples.R
# https://instagram.com/developer/authentication/?hl=en

setwd("~/")
getwd()


# Functions ---------------------------------------------------------------

# User Functions
# Function to convert Facebook date format to R date format
format.facebook.date <- function(datestring) {
  date <- as.POSIXct(datestring, format = "%Y-%m-%dT%H:%M:%S+0000", tz = "GMT")
}

# Shift a vector up by an amount
shift <- function(x, n){
  c(x[-(seq(n))], rep(NA, n))
}

# Get gcd from vector
gcd <- function(x,y) {
  r <- x%%y;
  return(ifelse(r, gcd(y, r), y))
}



# Inputs ------------------------------------------------------------------
# Set up script initials; what is the access ftoken, the relevant ids, and other necessary variables

# Define data range for data (2012 is out of bounds for some metrics)

# http://thinktostart.com/analyzing-facebook-with-r/
fb_oauth <- fbOAuth(app_id="<redacted>", app_secret="<redacted>",extended_permissions = FALSE)

posts <- 2000
roof = Sys.Date() #"2015-12-31"
floor = "2016-01-01" #"2015-05-01"
range = seq(as.Date(floor), as.Date(roof), by="days")


## Access ftoken
# Use token from Facebook Graph API
# token generated here: https://developers.facebook.com/tools/explorer
# Lasts two hours, and must be changed depending on page and permissions


ftokens <- c(
  # Brand Name
  <redacted>
  )

totalpagedata <- data.frame()
totalpostdata <- data.frame()

for (brand in 1:length(ftokens)) {
  ftoken <- ftokens[brand]

  ## User Id
  # Set up the user profile that will be accessing the data (must have all appropriate permissions/be Page Admin)
  userid = "<redacted>"

  # Access public personal data; basically a ftoken test
  me <- getUsers("me", token=ftoken)
  print(me$name)

  ## Page Id
  # Define which page will be used for the data collection. Change id's as necessary.
  # Can use Pagename or ID; ID is generally preferable. Can be found through Facebook Business Manager: https://business.facebook.com/

  pageid = me$id


  # Acquisition -------------------------------------------------------------
  # Grab/Load all Facebook Page & Post data until today for the Page defined.

  page <- getPage(pageid, ftoken, n = posts)
  page.store <- page

  # Create new vectors in dataset with datetime, month, and day formattiong

  if ((is.null(page$datetime[1]) & is.null(page$month[1]) & is.null(page$day[1])) == TRUE) {
    page$datetime <- format.facebook.date(page$created_time)
    page$month <- format(page$datetime, "%Y-%m")
    page$day <- format(page$datetime, "%Y-%m-%d")

    page$datetime <- as.Date(page$datetime)
    #page$month <- as.Date(page$month)
    page$day <- as.Date(page$day)
  } else {
    print("Date fields already exist.")
  }


  # Processing --------------------------------------------------------------
  # Process data to clean dataset and augment it with more data than default fields.
  # Check full package documentation for reference: http://cran.r-project.org/web/packages/Rfacebook/Rfacebook.pdf


## Cleaning =================================

# Page and Post Datasets
# Split dataset into two for pages and post data
# Create initial null sets
pagedata <- 0
postdata <- 0

## Appending =================================

### Page Metrics #############################
# Loop through all dates for the specified metric(s), and append the page dataset with metric values
# Some are automated, others are manual; after the script. Re-run from pull loop if there is an error; should auto-try until values are found.

# Page Metrics to automatically pull
# "page_fans_online" ,"page_fans_gender_age", "page_positive_feedback_by_type"
metrics = c("page_impressions","page_impressions_unique", "page_impressions_paid_unique", "page_engaged_users", "page_fans","page_consumptions") #c(
names(metrics) = c("Impressions","Total Reach",  "Paid Reach", "Engaged Users", "Fans", "Page Consumptions")

pagemetrics <- metrics


# Prep dataset by breaking into weeks
pagedata <- 0
pagedata <- cbind(page[1:length(range), c("from_id","from_name")],rev(range))


colnames(pagedata) = c("pageid", "page", "date")

pagedata$page = page$from_name[1]
pagedata$pageid = page$from_id[1]

divisor = 5
remainder = length(range)%%divisor;
pagedata <- pagedata[1:(nrow(pagedata)-remainder),]

weeks <- (nrow(pagedata)/5)-2

# Start Data Acquisition Loop
for (metric in 1:length(metrics)) {

  print(paste('Finding', names(metrics)[metric],'for',pagedata$page[1]))

  if ((metrics)[metric] == 'page_fans' | (metrics)[metric] == 'page_fans_gender_age') {
    period = 'lifetime'
  } else if ((metrics)[metric] == 'page_positive_feedback_by_type'| (metrics)[metric] == 'page_positive_feedback_by_type' ) {
    period = 'day'

    tempfloor = "2014-02-01"
    temprange = seq(as.Date(tempfloor), as.Date(roof), by="days")

    if (floor < tempfloor) {

    tempremainder = length(range[(length(range)-length(temprange)+1):length(range)])%%5
    tempweeks  = (length(temprange) - tempremainder)/5 - 2
    weeks = tempweeks

    } else {}
    } else {
    period = 'day'
    weeks <- (nrow(pagedata)/5)-2
  }

  hold <- matrix(0, nrow=0, ncol=7)

  for (week in 0:weeks) {

    end <- pagedata$date[(week*5)+1]
    start <- pagedata$date[((week+1)*5)+1]

    print(paste('Finding', names(metrics)[metric],'for',pagedata$page[1],'from',start,'to',end))

    pull <- NULL
    attempt <- 1

    while(is.null(pull) && attempt <= 10) {
      attempt <- attempt + 1
      try(
        pull <- getInsights(object_id=pageid, token=ftoken, metric=metrics[metric], period=period, parms=paste0('&since=',start,'&until=',end))
      )

      if (is.null(pull)) {
        print("Empty Pull. Re-attempting.")
        print(paste("Attempt", attempt))
      } else {
        pull$datetime <- format.facebook.date(pull$end_time)
        pull$day <- format(pull$datetime, "%Y-%m-%d")

        pull$datetime <- as.Date(pull$datetime)
        #page$month <- as.Date(page$month)
        pull$day <- as.Date(pull$day)

        if ((seq(from=start, to=(end-1), by = "days")[1] == pull$day[1]) & (seq(from=start, to=end, by = "days")[5] == pull$day[length(pull$day)]) == TRUE) {
          print("Found Facebook data matching date range. Storing values.")
        } else {
          print("Did not find Facebook data matching dataset dates. Re-querying.")
          print(paste("Attempt", attempt))
          pull <- NULL}

        if (attempt > 100) {
          print('Too many attempts. Skipping.')
          pull <- NULL
          break
        } else {}
      }

      pulllength <- ncol(pull)

      rpull = pull[rev(rownames(pull)),]

      hold <- rbind(hold,rpull)
      rawhold <- hold
    }
  }



  rhold = hold[rev(rownames(hold)),]
  rhold$value = shift(rhold$value, 1)
  hold = rhold[rev(rownames(rhold)),]
  hold$value[1] = rawhold$value[1]

hours <- seq(0,23)
names(hours) <- paste("Hour", hours)

subtypes <- c('link','comment', 'like')
names(subtypes) <- c('Shares','Comments', 'Likes')

demographics <- c("F.65+","F.55-64", "F.45-54","F.35-44", "F.25-34", "F.18-24", "M.65+", "M.55-64", "M.45-54", "M.35-44","M.25-34", "M.18-24")
names(demographics)  <- c("Females 65+", "Females 55-64", "Females 45-54", "Females 35-44", "Females 25-34", "Females 18-24",  "Males 65+", "Males 55-64", "Males 45-54", "Males 35-44", "Males 25-34", "Males 18-24")

# Posting demographics at the end of the loop as metrics[metric]; fix the tail end of the loop.

  if ((metrics)[metric] == 'page_positive_feedback_by_type') {

    for (type in 1:length(subtypes)) {
      typehold <- NA
      typehold <- hold[hold$variable == subtypes[type],]

      pagedata <- cbind(NA,pagedata)
      pagedata[2:(length(typehold$day)+1),1] <- (typehold$value)
      colnames(pagedata)[1] = paste0(tolower(names(subtypes[type])))

      metrics <- c(metrics,subtypes[type])
    }


  } else if ((metrics)[metric] == 'page_fans_gender_age') {

    for (demographic in 1:length(demographics)) {

      print(names(demographics[demographic]))

      typehold <- NA
      typehold <- hold[hold$variable == demographics[demographic],]
      typehold[typehold$value <= 10,] <- NA

      pagedata <- cbind(NA,pagedata)
      pagedata[2:(length(typehold$day)+1),1] <- (typehold$value)
      colnames(pagedata)[1] = paste0(tolower(demographics[demographic]))

      metrics <- c(metrics,demographics[demographic])
    }

  } else if ((metrics)[metric] == 'page_fans_online') {

    for (hour in 1:length(hours)) {

      typehold <- NA
      typehold <- hold[hold$variable == hours[hour],]

      pagedata <- cbind(NA,pagedata)
      pagedata[2:(length(typehold$day)+1),1] <- (typehold$value)
      colnames(pagedata)[1] = paste("hour",hours[hour])

      metrics <- c(metrics,hours[hour])
    }
  } else {
    pagedata <- cbind(NA,pagedata)
    pagedata[2:(length(hold$day)+1),1] <- (hold$value)
    colnames(pagedata)[1] = paste0(tolower(names(metrics[metric])))

  }

  cat("\n\n")
  print(head(pagedata))
  cat("\n")

  if (length(metrics) == (length(pagemetrics)  + length(demographics) + length(hours))) {
    break
  } else {
  }

}

pagedata.tempstore <- pagedata

#Page Metrics to remove because they have subtypes
metrics <- metrics[-c(which(metrics == "page_positive_feedback_by_type"),which(metrics == "page_fans_gender_age"),which(metrics == "page_fans_online"))]

# Page Metrics to manually create
metrics <- c(metrics,"organic reach")
names(metrics)[length(metrics)] <- c("Organic Reach")

pagedata <- cbind((as.numeric(pagedata$`total reach`) - as.numeric(pagedata$`paid reach`)),pagedata)
colnames(pagedata)[1] = "organic reach"

# Final dataset formatting
pagedatastore <- pagedata
#pagedata <- pagedatastore
pagedata2 <- pagedata

# reorder and null NA's for excel
pagedata2 <- pagedata2[,c((ncol(pagedata)-2), (ncol(pagedata)-1),(ncol(pagedata)),(1:(ncol(pagedata)-3)))]
pagedata2 <- pagedata2[2:nrow(pagedata2),]
#pagedata2[is.na(pagedata2)] <- ""
#pagedata2[pagedata2 == 0] <- ""

# store final dataset
pagedata <- pagedata2

### Post Metrics #############################
# Loop through all posts for the specified metric(s), and append the post dataset with metric values
# Most are automated, and will continue to retry through errors until a value is found.
# Manual modifications are run after initial data acquisition.

postmetrics = c("post_impressions_unique","post_impressions_paid_unique","post_video_views_organic","post_video_views_paid","post_video_complete_views_organic","post_video_complete_views_paid","post_engaged_users","post_consumptions_by_type")
names(postmetrics) = c("Total Reach", "Paid Reach","Organic Video Views", "Paid Video Views", "Organic Complete Video Views", "Paid Complete Video Views","Engaged Users", "Post Consumptions")

# Populate sets with values from pull

if ((is.null(page$datetime[1]) & is.null(page$month[1]) & is.null(page$day[1])) == TRUE) {
  page$datetime <- format.facebook.date(page$created_time)
  page$month <- format(page$datetime, "%Y-%m")
  page$day <- format(page$datetime, "%Y-%m-%d")

  page$datetime <- as.Date(page$datetime)
  #page$month <- as.Date(page$month)
  page$day <- as.Date(page$day)
} else {
  print("Date fields already exist for Post Data.")
}

postdata <- 0
postdata <- page[page$day > floor,]
postdata <- postdata[postdata$day < roof,]

#write.xlsx(postdata, paste0(paste(me$name,floor,"to",roof,sep=" "),".xlsx"), row.names=FALSE)


# Name column for usability
colnames(postdata) = c("pageid", "page", "message", "created", "type", "link", "postid", "likes", "comments", "shares", "datetime", "month","day")

rows <- nrow(postdata)
lpostmetrics <- postmetrics

testlength <- 2
#length(postmetrics) instead of testlength; swapped out for hotfixes


for (pmetric in 1:length(postmetrics)) {
  print(paste('Finding', names(postmetrics)[pmetric],'for',postdata$page[1]))

  if ((substr((postmetrics)[pmetric], 1, 17) == ('post_consumptions'))) {
    phold <- data.frame(0,0,0,0,0,0,0, stringsAsFactors=FALSE)
    names(phold) <- c("id","name","period","title","description","value","variable")
  } else {
    phold <- data.frame(0,0,0,0,0,0, stringsAsFactors=FALSE)
    names(phold) <- c("id","name","period","title","description","value")
  }


  for (post in 1:nrow(postdata)) {

    period <- "lifetime"


    print(paste('Finding', names(postmetrics)[pmetric],'for',postdata$page[1], postdata$type[post],'post:',paste0(substr(postdata$message[post], 1, 80),"...")))

      if ((substr((postmetrics)[pmetric], 1, 10) == ('post_video')) & (postdata$type[post] != 'video')) {
      print('Not a Facebook Video.')
      phold <- rbind(phold, NA)
      next()
      } else if ((substr((postmetrics)[pmetric], 1, 10) == ('post_video')) & (postdata$type[post] == 'video') & (substr(postdata$link[post], 12, 18) != 'youtube') & (substr(postdata$link[post], 8, 15) != 'youtu.be')) {
      } else {
      }


    postpull <- NULL
    attempt <- 1

    while( is.null(postpull) && attempt <= 100) {
      attempt <- attempt + 1
      try(
        postpull <- getInsights(object_id=postdata$postid[post], token=ftoken, metric=postmetrics[pmetric], period=period)
        ,silent=TRUE
      )
      if (attempt > 10) {
        print('Too many attempts. Skipping.')
        postpull <- NULL
        break
      } else {
      }
    }

    colnames(phold) <- names(postpull)
    phold <- rbind(phold, postpull)
  }
  pholdstore <- phold

  psubtypes <- c('other clicks','photo view', 'link clicks', 'video play')
  names(psubtypes) <- c('Other Clicks','Photo Views', 'Link Clicks', 'Video Plays')

  phold <- phold[-1,]

  if ((postmetrics)[pmetric] == 'post_consumptions_by_type') {

    postmetrics <- postmetrics[-pmetric]
    pmetric <- pmetric + 1

    for (ptype in (1:length(psubtypes))) {
      ptyphehold <- NA
      ptypehold <- phold[phold$variable == psubtypes[ptype],]

      postdata <- cbind(NA,postdata)
      postdata[match(substr(ptypehold$id, 1, 22), substr(postdata$postid, 1, 22)),1] <- ptypehold$value

      colnames(postdata)[1] = paste0(tolower(names(psubtypes[ptype])))
      postmetrics <- c(postmetrics,psubtypes[ptype])
    }


  } else {
    postdata <- cbind(NA,postdata)
    postdata[1:length(phold$value),1] <- phold$value
    colnames(postdata)[1] = paste0(tolower(names(postmetrics[pmetric])))
  }


  cat("\n\n")
  print(head(postdata))
  cat("\n")
}

postdatastore <- postdata



# Post Metrics to manually create
postmetrics <- c(postmetrics,"organic reach")
names(postmetrics)[length(postmetrics)] <- c("Organic Reach")

postdata <- cbind((as.numeric(postdata$`total reach`) - as.numeric(postdata$`paid reach`)),postdata)
colnames(postdata)[1] = "organic reach"

# Final dataset formatting
#postdatastore <- postdata
#postdata <- postdatastore

#head(postdatastore[,c((ncol(postdata)-12),(ncol(postdata)-11),(ncol(postdata)-9),(ncol(postdata)-2), (ncol(postdata)-1),ncol(postdata),(ncol(postdata)-6),(ncol(postdata)-7),(ncol(postdata)-8),(ncol(postdata)-10),(ncol(postdata)-5),(ncol(postdata)-4),(ncol(postdata)-3),(1:(ncol(postdata)-13)))])

# reorder and null NA's for Excel
postdata2 <- postdata
postdata2 <- postdata2[,c((ncol(postdata)-12),(ncol(postdata)-11),(ncol(postdata)-9),(ncol(postdata)-2), (ncol(postdata)-1),ncol(postdata),(ncol(postdata)-6),(ncol(postdata)-7),(ncol(postdata)-8),(ncol(postdata)-10),(ncol(postdata)-5),(ncol(postdata)-4),(ncol(postdata)-3),(1:(ncol(postdata)-13)))]
postdata2[is.na(postdata2)] <- ""
postdata2[postdata2 == 0] <- ""

# store final dataset
postdata <- as.data.frame(postdata2)

# Outputs -----------------------------------------------------------------

pagedata[,-c(1:3)] <- sapply(pagedata[,-c(1:3)], as.numeric)
postdata[,-c(1:10)] <- sapply(postdata[,-c(1:10)], as.numeric)

datafolder <- "Data"

dir.create(file.path(getwd(), datafolder), showWarnings = FALSE)

# Rename columns for Excel readability
#names(pagedata) = c("Page ID", "Page Name", "Date", rev(names(metrics)))
# output Page dataset as final csv
#write.csv(pagedata, paste0(paste(page$from_name[1],"Page Data",Sys.Date(), sep=" "),".csv"),row.names=FALSE, fileEncoding='iso-8859-1')
write.xlsx(pagedata, paste0(getwd(),"/",datafolder,"/",paste(page$from_name[1],"Page Data",Sys.Date(), sep=" "),".xlsx"), row.names=FALSE, showNA=FALSE)
?wri
# Rename columns for Excel readability
#names(postdata) = c("Page ID", "Page Name", "Created",  "Datetime", "Month", "Day", "Post ID", "Link", "Type", "Message", "Likes", "Comments", "Shares", rev(names(postmetrics)))
# output Post dataset as final Excel
#write.csv(postdata, paste0(paste(page$from_name[1],"Post Data",Sys.Date(), sep=" "),".csv"),row.names=FALSE)
write.xlsx(postdata, paste0(getwd(),"/",datafolder,"/",paste(page$from_name[1],"Post Data",Sys.Date(), sep=" "),".xlsx"), row.names=FALSE, showNA=FALSE)

# Raw Data
# output dataset as raw csv
#write.csv(page, paste0(paste(me$name,"Raw Data",Sys.Date(), sep=" "),".csv"),row.names=FALSE)

totalpagedata <- rbind(totalpagedata, pagedata)
totalpostdata <- rbind(totalpostdata, postdata)

}

write.xlsx(totalpagedata, paste0(getwd(),"/",datafolder,"/",paste("Baron","Page Data",Sys.Date(), sep=" "),".xlsx"), row.names=FALSE, showNA=FALSE)
# Rename columns for Excel readability
#names(postdata) = c("Page ID", "Page Name", "Created",  "Datetime", "Month", "Day", "Post ID", "Link", "Type", "Message", "Likes", "Comments", "Shares", rev(names(postmetrics)))
# output Post dataset as final Excel
#write.csv(postdata, paste0(paste(page$from_name[1],"Post Data",Sys.Date(), sep=" "),".csv"),row.names=FALSE)
write.xlsx(totalpostdata, paste0(getwd(),"/",datafolder,"/",paste("Baron","Post Data",Sys.Date(), sep=" "),".xlsx"), row.names=FALSE, showNA=FALSE)

# Images
#imagefolder <- paste0("Images","/",paste(page$from_name[1],sep=" "))#,floor,"to", roof, sep=" "))

#for (picture in (1:nrow(postdata))) {
#  dir.create(file.path(getwd(), imagefolder), showWarnings = FALSE)
#
#  imageURL <- fromJSON(getURL(paste('https://graph.facebook.com/v2.4/',postdata$`Post ID`[picture],'?fields=full_picture&access_token=',ftoken,sep="")))$full_picture
#  filename <- paste0(getwd(), "/", imagefolder, "/", postdata$`Post ID`[picture], ".png")
#
#  try(GET(imageURL, write_disk(filename, overwrite=TRUE)))


# Edit the core program and change feedback loop.

#
#}
