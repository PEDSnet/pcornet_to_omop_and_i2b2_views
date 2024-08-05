create or replace sequence database.schema_omop.visit_payer_seq start = 1 increment = 1;

create or replace secure view database.schema_omop.visit_payer as 
with payer_info as (
--primary
select
	split_part(source_concept_id,'-',1) as plan_class,
	split_part(source_concept_id,'-',2)as plan_type,
	coalesce(raw_payer_name_primary,source_concept_id,' ') as plan_name,
	enc.encounterid as visit_occurrence_id,
	31968::int as visit_payer_type_concept_id -- primary
from 
	database.schema_pcornet_deid.pcornet_deid_encounter enc
left join 
	database.pcornet_maps.pcornet_pedsnet_valueset_map payer_map
	on enc.payer_type_primary=payer_map.target_concept
	and payer_map.source_concept_class='Payer'
where 
	payer_type_primary is not null 
	and payer_type_primary <> 'NI'
	and payer_type_primary <> '23'

union

select
	'Medicaid/sCHIP' as plan_class,
	'Other/Unknown' as plan_type,
	coalesce(raw_payer_name_primary,'Medicaid/sCHIP-Other/Unknown') as plan_name,
	enc.encounterid as visit_occurrence_id,
	31968::int as visit_payer_type_concept_id -- primary
from 
	database.schema_pcornet_deid.pcornet_deid_encounter enc
where 
	payer_type_primary = '23'

union
--secondary
select
	split_part(source_concept_id,'-',1) as plan_class,
	split_part(source_concept_id,'-',2)as plan_type,
	coalesce(raw_payer_name_secondary,source_concept_id, ' ') as plan_name,
	enc.encounterid as visit_occurrence_id,
	31969::int as visit_payer_type_concept_id -- secondary
from 
	database.schema_pcornet_deid.pcornet_deid_encounter enc
left join 
	database.pcornet_maps.pcornet_pedsnet_valueset_map payer_map
	on enc.payer_type_secondary=payer_map.target_concept
	and payer_map.source_concept_class='Payer'
where 
	payer_type_secondary is not null 
	and payer_type_secondary <>'NI'
	and payer_type_secondary <>'23'

union

select
	'Medicaid/sCHIP' as plan_class,
	'Other/Unknown' as plan_type,
	coalesce(raw_payer_name_secondary,'Medicaid/sCHIP-Other/Unknown') as plan_name,
	enc.encounterid as visit_occurrence_id,
	31969::int as visit_payer_type_concept_id -- secondary
from 
	database.schema_pcornet_deid.pcornet_deid_encounter enc
where 
	payer_type_secondary = '23'
)
select distinct
	coalesce(payer_info.plan_class,'Other/Unknown') as plan_class,
	payer_info.plan_name as plan_name,
	coalesce(payer_info.plan_type,'Other/Unknown') as plan_type,
	payer_info.visit_occurrence_id,
 	database.schema_omop.visit_payer_seq.nextval ::bigint as visit_payer_id,
	payer_info.visit_payer_type_concept_id
from 
	payer_info;

