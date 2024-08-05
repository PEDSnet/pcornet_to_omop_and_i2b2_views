# PCORnet to OMOP and I2B2 Views

### This directory contains all SQL logic used to create OMOP and I2B2 Views on top of PCORnet CDM data within Snowflake.

## Prerequisites:

* A PCORnet modeled CDM loaded into a Snowflake database

## Process:
1. (setup folder) Create a set of de-identified (deid) PCORnet Tables. Patid, encounterid, facilityid, and providerid are made stable beforehand in corresponding map_id tables. All ids for deid tables are conveted to integers. 

2. (setup folder) Create and load data into OMOP vocabulary tables and additional mapping tables


3. (omop_views folder) Create a view for each OMOP table using the deid PCORnet tables and mapping tables. Any OMOP table that does not have a view mapping will have an empty table created.

4. (i2b2_views folder) Create a view for each I2B2 table using the deid PCORnet tables and mapping tables. Each obervation_fact domain has it's own view created in the format "domain_fact."

## Notes:
Database and schema names are generalized in code and may need to be changed. Names are as follows in code:

* database - "database"
* source pcornet cdm data schema - "schema_pcornet"
* Deid PCORnet CDM data dchema - "schema_pcornet_deid"
* OMOP data views schema - "schema_omop"
* I2B2 data views schema - "schema_i2b2"
