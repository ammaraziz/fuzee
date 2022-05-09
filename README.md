# Fuzee API
Interface to Fuzee API

# Installation

    install.packages("devtools")
    devtools::install_github("ammaraziz/fuzee")

# Usage
### Hash your password
To log into fuzee, create a hash of your password:

    openssl::md5("mypassword")
    % [1] "34819d7beeabb9260a5c854bc85b3e44"
Store this as `password`:

    password = "34819d7beeabb9260a5c854bc85b3e44"

### Export All button
    fuzee(username = 'moe.doe@@email.com', 
          password = password,
          file = 'Desktop/all.zip')

Where `file` is the directory/filename to save the zip file.

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
