SELECT *
  FROM all_tab_privs
 WHERE privilege = 'EXECUTE'
  AND grantor not in ('SYS')
  AND TYPE in ('PROCEDURE')
  AND GRANTEE in ('PUBLIC','APEX_PUBLIC_USER');