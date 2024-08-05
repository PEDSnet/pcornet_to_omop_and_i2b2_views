create or replace sequence database.schema_omop.loc_hist_seq start = 1 increment = 1;


create or replace secure view database.schema_omop.location_history as 

select distinct
 	addressid::bigint as location_history_id,
	'Person' as domain_id,
	address_period_end::date as end_date,
	address_period_end::timestamp as end_datetime,
	lds.patid as entity_id,
	loc.location_id as location_id,
	44814653 as location_preferred_concept_id,
	0 as relationship_type_concept_id,
	address_period_start::date as start_date,
	address_period_start::timestamp as start_datetime
from
	(select
		addressid,
	 	patid,
	 	address_period_start,
	 	address_period_end,
		case
            when address_zip5 is not null then address_zip5
            else address_zip9
        end as zip
    from database.schema_pcornet_deid.pcornet_deid_lds_address_history
	) as lds
left join 
    database.schema_pcornet_deid.pcornet_deid_private_address_geocode pag
    on pag.addressid = lds.addressid
left join 
	database.schema_omop.location loc
	on loc.location_source_value like '%patient history%'
	and coalesce(lds.zip,'') = trim(split_part(loc.location_source_value,'|',2))
	and coalesce(pag.GEOCODE_STATE,'') = trim(split_part(loc.location_source_value,'|',4))
	and coalesce(pag.GEOCODE_COUNTY,'') = trim(split_part(loc.location_source_value,'|',5))
	and coalesce(pag.GEOCODE_TRACT ,'') = trim(split_part(loc.location_source_value,'|',6))
	and coalesce(pag.GEOCODE_GROUP ,'') = trim(split_part(loc.location_source_value,'|',7))
;

