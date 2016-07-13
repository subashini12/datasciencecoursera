//wanted to get records greater the min lines of code in bu_id =1
select co_name ,co_type,co_no_of_lines ,bu_id from sonar_ma_component where co_no_of_lines > ANY(select co_no_of_lines from sonar_ma_component where bu_id=1 );

//will get all the records with bu names

Select comp.co_name,comp.co_type,bu.bu_name from sonar_ma_component comp,sonar_ma_business_unit bu where comp.bu_id= bu.bu_id;

//outer join  will get all bu_names even the component is not present for the particular bu.

select bu.bu_name, comp.co_name,comp.co_type,comp.bu_id   from sonar_ma_business_unit bu left  outer join sonar_ma_component comp  on(bu.bu_id = comp.bu_id);   


//creating seq
create sequence BUNIT_SEQ
minvalue 1
maxvalue 99999
start with 21
increment by 1;

insert into sonar_ma_business_unit(bu_id,bu_name) values(bunit_seq.nextval,'Raccolta');

select bunit_seq.currval from dual;

//creating synonym

create  synonym  bu_synonym for sonar_ma_business_unit;

select * from bu_synonym;




//creating view to get the co_name and bu_id only knowing the business unit name 

create view comp_view as select co_name,bu_id  from sonar_ma_component where bu_id = (select bu_id from sonar_ma_business_unit where bu_name='Finanza');

select * from comp_view;

//with read only 
create view bu_view(co_name,co_type) as select co_name,co_type  from sonar_ma_component where bu_id=1 with read only;


select * from bu_view;

create index bu_index on sonar_ma_component(bu_id);
select * from sonar_ma_component order by bu_id;

----------------

sample PL/SQL
------------

begin
  -- Test 
  dbms_output.put_line('Hello ,PL/SQL');
  
end;

o/p:Hello ,PL/SQL

//for rowtype
declare 
   bu_unit sonar_ma_business_unit%rowtype;
begin
  -- Test

   select * into bu_unit from sonar_ma_business_unit where bu_id =2;
   dbms_output.put_line('Business Unit='||bu_unit.bu_id||'-'||bu_unit.bu_name);
end;

o/p: Business Unit=2-RIC


//for column type
declare 
   b_id  sonar_ma_business_unit.bu_id%type; 
   b_name sonar_ma_business_unit.bu_name%type; 
begin
  -- Test statements here
   b_id:= :business_id;
   select bu_id,bu_name  into b_id,b_name from sonar_ma_business_unit where bu_id =b_id;
   dbms_output.put_line('Business Unit='||b_id||'-'||b_name);
end;

o/p: Business Unit=1-Finanza



//cursor

declare 
  co_name sonar_ma_component.co_name%type;
  co_type sonar_ma_component.co_type%type;
  num_lines sonar_ma_component.co_no_of_lines%type;
  bu_id sonar_ma_component.bu_id%type;
  
  cursor comp_cursor  is  select co_name,co_type,co_no_of_lines from sonar_ma_component where bu_id=bu_id;
begin
 bu_id:= :b_id;
 open comp_cursor;
 loop 
   fetch comp_cursor into co_name,co_type,num_lines ;
   exit when comp_cursor%rowcount>3 or comp_cursor%notfound;
   dbms_output.put_line(co_name||'-'||co_type||'-'||num_lines);
   
  end loop;
  close comp_cursor;
  
end;

FinanzaCapitalGain-TEST-New-20000
FinanzaCommon-TEST-Maintenance-16000
FinanzaCondizioni-TEST-Maintenance-80000