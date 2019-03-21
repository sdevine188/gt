library(tidyverse)
library(gt)
library(glue)
library(tidyverse)
library(rmarkdown)
library(webshot)
library(magick)


# https://gt.rstudio.com/

# Define the start and end dates for the data range
start_date <- "2010-06-07"
end_date <- "2010-06-14"

# Create a gt table based on preprocessed
# `sp500` table data
glimpse(sp500)
table1 <- sp500 %>%
        dplyr::filter(date >= start_date & date <= end_date) %>%
        dplyr::select(-adj_close) %>%
        dplyr::mutate(date = as.character(date)) %>%
        gt() %>%
        tab_header(
                title = "S&P 500",
                subtitle = glue::glue("{start_date} to {end_date}")
        ) %>%
        fmt_date(
                columns = vars(date),
                date_style = 3
        ) %>%
        fmt_currency(
                columns = vars(open, high, low, close),
                currency = "USD"
        ) %>%
        fmt_number(
                columns = vars(volume),
                scale_by = 1 / 1E9,
                pattern = "{x}B"
        )
table1


########################################################################################


# this code is copied from flextable_scratchpad, but gt tables seems similar

# saving table to png requires using webshot (per author of officer package)
# https://stackoverflow.com/questions/50225669/how-to-save-flextable-as-png-in-r
# note i use slightly differnt code than the stackoverflow answer, 
# knitting rmd direct from r script intead of creating rmd
# trying pdf()...dev.off() gets error that table is not a vector graphic with x,y coordinates

# save r script to tempfile for rendering as an rmarkdown doc
# will save to temporary folder - can navigate to file by following path
r_script_name <- tempfile(fileext = ".R")
cat("table1", file = r_script_name)
r_script_name

# create temporary html file for output of rendering
# will save to temporary folder - can navigate to file by following path
html_name <- tempfile(fileext = ".html")
html_name

# render r script as if it were rmarkdown
# http://brooksandrew.github.io/simpleblog/articles/render-reports-directly-from-R-scripts/
render(input = r_script_name, output_format = "html_document", 
       output_file = html_name)

# get a png from the html file with webshot - will save to working directory
# note that png and pdf will have higher resolution the higher the zoom
# 1 vs 5 is very noticeable; 10 vs 20 is less so until you enlarge pdf to see fine details
webshot(html_name, zoom = 20, delay = .5, file = "table1_zoom.png", 
        selector = "table")

# read png into magick
table_png_image <- image_read("table1_zoom.png")
table_png_image

# output png as pdf
image_write(table_png_image, path = "table1_zoom.pdf", format = "pdf")


#######################################################################################

# Use `gtcars` to create a gt table;
# add a header and then export as
# RTF code
tab_rtf <-
        gtcars %>%
        dplyr::select(mfr, model) %>%
        dplyr::slice(1:2) %>%
        gt() %>%
        tab_header(
                title = md("Data listing from **gtcars**"),
                subtitle = md("`gtcars` is an R dataset")
        ) %>%
        as_rtf()

# `tab_rtf` is a single element character
# vector
tab_rtf %>% cat()





















