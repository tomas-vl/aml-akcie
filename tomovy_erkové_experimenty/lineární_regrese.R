library(here)
library(dplyr)
library(ggplot2)

# načtení dat --------------------------------------------------------------------------------------
training_data <- read.csv(here("../data/ORCL_train.csv"), row.names = 1, header = TRUE) %>% 
  mutate(date = as.Date(date, format = "%Y-%m-%d"))

testing_data <- read.csv(here("../data/ORCL_test.csv"), row.names = 1, header = TRUE) %>% 
  mutate(date = as.Date(date, format = "%Y-%m-%d"))

# lin. model a predikování -------------------------------------------------------------------------
model <- lm(close ~ date, data = training_data)

predicted_training_data <- data.frame(
  close = predict(model, newdata = training_data), 
  date=training_data$date
  )

predicted_testing_data <- data.frame(
  close = predict(model, newdata = testing_data), 
  date=testing_data$date
)

# grafy --------------------------------------------------------------------------------------------
ggplot(training_data) +
  aes(x = date, y = close) +
  geom_point(size = 0.01) +
  geom_line(data = predicted_training_data, color = "#2c7fb8") +
  theme_linedraw() +
  labs(title = "Lineární model na trénovacích datech", x = "Datum", y = "Hodnota akcie „close“")
  
ggplot(testing_data) +
  aes(x = date, y = close) +
  geom_point(size = 0.01) +
  geom_line(data = predicted_testing_data, color = "#31a354") +
  theme_linedraw() +
  labs(title = "Lineární model na testovacích datech", x = "Datum", y = "Hodnota akcie „close“")

ggplot(rbind(training_data, testing_data)) +
  aes(x = date, y = close) +
  geom_point(size = 0.01) +
  geom_line(data = rbind(predicted_training_data, predicted_testing_data), color = "purple") +
  theme_linedraw() +
  labs(title = "Lineární model na všech datech", x = "Datum", y = "Hodnota akcie „close“")

# hodnotící metriky --------------------------------------------------------------------------------
rsq <- function (x, y) cor(x, y) ^ 2

summary(model)$r.squared
rsq(training_data$close, predicted_training_data$close)
rsq(testing_data$close, predicted_testing_data$close)