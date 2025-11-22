library(readr)
library(C50)
library(caret)
library(ggplot2)
library(reshape2)
library(scales)

# ===============================
# 1. Load Data & Model
# ===============================
df <- read_csv("dataset_c50_GEN5_FINAL.csv", show_col_types = FALSE)
model <- readRDS("model_c50_new.rds")

df$kelayakan       <- as.factor(df$kelayakan)
df$pekerjaan       <- as.factor(df$pekerjaan)
df$status_anak     <- as.factor(df$status_anak)
df$tempat_tinggal  <- as.factor(df$tempat_tinggal)

set.seed(123)
train_index <- sample(1:nrow(df), 0.8 * nrow(df))

train <- df[train_index, ]
test  <- df[-train_index, ]


# ===============================
# 2. Predict Test Set
# ===============================
pred <- predict(model, test)

# ===============================
# 3. Confusion Matrix
# ===============================
cm <- confusionMatrix(pred, test$kelayakan, positive = "1")
print(cm)

cm_table <- as.data.frame(cm$table)
colnames(cm_table) <- c("Actual", "Predicted", "Freq")

# ===============================
# 4. AESTHETIC CONFUSION MATRIX PLOT
# ===============================
p <- ggplot(data = cm_table, aes(x = Predicted, y = Actual, fill = Freq)) +
  geom_tile(color = "white", linewidth = 1.2) +
  
  # angka di dalam kotak
  geom_text(aes(label = Freq),
            color = "white",
            fontface = "bold",
            size = 7) +
  
  # warna aesthetic biru gradient
  scale_fill_gradient(
    low = "#6EC6FF",   # biru soft
    high = "#003B73"   # navy gelap
  ) +
  
  # tema elegan
  theme_minimal(base_size = 16) +
  ggtitle("Confusion Matrix - Model Decision Tree C5.0") +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold", size = 18),
    axis.title.x = element_text(face = "bold"),
    axis.title.y = element_text(face = "bold"),
    legend.position = "right"
  ) +
  labs(x = "Predicted", y = "Actual", fill = "Jumlah")

# Simpan gambar HD
ggsave("confusion_matrix_aesthetic.png", p, width = 9, height = 7, dpi = 300)

# ===============================
# 5. Calculate Metrics
# ===============================
accuracy  <- cm$overall["Accuracy"]
precision <- cm$byClass["Precision"]
recall    <- cm$byClass["Recall"]
f1        <- cm$byClass["F1"]

metrics <- data.frame(
  Metric = c("Accuracy", "Precision", "Recall", "F1-Score"),
  Value  = round(c(accuracy, precision, recall, f1), 4)
)

print(metrics)

write.csv(metrics, "model_metrics.csv", row.names = FALSE)
