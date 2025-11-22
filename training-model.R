# ===============================================================
# TRAINING MODEL DECISION TREE C5.0 UNTUK KLASIFIKASI KELAYAKAN UKT
# ===============================================================

library(readr)
library(dplyr)
library(C50)

# ===============================================================
# 1. LOAD DATASET
# ===============================================================
# Dataset final yang sudah melalui proses pembersihan & balancing
df <- read_csv("dataset_c50_GEN5_FINAL.csv", show_col_types = FALSE)

# ===============================================================
# 2. KONVERSI VARIABLE KATEGORIK MENJADI FAKTOR
# ===============================================================
df$kelayakan <- as.factor(df$kelayakan)
df$pekerjaan <- as.factor(df$pekerjaan)
df$status_anak <- as.factor(df$status_anak)
df$tempat_tinggal <- as.factor(df$tempat_tinggal)

# ===============================================================
# 3. PEMBAGIAN DATA (TRAINING 80%, TESTING 20%)
# ===============================================================
set.seed(123) # agar hasil bisa direplikasi
train_index <- sample(1:nrow(df), size = 0.8 * nrow(df))

train <- df[train_index, ]
test <- df[-train_index, ]

# ===============================================================
# 4. PEMBANGUNAN MODEL DECISION TREE C5.0
# ===============================================================
model_c50 <- C5.0(
    x = train %>% select(-kelayakan), # fitur
    y = train$kelayakan, # label
    trials = 1 # tree tunggal (tanpa boosting)
)

# ===============================================================
# 5. MELIHAT STRUKTUR MODEL
# ===============================================================
summary(model_c50)

# ===============================================================
# 6. PREDIKSI TERHADAP DATA TEST
# ===============================================================
pred <- predict(model_c50, test)

# CONFUSION MATRIX (Sederhana)
conf_mat <- table(Aktual = test$kelayakan, Prediksi = pred)
print(conf_mat)

# Hitung akurasi sederhana
accuracy <- sum(diag(conf_mat)) / sum(conf_mat)
cat("Akurasi model:", accuracy, "\n")

# ===============================================================
# 7. SIMPAN MODEL UNTUK DIGUNAKAN DI API
# ===============================================================
saveRDS(model_c50, "model_c50_new.rds")

cat("\n=====================================================\n")
cat("Model C5.0 berhasil dilatih dan disimpan sebagai model_c50_new.rds\n")
cat("=====================================================\n")
