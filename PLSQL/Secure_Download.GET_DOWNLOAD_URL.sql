create or replace FUNCTION GET_DOWNLOAD_URL 
(
  P_DOC_ID IN NUMBER default NULL
, P_APPLICANT_ID IN NUMBER default NULL 
, P_DOC_NAME in VARCHAR2 default NULL
, P_TYPE IN VARCHAR2  -- i = indevidual file, zi = zip indevidual file, za= zip all applicant files
) RETURN VARCHAR2 AS 
/*---------------
    Developed by ATK (Arash Tabeh Khalilian) on July 2016, 
    This function generate URL with SHA256 Hash token to secure douwnload
    It work in relation to Downoad procedure
    Version  Developer Date        Comment
    v1.0     ATK       04/07/2016  First version complete new to secure security vulnerability of download procedure
*/
  
  C_HASH_ADD_PHRASE constant varchar2(40) := 'ATKXYZGUIWHV5TO3WO45VHYT345' ; -- A randome code to make regenerate of hash harder same yo download procedure
  C_DOWNLOAD_PROCEDURE constant varchar2(40) := 'IITB_DOWNLOAD' ; -- procedure that do download (it was face security issue)
  
  v_schema varchar2(255);
  v_URL  varchar2(256);
  v_CLIENT_IP varchar2(32);
  v_DATE varchar2(32);
  v_HASH_STR varchar2(255);

BEGIN
  
  if P_DOC_ID is null and P_APPLICANT_ID is null then
    return 'Error1:No Doc ID or Applicant ID!';
  end if;
  
  v_schema := nvl( v('OWNER'), 'S_BABA'  ) ; --S1_CUSTOM
  v_CLIENT_IP := OWA_UTIL.get_cgi_env ('REMOTE_ADDR'); 
  v_DATE := to_char(sysdate , 'YYYYMMDD') ;
  v_HASH_STR := to_char(P_DOC_ID) ||'-' || v_CLIENT_IP || '-'|| to_char(P_APPLICANT_ID) ||'-' || v_DATE || P_TYPE || C_HASH_ADD_PHRASE || v('SESSION') || P_DOC_NAME ;
  --DBMS_OUTPUT.PUT_LINE('hash_str = ' || v_HASH_STR);
  
  
  
  v_URL := v_schema || '.' || C_DOWNLOAD_PROCEDURE|| '?';
  if P_DOC_ID is not null then 
    v_URL := v_URL || 'p_doc_id=' || P_DOC_ID ;
  end if;
  if P_APPLICANT_ID is not null then 
    if P_DOC_ID is not null then  
       v_URL := v_URL || '&' ; 
    end if;
    v_URL := v_URL || 'p_applic_id=' || P_APPLICANT_ID ;
  end if;
  v_URL := v_URL || '&p_type=' || P_TYPE ;
  v_URL := v_URL || '&p_session=' || v('SESSION') ;
  v_URL := v_URL || '&p_hash=' || sha256.encrypt(v_HASH_STR) ;
  
  --DBMS_OUTPUT.PUT_LINE('URL = ' || v_URL);
  RETURN v_URL;
  
  exception 
    When others THEN
    
    return 'ERROR2' ;
  
  
END GET_DOWNLOAD_URL;