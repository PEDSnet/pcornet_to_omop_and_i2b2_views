create or replace view database.schema_omop.OBSERVATION_PERIOD (
	OBSERVATION_PERIOD_ID,
	PERSON_ID,
	OBSERVATION_PERIOD_START_DATE,
	OBSERVATION_PERIOD_END_DATE,
	PERIOD_TYPE_CONCEPT_ID
) as
    with pat_visit_range as
        (
        select 
            PERSON_ID,
            min(visit_start_date)::date as OBSERVATION_PERIOD_START_DATE,
            max(coalesce(visit_end_date,visit_start_date))::date as OBSERVATION_PERIOD_END_DATE,
            32817 as PERIOD_TYPE_CONCEPT_ID -- EHR
        from 
            database.schema_omop.visit_occurrence
        group by 
            PERSON_ID
        )
    SELECT
        ROW_NUMBER() over(order by observation_period_start_date,person_id)::INTEGER AS observation_period_id,
        person_id AS person_id,
        OBSERVATION_PERIOD_START_DATE::date AS observation_period_start_date,
        OBSERVATION_PERIOD_END_DATE::date as OBSERVATION_PERIOD_END_DATE,
        PERIOD_TYPE_CONCEPT_ID::INTEGER AS period_type_concept_id

    FROM 
        pat_visit_range
;