create or replace sequence database.schema_omop.cond_occ_seq start = 1 increment = 1;

-- problem_list
create or replace secure view database.schema_omop.condition_occurrence as 
SELECT distinct
    coalesce(
        case
            --covid diagnosis codes
            when cond.condition = '398447004' then 320651::int
            when cond.condition = '713084008' then 37016927::int
            when cond.condition = '1240521000000100' then 37310254::int
            when cond.condition = '1240441000000108' then 37310260::int
            when cond.condition = '1240571000000101' then 37310283::int
            when cond.condition = '1240561000000108' then 37310284::int
            when cond.condition = '1240551000000105' then 37310285::int
            when cond.condition = '1240541000000107' then 37310286::int
            when cond.condition = '1240531000000103' then 37310287::int
            when cond.condition = '840546002' then 37311059::int
            when cond.condition = '840539006' then 37311061::int
            when cond.condition = '441590008' then 40479642::int
            when cond.condition = '444482005' then 40479782::int
            when cond.condition = '408688009' then 4248811::int
            when cond.condition = '186747009' then 439676::int
            when cond.condition = '702547000' then 45765578::int
            when cond.condition = '840544004' then 37311060::int
            when cond.condition = '840533007' then 37311065::int
            when cond.condition = '138389411000119105' then 3661405::int
            when cond.condition = '674814021000119106' then 3661406::int
            when cond.condition = '882784691000119100' then 3661408::int
            when cond.condition = '189486241000119100' then 3662381::int
            when cond.condition = '880529761000119102' then 3663281::int
            when cond.condition = '870588003' then 3655975::int
            when cond.condition = '870590002' then 3655976::int
            when cond.condition = '870591003' then 3655977::int
            when cond.condition = '119731000146105' then 3656667::int
            when cond.condition = '119741000146102' then 3656668::int
            when cond.condition = '119981000146107' then 3656669::int
            when cond.condition = '866152006' then 3661632::int
            when cond.condition = '870589006' then 3661748::int
            when cond.condition = '119751000146104' then 3661885::int
            when cond.condition = '292508471000119000' then 3661980::int
            when cond.condition = '870577009' then 3655973::int
            when cond.condition = '1240581000000100' then 37310282::int
            when cond.condition = '870577009' then 3655973::int
            when cond.condition_type='09' or cond.condition_type='ICD09' then cr_icd9.concept_id_2
            when cond.condition_type='10' or cond.condition_type='ICD10' then cr_icd10.concept_id_2
            when cond.condition_type='SM' then c_snomed.concept_id
             -- RegEx for ICD09 codes if condition_type <>'09' 
            when cond.condition REGEXP '^V[0-9]{2}.?[0-9]{0,2}$' then cr_icd9.concept_id_2
            when cond.condition REGEXP '^E[0-9]{3}.?[0-9]?$' then cr_icd9.concept_id_2
            when cond.condition REGEXP '^[0-9]{3}.?[0-9]{0,2}$' then cr_icd9.concept_id_2
            -- RegEx for ICD10 codes if condition_type <>'10' 
            when cond.condition REGEXP '^[A-Z][0-9][0-9A-Z].?[0-9A-Z]{0,4}$' then cr_icd10.concept_id_2
            else NULL
        end, 
    44814650)::int as condition_concept_id,
    coalesce(
        case
            when cond.condition_type='09' then c_icd9.concept_id
            when cond.condition_type='10' then c_icd10.concept_id
            when cond.condition_type='SM' then c_snomed.concept_id
            -- RegEx for ICD09 codes if condition_type <>'09' 
            when cond.condition REGEXP '^V[0-9]{2}.?[0-9]{0,2}$' then c_icd9.concept_id
            when cond.condition REGEXP '^E[0-9]{3}.?[0-9]?$' then c_icd9.concept_id
            when cond.condition REGEXP '^[0-9]{3}.?[0-9]{0,2}$' then c_icd9.concept_id
            -- RegEx for ICD10 codes if condition_type <>'10' 
            when cond.condition REGEXP '^[A-Z][0-9][0-9A-Z].?[0-9A-Z]{0,4}$' then c_icd10.concept_id
            else NULL
        end,
    44814650)::int as condition_source_concept_id,
    left(coalesce(cond.condition, ''),248) || ' | ' || coalesce(cond.condition_type,'') as condition_source_value,
    cond.resolve_date::date as condition_end_date,
    cond.resolve_date::timestamp as condition_end_datetime,
    database.schema_omop.cond_occ_seq.nextval  as condition_occurrence_id,
    case 
        when cond.onset_date::varchar is not null then cond.onset_date::date
        when cond.report_date is not null then cond.report_date::date
	    else '0001-01-01'::date
    end as condition_start_date,
    case 
        when cond.onset_date is not null then cond.onset_date::timestamp
        when cond.report_date is not null then cond.report_date::timestamp
	    else '0001-01-01'::timestamp
    end as condition_start_datetime,
    4230359 AS condition_status_concept_id,
    coalesce(cond.CONDITION_STATUS,cond.raw_condition_status) AS condition_status_source_value,
    2000000089 as condition_type_concept_id,
    cond.patid AS person_id,   
    44814650 as poa_concept_id, 
    enc.providerid as provider_id,   
    NULL as stop_reason,    
    cond.encounterid as visit_occurrence_id   
FROM 
    (
        select *
        from database.schema_pcornet_deid.pcornet_deid_condition
        where condition <> 'COVID'
    ) as cond
left join 
    database.schema_pcornet_deid.pcornet_deid_encounter enc
    on cond.encounterid=enc.encounterid
left join 
    database.vocabulary.concept c_icd9 
    on cond.condition=c_icd9.concept_code
    and c_icd9.vocabulary_id='ICD9CM'
left join 
    database.vocabulary.concept c_icd10 
    on cond.condition=c_icd10.concept_code
    and c_icd10.vocabulary_id='ICD10CM'
left join 
    database.vocabulary.concept c_snomed 
    on cond.condition=c_snomed.concept_code
    and c_snomed.vocabulary_id='SNOMED' 
    and cond.condition_type='SM'
left join 
    database.vocabulary.concept_relationship cr_icd9
    on c_icd9.concept_id = cr_icd9.concept_id_1
    and cr_icd9.relationship_id='Maps to'
left join 
    database.vocabulary.concept_relationship cr_icd10
    on c_icd10.concept_id = cr_icd10.concept_id_1
    and cr_icd10.relationship_id='Maps to'

union

-- visit diagnoses
SELECT distinct
    coalesce(
        case
            --covid diagnosis codes
            when cond.dx = '398447004' then 320651::int
            when cond.dx = '713084008' then 37016927::int
            when cond.dx = '1240521000000100' then 37310254::int
            when cond.dx = '1240441000000108' then 37310260::int
            when cond.dx = '1240571000000101' then 37310283::int
            when cond.dx = '1240561000000108' then 37310284::int
            when cond.dx = '1240551000000105' then 37310285::int
            when cond.dx = '1240541000000107' then 37310286::int
            when cond.dx = '1240531000000103' then 37310287::int
            when cond.dx = '840546002' then 37311059::int
            when cond.dx = '840539006' then 37311061::int
            when cond.dx = '441590008' then 40479642::int
            when cond.dx = '444482005' then 40479782::int
            when cond.dx = '408688009' then 4248811::int
            when cond.dx = '186747009' then 439676::int
            when cond.dx = '702547000' then 45765578::int
            when cond.dx = '840544004' then 37311060::int
            when cond.dx = '840533007' then 37311065::int
            when cond.dx = '138389411000119105' then 3661405::int
            when cond.dx = '674814021000119106' then 3661406::int
            when cond.dx = '882784691000119100' then 3661408::int
            when cond.dx = '189486241000119100' then 3662381::int
            when cond.dx = '880529761000119102' then 3663281::int
            when cond.dx = '870588003' then 3655975::int
            when cond.dx = '870590002' then 3655976::int
            when cond.dx = '870591003' then 3655977::int
            when cond.dx = '119731000146105' then 3656667::int
            when cond.dx = '119741000146102' then 3656668::int
            when cond.dx = '119981000146107' then 3656669::int
            when cond.dx = '866152006' then 3661632::int
            when cond.dx = '870589006' then 3661748::int
            when cond.dx = '119751000146104' then 3661885::int
            when cond.dx = '292508471000119000' then 3661980::int
            when cond.dx = '870577009' then 3655973::int
            when cond.dx = '1240581000000100' then 37310282::int
            when cond.dx = '870577009' then 3655973::int
            when cond.dx_type='09' or cond.dx_type='ICD09' then cr_icd9.concept_id_2
            when cond.dx_type='10' or cond.dx_type='ICD10' then cr_icd10.concept_id_2
            when cond.dx_type='SM' then c_snomed.concept_id
             -- RegEx for ICD09 codes if condition_type <>'09' 
            when cond.dx REGEXP '^V[0-9]{2}.?[0-9]{0,2}$' then cr_icd9.concept_id_2
            when cond.dx REGEXP '^E[0-9]{3}.?[0-9]?$' then cr_icd9.concept_id_2
            when cond.dx REGEXP '^[0-9]{3}.?[0-9]{0,2}$' then cr_icd9.concept_id_2
            -- RegEx for ICD10 codes if condition_type <>'10' 
            when cond.dx REGEXP '^[A-Z][0-9][0-9A-Z].?[0-9A-Z]{0,4}$' then cr_icd10.concept_id_2
            else NULL
        end,
    0)::int as condition_concept_id,
    coalesce(
        case
            --misc codes
            when cond.dx = 'M35.81' then 713856::int
            when cond.dx = 'U10' then 931072::int
            when cond.dx = 'U10.9' then 931073::int
            --pasc code
            when cond.dx = 'U09.9' then 766503::int
            when cond.dx_type='09' or cond.dx_type='ICD09' then c_icd9.concept_id
            when cond.dx_type='10' or cond.dx_type='ICD10' then c_icd10.concept_id
            -- RegEx for ICD09 codes if condition_type <>'09' 
            when cond.dx REGEXP '^V[0-9]{2}.?[0-9]{0,2}$' then c_icd9.concept_id
            when cond.dx REGEXP '^E[0-9]{3}.?[0-9]?$' then c_icd9.concept_id
            when cond.dx REGEXP '^[0-9]{3}.?[0-9]{0,2}$' then c_icd9.concept_id
            -- RegEx for ICD10 codes if condition_type <>'10' 
            when cond.dx REGEXP '^[A-Z][0-9][0-9A-Z].?[0-9A-Z]{0,4}$' then c_icd10.concept_id
            else NULL
        end,
    0)::int as condition_source_concept_id,
    left(coalesce(cond.dx,''),248) || ' | ' || coalesce(dx_type,'') as condition_source_value,
    null::timestamp as condition_end_date,
    null::timestamp as condition_end_datetime,
    database.schema_omop.cond_occ_seq.nextval  as condition_occurrence_id,
    case 
        when cond.dx_date is not null then cond.dx_date::date
        when cond.admit_date is not null then cond.admit_date::date
        else '0001-01-01'::date
    end as condition_start_date,
    case 
        when cond.dx_date is not null then cond.dx_date::timestamp
        when cond.admit_date is not null then cond.admit_date::timestamp
        else '0001-01-01'::timestamp
    end as condition_start_datetime,
    4230359 AS condition_status_concept_id,
    coalesce(cond.dx_source,cond.RAW_DX_SOURCE) AS condition_status_source_value,
    case 
        when cond.enc_type='ED' and dx_origin='BI' and pdx='P'then 2000001282
        when cond.enc_type='ED' and dx_origin='OD' and pdx='P'then 2000001280
        when cond.enc_type='ED' and dx_origin='CL' and pdx='P'then 2000001281
        when cond.enc_type='ED' and dx_origin='BI' and pdx='S'then 2000001284
        when cond.enc_type='ED' and dx_origin='OD' and pdx='S'then 2000001283
        when cond.enc_type='ED' and dx_origin='CL' and pdx='S'then 2000001285
        when cond.enc_type in ('AV','OA','TH') and dx_origin='BI' and pdx='P'then 2000000096
        when cond.enc_type in ('AV','OA','TH') and dx_origin='OD' and pdx='P'then 2000000095
        when cond.enc_type in ('AV','OA','TH') and dx_origin='CL' and pdx='P'then 2000000097
        when cond.enc_type in ('AV','OA','TH') and dx_origin='BI' and pdx='S'then 2000000102
        when cond.enc_type in ('AV','OA','TH') and dx_origin='OD' and pdx='S'then 2000000101
        when cond.enc_type in ('AV','OA','TH') and dx_origin='CL' and pdx='S'then 2000000103
        when cond.enc_type in ('IP','OS','IS','EI') and dx_origin='BI' and pdx='P'then 2000000093
        when cond.enc_type in ('IP','OS','IS','EI') and dx_origin='OD' and pdx='P'then 2000000092
        when cond.enc_type in ('IP','OS','IS','EI') and dx_origin='CL' and pdx='P'then 2000000094
        when cond.enc_type in ('IP','OS','IS','EI') and dx_origin='BI' and pdx='S'then 2000000099
        when cond.enc_type in ('IP','OS','IS','EI') and dx_origin='OD' and pdx='S'then 2000000098
        when cond.enc_type in ('IP','OS','IS','EI') and dx_origin='CL' and pdx='S'then 2000000100
        else 44814650
    end as condition_type_concept_id,
    cond.patid AS person_id,   
    coalesce(
        case 
            when dx_poa='Y' then 4188539 
            else 4188540 
        end,
        44814650)::int as poa_concept_id, 
    enc.providerid as provider_id,   
    NULL as stop_reason,    
    enc.encounterid as visit_occurrence_id  
FROM 
    database.schema_pcornet_deid.pcornet_deid_diagnosis cond
left join 
    database.schema_pcornet_deid.pcornet_deid_encounter enc
    on cond.encounterid=enc.encounterid
left join 
    database.vocabulary.concept c_icd9 
    on cond.dx=c_icd9.concept_code
    and c_icd9.vocabulary_id='ICD9CM' 
left join 
    database.vocabulary.concept c_icd10 
    on cond.dx=c_icd10.concept_code
    and c_icd10.vocabulary_id='ICD10CM'
left join 
    database.vocabulary.concept c_snomed 
    on cond.dx=c_snomed.concept_code
    and c_snomed.vocabulary_id='SNOMED' 
    and cond.dx_type='SM'
left join 
    database.vocabulary.concept_relationship cr_icd9
    on c_icd9.concept_id = cr_icd9.concept_id_1
    and cr_icd9.relationship_id='Maps to'
left join 
    database.vocabulary.concept_relationship cr_icd10
    on c_icd10.concept_id = cr_icd10.concept_id_1
    and cr_icd10.relationship_id='Maps to';