-- PROVIDER_DIMENSION
create or replace secure view database.schema_i2b2.PROVIDER_DIMENSION as 
    select 
        PROVIDERID as PROVIDER_ID,
        cast('@'  as VARCHAR(700)) as PROVIDER_PATH,
        cast(null as VARCHAR(850)) as NAME_CHAR,
        cast(null as text) as PROVIDER_BLOB,
        CURRENT_TIMESTAMP as UPDATE_DATE,
        CURRENT_TIMESTAMP as DOWNLOAD_DATE,
        CURRENT_TIMESTAMP as IMPORT_DATE,
        cast(null as VARCHAR(50))  s SOURCESYSTEM_CD,
        cast(null as INT) as UPLOAD_ID
    from 
        database.schema_pcornet_deid.pcornet_deid_PROVIDER as dim
;
