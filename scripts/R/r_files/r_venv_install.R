devtools::install_github('fdrennan/redditor')
devtools::install_github('fdrennan/biggr')

library(redditor)
library(biggr)

new_glue <- function(string) {
  glue(string, .open = "--", .close = "--")
}

VIRTUALENV_NAME <- 'redditor'
virtualenv_install(envname = VIRTUALENV_NAME, packages = 'praw')
install_python(method = 'virtualenv', envname = VIRTUALENV_NAME)

system(
  new_glue('echo RETICULATE_PYTHON=${HOME}/.virtualenvs/--VIRTUALENV_NAME--/bin/python >> .Renviron')
)


# configure_aws(
#   aws_access_key_id = Sys.getenv('AWS_SECRET'), 
#   aws_secret_access_key = Sys.getenv('AWS_ACCESS'), 
#   default.region = Sys.getenv('AWS_REGION')
# )