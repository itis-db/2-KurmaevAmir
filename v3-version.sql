/**
  @author
 */
--v2
alter table human add column date_registration timestamp default current_timestamp;  -- + column timestamp.
alter table company add constraint unique_model unique (INN);  -- + unique.
alter table human alter column name type varchar(36);  -- varchar(255) -> varchar(36).
alter table client add column order_cost integer default 0;  -- + column integer
alter table client alter column order_cost type numeric(10, 2) using order_cost::numeric(10, 2);  -- integer -> numeric(10, 2)

--rollback
alter table human drop column date_registration;
alter table company drop constraint unique_model;
alter table human alter column name type varchar(255);
alter table client alter column order_cost type integer using order_cost::integer;
alter table client drop column order_cost;