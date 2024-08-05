
create or replace secure view database.schema_omop.procedure_occurrence as 

SELECT distinct 
      row_number() over (order by proc.proceduresid)::bigint AS PROCEDURE_OCCURRENCE_ID,
      0 as modifier_concept_id,
      null as modifier_source_value,
      proc.patid,
      coalesce(
            case
                  when c_hcpcs.concept_id is not null AND c_hcpcs.standard_concept = 'S' then c_hcpcs.concept_id
                  when proc.px_type='CH' AND c_cpt.standard_concept = 'S' then c_cpt.concept_id
                  when proc.px_type='10' AND c_icd9.standard_concept = 'S' then c_icd9.concept_id
                  when proc.px_type='09' AND c_icd10.standard_concept = 'S' then c_icd10.concept_id
                  when proc.px_type='LC' AND c_loinc.standard_concept = 'S' then c_loinc.concept_id
                  when proc.px_type='ND' AND c_ndc.standard_concept = 'S' then c_ndc.concept_id
                  when wide_net.standard_concept = 'S' then wide_net.concept_id
		  	else cr_wide_net.concept_id_2
            end, 
            0) as procedure_concept_id,
      case 
            when proc.px_date is not null then proc.px_date::date
            when proc.admit_date is not null then proc.admit_date::date
            else '0001-01-01'::date
      end as procedure_date,
      null::date as procedure_end_date,
      case
            when proc.px_date is null then '0001-01-01'::timestamp
            else proc.px_date::timestamp
      end as procedure_datetime,
      null::timestamp as procedure_end_datetime,
      case
            when c_hcpcs.concept_id is not null then c_hcpcs.concept_id
            when proc.px_type='CH' then c_cpt.concept_id
            when proc.px_type='10' then c_icd9.concept_id
            when proc.px_type='09' then c_icd10.concept_id
            else 0 
      end as procedure_source_concept_id,
      proc.proceduresid as procedure_source_value,
      case 
            when proc.px_source = 'OD' and proc.ppx = 'P' then 2000001494
            when proc.px_source = 'OD' and proc.ppx <> 'P' then 38000275
            when proc.px_source ='BI' and proc.ppx = 'P' then 44786630
            when proc.px_source ='BI' and proc.ppx <> 'P' then 44786631
            else 44814650
      end AS procedure_type_concept_id,   
      enc.providerid as provider_id,
      null::bigint as quantity,
      proc.encounterid as visit_occurrence_id
FROM 
      database.schema_pcornet_deid.pcornet_deid_procedures proc
left join 
      database.schema_pcornet_deid.pcornet_deid_encounter enc 
      on proc.encounterid = enc.encounterid
left join 
      database.vocabulary.concept c_loinc
      on proc.px=c_loinc.concept_code 
      and proc.px_type='LC' 
      and c_loinc.vocabulary_id='LOINC'
left join 
      database.vocabulary.concept c_ndc
      on proc.px=c_ndc.concept_code 
      and proc.px_type='ND' 
      and c_ndc.vocabulary_id='NDC'   
left join 
      database.vocabulary.concept c_hcpcs
      on proc.px=c_hcpcs.concept_code 
      and proc.px_type='CH' 
      and c_hcpcs.vocabulary_id='HCPCS' 
      and proc.px REGEXP '[A-Z]'
left join 
      database.vocabulary.concept c_cpt
      on proc.px=c_cpt.concept_code 
      and proc.px_type='CH' 
      and c_cpt.vocabulary_id='CPT4'
left join 
      database.vocabulary.concept c_icd10
      on proc.px=c_icd10.concept_code 
      and proc.px_type='10' 
      and c_cpt.vocabulary_id='ICD10PCS'
 left join 
      database.vocabulary.concept c_icd9
      on proc.px=c_icd9.concept_code 
      and proc.px_type='09' 
      and c_cpt.vocabulary_id='ICD9CM'
left join 
      database.vocabulary.concept wide_net
      on proc.px = wide_net.concept_code 
left join 
      database.vocabulary.concept_relationship cr_wide_net
      on wide_net.concept_id = cr_wide_net.concept_id_1
      and cr_wide_net.relationship_id = 'Maps To';

													   
