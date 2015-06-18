library(googlesheets)
library(ggplot2)
library(dplyr)
library(tidyr)
library(directlabels)

my_theme <- theme_bw(base_size = 20) +
  theme(axis.title.x = element_blank(), axis.title.y = element_blank())
theme_set(my_theme)
lbs_formatter <- function(x) paste(x, "lbs")

gs_auth("jenny_token.rds") ## Sheet is NOT published to the web

jc_ss <- gs_title("jim-craig-weight-loss")
jc_dat <- gs_read(jc_ss)

jc_dat <- jc_dat %>%
  mutate(date = as.Date(date, format = "%m/%d/%Y")) %>%
  gather("who", "weight", Jim, Craig)

p <- ggplot(jc_dat, aes(x = date, y = weight, color = who)) +
  geom_point(alpha = 0.35) + geom_smooth(se = FALSE, lwd = 2) +
  scale_y_continuous(labels = lbs_formatter)
print(direct.label(p))
ggsave("jim-craig-scatter-with-smooth.png", dpi = 300)

p <- ggplot(jc_dat %>%
              filter(date %>% between(as.Date("2011-08-27"),
                                      as.Date("2012-01-10"))),
            aes(x = date, y = weight, color = who)) + geom_point() +
  geom_smooth(se = FALSE, lwd = 1.5)
print(direct.label(p))

