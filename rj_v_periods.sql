/* cre_tab_periods_consolidation.sql */
/* Raymond Jongeneel */
/* 14 juli 2012 : created */
/* how to merge adjacing periods into one  */
whenever sqlerror THEN
CONTINUE;
DROP TABLE rj_periods_consolidation;
prompt Creating rj_periods_consolidation and insert test data


--------------------------------------------------------
--  DDL for Table RJ_PERIODS_CONSOLIDATION
--------------------------------------------------------

  CREATE TABLE "RJ_PERIODS_CONSOLIDATION" 
   (	"ID" NUMBER(5,0), 
	"SV" CHAR(1 CHAR), 
	"DB" DATE, 
	"DE" DATE
   ) ;
/
REM INSERTING into RJ_PERIODS_CONSOLIDATION
SET DEFINE OFF;
Insert into RJ_PERIODS_CONSOLIDATION (ID,SV,DB,DE) values ('1067','B',to_date('01-01-06','DD-MM-RR'),to_date('01-01-06','DD-MM-RR'));
Insert into RJ_PERIODS_CONSOLIDATION (ID,SV,DB,DE) values ('1067','B',to_date('01-01-07','DD-MM-RR'),to_date('31-12-07','DD-MM-RR'));
Insert into RJ_PERIODS_CONSOLIDATION (ID,SV,DB,DE) values ('1067','B',to_date('01-01-08','DD-MM-RR'),to_date('31-12-08','DD-MM-RR'));
Insert into RJ_PERIODS_CONSOLIDATION (ID,SV,DB,DE) values ('1067','B',to_date('01-01-09','DD-MM-RR'),to_date('31-12-09','DD-MM-RR'));
Insert into RJ_PERIODS_CONSOLIDATION (ID,SV,DB,DE) values ('1067','B',to_date('01-01-10','DD-MM-RR'),to_date('31-12-10','DD-MM-RR'));







/*
CREATE TABLE rj_periods_consolidation AS
SELECT pb.relatienr                   AS id ,
  pb.soort_verzekering                AS sv ,
  pb.d_begin                          AS db ,
  pb.d_eind                          AS de
FROM mzv_polisblad pb
WHERE 1=1
--and rownum < 101
and pb.relatienr = 1067
and pb.soort_verzekering = 'B'
ORDER BY pb.relatienr,
  pb.d_begin,
  pb.soort_verzekering;

*/

prompt Before the update of rj_periods_consolidation
SELECT *
FROM rj_periods_consolidation;

--create or replace view rj_v_periods as
--select distinct b.id as relatienr, b.sv as soort_verzekering, b.db_new as d_begin, b.de_new as d_eind
--from
--(
select a.id, a.sv , a.db, a.de, a.x, a.y, a.xx, a.yy 
, case when a.x = 1 and a.y = 'gap' then a.db
       when a.x <> 1 and a.y = 'no gap' then first_value(a.db) over (partition by a.id,a.sv order by a.db asc)
       end as db_new
, case when a.xx = 1 and a.yy = 'gap' then a.de
       when a.xx <> 1 and a.yy = 'no gap' then first_value(a.de) over (partition by a.id,a.sv order by a.de desc)
       end as de_new
from
 ( SELECT id,sv,db,de
  ,row_number() over (partition by id,sv order by db asc) as x
  ,case when lag(de,1,de) over (partition by id,sv order by db asc)+1 = db
   then 'no gap'
   else 'gap'
   end as y
  ,row_number() over (partition by id,sv order by db desc) as xx
  ,case when lag(db,1,db) over (partition by id,sv order by db desc)-1 = de
   then 'no gap'
   else 'gap'
   end as yy
  FROM rj_periods_consolidation
  ) a
  order by a.id, a.sv, a.db
--  ) b
--  order by b.id, case when b.sv = 'B' then 1 when b.sv = 'A' then 2 when b.sv = 'C' then 3 else 4 end, b.db_new
  ;

prompt After the update of rj_periods_consolidation
SELECT *
FROM rj_periods_consolidation;

select * from
(
select p.*, count(*) over (partition by p.relatienr, p.soort_verzekering) as aantal from rj_v_periods p --where p.soort_verzekering = 'B'
)
where aantal>1;
