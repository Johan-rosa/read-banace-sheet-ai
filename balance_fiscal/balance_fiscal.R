library(httr2)
library(jsonlite)
library(base64enc)
library(tools)
library(purrr)

encode_image_to_base64 <- function(path) {
  mime <- switch(
    file_ext(path),
    jpg = "image/jpeg",
    jpeg = "image/jpeg",
    png = "image/png",
    stop("Only .jpg, .jpeg, and .png files are supported.")
  )
  dataURI(file = path, mime = mime)
}

openai_read_balance <- function(
    api_key,
    images,
    question = "
      Extract the data from this image in JSON format. Provide plain text only, without any additional 
      content such as Markdown formatting.
      
      Read the numbers from the first four columns and create a code in the format 2xxxx, 
      where 2 is followed by the digits from the first four columns concatenated. If a column is empty, 
      do not add a digit for it. Ignore the sixth column, it's not needed.
      
      The output should be a list of objects with two fields: code (refult first 4 columns) and devengado (5th column).
  ",
  model = "gpt-4o-mini",
  max_tokens = 1000,
  detail = "low"
) {
  if (length(images) < 1) stop("At least one image path or URL is required.")
  
  content_list <- list(list(type = "text", text = question))
  
  image_blocks <- lapply(images, function(img) {
    url <- if (grepl("^https?://", img)) img else encode_image_to_base64(img)
    list(
      type = "image_url",
      image_url = list(
        url = url,
        detail = detail
      )
    )
  })
  
  body <- list(
    model = model,
    messages = list(list(
      role = "user",
      content = c(content_list, image_blocks)
    )),
    max_tokens = max_tokens
  )
  
  resp <- request("https://api.openai.com/v1/chat/completions") |>
    req_method("POST") |>
    req_headers(
      "Authorization" = paste("Bearer", api_key),
      "Content-Type" = "application/json"
    ) |>
    req_body_json(body) |>
    req_perform()
  
  out <- resp_body_json(resp)
  return(out$choices[[1]]$message$content)
}

balances <- list.files("balance_fiscal/", pattern = "\\).png", full.names = TRUE)

responses <- 
map(
  balances,
  \(img) {
    openai_read_balance(
      api_key = Sys.getenv("OPENAI_API_KEY"),
      images = img,
      detail = "high"
    ) |>
    jsonlite::fromJSON()
  }
)
