
-- DEMOGRAPHIC_FACT
create or replace secure view database.schema_i2b2.DEMOGRAPHIC_FACT as 
    -- demographic hispanic
    select
        cast(-1 as integer) as ENCOUNTER_NUM, 
        PATIENT_NUM, 
        concat('DEM|HISP:', COALESCE(dim.HISPANIC, 'NI')) as CONCEPT_CD,
        '@' as PROVIDER_ID, 
        CURRENT_TIMESTAMP as START_DATE,  
        '@' as MODIFIER_CD,
        1 as INSTANCE_NUM, 
        '' as VALTYPE_CD,
        '' as TVAL_CHAR, 
        cast(null as integer) as NVAL_NUM, 
        '' as VALUEFLAG_CD,
        cast(null as integer) as QUANTITY_NUM, 
        '@' as UNITS_CD, 
        cast(null as TIMESTAMP) as END_DATE, 
        '@' as LOCATION_CD, 
        cast(null as text) as OBSERVATION_BLOB, 
        cast(null as integer) as CONFIDENCE_NUM, 
        CURRENT_TIMESTAMP as UPDATE_DATE,
        CURRENT_TIMESTAMP as DOWNLOAD_DATE,
        CURRENT_TIMESTAMP as IMPORT_DATE,
        cast(null as VARCHAR(50)) as SOURCESYSTEM_CD,
        cast(null as integer) as UPLOAD_ID
    from 
        database.schema_i2b2.PATIENT_DIMENSION as dim
    union all 
    -- demographic race
    select
        cast(-1 as integer) as ENCOUNTER_NUM, 
        PATIENT_NUM, 
        CASE
            WHEN dim.RACE_CD =  'American Indian or Alaska Native' THEN  concat('DEM|RACE:', 'NA')
            WHEN dim.RACE_CD =  'Asian' THEN  concat('DEM|RACE:', 'AS')
            WHEN dim.RACE_CD =  'Black or African American' THEN  concat('DEM|RACE:', 'B')
            WHEN dim.RACE_CD =  'Native Hawaiian or Other Pacific Islander' THEN  concat('DEM|RACE:', 'H')
            WHEN dim.RACE_CD =  'White' THEN  concat('DEM|RACE:', 'W')
            WHEN dim.RACE_CD =  'Multiple race' THEN  concat('DEM|RACE:', 'M')
            WHEN dim.RACE_CD =  'Refuse to answer' THEN  concat('DEM|RACE:', '07')
            WHEN dim.RACE_CD =  'No information' THEN  concat('DEM|RACE:', 'NI')
            WHEN dim.RACE_CD =  'Unknown' THEN  concat('DEM|RACE:', 'UN')
            WHEN dim.RACE_CD =  'Other' THEN  concat('DEM|RACE:', 'OT')
            ELSE concat('DEM|RACE:', 'NI')
        END as CONCEPT_CD,
        '@' as PROVIDER_ID, 
        CURRENT_TIMESTAMP as START_DATE,  
        '@' as MODIFIER_CD,
        1 as INSTANCE_NUM, 
        '' as VALTYPE_CD,
        '' as TVAL_CHAR, 
        cast(null as integer) as NVAL_NUM, 
        '' as VALUEFLAG_CD,
        cast(null as integer) as QUANTITY_NUM, 
        '@' as UNITS_CD, 
        cast(null as TIMESTAMP)  as END_DATE, 
        '@' as LOCATION_CD, 
        cast(null as text) as OBSERVATION_BLOB, 
        cast(null as integer) as CONFIDENCE_NUM, 
        CURRENT_TIMESTAMP as UPDATE_DATE,
        CURRENT_TIMESTAMP as DOWNLOAD_DATE,
        CURRENT_TIMESTAMP as IMPORT_DATE,
        cast(null as VARCHAR(50)) as SOURCESYSTEM_CD,
        cast(null as integer) as UPLOAD_ID
    from 
        database.schema_i2b2.PATIENT_DIMENSION as dim
    union all 
    --SEX
    select
        cast(-1 as integer) as ENCOUNTER_NUM, 
        PATIENT_NUM, 
        concat('DEM|SEX:', COALESCE(dim.SEX_CD, 'NI')) as CONCEPT_CD,
        '@' as PROVIDER_ID, 
        CURRENT_TIMESTAMP as START_DATE,  
        '@' as MODIFIER_CD,
        1 as INSTANCE_NUM, 
        '' as VALTYPE_CD,
        '' as TVAL_CHAR, 
        cast(null as integer) as NVAL_NUM, 
        '' as VALUEFLAG_CD,
        cast(null as integer) as QUANTITY_NUM, 
        '@' as UNITS_CD, 
        cast(null as TIMESTAMP)  as END_DATE, 
        '@' as LOCATION_CD, 
        cast(null as text) as OBSERVATION_BLOB, 
        cast(null as integer) as CONFIDENCE_NUM, 
        CURRENT_TIMESTAMP as UPDATE_DATE,
        CURRENT_TIMESTAMP as DOWNLOAD_DATE,
        CURRENT_TIMESTAMP as IMPORT_DATE,
        cast(null as VARCHAR(50)) as SOURCESYSTEM_CD,
        cast(null as  integer) as UPLOAD_ID
    from 
        database.schema_i2b2.PATIENT_DIMENSION as dim
    union all 
    --VITAL STATUS
    select
        cast(-1 as integer) as ENCOUNTER_NUM, 
        PATIENT_NUM, 
        CASE
            WHEN VITAL_STATUS_CD = 'Y' THEN 'DEM|VITAL STATUS:D'
            ELSE '@'
        END as CONCEPT_CD,
        '@' as PROVIDER_ID, 
        CURRENT_TIMESTAMP as START_DATE,  
        '@' as MODIFIER_CD,
        1 as INSTANCE_NUM, 
        '' as VALTYPE_CD,
        '' as TVAL_CHAR, 
        cast(null asinteger) as NVAL_NUM, 
        '' as VALUEFLAG_CD,
        cast(null as integer) as QUANTITY_NUM, 
        '@' as UNITS_CD, 
        cast(null as TIMESTAMP) as END_DATE, 
        '@' as LOCATION_CD, 
        cast(null as text) as OBSERVATION_BLOB, 
        cast(null as integer) as CONFIDENCE_NUM, 
        CURRENT_TIMESTAMP as UPDATE_DATE,
        CURRENT_TIMESTAMP as DOWNLOAD_DATE,
        CURRENT_TIMESTAMP as IMPORT_DATE,
        cast(null as VARCHAR(50)) as SOURCESYSTEM_CD,
        cast(null as integer) as UPLOAD_ID
    from 
        database.schema_i2b2.PATIENT_DIMENSION as dim;

-- DIAGNOSIS_FACT
create table database.schema_i2b2.DIAGNOSIS_FACT as 
    with extract as (
        select
            ENCOUNTERID as ENCOUNTER_NUM, 
            PATID as PATIENT_NUM, 
            case
                when dx_type = '10' then concat('ICD10CM:', dx)
                when dx_type = '09' then 
                    case --icd9 trailing '.' dots
                            when right(dx, 1) = '.' then  concat('ICD9CM:', split_part(dx, '.', 1))
                            else concat('ICD9CM:', dx)
                    end
                when dx_type = 'SM' then concat('SNOMED:', dx)
                else concat(dx_type, ':', dx)
            end as CONCEPT_CD,
            COALESCE(PROVIDERID, '@') as PROVIDER_ID, 
            coalesce(DX_DATE, ADMIT_DATE) :: TIMESTAMP as START_DATE,  
            '@' as MODIFIER_CD,
            1 as INSTANCE_NUM, 
            '' as VALTYPE_CD,
            '' as TVAL_CHAR, 
            cast(null as  integer)as NVAL_NUM, 
            '' as VALUEFLAG_CD,
            cast(null as  integer) as QUANTITY_NUM, 
            '@' as UNITS_CD, 
            cast(null as TIMESTAMP) as END_DATE, 
            '@' as LOCATION_CD, 
            cast(null as  text) as OBSERVATION_BLOB, 
            cast(null as  integer) as CONFIDENCE_NUM, 
            CURRENT_TIMESTAMP as UPDATE_DATE,
            CURRENT_TIMESTAMP as DOWNLOAD_DATE,
            CURRENT_TIMESTAMP as IMPORT_DATE,
            cast(null as VARCHAR(50)) as SOURCESYSTEM_CD,
            cast(null as  integer)  as UPLOAD_ID,
        from 
            database.schema_pcornet_deid.pcornet_deid_DIAGNOSIS
    ),

    find_dups as (
        select 
            *,
            ROW_NUMBER() over (partition by patient_num, start_date, end_date, encounter_num, concept_cd) as row_num
        from 
            extract
    )

    select
        ENCOUNTER_NUM,
        PATIENT_NUM,
        CONCEPT_CD,
        PROVIDER_ID,
        START_DATE,
        MODIFIER_CD,
        INSTANCE_NUM,
        VALTYPE_CD,
        TVAL_CHAR,
        NVAL_NUM,
        VALUEFLAG_CD,
        QUANTITY_NUM,
        UNITS_CD,
        END_DATE,
        LOCATION_CD,
        OBSERVATION_BLOB,
        CONFIDENCE_NUM,
        UPDATE_DATE,
        DOWNLOAD_DATE,
        IMPORT_DATE,
        SOURCESYSTEM_CD,
        UPLOAD_ID
    from 
        find_dups
    where 
        row_num = 1
;
