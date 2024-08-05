-- /* sequence is needed as the vital need to be transpose one id multiple values */
create or replace sequence database.schema_omop.measurement_id_seq start = 1 increment = 1;

create  or replace secure view database.schema_omop.measurement as 

with meas_vital_ht as (
SELECT distinct
    database.schema_omop.measurement_id_seq.nextval,
     3023540::int AS measurement_concept_id, 
     v_ht.measure_date::date AS measurement_date, 
     case 
          when v_ht.measure_time is not null then (v_ht.measure_date || ' '|| v_ht.measure_time)::timestamp
          else v_ht.measure_date::timestamp 
     end AS measurement_datetime,
     null as measurement_order_date, 
     null as measurement_order_datetime, 
     null as measurement_result_date, 
     null as measurement_result_datetime, 
     0 AS measurement_source_concept_id,
     'Height in cm (converted from inches)' AS measurement_source_value, 
     2000000033 as measurement_type_concept_id, 
     4172703 AS operator_concept_id, 
     v_ht.patid AS person_id, 
     0  as priority_concept_id, 
     null as priority_source_value, 
     enc.providerid as provider_id, 
     null as range_high, 
     null as range_high_operator_concept_id, 
     null as range_high_source_value, 
     null as range_low, 
     null as range_low_operator_concept_id, 
     null as range_low_source_value, 
     null as specimen_concept_id, 
     null as specimen_source_value, 
     8582 AS unit_concept_id,
     9237 AS unit_source_concept_id, 
     'cm (converted from inches)' AS unit_source_value, 
     NULL AS value_as_concept_id,
     (v_ht.ht::numeric*2.54) AS value_as_number,
     v_ht.ht::varchar AS value_source_value,
     v_ht.encounterid AS visit_occurrence_id 
FROM 
     database.schema_pcornet_deid.pcornet_deid_vital v_ht
left join 
     database.schema_pcornet_deid.pcornet_deid_encounter enc 
     on enc.encounterid = v_ht.encounterid
LEFT JOIN 
     database.pcornet_maps.p2o_vital_term_xwalk vt 
     ON vt.src_cdm_tbl = 'VITAL' 
     AND vt.src_cdm_column = 'VITAL_SOURCE' 
     AND vt.src_code = v_ht.vital_source
where 
     v_ht.ht is not null
),

meas_vital_wt as (
SELECT distinct
    database.schema_omop.measurement_id_seq.nextval,
     3013762::int AS measurement_concept_id, 
     v_wt.measure_date::date AS measurement_date,
     case 
          when v_wt.measure_time is not null 
          then (v_wt.measure_date || ' '|| v_wt.measure_time)::timestamp
          else v_wt.measure_date::timestamp 
     end AS measurement_datetime,
     null as measurement_order_date, 
     null as measurement_order_datetime, 
     null as measurement_result_date, 
     null as measurement_result_datetime, 
     0 AS measurement_source_concept_id,
     'Weight (converted from pounds)' AS measurement_source_value, 
     2000000033 as measurement_type_concept_id, 
     4172703 AS operator_concept_id, 
     v_wt.patid AS person_id, 
     0 as priority_concept_id, 
     null as priority_source_value, 
     enc.providerid as provider_id, 
     null as range_high, 
     null as range_high_operator_concept_id, 
     null as range_high_source_value, 
     null as range_low, 
     null as range_low_operator_concept_id, 
     null as range_low_source_value, 
     null as specimen_concept_id, 
     null as specimen_source_value,
     9529 AS unit_concept_id, 
     8739 AS unit_source_concept_id, 
     'kg (converted from pounds)' AS unit_source_value, 
     NULL AS value_as_concept_id,
     (v_wt.wt::numeric*0.453592) AS value_as_number,
     v_wt.wt::varchar as value_source_value,
     v_wt.encounterid AS visit_occurrence_id
FROM 
     database.schema_pcornet_deid.pcornet_deid_vital v_wt
left join 
     database.schema_pcornet_deid.pcornet_deid_encounter enc 
     on enc.encounterid = v_wt.encounterid
LEFT JOIN 
     database.pcornet_maps.p2o_vital_term_xwalk vt 
     ON vt.src_cdm_tbl = 'VITAL' 
     AND vt.src_cdm_column = 'VITAL_SOURCE' 
     AND vt.src_code = v_wt.vital_source
where 
     v_wt.wt is not null
),

meas_vital_sys as (
SELECT distinct
    database.schema_omop.measurement_id_seq.nextval,
     coalesce(sys_con.source_concept_id::int, 3004249)::int AS measurement_concept_id, 
     v_sys.measure_date::date AS measurement_date, 
     case 
          when v_sys.measure_time is not null 
          then (v_sys.measure_date || ' '|| v_sys.measure_time)::timestamp
          else v_sys.measure_date::timestamp 
     end AS measurement_datetime,
     null as measurement_order_date, 
     null as measurement_order_datetime, 
     null as measurement_result_date, 
     null as measurement_result_datetime, 
     0 AS measurement_source_concept_id,
     coalesce(v_sys.raw_systolic,v_sys.systolic::varchar,' ') AS measurement_source_value, 
     2000000033 as measurement_type_concept_id, 
     4172703 AS operator_concept_id, 
     v_sys.patid AS person_id, 
     0 as priority_concept_id, 
     null as priority_source_value, 
     enc.providerid as provider_id, 
     null as range_high, 
     null as range_high_operator_concept_id, 
     null as range_high_source_value, 
     null as range_low, 
     null as range_low_operator_concept_id, 
     null as range_low_source_value, 
     null as specimen_concept_id, 
     null as specimen_source_value, 
     8876 AS unit_concept_id,
     0 AS unit_source_concept_id, 
     'millimeter mercury column' AS unit_source_value, 
     NULL AS value_as_concept_id,
     v_sys.systolic::numeric AS value_as_number,
     v_sys.systolic::varchar as value_source_value,
     v_sys.encounterid AS visit_occurrence_id
FROM 
     database.schema_pcornet_deid.pcornet_deid_vital v_sys
left join 
     database.schema_pcornet_deid.pcornet_deid_encounter enc 
     on enc.encounterid = v_sys.encounterid
left join 
     (
          select target_concept, source_concept_id
          from database.pcornet_maps.pcornet_pedsnet_valueset_map 
          where source_concept_class='BP Position'
          and not(concept_description like '%Diastolic%')
     ) as sys_con on sys_con.target_concept = v_sys.bp_position
LEFT JOIN 
     database.pcornet_maps.p2o_vital_term_xwalk vt 
     ON vt.src_cdm_tbl = 'VITAL' 
     AND vt.src_cdm_column = 'VITAL_SOURCE' 
     AND vt.src_code = v_sys.vital_source
where 
     v_sys.systolic is not null
),

meas_vital_dia as (
SELECT distinct
    database.schema_omop.measurement_id_seq.nextval,
     3012888::int AS measurement_concept_id, 
     v_dia.measure_date::date AS measurement_date, 
     case 
          when v_dia.measure_time is not null 
          then (v_dia.measure_date || ' '|| v_dia.measure_time)::timestamp
          else v_dia.measure_date::timestamp 
     end AS measurement_datetime, 
     null as measurement_order_date, 
     null as measurement_order_datetime, 
     null as measurement_result_date, 
     null as measurement_result_datetime, 
     coalesce(dia_con.source_concept_id::int, 3012888) AS measurement_source_concept_id,
     coalesce(v_dia.raw_diastolic,v_dia.diastolic::varchar,' ') AS measurement_source_value, 
     2000000033 as measurement_type_concept_id, 
     4172703 AS operator_concept_id, 
     v_dia.patid AS person_id, 
     0  as priority_concept_id, 
     null as priority_source_value, 
     enc.providerid as provider_id, 
     null as range_high, 
     null as range_high_operator_concept_id, 
     null as range_high_source_value, 
     null as range_low, 
     null as range_low_operator_concept_id, 
     null as range_low_source_value, 
     null as specimen_concept_id, 
     null as specimen_source_value, 
     8876 AS unit_concept_id,
     0 AS unit_source_concept_id, 
     'millimeter mercury column' AS unit_source_value, 
     NULL AS value_as_concept_id,
     v_dia.diastolic::numeric as value_as_number,
     coalesce(dia_con.concept_description,' ')::varchar AS value_source_value,
     v_dia.encounterid AS visit_occurrence_id
FROM 
    database.schema_pcornet_deid.pcornet_deid_vital v_dia
left join 
     database.schema_pcornet_deid.pcornet_deid_encounter enc 
     on enc.encounterid = v_dia.encounterid
left join 
     (
          select target_concept, source_concept_id, concept_description
          from database.pcornet_maps.pcornet_pedsnet_valueset_map 
          where source_concept_class='BP Position'
          and not(concept_description like '%Systolic%')
     ) as dia_con on dia_con.target_concept = v_dia.bp_position
LEFT JOIN 
     database.pcornet_maps.p2o_vital_term_xwalk vt 
     ON vt.src_cdm_tbl = 'VITAL' 
     AND vt.src_cdm_column = 'VITAL_SOURCE' 
     AND vt.src_code = v_dia.vital_source
where 
     v_dia.diastolic is not null 
),

meas_vital_bmi as (
SELECT distinct
    database.schema_omop.measurement_id_seq.nextval,
     3038553::int AS measurement_concept_id, 
     v_bmi.measure_date::date AS measurement_date,
     case 
          when v_bmi.measure_time is not null then (v_bmi.measure_date || ' '|| v_bmi.measure_time)::timestamp
          else v_bmi.measure_date::timestamp 
     end AS measurement_datetime, 
     null as measurement_order_date, 
     null as measurement_order_datetime, 
     null as measurement_result_date, 
     null as measurement_result_datetime, 
     0 AS measurement_source_concept_id,
     'Original BMI' AS measurement_source_value, 
     2000000033 as measurement_type_concept_id, 
     4172703 AS operator_concept_id, 
     v_bmi.patid AS person_id, 
     0  as priority_concept_id, 
     null as priority_source_value, 
     enc.providerid as provider_id, 
     null as range_high, 
     null as range_high_operator_concept_id, 
     null as range_high_source_value, 
     null as range_low, 
     null as range_low_operator_concept_id, 
     null as range_low_source_value, 
     null as specimen_concept_id, 
     null as specimen_source_value, 
     null AS unit_concept_id, 
     null as unit_source_concept_id,
     null AS unit_source_value, 
     NULL AS value_as_concept_id,
     v_bmi.original_bmi::numeric as value_as_number,
     v_bmi.original_bmi::varchar AS value_source_value,
     v_bmi.encounterid AS visit_occurrence_id
FROM 
     database.schema_pcornet_deid.pcornet_deid_vital v_bmi
left join 
     database.schema_pcornet_deid.pcornet_deid_encounter enc 
     on enc.encounterid = v_bmi.encounterid
LEFT JOIN 
     database.pcornet_maps.p2o_vital_term_xwalk vt 
     ON vt.src_cdm_tbl = 'VITAL' 
     AND vt.src_cdm_column = 'VITAL_SOURCE' 
     AND vt.src_code = v_bmi.vital_source
where 
     v_bmi.original_bmi is not null 
),

meas_lab_result_cm as (
select distinct
     database.schema_omop.measurement_id_seq.nextval  AS measurement_id,
     coalesce(
          case
               --antigen tests
               when lab.LAB_LOINC = '94763-0' then 586516::int
               when lab.LAB_LOINC = '94558-4' then 723477::int
               when lab.LAB_LOINC = '95209-3' then 757685::int
               when lab.LAB_LOINC = '95942-9' then 36031949::int
               when lab.LAB_LOINC = '96119-3' then 36032419::int
               when lab.LAB_LOINC = '97097-0' then 36033641::int
               when lab.LAB_LOINC = '97099-6' then 36033643::int
               --pcr tests
               when lab.LAB_LOINC = '94308-4' then 706154::int
               when lab.LAB_LOINC = '94312-6' then 706155::int
               when lab.LAB_LOINC = '94307-6' then 706156::int
               when lab.LAB_LOINC = '94311-8' then 706157::int
               when lab.LAB_LOINC = '94531-1' then 706158::int
               when lab.LAB_LOINC = '94532-9' then 706159::int
               when lab.LAB_LOINC = '94534-5' then 706160::int
               when lab.LAB_LOINC = '94533-7' then 706161::int
               when lab.LAB_LOINC = '94500-6' then 706163::int
               when lab.LAB_LOINC = '94509-7' then 706166::int
               when lab.LAB_LOINC = '94510-5' then 706167::int
               when lab.LAB_LOINC = '94511-3' then 706168::int
               when lab.LAB_LOINC = '94306-8' then 706169::int
               when lab.LAB_LOINC = '94309-2' then 706170::int
               when lab.LAB_LOINC = '94310-0' then 706171::int
               when lab.LAB_LOINC = '94313-4' then 706172::int
               when lab.LAB_LOINC = '94314-2' then 706173::int
               when lab.LAB_LOINC = '94315-9' then 706174::int
               when lab.LAB_LOINC = '94316-7' then 706175::int
               when lab.LAB_LOINC = '94640-0' then 723465::int
               when lab.LAB_LOINC = '94641-8' then 723466::int
               when lab.LAB_LOINC = '94647-5' then 723472::int
               when lab.LAB_LOINC = '94565-9' then 723476::int
               when lab.LAB_LOINC = '94559-2' then 723478::int
               when lab.LAB_LOINC = '41458-1' then 3031852::int
               when lab.LAB_LOINC = '94764-8' then 586517::int
               when lab.LAB_LOINC = '94765-5' then 586518::int
               when lab.LAB_LOINC = '94767-1' then 586519::int
               when lab.LAB_LOINC = '94766-3' then 586520::int
               when lab.LAB_LOINC = '94758-0' then 586523::int
               when lab.LAB_LOINC = '94756-4' then 586524::int
               when lab.LAB_LOINC = '94757-2' then 586525::int
               when lab.LAB_LOINC = '94759-8' then 586526::int
               when lab.LAB_LOINC = '94745-7' then 586528::int
               when lab.LAB_LOINC = '94746-5' then 586529::int
               when lab.LAB_LOINC = '94845-5' then 715260::int
               when lab.LAB_LOINC = '94822-4' then 715261::int
               when lab.LAB_LOINC = '94819-0' then 715262::int
               when lab.LAB_LOINC = '94760-6' then 715272::int
               when lab.LAB_LOINC = '94660-8' then 723463::int
               when lab.LAB_LOINC = '94639-2' then 723464::int
               when lab.LAB_LOINC = '94642-6' then 723467::int
               when lab.LAB_LOINC = '94643-4' then 723468::int
               when lab.LAB_LOINC = '94644-2' then 723469::int
               when lab.LAB_LOINC = '94645-9' then 723470::int
               when lab.LAB_LOINC = '94646-7' then 723471::int
               when lab.LAB_LOINC = '95406-5' then 757677::int
               when lab.LAB_LOINC = '95409-9' then 757678::int
               when lab.LAB_LOINC = 'LP418702-9' then 36660752::int
               when lab.LAB_LOINC = 'LP418705-2' then 36660800::int
               when lab.LAB_LOINC = 'LP418693-0' then 36660801::int
               when lab.LAB_LOINC = 'LP418704-5' then 36660882::int
               when lab.LAB_LOINC = 'LP418709-4' then 36660887::int
               when lab.LAB_LOINC = 'LP418708-6' then 36660902::int
               when lab.LAB_LOINC = 'LP418711-0' then 36660907::int
               when lab.LAB_LOINC = 'LP419289-6' then 36660924::int
               when lab.LAB_LOINC = 'LP419178-1' then 36660927::int
               when lab.LAB_LOINC = 'LP418683-1' then 36660953::int
               when lab.LAB_LOINC = 'LP418696-3' then 36660966::int
               when lab.LAB_LOINC = 'LP419179-9' then 36660970::int
               when lab.LAB_LOINC = 'LP418710-2' then 36661011::int
               when lab.LAB_LOINC = 'LP419288-8' then 36661036::int
               when lab.LAB_LOINC = 'LP418695-5' then 36661115::int
               when lab.LAB_LOINC = 'LP418697-1' then 36661148::int
               when lab.LAB_LOINC = 'LP418712-8' then 36661184::int
               when lab.LAB_LOINC = 'LP418707-8' then 36661194::int
               when lab.LAB_LOINC = 'LP418698-9' then 36661244::int
               when lab.LAB_LOINC = 'LP418706-0' then 36661250::int
               when lab.LAB_LOINC = 'LP418703-7' then 36661286::int
               when lab.LAB_LOINC = 'LP418694-8' then 36661317::int
               when lab.LAB_LOINC = 'LP418713-6' then 36661348::int
               when lab.LAB_LOINC = '95521-1' then 36661370::int
               when lab.LAB_LOINC = '95522-9' then 36661371::int
               when lab.LAB_LOINC = '95424-8' then 36661377::int
               when lab.LAB_LOINC = '95425-5' then 36661378::int
               when lab.LAB_LOINC = '95609-4' then 36031213::int
               when lab.LAB_LOINC = '95608-6' then 36031238::int
               when lab.LAB_LOINC = '96123-5' then 36031453::int
               when lab.LAB_LOINC = '95824-9' then 36031506::int
               when lab.LAB_LOINC = '96120-1' then 36031652::int
               when lab.LAB_LOINC = '95826-4' then 36032061::int
               when lab.LAB_LOINC = '96091-4' then 36032174::int
               when lab.LAB_LOINC = '96448-6' then 36032258::int
               when lab.LAB_LOINC = '95823-1' then 36031814::int
               when lab.LAB_LOINC = '96121-9' then 36032295::int
               when lab.LAB_LOINC = '96122-7' then 36032286::int
               when lab.LAB_LOINC = '96741-4' then 36033667::int
               when lab.LAB_LOINC = '96751-3' then 36033664::int
               when lab.LAB_LOINC = '96752-1' then 36033665::int
               when lab.LAB_LOINC = '96763-8' then 36033658::int
               when lab.LAB_LOINC = '96765-3' then 36033660::int
               when lab.LAB_LOINC = '96797-6' then 36033656::int
               when lab.LAB_LOINC = '96829-7' then 36033655::int
               when lab.LAB_LOINC = '96895-8' then 36033652::int
               when lab.LAB_LOINC = '96896-6' then 36033653::int
               when lab.LAB_LOINC = '96957-6' then 36033645::int
               when lab.LAB_LOINC = '96958-4' then 36033646::int
               when lab.LAB_LOINC = '96986-5' then 36033644::int
               when lab.LAB_LOINC = '96094-8' then 36032352::int
               when lab.LAB_LOINC = '96894-1' then 36033651::int
               when lab.LAB_LOINC = '97098-8' then 36033642::int
               when lab.LAB_LOINC = '98132-4' then 1617427::int
               when lab.LAB_LOINC = '98494-8' then 1616454::int
               when lab.LAB_LOINC = '98131-6' then 1617191::int
               when lab.LAB_LOINC = '98493-0' then 1616841::int
               when lab.LAB_LOINC = '96756-2' then 36033662::int
               when lab.LAB_LOINC = '96757-0' then 36033663::int
               when lab.LAB_LOINC = '96764-6' then 36033659::int
               when lab.LAB_LOINC = '96898-2' then 36033648::int
               when lab.LAB_LOINC = '96899-0' then 36033649::int
               when lab.LAB_LOINC = '96900-6' then 36033650::int
               when lab.LAB_LOINC = '97104-4' then 36033640::int
               --serology tests
               when lab.LAB_LOINC = '94507-1' then 706181::int
               when lab.LAB_LOINC = '94505-5' then 706177::int
               when lab.LAB_LOINC = '94508-9' then 706180::int
               when lab.LAB_LOINC = '94506-3' then 706178::int
               when lab.LAB_LOINC = '94503-0' then 706176::int
               when lab.LAB_LOINC = '94504-8' then 706179::int
               when lab.LAB_LOINC = '94563-4' then 723474::int
               when lab.LAB_LOINC = '94720-0' then 723459::int
               when lab.LAB_LOINC = '94562-6' then 723473::int
               when lab.LAB_LOINC = '94547-7' then 723479::int
               when lab.LAB_LOINC = '94661-6' then 723480::int
               when lab.LAB_LOINC = '94564-2' then 723475::int
               when lab.LAB_LOINC = '94762-2' then 586515::int
               when lab.LAB_LOINC = '94768-9' then 586521::int
               when lab.LAB_LOINC = '94769-7' then 586522::int
               when lab.LAB_LOINC = '94761-4' then 586527::int
               when lab.LAB_LOINC = '94547-7' then 723479::int
               when lab.LAB_LOINC = '95410-7' then 757679::int
               when lab.LAB_LOINC = '95411-5' then 757680::int
               when lab.LAB_LOINC = '95125-1' then 757686::int
               when lab.LAB_LOINC = '95416-4' then 36659631::int
               when lab.LAB_LOINC = 'LP418689-8' then 36660768::int
               when lab.LAB_LOINC = 'LP418692-2' then 36660777::int
               when lab.LAB_LOINC = 'LP418686-4' then 36660905::int
               when lab.LAB_LOINC = 'LP418690-6' then 36660914::int
               when lab.LAB_LOINC = 'LP418685-6' then 36660931::int
               when lab.LAB_LOINC = 'LP418688-0' then 36661046::int
               when lab.LAB_LOINC = 'LP419433-0' then 36661053::int
               when lab.LAB_LOINC = 'LP419286-2' then 36661105::int
               when lab.LAB_LOINC = 'LP418687-2' then 36661216::int
               when lab.LAB_LOINC = 'LP418684-9' then 36661221::int
               when lab.LAB_LOINC = 'LP419413-2' then 36661273::int
               when lab.LAB_LOINC = 'LP418691-4' then 36661274::int
               when lab.LAB_LOINC = 'LP419447-0' then 36661322::int
               when lab.LAB_LOINC = '95542-7' then 36661369::int
               when lab.LAB_LOINC = '95427-1' then 36661372::int
               when lab.LAB_LOINC = '95428-9' then 36661373::int
               when lab.LAB_LOINC = '95429-7' then 36661374::int
               when lab.LAB_LOINC = '95825-6' then 36031197::int
               when lab.LAB_LOINC = '96603-6' then 36031734::int
               when lab.LAB_LOINC = '95970-0' then 36031944::int
               when lab.LAB_LOINC = '95972-6' then 36031956::int
               when lab.LAB_LOINC = '95971-8' then 36031969::int
               when lab.LAB_LOINC = '95973-4' then 36032309::int
               when lab.LAB_LOINC = '96742-2' then 36033666::int
               when lab.LAB_LOINC = '96118-5' then 36032301::int
               when lab.LAB_LOINC = '98733-9' then 1619028::int
               when lab.LAB_LOINC = '98069-8' then 1617634::int
               when lab.LAB_LOINC = '98732-1' then 1619027::int
               when lab.LAB_LOINC = '98734-7' then 1619029::int
               when lab.LAB_LOINC = '99596-9' then 2000001501::int
               when lab.LAB_LOINC = '99597-7' then 2000001502::int
               --other
               else null
          end,
          c.concept_id,0) ::int AS measurement_concept_id,
     case 
          when lab.result_date is  not null then lab.result_date::date
          when lab.specimen_date is not null then lab.specimen_date::date
          else '0001-01-01'::date 
     end::date AS measurement_date,
     case 
          when lab.result_date is not null  then lab.result_date::timestamp
          when lab.specimen_date is not null then lab.specimen_date::timestamp
          else '0001-01-01'::timestamp 
     end as measurement_datetime,
     lab.lab_order_date::date as measurement_order_date,
     lab.lab_order_date::timestamp as measurement_order_datetime,
     lab.result_date::date as measurement_result_date,
     lab.result_date::timestamp as measurement_result_datetime,
     coalesce(c.concept_id,0) as measurement_source_concept_id,
     coalesce(lab.LAB_LOINC,' ') as measurement_source_value,
     44818702 AS measurement_type_concept_id,
     coalesce(
          case
               when lab.result_modifier = 'OT' then 4172703
               else opa.source_concept_id::int 
          end,0) as operator_concept_id,
     lab.patid AS person_id,  
     coalesce(priority.source_concept_id::int,44814650) as priority_concept_id,
     null as priority_source_value,
     enc.providerid as provider_id,
     try_to_decimal(lab.norm_range_high) as range_high,
     coalesce(
		case 
			when hi_mod.source_concept_id = '[TBD]' then 0
			else hi_mod.source_concept_id::int
		end,0) as range_high_operator_concept_id, 
     null as range_high_source_value,
     try_to_decimal(lab.norm_range_low) as range_low,
     coalesce(
		case 
			when lo_mod.source_concept_id = '[TBD]' then 0
			else lo_mod.source_concept_id::int
		end,0) as range_low_operator_concept_id, 
     null as range_low_source_value,
     coalesce(case
          when specimen_source = 'SPECIMEN' then 4048506
          when specimen_source = 'BODY_FLD' then 4204181
          when specimen_source = 'TISSUE' then 4002890
          when specimen_source = 'XXX.SWAB' then 4120698
          when specimen_source = 'URINE' then 4046280
          when specimen_source = 'BLD' then 4001225
          when specimen_source = 'CVX_VAG' then 45765695
          when specimen_source = 'PLAS' then 4000626
          when specimen_source = 'BONE_MARROW' then 4000623
          when specimen_source = 'SKIN' then 43531265
          when specimen_source = 'BREAST' then 4132242
          when specimen_source = 'SER' then 4001181
          when specimen_source = 'CSF' then 4124259
          when specimen_source = 'STOOL' then 4002879
          when specimen_source = 'COLON' then 4002892
          when specimen_source = 'MILK' then 4001058
          when specimen_source = 'LYMPH_NODE' then 4124291
          when specimen_source = 'THYROID' then 4164619
          when specimen_source = 'PENIS' then 4002896
          when specimen_source = 'CALCULUS' then 4001065
          when specimen_source = 'LUNG' then 4133172
          when specimen_source = 'ANAL' then 4002895
          when specimen_source = 'TISS.FNA' then 4046275
          when specimen_source = 'BONE' then 4328578
          when specimen_source = 'BRONCHIAL' then 4001187
          when specimen_source = 'SALIVARY_GLAND.FNA' then 4265164
          when specimen_source = 'SALIVA' then 4001062
          when specimen_source = 'PROSTATE' then 4001186
          when specimen_source = 'RESPIRATORY.LOWER' then 4119538
          when specimen_source = 'RESPIRATORY.UPPER' then 4119537
          when specimen_source = 'GENITAL' then 4001063
          when specimen_source = 'LIVER.FNA' then 4335802
          when specimen_source = 'EAR' then 4204951
          when specimen_source = 'LYMPH_NODE.FNA' then 4333886
          when specimen_source = 'EYE' then 4001190
          when specimen_source = 'ABSCESS' then 4001183
          when specimen_source = 'PLACENTA' then 4001192
          when specimen_source = 'PANCREAS' then 4133175
          when specimen_source = 'SINUS' then 4332520
          when specimen_source = 'LIVER' then 4002224
          when specimen_source = 'KIDNEY.FNA' then 4048981
          when specimen_source = 'PROSTATE.FNA' then 40480935
          when specimen_source = 'THYROID.FNA' then 4204318
          when specimen_source = 'KIDNEY' then 4133742
          when specimen_source = 'OVARY' then 4027387
          when specimen_source = 'RESPIRATORY' then 4119536
          when specimen_source = 'BLDC' then 4046834
          when specimen_source = 'BLDV' then 4045667
          when specimen_source = 'PPP' then 4000627
          when specimen_source = 'RBC' then 4000622
          when specimen_source = 'SER_PLAS' then 4000626
          when specimen_source = 'THRT' then 4002893
          when specimen_source = 'URINE_SED' then 4045758
          when specimen_source = 'OT' then 44814649
     end,spec_con.source_concept_id::int,0) as specimen_concept_id, 
     lab.specimen_source as specimen_source_value, 
     coalesce(
          case 
               when lab.result_unit = '[ppm]' then 9387
               when lab.result_unit = '%{activity}' then 8687
               when lab.result_unit = 'nmol/min/mL' then 44777635
               when lab.result_unit = 'kU/L' then 8810
               else units.source_concept_id::int
          end, 0) as unit_concept_id,
     coalesce(
          case 
               when lab.result_unit = '[ppm]' then 9387
               when lab.result_unit = '%{activity}' then 8687
               when lab.result_unit = 'nmol/min/mL' then 44777635
               when lab.result_unit = 'kU/L' then 8810
               else units.source_concept_id::int
          end, 0) as unit_source_concept_id,  
     lab.result_unit as unit_source_value, 
     case 
		when lower(trim(result_qual)) = 'positive' then 45884084
	     when lower(trim(result_qual)) = 'negative' then 45878583
          when lower(trim(result_qual)) = 'pos' then 45884084
          when lower(trim(result_qual)) = 'neg' then 45878583
          when lower(trim(result_qual)) = 'presumptive positive' then 45884084
          when lower(trim(result_qual)) = 'presumptive negative' then 45878583
          when lower(trim(result_qual)) = 'detected' then 45884084
          when lower(trim(result_qual)) = 'not detected' then 45878583
          when lower(trim(result_qual)) = 'inconclusive' then 45877990
          when lower(trim(result_qual)) = 'normal' then 45884153
          when lower(trim(result_qual)) = 'abnormal' then 45878745
          when lower(trim(result_qual)) = 'low' then 45881666
          when lower(trim(result_qual)) = 'high' then 45876384
          when lower(trim(result_qual)) = 'borderline' then 45880922
          when lower(trim(result_qual)) = 'elevated' then 4328749  --ssh add issue number 55 - 6/26/2020 
          when lower(trim(result_qual)) = 'undetermined' then 45880649
          when lower(trim(result_qual)) = 'undetectable' then 45878583 
          when lower(trim(result_qual)) = 'un' then 0
          when lower(trim(result_qual)) = 'unknown' then 0
          when lower(trim(result_qual)) = 'no information' then 46237210
          else 45877393 
     end as value_as_concept_id,
     lab.result_num::numeric as value_as_number,
     case 
          when (lab.result_num::text != '0') then lab.result_num::text
          when lab.raw_result IS NOT NULL then lab.raw_result
          else 'Unknown' 
     end as value_source_value, 
     lab.encounterid as visit_occurrence_id
from 
     database.schema_pcornet_deid.pcornet_deid_LAB_RESULT_CM as lab
left join 
     database.schema_pcornet_deid.pcornet_deid_encounter enc 
     on lab.encounterid = enc.encounterid
left join 
     (
          select target_concept, source_concept_id
          from database.pcornet_maps.pcornet_pedsnet_valueset_map 
          where source_concept_class = 'Result modifier'
          and not (target_concept = 'OT' and source_concept_id = '0')
     ) as opa on opa.target_concept = lab.result_modifier
left join 
     (
          select target_concept, source_concept_id
          from database.pcornet_maps.pcornet_pedsnet_valueset_map 
          where source_concept_class = 'Result modifier'
          and not (target_concept = 'OT' and source_concept_id = '0')
     ) as hi_mod on hi_mod.target_concept = lab.NORM_MODIFIER_HIGH
left join 
     (
          select target_concept, source_concept_id
          from database.pcornet_maps.pcornet_pedsnet_valueset_map 
          where source_concept_class = 'Result modifier'
          and not (target_concept = 'OT' and source_concept_id = '0')
     ) as lo_mod on lo_mod.target_concept = lab.NORM_MODIFIER_LOW
	left join 
     (
          select target_concept, source_concept_id
          from database.pcornet_maps.pcornet_pedsnet_valueset_map
          where source_concept_class = 'Result unit'
		and source_concept_id <> 'null'
     ) as units on lab.result_unit = units.target_concept
left join 
     database.pcornet_maps.pcornet_pedsnet_valueset_map priority 
     on priority.target_concept = lab.priority 
     and priority.source_concept_class = 'Lab priority'
left join 
     database.vocabulary.concept c 
     on lab.lab_loinc=c.concept_code 
     and c.vocabulary_id='LOINC'
left join  
     (
          select target_concept, source_concept_id
          from database.pcornet_maps.pcornet_pedsnet_valueset_map
          where source_concept_class = 'Specimen concept'
     ) as spec_con on spec_con.target_concept = lab.specimen_source

),
sm as (select concept_id,concept_name,concept_code 
             from database.vocabulary.concept
             where vocabulary_id='SNOMED'
             and standard_concept='S'),
lnc as (select concept_id,concept_name,concept_code 
             from database.vocabulary.concept
             where vocabulary_id='LOINC'
             and standard_concept='S'),
unit as(select concept_id,concept_name,concept_code 
             from database.vocabulary.concept
             where vocabulary_id='UCUM'
             and standard_concept='S'),
qual as(select concept_id,concept_name,concept_code 
             from database.vocabulary.concept
             where vocabulary_id='SNOMED'
               and concept_class_id='Qualifier Value'
             and standard_concept='S'),   


meas_obs_clin_loinc as (
SELECT distinct
     database.schema_omop.measurement_id_seq.nextval  AS measurement_id,
     coalesce(lnc.concept_id,0)::int AS measurement_concept_id,
     case 
          when clin.obsclin_start_date is not null then clin.obsclin_start_date
          else '0001-01-01'::date 
     end::date AS measurement_date,
     case 
          when clin.obsclin_start_date is not null and clin.obsclin_start_time is not null then (clin.obsclin_start_date || ' '|| clin.obsclin_start_time)::timestamp 
          when clin.obsclin_start_date is not null then clin.obsclin_start_date::timestamp
          else '0001-01-01'::timestamp 
     end AS measurement_datetime, 
     null::date as measurement_order_date, 
     null::timestamp as measurement_order_datetime, 
     null::date as measurement_result_date, 
     null::timestamp as measurement_result_datetime, 
     coalesce(lnc.concept_id,0) AS measurement_source_concept_id,
     coalesce(clin.raw_obsclin_name,clin.OBSCLIN_CODE,lnc.concept_name,' ') AS measurement_source_value, 
     2000000033 as measurement_type_concept_id, 
     case 
          when clin.obsclin_result_modifier ='GE' then 4171755
          when clin.obsclin_result_modifier ='GT' then 4172704
          when clin.obsclin_result_modifier ='LE' then 4171754
          when clin.obsclin_result_modifier ='LT' then 4171756
          else 4172703 -- Equal
     end AS operator_concept_id, 
     clin.patid AS person_id, 
     0  as priority_concept_id, 
     null as priority_source_value, 
     enc.providerid as provider_id, 
     null::int as range_high, 
     null::int as range_high_operator_concept_id, 
     null as range_high_source_value, 
     null::int as range_low, 
     null::int as range_low_operator_concept_id, 
     null as range_low_source_value, 
     null::int as specimen_concept_id, 
     null as specimen_source_value, 
     coalesce(
          case 
               when clin.obsclin_result_unit = 'NI' then 44814650
               else unit.concept_id
          end,0) AS unit_concept_id,
     coalesce(
          case 
               when clin.obsclin_result_unit = 'NI' then 44814650
               else unit.concept_id
          end,0) AS unit_source_concept_id,
     coalesce(clin.obsclin_result_unit,clin.raw_obsclin_unit) AS unit_source_value, 
     coalesce(
          case
               when clin.obsclin_result_qual = 'NI' then 44814650
               when clin.obsclin_result_qual = 'OT' then 44814649
               else qual.concept_id
          end,0) AS value_as_concept_id,
     clin.obsclin_result_num::numeric AS value_as_number, 
     coalesce(
          clin.obsclin_result_text,
          clin.obsclin_result_qual,
          clin.obsclin_result_num::text,
          ' ') AS value_source_value,
    clin.encounterid AS visit_occurrence_id
FROM 
     database.schema_pcornet_deid.pcornet_deid_obs_clin clin
left join 
     database.schema_pcornet_deid.pcornet_deid_encounter enc 
     on clin.encounterid=enc.encounterid
left join 
     lnc 
     on clin.obsclin_code=lnc.concept_code
left join 
     unit 
     on clin.obsclin_result_unit=unit.concept_code
left join 
     qual 
     on clin.obsclin_result_qual=qual.concept_code
where 
     obsclin_type='LC'

),

meas_obs_clin_snomed as (
SELECT distinct
     database.schema_omop.measurement_id_seq.nextval  AS measurement_id,
     coalesce(sm.concept_id,0)::int AS measurement_concept_id, 
     case 
          when clin.obsclin_start_date is not null then clin.obsclin_start_date      
          else '0001-01-01'::date 
     end::date AS measurement_date,
     case 
          when clin.obsclin_start_date is not null and clin.obsclin_start_time is not null then (clin.obsclin_start_date || ' '|| clin.obsclin_start_time)::timestamp
          when clin.obsclin_start_date is not null then clin.obsclin_start_date::timestamp
          else '0001-01-01'::timestamp 
     end AS measurement_datetime,
     null::date as measurement_order_date, 
     null::timestamp as measurement_order_datetime, 
     null::date as measurement_result_date, 
     null::timestamp as measurement_result_datetime, 
     coalesce(sm.concept_id,0) AS measurement_source_concept_id,
     coalesce(clin.raw_obsclin_name,clin.OBSCLIN_CODE,sm.concept_name,' ') AS measurement_source_value, 
     2000000033 as measurement_type_concept_id, 
     case 
          when clin.obsclin_result_modifier ='GE' then 4171755
          when clin.obsclin_result_modifier ='GT' then 4172704
          when clin.obsclin_result_modifier ='LE' then 4171754
          when clin.obsclin_result_modifier ='LT' then 4171756
          else 4172703 -- Equal
     end AS operator_concept_id, 
     clin.patid AS person_id, 
     0 as priority_concept_id, 
     null as priority_source_value, 
     enc.providerid as provider_id, 
     null::int as range_high, 
     null::int as range_high_operator_concept_id, 
     null as range_high_source_value, 
     null::int as range_low, 
     null::int as range_low_operator_concept_id, 
     null as range_low_source_value, 
     null::int as specimen_concept_id, 
     null as specimen_source_value, 
     coalesce(
          case 
               when clin.obsclin_result_unit = 'NI' then 44814650
               else unit.concept_id
          end,0) AS unit_concept_id,
     coalesce(
          case 
               when clin.obsclin_result_unit = 'NI' then 44814650
               else unit.concept_id
          end,0) AS unit_source_concept_id,
     coalesce(clin.obsclin_result_unit,clin.raw_obsclin_unit) AS unit_source_value, 
     coalesce(
          case
               when clin.obsclin_result_qual = 'NI' then 44814650
               when clin.obsclin_result_qual = 'OT' then 44814649
               else qual.concept_id
          end,0) AS value_as_concept_id,
     clin.obsclin_result_num::numeric AS value_as_number,
     coalesce(
          clin.obsclin_result_text,
          clin.obsclin_result_qual,
          clin.obsclin_result_num::text,
          ' ') AS value_source_value,
    clin.encounterid AS visit_occurrence_id
FROM 
     database.schema_pcornet_deid.pcornet_deid_obs_clin clin
left join 
     database.schema_pcornet_deid.pcornet_deid_encounter enc 
     on clin.encounterid=enc.encounterid
left join 
     sm 
     on clin.obsclin_code=sm.concept_code
left join 
     unit 
     on clin.obsclin_result_unit=unit.concept_code
left join 
     qual 
     on clin.obsclin_result_qual=qual.concept_code
where 
     obsclin_type='SM'
)

select * from meas_vital_ht
union
select * from meas_vital_wt
union
select * from meas_vital_sys
union
select * from meas_vital_dia
union
select * from meas_vital_bmi
union
select * from meas_lab_result_cm
union
select * from meas_obs_clin_loinc
union
select * from meas_obs_clin_snomed