# Loading data
url <- paste0("https://warin.ca/datalake/iriR/iri_data.csv")
path <- file.path(tempdir(), "temp.csv")
curl::curl_download(url, path)
# Reading data
csv_file <- file.path(paste0(tempdir(), "/temp.csv"))
IRI_data <- read.csv(csv_file)

# Loading indicators
url <- paste0("https://warin.ca/datalake/iriR/iri_indicator.csv")
path <- file.path(tempdir(), "temp.csv")
curl::curl_download(url, path)
csv_file <- file.path(paste0(tempdir(), "/temp.csv"))
IRI_indicator <- read.csv(csv_file)

IRI_data <- reshape2::melt(IRI_data,
                           # ID variables - all the variables to keep but not split apart on
                           id.vars = c("country", "country_code", "year", "rank", "company", "industrial.sector"),
                           # The source columns
                           measure.vars = colnames(IRI_data)[7:ncol(IRI_data)],
                           # Name of the destination column that will identify the original
                           # column that the measurement came from
                           variable.name = "indicator_code",
                           value.name = "value"
)

base::names(IRI_data) = c("country_name", "country_code", "year", "rank", "company_name", "industry_name", "indicator_code", "value")

# Creating the default values for the function query
# IF an entry is missing, all the observations of this variable will be displayed

iri_country <- base::unique(IRI_data[,2])
iri_year <- base::unique(IRI_data[,3])
iri_indicator <- base::unique(IRI_data[,7])
iri_company <- base::unique(IRI_data[,5])
iri_industry <- base::unique(IRI_data[,6])
iri_rank <- base::unique(IRI_data[,4])

# Function 1: Data collection

#' irir_data
#'
#' @description This function allows you to find and display the Industrial R&D Investment Scoreboards (European Commission) data according to the selected parameters.
#' If no arguments are filled, all data will be displayed.
#'
#' @param country Countries' ISO code.
#' @param years Years for which you want the data.
#' @param indicators Indicators from the Industrial Research and Innovation.
#' @param company Companies for which you want the data.
#' @param industry Industries for which you want the data.
#' @param ranks Rank of a company.
#'
#' @import gsheet
#' @import dplyr
#' @import reshape2
#'
#' @return Data for the country, indicator, year, company, industrial sector and rank requested
#' @export
#'
#' @seealso \code{\link{irir_indicator}} for the IRI's indicator symbol, \code{\link{irir_country}} for the country's ISO code,
#'      \code{\link{irir_company}} for the IRI's companies name and \code{\link{irir_industry}} for the IRI's industries name.
#'
#' @examples
#' data <- irir_data(country = "USA", years = "2018", indicators = "RD.euro",
#'    company = "FORD MOTOR", industry = "Automobile & Parts", rank = 14)

irir_data <- function(country = iri_country,
                      years = iri_year,
                      indicators = iri_indicator,
                      company = iri_company,
                      industry = iri_industry,
                      ranks = iri_rank) {
  country_code <- year <- indicator_code <- company_name <- industry_name <- rank <- NULL
  out <- dplyr::filter(IRI_data,
                       country_code %in% country,
                       year %in% years,
                       indicator_code %in% indicators,
                       company_name %in% company,
                       industry_name %in% industry,
                       rank %in% ranks)
  return(out)
}


# Function 2: Indicators' symbols query
# If the user does not know the code of an indicator, s.he has access to the answer in natural language through this query

#' irir_indicator
#'
#' @description This function allows you to find and search the right indicator code from the Industrial R&D Investment Scoreboard you want to use.
#' If no argument is filed, all indicators will be displayed.
#' @param indicators An indicator from the Industrial Research and Innovation.
#'
#' @return Indicator code from the Industrial Research and Innovation.
#' @export
#' @seealso \code{\link{irir_country}} for the IRI's country code, \code{\link{irir_company}} for the IRI's companies name, \code{\link{irir_industry}} for the IRI's industries name and \code{\link{irir_data}} to collect the data.
#'
#' @examples
#'myIndicator <- irir_indicator(indicators = "sales")

irir_indicator <- function(indicators) {
  iri_indicators_natural_language <- IRI_indicator[, 1:3]
  if (missing(indicators)) {
    iri_indicators_natural_language
  } else {
    iri_indicators_natural_language[grep(indicators, iri_indicators_natural_language$indicator_name, ignore.case = TRUE), ]
  }
}




# Function 3: Countries' code reconciliation
# If the user does not know the ISO code of a country, s.he has access to the answer in natural language through this query

#' irir_country
#'
#' @description This function allows you to find and search the right country code associated with the Industrial Research and Innovation's Data.
#' If no argument is filed, all indicators will be displayed.
#'
#' @param country The name of the country.
#'
#' @return Country's ISO code.
#' @export
#' @seealso \code{\link{irir_indicator}} for the IRI's indicators, \code{\link{irir_company}} for the IRI's companies name, \code{\link{irir_industry}} for the IRI's industries name and \code{\link{irir_data}} to collect the data.
#' @examples
#'mycountry <- irir_country(country = "Canada")

irir_country <- function(country) {
  iri_countries_natural_language <- unique(IRI_data[, 1:2])
  if (missing(country)) {
    iri_countries_natural_language
  } else {
    iri_countries_natural_language[grep(country, iri_countries_natural_language$country_name, ignore.case = TRUE), ]
  }
}


# Function 4: Companies' name reconciliation
# If the user wants to know which company is included in IRI's data, s.he has access to the answer in this query

#' irir_company
#' @description This function allows you to find and search the right company name associated with the Industrial Research and Innovation's Data.
#' If no argument is filed, all names will be displayed.
#'
#' @param company The name of a company.
#'
#' @return Company's name.
#' @export
#' @seealso \code{\link{irir_country}} for the IRI's country code, \code{\link{irir_indicator}} for the IRI's indicators, \code{\link{irir_industry}} for the IRI's industries name and \code{\link{irir_data}} to collect the data.
#' @examples
#'mycompany<- irir_company(company = "Samsung")

irir_company <- function(company){
  iri_company_natural_language <- unique(IRI_data$company_name)
  iri_company_natural_language <- as.data.frame(iri_company_natural_language)
  names(iri_company_natural_language)[1] <- "company_name"
  if (missing(company)) {
    iri_company_natural_language
  } else {
    iri_company_natural_language[grep(company, iri_company_natural_language$company_name, ignore.case = TRUE), ]
  }
}

# Function 5: Industries' name reconciliation
# If the user wants to know which industry is included in IRI's data, s.he has access to the answer in this query

#' irir_industry
#' @description This function allows you to find and search the right industry name associated with the Industrial Research and Innovation's Data.
#' If no argument is filed, all names will be displayed.
#'
#' @param industry The name of the industrial sector.
#'
#' @return Industry's name.
#' @export
#' @import dplyr
#'
#' @seealso \code{\link{irir_country}} for the IRI's country code, \code{\link{irir_indicator}} for the IRI's indicators, \code{\link{irir_company}} for the IRI's companies name and \code{\link{irir_data}} to collect the data.
#' @examples
#'myindustry <- irir_industry(industry = "Automobile")

irir_industry <- function(industry){
  iri_industry_natural_language <- unique(IRI_data$industry_name)
  iri_industry_natural_language <- as.data.frame(iri_industry_natural_language)
  names(iri_industry_natural_language)[1] <- "industry_name"
  if (missing(industry)) {
    iri_industry_natural_language
  } else {
    iri_industry_natural_language[grep(industry, iri_industry_natural_language$industry_name, ignore.case = TRUE), ]
  }
}



# Function 6: Visuals


#' irir_visual
#' @description This function allows you to create 3 sorts of visuals: line, bar and point charts.
#'
#' @param country The Country ISO code
#' @param chart Type of charts
#' @param title Chart title, set by default to TRUE
#' @param years Year, only works for bar chart and set by default to max year of IRI's data
#'
#' @return Chosen Graph
#'
#' @export
#'
#' @import dplyr
#' @import ggplot2
#' @import ggsci
#' @import WDI
#' @import scales
#'
#' @seealso \code{\link{irir_country}} for the IRI's country code, \code{\link{irir_industry}} for the IRI's industries name, \code{\link{irir_indicator}} for the IRI's indicators, \code{\link{irir_company}} for the IRI's companies name and \code{\link{irir_data}} to collect the data.
#'
#' @examples
#' irir_visual(country = "CAN", chart = "bar_1", title = TRUE, years = 2019)

irir_visual <- function(country = "CAN", chart = "bar_1", title = TRUE, years = as.numeric(max(IRI_data$year))){

  year <- value <- country_code <- country_name <- n.company <- indicator_code <- RD.sales <- RD.usd <- NULL

  if(years > 2019 | years < 2004){
    stop("no available data for the requested year")
  }

  if(chart == "bar_1"){
    barchart1 <- IRI_data[, c("year", "company_name", "country_name", "country_code")]
    barchart1 <- dplyr::filter(barchart1, year == years)
    barchart1$value <- 1
    barchart1 <- stats::aggregate(value ~ year + country_name + country_code, barchart1, sum, na.rm=TRUE)
    barchart1 <- dplyr::arrange(barchart1, desc(value))
    barchart1 <- dplyr::filter(barchart1, country_code==country | country_code==barchart1[1, 3] | country_code==barchart1[2,3] | country_code==barchart1[3, 3] | country_code==barchart1[4, 3] | country_code==barchart1[5, 3])
    barchart1$country_name <- factor(barchart1$country_name, levels = unique(barchart1$country_name)[order(barchart1$value)])
    if(title == TRUE){
      ggplot2::ggplot(data = barchart1, aes(x = country_name, y = value, fill = country_name)) +
        ggplot2::geom_col() +
        ggplot2::ylab("")  +
        ggplot2::xlab("") +
        ggplot2::ggtitle(paste("Number of leading companies in R&D for the most \nrepresented countries in", years)) +
        ggplot2::theme_minimal() +
        guides(fill=FALSE) +
        ggsci::scale_fill_uchicago() +
        ggplot2::theme(legend.position="none", plot.title = element_text(size=12))  +
        ggplot2::labs(fill = "Countries", caption="Source: Warin (2020) & European Commission.") +
        geom_text(aes(label=value), vjust=-0.5, hjust = 0.5, colour = "black", size = 3.2, fontface = "bold")
    } else {
      ggplot2::ggplot(data = barchart1, aes(x = country_name, y = value, fill = country_name)) +
        ggplot2::geom_col() +
        ggplot2::ylab("")  +
        ggplot2::xlab("") +
        ggplot2::ggtitle("") +
        ggplot2::theme_minimal() +
        guides(fill=FALSE) +
        ggsci::scale_fill_uchicago() +
        ggplot2::theme(legend.position="none", plot.title = element_text(size=12))  +
        ggplot2::labs(fill = "Countries", caption="Source: Warin (2020) & European Commission.") +
        geom_text(aes(label=value), vjust=-0.5, hjust = 0.5, colour = "black", size = 3.2, fontface = "bold")
    }
  } else if(chart == "bar_2"){
    barchart2 <- IRI_data[, c("year", "company_name", "country_name", "country_code")]
    barchart2 <- dplyr::filter(barchart2, year == years)
    barchart2$value <- 1
    barchart2 <- stats::aggregate(value ~ year + country_name + country_code, barchart2, sum, na.rm=TRUE)
    gdpWdi <- WDI::WDI(indicator = "NY.GDP.MKTP.CD", country = "all", start = years, end = years) #change year
    gdpWdi <- gdpWdi[,-1]
    colnames(gdpWdi) <- c("country_name", "gdp", "year")
    barchart2 <- dplyr::left_join(barchart2, gdpWdi, by = c("country_name", "year"))
    barchart2$n.company <- (barchart2$value * 100e+9)/barchart2$gdp
    barchart2 <- barchart2[,c("year", "country_name", "country_code", "n.company")]
    barchart2 <- unique(barchart2)
    barchart2 <- dplyr::arrange(barchart2, desc(n.company))
    barchart2 <- dplyr::filter(barchart2, country_code==country | country_code==barchart2[1, 3] | country_code==barchart2[2,3] | country_code==barchart2[3, 3] | country_code==barchart2[4, 3] | country_code==barchart2[5, 3])
    barchart2$country_name <- factor(barchart2$country_name, levels = unique(barchart2$country_name)[order(barchart2$n.company)])
    barchart2$n.company <- round(barchart2$n.company, digits = 0)
    if(title == TRUE){
      ggplot2::ggplot(data = barchart2, aes(x = country_name, y = n.company, fill = country_name)) +
        ggplot2::geom_col() +
        ggplot2::ylab("")  +
        ggplot2::xlab("") +
        ggplot2::ggtitle(paste("Number of leading companies in R&D per 100 billion $US of GDP \nfor the most represented countries in", years)) +
        ggplot2::theme_minimal() +
        ggsci::scale_fill_uchicago() +
        ggplot2::theme(legend.position="none", plot.title = element_text(size=12))  +
        ggplot2::labs(fill = "Countries", caption="Source: Warin (2020), European Commission & WDI.") +
        geom_text(aes(label=n.company), vjust=-0.5, hjust = 0.5, colour = "black", size = 3.2, fontface = "bold")
    } else {
      ggplot2::ggplot(data = barchart2, aes(x = country_name, y = n.company, fill = country_name)) +
        ggplot2::geom_col() +
        ggplot2::ylab("")  +
        ggplot2::xlab("") +
        ggplot2::ggtitle("") +
        ggplot2::theme_minimal() +
        ggsci::scale_fill_uchicago() +
        ggplot2::theme(legend.position="none", plot.title = element_text(size=12))  +
        ggplot2::labs(fill = "Countries", caption="Source: Warin (2020), European Commission & WDI.") +
        geom_text(aes(label=n.company), vjust=-0.5, hjust = 0.5, colour = "black", size = 3.2, fontface = "bold")
    }
  } else if (chart == "bar_3"){
    barchart3 <- IRI_data[, c("year", "country_name", "country_code", "indicator_code", "value")]
    barchart3 <- dplyr::filter(barchart3, indicator_code == "RD.usd")
    barchart3 <- dplyr::filter(barchart3, year == years)
    barchart3 <- stats::aggregate(value ~ year + country_name + country_code, barchart3, sum, na.rm=TRUE)
    barchart3 <- dplyr::arrange(barchart3, desc(value))
    barchart3 <- dplyr::filter(barchart3, country_code==country | country_code==barchart3[1, 3] | country_code==barchart3[2,3] | country_code==barchart3[3, 3] | country_code==barchart3[4, 3] | country_code==barchart3[5, 3])
    barchart3$country_name <- factor(barchart3$country_name, levels = unique(barchart3$country_name)[order(barchart3$value)])
    if(title == TRUE){
      ggplot2::ggplot(data = barchart3, aes(x = country_name, y = value, fill = country_name)) +
        ggplot2::geom_col() +
        ggplot2::ylab("")  +
        ggplot2::xlab("") +
        ggplot2::ggtitle(paste("R&D expenditures of the leading companies \nfor the most represented countries in", years)) +
        ggplot2::theme_minimal() +
        ggsci::scale_fill_uchicago() +
        ggplot2::scale_y_continuous(labels = scales::dollar) +
        ggplot2::theme(legend.position="none", axis.title.y = element_text(size = 12))  +
        ggplot2::labs(fill = "Countries", caption="Source: Warin (2020), European Commission & WDI.")  +
        geom_text(aes(label=paste0("$", round(value/1000000000, digits = 0), " B")), vjust=-0.5, hjust = 0.5, colour = "black", size = 3.2, fontface = "bold")
    } else {
      ggplot2::ggplot(data = barchart3, aes(x = country_name, y = value, fill = country_name)) +
        ggplot2::geom_col() +
        ggplot2::ylab("")  +
        ggplot2::xlab("") +
        ggplot2::ggtitle("") +
        ggplot2::theme_minimal() +
        ggsci::scale_fill_uchicago() +
        ggplot2::scale_y_continuous(labels = scales::dollar) +
        ggplot2::theme(legend.position="none", axis.title.y = element_text(size = 12))  +
        ggplot2::labs(fill = "Countries", caption="Source: Warin (2020), European Commission & WDI.")  +
        geom_text(aes(label=paste0("$", round(value/1000000000, digits = 0), " B")), vjust=-0.5, hjust = 0.5, colour = "black", size = 3.2, fontface = "bold")
    }
  } else if(chart == "line_1"){
    linechart1 <- IRI_data[, c("year", "company_name", "country_name", "country_code")]
    linechart1$value <- 1
    linechart1 <- stats::aggregate(value ~ year + country_name + country_code, linechart1, sum, na.rm=TRUE)
    linechart1 <- dplyr::arrange(linechart1, desc(year), desc(value))
    linechart1 <- dplyr::filter(linechart1, country_code==country | country_code==linechart1[1, 3] | country_code==linechart1[2,3] | country_code==linechart1[3, 3] | country_code==linechart1[4, 3] | country_code==linechart1[5, 3])
    if(title == TRUE){
      ggplot2::ggplot(data = linechart1, aes(x = year, y = value, color = country_name, shape = country_name)) +
        geom_line() +
        ggplot2::ylab("")  +
        ggplot2::xlab("") +
        ggplot2::ggtitle(paste("Evolution as regards the number of leading companies \nin R&D for the", max(IRI_data$year), "most represented countries")) +
        ggplot2::theme_minimal() +
        guides(fill=FALSE) +
        ggplot2::geom_point(size = 2, stroke = 1) +
        ggsci::scale_color_uchicago() +
        ggplot2::theme(legend.position="right", plot.title = element_text(size=12))  +
        ggplot2::labs(shape = "Countries", color = "Countries", caption="Source: Warin (2020) & European Commission.")
    } else {
      ggplot2::ggplot(data = linechart1, aes(x = year, y = value, color = country_name, shape = country_name)) +
        geom_line() +
        ggplot2::ylab("")  +
        ggplot2::xlab("") +
        ggplot2::ggtitle("") +
        ggplot2::theme_minimal() +
        guides(fill=FALSE) +
        ggplot2::geom_point(size = 2, stroke = 1) +
        ggsci::scale_color_uchicago() +
        ggplot2::theme(legend.position="right", plot.title = element_text(size=12))  +
        ggplot2::labs(shape = "Countries", color = "Countries", caption="Source: Warin (2020) & European Commission.")
    }
  } else if(chart == "line_2"){
    linechart2 <- IRI_data[, c("year", "company_name", "country_name", "country_code")]
    linechart2$value <- 1
    linechart2 <- stats::aggregate(value ~ year + country_name + country_code, linechart2, sum, na.rm=TRUE)
    gdpWdi <- WDI::WDI(indicator = "NY.GDP.MKTP.CD", country = "all", start = min(IRI_data$year), end = max(IRI_data$year)) #change year
    gdpWdi <- gdpWdi[,-1]
    colnames(gdpWdi) <- c("country_name", "gdp", "year")
    linechart2 <- dplyr::left_join(linechart2, gdpWdi, by = c("country_name", "year"))
    linechart2$n.company <- (linechart2$value * 100e+9)/linechart2$gdp
    linechart2 <- linechart2[,c("year", "country_name", "country_code", "n.company")]
    linechart2 <- unique(linechart2)
    linechart2 <- dplyr::arrange(linechart2, desc(year), desc(n.company))
    linechart2 <- dplyr::filter(linechart2, country_code==country | country_code==linechart2[1, 3] | country_code==linechart2[2,3] | country_code==linechart2[3, 3] | country_code==linechart2[4, 3] | country_code==linechart2[5, 3])
    if(title == TRUE){
      ggplot2::ggplot(data = linechart2, aes(x = year, y = n.company, color = country_name, shape = country_name)) +
        geom_line() +
        ggplot2::ylab("")  +
        ggplot2::xlab("") +
        ggplot2::ggtitle(paste("Evolution as regards the number of leading companies in R&D \nper 100 billion $US of GDP for the", max(IRI_data$year), "most represented countries")) +
        ggplot2::theme_minimal() +
        ggplot2::geom_point(size = 2, stroke = 1) +
        ggsci::scale_color_uchicago() +
        ggplot2::theme(legend.position="right", plot.title = element_text(size=12))  +
        ggplot2::labs(shape = "Countries", color = "Countries", caption="Source: Warin (2020), European Commission & WDI.")
    } else {
      ggplot2::ggplot(data = linechart2, aes(x = year, y = n.company, color = country_name, shape = country_name)) +
        geom_line() +
        ggplot2::ylab("")  +
        ggplot2::xlab("") +
        ggplot2::ggtitle("") +
        ggplot2::theme_minimal() +
        ggplot2::geom_point(size = 2, stroke = 1) +
        ggsci::scale_color_uchicago() +
        ggplot2::theme(legend.position="right", plot.title = element_text(size=12))  +
        ggplot2::labs(shape = "Countries", color = "Countries", caption="Source: Warin (2020), European Commission & WDI.")
    }
  } else if (chart == "line_3"){
    linechart3 <- IRI_data[, c("year", "country_name", "country_code", "indicator_code", "value")]
    linechart3 <- dplyr::filter(linechart3, indicator_code == "RD.usd")
    linechart3 <- stats::aggregate(value ~ year + country_name + country_code, linechart3, sum, na.rm=TRUE)
    linechart3 <- dplyr::arrange(linechart3, desc(year), desc(value))
    linechart3 <- dplyr::filter(linechart3, country_code==country | country_code==linechart3[1, 3] | country_code==linechart3[2,3] | country_code==linechart3[3, 3] | country_code==linechart3[4, 3] | country_code==linechart3[5, 3])
    if(title == TRUE){
      ggplot2::ggplot(data = linechart3, aes(x = year, y = value, color = country_name, shape = country_name)) +
        geom_line() +
        ggplot2::ylab("")  +
        ggplot2::xlab("") +
        ggplot2::ggtitle(paste("Evolution as regards R&D expenditures of the leading \ncompanies for the", max(IRI_data$year), "most represented countries")) +
        ggplot2::theme_minimal() +
        ggplot2::geom_point(size = 2, stroke = 1) +
        ggsci::scale_color_uchicago() +
        ggplot2::scale_y_continuous(labels = scales::dollar) +
        ggplot2::theme(legend.position="right", axis.title.y = element_text(size = 12))  +
        ggplot2::labs(shape = "Countries", color = "Countries", caption="Source: Warin (2020), European Commission & WDI.")
    } else {
      ggplot2::ggplot(data = linechart3, aes(x = year, y = value, color = country_name, shape = country_name)) +
        geom_line() +
        ggplot2::ylab("")  +
        ggplot2::xlab("") +
        ggplot2::ggtitle("") +
        ggplot2::theme_minimal() +
        ggplot2::geom_point(size = 2, stroke = 1) +
        ggsci::scale_color_uchicago() +
        ggplot2::scale_y_continuous(labels = scales::dollar) +
        ggplot2::theme(legend.position="right", axis.title.y = element_text(size = 12))  +
        ggplot2::labs(shape = "Countries", color = "Countries", caption="Source: Warin (2020), European Commission & WDI.")
    }
  } else if(chart == "line_4"){
    linechart4 <- IRI_data[, c("year", "country_name", "country_code", "indicator_code", "value")]
    linechart4 <- dplyr::filter(linechart4, indicator_code == "RD.usd")
    linechart4 <- dplyr::filter(linechart4, country_code==country)
    linechart4A <- stats::aggregate(value ~ year + country_name + country_code, linechart4, sum, na.rm = TRUE)
    linechart4A$value <- linechart4A$value/1e+6
    linechart4$n.company <- 1
    linechart4B <- stats::aggregate(n.company ~ year + country_name + country_code, linechart4, sum, na.rm = TRUE)
    linechart4 <- dplyr::left_join(linechart4A, linechart4B, c("year", "country_name", "country_code"))
    linechart4 <- reshape2::melt(linechart4, id.vars= c("year","country_name", "country_code"))
    linechart4$variable <- gsub("RD.usd", "R&D (million $US)", linechart4$variable)
    linechart4$variable <- gsub("n.company", "Leading R&D companies", linechart4$variable)
    if(title == TRUE){
      ggplot2::ggplot(data = linechart4, aes(x = year, y = value, color = country)) +
        geom_line() +
        ggplot2::ylab("")  +
        ggplot2::xlab("") +
        ggplot2::ggtitle("Evolution as regards the number of leading companies in R&D \n& the total of their R&D investments (in millions of $US)") +
        ggplot2::theme_minimal() +
        guides(fill=FALSE) +
        ggsci::scale_color_uchicago() +
        ggplot2::geom_point(shape = 19, size = 2, stroke = 1.20) +
        ggplot2::theme(legend.position="none") +
        facet_grid(variable ~ ., scales = "free") +
        ggplot2::labs(caption="Source: Warin (2020) & European Commission.")
    } else{
      ggplot2::ggplot(data = linechart4, aes(x = year, y = value, color = country)) +
        geom_line() +
        ggplot2::ylab("")  +
        ggplot2::xlab("") +
        ggplot2::ggtitle("") +
        ggplot2::theme_minimal() +
        guides(fill=FALSE) +
        ggsci::scale_color_uchicago() +
        ggplot2::geom_point(shape = 19, size = 2, stroke = 1.20) +
        ggplot2::theme(legend.position="none") +
        facet_grid(variable ~ ., scales = "free") +
        ggplot2::labs(caption="Source: Warin (2020) & European Commission.")
    }
  } else if(chart == "line_5"){
    linechart5 <- IRI_data[, c("year", "company_name", "country_name", "country_code", "indicator_code", "value")]
    linechart5 <- dplyr::filter(linechart5, indicator_code == "RD.usd")
    linechart5A <- dplyr::filter(linechart5, country_code==country)
    linechart5A <- stats::aggregate(value ~ year + country_name + country_code, linechart5A, sum, na.rm = TRUE)
    linechart5B <- stats::aggregate(value ~ year, linechart5, sum, na.rm = TRUE)
    linechart5 <- left_join(linechart5A, linechart5B, by = "year")
    linechart5$value <- linechart5$value.x /linechart5$value.y
    if(title == TRUE){
      ggplot2::ggplot(data = linechart5, aes(x = year, y = value, color = country)) +
        geom_line() +
        ggplot2::ylab("")  +
        ggplot2::xlab("") +
        geom_smooth(span = 0.8) +
        ggplot2::ggtitle(paste("Evolution as regards the percentage of R&D investments made by \ncompanies in", unique(linechart5$country_name), "in the total R&D investments.")) +
        ggplot2::theme_minimal() +
        guides(fill=FALSE) +
        ggsci::scale_color_uchicago() +
        ggplot2::geom_point(shape = 19, size = 2, stroke = 1.20) +
        ggplot2::theme(legend.position="none", plot.title = element_text(size=12)) +
        ggplot2::scale_y_continuous(labels = scales::percent_format(accuracy=.1)) +
        ggplot2::labs(caption="Source: Warin (2020) & European Commission.")
    } else {
      ggplot2::ggplot(data = linechart5, aes(x = year, y = value, color = country)) +
        geom_line() +
        ggplot2::ylab("")  +
        ggplot2::xlab("") +
        geom_smooth(span = 0.8) +
        ggplot2::ggtitle("") +
        ggplot2::theme_minimal() +
        guides(fill=FALSE) +
        ggsci::scale_color_uchicago() +
        ggplot2::geom_point(shape = 19, size = 2, stroke = 1.20) +
        ggplot2::theme(legend.position="none", plot.title = element_text(size=12)) +
        ggplot2::scale_y_continuous(labels = scales::percent_format(accuracy=.1)) +
        ggplot2::labs(caption="Source: Warin (2020) & European Commission.")
    }
  } else if (chart == "line_6"){
    linechart6 <- IRI_data[, c("year", "company_name", "country_name", "country_code", "indicator_code", "value")]
    linechart6 <- dplyr::filter(linechart6, country_code==country)
    linechart6A <- dplyr::filter(linechart6, indicator_code == "RD.usd")
    linechart6B <- dplyr::filter(linechart6, indicator_code == "employees.qty")
    linechart6A <- stats::aggregate(value ~ year + country_name + country_code, linechart6A, sum, na.rm=FALSE)
    linechart6B <- stats::aggregate(value ~ year + country_name + country_code, linechart6B, sum, na.rm=FALSE)
    linechart6 <- left_join(linechart6A, linechart6B, by = c("country_name", "country_code", "year"))
    linechart6$value <- linechart6$value.x / linechart6$value.y
    if(title == TRUE){
      ggplot2::ggplot(data = linechart6, aes(x = year, y = value, color = country)) +
        geom_line() +
        ggplot2::ylab("")  +
        ggplot2::xlab("") +
        ggplot2::ggtitle("Evolution as regards the R&D per employee in $US") +
        ggplot2::theme_minimal() +
        ggsci::scale_color_uchicago() +
        ggplot2::geom_point(shape = 19, size = 2, stroke = 1.10) +
        ggplot2::theme(plot.title = element_text(size=12)) +
        ggplot2::labs(color = "Country", caption="Source: Warin(2020) & European Commission.")
    } else {
      ggplot2::ggplot(data = linechart6, aes(x = year, y = value, color = country)) +
        geom_line() +
        ggplot2::ylab("")  +
        ggplot2::xlab("") +
        ggplot2::ggtitle("") +
        ggplot2::theme_minimal() +
        ggsci::scale_color_uchicago() +
        ggplot2::geom_point(shape = 19, size = 2, stroke = 1.10) +
        ggplot2::theme(plot.title = element_text(size=12)) +
        ggplot2::labs(color = "Country", caption="Source: Warin(2020) & European Commission.")
    }
  } else if(chart == "point_1"){
    pointchart1 <- IRI_data[, c("year", "company_name", "country_name", "country_code", "indicator_code", "value")]
    pointchart1 <- dplyr::filter(pointchart1, year == years)
    pointchart1A <- dplyr::filter(pointchart1, indicator_code == "RD.usd")
    pointchart1B <- dplyr::filter(pointchart1, indicator_code == "sales.usd")
    pointchart1A <- stats::aggregate(value ~ year + country_name + country_code, pointchart1A, sum, na.rm=FALSE)
    pointchart1B <- stats::aggregate(value ~ year + country_name + country_code, pointchart1B, sum, na.rm=FALSE)
    names(pointchart1A)[4] <- "RD.usd"
    names(pointchart1B)[4] <- "sales.usd"
    pointchart1 <- left_join(pointchart1A, pointchart1B, by = c("year", "country_name", "country_code"))
    pointchart1$RD.sales <- pointchart1$sales.usd / pointchart1$RD.usd
    pointchart1 <- dplyr::arrange(pointchart1, desc(RD.sales))
    pointchart1 <- dplyr::filter(pointchart1, country_code==country | country_code==pointchart1[1,3] | country_code==pointchart1[2,3] | country_code==pointchart1[3,3] | country_code==pointchart1[4,3] | country_code==pointchart1[5,3])
    if(title == TRUE){
      ggplot2::ggplot(data = pointchart1, aes(x = RD.usd, y = RD.sales, color = country_name, shape = country_name)) +
        ggplot2::geom_point() +
        ggplot2::ylab("Net sales/R&D investment")  +
        ggplot2::xlab("Total R&D investments") +
        ggplot2::ggtitle(paste("Net sales/R&D investment ratio per total R&D investment \nfor the", max(IRI_data$year), "most represented countries")) +
        guides(fill=FALSE) +
        ggplot2::theme_minimal() +
        ggsci::scale_color_uchicago() +
        ggplot2::geom_point(size = 3, stroke = 1) +
        ggplot2::theme(plot.title = element_text(size=12)) +
        ggplot2::labs(shape = "Countries", color = "Countries", caption="Source: Warin (2020) & European Commission.")
    } else {
      ggplot2::ggplot(data = pointchart1, aes(x = RD.usd, y = RD.sales, color = country_name, shape = country_name)) +
        ggplot2::geom_point() +
        ggplot2::ylab("Net sales/R&D investment")  +
        ggplot2::xlab("Total R&D investments") +
        ggplot2::ggtitle("") +
        guides(fill=FALSE) +
        ggplot2::theme_minimal() +
        ggsci::scale_color_uchicago() +
        ggplot2::geom_point(size = 3, stroke = 1) +
        ggplot2::labs(shape = "Countries", color = "Countries", caption="Source: Warin (2020) & European Commission.")
    }
  } else{
    stop("invalid arguments")
  }
}
