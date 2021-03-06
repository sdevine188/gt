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


table1 %>% tab_options(
        heading.background.color = "#3366ff"
)

table1 %>% tab_style(style = cells_styles(text_color = "#ff4d94"), 
                     locations = cells_title(groups = "title")) %>%
        tab_style(style = cells_styles(text_color = "#ff4d94"), 
                  locations = cells_title(groups = "subtitle"))

table1 %>% tab_style(style = cells_styles(bkgd_color = "#3366ff"),
                     locations = cells_column_labels(columns = everything())) 


###########


gtcars %>% glimpse()
tab1 <- gtcars %>% select(model, year, hp, trq) %>% slice(1:8) %>% 
        # rename("year<sup>a</sup>" = year) %>%
        gt() %>% tab_header(title = "gtcars table") %>%
        tab_style(style = cells_styles(text_font = "Georgia"), locations = cells_title(groups = "title")) %>%
        
        # note that there is no way at present to get formatted superscript on column name
        # even tab_footer, which will put numeric superscript, won't accept any formatting
        # tab_style(style = cells_styles(bkgd_color = "#3366ff", text_color = "#ffffff", text_font = "Georgia"),
        #                    locations = cells_column_labels(columns = everything())) %>%
        tab_footnote(footnote = "test footnote", locations = cells_column_labels(columns = vars(year))) %>%
        # tab_style(style = cells_styles(bkgd_color = "#3366ff", text_color = "#ffffff", text_font = "Georgia"),
        #           locations = cells_column_labels(columns = c(1, 2, 3))) %>%
        tab_style(style = cells_styles(text_font = "Georgia"),
                  locations = cells_data(columns = everything())) %>%
       
         # note there is no locations function to target footers and source_notes with styles
        # but you can use md() and html() to style them when adding them 
        tab_source_note(source_note = html("<p style = 'font-family:georgia,garamond,serif;'>
                                           <sup>a</sup>Source: Database<sub>b</sub></p>")) %>%
        
        # note that text_transform only works on cells_data (per github issue response)
        # text_transform(locations = cells_column_labels(columns = vars(year)),
        #         fn = function(x) {
        #                 str_c("year_test")
        #         }
        # ) %>%
        text_transform(locations = cells_data(columns = vars(year)),
                       fn = function(x) {
                               str_c("year_test")
                       }
        ) %>%
        identity()


# for some reason i cant get text_transform to work on column names
attributes(tab1)
attributes(tab1)$col_labels$year <- "year_test"
attributes(tab1)$data_df <- attributes(tab1)$data_df %>% rename(year_test = year)
attributes(tab1)$cols_df <- attributes(tab1)$cols_df %>% 
        mutate(colnames_start = case_when(colnames_start == "year" ~ "year_test", TRUE ~ colnames_start))
# attributes(tab1)$boxh_df <- attributes(tab1)$boxh_df %>% rename(year_test = year)
attributes(tab1)$names <- case_when(attributes(tab1)$names == "year" ~ "year_test", TRUE ~ attributes(tab1)$names)

tab1 %>% tab_style(style = cells_styles(bkgd_color = "#3366ff", text_color = "#ffffff", text_font = "Georgia"),
                   locations = cells_column_labels(columns = everything()))

attributes(tab1)$col_labels$year
attributes(tab1)$data_df
attributes(tab1)$cols_df
attributes(tab1)$boxh_df
attributes(tab1)$names
attributes(tab1)$spec
tab1


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



############################################################



















