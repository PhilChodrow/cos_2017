library(tidyverse)

prices <- read_csv('data/calendar.csv')
listings <- read_csv('data/listings.csv')

prices <- prices %>%
	left_join(listings, by = c('listing_id' = 'id' )) %>% 
	select(listing_id, date, price = price.x, accommodates) %>%
	mutate(price = as.numeric(gsub('\\$|,', '', price)),
		   price_per = price / accommodates) %>% 
	select(listing_id, date, price_per) %>% 
	group_by(listing_id) %>% 
	filter(sum(!is.na(price_per)) >= 200) %>% 
	na.omit() %>% 
	ungroup()

listings <- listings %>% 
	select(id, latitude, longitude)


