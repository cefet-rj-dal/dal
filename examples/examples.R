if (!exists("repos_name"))
  repos_name <<- getOption("repos")[1]

setrepos <- function(repos=repos) {
  repos_name <<- repos 
}

loadlibrary <- function(packagename) 
{
  if (!require(packagename, character.only = TRUE))
  {
    install.packages(packagename, repos=repos_name, dep=TRUE, verbose = FALSE)
    require(packagename, character.only = TRUE)
  }
}

load_dal <- function() 
{
  if (!require("dal", character.only = TRUE))
  {
    library(devtools) 
    
    devtools::install_github("cefet-rj-dal/dal", force=TRUE)
    
    library(dal)
  }
}