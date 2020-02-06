# SELECT
# FROM -> SELECT 순서로 실행된다.

show databases;
create database test_mysql;
use classicmodels;

show databases;

# db(classicmodel) 사용
use classicmodels;

# customers table 출력
select *
from customers;
# employees table 출력
select *
from employees;
# 모든 테이블 출력
show tables;

# 테이블에 적용된 index 출력
show index from customers;


# customers table schema 출력
show create table customers;

# 명령어를 이용해 schema의 character set 변경
set character_set_client = utf8mb4;
set character_set_server = utf8mb4;
set character_set_results = utf8mb4;
# set character_set_system = utf8mb4; (read only)
set character_set_connection = utf8mb4;
alter database classicmodels default character set utf8mb4;
commit;



show create table employees;

show variables like 'char%';

select lastName
from employees;

select lastName, firstName, jobtitle
from employees;

# ORDER BY
# FROM -> SELECT -> ORDER BY 순서로 실행(평가)된다.

# 오름차순
select contactLastname, contactFirstname
from customers
order by contactLastname;

# 내림차순
select contactLastname, contactFirstname
from customers
order by contactLastname desc;

# 오름차순(contactLastname) 후 내림차순(contactFirstname)
# -> (내림차순으로 정렬된)동일한 contactLastname의 contactFirstname이 오름차순으로 정렬된다.
select contactLastname,
       contactFirstname
from customers
order by contactLastname desc,
         contactFirstname asc;

# 연산을 거친 후 내림 차순
select ordernumber,
       orderlinenumber,
       quantityordered * priceeach as subtotal
from orderdetails
order by subtotal desc;

# ORDER BY with FIELD()
select *
from orders;
# field()에 입력된 순서로 컬럼값이 출력된다.
select orderNumber, status
from orders
order by field(status, 'In Process',
               'on Hold',
               'Cancelled',
               'Resolved',
               'Disputed',
               'Shipped') desc;
# field는 아래와 같이 index를 반환한다.
# In Process -> 1
# on hold -> 2
# cancelled -> 3
# ...

# WHERE: 검색 또는 업데이트 시 필요한 행의 조건
# FROM->WHERE->SELECT->ORDER BY

# syntax
# SELECT  #-> UPDATE or DELETE 사용 가능
#     [select_list]
# FROM
#     [table_name]
# WHERE  #-> 논리연산자를 사용할 수 있다.(and, or, not)
#     [search_condition];
select lastName,
       firstName,
       jobTitle,
       officeCode
from employees
# 컬럼 jobTitle과 officeCode에 대한 행 검색
where jobTitle = 'Sales Rep'
   or officeCode = 1
order by officeCode, jobTitle;

# BETWEEN: 범위에 해당할 경우 TRUE
# syntax : expression(column name) BETWEEN [low] AND [high]
select lastName,
       firstName,
       officeCode
from employees
where officeCode between 1 and 3 # 1~3을 표현할 때 and 사용
order by officeCode;

# LIKE: 해당 패턴 일치할 경우 TRUE
# %: 모든 문자
# _: 한 개의 문자
select firstName, lastName
from employees
where lastName like '%son'
order by firstName;

# IN: 리스트에 포함된 값을 가지고 있을 경우 TRUE
# syntax: value(column name) IN (value1, value2, ...)
select lastName, firstName, officeCode
from employees
where officeCode in (1, 2, 3)
order by officeCode;

# IS NULL: column 값이 null일 경우 TRUE(equal operator(=)와 다름)
# 데이터베이스에서 0 또는 빈 문자열과 null(데이터가 없거나 알 수 없음을 나타내기 위한 표시로 사)은 다르다.
select lastName,
       firstName,
       reportsTo
from employees
where reportsTo is null;

# comparison operators
# '=' => equal
# '<>' or '!' => not equal
# '<' or '>' => less than or greater than
# '<=' or '>=' => Less than or equal to or greater than or equal to
select lastName, firstName, jobTitle
from employees
# sales rep가 아닌 모든 행
where jobTitle <> 'sales rep';
# officecode가 5보다 클 경우
# where officecode > 5;
# officecode가 4보다 작거나 같을 경우
# where officecode <= 4;