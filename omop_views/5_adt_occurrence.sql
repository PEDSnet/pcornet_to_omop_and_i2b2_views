create or replace sequence database.schema_omop.adt_seq start = 1 increment = 1;

-- insert obs_gen covid ICU admissions into adt_occurrence
create or replace secure view database.schema_omop.adt_occurrence as 
select 
    database.schema_omop.adt_seq.nextval as adt_occurrence_id,
    og.patid AS person_id,   
    og.encounterid as visit_occurrence_id,
    case 
        when og.OBSGEN_START_DATE is not null then og.OBSGEN_START_DATE::date
        when og.OBSGEN_START_DATE is not null then og.OBSGEN_START_DATE::date
        else '0001-01-01'::date
    end as adt_date,
    case
        when og.OBSGEN_START_DATE is null then '0001-01-01'::timestamp
        else og.OBSGEN_START_DATE::timestamp
    end as adt_datetime,
    enc.facilityid as care_site_id,
    2000000078 as service_concept_id, --PICU
    2000000083 as adt_type_concept_id, --admission
    'obs_gen ' || OBSGEN_TYPE || ' ' || OBSGEN_CODE as service_source_value
from 
    database.schema_pcornet_deid.pcornet_deid_obs_gen og
left join 
    database.schema_pcornet_deid.pcornet_deid_encounter enc
    on og.encounterid = enc.encounterid
where 
    OBSGEN_TYPE= 'PC_COVID'
    and OBSGEN_CODE = '2000'
    and OBSGEN_RESULT_TEXT <> 'N'
    and enc.encounterid is not null

union

-- insert ICU submissions that are procedures
select
    database.schema_omop.adt_seq.nextval as adt_occurrence_id,
    proc.patid AS person_id,   
    proc.encounterid as visit_occurrence_id,
    case 
        when proc.px_date is not null then proc.px_date::date
        when proc.admit_date is not null then proc.admit_date::date
        else '0001-01-01'::date
    end as adt_date,
    case
        when proc.px_date is null then '0001-01-01'::timestamp
        else proc.px_date::timestamp
    end as adt_datetime,
    enc.facilityid as care_site_id,
    2000000078 as service_concept_id, --PICU
    2000000083 as adt_type_concept_id, --admission
    'procedures ' || px || ' ' || raw_px as service_source_value
from 
    database.schema_pcornet_deid.pcornet_deid_procedures proc 
LEFT JOIN
    database.schema_pcornet_deid.pcornet_deid_encounter enc
    on enc.encounterid = proc.encounterid
where
    enc.encounterid is not null
    and px in (
        '99291', -- ICU
        '99292', -- ICU
        '99293', -- PICU
        '99294' -- PICU
    )
;

