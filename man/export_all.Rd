% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/fuzee.R
\name{export_all}
\alias{export_all}
\title{Export All Data}
\usage{
export_all(cookie, file)
}
\arguments{
\item{cookie}{for authentication, returned by \code{auth} function}

\item{file}{a character string naming a file}
}
\description{
Replicates the 'Export all' button.
}
\examples{
cookie = auth(username = 'moe.doe@email.com',
              password = 'md5hash') 
export_all(cookie = cookie, file = '~/Desktop/all.zip')
}
