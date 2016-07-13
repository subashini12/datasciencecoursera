-- 1. display unique job codes

select distinct job_id from test_ma_employees;
pause;


-- 2.display lname,dept name and sal

select emp.l_name as lastname,dept.dept_name as DeptName,emp.salary as salary from test_ma_employees emp,test_ma_department dept where emp.dept_id= dept.dept_id and emp.salary >12000;
pause;

--3.display lname,salary not in range of 5000 and 20000

select l_name as lastname,salary from test_ma_employees where salary not between 5000 and 20000;
pause;

--4.display lname,job_id,startdate

select l_name as lastname,job_id,hire_date as start_date from test_ma_employees where hire_date between to_date('2-20-1998' ,'MM-DD-YYYY') and to_date('5-2-1998','MM-DD-YYYY') order by hire_date;

pause;

--5.display lname and hire date 

select l_name as lastname ,hire_date  from test_ma_employees where hire_date between to_date('6-1-1994','MM-DD-YYYY') and to_date('6-30-1994' ,'MM-DD-YYYY');
pause;

--6.display lname,salary,commission 

select l_name as lastname,salary,comm_pct as commission from test_ma_employees where comm_pct >0.04 order by salary,comm_pct;
pause;

-- 7. display  lname where 3rd letter is a 

select l_name  as lastname  from test_ma_employees where instr(l_name,'a',3,1)=3;
pause;
 ---or

select l_name  as lastname  from test_ma_employees where l_name like '__a%';
pause;

--8.lname contain a and e

select l_name as lastname from test_ma_employees where  instr(lower(l_name),'a') >1 and instr(lower(l_name),'e') >1;

pause;

--9.display lname , job ,salary

select emp.l_name as lastname,emp.job_id ,emp.salary  from test_ma_employees emp where  (emp.job_id= 'ST_CLERK' or emp.job_id = 'SA_REP') and (emp.salary <> 2500 or emp.salary<>3500 or emp.salary <>7000) ;
pause;

--10. lname,salary,commission=20%

select l_name as lastname ,salary,(comm_pct*100)||'%' as commission from test_ma_employees where comm_pct=0.2;
pause;

--11. 15% salary increase

select emp_id , l_name as lastname ,salary ,salary+round(salary*0.15) as new_Salary ,round(salary*0.15) as Increase from test_ma_employees ;
pause;

--12.lname with j,a,m 

select initcap(l_name) as lastname, length(l_name) as Str_length from test_ma_employees where lower(l_name) like 'j%' or lower(l_name) like 'a%' or lower(l_name) like 'm%';

pause;

--13. months between today and hire_date

select l_name as lastname , hire_date, months_between(sysdate,hire_date) as months_worked from test_ma_employees ;
pause;

--14.dream salary

select 'Employee '||l_name||' earns '||salary||' monthly,but wants '||(3*salary) as dream_salaries , hire_date from test_ma_employees order by round(months_between(sysdate,hire_date));
pause;

--15. lpad with $

select l_name as lastname, lpad(to_char(salary),6,'$') as salary from test_ma_employees ;
pause;

--16. salary review date

select l_name as lastname , hire_date, to_char(next_day(add_months(hire_date,6),'MON'),'DAY,DDTH,YYYY') as review_date from test_ma_employees ;
pause;


--17.DAY COLUMN
select l_name as lastname,hire_date ,to_char(hire_date,'DAY') as day_Started from test_ma_employees ;
pause;

--18. displaying no commission for employees


select l_name as lastname,decode(comm_pct,null,'No Commission',(comm_pct*100)||'%')as commission
      
  from test_ma_employees;
pause;

-- 19. salary with ***

select l_name as lastname,round((salary*12)/1000),lpad('*',round((salary*12)/1000),'*') as employees_and_their_salaries from test_ma_employees order by salary desc;   

pause;
--20. decode

select l_name as lastname, job_id ,decode(job_id,'AD_PRES','A',
                                                 'ST_MAN','B',
                                                   'IT_PROG','C', 
                                                    'SA_REP','D',
                                                     'ST_CLERK','E',
                                                       'O')job_code  from test_ma_employees;  
pause; 

--21. case
 select l_name as lastname,job_id,case job_id
                                     when 'AD_PRES'
                                      then 'A'  
                                      when 'ST_MAN'
                                      then 'B'
                                      when 'IT_PROG'
                                      then 'C'
                                      when 'SA_REP'
                                      then 'D'
                                      when 'ST_CLERK'
                                      then 'E'
                                      else 'O'
                                    end as job_code  from test_ma_employees; 
pause;

--22. unique jobs in dept with location  80

select distinct emp.job_id,country.country_name from  test_ma_employees emp,test_ma_department dept,test_ma_locations loc,test_ma_countries country   where emp.dept_id= 80 and emp.dept_id = dept.dept_id and dept.loc_id= loc.loc_id and loc.country_id=country.country_id;

pause;
 --23.city of emp who earn commission

select emp.l_name as lastname , dept.dept_name as DeptName,dept.loc_id as Location_ID,loc.city as city from  test_ma_employees emp,test_ma_department dept,test_ma_locations loc where emp.comm_pct>0 and  emp.dept_id = dept.dept_id and dept.loc_id= loc.loc_id ;   
pause;

--24.lname and dept who earn commissiom

select emp.l_name as lastname ,dept.dept_name ,emp.comm_pct from test_ma_employees emp, test_ma_department dept where emp.comm_pct>0 and emp.dept_id= dept.dept_id;
pause;

--25.work in toronto

select emp.l_name as lastname ,emp.job_id,emp.dept_id , dept.dept_name from test_ma_department dept,test_ma_employees emp   where dept.loc_id in (select loc_id  from test_ma_locations where city='Toronto')and emp.dept_id= dept.dept_id ;
pause;

--26 mgr and mgr num

select emp.l_name as employee,emp.emp_id as emp_num,mgr.l_name as Manager ,mgr.emp_id as Mgr_id from test_ma_employees emp, test_ma_employees mgr where  emp.mgr_id= mgr.emp_id(+) order by emp.emp_id;
pause;

--27 who work in same dept

select emp.l_name as lastname,emp.dept_id from test_ma_employees emp, test_ma_employees emp1  where  emp1.emp_id= 170 and emp.dept_id=emp1.dept_id ;

pause;

--28.diplaying grade

select emp.l_name as employee, job.job_title,dept.dept_name,emp.salary,decode(emp.job_id,'AD_PRES','A',
  'ST_MAN','B',
      'IT_PROG','C', 
     'SA_REP','D',
    'ST_CLERK','E',
       'O')grade from test_ma_department dept, test_ma_employees emp, test_ma_jobs job where emp.dept_id= dept.dept_id and emp.job_id = job.job_id;
pause;

--29 display employee after davies

select l_name as employee , hire_date from  test_ma_employees where hire_date > (select hire_date from test_ma_employees where lower(l_name)='davies')  ;
pause;

--30.mgr and hire dates
 
 select emp.l_name as lastname,emp.hire_date as emp_hire_date,mgr.l_name as Mgr_Last_Name,  mgr.hire_date as Mgr_hire_date from test_ma_employees emp, test_ma_employees mgr 
 
 where emp.mgr_id = mgr.emp_id and emp.hire_date < mgr.hire_date;
pause;

--31 .max  salary
 
 select max(salary) as max_salary, min(salary) as min_salary,sum(salary) as total_Salary, round(avg(salary)) as Avg_salary from test_ma_employees ;

pause;

--32.salary for each job_type
 
 select job_id, min(salary),max(salary),max(salary),sum(salary),avg(salary) from test_ma_employees group by job_id;

pause;

-- 33.display people with same job
 
 select job_id, count(job_id) from test_ma_employees group by job_id;

pause;

---34 . salary difference
 
 select min(salary) as min_salary,max(salary) as max_salary , max(salary)-min(salary) as difference from test_ma_employees;

pause;


--35. salary >6000
 
 select mgr_id,min(salary) from test_ma_employees group by mgr_id having min(salary) >6000 order by min(salary) desc;

pause;

 --36.dept name and location
 
 select dept.dept_name, loc.city ,(select count(emp_id) from test_ma_employees where dept_id = dept.dept_id) as emp_count, (select avg(salary) from test_ma_employees where dept_id= dept.dept_id) as avg_salary from  test_ma_department dept, test_ma_locations loc where dept.loc_id= loc.loc_id;

pause;
--37.employee hired in 1995 - 1998
 
 select (select count(emp_id) from test_ma_employees) as total_emp,(select count(emp_id) from test_ma_employees where to_char(hire_date,'YYYY')='1995') as total_emp_1995,
 (select count(emp_id) from test_ma_employees where to_char(hire_date,'YYYY')='1996') as total_emp_1996,
 (select count(emp_id) from test_ma_employees where to_char(hire_date,'YYYY')='1997') as total_emp_1997,
 (select count(emp_id) from test_ma_employees where to_char(hire_date,'YYYY')='1998') as total_emp_1998 from dual;

pause;

--38.dept 20,50,80,90
 
 select distinct job_id ,
 
 sum(case dept_id
      when 20 
       then salary
       end)as  dept_20,
       sum(case dept_id
      when 50 
       then salary
       end)as  dept_50,
       sum(case dept_id
      when 80
       then salary
       end)as  dept_80,
       sum(case dept_id
      when 90 
       then salary
       end)as  dept_90,
         sum(salary) from test_ma_employees  group by job_id;
pause;

--39.earn more tahn avg(salary)

select emp_id,salary,l_name as lastname from test_ma_employees where salary > (select avg(salary) from test_ma_employees);
pause;

--40 contains u 

select emp_id, l_name as lastname, dept_id from test_ma_employees where dept_id in (select distinct dept_id from test_ma_employees where lower(l_name) like '%u%'); //check again 
pause;

-- 41 .loc = 1700
select emp.l_name as lastname,emp.dept_id ,emp.job_id from test_ma_employees emp, test_ma_department dept, test_ma_locations loc where emp.dept_id = dept.dept_id and dept.loc_id = loc.loc_id and dept.loc_id = 1700;

pause;

--42.who reports 2 king

select l_name as lastname , salary  from  test_ma_employees  where mgr_id in (select emp_id from test_ma_employees where lower(l_name)='king'); 
pause;

--43.l_name in executive dept 

select l_name as lastname,dept_id ,job_id from test_ma_employees where dept_id = (select dept_id from test_ma_department where dept_name='Executive');
pause;

--44.work with employee contains u 

select l_name,emp_id ,salary from  test_ma_employees where salary >(select avg(salary) from test_ma_employees ) and dept_id in (select dept_id from test_ma_employees where lower(l_name) like '%u%');
pause;

--47 copy table  employee

create table employee_backup as (select emp_id as ID,f_name as FIRST_NAME,l_name as LAST_NAME, salary ,dept_id from test_ma_employees where 1 = 2) ;
pause;

--48. add comment to dept and emp table 

comment on table test_ma_department is 'Department Table';

comment on table test_ma_employees is 'Employee Table';

pause;

--50 adding a constraint to  commission column 

alter table test_ma_employees  add constraint commission_not_zero  check (comm_pct != 0);
pause;

-- 46 pl/sql 


declare 
  -- Local variables here
  la_name test_ma_employees.l_name%type;
  job_id test_ma_employees.job_id%type;
  city1 test_ma_locations.city%type;
  de_name test_ma_department.dept_name%type;
  
  cursor emp_cursor  is 
   select emp.l_name,emp.job_id,dept.dept_name  from test_ma_employees emp,test_ma_department dept 
  where emp.dept_id= dept.dept_id and 
  dept.loc_id=(Select loc_id from test_ma_locations where lower(city)=lower(city1));
  
  
  begin
  -- Test statements here
  city1 := '&city1';
  
  open emp_cursor;
  
  loop 
  
   fetch  emp_cursor into la_name,job_id,de_name ;
  
          exit  when emp_cursor%notfound;
          dbms_output.put_line(la_name||' with job_id '||job_id||' works for '||de_name);
  end loop;
  
  exception  when no_data_found then 
  
      dbms_output.put_line('There is no employee working for the given location');
end;

pause;

--45 using  define 

   DEFINE LOW_DATE=01/01/1999
      DEFINE HIGH_DATE=01/01/1999
pause;

select l_name ,job_id, hire_date from test_ma_employees where hire_date between to_date('&LOW_DATE','mm/dd/yyyy') and to_date('&HIGH_DATE','mm/dd/yyyy');

pause;