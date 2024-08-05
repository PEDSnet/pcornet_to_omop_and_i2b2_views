
--procedure_fact
create or replace secure view database.schema_i2b2.PROCEDURE_FACT as 
    with extract as (
        select
            ENCOUNTERID            as ENCOUNTER_NUM, 
            PATID              as PATIENT_NUM, 
            case 
                when px_type = '10' then concat('ICD10PCS:',px)
                when px_type = '09' then concat('ICD9PROC:',px)
                when px_type = 'CH' then concat('CPT4',':', px)
                when px_type = 'LC' then concat('LOINC:',px)
                when px_type = 'ND' then concat('NDC:',px)
                else concat(px_type,':',px)
            end                     as CONCEPT_CD,
            COALESCE(fact.PROVIDERID, '@') as PROVIDER_ID, 
            coalesce(PX_DATE, ADMIT_DATE) :: TIMESTAMP as START_DATE,  
            '@'                     as MODIFIER_CD,
            1                       as INSTANCE_NUM, 
            ''                      as VALTYPE_CD,
            ''                      as TVAL_CHAR, 
            cast(null as  integer)  as NVAL_NUM, 
            ''                      as VALUEFLAG_CD,
            cast(null as  integer)  as QUANTITY_NUM, 
            '@'                     as UNITS_CD, 
            cast(null  	as TIMESTAMP) as END_DATE, 
            '@'                     as LOCATION_CD, 
            cast(null as  text)     as OBSERVATION_BLOB, 
            cast(null as  integer)  as CONFIDENCE_NUM, 
            CURRENT_TIMESTAMP       as UPDATE_DATE,
            CURRENT_TIMESTAMP       as DOWNLOAD_DATE,
            CURRENT_TIMESTAMP       as IMPORT_DATE,
            cast(null as VARCHAR(50)) as SOURCESYSTEM_CD,
            cast(null as  integer)  as UPLOAD_ID
        from 
            database.schema_pcornet_deid.pcornet_deid_PROCEDURES fact
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