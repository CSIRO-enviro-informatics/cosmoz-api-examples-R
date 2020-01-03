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
STATION_NO <- 21
# Endpoint to get a station's calibrations is "pipeline/rest/stations/{id}/calibration"
stations_endpoint <- paste0(COSMOZ_API_URL, "stations/")
station_endpoint <- paste0(stations_endpoint, STATION_NO)
station_cal_endpoint <- paste0(station_endpoint, "/calibration")

# Add a header to specifically ask for JSON output
request_headers <- list(Accept = "application/json")
x <- HttpClient$new(url = station_cal_endpoint, headers = request_headers)

res <- x$get()
content <- res$parse()
payload <- jsonlite::fromJSON(content)
count <- payload$meta$count
calibrations <- payload$calibrations
writeLines(paste("Calibrations Count:", count))
for (row in 1:nrow(calibrations)) {
  writeLines(paste("Calibration:", row))
  a <- unlist(calibrations[row,])
  key_vals <- paste0("\t", names(a), ": ", a)
  writeLines(key_vals)
  writeLines("")
}
