--USER should be your postgres user
--select truncate_tables(USER);

insert into address (address) values ('kburns');
insert into address (address) values ('tearle');
insert into address (address) values ('kstalzer');
insert into address (address) values ('kdumont');
insert into address (address) values ('larry');

insert into message (from_address, subject, body) values (1, 'Test Subject 1', 'Test Body 1')
insert into message_recipient (message_id, address_id) values (1,2)
insert into message_recipient (message_id, address_id) values (1,3)

insert into message (from_address, subject, body) values (3, 'Test Subject 2', 'Test Body 2')
insert into message_recipient (message_id, address_id) values (2,2)
insert into message_recipient (message_id, address_id) values (2,1)

insert into message (from_address, subject, body) values (2, 'Test Subject 3', '')
insert into message_recipient (message_id, address_id) values (3,5)

insert into message (from_address, subject, body) values (4, 'Test Subject 3', 'Test Body 4')
insert into message_recipient (message_id, address_id) values (4,1)
