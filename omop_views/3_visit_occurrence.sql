create or replace secure view database.schema_omop.visit_occurrence as 
SELECT distinct
    enc.encounterid AS visit_occurrence_id,
    vsrc.target_concept_id AS admitted_from_concept_id,
    coalesce(vsrc.SRC_TYPE_DISCRIPTION,'') || ' | ' || coalesce(enc.admitting_source,enc.raw_admitting_source) AS admitted_from_source_value,
    enc.facilityid as care_site_id,
    disp.target_concept_id AS discharged_to_concept_id,
    coalesce(disp.SRC_DISCHARGE_STATUS_DISCRP,'') || ' | ' || coalesce(enc.discharge_status,enc.raw_discharge_status) AS discharged_to_source_value,
    enc.patid AS person_id,
    NULL AS preceding_visit_occurrence_id,
    enc.providerid AS provider_id,
    coalesce(typ.source_concept_id::int,0) AS visit_concept_id,
    coalesce(
        case 
            when enc.discharge_date is not null then enc.discharge_date::date
            when enc.admit_date is not null then enc.admit_date::date
        end,
        '9999-12-31'::date
    ) AS visit_end_date,
    coalesce(
        case 
            when enc.discharge_date is not null then enc.discharge_date::timestamp
            when enc.admit_date is not null then enc.admit_date::timestamp
        end,
        '9999-12-31'::timestamp
     ) AS visit_end_datetime,
    0 AS visit_source_concept_id,
    enc.encounterid AS visit_source_value,
    enc.admit_date AS visit_start_date,
    (enc.admit_date)::timestamp AS visit_start_datetime,
    44818518 AS visit_type_concept_id
FROM 
    database.schema_pcornet_deid.pcornet_deid_encounter enc
LEFT JOIN 
    database.pcornet_maps.p2o_admitting_source_xwalk vsrc 
    ON vsrc.cdm_tbl = 'ENCOUNTER'
    AND vsrc.cdm_source = 'PCORnet'
    AND vsrc.src_admitting_source_type = enc.admitting_source
LEFT JOIN 
    database.pcornet_maps.p2o_discharge_status_xwalk disp 
    ON disp.cdm_tbl = 'ENCOUNTER'
    AND disp.cdm_source = 'PCORnet'
    AND disp.src_discharge_status = enc.discharge_status
left join 
    database.pcornet_maps.pcornet_pedsnet_valueset_map typ 
    on typ.target_concept = enc.enc_type 
    and typ.source_concept_class = 'Encounter type'
    and source_concept_id not in ('2000000469','42898160')
;                                 
