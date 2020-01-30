
<!-- README.md is generated from README.Rmd. Please edit that file -->

# iriR

<!-- badges: start -->

<!-- badges: end -->

The goal of iriR is to easily access the EU Industrial Research and
Industry Scoreboard.

## Installation

You can install the released version of iriR from
[CRAN](https://CRAN.R-project.org) with:

``` r
devtools::install_github("warint/iriR")
```

## Overview of the available data

## Installation

You can install the current development version of ‘iriR’ with:

``` r
devtools::install_github("warint/iriR")
```

## How-To

### Step 1: Getting the country’s ISO code

A user needs to enter the ISO code of a country. To have access to this
code, the following function provides this information.

``` r
sqs_iri_country() # A list of all countries will be produced

sqs_iri_country(country = "Canada") # The ISO code for Canada will be produced

sqs_iri_country("Canada") # The ISO code for Canada will be produced
```

### Step 2: Getting the indicator’s code

A user needs to enter the code of the desired indicator. To do so, the
following function provides access to all the indicators of interest.

``` r
sqs_iri_indicator() # A list of all indicators will be produced

sqs_iri_indicator(indicators = "sales") # A list with all the variables including "sales" will be produced

sqs_iri_indicator("sales") # A list with all the variables including "sales" will be produced
```

### Step 3: Getting the company’ name

A user needs to enter the name of the desired company. To do so, the
following function provides access to all the companies of interest.

``` r
sqs_iri_company() # A list of all companies will be produced

sqs_iri_company(company = "Samsung") # A list with all the variables including "Samsung" will be produced

sqs_spi_indicator("Samsung") # A list with all the variables including "Samsung" will be produced
```

### Step 4: Getting the industry’ name

A user needs to enter the name of the desired industry. To do so, the
following function provides access to all the industries of interest.

``` r
sqs_iri_industry() # A list of all companies will be produced

sqs_iri_industry(industry = "Automobile") # A list with all the variables including "Automobile" will be produced

sqs_iri_industry("Automobile")# A list with all the variables including "Automobile" will be produced
```

### Step 5: Getting the data

Once the user knows all the arguments, s.he can collect the data in a
very easy way through this
function:

``` r
sqs_iri_data(country = "USA", years = "2018", indicators = "RD.euro", company = "FORD MOTOR", industry = "Automobiles & Parts", rank = 14)  # It generates a data frame of the overall IRI data for American company "FORD MOTOR" in 2018.

sqs_iri_data(country=c("USA", "FRA"), years="2018",) # It generates a data frame of all the companies data from all the industries for the USA and France in 2018.

sqs_iri_data(years = "2018") # It generates a data frame of all the companies data for from all the industries for all the countries in 2018.

sqs_iri_data() # It generates a data frame of the complete dataset
```

### Cite ‘iriR’

…

### Why SQS ?

SQS stands for SKEMA Quantum Studio, a research and technological
development centre based in Montreal, Canada, that serves as the engine
room for the SKEMA Global lab in AI.

SKEMA Quantum Studio is also a state-of-the-art platform developed by
our team that enables scholars, students and professors to access one of
the most powerful analytical tools in higher education. By using data
science and artificial intelligence within the platform, new theories,
methods and concepts are being developed to study globalisation,
innovation and digital transformations that our society faces.

To learn more about the SKEMA Quantum Studio and the mission of the
SKEMA Global Lab in AI, please visit the following websites :
[SQS](https://quantumstudio.skemagloballab.io) ; [Global
Lab](https://skemagloballab.io/).

### Acknowledgments

The author would like to thank the Center for Interuniversity Research
and Analysis of Organizations (CIRANO, Montreal) for its support, as
well as Thibault Senegas, Marine Leroi and Martin Paquette at SKEMA
Global Lab in AI. The usual caveats apply.
