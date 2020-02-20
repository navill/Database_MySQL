create database test_index;
use test_index;
create table tbl1
(
    a int primary key,
    b int unique,
    c int unique
);

create table tbl2
(
    a int primary key,
    b int unique,
    c int unique
);

create table tbl3
(
    a int primary key,
    b int unique not null,
    c int unique not null
);
alter table tbl3
    drop primary key;
alter table tbl3
    add constraint pk_name primary key (a);
show create table tbl3;

show index from tbl1;
show index from tbl2;
show index from tbl3;


# mixed index
create database if not exists testDB;
use testdb;
create table mixedTbl
(
    userID char(8)     not null,
    name   varchar(10) not null,
    addr   char(2)
);

insert into mixedTbl value ('LSG', '이승기', '서울');
insert into mixedTbl value ('KBS', '김범수', '경남');
insert into mixedTbl value ('KKH', '김경호', '전남');
insert into mixedTbl value ('JYP', '조용필', '경기');
insert into mixedTbl value ('SSK', '성시경', '서울');
insert into mixedTbl value ('LJB', '임재범', '서울');
insert into mixedTbl value ('YJS', '윤종신', '경남');
insert into mixedTbl value ('EJW', '은지원', '경북');
insert into mixedTbl value ('JKW', '조관우', '경기');
insert into mixedTbl value ('BBK', '바비킴', '서울');

select *
from mixedTbl
where name = '이승기';

select *
from mixedTbl;

show create table mixedTbl;

# userID를 PK로 지정 -> 클러스터 인덱스 생성(루트 페이지 + 리프 페이지(데이터 페이지))
alter table mixedTbl
    add constraint PK_mixedTbl_userID
        primary key (userID);

# name을 UNIQUE로 지정 -> 보조 인덱스 생성
alter table mixedTbl
    add constraint UK_mixedTbl_name
        unique (name);

# create index를 이용해 보조 인덱스 생성
create index idx_mixedTbl on mixedTbl (addr);


# index 정보
show index from mixedTbl;
# index의 크기를 포함한 상세 정보
show table status like 'mixedTbl';

analyze table mixedTbl;

show table status like 'mixedTbl';

# 여러 열을 이용한 인덱스
create index idx_mixedTbl_name_addr
    on mixedTbl (name, addr);

select *
from mixedTbl
where name = '이승기'
  and addr = '서울';

# 반드시 보조 인덱스 삭제 후 클러스터 인덱스 삭제
# 1.secondary index 삭제
drop index UK_mixedTbl_name on mixedTbl;
drop index idx_mixedTbl on mixedTbl;
drop index idx_mixedTbl_name_addr on mixedTbl;

# 2.clustered index 삭제(pk)
alter table mixedTbl
    drop primary key;

# 3. 만일 다른 테이블에서 클러스터 인덱스(pk)를 참조하고 있을 경우 에러 발생
# -> pk를 참조하는 테이블의 제약조건 이름 확인
select table_name, constraint_name
from information_schema.REFERENTIAL_CONSTRAINTS
where CONSTRAINT_SCHEMA = 'sqlDB';
# -> 참조하는 테이블의 외래키와 클러스터 인덱스의 외래키 제거
alter table referTbl
    drop foreign key refertbl_ibfk_1;
alter table mixedTbl
    drop foreign key;


show create table mixedTbl;

