/**
  @author
 */
select h.name, h.surname, h.patronymic, g.value as gender
from human as h join gender as g
                     on h.gender_id = g.id;

select c.method_address, c.start_date_work, h.email, h.phone_number
from client as c join human as h
                      on c.user_id = h.id;

select com.name, c.method_address
from company as com join client as c
                         on c.company_id = com.id;

select c.method_address, m.login
from managerclient as mc join client as c
                              on mc.client_id = c.id
                         join manager as m on mc.manager_id = m.id;

alter table human add column parent integer,
                  add constraint parent foreign key (parent) references human(id);
with recursive cte as (
    select 2 as i
    union all
    select i + 1 from cte where i < 204
)
update human as h
set
    parent = i
from cte
where cte.i = h.id;

with recursive cte as (select *, 1 as level
                       from human
                       union all
                       select h.*, hc.level + 1 as level
                       from human as h
                                join cte as hc on hc.id = h.parent
                       where hc.level < 2)
select * from cte;
