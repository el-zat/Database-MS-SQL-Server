--Protokolltabellen

--Protokoll für Löschen von Mitlgiedern

Select* from mitglied

create table protokoll_mitglied
(
protokoll_nr int identity (100,1) constraint pk_protokoll_mitglied primary key,
mitglied_nr int,
nachname varchar(30),
vorname varchar(30),
geschlecht varchar(1),
geburtsdatum date,
beitritts_datum datetime,
strasse varchar(40),
plz varchar(5),
ort varchar(20),
telefon varchar(20),
email varchar(30),
benutzername varchar(30),
passwort varchar(30),
loeschdatum datetime default (getdate()) ,
Erfasser varchar(40) default (suser_sname())
);


create trigger del_mit
on mitglied for delete
as
begin
	begin transaction 
	insert into protokoll_mitglied(mitglied_nr, nachname, vorname, geschlecht, geburtsdatum, beitritts_datum, strasse, plz,
	              telefon)
	select mitglied_nr, nachname, vorname, geschlecht, geburtsdatum, beitritts_datum, strasse, plz, telefon
	from deleted;
	commit;
end;

Select*from Mitglied;
Insert into Mitglied(nachname, vorname, geschlecht, geburtsdatum, beitritts_datum, strasse, plz, ort, telefon, email, 
                      benutzername, passwort) 
values ('Mueller', 'Achim', 'm', '02.05.1978', '05.04.2017', 'Auf der Weide 58', '78456', 'Ulm', '214597853', null, null, null);

delete mitglied where mitglied_nr=1067

Select*from Protokoll_mitglied


--Protokoll für Löschen von Buchtiteln

Select* from buch
 
drop table protokoll_buch;

create table protokoll_buch
(
protokoll_nr int identity (100,1) constraint pk_protokoll_buch primary key,
titel_nr int,
buch_name varchar(300),
sektion varchar(20),
altersfreigabe varchar(15),
genre varchar(30),
beschreibung varchar(max),
loeschdatum datetime default (getdate()) ,
Erfasser varchar(40) default (suser_sname())
);
go


create trigger del_buch
on buch for delete
as
begin
	begin transaction 
	insert into protokoll_buch(titel_nr, buch_name, sektion, altersfreigabe, genre, beschreibung)
	select titel_nr, buch_name, sektion, altersfreigabe, genre, beschreibung
	from deleted;
	commit;
end;

Select*from Buch
Insert into buch(buch_name,sektion, altersfreigabe, genre, beschreibung) 
values ('Der kleine Prinz', 'Belletristik', 'ab 0 Jahre', 'Roman', 'Ein kleiner Junge auf Reisen durch die Welt')

delete buch where titel_nr= 162;

Select * from Protokoll_buch



--Protokoll für Storno von Verleihungen

Select*from ausleihe;

create table storno_ausleihe
(
protokoll_nr int identity (100,1) constraint pk_storno_ausleihe primary key,
leih_nr int,
buch_nr int ,
mitglied_nr int ,
ausleihe_datum datetime ,
ausleihe_mitarbeiter varchar(30),
faelligkeits_datum datetime ,
rueckgabe_datum datetime ,
rueckgabe_mitarbeiter varchar(30),
Storno datetime default (getdate()) ,
Erfasser varchar(40) default (suser_sname())
);
go

create trigger del_storno
on ausleihe for delete
as
begin
	begin transaction 
	insert into storno_ausleihe(leih_nr, buch_nr, mitglied_nr, ausleihe_datum, faelligkeits_datum,  ausleihe_mitarbeiter, rueckgabe_datum, rueckgabe_mitarbeiter)
	select leih_nr, buch_nr, mitglied_nr, ausleihe_datum, faelligkeits_datum, ausleihe_mitarbeiter, rueckgabe_datum, rueckgabe_mitarbeiter
	from deleted
	commit;
end;


Select*from ausleihe;

Insert into ausleihe( buch_nr, mitglied_nr, ausleihe_mitarbeiter, ausleihe_datum, faelligkeits_datum, rueckgabe_datum, 
                      rueckgabe_mitarbeiter, rueckgabezustand, verfuegbarkeit)
values (110, 1065, 504, '20.05.2020', '15.06.2020', '10.06.2020', 549, 'E',1);

Delete ausleihe where leih_nr=425;

Select*from storno_ausleihe;