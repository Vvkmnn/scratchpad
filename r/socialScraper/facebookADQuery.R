## Facebook Ad API Scraper #####
## By Vivek Menon ##############
## v.1.2.0 #####################

# Setup -------------------------------------------------------------------

library(httr)
library(RJSONIO)
library(RCurl)
library(devtools)
library(xlsx)

# CRAN Approach
# Install and use Rfacebook; deprecated for direct API call approach.
#install_github("pablobarbera/Rfacebook/Rfacebook")
#library(Rfacebook)
#install.packages("Rfacebook")
#library(Rfacebook)

# Github Approach
# Using 'rFacebook' from Github
# fboauth <- fbOAuth(app_id = app_id, app_secret ,extended_permissions = scope)
#callAPI("https://graph.facebook.com/v2.6/<redacted>", fboauth)


# Todo -------------------------------------------------------------------

# - Bug fixes, date_preset for v2.6 set to 30 by default, reset to lifetime
# - Set to more rigorous method that pulls all ads at addaccount_id level, instead of consistent queries

# Options -------------------------------------------------------------------

# Turn stringsAsFactors off so rbind works properly.
#options(stringsAsFactors = FALSE)


# Functions ---------------------------------------------------------------

# User Functions
# Function to convert Facebook date format to R date format
format.facebook.date <- function(datestring) {
  date <- as.POSIXct(datestring, format = "%Y-%m-%dT%H:%M:%S+0000", tz = "GMT")
}


# Inputs ------------------------------------------------------------------

# Find OAuth settings for facebook:
#http://developers.facebook.com/docs/authentication/server-side/
facebook <- oauth_endpoints("facebook")

#facebook <- oauth_endpoint(
#  authorize = "https://www.facebook.com/dialog/oauth",
#  access = "https://graph.facebook.com/oauth/access_token",
#  base = "https://localhost:1410")

# Register an application at https://developers.facebook.com/apps/
#Insert your values below - if secret is omitted, it will look it up in
#the FACEBOOK_CONSUMER_SECRET environmental variable.

app_name <- "<redacted>"
app_id <- "<redacted>"
app_secret <- "<redacted>"
scope = "ads_management,manage_pages,publish_actions"

## Get a callback URL that matches the value entered in the Facebook App, typically "https://localhost:1410"
full_url <- oauth_callback()
full_url <- gsub("(.*localhost:[0-9]{1,5}/).*", x=full_url, replacement="\\1")
message <- paste("Copy and paste into Site URL on Facebook App Settings:",
full_url, "\nWhen done, press any key to continue...")

## Reminder to add callback into the app page.
invisible(readline(message))

myapp <- oauth_app(app_name, app_id, app_secret)

## current httr version, to test which oauth protocol to use. [Required to set global port variables; won't work otherwise.]
if (packageVersion('httr') > "0.6.1"){
  Sys.setenv("HTTR_SERVER_PORT" = "1410/")
  fb_oauth <- oauth2.0_token(facebook, myapp,
 scope=scope, type = "application/x-www-form-urlencoded", cache=FALSE)
  if (GET("https://graph.facebook.com/me", config(token=fb_oauth))$status==200){
message("Authentication successful.")
  }
}

# Test 1: Facebook Profile Information
req <- GET("https://graph.facebook.com/v2.6/me?fields=id,name", config(token = fb_oauth))
stop_for_status(req)
str(content(req))

# Test 2: Ad Account Information
accountreq <- GET("https://graph.facebook.com/v2.6/<redacted>", config(token = fb_oauth))

adaccountname <- content(accountreq)[1]$name
adaccountid <- content(accountreq)[2]$id

# Inputs ------------------------------------------------------------------

# /insights is the new /stats; gets ad data at the account and id level
# /keywordstats = interests in ad manager UI

## Variables
# Number of Ads to Pull
ads = 2000 #So far, only 167 in the account.

#try(
#  adreq <- GET(paste0("https://graph.facebook.com/v2.6/",adlist[ad,1],"/insights?fields=",paste(admetrics,collapse=",")), config(token = fb_oauth))
#)
#stop_for_status(adreq)
#adcontent <- content(adreq)
#adcontentparsed <- unlist(adcontent$data, use.names=TRUE, recursive=TRUE)

## Facebook:
#[1] All valid values are: date_start, date_stop, account_id, account_name, adgroup_id, adgroup_name, campaign_group_id, campaign_group_name, campaign_id, campaign_name, action_carousel_card_id, action_carousel_card_name, actions, unique_actions, total_actions, total_unique_actions, action_values, total_action_value, impressions, social_impressions, clicks, social_clicks, unique_impressions, unique_social_impressions, unique_clicks, unique_social_clicks, spend, frequency, social_spend, deeplink_clicks, app_store_clicks, website_clicks, call_to_action_clicks, newsfeed_avg_position, newsfeed_impressions, newsfeed_clicks, reach, social_reach, ctr, unique_ctr, cpc, cpm, cpp, cost_per_total_action, cost_per_action_type, cost_per_unique_click, cost_per_10_sec_video_view, relevance_score, website_ctr, video_avg_sec_watched_actions, video_avg_pct_watched_actions, video_p25_watched_actions, video_p50_watched_actions, video_p75_watched_actions, video_p95_watched_actions, video_p100_watched_actions, video_complete_watched_actions, video_10_sec_watched_actions, video_15_sec_watched_actions, video_30_sec_watched_actions"w

# Processing --------------------------------------------------------------

### Intial Batch Ad Pull
# Dataframe and query result holder

initialcontent <- NULL
after <- NULL

# Pull all ad ids and names, batch mode

#initialreq <- GET(paste0("https://graph.facebook.com/v2.6/<redacted>/adcampaigns?fields=name&limit=",ads), config(token = fb_oauth))

initialreq <- 400
count <- 0


while (warn_for_status(initialreq) != TRUE) {
  count <- count + 1
  print(paste('Query Attempt', count))
  initialreq <- GET(paste0("https://graph.facebook.com/v2.6/<redacted>/campaigns?fields=name,objective,id,created_time&limit=",ads), config(token = fb_oauth))
}


initialreq <- GET(paste0("https://graph.facebook.com/v2.6/<redacted>/campaigns?fields=name,objective,id,created_time&limit=",ads), config(token = fb_oauth))

str(content(initialreq))
initialcontent <- content(initialreq)

# List of 154; don't need to paginate yet
#after <- initialcontent$paging$cursors$after


## Loop 1, Organize all ads into dataset
print(paste("Pulling All Ad Campaigns for",paste0(adaccountname,".")))

adlist <- data.frame(NULL, stringsAsFactors = FALSE)
ad <- 0


for (ad in (1:(length(initialcontent$data)))) {
    #print(i)

    adlist[ad,c("ad.campaign.id")] <- initialcontent$data[[ad]]$id
    adlist[ad,c("ad.campaign.name")] <- initialcontent$data[[ad]]$name
    adlist[ad,c("objective")] <- initialcontent$data[[ad]]$objective
    #adlist[ad,c("status")] <- initialcontent$data[[ad]]$campaign_group_status
    adlist[ad,c("created.time")] <- substr(initialcontent$data[[ad]]$created_time, 1, 10)


    #adlist[ad,c("campaign id")] <- initialcontent$data[[ad]]$campaign_id
    #adlist[ad,c("campaign name")] <- initialcontent$data[[ad]]$campaign_name
    # Use this loop to populate with admetrics, and augment initial dataset; will not affect following loops.

    completion <- (ad/(length(initialcontent$data))*100)

    print(paste(paste0(round(completion, digits = 0),"%"), "Complete."))
  }


adlist_store <- adlist

# slice list
#adlist <- adlist[adlist$created.time > "2016-02-29",]

#adlist_sliced <- adlist

# Metrics to examine
admetrics <- c("frequency,newsfeed_avg_position,ctr,unique_ctr,spend,reach,social_reach,unique_clicks,social_clicks,cost_per_unique_click,total_actions,cost_per_total_action,actions,video_avg_pct_watched_actions,video_avg_sec_watched_actions") #"cost_per_action_type"

# Test Pull for Loop 2
#testreq <- GET(paste0("https://graph.facebook.com/v2.6/",adlist[89,1],"/insights?fields=",paste(admetrics,collapse=",")), config(token = fb_oauth))
#warn_for_status(testreq)
#content(testreq)

# Metrics framed
overalladmetricsreturned <- c("date_start","date_stop","spend","reach","social_reach","frequency","page_engagement","post_engagement","unique_clicks","social_clicks","cost_per_unique_click","total_actions","cost_per_total_action","like","post_like","comment","share","link_click","photo_view","video_play","video_view","video_avg_sec_watched_video_view","video_avg_sec_watched_page_engagement","video_avg_sec_watched_post_engagement","video_avg_pct_watched_video_view","video_avg_pct_watched_page_engagement","video_avg_pct_watched_post_engagement")


#number of columns = length(c(names(header),overalladmetricsreturned))

#adstart <- ad
#600 calls / 600 seconds rate limit

#adlist <- subset(adlist, created.time > "2016-04-26")
#adlist <- subset(adlist, "2016-07-05" > created.time)

adoveralldata <- data.frame(stringsAsFactors = FALSE)

# Baron
adlist <- adlist[grep("BAR",adlist$ad.campaign.name),]


### Warning: Massive while loop that continues until the ad list is retrieved from Facebook Need to restart/interrupt R to stop the loop.

#nrow(adlist))
#4

for (ad in 1:nrow(adlist)) {
  print(paste0('Querying Ad ',ad,": ", adlist$ad.campaign.name[ad]))
  adreq$status_code = 400
  count <- 0

  try(adreq <- GET(paste0("https://graph.facebook.com/v2.6/",adlist[ad,1],"/insights?fields=",paste(admetrics[1],collapse=","),"&date_preset=lifetime&time_increment=1"), config(token = fb_oauth)))

  if(adreq$status_code == 400) {
    while(adreq$status_code == 400) {
      try(adreq <- GET(paste0("https://graph.facebook.com/v2.6/",adlist[ad,1],"/insights?fields=",paste(admetrics[1],collapse=","),"&date_preset=lifetime&time_increment=1"), config(token = fb_oauth)))

      count <- count + 1
      print(adreq)
      print(paste('Limit Reached. Waiting 30 seconds.'))
      print(paste('Attempt:',count))
      Sys.sleep(30) #5*60
    }
  } else {
    print('Query successful.')
  }

  # Organize/clean data
  adcontent <- content(adreq)
  adcontentparsed <- unlist(adcontent$data, use.names=TRUE, recursive=TRUE)

  print(adcontentparsed)

  nextpage <- adcontent$paging$`next`

  while (is.null(nextpage) == FALSE) {
    #print("Additional Days")

    adreq.additional <- GET(adcontent$paging$`next`, config(token = fb_oauth))
    adcontent.additional <- content(adreq.additional)
    adcontent.additional.parsed <- unlist(adcontent.additional, use.names=TRUE, recursive=TRUE)

    adcontentparsed <- c(adcontentparsed,adcontent.additional.parsed)
    nextpage <- adcontent.additional$paging$`next`
  }
  #adcontent2 <- unlist(adcontent$data, use.names=FALSE, recursive=TRUE)

  adcontentparsed.store <- adcontentparsed
  #adcontentparsed <- adcontentparsed.store

  names(adcontentparsed)[(names(adcontentparsed) == ("actions.value"))] <- adcontentparsed[(names(adcontentparsed) == ("actions.action_type"))]
  adcontentparsed <- adcontentparsed[-which((names(adcontentparsed) == ("actions.action_type")))]

  if (length(which(names(adcontentparsed) %in% c("video_avg_pct_watched_actions.action_type","video_avg_sec_watched_actions.action_type"))) > 1) {
    names(adcontentparsed)[(names(adcontentparsed) == ("video_avg_sec_watched_actions.value"))] <- paste0("video_avg_sec_watched_",adcontentparsed[(names(adcontentparsed) == ("video_avg_sec_watched_actions.action_type"))])
    names(adcontentparsed)[(names(adcontentparsed) == ("video_avg_pct_watched_actions.value"))] <- paste0("video_avg_pct_watched_",adcontentparsed[(names(adcontentparsed) == ("video_avg_sec_watched_actions.action_type"))])

    adcontentparsed <- adcontentparsed[-which((names(adcontentparsed) == ("video_avg_pct_watched_actions.action_type")))]
  }
  # Frame data for inclusion

  days = length((adcontentparsed[overalladmetricsreturned[1] == names(adcontentparsed)]))

  header <- c(adlist[ad,c("ad.campaign.id","ad.campaign.name","objective","created.time")])
  footer <- data.frame()

  if (is.null(adcontentparsed)==TRUE) {
    footer <- rep(0,length(overalladmetricsreturned))
    names(footer) <- overalladmetricsreturned
    adoverallset <- c(unlist(header),footer)
  } else {
    for (day in 1:days) {
      for (metric in 1:length(overalladmetricsreturned)) {

        if (is.na(adcontentparsed[(overalladmetricsreturned[metric] == names(adcontentparsed))][day]) == TRUE) {
          footer[day,metric] <- 0
        } else {
          footer[day,metric] <- adcontentparsed[(overalladmetricsreturned[metric] == names(adcontentparsed))][day]
        }
      }
    }
    colnames(footer) <- overalladmetricsreturned
    adoverallset <- cbind(header,footer)
  }


  adoveralldata <- rbind(adoveralldata,adoverallset)

  colnames(adoveralldata) <- c(names(header),overalladmetricsreturned)

  # Print processing stats
  #completion <- (ad/(nrow(adlist))*100)
  #print(ad)
  #print(nrow(adoveralldata))
  #print(paste0("Finding Facebook Data for Ad Set ",ad,": ",adlist[ad,2]))
  print(paste0('Primary dataset appended: ',nrow(adoveralldata),' rows retrieved from Facebook.'))
  #print(paste(paste0(round(completion, digits = 0),"%"), "of Ads Processed."))

}



#names(adoveralldata) <- overalladmetricsreturned
print(adoveralldata)

# Exporting ---------------------------------------------------------------

adoveralldatastore <- adoveralldata
#adoveralldata <- adoveralldatastore

adoveralldata[is.na(adoveralldata)] <- ""
#adoveralldata[,-c(2:6)] <- sapply(adoveralldata[,-c(2:6)], as.numeric)

#pagedata[,-c(1:3)] <- sapply(pagedata[,-c(1:3)], as.numeric)
#postdata[,-c(1:10)] <- sapply(postdata[,-c(1:10)], as.numeric)
setwd("~")
datafolder <- "Data"
dir.create(file.path(getwd(), datafolder), showWarnings = FALSE)

# Rename columns for Excel readability
#names(pagedata) = c("Page ID", "Page Name", "Date", rev(names(metrics)))
# output Page dataset as final csv
#write.csv(pagedata, paste0(paste(page$from_name[1],"Page Data",Sys.Date(), sep=" "),".csv"),row.names=FALSE, fileEncoding='iso-8859-1')
#write.xlsx(adoveralldata, paste0(getwd(),"/",datafolder,"/",paste(adaccountname,"Ad Data",Sys.Date(), sep=" "),".xlsx"), row.names=FALSE, showNA=FALSE)

write.csv(adoveralldata, file = paste0(getwd(),"/",datafolder,"/",paste(adaccountname,"Ad Data",Sys.Date(), sep=" "),".csv"), row.names=FALSE)

#####

#####

#####


## Ad Hourly Vector Frame
admetricsreturned <- c("campaign_id","campaign_name","date_start","date_stop","hourly_stats_aggregated_by_advertiser_time_zone","spend","reach","social_reach","frequency","page_engagement","post_engagement","clicks","social_clicks","ctr","cost_per_unique_click","total_actions","cost_per_total_action","like","post_like","comment","share","link_click","photo_view","video_play","video_view")




adhourdata <- data.frame(NULL,stringsAsFactors=FALSE)


### Hourly Ad Metrics
## Loop 2: Hourly Ad Pull (Based on Loop 1)
for (ad in 1:nrow(adlist)) {
  adhourreq <- GET(paste0("https://graph.facebook.com/v2.6/",adlist[ad,1],"/insights?fields=",paste(admetrics,collapse=","),"&breakdowns=hourly_stats_aggregated_by_advertiser_time_zone"), config(token = fb_oauth))
  adhourlydata <- content(adhourreq)
  adhourlycontent <- unlist(adhourlydata$data, use.names=TRUE, recursive=TRUE)

  completion <- (ad/(nrow(adlist))*100)

  print(paste('Finding Facebook Ad Data for',adlist[ad,2]))
  print(paste(paste0(round(completion, digits = 0),"%"), "Complete."))


  if (length(adhourlycontent) > 0) {
    names(adhourlycontent)[(names(adhourlycontent) == ("actions.value"))] <- adhourlycontent[(names(adhourlycontent) == ("actions.action_type"))]
    adhourlycontent <- adhourlycontent[-which((names(adhourlycontent) == ("actions.action_type")))]

    hours <- adhourlycontent[names(adhourlycontent) == "hourly_stats_aggregated_by_advertiser_time_zone"]

    adhourlysetdata <- data.frame(NULL, stringsAsFactors = FALSE)

    for (hour in 1:length(hours)){

      if (hour <= 1) {
        startindex = 1
        endindex = which(adhourlycontent == hours[(hour)])
      } else {
        startindex = which(adhourlycontent == hours[(hour-1)])+1
        endindex = which(adhourlycontent == hours[(hour)])
      }

      #print(paste("Set", hour))
      #print(length(adhourlycontent[startindex:endindex]))
      #print(adhourlycontent[startindex:endindex])

      adhourlyset <- adhourlycontent[startindex:endindex]
      adhourlyrow <- adhourlyset[match(admetricsreturned,names(adhourlyset))]
      adhourlysetdata <- rbind(adhourlyrow,adhourlysetdata)

      #print(adhourlyrow)

    }
    names(adhourlysetdata) <- admetricsreturned
    #print(tail(adhourlysetdata))

    adhourdata <- rbind(adhourlysetdata,adhourdata)

    names(adhourdata) <- admetricsreturned
  } else {
    #next()
  }


}

adstart <- ad

#Hourly Admetrics
for (ad in 1:nrow(adlist)) {
  adhourreq <- GET(paste0("https://graph.facebook.com/v2.6/",adlist[ad,1],"/insights?fields=",paste(admetrics,collapse=","),"&breakdowns=hourly_stats_aggregated_by_advertiser_time_zone"), config(token = fb_oauth))
  adhourlydata <- content(adhourreq)
  adhourlycontent <- unlist(adhourlydata$data, use.names=TRUE, recursive=TRUE)


  if (length(adhourlycontent) > 0) {
    names(adhourlycontent)[(names(adhourlycontent) == ("actions.value"))] <- adhourlycontent[(names(adhourlycontent) == ("actions.action_type"))]
    adhourlycontent <- adhourlycontent[-which((names(adhourlycontent) == ("actions.action_type")))]

    hours <- adhourlycontent[names(adhourlycontent) == "hourly_stats_aggregated_by_advertiser_time_zone"]

    adhourlysetdata <- data.frame(NULL, stringsAsFactors = FALSE)

    for (hour in 1:length(hours)){

      if (hour <= 1) {
        startindex = 1
        endindex = which(adhourlycontent == hours[(hour)])
      } else {
        startindex = which(adhourlycontent == hours[(hour-1)])+1
        endindex = which(adhourlycontent == hours[(hour)])
      }

      #print(paste("Set", hour))
      #print(length(adhourlycontent[startindex:endindex]))
      #print(adhourlycontent[startindex:endindex])

      adhourlyset <- adhourlycontent[startindex:endindex]
      adhourlyrow <- adhourlyset[match(admetricsreturned,names(adhourlyset))]
      adhourlysetdata <- rbind(adhourlyrow,adhourlysetdata)

      #print(adhourlyrow)

    }
    names(adhourlysetdata) <- admetricsreturned
    #print(tail(adhourlysetdata))

    adhourdata <- rbind(adhourlysetdata,adhourdata)

    names(adhourdata) <- admetricsreturned
  } else {
    next()
  }
}


### Segmented Ad Metrics
## Loop 3: Segmented Ad Pull (Based on Loop 1)
ad <-  0

admetricsreturned <- c("campaign_id","campaign_name","date_start","date_stop","gender","age","spend","reach","social_reach","frequency","page_engagement","post_engagement","clicks","social_clicks","ctr","cost_per_unique_click","total_actions","cost_per_total_action","like","post_like","comment","share","link_click","photo_view","video_play","video_view")

### PICK UP FROM HERE; THIS LOOP ONLY GETS TO 5% ###


adsegmentsetdata <- data.frame(NULL,stringsAsFactors=FALSE)

for (ad in 1:nrow(adlist)) {
  adsegmentreq <- GET(paste0("https://graph.facebook.com/v2.6/",adlist[ad,1],"/insights?fields=",paste(admetrics,collapse=","),"&breakdowns=age,gender"), config(token = fb_oauth))
  adsegmentdata <- content(adsegmentreq)
  adsegmentcontent <- unlist(adsegmentdata$data, use.names=TRUE, recursive=TRUE)

  completion <- (ad/(length(initialcontent$data))*100)
  print(paste(paste0(round(completion, digits = 0),"%"), "Complete."))

  if (length(adsegmentcontent) > 0) {
    names(adsegmentcontent)[(names(adsegmentcontent) == ("actions.value"))] <- adsegmentcontent[(names(adsegmentcontent) == ("actions.action_type"))]
    adsegmentcontent <- adsegmentcontent[-which((names(adsegmentcontent) == ("actions.action_type")))]

    ages <- unique(adsegmentcontent[names(adsegmentcontent) == "age"])
    genders <- unique(adsegmentcontent[names(adsegmentcontent) == "gender"])

    adsegmentsetdata <- data.frame(NULL, stringsAsFactors = FALSE)

    for (age in 1:length(ages)) {

      if (age <= 1) {
        startindex = 1
        endindex = which(adsegmentcontent == ages[(age)])[3]+1
      } else {
        startindex = which(adsegmentcontent == ages[(age-1)])[3]+1
        endindex = which(adsegmentcontent == ages[(age)])[3]+1
      }


      adsegmentset <- adsegmentcontent[startindex:endindex]


      for (gender in 1:length(genders)) {

        if (gender <= 1) {
          startgenderindex = 1
          endgenderindex = which(adsegmentset == genders[(gender)])
        } else {
          startgenderindex = which(adsegmentset == genders[(gender-1)])+1
          endgenderindex = which(adsegmentset == genders[(gender)])
        }


        adsegmentrow <- adsegmentset[match(admetricsreturned,names(adsegmentset))]
        adsegmentsetdata <- rbind(adsegmentrow,adsegmentsetdata)
      }
    }
  } else {
    next()
  }
}

names(adsegmentdata) <- admetricsreturned

# Placement and Device
adplacereq <- GET(paste0("https://graph.facebook.com/v2.6/",adlist[ad,1],"/insights?fields=",paste(admetrics,collapse=","),"&breakdowns=placement,impression_device"), config(token = fb_oauth))

# Age and Gender
adreq2 <- GET(paste0("https://graph.facebook.com/v2.6/",adlist[ad,1],"/insights?fields=",paste(admetrics,collapse=","),"&breakdowns=age,gender"), config(token = fb_oauth))
adcontent <- content(adreq)
adcontent1 <- unlist(adcontent$data, use.names=TRUE, recursive=TRUE)

# Clean out the NA's

# Exporting ---------------------------------------------------------------

adoveralldata[is.na(adoveralldata)] <- ""

adoveralldata[,-c(2:6)] <- sapply(adoveralldata[,-c(2:6)], as.numeric)

#pagedata[,-c(1:3)] <- sapply(pagedata[,-c(1:3)], as.numeric)
#postdata[,-c(1:10)] <- sapply(postdata[,-c(1:10)], as.numeric)
setwd("~")
datafolder <- "Data"
dir.create(file.path(getwd(), datafolder), showWarnings = FALSE)

# Rename columns for Excel readability
#names(pagedata) = c("Page ID", "Page Name", "Date", rev(names(metrics)))
# output Page dataset as final csv
#write.csv(pagedata, paste0(paste(page$from_name[1],"Page Data",Sys.Date(), sep=" "),".csv"),row.names=FALSE, fileEncoding='iso-8859-1')
write.xlsx(adoveralldata, paste0(getwd(),"/",datafolder,"/",paste(adaccountname,"Ad Data",Sys.Date(), sep=" "),".xlsx"), row.names=FALSE, showNA=FALSE)

# Rename columns for Excel readability
#names(postdata) = c("Page ID", "Page Name", "Created",  "Datetime", "Month", "Day", "Post ID", "Link", "Type", "Message", "Likes", "Comments", "Shares", rev(names(postmetrics)))
# output Post dataset as final Excel
#write.csv(postdata, paste0(paste(page$from_name[1],"Post Data",Sys.Date(), sep=" "),".csv"),row.names=FALSE)
