# functions for pretty printing to console
success = function(text) { 
  write(paste0("\033[0;32m  -> ", text, "\033[0m"), stdout())
}
error = function(text) { 
  write(paste0("\033[0;31m  -> ", text, "\033[0m"), stdout())
}
warn = function(text) { 
  write(paste0("\033[0;33m  -> ", text, "\033[0m"), stdout())
}

#' Get Sheet Names or Codes
#' 
#' Return a list of sheet names and/or their codes
#' 
#' @details
#' List of data sheets available: 
#' Samples - Storage \cr
#' Batches \cr 
#' BXA \cr 
#' Despatch \cr 
#' Egg Culture \cr
#' GA-PCRID \cr
#' GA-Pyro \cr
#' GA-Sequencing \cr
#' HI \cr
#' NAI \cr
#' Samples - Received \cr
#' Samples - Storage  \cr
#' Seqirus \cr
#' Shipments  \cr
#' VirusCulture  \cr
#' @param pretty boolean. TRUE pretty print sheet names, FALSE returns a list
#' 
#' @export
get_codes = function(pretty = T){
  
  codes = list('Samples%20-%20Storage' = '000000000x2r4f6',
       'Batches' = '000000000x2r9ox',
       'BXA' = '000000000x2r7hh',
       'Despatch' = '000000000x2r4zr',
       'Egg Culture' = '000000000x2r4zs',
       'GA%20-%20PCR%20ID' = '000000000x2r4id',
       'GA%20-%20Pyro' = '000000000x2r4ie',
       'GA%20-%20Sequencing' = '000000000x2r4if',
       'HI' = '000000000x2r4ic',
       'NAI' = '000000000x2r4ib',
       'Samples%20-%20Received' = '000000000x2r4zq',
       'Samples%20-%20Storage' = '000000000x2r4f6',
       'Seqirus' = '000000000x2r5cu',
       'Shipments' = '000000000x2r8rd',
       'Virus%20Culture' = '000000000x2r4ia')
  
  if (isTRUE(pretty)) {
    success('List of data sheets avaliable: ')
    warn((gsub("%20", " ", names(codes))))
    } 
  if (isFALSE(pretty)) {
    return(codes)
    }
}

#' Generate Fuzee URL
#' 
#' Generate URL For Data Sheets
#' @param sheet_name The name of the data sheet
#' @seealso See `codes()` for a list
#' @return String - constructed URL
generate_data_url = function(sheet_name){
  
  sheet_name = gsub(pattern = ' ', '%20', sheet_name)
  data_codes = get_codes(pretty = F)
  
  if(!(sheet_name %in% names(data_codes))){
    error(paste0("Requested datasheet name '", sheet_name, "' Does not match data"))
    warn('Use function codes() to see available list of data sheets')
    stop("Error: See Above")
  }
  
  base_url = "https://my.fuzee.com/ajax?c=dataset&s=export2&code=_"
  params = "&params=e30=&filter=e30=&filter_type=e30=&sortby=e30=&name="
  
  url = paste0(base_url, data_codes[sheet_name], params, sheet_name)
  return(url)
}

#' Generate Fingerprint
#' 
#' Generate unique 32-bit string used as a fingerprint
#' Uses `openssl::md5` to generate hash
generate_fingerprint = function(){
  generate_random_string <- function(n = 5000) {
    a <- do.call(paste0, replicate(5, sample(LETTERS, n, TRUE), FALSE))
    paste0(a, sprintf("%04d", sample(9999, n, TRUE)), sample(LETTERS, n, TRUE))
  }
  return(openssl::md5(generate_random_string(1)))
}

#' Generate 16-bit string by random sampling letters and numbers
#' Used for device_id
generate_device_id = function(){
  return(
    paste0(sample(c(0:9, LETTERS[1:6], letters[1:6]), 16, T), collapse = '')
  )
}

#' Authenticate with Fuzee
#' 
#' POST request sent to Fuzee for authentication.
#' Password must be hashed with md5.
#' @param username String - Email used to log into fuzee
#' @param password String -  md5 hash of password, use openssl::md5 to generate hash
#' @return HTTP cookie used for GET requests downstream 
#' @export
#' @examples 
#' cookie = auth(username = 'moe.dong@@email.com', 
#'               password = 'd676b8d41fa96fd07bebe8c987513ab8')
auth = function(username, password) {
  login = list(
    email = username,
    password = password,
    fingerprint = generate_fingerprint(),
    device_id = generate_device_id()
    )
  
  warn('Authenticating....')
  
  rPost = httr::POST("https://my.fuzee.com/login", 
                body = login, 
                encode = "form", 
                httr::add_headers(.headers = c(
                  'User-Agent'= 'curl/7.80.0',
                  "Accept" = "*/*")),
                httr::set_cookies("FUZEESTAYLOGGEDIN" = "YES"),
                multipart = FALSE)
  httr::stop_for_status(rPost, "Authenticate")
  if( nrow(httr::cookies(rPost)) == 0 ){
    stop("Failed to Authenticate, No cookies were returned")
  }
  
  success('Authentication Successful')
  return(httr::cookies(rPost)$value)
}

#' Export Datasheet
#' 
#' Export a specific datasheet into a dataframe
#' A GET request is sent to fuzee for downloading a specific datasheet.
#' @param dataset String - Name of the sheet data to download. use `codes()` to get a complete list
#' @param cookie String - cookie for authentication returned by `auth`
#' @return a dataframe 
#' @seealso `codes()` to get a list of sheet names
#' @seealso `auth()` to authenticate with fuzee
#' @export
#' @examples 
#' batches = export_dataset(dataset = 'batches', cookie = cookie)
export_dataset = function(dataset, cookie){
  url = generate_data_url(dataset)
  warn('Data Request Sent....')
  warn('Downloading... this may take a while')
  rGet <- httr::GET(url = url,
              httr::set_cookies("FUZEEUSERAUTH" = cookie,
                          "FUZEESTAYLOGGEDIN" = "YES"),
              httr::progress())
  # error handling
  httr::stop_for_status(rGet, "Authenticate")
  if( nrow(httr::cookies(rGet)) == 0){
    error("Get request failed. No cookies were returned")
    stop('See above', )
  }  
  
  data = read.csv(text = httr::content(rGet, 'text', encoding = 'UTF-8'))
  
  success('Done!')
  return(data)
}

#' Export All Data
#' 
#' Replicates the 'Export all' button.
#' @param cookie for authentication, returned by `auth` function
#' @param file a character string naming a file
#' @export
#' @examples
#' cookie = auth(username = 'moe.doe@@email.com',
#'               password = 'md5hash') 
#' export_all(cookie = cookie, file = '~/Desktop/all.zip')
export_all = function(cookie, file) {
  url = 'https://my.fuzee.com/ajax?c=file&s=exportByCategory&code=_000000000x2r4f7'
  warn('Request Sent....')
  warn('Downloading....')
  
  # send request
  rGet <- httr::GET(url, httr::set_cookies("FUZEEUSERAUTH" = cookie,
                               "FUZEESTAYLOGGEDIN" = "YES"),
              httr::progress(),
              httr::write_disk(file))
  
  # error handling
    httr::stop_for_status(rGet, "Authenticate")
    if( nrow(httr::cookies(rGet)) == 0){
      error("Get request failed. No cookies were returned")
      stop('See above')
    }  
    if(is.na(file.size(file))){
      error('File was not created.')
    }
    if(file.size(file) == 0L){
      error('File is empty. Check cookies or reauthenticate')
    }
  
  success('Finished.')
  return(rGet)
}

#' Authenticate and Export All
#' 
#' Helper function which wraps auth() and export_all()
#' Use this for a one-iner
#' @param username String - Email used to log into fuzee
#' @param password String -  md5 hash of password, use openssl::md5 to generate hash
#' @param file String - location/file name to save zip file
#' @return Returns Nothing!
#' @export
#' @examples
#' fuzee(username = 'moe.doe@@email.com', 
#'        password = 'd676b8d41fa96fd07bebe8c987513ab8',
#'        file = 'Desktop/all.zip')
fuzee = function(username, password, file) {
  cookie = auth(username, password)
  export_all(cookie, file)
}

# untested
get_genetic_batch = function(batch_number, cookie) {
  base_url = 'http://my.fuzee.com/ajax?c=DataSet&s=getData&code=Q_000000000x2r03s&start=0&page_size=1000&params[batch]='
  url = paste0(base_url, batch_number)
  
  warn('Data Request Sent....')
  rGet <- httr::GET(url = url,
                    httr::set_cookies("FUZEEUSERAUTH" = cookie,
                                      "FUZEESTAYLOGGEDIN" = "YES"),
                    httr::progress())
  # error handling
  httr::stop_for_status(rGet, "Authenticate")
  if( nrow(httr::cookies(rGet)) == 0){
    error("Get request failed. No cookies were returned")
    stop('See above', )
  }  
  
  json = read.csv(text = httr::content(rGet, 'application/json', encoding = 'UTF-8'))
  data = json$rows
  
  success('Done!')
  return(data)
}
  