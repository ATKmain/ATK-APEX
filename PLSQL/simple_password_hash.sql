create or replace function  simple_password_hash (p_username in varchar2, p_password in varchar2)
return varchar2
is
  l_password varchar2(4000);
  l_salt varchar2(4000) := 'ATK284JFD837DH2829DKSNW8342LSDLNC8KJNVS834LJBGSVLURHVW30485VNT5478VTNY3475NCYT357CTN3Y4785TNCWT57M3Y57ON837YCNTYIV75TVY4TY375TYC3754MT9OK3D5TU3V475T9C3N5Y935';
begin

-- This function should be wrapped, as the hash algorhythm is exposed here.
-- You can change the value of l_salt 
-- You should change DBMS_OBFUSCATOIN to other hash functions like SHA256. MD5 is cracked

l_password := utl_raw.cast_to_raw(dbms_obfuscation_toolkit.md5
  (input_string => p_password || substr(l_salt,10,13) || upper(p_username) ||
    substr(l_salt, 4,10)));
return l_password;
end;