-- VISIT_DIMENSION
create or replace secure view chop_i2b2.VISIT_DIMENSION as 
    select
        dim.ENCOUNTERid as ENCOUNTER_NUM, 
        dim.patid as PATIENT_NUM,
        cast(null as VARCHAR(50)) as ACTIVE_STATUS_CD,
        TO_TIMESTAMP(admit_date :: DATE || ' ' || admit_time, 'YYYY-MM-DD HH24:MI:SS') AS start_date,
        TO_TIMESTAMP(COALESCE(discharge_date, admit_date) :: DATE || ' ' || COALESCE(discharge_time, '23:59:59'), 'YYYY-MM-DD HH24:MI:SS') AS end_date,
        ENC_TYPE as INOUT_CD,
        FACILITY_LOCATION as LOCATION_CD,
        cast(null as VARCHAR(900)) as LOCATION_PATH,
        coalesce(discharge_date - admit_date, 0) as length_of_stay,
        cast(null as text) as VISIT_BLOB,
        CURRENT_TIMESTAMP as UPDATE_DATE,
        CURRENT_TIMESTAMP as DOWNLOAD_DATE,
        CURRENT_TIMESTAMP as IMPORT_DATE,
        cast(null as VARCHAR(50)) as SOURCESYSTEM_CD,
        cast(null as  integer) as UPLOAD_ID
    from 
        database.schema_pcornet_deid.pcornet_deid_ENCOUNTER as dim
;   
