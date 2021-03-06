#' @rdname Spectra
#'
#' @section Constructor:
#'
#' New [Spectra] can be created with the `Spectra(...)` function
#' where `...` can either be a single [Spectrum-class] object or a `list` of
#' `Spectrum` objects ([Spectrum1-class] and/or [Spectrum2-class]).
#'
#' @param ... For `Spectra`: [Spectrum-class] object(s) or a `list` of
#'     [Spectrum-class] objects.
#'     For all other methods optional arguments passed along.
#'
#' @param elementMetadata For `Spectra`: [DataFrame] with optional information
#'     that should be added as metadata information (`mcols`) to the object.
#'     The number of rows has to match the number of [Spectrum-class] objects,
#'     each row is expected to represent additional metadata information for
#'     one spectrum.
#'
#' @author Johannes Rainer
#'
#' @md
#'
#' @examples
#' 
#' ## Create from Spectrum objects
#' sp1 <- new("Spectrum1", mz = c(1, 2, 4), intensity = c(4, 5, 2))
#' sp2 <- new("Spectrum2", mz = c(1, 2, 3, 4), intensity = c(5, 3, 2, 5),
#'     precursorMz = 2)
#'
#' spl <- Spectra(sp1, sp2)
#' spl
#' spl[[1]]
#'
#' ## Add also metadata columns
#' mcols(spl)$id <- c("a", "b")
#' mcols(spl)
#'
#' ## Create a Spectra with metadata
#' spl <- Spectra(sp1, sp2, elementMetadata = DataFrame(id = c("a", "b")))
#'
#' mcols(spl)
#' mcols(spl)$id
Spectra <- function(..., elementMetadata = NULL) {
    args <- list(...)
    if (length(args) == 1L && is.list(args[[1L]]))
        args <- args[[1L]]
    new("Spectra", listData = args, elementMetadata = elementMetadata)
}

.show_Spectra <- function(x, margin = "", print.classinfo = FALSE) {
    cat("Spectra with", length(x), "spectra and", length(mcols(x)),
        "metadata column(s):\n")
    if (length(x)) {
        out <- S4Vectors:::makePrettyMatrixForCompactPrinting(
                               x, .make_naked_matrix_from_Spectra)
        if (print.classinfo) {
            .COL2CLASS <- c(msLevel = "integer", rtime = "numeric",
                            peaksCount = "integer")
            classinfo <- S4Vectors:::makeClassinfoRowForCompactPrinting(
                                         x, .COL2CLASS)
            out <- rbind(classinfo, out)
        }
        if (nrow(out))
            rownames(out) <- paste0(margin, rownames(out))
        print(out, quote = FALSE, right = TRUE, max = length(out))
    }
}

.short_spectrum_info <- function(x) {
    c(msLevel = x@msLevel, rtime = ifelse(length(x@rt), x@rt, NA_real_),
      peaksCount = peaksCount(x))
}

.make_naked_matrix_from_Spectra <- function(x) {
    x_len <- length(x)
    mcls <- mcols(x, use.names = FALSE)
    x_mcls_len <- if (is.null(mcls)) 0L else ncol(mcls)
    res <- do.call(rbind, lapply(x, .short_spectrum_info))
    res <- apply(res, 2, format, digits = 6)
    if (!is.matrix(res))
        res <- t(as.matrix(res))
    res <- res[, c("msLevel", "rtime", "peaksCount"), drop = FALSE]
    if (x_mcls_len > 0) {
        tmp <- do.call(data.frame, c(lapply(mcls, showAsCell),
                                     list(check.names = FALSE)))
        res <- cbind(res, `|` = rep.int("|", x_len), as.matrix(tmp))
    }
    res
}
