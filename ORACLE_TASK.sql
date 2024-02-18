-- system Connection 

create user manager identified by 123;
grant create session to manager; 
grant create user to manager;


-- Manager Connection 

create user user_1 identified by 123;
create user user_2 identified by 123;

-- Hello

-- Sys Connection 

grant create session to user_1;
grant create table to user_1;
alter user user_1 quota 20m on system;

-- User_1 Connection 

create table dept(
  dept_id INTEGER PRIMARY KEY,
  dept_name varchar(50)  
);

create table emp(
  emp_id integer primary key,
  emp_name varchar(50),
  salary number,
  dept_id integer,
  CONSTRAINT forign_id FOREIGN KEY (dept_id) REFERENCES  dept(dept_id)
);


insert into dept values (1, 'HR');
insert into dept values (2, 'IT');
insert into dept values (3, 'Finance');

commit;


-- Sys Connection

grant create session to user_2; 
grant insert on user_1.emp to user_2;

-- User_2 Connection

insert into user_1.emp values (1,'Hazem',300,1);
insert into user_1.emp values (2,'Hossam',200,2);
insert into user_1.emp values (3,'Hamid',100,2);
insert into user_1.emp values (4,'Hafez',500,2);
insert into user_1.emp values (5,'Zeyad',400,1);
commit;


-- Sys Connection 

CREATE OR REPLACE FUNCTION RaiseSalary
RETURN NUMBER AS
    count_updated NUMBER := 0;
BEGIN
    FOR counter IN (SELECT salary FROM user_1.emp WHERE dept_id = 1)
    LOOP
        UPDATE user_1.emp SET salary = counter.salary * 1.1 WHERE dept_id = 1;
        count_updated := count_updated + 1;
    END LOOP;
    RETURN count_updated;
END;

grant execute on RaiseSalary to user_1;
grant execute on RaiseSalary to user_2;


-- User_1 Connection

DECLARE
    updated_count NUMBER;
BEGIN
    updated_count := sys.RaiseSalary();
END;

-- rollback;
-- or
-- commit after the Block Waiting Situation Happens;


--User_2 Connection 

DECLARE
    updated_count NUMBER;
BEGIN
    updated_count := sys.RaiseSalary();
END;

-- rollback;
-- or
-- commit after the Block Waiting Situation Happens;


-- Make 2 different Connections for user_1 Deadlock 

--deadlock user1

update emp set SALARY = 60 where EMP_ID = 1; -- Run First

update dept set DEPT_NAME = 'AI' where DEPT_ID = 1; -- Run Third (Block Waiting Happens)

-- rollback;

-- commit;

update dept set DEPT_NAME = 'CS' where DEPT_ID = 1; -- Run Second


update emp set SALARY = 6000 where EMP_ID = 1; -- Run Fourth (DeadLock)


-- rollback;


-- to get session id and serial for the situation 


SELECT w.sid "Waiting Session",
       w.serial# "Waiting Serial Id",
       w.blocking_session "Blocker session id",
       w.seconds_in_wait "Waiting Session Period",
       v.sql_fulltext "Waiting Sql Statement",
       blocking.serial# "Blocking Serial"
FROM v$session w
JOIN v$sql v ON w.sql_id = v.sql_id
LEFT JOIN v$session waiting ON w.sid = waiting.sid
LEFT JOIN v$session blocking ON w.blocking_session = blocking.sid
WHERE w.blocking_session IS NOT NULL;



-- 


CREATE OR REPLACE FUNCTION avg_salary(desired_dept_id INTEGER)
RETURN NUMBER
IS
  avg_sal NUMBER;
BEGIN
  SELECT AVG(user_1.emp.salary) INTO avg_sal
  FROM user_1.emp
  WHERE dept_id = desired_dept_id;
  
  RETURN avg_sal;
END;


-- set serveroutput on
DECLARE
  avg_salary_for_dept NUMBER;
BEGIN
  avg_salary_for_dept := avg_salary(2);
  DBMS_OUTPUT.PUT_LINE('Average Salary for Department ' || avg_salary_for_dept);
END;



CREATE OR REPLACE FUNCTION total_salary(desired_dept_id INTEGER)
RETURN NUMBER
IS
  total_sal NUMBER;
BEGIN
  SELECT SUM(user_1.emp.salary) INTO total_sal
  FROM user_1.emp
  WHERE dept_id = desired_dept_id;
  
  RETURN total_sal;
END;


DECLARE
  total_salary_for_dept NUMBER;
BEGIN
  total_salary_for_dept := TOTAL_SALARY(2);
  DBMS_OUTPUT.PUT_LINE('Total Salary for Department ' || total_salary_for_dept);
END;




CREATE OR REPLACE FUNCTION getMax
RETURN NUMBER
IS
  max_sal NUMBER;
BEGIN
  SELECT MAX(user_1.emp.salary) INTO max_sal
  FROM user_1.emp;
  
  RETURN max_sal;
END;


DECLARE
  MAX_NUMBER NUMBER;
BEGIN
  MAX_NUMBER := getMAX();
  DBMS_OUTPUT.PUT_LINE('Maximum Salary Across All Departments: ' || MAX_NUMBER);
END;


