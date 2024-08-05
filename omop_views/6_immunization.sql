create or replace sequence database.schema_omop.imm_seq start = 1 increment = 1;

create or replace secure view database.schema_omop.immunization as 
select distinct
	coalesce(
		case
			when imm.vx_body_site = 'BN' then 46233552
			when imm.vx_body_site = 'BU' then 4180330
			when imm.vx_body_site = 'LA' then 46233636
			when imm.vx_body_site = 'LD' then 35632108
			when imm.vx_body_site = 'LG' then 44516524
			when imm.vx_body_site = 'LLAQ' then 45912254
			when imm.vx_body_site = 'LLFA' then 4283512
			when imm.vx_body_site = 'LMFA' then 4284054
			when imm.vx_body_site = 'LT' then 4264018
			when imm.vx_body_site = 'LUA' then 4283159
			when imm.vx_body_site = 'LUAQ' then 45955947
			when imm.vx_body_site = 'LVL' then 4079043
			when imm.vx_body_site = 'NI' then 44814650
			when imm.vx_body_site = 'OT' then 44814649
			when imm.vx_body_site = 'RA' then 44517192
			when imm.vx_body_site = 'RD' then 35632107
			when imm.vx_body_site = 'REJ' then 36695683
			when imm.vx_body_site = 'RF' then 4298982
			when imm.vx_body_site = 'RG' then 35632281
			when imm.vx_body_site = 'RH' then 4302584
			when imm.vx_body_site = 'RLAQ' then 45955948
			when imm.vx_body_site = 'RLFA' then 4271843
			when imm.vx_body_site = 'RMFA' then 4284053
			when imm.vx_body_site = 'RT' then 4008238
			when imm.vx_body_site = 'RUA' then 4274743
			when imm.vx_body_site = 'RUAQ' then 45933908
			when imm.vx_body_site = 'RUFA' then 44517187
			when imm.vx_body_site = 'RVL' then 4031702
			when imm.vx_body_site = 'UN' then 44814653
			else 44814650
		end, 
	44814650) as imm_body_site_concept_id,
	imm.vx_body_site as imm_body_site_source_value, 
	coalesce(unit_map.source_concept_id::int, 44814653) as imm_dose_unit_concept_id, 
	imm.vx_dose_unit as imm_dose_unit_source_value,
    imm.vx_exp_date::date as imm_exp_date,
	imm.vx_exp_date::timestamp as imm_exp_datetime, 
	imm.vx_lot_num as imm_lot_num, 
	imm.vx_manufacturer as imm_manufacturer, 
	imm.vx_record_date as imm_recorded_date, 
	imm.vx_record_date::timestamp as imm_recorded_datetime, 
	coalesce(route_map.concept_id, 45956875) as imm_route_concept_id, 
	imm.vx_route as imm_route_source_value, 
	coalesce(
		case
			when imm.VX_CODE = '207' then 724906::int
			when imm.VX_CODE = '208' then 724907::int
			when imm.VX_CODE = '210' then 724905::int
			when imm.VX_CODE = '213' then 724904::int
			when imm.VX_CODE = '212' then 702866::int
			when imm.VX_CODE = '217' then 702677::int
			when imm.VX_CODE = '218' then 702678::int
			when imm.VX_CODE = '211' then 702679::int
            when c_hcpcs.concept_id is not null then c_hcpcs.concept_id
            when imm.vx_code_type='CH' then c_cpt.concept_id
            when imm.vx_code_type='CX' then c_cvx.concept_id
            when imm.vx_code_type='RX' then c_rxnorm.concept_id
            when imm.vx_code_type='ND' then c_ndc.concept_id
            when imm.vx_code_type='NI' then 44814650
            when imm.vx_code_type='UN' then 44814653
            when imm.vx_code_type='OT' then 44814649
      		else 0 
		end, 0) as immunization_concept_id,
	coalesce(imm.vx_admin_date,imm.vx_record_date,'0001-01-01')::date as immunization_date,
	coalesce(imm.vx_admin_date,imm.vx_record_date,'0001-01-01')::timestamp as immunization_datetime,
	imm.vx_dose as dose,
	database.schema_omop.imm_seq.nextval  as immunization_id,
	coalesce(	
		case
            when c_hcpcs.concept_id is not null then c_hcpcs.concept_id
            when imm.vx_code_type='CH' then c_cpt.concept_id
            when imm.vx_code_type='CX' then c_cvx.concept_id
            when imm.vx_code_type='RX' then c_rxnorm.concept_id
            when imm.vx_code_type='ND' then c_ndc.concept_id
			when imm.vx_code_type='NI' then 44814650
            when imm.vx_code_type='UN' then 44814653
            when imm.vx_code_type='OT' then 44814649 
	end, 0) as immunization_source_concept_id, 
	coalesce(imm.raw_vx_name,'')||'|'||coalesce(imm.vx_code,'') as immunization_source_value, 
	case 
		when vx_source='OD' then 2000001288
		when vx_source='EF' then 2000001289
		when vx_source='IS' then 2000001290
		when vx_source='PR' then 2000001291
		else 44814649
	end as immunization_type_concept_id, 
	imm.patid as person_id,
	null as procedure_occurrence_id,
	enc.providerid as provider_id,
	imm.encounterid as visit_occurrence_id
from 
	database.schema_pcornet_deid.pcornet_deid_immunization imm
left join 
	database.schema_pcornet_deid.pcornet_deid_encounter enc
    on imm.encounterid = enc.encounterid
left join 
	database.vocabulary.concept c_hcpcs
    on imm.vx_code=c_hcpcs.concept_code 
	and imm.vx_code_type='CH' 
	and c_hcpcs.vocabulary_id='HCPCS' 
	and imm.vx_code REGEXP '[A-Z]'
left join 
	database.vocabulary.concept c_cpt
    on imm.vx_code=c_cpt.concept_code 
	and imm.vx_code_type='CH' 
	and c_cpt.vocabulary_id='CPT4'
left join 
	database.vocabulary.concept c_rxnorm
    on imm.vx_code=c_rxnorm.concept_code 
	and imm.vx_code_type='RX' 
	and c_rxnorm.vocabulary_id='RxNorm'
left join 
	database.vocabulary.concept c_cvx
    on imm.vx_code=c_cvx.concept_code 
	and imm.vx_code_type='CX' 
	and c_cvx.vocabulary_id='CVX'
left join 
	database.vocabulary.concept c_ndc
    on imm.vx_code=c_ndc.concept_code 
	and imm.vx_code_type='ND' 
	and c_ndc.vocabulary_id='NDC'
left join 
	database.pcornet_maps.pcornet_pedsnet_valueset_map unit_map
	on imm.vx_dose_unit = unit_map.target_concept 
	and unit_map.target_concept = 'Dose unit'
left join 
	(
	select target_concept, concept_id
	from 
		(
		select target_concept, source_concept_id
		from database.pcornet_maps.pcornet_pedsnet_valueset_map
		where source_concept_class = 'Route'
		) as maps
	inner join 
		(
		select concept_id
		from database.vocabulary.concept
		where standard_concept = 'S' 
		and domain_id = 'Route'
		) as voc
		on maps.source_concept_id = voc.concept_id::varchar
	) as route_map
	on imm.vx_route = route_map.target_concept;
