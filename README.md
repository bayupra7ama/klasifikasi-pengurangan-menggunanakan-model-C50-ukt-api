

---

# **README — API Klasifikasi Kelayakan UKT (Model C5.0)**

Repositori ini berisi API untuk melakukan prediksi *Kelayakan UKT* menggunakan model machine learning **C5.0**. API ini dibangun menggunakan bahasa **R**, dilengkapi dengan model terlatih, dataset, skrip training, evaluasi, dan file untuk menjalankan server API.

---

## **📁 Struktur Folder**

Berikut adalah file–file utama dalam project:

```
├── api.R                      # Definisi endpoint API
├── start.R                    # Script untuk menjalankan API
├── model_c50_new.rds          # Model C5.0 yang sudah dilatih
├── dataset_c50_GEN5_FINAL.csv # Dataset training final
├── training-model.R           # Script untuk melatih model
├── evaluate_pretty.R          # Script evaluasi & confusion matrix
├── model_metrics.csv          # Hasil metrik model
├── template_row.csv           # Contoh struktur input data
├── confusion_matrix_aesthetic.png # Visualisasi confusion matrix
```

---

## **📦 Dependencies**

Pastikan package berikut sudah terinstall:

```r
install.packages(c(
  "C50", "plumber", "jsonlite", 
  "readr", "dplyr", "ggplot2",
  "caret", "e1071"
))
```

---

## **🚀 Menjalankan API**

### **1. Pastikan semua file berada dalam satu folder proyek**

Pastikan `model_c50_new.rds` tidak dipindah dari posisi default yang digunakan `api.R`.

### **2. Jalankan API**

Jalankan melalui terminal:

```bash
Rscript start.R
```

Atau langsung lewat R console:

```r
source("start.R")
```

API biasanya berjalan di:

```
http://127.0.0.1:5000
```

(Tergantung port yang kamu set di `start.R`)

---

## **🔮 Endpoint Prediksi**

### **Endpoint**

`POST /predict`

### **Content-Type**

`application/json`

### **Contoh Input**

```json
{
  "semester": 6,
  "ipk": 3.45,
  "penghasilan_orangtua": 2500000,
  "tanggungan_orangtua": 3,
  "score_rumah": 0.72
}
```

### **Contoh Curl**

```bash
curl -X POST "http://127.0.0.1:8000/predict" \
-H "Content-Type: application/json" \
-d '{
  "semester": 6,
  "ipk": 3.45,
  "penghasilan_orangtua": 2500000,
  "tanggungan_orangtua": 3,
  "score_rumah": 0.72
}'
```

### **Contoh Output**

```json
{
  "predicted": "LAYAK",
  "probability": {
    "LAYAK": 0.87,
    "TIDAK_LAYAK": 0.13
  },
  "model_version": "model_c50_new.rds"
}
```

---

## **📊 Evaluasi Model**

* Script evaluasi ada pada: `evaluate_pretty.R`
* Hasil metrik disimpan di: `model_metrics.csv`
* Confusion matrix berada di: `confusion_matrix_aesthetic.png`

---

## **🔁 Retrain Model**

Untuk melatih ulang model:

1. Edit / ganti dataset pada `dataset_c50_GEN5_FINAL.csv`
2. Jalankan:

```r
source("training-model.R")
```

3. Model baru akan tersimpan sebagai:

```
model_c50_new.rds
```

4. Restart API:

```bash
Rscript start.R
```

---

## **🛡️ Catatan Deployment**

* Tambahkan validasi input pada API.
* Pastikan preprocessing input sama dengan training.
* Gunakan port environment jika deploy ke server.
* Disarankan dibungkus Docker untuk produksi.

---


