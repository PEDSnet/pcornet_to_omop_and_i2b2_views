-- create vocabulary empty tables
create or replace database.vocabulary;

CREATE TABLE database.vocabulary.concept (
concept_id INTEGER NOT NULL, 
concept_name VARCHAR(512) NOT NULL, 
domain_id VARCHAR(20) NOT NULL, 
vocabulary_id VARCHAR(20) NOT NULL, 
concept_class_id VARCHAR(50) NOT NULL, 
standard_concept VARCHAR(1), 
concept_code VARCHAR(256) NOT NULL, 
valid_start_date DATE NOT NULL,
valid_end_date DATE NOT NULL, 
invalid_reason VARCHAR(1),
CONSTRAINT database.vocabulary.xpk_concept PRIMARY KEY (concept_id)
);

CREATE TABLE database.vocabulary.concept_ancestor (
ancestor_concept_id INTEGER NOT NULL, 
descendant_concept_id INTEGER NOT NULL, 
min_levels_of_separation INTEGER NOT NULL,
max_levels_of_separation INTEGER NOT NULL, 
CONSTRAINT database.vocabulary.xpk_concept_ancestor PRIMARY KEY (ancestor_concept_id, descendant_concept_id)
);

CREATE TABLE database.vocabulary.concept_class (
concept_class_id VARCHAR(50) NOT NULL, 
concept_class_name VARCHAR(255) NOT NULL, 
concept_class_concept_id INTEGER NOT NULL,
CONSTRAINT database.vocabulary.xpk_concept_class PRIMARY KEY (concept_class_id)
);

CREATE TABLE database.vocabulary.concept_relationship (
concept_id_1 INTEGER NOT NULL, 
concept_id_2 INTEGER NOT NULL,
relationship_id VARCHAR(20) NOT NULL, 
valid_start_date DATE NOT NULL,
valid_end_date DATE NOT NULL,
invalid_reason VARCHAR(1), 
CONSTRAINT database.vocabulary.xpk_concept_relationship PRIMARY KEY (concept_id_1, concept_id_2, relationship_id)
);

CREATE TABLE database.vocabulary.concept_synonym (
concept_id INTEGER NOT NULL, 
concept_synonym_name VARCHAR(1200) NOT NULL, 
language_concept_id INTEGER NOT NULL
);

CREATE TABLE database.vocabulary.domain (
domain_id VARCHAR(20) NOT NULL, 
domain_name VARCHAR(255) NOT NULL,
domain_concept_id INTEGER NOT NULL,
CONSTRAINT database.vocabulary.xpk_domain PRIMARY KEY (domain_id)
);

CREATE TABLE database.vocabulary.drug_strength (
drug_concept_id INTEGER NOT NULL, 
ingredient_concept_id INTEGER NOT NULL,
amount_value NUMERIC(20, 5),
amount_unit_concept_id INTEGER,
numerator_value NUMERIC(20,0),
numerator_unit_concept_id INTEGER, 
denominator_value NUMERIC(20, 5),
denominator_unit_concept_id INTEGER, 
box_size INTEGER, 
valid_start_date DATE NOT NULL, 
valid_end_date DATE NOT NULL, 
invalid_reason VARCHAR(1),
CONSTRAINT database.vocabulary.xpk_drug_strength PRIMARY KEY (drug_concept_id, ingredient_concept_id)
);

CREATE TABLE database.vocabulary.relationship (
relationship_id VARCHAR(20) NOT NULL, 
relationship_name VARCHAR(255) NOT NULL, 
is_hierarchical VARCHAR(1) NOT NULL, 
defines_ancestry VARCHAR(1) NOT NULL, 
reverse_relationship_id VARCHAR(20) NOT NULL,
relationship_concept_id INTEGER NOT NULL, 
CONSTRAINT database.vocabulary.xpk_relationship PRIMARY KEY (relationship_id)
);

CREATE TABLE database.vocabulary.vocabulary (
vocabulary_id VARCHAR(20) NOT NULL, 
vocabulary_name VARCHAR(255) NOT NULL, 
vocabulary_reference VARCHAR(255), 
vocabulary_version VARCHAR(255), 
vocabulary_concept_id INTEGER NOT NULL, 
CONSTRAINT database.vocabulary.xpk_vocabulary PRIMARY KEY (vocabulary_id)
);

-- load data from tables to csv
-- csvs need to be added to a staging environment to load
-- data in 1_setup/data/omop_vocabulary/

COPY into database.vocabulary.concept
from @"<stagename>"/omop_vocabulary/concept.csv
FILE_FORMAT = 
    (
        type = csv 
        record_delimiter = '\n' 
        field_delimiter = ',' 
        FIELD_OPTIONALLY_ENCLOSED_BY = '0x22' 
    )
;

COPY into database.vocabulary.concept_ancestor
from @"<stagename>"/omop_vocabulary/concept_ancestor.csv
FILE_FORMAT = 
    (
        type = csv 
        record_delimiter = '\n' 
        field_delimiter = ',' 
        FIELD_OPTIONALLY_ENCLOSED_BY = '0x22' 
    )
;

COPY into database.vocabulary.concept_class
from @"<stagename>"/omop_vocabulary/concept_class.csv
FILE_FORMAT = 
    (
        type = csv 
        record_delimiter = '\n' 
        field_delimiter = ',' 
        FIELD_OPTIONALLY_ENCLOSED_BY = '0x22' 
    )
;

COPY into database.vocabulary.concept_relationship
from @"<stagename>"/omop_vocabulary/concept_relationship.csv
FILE_FORMAT = 
    (
        type = csv 
        record_delimiter = '\n' 
        field_delimiter = ',' 
        FIELD_OPTIONALLY_ENCLOSED_BY = '0x22' 
    )
;

COPY into database.vocabulary.concept_synonym
from @"<stagename>"/omop_vocabulary/concept_synonym.csv
FILE_FORMAT = 
    (
        type = csv 
        record_delimiter = '\n' 
        field_delimiter = ',' 
        FIELD_OPTIONALLY_ENCLOSED_BY = '0x22' 
    )
;

COPY into database.vocabulary.domain
from @"<stagename>"/omop_vocabulary/domain.csv
FILE_FORMAT = 
    (
        type = csv 
        record_delimiter = '\n' 
        field_delimiter = ',' 
        FIELD_OPTIONALLY_ENCLOSED_BY = '0x22' 
    )
;

COPY into database.vocabulary.drug_strength
from @"<stagename>"/omop_vocabulary/drug_strength.csv
FILE_FORMAT = 
    (
        type = csv 
        record_delimiter = '\n' 
        field_delimiter = ',' 
        FIELD_OPTIONALLY_ENCLOSED_BY = '0x22' 
    )
;

COPY into database.vocabulary.relationship
from @"<stagename>"/omop_vocabulary/relationship.csv
FILE_FORMAT = 
    (
        type = csv 
        record_delimiter = '\n' 
        field_delimiter = ',' 
        FIELD_OPTIONALLY_ENCLOSED_BY = '0x22' 
    )
;

COPY into database.vocabulary.vocabulary
from @"<stagename>"/omop_vocabulary/vocabulary.csv
FILE_FORMAT = 
    (
        type = csv 
        record_delimiter = '\n' 
        field_delimiter = ',' 
        FIELD_OPTIONALLY_ENCLOSED_BY = '0x22' 
    )
;