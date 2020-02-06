# ** DISTINCT: 중복된 행 제거 **
# syntax
# SELECT DISTINCT [select_list] FROM [table_name];
select distinct lastName
from employees
order by lastName;

# 데이터에 null이 포함된 상태에서 DISTINCT를 사용할 경우
# 첫 번째 null 한 개를 출력하고 나머지 null은 출력하지 않는다.
select distinct state
from customers;

# multi column with distinct
# 여러 컬럼을 묶어서 유일한지 결정한다.
select distinct state, city
from customers
where state is not null
order by state, city;

# DISTINCT vs GROUP BY = 동일한 기능(중복 제거)
select state
from customers
group by state;
select distinct state
from customers;
# MySQL 8.0+ 부터 GROUP BY의 sort 기능이 사라짐
# MySQL 8.0 이전 버전은 GROUP BY의 결과는 정렬되어 출력된다.

# DISTINCT with aggregate functions(SUM, AVG, and COUNT)
# 중복되지 않은 도시 출력
select distinct state
from customers
where country = 'usa';
# 중복되지 않은 도시의 숫자 출력
select count(distinct state)
from customers
where country = 'usa';

# DISTINCT with LIMIT
# null이 아닌 다섯개의 state를 출력
select distinct state
from customers
where state is not null
limit 5;


# ** AND **
# https://www.mysqltutorial.org/mysql-and/
# AND 연산자에서 FALSE가 NULL보다 우선순위가 높다.
# FALSE AND NULL => FALSE
# SELECT, UPDATE, DELETE 구문의 WHERE 절에서 사용될 수 있다.
# INNER JOIN and LEFT JOIN 에서도 사용될 수 있다.

select customerName, country, state
from customers
where country = 'usa'
  and state = 'ca';


# ** OR **
# https://www.mysqltutorial.org/mysql-or/
# OR 연산자에서 NULL이 FALSE보다 우선순위가 높다.
# FALSE OR NULL => NULL
select customerName, country
from customers
where country = 'usa'
   or country = 'france';

# ** IN **
# 컬럼의 값 중 리스트에 일치하는 값을 가진 행을 출력하거나 subquery를 반환할 수 있다.
# subquery: https://www.mysqltutorial.org/mysql-subquery/
# syntax
# SELECT [column1, column2] FROM [table_name] WHERE ([expr]|[colum_1]) IN ([value1, value2])
select officeCode, city, phone, country
from offices
where country in ('usa', 'france');
# 동일한 기능을 OR 연산자로 구현할 수 있다.
select officeCode, city, phone, country
from offices
where country = 'usa'
   or country = 'france';
# NOT 연산자를 이용해 'usa'와 'france'를 제외한 행 출력
select officeCode, city, phone, country
from offices
where country not in ('usa', 'france');


# 리스트를 이용해 값을 제공하지 않고 subquery를 이용해 IN 연산자를 사용
# table: a parent(orders)<-children(orderdetails)
select orderNumber, customerNumber, status, shippedDate
from orders
where orderNumber in
      (
          select orderNumber
          from orderdetails
          group by orderNumber
                   # HAVING: where와 유사(group by 없을 경우 where 동일)
                   # https://www.mysqltutorial.org/mysql-having.aspx
          having sum(quantityOrdered * priceEach) > 60000
      );
# 위 코드를 두 개로 분리하면 아래와 같다.

# first evaluation(subquery)
select orderNumber
from orderdetails
group by orderNumber
having sum(quantityOrdered * priceEach) > 60000;
# result => 10165, 10287, 10310

# second evaluation
select orderNumber, customerNumber, status, shippedDate
from orders
where orderNumber in (10165, 10287, 10310);


# ** BETWEEN **
# syntax
# [expr] [NOT] BETWEEN [begin_expr] AND [end_expr];
# 세 개의 표현식(expr, begin_expr, end_expr)은 동일한 데이터 타입
# 기본적으로 비교는 <=, >= 연산자가 사용된다.

# 구매 가격(buyPrice)이 90~100 사이에 포함되는 행 출력
select productCode, productName, buyPrice
from products
where buyPrice between 90 and 100;
# 위 where절은 아래와 동일
# where buyPrice between buyPrice>=90 and buyPrice<=100;

# 구매 가격이 20보다 작고 100보다 큰 행 출력
# == not 20~100
select productCode, productName, buyPrice
from products
where buyPrice not between 20 and 100;
# 위 where 절은 아래와 동일
# where buyPrice < 20 or buyPrice > 100;

# BETWEEN with dates
# 날짜는 cast를 이용해 명시적으로 표현하는 것이 좋다.
select orderNumber, requiredDate, status
from orders
where requiredDate
          between # 2003-01-01 ~ 2003-01-31
          cast('2003-01-01' as date) and
          cast('2003-01-31' as date);


# ** LIKE **
# SELECT, DELETE, UPDATE의 WHERE 절에서 데이터 필터링을 위해 사용된다.
# syntax: [expression] LIKE [pattern] ESCAPE [escape_character]

# lastName에 'on'을 포함하는 모든 행 출력
select employeeNumber, lastName, firstName
from employees
where lastName like '%on%';

# 'b'로 시작하는 lastName을 제외한 모든 행 출력
select employeeNumber, lastName, firstName
from employees
where lastName not like 'b%';

# LIKE with ESCAPE
# 만일 wildcard 문자를 포함한 데이터를 필터링해야할 경우 ESCAPE 절을 이용
# '\' 또는 [pattern] ESCAPE 'special character'
select productCode, productName
from products
where productCode like '%\_20%';
# 또는 where productCode like '%$_20%' escape '$';


# ** LIMIT **
# FROM -> WHERE -> SELECT -> ORDER BY -> LIMIT
# 반환할 행 수를 제어할 때 사용
# syntax: select [select_list] FROM [table_name] LIMIT [offset,] row_count;
select customerNumber, customerName, creditLimit
from customers
order by creditLimit desc
limit 5;

# LIMIT for pagination
# 총 122행을 각 페이지별로 10개씩, 마지막 페이지는 2개로 출력하고자 할 경우
select count(*)
from customers;
# 122
# 첫 번째 페이지(1~10행)
select customerNumber, customerName
from customers
order by customerName
limit 10;
# 두 번째 페이지(11~20행)
select customerNumber, customerName
from customers
order by customerName
limit 10, 10;


use classicmodels;

# ** IS NULL **
# syntax : [value] IS [NOT] NULL
# https://www.mysqltutorial.org/mysql-is-null/
# 1. 만일 특정 테이블 필드의 제약사항에 NOT NULL일 경우
CREATE TABLE IF NOT EXISTS projects
(
    id            INT AUTO_INCREMENT,
    title         VARCHAR(255),
    begin_date    DATE NOT NULL,
    complete_date DATE NOT NULL,
    PRIMARY KEY (id)
);

# NO_ZERO_DATE: https://dev.mysql.com/doc/refman/8.0/en/sql-mode.html#sqlmode_no_zero_date
# MySQL에서 0000-00-00을 null로 볼 것인지, (더미)데이터로 볼 것인지 여부
INSERT INTO projects(title, begin_date, complete_date)
VALUES ('New CRM', '2020-01-01', '0000-00-00'),
       ('ERP Future', '2020-01-01', '0000-00-00'),
       ('VR', '2020-01-01', '2030-01-01');


SELECT *
FROM projects
WHERE complete_date IS NULL;
# 'New CRM', 'ERP Future' 컬럼이 출력된다.
# date의 경우 '0000-00-00'을 NULL로 평가한다.

# 2. @@sql_auto_is_null이 1일 경우 INSERT에 의해 성성되는 행은 NULL이 된다.
SET @@sql_auto_is_null = 1;
INSERT INTO projects(title,begin_date, complete_date)
VALUES('MRP III','2010-01-01','2020-12-31');

select * from projects where id is null;
# 'MRP III'가 NULL로 평가된다.

# IS NULL을 이용해 필터링할 경우 기본적으로 index를 사용한다.
# type = ref
explain select customerNumber, salesRepEmployeeNumber
from customers
where salesRepEmployeeNumber is NULL;

# type = ref_or_null
explain select customerNumber, salesRepEmployeeNumber
from customers
where salesRepEmployeeNumber = 1370 or
      salesRepEmployeeNumber is NULL;
