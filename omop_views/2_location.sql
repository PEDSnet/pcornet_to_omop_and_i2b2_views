create or replace sequence database.schema_omop.loc_seq start = 1 increment = 1;

create or replace secure view database.schema_omop.location as

with t1 as (
-- care site locations
select 
    null as city,
    null as state,
	facility_location as zip,
	'encounter | ' || facility_location  as location_source_value,
    42046186 as country_concept_id,
    'United States' as country_source_value
 FROM database.schema_pcornet_deid.pcornet_deid_encounter enc
 WHERE enc.facilityid IS NOT NULL
 GROUP BY facility_location

 UNION

-- address history locations
select distinct
    address_city as city,
    address_state as state,
	zip as zip,
	'patient history | ' || coalesce(zip,'') || ' | geocode | ' || coalesce(GEOCODE_STATE,'') || ' | ' || coalesce(GEOCODE_COUNTY,'') || ' | ' || coalesce(GEOCODE_TRACT,'') || ' | ' || coalesce(GEOCODE_GROUP,'') as location_source_value,
    42046186 as country_concept_id,
    'United States' as country_source_value
FROM 
    (select 
        addressid,
        coalesce(address_zip5,address_zip9) as zip,
        address_city,
        address_state
    from database.schema_pcornet_deid.pcornet_deid_lds_address_history
	) as lds
left join 
    database.schema_pcornet_deid.pcornet_deid_private_address_geocode pag
    on pag.addressid = lds.addressid
where 
    trim(pag.geocode_state) <> 'NA' 
    and pag.geocode_state is not null
GROUP BY 
    zip, 
    address_city,
    address_state,
    GEOCODE_STATE,
    GEOCODE_COUNTY,
    GEOCODE_TRACT,
    GEOCODE_GROUP
)

select 
    database.schema_omop.loc_seq.nextval as location_id,
    city,
    state,
	zip,
	location_source_value,
    country_concept_id,
    country_source_value
from
    t1
UNION

select 
    9999999 as location_id,
    null as city,
    null as state,
	null as zip,
	null  as location_source_value,
    null as country_concept_id,
    null as country_source_value
;