library(here)
library(dplyr)

orcl_all <- read.csv(here("../data/ORCL_all_orig.csv")) %>% # načte soubor
  rename(date = Date,           # přejmenuje sloupce
         open = Open, 
         high = High, 
         low = Low, 
         close = Close, 
         adjusted_close = Adj.Close, 
         volume = Volume
         ) %>% 
  mutate(id = row_number()) %>% # přidá sloupec s ID
  select(id, everything()) %>%  # přesune sloupec s ID na začátek
  mutate(date = as.Date(date, format = "%Y-%m-%d"))

# trénovací a testovací data v poměru 3 : 1
orcl_train <- subset(orcl_all, date < "2017-01-03")
orcl_test <- subset(orcl_all, date >= "2017-01-03")

write.csv(orcl_all, here("../data/ORCL_all.csv"))
write.csv(orcl_train, here("../data/ORCL_train.csv"))
write.csv(orcl_test, here("../data/ORCL_test.csv"))
