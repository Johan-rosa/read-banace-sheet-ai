library(httr2)
library(jsonlite)
library(base64enc)
library(tools)

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
    Extract the data from this image and return it as a compact, valid JSON object.
    
    The response must be plain text only — no code blocks, no Markdown, no extra explanation.
    The output must be ready to be parsed by a JSON parser.
    
    Include the following fields:
    - date
    - empresa
    - total_activos
    - total_pasivos
    - capital_de_trabajo
    - utilidad_neta
    - gastos
    - ventas
    
    If any value is missing in the image, return it as an empty string.
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

response <- openai_read_balance(
  api_key = Sys.getenv("OPENAI_API_KEY"),
  images = c("Balance O7 - 2025-04-03.jpeg", "balance-parqueo.jpeg"),
  detail = "high"
)

jsonlite::fromJSON(response)
