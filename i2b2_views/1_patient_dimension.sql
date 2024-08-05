-- PATIENT_DIMENSION
create or replace secure view database.schema_i2b2.PATIENT_DIMENSION as 
    select 
        dim.patid as PATIENT_NUM,
        CASE
            WHEN dead.DEATH_DATE is not null THEN 'Y'
            ELSE 'N'
        END as VITAL_STATUS_CD,
        dim.birth_date :: TIMESTAMP as BIRTH_DATE, 
        cast(DEATH_DATE  as TIMESTAMP) as DEATH_DATE,
        COALESCE(dim.sex, 'NI') as SEX_CD,
        PAT_PREF_LANGUAGE_SPOKEN as LANGUAGE_CD,
        COALESCE(dim.hispanic, 'NI') as ethnicity_cd,
        CASE
            WHEN dim.RACE = '01' THEN 'American Indian or Alaska Native' 
            WHEN dim.RACE = '02' THEN 'Asian'
            WHEN dim.RACE = '03' THEN 'Black or African American'
            WHEN dim.RACE = '04' THEN 'Native Hawaiian or Other Pacific Islander'
            WHEN dim.RACE = '05' THEN 'White'
            WHEN dim.RACE = '06' THEN 'Multiple race'
            WHEN dim.RACE = '07' THEN 'Refuse to answer'
            WHEN dim.RACE = 'NI' THEN 'No information'
            WHEN dim.RACE = 'UN' THEN 'Unknown'
            WHEN dim.RACE = 'OT' THEN 'Other'
            ELSE 'No information'
        END AS RACE_CD,
        cast(null as VARCHAR(50)) AS MARITAL_STATUS_CD,
        cast(extract(year from birth_date) as integer) as AGE_IN_YEARS_NUM,
        cast(null as VARCHAR(50)) as RELIGION_CD,
        cast(coalesce(ADDRESS_ZIP9,ADDRESS_ZIP5) as VARCHAR(10)) as ZIP_CD,
        cast((ADDRESS_STATE || ' ' || ADDRESS_CITY || ' ' || coalesce(ADDRESS_ZIP9,ADDRESS_ZIP5)) as VARCHAR(700)) as STATECITYZIP_PATH,
        cast(null as VARCHAR(50)) as INCOME_CD,
        cast(null as text) as PATIENT_BLOB,
        CURRENT_TIMESTAMP as UPDATE_DATE,
        CURRENT_TIMESTAMP as DOWNLOAD_DATE,
        CURRENT_TIMESTAMP as IMPORT_DATE,
        cast(null as VARCHAR(50)) as SOURCESYSTEM_CD,
        cast(null	as INT) as UPLOAD_ID
    from 
        database.schema_pcornet_deid.pcornet_deid_DEMOGRAPHIC as dim
    left join database.schema_pcornet_deid.pcornet_deid_DEATH as dead  
        on dim.patid = dead.patid
    left join 
        (
            select 
                patid, 
                ADDRESS_ZIP5,
                ADDRESS_ZIP9,
                ADDRESS_CITY,
                ADDRESS_STATE
            from 
                (
                select 
                    patid, 
                    ADDRESS_ZIP5,
                    ADDRESS_ZIP9,
                    ADDRESS_CITY,
                    ADDRESS_STATE,
                    ROW_NUMBER() OVER 
                        (
                            PARTITION BY 
                                patid
                            ORDER BY 
                                ADDRESS_PERIOD_START desc
                        ) as row_num
                    from
                        database.schema_pcornet_deid.pcornet_deid_lds_address_history
                    where 
                        ADDRESS_ZIP5 is not null 
                        or ADDRESS_ZIP9 is not null
                ) as t1
            where row_num = 1
        ) as address
        on dim.patid = address.patid
;