-- Creat a genral Exception loger
-- Just put "LOG_EXCEPTION;" in the begining of your exception block

CREATE TABLE EXCEPTION_LOG 
(
  PARTKEY NUMBER DEFAULT TO_NUMBER(TO_CHAR(SYSDATE,'YYYYMMDD')) 
, ERROR_ID NUMBER NOT NULL 
, ERROR_DATE TIMESTAMP(6) DEFAULT SYSTIMESTAMP 
, SC_CURRENT_SCHEMA VARCHAR2(32 BYTE) DEFAULT UPPER(SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')) 
, SC_MODULE VARCHAR2(64 BYTE) DEFAULT UPPER(SYS_CONTEXT('USERENV', 'MODULE')) 
, SC_ACTION VARCHAR2(32 BYTE) DEFAULT UPPER(SYS_CONTEXT('USERENV', 'ACTION')) 
, SC_OS_USER VARCHAR2(32 BYTE) DEFAULT UPPER(SYS_CONTEXT('USERENV', 'OS_USER')) 
, SC_CLIENT_IDENTIFIER VARCHAR2(64 BYTE) DEFAULT UPPER(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER')) 
, SC_CLIENT_INFO VARCHAR2(64 BYTE) DEFAULT UPPER(SYS_CONTEXT('USERENV', 'CLIENT_INFO')) 
, SC_NLS_DATE_FORMAT VARCHAR2(64 BYTE) DEFAULT UPPER(SYS_CONTEXT('USERENV', 'NLS_DATE_FORMAT')) 
, SC_HOST VARCHAR2(64 BYTE) DEFAULT UPPER(SYS_CONTEXT('USERENV', 'HOST')) 
, SC_INSTANCE VARCHAR2(32 BYTE) DEFAULT UPPER(SYS_CONTEXT('USERENV', 'INSTANCE')) 
, SC_IP_ADDRESS VARCHAR2(32 BYTE) DEFAULT UPPER(SYS_CONTEXT('USERENV', 'IP_ADDRESS')) 
, SC_SERVICE_NAME VARCHAR2(64 BYTE) DEFAULT UPPER(SYS_CONTEXT('USERENV', 'SERVICE_NAME')) 
, SC_SESSION_USER VARCHAR2(32 BYTE) DEFAULT UPPER(SYS_CONTEXT('USERENV', 'SESSION_USER')) 
, SC_SESSIONID VARCHAR2(32 BYTE) DEFAULT UPPER(SYS_CONTEXT('USERENV', 'SESSIONID')) 
, SC_SID VARCHAR2(32 BYTE) DEFAULT UPPER(SYS_CONTEXT('USERENV', 'SID')) 
, SQL_ROWCOUNT NUMBER(*, 0) 
, SQL_ERROR_CODE NUMBER(*, 0) 
, SQL_ERROR_MESSAGE VARCHAR2(512 BYTE) 
, CALL_STACK VARCHAR2(2000 BYTE) 
, ERROR_BACKTRACE VARCHAR2(4000 BYTE) 
, ERROR_STACK VARCHAR2(2000 BYTE) 
) ;

 CREATE SEQUENCE exception_seq MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1 CACHE 20 NOORDER  NOCYCLE ;


create or replace trigger error_log_bi_trg BEFORE INSERT ON exception_log REFERENCING NEW AS NEW OLD AS OLD FOR EACH ROW
BEGIN
  select exception_seq.nextval into :new.error_id from dual;
END;

create or replace PACKAGE exception_pkg_v1 IS

  /******************************************************************************
   DESCRIPTION:
     This package provides APIs for logging PL/SQL exceptions as defined in  database standard.

   REVISION HISTORY:
     Ver        Date        Author           Actions
     ---------  ----------  ---------------  ------------------------------------
     1.0        28/02/2012  Han Xie          Creation of this package.
  ******************************************************************************/

  PROCEDURE log_exception;
END;

create or replace PACKAGE BODY                            exception_pkg_v1 IS

  /******************************************************************************
   DESCRIPTION:
     This package provides APIs for managing db links as defined in PUMA database standard.

   REVISION HISTORY:
     Ver        Date        Author           Actions
     ---------  ----------  ---------------  ------------------------------------
     1.0        28/02/2012  Han Xie          Creation of this package.
  ******************************************************************************/

  PROCEDURE log_exception as PRAGMA AUTONOMOUS_TRANSACTION;
    v_sql_rowcount                  INTEGER := -1;  -- SQL%ROWCOUNT
    v_sql_error_code                INTEGER;        -- SQLCODE
    v_sql_error_message             VARCHAR2(512);  -- SQLERRM, Still useful occasionally, e.g. "FORALL with SAVE EXCEPTIONS clause".
    v_call_stack                    VARCHAR2(2000); -- DBMS_UTILITY.FORMAT_CALL_STACK
    v_error_backtrace               VARCHAR2(4000); -- DBMS_UTILITY.FORMAT_ERROR_BACKTRACE
    v_error_stack                   VARCHAR2(2000); -- DBMS_UTILITY.FORMAT_ERROR_STACK
  BEGIN
    v_sql_rowcount      := SQL%ROWCOUNT;
    v_sql_error_code    := SQLCODE;
    v_sql_error_message := SQLERRM;
    v_call_stack        := DBMS_UTILITY.FORMAT_CALL_STACK;
    v_error_backtrace   := substr(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, 1, 4000);
    v_error_stack       := DBMS_UTILITY.FORMAT_ERROR_STACK;

    insert into exception_log
      (sql_rowcount,   sql_error_code,   sql_error_message,   call_stack,   error_backtrace,   error_stack)  values
      (v_sql_rowcount, v_sql_error_code, v_sql_error_message, v_call_stack, v_error_backtrace, v_error_stack);
      commit;
  END;
END;


 CREATE OR REPLACE PUBLIC SYNONYM "LOG_EXCEPTION" FOR exception_pkg_v1.log_exception;