use classicmodels;

# ** Alias for columns **
# syntax: SELECT [column_1 | expression] AS descriptive_name
# FROM table_name;
# AS 뒤에 올 별칭에 띄어쓰기가 있을경우 'descriptive name'으로 사용할 수 있다.
# ORDER BY, GROUP, HAVING 구문에서 컬럼을 참조하기 위해 별칭을 사용할 수 있다.
select concat_ws(', ', lastName, firstName) as 'Full name'
from employees;
# CONCAT: 문자(string)를 결합할 때 사용할 수 있다.
# CONCAT_WS: 구분자를 이용해 문자를 결합한다.

# sql_mode default 설정
set sql_mode = '';

# ONLY_FULL_GROUP_BY error: list, HAVING condition, ORDER BY가 non-aggregated column을 참조 -> 그렇지 않을 경우 error
SELECT orderNumber 'Order no.', SUM(priceEach * quantityOrdered) total
FROM orderdetails
# GROUP BY 'Order no.'
HAVING total > 60000;

# ONLY_FULL_GROUP_BY 설정
set sql_mode = 'ONLY_FULL_GROUP_BY';

# 현재 설정된 sql_mode 리스트 출력
select @@sql_mode;

select orderNumber, sum(priceEach * quantityOrdered) total
from orderdetails;

# ** Alias for tables **
# JOIN(INNER, LEFT, RIGHT) 구문이나 서브쿼리에서 종종 사용 됨
# syntax: table_name AS table_alias
select *
from employees e;
# 별칭을 이용해 컬럼을 불러올 수 있다.
select e.firstname, e.lastname
from employees e
order by e.firstName;

# customers와 orders 테이블 모두 customerName을 가지고 있다.
# 따라서 아래와 같이 실행할 경우 [1052] customerNumber가 중복된다는 에러를 발생시킨다.
select customerName, count(orderNumber) total
from customers
         inner join orders on customerNumber
group by customerName
order by total desc;

# 테이블에 대한 별칭을 이용해 위 문제를 해결
# 고객(customers.customerName)이 주문한 주문 수(orders.orderNumber)
select c.customerName, count(o.orderNumber) as total
from customers as c
         # o.customerNumber = c.customerNumber 둘의 순서가 바뀌어도 동일한 결과
         inner join orders as o using (customerNumber) #on c.customerNumber = o.customerNumber
group by c.customerName # 중복 제거
order by total desc;


select *
from orders;

select *
from customers;

# ** JOIN **
# 테이블 간 공통 컬럼(foreign key)을 이용해 한 번의 쿼리로 두 테이블의 데이터를 가져온다.
create table members
(
    member_id int auto_increment,
    name      varchar(100),
    primary key (member_id)
);

create table committees
(
    committee_id int auto_increment,
    name         varchar(100),
    primary key (committee_id)
);

insert into members(name)
    value ('jone'),('jane'),('mary'),('david'),('amelia');

insert into committees(name)
    value ('jone'),('mary'),('amelia'),('joe');

select *
from members;
select *
from committees;

# ** inner join **
# syntax
# SELECT column_list
# FROM table_1
# INNER JOIN table_2 ON join_condition;
# 두 테이블에 동일한 이름의 컬럼이 있고 equal operator를 사용한다면 USING 구문을 사용할 수 있다.
# INNER JOIN table_2 USING (column_name);  # -> 49line 예제
select m.member_id, m.name as member, c.committee_id, c.name as committee
from members m
         inner join committees c using (name); # on c.name=m.name;

select productCode, productName, textDescription
from products t1
         inner join productlines t2
                    using (productLine);

# INNER JOIN with GROUP BY
select t1.orderNumber, t1.status, sum(t2.quantityOrdered * t2.priceEach) total
from orders t1
         inner join orderdetails t2
                    using (orderNumber)
group by orderNumber;

# INNER JOIN - Three Tables
select orderNumber, orderDate, orderLineNumber, productName, quantityOrdered, priceEach
from orders
         inner join orderdetails using (orderNumber)
         inner join products using (productcode)
order by orderNumber, orderLineNumber;

# INNER JOIN - Four Tables
select orderNumber, orderDate, customerName, orderLineNumber, productName, quantityOrdered, priceEach
from customers
         inner join orders using (customerNumber)
         inner join orderdetails using (orderNumber)
         inner join products using (productCode)
order by orderNumber, orderLineNumber;

# INNER JOIN with other operators
select orderNumber, productName, MSRP, priceEach
from products p
inner join orderdetails o on p.productCode=o.productCode and p.msrp>o.priceEach;



# ** LEFT JOIN **
# right 테이블의 조건이 맞지 않을경우, left table의 컬럼을 기준으로 행은 생성되지만
# right에 해당하는 컬럼은 null
select m.member_id, m.name as member, c.committee_id, c.name as committee
from members m
         left join committees c using (name);

# member 중 committee에 속하지 않은 멤버 = only members
select m.member_id, m.name as member, c.committee_id, c.name as committee
from members m
         left join committees c using (name)
where c.committee_id is null;

# ** RIGHT JOIN **
select m.member_id, m.name as member, c.committee_id, c.name as committes
from members m
         right join committees c using (name);

# only committees
select m.member_id, m.name, c.committee_id, c.name
from members m
         right join committees c using (name)
where m.member_id is null;


# ** CROSS JOIN **
select m.member_id,
       m.name,
       c.committee_id,
       c.name
from members m
         cross join committees c;

