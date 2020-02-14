create database test_index;
use test_index;
create table tbl1(
    a int primary key,
    b int unique,
    c int unique
);

create table tbl2(
    a int primary key,
    b int unique,
    c int unique
);

create table tbl3(
    a int primary key,
    b int unique not null,
    c int unique not null
);
alter table tbl3 drop primary key;
alter table tbl3 add constraint pk_name primary key(a);
show create table tbl3;

show index from tbl1;
show index from tbl2;
show index from tbl3;