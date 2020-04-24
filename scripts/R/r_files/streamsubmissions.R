library(redditor)
library(biggr)

praw = reticulate::import('praw')

reddit_con = praw$Reddit(client_id=Sys.getenv('REDDIT_CLIENT'),
                         client_secret=Sys.getenv('REDDIT_AUTH'),
                         user_agent=Sys.getenv('USER_AGENT'),
                         username=Sys.getenv('USERNAME'),
                         password=Sys.getenv('PASSWORD'))

sns_send_message(phone_number=Sys.getenv('MY_PHONE'), message='Running gathering')

# Do something with comments
parse_comments_wrapper <- function(x) {
  submission_value <- parse_meta(x)
  write_csv(x = submission_value, path = 'streamsubmissions.csv', append = TRUE)
  print(now(tzone = 'UTC') - submission_value$created_utc)
}

stream_submission(reddit = reddit_con,
                  subreddit =  'all',
                  callback =  parse_comments_wrapper)
