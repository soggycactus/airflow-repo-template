library(biggr)

configure_aws(
  aws_access_key_id = Sys.getenv('AWS_ACCESS'), 
  aws_secret_access_key = Sys.getenv('AWS_SECRET'), 
  default.region = Sys.getenv('AWS_REGION')
)