-- A method to convert a delimited string like checkbox items' value in APEX to a selectable table to use simply in SQL queries
Drop function string_to_selectable_table;
Drop TYPE t_str_row_tab ;
/
CREATE or REPLACE TYPE t_str_row_tab IS TABLE OF VARCHAR2(4000) ;
/
CREATE or REPLACE FUNCTION string_to_selectable_table ( p_string      IN VARCHAR2,   p_delimiter   IN VARCHAR2 DEFAULT ':')
      RETURN t_str_row_tab PIPELINED
   AS
      n_row NUMBER := 1 ;
      v_str VARCHAR2(4000) ;
   BEGIN      
      v_str := trim(regexp_substr(p_string, '[^'|| p_delimiter || ']+', 1, n_row) ) ;
      WHILE ( v_str is not null )
      LOOP
          PIPE ROW ( v_str );
          n_row := n_row + 1 ;
          v_str := trim(regexp_substr(p_string, '[^'|| p_delimiter || ']+', 1, n_row) ) ;
          
      END LOOP;

      RETURN;
END string_to_selectable_table;
/
-- Example Query
select COLUMN_VALUE  from table(string_to_selectable_table('Option1:Option2:Option3', ':') ) aa;
   