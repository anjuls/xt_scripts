@inc/input_vars_init;
set termout off timing off head off feed off
col qtext format a1500
prompt ################################  Original query text:  ################################################;
spool &_SPOOLS/to_format.sql
select df.VIEW_DEFINITION
from v$fixed_view_definition df 
where df.VIEW_NAME like upper('&1')
;
spool off
col qtext   clear
set termout on head on
prompt ################################  Formatted query text #################################################;
--host perl inc/sql_format_standalone.pl &_SPOOLS/to_format.sql
host java -jar inc/SQLBeautifier.jar &_SPOOLS/to_format.sql
prompt ################################  Formatted query text End #############################################;
@inc/input_vars_undef;