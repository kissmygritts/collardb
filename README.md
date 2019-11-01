
# collardb

<!-- badges: start -->
<!-- badges: end -->

The goal of collardb is to make GPS telemtry data management simple. 

collardb will create a SQLite database to manage telemetry data, provide utilities to enter data into the database, and query data from the database. collardb will interface with the [collar](https://github.com/Huh/collar) package to assist with getting data directly from GPS sensor vendors into a relational database. 

## SQLite

SQLite is a C-language library that implements a small, fast, self-contained, high-reliability, full-featured, SQL database engine. SQLite is the most used database engine in the world. 

The SQLite file format is stable, cross-platform, and backwards compatible and the developers pledge to keep it that way through at least the year 2050. SQLite database files are commonly used as containers to transfer rich content between systems and as a long-term archival format for data. There are over 1 trillion (1e12) SQLite databases in active use.

SQLite source code is in the public-domain and is free to everyone to use for any purpose. 

*From [SQLite.org](https://sqlite.org/index.html)*

### Why SQLite

Because it is a simple single file database engine that can be used without a server. There are numerous extensions to make working with the data easier. There is even a spatial extension, [SpatiaLite](https://www.gaia-gis.it/fossil/libspatialite/index) that add a bunch of spatial data features. 

SQLite can be used as a data source in many common GIS software as well.

## Installation

You can install the package using the `devtools` package

``` r
devtools::install_github('kissmygritts/collardb')
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(collardb)

# bootstrap collardb sqlite database
bootstrap_collardb()

# create a database connection to inspect database
conn <- collardb_conn()

## check tables
DBI::dbListTables(conn)
#> [1] "animals" "deployments" "devices" "sqlite_sequence" "telemetry"
```

## Roadmap

*This package is very much a work-in-progress*

These will be the areas I focus on in the immediate future.

1. Bootstrap telemety database
    * complete schema
    * add views for quicker queries
    * add indexes for optimization
1. Data access
    * write data to database
    * read data from database
1. Interface with collar package
1. Write as [Shiny app](http://shiny.rstudio.com/) or [RStudio Addin](https://rstudio.github.io/rstudio-extensions/rstudio_addins.html)
1. Methods to extend the functionality
    * extend to PostgreSQL (maybe?)
1. Build and deploy as a SaaS (maybe?)
