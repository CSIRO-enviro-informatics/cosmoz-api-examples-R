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
# This example gets some Sensor Observations from a given Cosmoz station, with observations aggregated 512 steps,
# and plots it using built-in R plotting routines.
#
library("crul")
library("jsonlite")

COSMOZ_API_URL <- "https://esoil.io/cosmoz-data-pipeline/rest/"  # Keep the trailing slash on here
STATION_NO <- 21
PROCESSING_LEVEL <- 4  # Choose processing level 1, 2, 3, 4, or 0 (for Raw)

# Endpoint to get a station's calibrations is "pipeline/rest/stations/{id}/observations"
stations_endpoint <- paste0(COSMOZ_API_URL, "stations/")
station_endpoint <- paste0(stations_endpoint, STATION_NO)
station_obs_endpoint <- paste0(station_endpoint, "/observations")

# Time Period Start Date
start_date <- as.POSIXlt("2019-1-1", "UTC", "%Y-%m-%d")
start_date_str <- strftime(start_date , "%Y-%m-%dT%H:%M:%S.000Z") # ISO8601 Format
# Time Period End Date
end_date <- as.POSIXlt("2019-1-31", "UTC", "%Y-%m-%d")
end_date_str <- strftime(end_date , "%Y-%m-%dT%H:%M:%S.000Z") # ISO8601 Format

# Aggregate the whole month into 512 slices
t_delta <- difftime(end_date, start_date, "UTC")
delta_seconds <- as.numeric(t_delta, units="secs")
# Use 511, because there are 511 steps in 512 slices
step_seconds <- delta_seconds %/% 511  # Integer divide, not floating point
if ((step_seconds %% 511) != 0) {
    step_seconds <- step_seconds + 1  # Add one if the total seconds doesn't divide cleanly into 511
}
# Add request query params
query_params <- list("processing_level" = PROCESSING_LEVEL,
              "startdate" = start_date_str,
              "enddate" = end_date_str,
              "aggregate" = paste0(step_seconds, "s")) # Set aggregation to steps
q_string <- paste(paste0(names(query_params), "=",query_params), collapse="&")
station_obs_url <- paste0(station_obs_endpoint, "?", q_string)

# Add a header to specifically ask for JSON output
request_headers <- list(Accept = "application/json")
x <- HttpClient$new(url = station_obs_url, headers = request_headers)

res <- x$get()
content <- res$parse()
payload <- jsonlite::fromJSON(content)
count <- payload$meta$count
observations <- payload$observations
p <- plot(observations[,"mean_soil_moist_filtered"],
     ylim=c(0,20), yaxs="i", type="o",
     ylab = "Volumetric soil moisture m³/m³",
     xlab = "time slice count",
     main="Example of plotting soil moisture for one month.")
box()
