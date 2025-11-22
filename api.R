library(plumber)
library(readr)
library(C50)
library(jsonlite)

# ===============================
# 1. LOAD MODEL & TEMPLATE
# ===============================
MODEL_PATH <- "model_c50_new.rds"
TEMPLATE_PATH <- "template_row.csv"

# Load model
if (!file.exists(MODEL_PATH)) stop("Model file not found: ", MODEL_PATH)
model <- readRDS(MODEL_PATH)

# Load template row (to maintain factor levels)
if (!file.exists(TEMPLATE_PATH)) stop("Template file not found: ", TEMPLATE_PATH)
template <- read_csv(TEMPLATE_PATH, show_col_types = FALSE)

# Remove label column if present
label_cols <- intersect(names(template), c("kelayakan", "label", "target"))
if (length(label_cols) > 0) {
  template <- template[, setdiff(names(template), label_cols), drop = FALSE]
}

# ===============================
# 2. FUNCTION: fill template safely
# ===============================
fill_template <- function(template_row, newvals) {
  out <- template_row

  for (nm in names(newvals)) {
    if (!nm %in% names(out)) next
    val <- newvals[[nm]]

    if (is.numeric(out[[nm]])) {
      out[[nm]] <- as.numeric(val)
    } else {
      lvls <- unique(as.character(template[[nm]]))
      out[[nm]] <- factor(as.character(val), levels = lvls)
    }
  }

  return(as.data.frame(out))
}

# ===============================
# 3. API DEFINITION
# ===============================

#* @get /health
function() {
  list(status = "ok", model_loaded = TRUE)
}

#* @post /predict
#* @post /predict
function(req, res) {
  json_txt <- req$postBody
  if (is.raw(json_txt)) json_txt <- rawToChar(json_txt)

  body <- tryCatch(fromJSON(json_txt), error = function(e) NULL)

  if (is.null(body)) {
    res$status <- 400
    return(list(error = "JSON body tidak valid"))
  }

  newrow <- fill_template(template[1, ], body)

  # ============ PREDIKSI ============
  pred <- predict(model, newrow)
  predicted <- as.character(pred)[1] # FIX 1
  predicted <- trimws(predicted) # FIX 2

  # ============ PROBABILITAS ============
  prob <- tryCatch(predict(model, newrow, type = "prob"), error = function(e) NULL)

 # Probabilitas (jika ada)
prob <- NULL
try(prob <- predict(model, newrow, type = "prob"), silent = TRUE)

prob_list <- NULL
if (!is.null(prob)) {
  prob_numeric <- as.numeric(prob[1, ])     # selalu array numeric
  names(prob_numeric) <- colnames(prob)     # beri nama 0 dan 1
  prob_list <- as.list(prob_numeric)        # convert ke list numerik
}

return(list(
  predicted = predicted,
  probabilities = prob_list
))


  return(list(
    predicted = predicted,
    probabilities = prob_list
  ))
}


# ===============================
