create database if not exists indexDB;

use indexDB;
use employees;
show databases;

# 30만개의 데이터
select count(*)
from employees.employees;

select *
from employees.employees
where emp_no = '100000';

# 무작위로 30만개의 데이터 테이블 생성
create table Emp
select *
from employees.employees
order by rand();

# 클러스터 인덱스
create table Emp_c
select *
from employees.employees
order by rand();

# 보조 인덱스
create table Emp_Se
select *
from employees.employees
order by rand();

show table status;
# 클러스터 인덱스 생성
ALTER TABLE Emp_C
    ADD PRIMARY KEY (emp_no);
# 보조 인덱스 생성
ALTER TABLE Emp_Se
    ADD INDEX idx_emp_no (emp_no);

show create table emp_se;
show create table employees.employees;
show create table employees.dept_emp;

show index from departments;
show index from employees.dept_emp;


# 보조 인덱스 삭제
drop index idx_emp_no on Emp_Se;
# 클러스터 인덱스 삭제
alter table Emp_C
    drop primary key;

select *
from emp;
select *
from emp_c
limit 5;
select *
from emp_se
limit 5;

show create table emp_se;

analyze table emp, emp_c, emp_se;

show index from emp;
show index from emp_c;
show index from emp_se;

show table status;

show global status like 'Innodb_pages_read';
select *
from Emp
where emp_no < 300000;
show global status like 'Innodb_pages_read';

show status;

alter table Emp_Se
    add constraint unique idx_emp_se (emp_no);

create table table_a
select *
from employees.employees
order by rand();
create table table_c
select *
from employees.employees
order by rand();
create table table_se
select *
from employees.employees
order by rand();

ALTER TABLE table_c
    ADD PRIMARY KEY (emp_no);
ALTER TABLE table_se
    ADD INDEX idx_emp_no (emp_no);
alter table table_se
    add constraint unique idx_emp_no (emp_no);

show table status;
show create table table_se;
analyze table table_a, table_c, table_se;

drop index idx_emp_no on table_se;
alter table table_se
    drop key idx_emp_se;

use employees;

show table status;
show create table salaries;
show create table employees;
show create table titles;
show index from salaries;
show index from employees;
show index from titles;


select * from employees.salaries order by rand() limit 15;
select count(*) from employees.salaries;

create database index_test;
use index_test;
# salaries: data 2,800,000개
# 테이블 생성하는데 약 25초 소요
create table sal
select *
from employees.salaries
order by rand();

show create table employees.salaries;

create table sal_c
select *
from employees.salaries
order by rand();

create table sal_se
select *
from employees.salaries
order by rand();

# sal_c의 index 등록 순서 변경(from_date, emp_no)
create table sal_c_rev
select *
from employees.salaries
order by rand();


show create table sal;
show table status;
select *
from sal
limit 5;

# primary key 부여
ALTER TABLE sal_c
    ADD PRIMARY KEY (emp_no);

analyze table sal, sal_c, sal_se, sal_c_rev;

show index from sal;
show index from sal_c;
show index from sal_se;
show index from sal_c_rev;

# emp_no & from_date를 pk로 지정
ALTER TABLE sal_c
    ADD PRIMARY KEY (emp_no, from_date);

# from_date & emp_no를 pk로 지정
alter table sal_c_rev
    add primary key (from_date, emp_no);

# emp_no & from_date를 (보조)index로 지정
alter table sal_se
    add index idx_emp_no (emp_no, from_date);

show table status;

desc sal;
select * from sal limit 5;
select * from sal_c limit 5;
select * from sal_se limit 5;
select * from sal_c_rev limit 5;

select * from sal where emp_no = 430609;
select * from sal_c where emp_no = 430609;
# 강제로 index를 사용하지 않도록 함
# select * from sal_c ignore index (PRIMARY) where emp_no = 430609;
# emp_no * 1 = 결과는 동일하게 출력되지만, where 구문에 (컬럼에 대한)연산이 들어갈 경우 full scan으로 동작
# -> emp_no = 430609/1은 index로 동작한다.
# select * from sal_c where emp_no*1 = 430609;
select * from sal_se where emp_no = 430609;

# SELECT SUM(DATA_FREE)
#     FROM  INFORMATION_SCHEMA.PARTITIONS
#     WHERE TABLE_SCHEMA = 'index_test'
#     AND   TABLE_NAME   = 'sal_se';


show global status like 'Innodb_pages_read';
# select * from sal where emp_no = 430609;
# select SQL_NO_CACHE * from sal_c where from_date = '2020-02-21';
select SQL_NO_CACHE * from sal_c where emp_no = 430610;
# select * from sal_se where emp_no = 430610;
show global status like 'Innodb_pages_read';

# INSERT value - Non-Index
insert into sal value ('430610', '99999', '2020-02-21', '2020-02-21');
# INSERT value - Clustered Index
insert into sal_c value ('430610', '99999', '2020-02-21', '2020-02-21');
# INSERT value - Secondary Index
insert into sal_se value ('430610', '99999', '2020-02-21', '2020-02-21');

# index 컬럼이 여러개 일 때 cardinality에 따른 emp_no, from_date vs from_date, emp_no의 속도 비교
select * from sal_c where emp_no = 430610 and from_date = '2020-02-21';
select * from sal_c where emp_no = 430611 and from_date = '2000-12-03';
select * from sal_c where emp_no = 430612 and from_date = '2001-10-06';
select * from sal_c where emp_no = 430613 and from_date = '2002-06-06';
select * from sal_c where emp_no = 430614 and from_date = '1999-09-08';

select * from sal_c_rev where emp_no = 430610 and from_date = '2020-02-21';
select * from sal_c_rev where emp_no = 430611 and from_date = '2000-12-03';
select * from sal_c_rev where emp_no = 430612 and from_date = '2001-10-06';
select * from sal_c_rev where emp_no = 430613 and from_date = '2002-06-06';
select * from sal_c_rev where emp_no = 430614 and from_date = '1999-09-08';