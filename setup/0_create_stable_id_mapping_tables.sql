-- patid --> person_id map
create or replace sequence database.schema_pcornet.patid_map_seq start = 1 increment = 1;

create table database.schema_pcornet.map_patid as 
select 
    patid,
    database.schema_pcornet.patid_map_seq.nextval as person_id
from
    database.schema_pcornet.demographic;

-- encounterid --> visit_occurrence_id map
create or replace sequence database.schema_pcornet.encounterid_map_seq start = 1 increment = 1;

create table database.schema_pcornet.map_encounterid as 
select 
    encounterid,
    database.schema_pcornet.encounterid_map_seq.nextval as visit_occurrence_id
from
    database.schema_pcornet.encounter;

-- facilityid --> care_site_id map
create or replace sequence database.schema_pcornet.facilityid_map_seq start = 1 increment = 1;

create table database.schema_pcornet.map_facilityid as 
with t1 as (select distinct facilityid from database.schema_pcornet.encounter)
select 
    facilityid,
    database.schema_pcornet.facilityid_map_seq.nextval as care_site_id
from
    t1;

-- providerid --> provider_id map
create or replace sequence database.schema_pcornet.providerid_map_seq start = 1 increment = 1;

create table database.schema_pcornet.map_providerid as 
select 
    providerid,
    database.schema_pcornet.providerid_map_seq.nextval as provider_id
from
    database.schema_pcornet.provider;