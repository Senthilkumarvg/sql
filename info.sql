/* info.sql */
/* Raymond Jongeneel */
/* 13 juli 2012 : created */
/* contains interesting sql  */

whenever sqlerror then continue;

select * from v$database;

-- om SQL Tuning adviser te kunnen runnen moeten de volgende system privileges
-- toegekend worden onder sys
grant advisor, administer sql tuning set, select any dictionary to comp_sis;