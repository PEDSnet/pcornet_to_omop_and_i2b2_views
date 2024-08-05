-- create remaining OMOP tables that we do not have ETL mappings for

create or replace TABLE database.schema_omop.CDM_SOURCE (
	CDM_ETL_REFERENCE VARCHAR(255),
	CDM_HOLDER VARCHAR(255),
	CDM_RELEASE_DATE DATE,
	CDM_SOURCE_ABBREVIATION VARCHAR(25),
	CDM_SOURCE_NAME VARCHAR(255) NOT NULL,
	CDM_VERSION VARCHAR(10),
	SOURCE_DESCRIPTION VARCHAR(16777216),
	SOURCE_DOCUMENTATION_REFERENCE VARCHAR(255),
	SOURCE_RELEASE_DATE DATE,
	VOCABULARY_VERSION VARCHAR(20)
);

create or replace TABLE database.schema_omop.COHORT (
	COHORT_DEFINITION_ID NUMBER(38,0) NOT NULL,
	COHORT_END_DATE DATE NOT NULL,
	COHORT_END_DATETIME TIMESTAMP_NTZ(9) NOT NULL,
	COHORT_START_DATE DATE NOT NULL,
	COHORT_START_DATETIME TIMESTAMP_NTZ(9) NOT NULL,
	PARTICIPANT_ID VARCHAR(256),
	SUBJECT_ID NUMBER(38,0) NOT NULL,
	WITHDRAW_DATE DATE,
	WITHDRAW_DATETIME TIMESTAMP_NTZ(9),
	constraint database.schema_omop.XPK_COHORT primary key (COHORT_DEFINITION_ID, SUBJECT_ID, COHORT_START_DATETIME)
);

create or replace TABLE database.schema_omop.COHORT_DEFINITION (
	COHORT_DEFINITION_DESCRIPTION VARCHAR(256),
	COHORT_DEFINITION_ID NUMBER(38,0) NOT NULL,
	COHORT_DEFINITION_NAME VARCHAR(256) NOT NULL,
	COHORT_DEFINITION_SYNTAX VARCHAR(256),
	COHORT_INITIATION_DATE DATE,
	DEFINITION_TYPE_CONCEPT_ID NUMBER(38,0) NOT NULL,
	SUBJECT_CONCEPT_ID NUMBER(38,0) NOT NULL,
	constraint database.schema_omop.XPK_COHORT_DEFINITION primary key (COHORT_DEFINITION_ID)
);

create or replace TABLE database.schema_omop.CONDITION_ERA (
	CONDITION_CONCEPT_ID NUMBER(38,0),
	CONDITION_ERA_END_DATE DATE NOT NULL,
	CONDITION_ERA_ID NUMBER(38,0) NOT NULL,
	CONDITION_ERA_START_DATE DATE NOT NULL,
	CONDITION_OCCURRENCE_COUNT NUMBER(38,0),
	PERSON_ID NUMBER(38,0),
	constraint database.schema_omop.XPK_CONDITION_ERA primary key (CONDITION_ERA_ID)
);

create or replace TABLE database.schema_omop.DOSE_ERA (
	DOSE_ERA_END_DATE DATE NOT NULL,
	DOSE_ERA_ID NUMBER(38,0) NOT NULL,
	DOSE_ERA_START_DATE DATE NOT NULL,
	DOSE_VALUE FLOAT NOT NULL,
	DRUG_CONCEPT_ID NUMBER(38,0),
	PERSON_ID NUMBER(38,0),
	UNIT_CONCEPT_ID NUMBER(38,0),
	constraint database.schema_omop.XPK_DOSE_ERA primary key (DOSE_ERA_ID)
);

create or replace TABLE database.schema_omop.DRUG_ERA (
	DRUG_CONCEPT_ID NUMBER(38,0),
	DRUG_ERA_END_DATE DATE NOT NULL,
	DRUG_ERA_ID NUMBER(38,0) NOT NULL,
	DRUG_ERA_START_DATE DATE NOT NULL,
	DRUG_EXPOSURE_COUNT NUMBER(38,0),
	GAP_DAYS NUMBER(38,0),
	PERSON_ID NUMBER(38,0),
	constraint database.schema_omop.XPK_DRUG_ERA primary key (DRUG_ERA_ID)
);

create or replace TABLE database.schema_omop.FACT_RELATIONSHIP (
	DOMAIN_CONCEPT_ID_1 NUMBER(38,0) NOT NULL,
	DOMAIN_CONCEPT_ID_2 NUMBER(38,0) NOT NULL,
	FACT_ID_1 NUMBER(38,0) NOT NULL,
	FACT_ID_2 NUMBER(38,0) NOT NULL,
	RELATIONSHIP_CONCEPT_ID NUMBER(38,0) NOT NULL
);

create or replace TABLE database.schema_omop.LAB_SITE_MAPPING (
	PEDSNET_CONCEPT_ID NUMBER(38,0) NOT NULL,
	PEDSNET_LAB_NAME VARCHAR(256) NOT NULL,
	PEDSNET_LOINC_CODE VARCHAR(256) NOT NULL,
	SITE_LOINC_CODE VARCHAR(256),
	SITE_MEASUREMENT_CONCEPT_ID NUMBER(38,0) NOT NULL,
	SITE_SOURCE_VALUE VARCHAR(256) NOT NULL
);

create or replace TABLE database.schema_omop.NOTE (
	NOTE_DATE DATE NOT NULL,
	NOTE_ID NUMBER(38,0) NOT NULL,
	NOTE_SOURCE_VALUE VARCHAR(50),
	NOTE_TEXT VARCHAR(16777216) NOT NULL,
	NOTE_TIME VARCHAR(10),
	NOTE_TYPE_CONCEPT_ID NUMBER(38,0) NOT NULL,
	PERSON_ID NUMBER(38,0) NOT NULL,
	PROVIDER_ID NUMBER(38,0),
	VISIT_OCCURRENCE_ID NUMBER(38,0),
	primary key (NOTE_ID)
);

create or replace TABLE database.schema_omop.PAYER_PLAN_PERIOD (
	PAYER_PLAN_PERIOD_ID NUMBER(38,0) NOT NULL,
	PERSON_ID NUMBER(38,0) NOT NULL,
	CONTRACT_PERSON_ID NUMBER(38,0),
	PAYER_PLAN_PERIOD_START_DATE DATE NOT NULL,
	PAYER_PLAN_PERIOD_END_DATE DATE NOT NULL,
	PAYER_CONCEPT_ID NUMBER(38,0) NOT NULL,
	PLAN_CONCEPT_ID NUMBER(38,0) NOT NULL,
	CONTRACT_CONCEPT_ID NUMBER(38,0) NOT NULL,
	SPONSOR_CONCEPT_ID NUMBER(38,0) NOT NULL,
	STOP_REASON_CONCEPT_ID NUMBER(38,0) NOT NULL,
	PAYER_SOURCE_VALUE VARCHAR(50),
	PAYER_SOURCE_CONCEPT_ID NUMBER(38,0) NOT NULL,
	PLAN_SOURCE_VALUE VARCHAR(50),
	PLAN_SOURCE_CONCEPT_ID NUMBER(38,0) NOT NULL,
	CONTRACT_SOURCE_VALUE VARCHAR(50),
	CONTRACT_SOURCE_CONCEPT_ID NUMBER(38,0) NOT NULL,
	SPONSOR_SOURCE_VALUE VARCHAR(50),
	SPONSOR_SOURCE_CONCEPT_ID NUMBER(38,0) NOT NULL,
	FAMILY_SOURCE_VALUE VARCHAR(50),
	STOP_REASON_SOURCE_VALUE VARCHAR(50),
	STOP_REASON_SOURCE_CONCEPT_ID NUMBER(38,0) NOT NULL,
	primary key (PAYER_PLAN_PERIOD_ID)
);

create or replace TABLE database.schema_omop.SPECIMEN (
	SPECIMEN_ID NUMBER(38,0) NOT NULL,
	PERSON_ID NUMBER(38,0) NOT NULL,
	SPECIMEN_CONCEPT_ID NUMBER(38,0) NOT NULL,
	SPECIMEN_TYPE_CONCEPT_ID NUMBER(38,0) NOT NULL,
	SPECIMEN_DATE DATE,
	SPECIMEN_DATETIME TIMESTAMP_NTZ(9) NOT NULL,
	QUANTITY NUMBER(38,0),
	UNIT_CONCEPT_ID NUMBER(38,0),
	ANATOMIC_SITE_CONCEPT_ID NUMBER(38,0) NOT NULL,
	DISEASE_STATUS_CONCEPT_ID NUMBER(38,0) NOT NULL,
	SPECIMEN_SOURCE_ID VARCHAR(50),
	SPECIMEN_SOURCE_VALUE VARCHAR(50),
	UNIT_SOURCE_VALUE VARCHAR(50),
	ANATOMIC_SITE_SOURCE_VALUE VARCHAR(50),
	DISEASE_STATUS_SOURCE_VALUE VARCHAR(50),
	primary key (SPECIMEN_ID)
);

create or replace TABLE database.schema_omop.VISIT_DETAIL (
	VISIT_DETAIL_ID NUMBER(38,0) NOT NULL,
	PERSON_ID NUMBER(38,0) NOT NULL,
	VISIT_DETAIL_CONCEPT_ID NUMBER(38,0) NOT NULL,
	VISIT_DETAIL_START_DATE DATE,
	VISIT_DETAIL_START_DATETIME TIMESTAMP_NTZ(9) NOT NULL,
	VISIT_DETAIL_END_DATE DATE,
	VISIT_DETAIL_END_DATETIME TIMESTAMP_NTZ(9) NOT NULL,
	VISIT_DETAIL_TYPE_CONCEPT_ID NUMBER(38,0) NOT NULL,
	PROVIDER_ID NUMBER(38,0),
	CARE_SITE_ID NUMBER(38,0),
	DISCHARGE_TO_CONCEPT_ID NUMBER(38,0) NOT NULL,
	ADMITTED_FROM_CONCEPT_ID NUMBER(38,0) NOT NULL,
	ADMITTED_FROM_SOURCE_VALUE VARCHAR(50),
	VISIT_DETAIL_SOURCE_VALUE VARCHAR(50),
	VISIT_DETAIL_SOURCE_CONCEPT_ID NUMBER(38,0) NOT NULL,
	DISCHARGE_TO_SOURCE_VALUE VARCHAR(50),
	PRECEDING_VISIT_DETAIL_ID NUMBER(38,0),
	VISIT_DETAIL_PARENT_ID NUMBER(38,0),
	VISIT_OCCURRENCE_ID NUMBER(38,0) NOT NULL,
	ADMITTING_SOURCE_VALUE VARCHAR(50),
	ADMITTING_SOURCE_CONCEPT_ID NUMBER(38,0),
	primary key (VISIT_DETAIL_ID)
);