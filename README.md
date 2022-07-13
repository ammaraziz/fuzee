# Fuzee API
Interface to Fuzee API

# Installation

    install.packages("devtools")
    devtools::install_github("ammaraziz/fuzee")

# Usage
### Hash your password

1. Generate a hash of your password. Type the following into your console:

     openssl::md5("mypassword")

Where `mypassword` is the password to log into fuzee. Output will look like:

    % [1] "34819d7beeabb9260a5c854bc85b3e44"

Copy this hash, store it in a variable called `password`:

    password = "34819d7beeabb9260a5c854bc85b3e44"

Do not store your password in plain text. Use the hashed string.

### Download All Data

To download all data in a zip format, similar to the `Export All` button on Fuzee:

    fuzee(username = 'moe.doe@@email.com', 
          password = password,
          file = 'Desktop/all.zip')

Where `file` is the directory/filename to save the zip file. 

To uncompress the zip file in R, run the following: 

    unzip(zipfile = "location/to/zipfile",
		exdir = "location/to/extract",
		overwrite = TRUE)

### Download individual datasets
First authenticate using `auth` then download the dataset with `export_dataset`:

    cookie = auth(username = email, password = password)
    samples = export_dataset(dataset = "Samples - Received", cookie = cookie)

`export_datasets()` returns a dataframe.

Note: The `dataset` option must match one of the following:

	Samples - Storage
	Batches 
	BXA 
	Despatch 
	Egg Culture
	GA-PCRID
	GA-Pyro
	GA-Sequencing
	HI
	NAI
	Samples - Received
	Samples - Storage 
	Seqirus
	Shipments 
	VirusCulture 

Use `get_codes()` to see this list.

### Future Improvments:

Support direct querying of:

- Worksheets > Genetic Analysis > Show All
- Shipments > Search Shipments
- Shipments > Search Samples
