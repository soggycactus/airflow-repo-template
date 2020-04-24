library(biggr)
library(redditor)

tryCatch({
  con = postgres_connector()
  on.exit(dbDisconnect(conn = con))
  nowtime <- as.character(now(tzone = 'UTC'))
  nowtime <- str_replace(nowtime, ' ', '_')
  now_time_csv <- glue('stream_submissions_{nowtime}.csv')
  now_time_zip <- glue('stream_submissions_{nowtime}.zip')
  fs::file_move(path = 'streamsubmissions.csv', new_path = now_time_csv)
  data <- read_csv(now_time_csv, col_names = FALSE)
  colnames(data) <- c("author", "author_fullname", "author_premium", "author_patreon_flair", 
                      "can_gild", "can_mod_post", "clicked", "comment_limit", "created", 
                      "created_utc", "downs", "edited", "fullname", "gilded", "hidden", 
                      "hide_score", "id", "is_crosspostable", "is_meta", "is_original_content", 
                      "is_reddit_media_domain", "is_robot_indexable", "is_self", "is_video", 
                      "locked", "media_only", "name", "no_follow", "over_18", "permalink", 
                      "pinned", "quarantine", "saved", "selftext", "shortlink", "subreddit", 
                      "subreddit_id", "subreddit_name_prefixed", "subreddit_subscribers", 
                      "subreddit_type", "thumbnail", "title", "url")
  dbAppendTable(conn = con, name = 'stream_submissions_all', value = data)
  # zip(zipfile = now_time_zip, files = now_time_csv)
  # s3_upload_file(bucket = 'reddit-dumps', from = now_time_zip, to = now_time_zip, make_public = TRUE)
  # file_size <- as.character(fs::file_info(now_time_csv)$size)
  file_delete(now_time_csv)
  file_delete(now_time_zip)
}, error = function(e) {
  # file_size <- as.character(fs::file_info(now_time_csv)$size)
  sns_send_message(phone_number = Sys.getenv('MY_PHONE'), message = 'Something went wrong') 
})
