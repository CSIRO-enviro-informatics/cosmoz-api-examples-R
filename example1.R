#!/bin/Rscript
# Copyright 2019-2020 CSIRO Land and Water
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#
#This example gets a list of stations from the API endpoint
#
library("crul")
library("jsonlite")

COSMOZ_API_URL <- "https://esoil.io/cosmoz-data-pipeline/rest/"  # Keep the trailing slash on here
# Endpoint to get all stations is "pipeline/rest/stations/"
stations_endpoint <- paste0(COSMOZ_API_URL, "stations/")
# Add a header to specifically ask for JSON output
request_headers <- list(Accept = "application/json")
x <- HttpClient$new(url = stations_endpoint, headers = request_headers)

res <- x$get()
content <- res$parse()
payload <- jsonlite::fromJSON(content)
count <- payload$meta$count
stations <- payload$stations
writeLines(paste("Stations Count:", count))
for (row in 1:nrow(stations)) {
  writeLines(paste("Station:", row))
  a <- unlist(stations[row,])
  key_vals <- paste0("\t", names(a), ": ", a)
  writeLines(key_vals)
  writeLines("")
}
