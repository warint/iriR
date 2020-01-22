#' sqs_iri_data
#'
#' @description This function allows you to find and display the Industrial Research and Innovation data according to the selected parameters.
#' If no arguments are filled, all data will be displayed.
#'
#' @param country Countries' ISO code.
#' @param years Years for which you want the data.
#' @param indicators Indicators from the Industrial Research and Innovation.
#' @param company Companies for which you want the data.
#' @param industry Industries for which you want the data.
#' @param rank Rank of a company.
#'
#' @import gsheet
#' @import dplyr
#' @import reshape2
#'
#' @return Data for the country, indicator, year, company, industrial sector and rank requested
#' @export
#'
#' @seealso \code{\link{sqs_iri_indicator}} for the IRI's indicator symbol, \code{\link{sqs_iri_country}} for the country's ISO code,
#'      \code{\link{sqs_iri_company}} for the IRI's companies name and \code{\link{sqs_iri_industry}} for the IRI's industries name.
#'
#' @examples
#' data <- sqs_iri_data(country = "USA", years = "2018", indicators = "RD.euro",
#'  company = "FORD MOTOR")
#' data <- sqs_iri_data("USA", "2018", "RD.euro", "FORD MOTOR",
#'  "Automobiles & Parts", "14")
#' data <- sqs_iri_data(country =c("USA","DEU"),
#'  years =c("2018"), rank = 1:25 )
#'
#



# Function 1: Data collection

sqs_iri_data <- function(country = data_long_country,
                         years = data_long_year,
                         indicators = dat_long_indicator,
                         company = data_long_company,
                         industry = data_long_industry,
                         rank = data_long_rank) {
  var_code <- var_year <- var_indicator <- var_company <- var_industrial.sector <- var_rank <- NULL
  out <- dplyr::filter(data_long,
                       var_code %in% country,
                       var_year %in% years,
                       var_indicator %in% indicators,
                       var_company %in% company,
                       var_industrial.sector %in% industry,
                       var_rank %in% rank)
  return(out)
}

iri_data <- gsheet::gsheet2tbl("https://docs.google.com/spreadsheets/d/1mWprVoXjECQOKRpFNn4vDtpegLmhkRLSlABqrITTObY/edit?usp=sharing")

data_long <- reshape2::melt(iri_data,
                            # ID variables - all the variables to keep but not split apart on
                            id.vars = c("countryName", "code", "year", "rank", "company", "industrial.sector"),
                            # The source columns
                            measure.vars = colnames(iri_data)[7:ncol(iri_data)],
                            # Name of the destination column that will identify the original
                            # column that the measurement came from
                            variable.name = "var_indicator",
                            value.name = "value"
)

base::names(data_long) = c("countryName", "var_code", "var_year", "var_rank", "var_company", "var_industrial.sector", "var_indicator", "value")


# Creating the default values for the function query
# IF an entry is missing, all the observations of this variable will be displayed

data_long_country <- base::unique(data_long[,2])
data_long_year <- base::unique(data_long[,3])
dat_long_indicator <- base::unique(data_long[,7])
data_long_company <- base::unique(data_long[,5])
data_long_industry <- base::unique(data_long[,6])
data_long_rank <- base::unique(data_long[,4])



# Function 2: Indicators' symbols query
# If the user does not know the code of an indicator, s.he has access to the answer in natural language through this query

#' sqs_iri_indicator
#'
#' @description This function allows you to find and search the right indicator code from the Industrial Research and Innovation you want to use.
#' If no argument is filed, all indicators will be displayed.
#' @param indicators An indicator from the Industrial Research and Innovation.
#'
#' @return Indicator code from the Industrial Research and Innovation.
#' @export
#' @seealso \code{\link{sqs_iri_country}} for the IRI's country code, \code{\link{sqs_iri_company}} for the IRI's companies name, \code{\link{sqs_iri_industry}} for the IRI's industries name and \code{\link{sqs_iri_data}} to collect the data.
#'
#' @examples
#'myIndicator <- sqs_iri_indicator()
#'myIndicator <- sqs_iri_indicator(indicators = "sales")
#'myIndicator <- sqs_iri_indicator("sales")
#'


sqs_iri_indicator <- function(indicators) {
  iri_indicators_natural_language <- gsheet::gsheet2tbl("https://docs.google.com/spreadsheets/d/1mWprVoXjECQOKRpFNn4vDtpegLmhkRLSlABqrITTObY/edit#gid=1353281495")
  if (missing(indicators)) {
    iri_indicators_natural_language
  } else {
    iri_indicators_natural_language[grep(indicators, iri_indicators_natural_language$indicator_name, ignore.case = TRUE), ]
  }
}



# Function 3: Countries' code reconciliation
# If the user does not know the ISO code of a country, s.he has access to the answer in natural language through this query

#' sqs_iri_country
#' @description This function allows you to find and search the right country code associated with the Industrial Research and Innovation's Data.
#' If no argument is filed, all indicators will be displayed.
#'
#' @param country The name of the country.
#'
#' @return Country's ISO code.
#' @export
#' @seealso \code{\link{sqs_iri_indicator}} for the IRI's indicators, \code{\link{sqs_iri_company}} for the IRI's companies name, \code{\link{sqs_iri_industry}} for the IRI's industries name and \code{\link{sqs_iri_data}} to collect the data.
#' @examples
#'mycountry <- sqs_iri_country()
#'mycountry <- sqs_iri_country(country = "Canada")
#'mycountry <- sqs_iri_country("Canada")
#'


sqs_iri_country <- function(country) {
  iri_countries_natural_language <- unique(iri_data[, 4:5])
  if (missing(country)) {
    iri_countries_natural_language
  } else {
    iri_countries_natural_language[grep(country, iri_countries_natural_language$countryName, ignore.case = TRUE), ]
  }
}


# Function 4: Companies' name reconciliation
# If the user wants to know which company is included in IRI's data, s.he has access to the answer in this query

#' sqs_iri_company
#' @description This function allows you to find and search the right company name associated with the Industrial Research and Innovation's Data.
#' If no argument is filed, all names will be displayed.
#'
#' @param company The name of a company.
#'
#' @return Company's name.
#' @export
#' @seealso \code{\link{sqs_iri_country}} for the IRI's country code, \code{\link{sqs_iri_indicator}} for the IRI's indicators, \code{\link{sqs_iri_industry}} for the IRI's industries name and \code{\link{sqs_iri_data}} to collect the data.
#' @examples
#'mycompany<- sqs_iri_company()
#'mycompany<- sqs_iri_company(company = "Samsung")
#'mycompany<- sqs_iri_company("Samsung")
#'

sqs_iri_company <- function(company){
  iri_company <- unique(iri_data[,3])
  iri_company <- dplyr::arrange(iri_company, company)
  if (missing(company)) {
    iri_company
  } else {
    iri_company[grep(company, iri_company$company, ignore.case = TRUE), ]
  }
}


# Function 5: Industries' name reconciliation
# If the user wants to know which industry is included in IRI's data, s.he has access to the answer in this query

#' sqs_iri_industry
#' @description This function allows you to find and search the right industry name associated with the Industrial Research and Innovation's Data.
#' If no argument is filed, all names will be displayed.
#'
#' @param industry The name of the industrial sector
#'
#' @return Industry's name.
#' @export
#' @seealso \code{\link{sqs_iri_country}} for the IRI's country code, \code{\link{sqs_iri_indicator}} for the IRI's indicators, \code{\link{sqs_iri_company}} for the IRI's companies name and \code{\link{sqs_iri_data}} to collect the data.
#' @examples
#'myindustry <- sqs_iri_industry()
#'myindustry <- sqs_iri_industry(industry = "Automobile")
#'myindustry <- sqs_iri_industry("Automobile")
#'

sqs_iri_industry <- function(industry){
  iri_industry <- unique(iri_data[,6])
  iri_industry <- dplyr::arrange(iri_industry, industrial.sector)
  if (missing(industry)) {
    iri_industry
  } else {
    iri_industry[grep(industry, iri_industry$industrial.sector, ignore.case = TRUE), ]
  }
}
