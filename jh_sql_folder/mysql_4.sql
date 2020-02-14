# ** HAVING **
select orderNumber,
       sum(quantityOrdered)             as itemCount,
#        priceEach                        as 'unit price',
       sum(priceEach * quantityOrdered) as total
from orderdetails
group by orderNumber #, priceEach
having total > 1000
   and itemCount > 60;


# ** ROLLUP **
# syntax
# select select_list
# from table_name
# group by c1, c2, c3 with rollup;

# 기존의 테이블에서(orderDetails, orders, products) 데이터를 추출하고
# 새로운 테이블(sales) 생성
CREATE TABLE sales
SELECT productLine,
       YEAR(orderDate)                  orderYear,
       SUM(quantityOrdered * priceEach) orderValue
FROM orderDetails
         INNER JOIN
     orders USING (orderNumber)
         INNER JOIN
     products USING (productCode)
GROUP BY productLine,
         orderYear;

select *
from sales;

select productLine, sum(orderValue) as totalOrderValue
from sales
group by productLine;

select sum(orderValue) as totalOrderValue
from sales;

# 여러 그룹들을 한 번의 쿼리로 가져오고자 할 경우 UNION ALL 연산자를 이용할 수 있다.
select productLine, sum(orderValue) as totalOrderValue
from sales
group by productLine
union all
# 동일한 수의 열이 필요하기 때문에 null 추가
select null, sum(orderValue) as totalOrderValue
from sales;
# -> 쿼리가 길어짐 + 하나의 쿼리이지만, 실제로 실행은 두번의 쿼리를 실행하고, 이를 하나로 합치기 위한 연산 필요

select productLine, sum(orderValue) as totalOrderValue
from sales
group by productLine
with rollup;

SELECT productLine,
       orderYear,
       SUM(orderValue) totalOrderValue
FROM sales
GROUP BY productline,
         orderYear
WITH ROLLUP;

# ** GROUPING **
# GROUP BY 과정에서 발생하는 NULL을 체크할 때 사용
SELECT orderYear, productLine, SUM(orderValue) as totalOrderValue, GROUPING (orderYear), GROUPING (productLine)
FROM
    sales
GROUP BY
    orderYear,
    productline
WITH ROLLUP;

# GROUPING과 IF를 이용해 결과 출력
select if(grouping (orderYear), 'All year', orderYear)              as orderYear,
       if(grouping (productLine), 'All Product Lines', productLine) as productLine,
       sum(orderValue)                                              as totalOrderValue
from sales
group by orderYear, productLine
with rollup;


# ** SUB QUERY **
# 주문에 없는 고객 이름 출력
select customerName
from customers
where customerNumber not in
      (select distinct customerNumber
       from orders);

# sub query - 총 가격이 60000이 넘는 주문 번호
select orderNumber, sum(priceEach * quantityOrdered) as total
from orderdetails
         inner join orders using (orderNumber)
group by orderNumber
having total > 60000;

# sub query를 이용해 해당 주문의 주문자 정보 출력
select customerNumber, customerName
from customers
where exists(
              select orderNumber, sum(priceEach * quantityOrdered) as total
              from orderdetails
                       inner join orders using (orderNumber)
              where orders.customerNumber = customers.customerNumber
              group by orderNumber
              having total > 60000);