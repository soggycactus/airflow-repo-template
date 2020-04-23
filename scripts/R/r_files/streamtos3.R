library(biggr)
library(redditor)

tryCatch({
  con = postgres_connector()
  on.exit(dbDisconnect(conn = con))
  nowtime <- as.character(now(tzone = 'UTC'))
  nowtime <- str_replace(nowtime, ' ', '_')
  now_time_csv <- glue('stream_{nowtime}.csv')
  now_time_zip <- glue('stream_{nowtime}.zip')
  fs::file_move(path = 'stream.csv', new_path = now_time_csv)
  data <- read_csv(now_time_csv, col_names = FALSE)
  colnames(data) <- c("author", "author_fullname", "author_patreon_flair", "author_premium", 
                      "body", "can_gild", "can_mod_post", "controversiality", "created", 
                      "created_utc", "depth", "downs", "fullname", "id", "is_root", 
                      "is_submitter", "link_id", "name", "no_follow", "parent_id", 
                      "permalink", "score", "submission", "subreddit", "subreddit_id", 
                      "total_awards_received", "ups", "time_gathered_utc")
  dbAppendTable(conn = con, name = 'streamall', value = data)
  zip(zipfile = now_time_zip, files = now_time_csv)
  s3_upload_file(bucket = 'reddit-dumps', from = now_time_zip, to = now_time_zip, make_public = TRUE)
  file_size <- as.character(fs::file_info(now_time_csv)$size)
  file_delete(now_time_csv)
  file_delete(now_time_zip)
}, error = function(e) {
  file_size <- as.character(fs::file_info(now_time_csv)$size)
  sns_send_message(phone_number = Sys.getenv('MY_PHONE'), message = 'Something went wrong') 
})
