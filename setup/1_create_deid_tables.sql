-- demographic deid
create schema database.schema_pcornet_deid;

create or replace table database.schema_pcornet_deid.PCORNET_DEID_demographic as 
select 
    demo.* exclude patid,
    map1.person_id::varchar as patid
from 
    database.schema_pcornet.demographic demo
inner join 
    database.schema_pcornet.map_patid map1
    on map1.patid = demo.patid;

-- enrollment deid
create or replace table database.schema_pcornet_deid.PCORNET_DEID_enrollment as 
select 
    enr.* exclude patid,
    map1.person_id::varchar as patid
from 
    database.schema_pcornet.enrollment enr
inner join 
    database.schema_pcornet.map_patid map1
    on map1.patid = enr.patid;

-- provider deid
create or replace table database.schema_pcornet_deid.PCORNET_DEID_provider as 
select 
    pro.* exclude providerid,
    map2.provider_id::varchar as providerid
from 
    database.schema_pcornet.provider pro
inner join 
    database.schema_pcornet.map_providerid map2
    on map2.providerid = pro.providerid;

-- encounter deid
create or replace table database.schema_pcornet_deid.PCORNET_DEID_encounter as 
select 
    enc.* exclude (patid, providerid, encounterid, facilityid),
    map1.person_id::varchar as patid,
    map2.provider_id::varchar as providerid,
    map3.visit_occurrence_id::varchar as encounterid,
    map4.care_site_id::varchar as facilityid
from 
    database.schema_pcornet.encounter enc
inner join 
    database.schema_pcornet.map_patid map1
    on map1.patid = enc.patid
left join 
    database.schema_pcornet.map_providerid map2
    on map2.providerid = enc.providerid
inner join 
    database.schema_pcornet.map_encounterid map3
    on map3.encounterid = enc.encounterid
left join 
    database.schema_pcornet.map_facilityid map4
    on map4.facilityid = enc.facilityid
;

-- diagnosis deid
create or replace sequence database.schema_pcornet_deid.diagnosis_seq start = 1 increment = 1;

create or replace table database.schema_pcornet_deid.PCORNET_DEID_diagnosis as 
select 
    dia.* exclude (diagnosisid, patid, providerid, encounterid),
    database.schema_pcornet_deid.diagnosis_seq.nextval::varchar as diagnosisid,
    map1.person_id::varchar as patid,
    map2.provider_id::varchar as providerid,
    map3.visit_occurrence_id::varchar as encounterid
from 
    database.schema_pcornet.diagnosis dia
inner join 
    database.schema_pcornet.map_patid map1
    on map1.patid = dia.patid
left join 
    database.schema_pcornet.map_providerid map2
    on map2.providerid = dia.providerid
left join 
    database.schema_pcornet.map_encounterid map3
    on map3.encounterid = dia.encounterid
;

-- procedures deid
create or replace sequence database.schema_pcornet_deid.procedures_seq start = 1 increment = 1;

create or replace table database.schema_pcornet_deid.PCORNET_DEID_procedures as 
select 
    proc.* exclude (proceduresid, patid, providerid, encounterid),
    database.schema_pcornet_deid.procedures_seq.nextval::varchar as proceduresid,
    map1.person_id::varchar as patid,
    map2.provider_id::varchar as providerid,
    map3.visit_occurrence_id::varchar as encounterid
from 
    database.schema_pcornet.procedures proc
inner join 
    database.schema_pcornet.map_patid map1
    on map1.patid = proc.patid
left join 
    database.schema_pcornet.map_providerid map2
    on map2.providerid = proc.providerid
left join 
    database.schema_pcornet.map_encounterid map3
    on map3.encounterid = proc.encounterid
;

-- vital deid
create or replace sequence database.schema_pcornet_deid.vital_seq start = 1 increment = 1;

create or replace table database.schema_pcornet_deid.PCORNET_DEID_vital as 
select 
    vit.* exclude (vitalid, patid, encounterid),
    database.schema_pcornet_deid.vital_seq.nextval::varchar as vitalid,
    map1.person_id::varchar as patid,
    map3.visit_occurrence_id::varchar as encounterid
from 
    database.schema_pcornet.vital vit
inner join 
    database.schema_pcornet.map_patid map1
    on map1.patid = vit.patid
left join 
    database.schema_pcornet.map_encounterid map3
    on map3.encounterid = vit.encounterid
;

-- dispensing deid
create or replace sequence database.schema_pcornet_deid.dispensing_seq start = 1 increment = 1;

create or replace table database.schema_pcornet_deid.PCORNET_DEID_dispensing as 
select 
    disp.* exclude (dispensingid, patid, prescribingid),
    database.schema_pcornet_deid.dispensing_seq.nextval::varchar as dispensingid,
    map1.person_id::varchar as patid,
    null as prescribingid
from 
    database.schema_pcornet.dispensing disp
inner join 
    database.schema_pcornet.map_patid map1
    on map1.patid = disp.patid
;

-- lab_result_cm deid
create or replace sequence database.schema_pcornet_deid.lab_result_cm_seq start = 1 increment = 1;

create or replace table database.schema_pcornet_deid.PCORNET_DEID_lab_result_cm as 
select 
    lab.* exclude (lab_result_cm_id, patid, encounterid),
    database.schema_pcornet_deid.lab_result_cm_seq.nextval::varchar as lab_result_cm_id,
    map1.person_id::varchar as patid,
    map3.visit_occurrence_id::varchar as encounterid
from 
    database.schema_pcornet.lab_result_cm lab
inner join 
    database.schema_pcornet.map_patid map1
    on map1.patid = lab.patid
left join 
    database.schema_pcornet.map_encounterid map3
    on map3.encounterid = lab.encounterid
;

-- condition deid
create or replace sequence database.schema_pcornet_deid.condition_seq start = 1 increment = 1;

create or replace table database.schema_pcornet_deid.PCORNET_DEID_condition as 
select 
    cond.* exclude (conditionid, patid, encounterid),
    database.schema_pcornet_deid.condition_seq.nextval::varchar as conditionid,
    map1.person_id::varchar as patid,
    map3.visit_occurrence_id::varchar as encounterid
from 
    database.schema_pcornet.condition cond
inner join 
    database.schema_pcornet.map_patid map1
    on map1.patid = cond.patid
left join 
    database.schema_pcornet.map_encounterid map3
    on map3.encounterid = cond.encounterid
;

-- pro_cm deid
create or replace sequence database.schema_pcornet_deid.pro_cm_seq start = 1 increment = 1;

create or replace table database.schema_pcornet_deid.PCORNET_DEID_pro_cm as 
select 
    pro_cm.* exclude (pro_cm_id, patid, encounterid),
    database.schema_pcornet_deid.pro_cm_seq.nextval::varchar as pro_cm_id,
    map1.person_id::varchar as patid,
    map3.visit_occurrence_id::varchar as encounterid
from 
    database.schema_pcornet.pro_cm pro_cm
inner join 
    database.schema_pcornet.map_patid map1
    on map1.patid = pro_cm.patid
left join 
    database.schema_pcornet.map_encounterid map3
    on map3.encounterid = pro_cm.encounterid
;

-- prescribing deid
create or replace sequence database.schema_pcornet_deid.prescribing_seq start = 1 increment = 1;

create or replace table database.schema_pcornet_deid.PCORNET_DEID_prescribing as 
select 
    pres.* exclude (prescribingid, patid, rx_providerid, encounterid),
    database.schema_pcornet_deid.prescribing_seq.nextval::varchar as prescribingid,
    map1.person_id::varchar as patid,
    map2.provider_id::varchar as rx_providerid,
    map3.visit_occurrence_id::varchar as encounterid
from 
    database.schema_pcornet.prescribing pres
inner join 
    database.schema_pcornet.map_patid map1
    on map1.patid = pres.patid
left join 
    database.schema_pcornet.map_providerid map2
    on map2.providerid = pres.rx_providerid
left join 
    database.schema_pcornet.map_encounterid map3
    on map3.encounterid = pres.encounterid
;

-- pcornet_trial deid
create or replace table database.schema_pcornet_deid.PCORNET_DEID_pcornet_trial as 
select 
    tri.* exclude (patid),
    map1.person_id::varchar as patid,
from 
    database.schema_pcornet.pcornet_trial tri
inner join 
    database.schema_pcornet.map_patid map1
    on map1.patid = tri.patid
;

-- death deid
create or replace table database.schema_pcornet_deid.PCORNET_DEID_death as 
select 
    death.* exclude (patid),
    map1.person_id::varchar as patid,
from 
    database.schema_pcornet.death death
inner join 
    database.schema_pcornet.map_patid map1
    on map1.patid = death.patid
;

-- death_cause deid
create or replace table database.schema_pcornet_deid.PCORNET_DEID_death_cause as 
select 
    death.* exclude (patid),
    map1.person_id::varchar as patid,
from 
    database.schema_pcornet.death_cause death
inner join 
    database.schema_pcornet.map_patid map1
    on map1.patid = death.patid
;

-- med_admin deid
create or replace sequence database.schema_pcornet_deid.med_admin_seq start = 1 increment = 1;

create or replace table database.schema_pcornet_deid.PCORNET_DEID_med_admin as 
select 
    med_admin.* exclude (medadminid, patid, medadmin_providerid, encounterid, prescribingid),
    database.schema_pcornet_deid.med_admin_seq.nextval::varchar as medadminid,
    map1.person_id::varchar as patid,
    map2.provider_id::varchar as medadmin_providerid,
    map3.visit_occurrence_id::varchar as encounterid,
    null as prescribingid
from 
    database.schema_pcornet.med_admin med_admin
inner join 
    database.schema_pcornet.map_patid map1
    on map1.patid = med_admin.patid
left join 
    database.schema_pcornet.map_providerid map2
    on map2.providerid = med_admin.medadmin_providerid
left join 
    database.schema_pcornet.map_encounterid map3
    on map3.encounterid = med_admin.encounterid
;

-- obs_clin deid
create or replace sequence database.schema_pcornet_deid.obs_clin_seq start = 1 increment = 1;

create or replace table database.schema_pcornet_deid.PCORNET_DEID_obs_clin as 
select 
    obs.* exclude (obsclinid, patid, obsclin_providerid, encounterid),
    database.schema_pcornet_deid.obs_clin_seq.nextval::varchar as obsclinid,
    map1.person_id::varchar as patid,
    map2.provider_id::varchar as obsclin_providerid,
    map3.visit_occurrence_id::varchar as encounterid
from 
    database.schema_pcornet.obs_clin obs
inner join 
    database.schema_pcornet.map_patid map1
    on map1.patid = obs.patid
left join 
    database.schema_pcornet.map_providerid map2
    on map2.providerid = obs.obsclin_providerid
left join 
    database.schema_pcornet.map_encounterid map3
    on map3.encounterid = obs.encounterid
;

-- obs_gen deid
create or replace sequence database.schema_pcornet_deid.obs_gen_seq start = 1 increment = 1;

create or replace table database.schema_pcornet_deid.PCORNET_DEID_obs_gen as 
select 
    obs.* exclude (obsgenid, patid, obsgen_providerid, encounterid),
    database.schema_pcornet_deid.obs_gen_seq.nextval::varchar as obsgenid,
    map1.person_id::varchar as patid,
    map2.provider_id::varchar as obsgen_providerid,
    map3.visit_occurrence_id::varchar as encounterid
from 
    database.schema_pcornet.obs_gen obs
inner join 
    database.schema_pcornet.map_patid map1
    on map1.patid = obs.patid
left join 
    database.schema_pcornet.map_providerid map2
    on map2.providerid = obs.obsgen_providerid
left join 
    database.schema_pcornet.map_encounterid map3
    on map3.encounterid = obs.encounterid
;

-- hash_token deid
create or replace table database.schema_pcornet_deid.PCORNET_DEID_hash_token as 
select 
    hash_token.* exclude (patid),
    map1.person_id::varchar as patid
from 
    database.schema_pcornet.hash_token hash_token
inner join 
    database.schema_pcornet.map_patid map1
    on map1.patid = hash_token.patid
;

-- LDS_ADDRESS_HISTORY deid
create or replace sequence database.schema_pcornet_deid.lds_address_seq start = 1 increment = 1;

create or replace table database.schema_pcornet_deid.PCORNET_DEID_LDS_ADDRESS_HISTORY as 
select 
    lds.* exclude (addressid, patid),
    database.schema_pcornet_deid.lds_address_seq.nextval::varchar as addressid,
    map1.person_id::varchar as patid
from 
    database.schema_pcornet.LDS_ADDRESS_HISTORY lds
inner join 
    database.schema_pcornet.map_patid map1
    on map1.patid = lds.patid
;

-- immunization deid
create or replace sequence database.schema_pcornet_deid.immunization_seq start = 1 increment = 1;

create or replace table database.schema_pcornet_deid.PCORNET_DEID_immunization as 
select 
    imm.* exclude (immunizationid, patid, vx_providerid, encounterid, proceduresid),
    database.schema_pcornet_deid.immunization_seq.nextval::varchar as immunizationid,
    map1.person_id::varchar as patid,
    map2.provider_id::varchar as vx_providerid,
    map3.visit_occurrence_id::varchar as encounterid,
    null as proceduresid
from 
    database.schema_pcornet.immunization imm
inner join 
    database.schema_pcornet.map_patid map1
    on map1.patid = imm.patid
left join 
    database.schema_pcornet.map_providerid map2
    on map2.providerid = imm.vx_providerid
left join 
    database.schema_pcornet.map_encounterid map3
    on map3.encounterid = imm.encounterid
;

-- harvest deid
create or replace table database.schema_pcornet_deid.PCORNET_DEID_harvest as 
select 
    *
from 
    database.schema_pcornet.harvest
;

-- lab_history deid
create or replace sequence database.schema_pcornet_deid.lab_hist_seq start = 1 increment = 1;

create or replace table database.schema_pcornet_deid.PCORNET_DEID_lab_history as 
select 
    * exclude (labhistoryid),
    database.schema_pcornet_deid.lab_hist_seq.nextval::varchar as labhistoryid,
from 
    database.schema_pcornet.lab_history
;

-- private_demographic deid - no new IDs since table is supposed to be private and wont be queried downstream
create or replace table database.schema_pcornet_deid.PCORNET_DEID_private_demographic as 
select 
    demo.* exclude patid,
    map1.person_id::varchar as patid
from 
    database.schema_pcornet.private_demographic demo
inner join 
    database.schema_pcornet.map_patid map1
    on map1.patid = demo.patid
;

-- PRIVATE_ADDRESS_HISTORY deid - no new IDs since table is supposed to be private and wont be queried downstream
create or replace table database.schema_pcornet_deid.PCORNET_DEID_PRIVATE_ADDRESS_HISTORY as 
select 
    lds.* exclude (patid),
    map1.person_id::varchar as patid
from 
    database.schema_pcornet.PRIVATE_ADDRESS_HISTORY lds
inner join 
    database.schema_pcornet.map_patid map1
    on map1.patid = lds.patid
;

-- private_address_geocode deid - no new IDs since table is supposed to be private and wont be queried downstream
create or replace table database.schema_pcornet_deid.PCORNET_DEID_private_address_geocode as 
select 
    *
from 
    database.schema_pcornet.private_address_geocode
;