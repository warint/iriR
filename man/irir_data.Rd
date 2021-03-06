% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/iriR.R
\name{irir_data}
\alias{irir_data}
\title{irir_data}
\usage{
irir_data(
  country = iri_country,
  years = iri_year,
  indicators = iri_indicator,
  company = iri_company,
  industry = iri_industry,
  ranks = iri_rank
)
}
\arguments{
\item{country}{Countries' ISO code.}

\item{years}{Years for which you want the data.}

\item{indicators}{Indicators from the Industrial Research and Innovation.}

\item{company}{Companies for which you want the data.}

\item{industry}{Industries for which you want the data.}

\item{ranks}{Rank of a company.}
}
\value{
Data for the country, indicator, year, company, industrial sector and rank requested
}
\description{
This function allows you to find and display the Industrial R&D Investment Scoreboards (European Commission) data according to the selected parameters.
If no arguments are filled, all data will be displayed.
}
\examples{
data <- irir_data(country = "USA", years = "2018", indicators = "RD.euro",
   company = "FORD MOTOR", industry = "Automobile & Parts", rank = 14)
}
\seealso{
\code{\link{irir_indicator}} for the IRI's indicator symbol, \code{\link{irir_country}} for the country's ISO code,
\code{\link{irir_company}} for the IRI's companies name and \code{\link{irir_industry}} for the IRI's industries name.
}
