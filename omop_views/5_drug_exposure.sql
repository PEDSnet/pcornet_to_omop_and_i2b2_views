create or replace sequence database.schema_omop.DRUG_EXPOSURE_SEQ start = 1 increment = 1;

create or replace secure view database.schema_omop.drug_exposure as 
select distinct
	dispense_sup::numeric as days_supply,	
	0 as dispense_as_written_concept_id, 
	coalesce(case 
			when disp.dispense_dose_disp_unit = 'NI' then ucum_maps.source_concept_id::int
			when disp.dispense_dose_disp_unit = 'OT' then ucum_maps.source_concept_id::int
			else unit.concept_id
		end,0) as dose_unit_concept_id,
	dispense_dose_disp_unit as dose_unit_source_value,
	coalesce(ndc_map.concept_id_2,0) drug_concept_id,
	null::date as drug_exposure_end_date,
	null::timestamp as drug_exposure_end_datetime,
	database.schema_omop.drug_exposure_seq.nextval  AS drug_exposure_id,
	null::date as drug_exposure_order_date,
	null::timestamp as drug_exposure_order_datetime,
	case
        when dispense_date is null then '0001-01-01'::date
	    else dispense_date::date
	end as drug_exposure_start_date,
	case
	   when dispense_date is null then '0001-01-01'::timestamp
	   else dispense_date::timestamp
	end as drug_exposure_start_datetime,
	--only have concept mappings for 'OD' and 'BI'. Else default to no information
	case
		when dispense_source = 'OD' then 38000275
		when dispense_source = 'BI' then 44786630
		else 44814653 
	end as drug_source_concept_id,
	coalesce(disp.ndc,' ') as drug_source_value,
	38000175 as drug_type_concept_id,
	dispense_dose_disp::varchar as eff_drug_dose_source_value,
	dispense_dose_disp::numeric as effective_drug_dose,
	null as frequency,
	null as lot_number,
	disp.patid as person_id,
	null as provider_id,
	dispense_amt::numeric as quantity,
	null::integer as refills,
	coalesce(
		case
			when disp.dispense_route = 'OT' then 44814649
			else route.concept_id
		end, 0) as route_concept_id,
	dispense_route as route_source_value,
	null as sig,
	null as stop_reason,
	null as visit_occurrence_id
from 
	database.schema_pcornet_deid.pcornet_deid_dispensing disp
left join 
	database.vocabulary.concept ndc 
	on disp.ndc=ndc.concept_code 
	and ndc.vocabulary_id='NDC' 
left join 
	database.vocabulary.concept_relationship ndc_map 
	on ndc.concept_id=ndc_map.concept_id_1 
	and (
		ndc_map.relationship_id='Maps to'
		or ndc_map.relationship_id = 'Non-standard to Standard map (OMOP)'
		)
	and ndc_map.concept_id_2 in (select concept_id from database.vocabulary.concept where vocabulary_id = 'RxNorm')
left join 
	database.pcornet_maps.pcornet_pedsnet_valueset_map as ucum_maps
	on disp.dispense_dose_disp_unit = ucum_maps.target_concept 
	and ucum_maps.source_concept_class = 'Dose unit'
left join 
	(select concept_id
	from database.vocabulary.concept
	where vocabulary_id = 'UCUM' and standard_concept = 'S'
	) as unit
	on ucum_maps.source_concept_id = unit.concept_id::varchar
left join 
	(select target_concept, source_concept_id, concept_id
	 from
		(select target_concept, source_concept_id
		from database.pcornet_maps.pcornet_pedsnet_valueset_map
		where source_concept_class = 'Route') as route_maps
		inner join (
			select concept_id, vocabulary_id
			from database.vocabulary.concept
			where domain_id = 'Route' and standard_concept = 'S' 
		) as voc2
		on route_maps.source_concept_id = voc2.concept_id::varchar
	) as route 
	on disp.dispense_route = route.target_concept

union

select distinct
	rx_days_supply::int as days_supply,
	case 
		when rx_dispense_as_written='Y' then 4188539 -- Yes
		when rx_dispense_as_written='N' then 4188540 -- No
		when rx_dispense_as_written='NI' then 44814650 -- No Information
        when rx_dispense_as_written='OT' then 44814649 -- Other
        when rx_dispense_as_written='UN' then 44814653 -- Unknown
		end as dispense_as_written_concept_id,
	coalesce(
		case 
			when presc.rx_dose_ordered_unit = 'NI' then ucum_maps.source_concept_id::int
			when presc.rx_dose_ordered_unit = 'OT' then ucum_maps.source_concept_id::int
			else unit.concept_id
		end, 0) as dose_unit_concept_id,
	rx_dose_ordered_unit as dose_unit_source_value,
	coalesce(rxnorm.concept_id,0) as drug_concept_id,
	rx_end_date::date as drug_exposure_end_date,
	rx_end_date::timestamp as drug_exposure_end_datetime,
	database.schema_omop.drug_exposure_seq.nextval  AS drug_exposure_id,
	rx_order_date::date as drug_exposure_order_date,
	case 
		when rx_order_time is not null then (rx_order_date || ' '|| rx_order_time)::timestamp 
		else rx_order_date::timestamp 
	end as drug_exposure_order_datetime,
	case
        when rx_start_date is null then '0001-01-01'::date
        else rx_start_date::date
	end as drug_exposure_start_date,
	case
	    when rx_start_date is null then '0001-01-01'::timestamp
	    else rx_start_date::timestamp
	end as drug_exposure_start_datetime,
	coalesce(rxnorm.concept_id,0) as drug_source_concept_id,
	coalesce(left(raw_rx_med_name, 200),' ')||'|'||coalesce(rxnorm_cui,' ') as drug_source_value,
	38000177 as drug_type_concept_id,
	null as eff_drug_dose_source_value,
	rx_dose_ordered::numeric as effective_drug_dose,
	rx_frequency as frequency,
	null as lot_number,
	presc.patid as person_id,
	enc.providerid as provider_id,
	rx_quantity::numeric as quantity,
	rx_refills::int as refills,
	coalesce(case
			when presc.rx_route = 'OT' then 44814649
			else route.concept_id
		end,0) as route_concept_id,
	rx_route as route_source_value,
	null as sig,
	null as stop_reason,
 	presc.encounterid as visit_occurrence_id
from 
	database.schema_pcornet_deid.pcornet_deid_prescribing presc
left join 
	database.vocabulary.concept as rxnorm 
	on trim(presc.rxnorm_cui) = rxnorm.concept_code 
	and vocabulary_id='RxNorm' 
	and standard_concept='S'
left join 
	database.pcornet_maps.pcornet_pedsnet_valueset_map as ucum_maps
	on presc.rx_dose_ordered_unit = ucum_maps.target_concept 
	and source_concept_class = 'Dose unit'
left join 
	(select concept_id
	from database.vocabulary.concept
	where vocabulary_id = 'UCUM' and standard_concept = 'S'
	) as unit
	on ucum_maps.source_concept_id = unit.concept_id::varchar
left join 
	(select target_concept, source_concept_id, concept_id
	 from
		(select 
		 target_concept, source_concept_id
		from database.pcornet_maps.pcornet_pedsnet_valueset_map
		where source_concept_class = 'Route') as route_maps
		inner join (
			select concept_id, vocabulary_id
			from database.vocabulary.concept
			where domain_id = 'Route' and standard_concept = 'S' 
		) as voc2
		on route_maps.source_concept_id = voc2.concept_id::varchar
	) as route 
	on presc.rx_route = route.target_concept

union

select distinct
	null::integer as days_supply,
	0 as dispense_as_written_concept_id,
	coalesce(
		case 
			when medadmin.medadmin_dose_admin_unit = 'NI' then ucum_maps.source_concept_id::int
			when medadmin.medadmin_dose_admin_unit = 'OT' then ucum_maps.source_concept_id::int
			else unit.concept_id::int
		end, 0) as dose_unit_concept_id,
	medadmin_dose_admin_unit as dose_unit_source_value,
	coalesce(
		case
			when medadmin_type='ND' then ndc_map.concept_id_2
			when medadmin_type='RX' then rxnorm.concept_id
			else 0 
		end, 0) as drug_concept_id,
	medadmin_stop_date::date as drug_exposure_end_date,
	(medadmin_stop_date || ' '|| medadmin_stop_time)::timestamp as drug_exposure_end_datetime,
 	database.schema_omop.drug_exposure_seq.nextval  AS drug_exposure_id,
	null::date as drug_exposure_order_date,
	null::timestamp as drug_exposure_order_datetime,
	case
        when medadmin_start_date is null then '0001-01-01'::date
	    else medadmin_start_date
	end as drug_exposure_start_date,
	case
	    when medadmin_start_date is null OR medadmin_start_time is null then '0001-01-01'::timestamp
        else (medadmin_start_date || ' '|| medadmin_start_time)::timestamp
	end as drug_exposure_start_datetime,
	case
		when medadmin_type='ND' then ndc.concept_id
		when medadmin_type='RX' then rxnorm.concept_id
		else 0 
	end as drug_source_concept_id,
	coalesce(left(raw_medadmin_med_name, 200)||'...',' ')||'|'||coalesce(medadmin_code,' ') as drug_source_value,
	38000180 as drug_type_concept_id,
	medadmin_dose_admin::varchar as eff_drug_dose_source_value,
	medadmin_dose_admin::numeric as effective_drug_dose,
	null as frequency,
	null as lot_number,
	medadmin.patid as person_id,
	enc.providerid as provider_id,
	null::numeric as quantity,
	null::integer as refills,
	coalesce(
		case 
			when medadmin.medadmin_route = 'OT' then 44814649
			else route.concept_id::int
		end,0) as route_concept_id,
	medadmin_route as route_source_value,
	null as sig,
	null as stop_reason,
	medadmin.encounterid as visit_occurrence_id
from 
	database.schema_pcornet_deid.pcornet_deid_med_admin as medadmin
left join 
	database.schema_pcornet_deid.pcornet_deid_encounter enc
    on medadmin.encounterid = enc.encounterid
left join 
	database.vocabulary.concept ndc 
	on medadmin.medadmin_code=ndc.concept_code 
	and medadmin_type='ND' 
	and ndc.vocabulary_id='NDC' 
left join 
	database.vocabulary.concept_relationship ndc_map 
	on ndc.concept_id=ndc_map.concept_id_1 
	and (
		ndc_map.relationship_id='Maps to'
		or ndc_map.relationship_id = 'Non-standard to Standard map (OMOP)'
		)
	and ndc_map.concept_id_2 in (select concept_id from database.vocabulary.concept where vocabulary_id = 'RxNorm')
left join 
	database.vocabulary.concept rxnorm 
	on medadmin.medadmin_code = rxnorm.concept_code 
	and medadmin_type='RX' 
	and rxnorm.vocabulary_id='RxNorm' 
	and rxnorm.standard_concept='S'
left join 
	database.pcornet_maps.pcornet_pedsnet_valueset_map as ucum_maps
	on medadmin.medadmin_dose_admin_unit = ucum_maps.target_concept 
	and ucum_maps.source_concept_class = 'Dose unit'
left join 
	(select concept_id
	from database.vocabulary.concept
	where vocabulary_id = 'UCUM' and standard_concept = 'S'
	) as unit
	on ucum_maps.source_concept_id = unit.concept_id::varchar
left join 
	(select target_concept, source_concept_id, concept_id
	 from
		(select target_concept, source_concept_id
		from database.pcornet_maps.pcornet_pedsnet_valueset_map
		where source_concept_class = 'Route') as route_maps
		inner join (
			select concept_id, vocabulary_id
			from database.vocabulary.concept
			where domain_id = 'Route' and standard_concept = 'S' 
		) as voc2
		on route_maps.source_concept_id = voc2.concept_id::varchar
		where vocabulary_id = 'SNOMED'
	) as route 
	on medadmin.medadmin_route = route.target_concept;