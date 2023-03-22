PRAGMA foreign_keys=OFF;
begin transaction;

create table commands_new (id integer primary key autoincrement, argv text, unique(argv) on conflict ignore) strict;
create table places_new   (id integer primary key autoincrement, host text, dir text, unique(host, dir) on conflict ignore) strict;
create table history_new  (id integer primary key autoincrement,
                       session int,
                       command_id int references commands (id),
                       place_id int references places (id),
                       exit_status int,
                       start_time real,
                       duration real,
                       unique(session, command_id, place_id, start_time) on conflict ignore
                       ) strict;

insert into commands_new (id, argv) select rowid, argv from commands;
insert into places_new (id, host, dir) select rowid, host, dir from places;
insert into history_new (session, command_id, place_id, exit_status, start_time, duration)
select H.session, C.rowid, P.rowid, H.exit_status, H.start_time, H.duration
from history H
left join places P ON H.place_id = P.rowid
left join commands C ON H.command_id = C.rowid;
drop table history;
drop table places;
drop table commands;
alter table commands_new rename to commands;
alter table places_new rename to places;
alter table history_new rename to history;

PRAGMA foreign_key_check ;
PRAGMA user_version=3;
commit;
VACUUM;
PRAGMA foreign_keys=ON;
