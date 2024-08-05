create or replace secure view database.schema_omop.care_site as 

with enc as (
    select 
        facilityid,
        max(facility_type) as facility_type,
        max(facility_location) as facility_location,
    from
        database.schema_pcornet_deid.pcornet_deid_encounter enc
    group by  
        facilityid  
)

SELECT 
    enc.care_site_id AS care_site_id,
    enc.facility_type AS care_site_name,
    enc.facilityid AS care_site_source_value,
    loc.location_id location_id,
    case
        when place.source_concept_id REGEXP '^[0-9]+$' then place.source_concept_id::int
        else 44814650
    end AS place_of_service_concept_id,
    substr(enc.facility_type, 1, 50) AS place_of_service_source_value,
    case
        when facility_spec.value_as_concept_id REGEXP '^[0-9]+$' then facility_spec.value_as_concept_id::int
        else 44814650
    end as specialty_concept_id,
    coalesce(
        facility_spec.target_concept,
        enc.facility_type
    ) as specialty_source_value
FROM 
   enc
 left join 
     database.pcornet_maps.pcornet_pedsnet_valueset_map facility_spec 
     on facility_spec.source_concept_class='Facility type'
     and enc.facility_type=facility_spec.target_concept
left join 
    database.pcornet_maps.pcornet_pedsnet_valueset_map place 
    on place.target_concept = enc.facility_type
    and place.source_concept_id is not null
    and place.value_as_concept_id is null
    and place.source_concept_class='Facility type'
left join 
    database.schema_omop.location loc 
    on enc.facility_location=loc.zip
WHERE 
    enc.facilityid is not null

union 
-- default care site

select
    9999999::Varchar as care_site_id,
    'n/a' as care_site_name,
    '9999999' as care_site_source_value,
    9999999 as location_id,
    44814650 as place_of_service_concept_id,
    'N/A' as place_of_service_source_value,
    44814650 as specialty_concept_id, 
    'N/A' as specialty_source_value
;
