create or replace sequence database.schema_omop.geocode_seq start = 1 increment = 1;


create or replace secure view database.schema_omop.location_fips as 

select 
    database.schema_omop.geocode_seq.nextval  as geocode_id,
    loc.location_id as location_id,
    coalesce(
        case
            when length(GEOCODE_STATE) = 2 then GEOCODE_STATE
            else substring(GEOCODE_GROUP,1,2)
        end,
        ' ') as geocode_state,
    coalesce(
        case 
            when length(GEOCODE_COUNTY) = 3 then GEOCODE_COUNTY
            else substring(GEOCODE_GROUP,3,3)
        end,
        ' ') as geocode_county,
    coalesce(
        case 
            when length(GEOCODE_TRACT) = 6 then GEOCODE_TRACT
            else substring(GEOCODE_GROUP,6,6)
        end,
        ' ') as geocode_tract,
    coalesce(
        case 
            when length(GEOCODE_GROUP) = 1 then GEOCODE_GROUP
            else substring(GEOCODE_GROUP,12,1)
        end,
        ' ') as GEOCODE_GROUP,
    coalesce(
        case
            when trim(GEOCODE_CUSTOM_TEXT) = '2010' then 2010
            when trim(GEOCODE_CUSTOM_TEXT) = '2020' then 2020
            else null
        end,
        case
            when trim(GEO_PROV_REF) = '2010' then 2010
            when trim(GEO_PROV_REF) = '2020' then 2020
            else null
        end,
        0
    ) as geocode_year,
    SHAPEFILE as geocode_shapefile
from 
    database.schema_pcornet_deid.pcornet_deid_private_address_geocode pag
left join 
    (select
		addressid,
	 	patid,
		case
            when address_zip5 is not null then address_zip5
            else address_zip9
        end as zip
    from database.schema_pcornet_deid.pcornet_deid_lds_address_history
	) as lds
    on pag.addressid = lds.addressid
left join 
	database.schema_omop.location loc
	on loc.location_source_value like '%patient history%'
	and coalesce(lds.zip,'') = trim(split_part(loc.location_source_value,'|',2))
	and coalesce(pag.GEOCODE_STATE,'') = trim(split_part(loc.location_source_value,'|',4))
	and coalesce(pag.GEOCODE_COUNTY,'') = trim(split_part(loc.location_source_value,'|',5))
	and coalesce(pag.GEOCODE_TRACT ,'') = trim(split_part(loc.location_source_value,'|',6))
	and coalesce(pag.GEOCODE_GROUP ,'') = trim(split_part(loc.location_source_value,'|',7))
where
    loc.location_id is not null 
    and trim(pag.geocode_state) <> 'NA' 
    and pag.geocode_state is not null
;

