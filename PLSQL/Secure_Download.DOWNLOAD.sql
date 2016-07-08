create or replace PROCEDURE    download(
 p_doc_id in number default null, 
 p_applic_id in number default null,
 p_type in varchar2 ,
 p_session in varchar2 ,
 p_hash in varchar2 
 )
 /*---------------
    Developed by ATK (Arash Tabeh Khalilian) on July 2016, 
    This procedure check SHA256 Hash token in URL and provide download to secure download
    It work in relation to function GET_DOWNLOAD_URL
    
    Types in version 1.0
    i = indvidual file
    a = all files of an applicant
    z = ZIP file
    
    Version  Developer Date        Comment
    v1.0     ATK       04/07/2016  First version complete rewrite of old simple download procedure with security vulnerability
*/
 
 IS
    C_HASH_ADD_PHRASE constant varchar2(40) := 'YOUR_SECURE_PHRASE' ; -- A randome code to make regenerate of hash harder
    V_DEBUG             number(5) := 0;  -- Debug mode >= 4 do not download files and just shows debug information
    
    l_blob              blob;
    l_mime              varchar2(48);
    l_size              number;
    l_filename          varchar2(255);
    l_DOC_SEQ_NUM       number;
    
    l_APPLIC_NUM        varchar2(255);
    v_CLIENT_IP         varchar2(32);
    v_DATE              varchar2(32);   
    v_NEW_HASH_STR      varchar2(255);
    v_NEW_HASH          varchar2(255);
    v_current_session   varchar2(255);
    v_session_exist     number(5);
    v_file_name         varchar2(255);
    v_student_name      varchar2(150);
    v_file_part_blob    blob;
  
 BEGIN
    -- Part one: Check and Sanitize varchar input to only expected format to prevent injection and security penetration attempt
           
    if (not REGEXP_LIKE(p_type,'^[a-z]{1,5}$') ) then --Type can be small letter and only maximum 5 charechter
      htp.print('<html><body>Smart Error: Wrong type data</body></html>');
      Raise_Application_Error (-20088, 'Wrong data input. Posibility of security penetration attempt.');
    end if;    
    if (not REGEXP_LIKE(p_hash,'^[a-z0-9]{64}$') ) then -- Hash is a 64 bit small charechter string
      htp.print('<html><body>Smart Error: Wrong hash data</body></html>');
      Raise_Application_Error (-20088, 'Wrong data input. Posibility of security penetration attempt.');
    end if;    
    if (not REGEXP_LIKE(p_session,'^\d+$') ) then -- session is a only number, no limit to keep compatibility to future APEX versions
      htp.print('<html><body>Smart Error: Wrong session data</body></html>');
      Raise_Application_Error (-20088, 'Wrong data input. Posibility of security penetration attempt.');
    end if;
    
    
    -- Part Two: Validate parameter input
    if (p_type is null) then
      --htp.print('<html><body>Error: Need file type</body></html>');
      Raise_Application_Error (-20087, 'Wrong data input. No file type!');
    elsif (p_doc_id is null and (p_type like '%i%' or  p_type like '%r%' ) ) then
      --htp.print('<html><body>Error: need Document ID</body></html>');
      Raise_Application_Error (-20087, 'Wrong data input. There is no Document ID!');
    elsif (p_applic_id is null and p_type like '%a%' ) then
      --htp.print('<html><body>Error: Need Applicant ID</body></html>');
      Raise_Application_Error (-20087, 'Wrong data input. There is no Applicant ID!');
    end if;
    
    
    -- Part three: Get file information
    if p_doc_id is not null and p_type like '%i%' then  -- Individual
      for c1 in (select doc_name, mime_type, blob_content, doc_size, APPLIC_NUM
                   from s1_custom.applic_document
                  where doc_seq_num = p_doc_id ) loop
          l_APPLIC_NUM:= c1.APPLIC_NUM;
          l_filename  := c1.doc_name;
          l_blob      := c1.blob_content;
          l_mime      := c1.mime_type;
          l_size      := dbms_lob.getlength(l_blob);
          v_file_name := l_APPLIC_NUM || '_' || replace(replace(l_filename,chr(10),null),chr(13),null) ;
          
      end loop;
    elsif p_applic_id is not null and p_type like '%a%' and p_type like '%z%' then  -- Download all files in zip (currently only)
      
      dbms_lob.createtemporary(l_blob, false);
      -- Get name
      select substr(lower(replace(trim(given_names) || '_' || trim(surname) ,' ','_')),1,100 )
             into v_student_name
             from student 
             where form_a_number = p_applic_id ;
      
      for c1 in (select DOC_SEQ_NUM, doc_name, mime_type, blob_content, doc_size
                   from s1_custom.applic_document
                  where APPLIC_NUM = p_applic_id ) loop
          l_DOC_SEQ_NUM     := c1.DOC_SEQ_NUM;
          l_filename        := c1.doc_name;
          v_file_part_blob  := c1.blob_content;
          l_mime            := c1.mime_type;
          l_size            := dbms_lob.getlength(l_blob);
          v_file_name       := p_applic_id || '_' || replace(replace(l_filename,chr(10),null),chr(13),null) ;
          
          Zip.add1file( l_blob , v_file_name , v_file_part_blob );
          
         
          
      end loop;
      Zip.finish_zip( l_blob );
      l_size := DBMS_LOB.getlength(l_blob);
      l_mime := 'application/zip';
      l_filename := null;
      v_file_name := v_student_name ||'__' || p_applic_id || '.zip' ;
    end if;
    
    -- Part four: Calculate values
    v_current_session := to_char(APEX_CUSTOM_AUTH.GET_SESSION_ID_FROM_COOKIE) ;
    v_CLIENT_IP := OWA_UTIL.get_cgi_env ('REMOTE_ADDR'); 
    v_DATE := to_char(sysdate , 'YYYYMMDD') ;
    v_NEW_HASH_STR := to_char(P_DOC_ID) ||'-' || v_CLIENT_IP || '-'|| to_char(p_applic_id) ||'-' || v_DATE || p_type || C_HASH_ADD_PHRASE || p_session || l_filename ;
    v_NEW_HASH := sha256.encrypt(v_NEW_HASH_STR) ;
    select count(*) into v_session_exist from APEX_WORKSPACE_SESSIONS where APEX_SESSION_ID = to_number(p_session) ;
    
    if (v_NEW_HASH <> p_hash and V_DEBUG < 4 ) then
          owa_util.mime_header('text/html');
          Raise_Application_Error (-20089, 'Data and security HASH token are not match. <br>Refresh your page and try again.<br>');
    elsif (v_session_exist = 0 and V_DEBUG < 4 ) then
          owa_util.mime_header('text/html');
         --htp.print('<html><body><h1>Error: Data and HASH are not match</h1>Refresh your page and try again.<br></body></html>');
         Raise_Application_Error (-20090, 'Session is not valid.<br>Logout and Login again then try download again.<br>');
    end if ;
    
       
    -- Part Debug: Debug print 
    if V_DEBUG >= 4 then  -- Shows when is in debug mode
      owa_util.mime_header('text/html');
      htp.print('<html>');
      htp.print('<head>');
      htp.print('<meta http-equiv="Content-Type" content="text/html">');
      htp.print('<title>Download debug</title>');
      htp.print('</head>');
      
      htp.print('<body TEXT="#000000" BGCOLOR="#FFFFFF">');
      htp.print('<h1>Input parameter</h1>');
      htp.print('p_doc_id = ' ||p_doc_id || '<br>');
      htp.print('p_applic_id = ' ||p_applic_id || '<br>');
      htp.print('p_type = ' ||p_type || '<br>');
      htp.print('p_session = ' ||p_session || '<br>');
      htp.print('p_hash = ' ||p_hash || '<br>');
      htp.print('<h1>Calculated Variables</h1>');
      htp.print('l_APPLIC_NUM = ' ||l_APPLIC_NUM || '<br>');
      htp.print('l_filename = ' ||l_filename || '<br>');
      htp.print('l_mime = ' ||l_mime || '<br>');
      htp.print('l_size = ' ||l_size || '<br>');
      htp.print('v_CLIENT_IP = ' ||v_CLIENT_IP || '<br>');
      htp.print('v_DATE = ' ||v_DATE || '<br>');
      htp.print('v_NEW_HASH_STR = ' ||v_NEW_HASH_STR || '<br>');
      htp.print('v_NEW_HASH = ' ||v_NEW_HASH || '<br>');
      htp.print('v_current_session = ' ||v_current_session || '<br>');
      htp.print('v_session_exist = ' ||v_session_exist || '<br>');
      if (v_NEW_HASH = p_hash ) then
         htp.print('<h2 style="color:blue"> HASHs are match *OK*<h2>');
       else
         htp.print('<h2 style="color:orange"> HASHs NOT match </h2>');
      end if ;
      htp.print('</body>');
      
    else  --Download when debug mode < 4 
    
      
      
      
      
      -- Part Seven: Download file
       owa_util.mime_header( nvl(l_mime,'application/octet'), FALSE );
       htp.p('Content-length: ' || l_size);
       htp.p('Content-Disposition:  attachment; filename="'|| v_file_name || '"');
       owa_util.http_header_close;
       wpg_docload.download_file( l_blob );
       dbms_lob.freetemporary(l_blob);
       dbms_lob.freetemporary(v_file_part_blob);
      
    end if;
    
 EXCEPTION
   -- WHEN OTHERS THEN null;
     WHEN OTHERS THEN  
       if (SQLCODE =  -20088 ) then 
          raise;
       else
          htp.print('<html><body>Error ' || SQLERRM ||'</body></html>');
       end if;
 END download;