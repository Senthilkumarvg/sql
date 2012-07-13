/* upd_tab_with_case.sql */
/* Raymond Jongeneel */
/* 13 juli 2012 : created */
/* update example for updating a table with a case statement  */

whenever sqlerror then continue;
drop table rj_test01;

create table rj_test01 (a varchar2(10),
                      b varchar2(10),
                      c varchar2(10));
                      
insert into rj_test01 (a,b,c) values ('aap','noot',null);                      
insert into rj_test01 (a,b,c) values ('ton','toon',null);                      

prompt Before the update of rj_test01
select * from rj_test01;

update                        
(select a,b,c,case when a='aap' then a when a<>'aap' then b end as d
from rj_test01)
set c=d;

prompt After the update of rj_test01
select * from rj_test01;
