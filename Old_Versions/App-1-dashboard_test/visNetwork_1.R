nb <- 10
nodes <- data.frame(id = 1:nb, label = paste("Label", 1:nb),
                    group = sample(LETTERS[1:3], nb, replace = TRUE), value = 1:nb,
                    title = paste0("<p>", 1:nb,"<br>Tooltip !</p>"), stringsAsFactors = FALSE)

edges <- data.frame(from = c(8,2,7,6,1,8,9,4,6,2),
                    to = c(3,7,2,7,9,1,5,3,2,9),
                    value = rnorm(nb, 10), label = paste("Edge", 1:nb),
                    title = paste0("<p>", 1:nb,"<br>Edge Tooltip !</p>"))

visNetwork(nodes, edges, height = "500px", width = "100%") %>% 
  visOptions(manipulation = TRUE) %>%
  visLayout(randomSeed = 123)