#' Generates mixed populuation
#'
#' @param nb.inds number of (unrelated) individuals per 'deme'
#' @param haplos haplotype bed matrix
#' @param population vector giving the population of origin of each haplotype 
#' @param kinship Logical. TRUE to get kinship matrix computed from IBD sharing.
#' @param fraternity Logical. TRUE to get fraternity matrix computed from IBD sharing.
#' @param ... Additional parameters give the probability of drawing a tile in each population.
#' 
#' @details The number of 'demes' is given by the length of the vectors of probabilities.
#' There will be `nb.inds` individuals on each deme. `nb.inds` could be a vector giving 
#' different number of individuals for each deme.
#' 
#' @return a list width components `bed`, `kinship` and `fraternity` (if applicable).
#' The bed matrix will have extra columns in @ped giving the probabilities used for the deme of the individuals.
#' @export
#'
#' @examples #' # installs KGH is not already installed
#' if(!require("KGH")) install.packages("KGH", repos="https://genostats.github.io/R/")
#' # loads a bed matrix of 1006 european haplotypes
#' filepath <- system.file("extdata", "1KG_haplos.bed", package = "KGH")
#' H <- read.bed.matrix(filepath)
#' 
#' # 100 individuals x 11 demes with different proportions of TSI / IBS
#' p <- seq(0, 1, length = 11)
#' x.1 <- mix.pop(100, H, TSI = p, IBS = 1 - p)
#' # let's do a quick PCA
#' z <- LD.thin(select.snps(x.1$bed, maf > 0.05), 0.1)
#' K <- GRM(z)
#' par(mfrow=c(1,2))
#' plot( eigen(K)$vectors, col = hsv(x.1$bed@ped$TSI) )
#' 
#' # to generate a mixture of 4 populations on a 11 x 11 square
#' f <- function(x,y) c( (1-y)*c(x, 1-x), y*c(x, 1-x))
#' N <- 11
#' t <- rep(seq(0,1,length=N), N); u <- rep(seq(0,1,length=N), each = N)
#' pp <- t(mapply(f, t, u))
#' x.2 <- mix.pop(10, H, TSI = pp[,1], IBS = pp[,2], CEU = pp[,3], FIN = pp[,4])
#' # PCA
#' z <- LD.thin(select.snps(x.2$bed, maf > 0.05), 0.1)
#' K <- GRM(z)
#' plot( eigen(K)$vectors, col = rgb(x.2$bed@ped$TSI, x.2$bed@ped$IBS, x.2$bed@ped$CEU) )

mix.pop <- function(nb.inds, haplos, population = haplos@ped$population, tile.length = 20, kinship = FALSE, fraternity = FALSE, ...) {
  if(length(population) != nrow(haplos))
    stop("Dimensions mismatch")
  probs <- list(...)
  proba.haplos <- make.proba.haplos(population, probs)
  nb.inds <- rep_len(nb.inds, ncol(proba.haplos))
  x <- make.inds(nb.inds, haplos, proba.haplos, tile.length, kinship, fraternity)
  for(a in names(probs)) {
    x$bed@ped[[a]] <- as.vector(mapply(rep, probs[[a]], nb.inds))
  }
  x
}

