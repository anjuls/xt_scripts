@inc/input_vars_init.sql
set timing off
col owner       new_val _owner      format a20
col object_name new_val _object     format a30
col object_type new_val _type       format a15
col subobject_name                  format a30
col timestamp                       format a20

select distinct
  nvl(o2.owner          ,o.owner          ) owner
 ,nvl(o2.object_name    ,o.object_name    ) object_name
 ,nvl(o2.subobject_name ,o.subobject_name ) subobject_name
 ,nvl(o2.object_id      ,o.object_id      ) object_id
 ,nvl(o2.data_object_id ,o.data_object_id ) data_object_id
 ,nvl(o2.object_type    ,o.object_type    ) object_type
 ,nvl(o2.created        ,o.created        ) created
 ,nvl(o2.last_ddl_time  ,o.last_ddl_time  ) last_ddl_time
 ,nvl(o2.timestamp      ,o.timestamp      ) timestamp
 ,nvl(o2.status         ,o.status         ) status
 ,nvl(o2.temporary      ,o.temporary      ) temporary
 ,nvl(o2.generated      ,o.generated      ) generated
from dba_objects o
    ,dba_synonyms syn
    ,dba_objects o2
where o.object_name like upper(regexp_substr('&1','[^.]+$'))
  and o.owner  like case when instr('&1','.')>0 then upper(regexp_substr('&1','^[^.]*'))
                         when '&2' is not null then upper('&2')
                         else '%'
                    end
  and o.owner         = syn.owner(+)
  and o.OBJECT_NAME   = syn.synonym_name(+)
  and syn.table_owner = o2.OWNER(+)
  and syn.table_name  = o2.OBJECT_NAME(+)
order by 
      decode(nvl(o2.owner          ,o.owner          )
               ,'SYS',1
               ,2
            )
     ,decode(nvl(o2.object_type    ,o.object_type    )
               ,'TABLE'  ,4
               ,'INDEX'  ,3
               ,'VIEW'   ,2
               ,'PACKAGE',1
               ,0
            )
/
prompt Describing &_type  &_owner..&_object....
set termout off
col _exec           new_val _exec           noprint
col _show_seg       new_val _show_seg       noprint
col _get_indexes    new_val _get_indexes    noprint
select case '&_type'
        when 'INDEX' then 'desc_index'
        when 'TABLE' then 'desc_table'
        else 'desc'
      end as "_EXEC"
      ,case when '&_type' in ('INDEX','TABLE') then 'seg'
            else 'inc/null'
       end "_show_seg"
      ,case when '&_type'='TABLE' then 'indexes'
            else 'inc/null'
       end "_get_indexes"
from dual;
set termout on
@inc/&_exec         "&_object" "&_owner"
@inc/input_vars_undef.sql
@&_get_indexes      "&_object" "&_owner"
@&_show_seg         "&_object" "&_owner"
undef _owner _object _type
@inc/input_vars_undef.sql