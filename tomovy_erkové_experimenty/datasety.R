library(here)
library(dplyr)

orcl_all <- read.csv(here("../data/ORCL_all_orig.csv")) %>% 
  rename(date = Date, 
         open = Open, 
         high = High, 
         low = Low, 
         close = Close, 
         adjusted_close = Adj.Close, 
         volume = Volume
         ) %>% 
  mutate(id = row_number()) %>% 
  select(id, everything())

total_rows <- nrow(orcl_all)
split_point <- floor(3/4 * total_rows)

orcl_train <- orcl_all[1:split_point, ]
orcl_test <- orcl_all[(split_point + 1):total_rows, ]

write.csv(orcl_all, here("../data/ORCL_all.csv"))
write.csv(orcl_train, here("../data/ORCL_train.csv"))
write.csv(orcl_test, here("../data/ORCL_test.csv"))

# orcl <- read.csv(here("../data/ORCL_all.csv"), row.names = 1, header = TRUE)