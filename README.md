# 📊 Image-to-JSON Balance Sheet Extractor

This R project allows you to extract structured financial data from balance sheet images using OpenAI's Vision API (`gpt-4o-mini`). It reads one or multiple image files (local or URLs), sends them to the API, and returns a minified JSON with key fields.

---

## ✨ Features

- ✅ Supports multiple images at once
- ✅ Works with local files (`.jpg`, `.jpeg`, `.png`) or URLs
- ✅ Outputs clean, minified JSON
- ✅ Customizable prompt and image detail setting
- ✅ Detects missing fields 

---

## 📦 Requirements

- R >= 4.1
- OpenAI API key
- The following R packages:
  - `httr2`
  - `jsonlite`
  - `base64enc`
  - `tools`

Install them with:

```r
install.packages(c("httr2", "jsonlite", "base64enc", "tools"))
```
