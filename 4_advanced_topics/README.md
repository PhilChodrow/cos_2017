# Before the Session

You need to ensure that the `tidyverse` packages is installed. You will also need the `ggmap` package: 

```r
install.packages('tidyverse')
install.packages('ggmap')
```

To test your installation, paste the following code into your console, run it, and report the result. 

```{r}
library(tidyverse)
1:10 %>% purrr::map(~.^2) %>% unlist()
```