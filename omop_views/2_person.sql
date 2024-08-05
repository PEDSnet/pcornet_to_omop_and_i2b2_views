create or replace secure view database.schema_omop.person as 
with provider_history as (
    select
	    demo.patid, 
	    enc.providerid, 
	    max((coalesce(enc.admit_date,'0001-01-01')::varchar || ' ' || coalesce(enc.admit_time::time,'00:00:00')::varchar)::timestamp) as most_recent_date, 
	    count(enc.providerid) as num_visits
    from database.schema_pcornet_deid.pcornet_deid_demographic demo
    left join database.schema_pcornet_deid.pcornet_deid_encounter enc
    on demo.patid = enc.patid
    group by 
	    demo.patid, 
	    enc.providerid
),

get_provider_max as (
    select 
	    provider_history.patid, 
	    provider_history.providerid, 
	    provider_history.num_visits,
	    provider_history.most_recent_date
    from provider_history
    inner join (
	    select patid, max(num_visits) as max_visit
		from provider_history
		group by patid
	) as most_visits 
	on provider_history.patid = most_visits.patid
	and provider_history.num_visits = most_visits.max_visit
    order by patid, most_recent_date desc
),

person_primary_provider as (
select 
	pcor_prov.patid,
	pcor_prov.providerid
from (	
	select patid, max(providerid) as providerid
	from get_provider_max
	group by patid 
) as pcor_prov
)

SELECT distinct 
  demo.patid AS person_id, 
  demo.birth_date::date as birth_date,
  (demo.birth_date || ' 00:00:00')::timestamp as birth_datetime,
  9999999 AS care_site_id,
  extract(day from demo.birth_date::date) AS day_of_birth,
  extract(month from birth_date::date) AS month_of_birth,
  extract(year from birth_date::date) AS year_of_birth,
  case 
      when ethnicity_map.target_concept = 'OT' then 44814649
	    when ethnicity_map.source_concept_id not REGEXP '^[0-9]+$' then 44814650
      else coalesce(ethnicity_map.source_concept_id::int, 44814650) 
  end AS ethnicity_concept_id,
  44814650 AS ethnicity_source_concept_id,
  coalesce(ethnicity_map.concept_description,'') || ' | ' || coalesce(demo.hispanic,demo.raw_hispanic) AS ethnicity_source_value,
  case 
      when gender_map.target_concept = 'OT' then 44814649
      when gender_map.source_concept_id not REGEXP '^[0-9]+$' then 44814650
      else coalesce(gender_map.source_concept_id::int,44814650) 
  end AS gender_concept_id,
  44814650 as gender_source_concept_id,
  coalesce(gender_map.concept_description,'') || ' | ' || coalesce(demo.sex,demo.raw_sex) AS gender_source_value,
  case
      when lang.source_concept_id not REGEXP '^[0-9]+$' then 44814650
	    else coalesce(lang.source_concept_id::int, 44814650)
  end	as language_concept_id,
  44814650 as language_source_concept_id,
  coalesce(lang.concept_description,'') || ' | ' || coalesce(PAT_PREF_LANGUAGE_SPOKEN,raw_pat_pref_language_spoken) as language_source_value,
  9999999 AS location_id,
  demo.patid AS person_source_value, 
  null::numeric as pn_gestational_age, 
  ppp.providerid AS provider_id,
  case
      when race_map.source_concept_id not REGEXP '^[0-9]+$' then 44814650
	    else coalesce(race_map.source_concept_id::int,44814650)
      end as race_concept_id,
  44814650 AS race_source_concept_id, 				
  coalesce(race_map.concept_description,'') || ' | ' || coalesce(demo.race,demo.raw_race) AS race_source_value
FROM 
  database.schema_pcornet_deid.pcornet_deid_DEMOGRAPHIC demo
left join 
  person_primary_provider ppp
  on ppp.patid = demo.patid
left join 
  database.pcornet_maps.pcornet_pedsnet_valueset_map lang 
  on source_concept_class = 'Language' 
  and source_concept_id is not null 
	and lang.target_concept = demo.pat_pref_language_spoken
left join 
  database.pcornet_maps.pcornet_pedsnet_valueset_map gender_map 
  on demo.sex=gender_map.target_concept
  and gender_map.source_concept_class='Gender'
left join 
  database.pcornet_maps.pcornet_pedsnet_valueset_map ethnicity_map 
  on demo.hispanic = ethnicity_map.target_concept
  and ethnicity_map.source_concept_class='Hispanic'
left join 
  database.pcornet_maps.pcornet_pedsnet_valueset_map race_map
  on demo.race=race_map.target_concept
  and race_map.source_concept_class = 'Race'
