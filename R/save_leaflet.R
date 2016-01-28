library(htmltools)

saveas <- function(map, file){
  class(map) <- c("saveas",class(map))
  attr(map,"filesave")=file
  map
}

print.saveas <- function(x, ...){
  class(x) = class(x)[class(x)!="saveas"]
  htmltools::save_html(x, file=attr(x,"filesave"))
}