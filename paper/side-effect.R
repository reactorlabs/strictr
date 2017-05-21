f1 <- function(x = 2, y = 3) {
   print(x)
   f2(z = { x <- "Hello" })
   print(x)
}
