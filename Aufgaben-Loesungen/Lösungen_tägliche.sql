select * from ausleihe

--Tägliche Bibliotheksaufgaben 

--1.	Hinzufügen neuer Buchtitel zur Datenbank

create procedure buch_hinzufuegen
(
@titel_nr int,
@buch_name varchar(300),
@sektion varchar(20),
@altersfreigabe varchar(15),
@genre varchar(30),
@beschreibung varchar(max) null
 )
as
begin  
begin transaction  
		insert into buch(buch_name,sektion,altersfreigabe,genre,beschreibung)
					values(@buch_name,@sektion,@altersfreigabe,@genre,@beschreibung)
commit;
end

execute buch_hinzufuegen  161,'buch_name','section','altersfreigabe','genre','beschreibung'

select * from buch
---------exemplar

create procedure exemplare_hinzufuegen
(
@titel_nr int,
@isbn varchar(30),
@seiten int,
@auflage int,
@erscheinungs_jahr int,
@erscheinungs_ort varchar(30), 
@anschaffungs_datum date,
@sprache varchar(30),
@formattyp varchar(30)
)

as
begin  
begin transaction  
		insert into exemplare(titel_nr,isbn,seiten,auflage,erscheinungs_jahr,erscheinungs_ort, 
							   anschaffungs_datum,sprache,formattyp)
					values(@titel_nr,@isbn,@seiten,@auflage,@erscheinungs_jahr,@erscheinungs_ort, 
							   @anschaffungs_datum,@sprache,@formattyp)
commit;
end

execute exemplare_hinzufuegen 161,'isbn',250,3,2019,'Berlin','25.08.2020','deutsch','Hardcover'

select * from exemplare
---------verlag 
create procedure verlag_hinzufuegen
(
@verlag varchar(30), 
@ort varchar(20),
@land varchar(20)
)

as
begin  
begin transaction  
		insert into verlag(verlag, ort, land)
					values(@verlag,@ort,@land)
commit;
end

execute verlag_hinzufuegen  'Kinderbuchverlag', NULL, 'Deutschland'

select * from verlag

---------autor 
create procedure autor_hinzufuegen
(
@nachname varchar(30),
@vorname varchar(30)
)

as
begin  
begin transaction  
		insert into autor (nachname, vorname)
					values(@nachname,@vorname)
commit;
end


execute autor_hinzufuegen  'autor',  'name'

select * from autor

--- verändern der Tabellen Autor zu buch:

--in diese Tabelle werden die Werte aus der anderen Tabellen eingetragen(die Werte 888,999 nur für Testen)
create procedure autor_zu_buch_hinzufuegen
(
@autor_nr int,
@titel_nr int
)

as
begin  
begin transaction  
		insert into autor_zu_buch (autor_nr, titel_nr)
					values(@autor_nr,@titel_nr)
commit;
end

execute autor_zu_buch_hinzufuegen  888,  999

select * from autor_zu_buch

--- verlag zu Buch
--in diese Tabelle werden die Werte aus der anderen Tabellen eingetragen(die Werte 888,999 nur für Testen)

create procedure verlag_zu_buch_hinzufuegen
(
@verlag_nr int,
@titel_nr int
)

as
begin  
begin transaction  
		insert into verlag_zu_buch (verlag_nr, titel_nr)
					values(@verlag_nr,@titel_nr)
commit;
end

execute verlag_zu_buch_hinzufuegen  888,  999

--2.	Eingeben neuer Mitglieder

create procedure mitglied_hinzufuegen
(
@mitglied_nr int,
@vorname varchar(30), 
@nachname varchar(30),
@strasse varchar(40),
@plz varchar(5),
@ort varchar(20),
@geburtsdatum date,
@geschlecht varchar(1),
@beitritts_datum datetime,
@telefon varchar(20),
@email varchar(30),
@benutzername varchar(30),
@passwort varchar(30)
)

as
begin  
		insert into mitglied(vorname, nachname, strasse, plz, ort, geburtsdatum,geschlecht,beitritts_datum,telefon,email,
		                     benutzername, passwort)
					values(@vorname,@nachname,@strasse,@plz,@ort,@geburtsdatum,@geschlecht,@beitritts_datum,@telefon,@email,
					       @benutzername, @passwort)
end;

execute mitglied_hinzufuegen 1066, 'Hanna', 'Heise','Kцnigsberger Str. 7', '69168' ,'Wiesloch','02.03.1989', 'm','10.02.2020', '0176005090123',
	        'Hanna_Heise@yahoo.com','HannaHeise123','Hanna12345'

select * from mitglied






--3.	Rückgabe der Bücher

--Variante 1. Update ausleihe (leih_nr,  rueckgabe_mitarbeiter, rueckgabe_datum, rueckgabezustand, verfuegbar)
--values (110,1065,'05.03.2020', 'E', 1 ) und in View abspeichern

alter view rueckgabe_Buch
as 
	select a.buch_name 'Buch Name',c.ausleihe_datum,
	       c.rueckgabe_datum 'rückgabe Datum', c.verfuegbarkeit 'verfügbarkeit 0 = Nein 1 = ja',c.leih_nr 'Leih Nummer'
	from buch a
	inner join exemplare b
	on a.titel_nr = b.titel_nr
	inner join ausleihe c
	on b.buch_nr = c.buch_nr
	
	--where buch_name like '%a'
with check option

select * from rueckgabe_Buch

--Variante 2. Prozedure fügt fehlendes Rückgabedatum hinzu

create procedure rueckgabe
(
@rueckgabe_datum datetime,
@leih_nr int
)
as 
begin
select * 
from ausleihe 
where rueckgabe_datum is Null
begin transaction
update ausleihe 
set rueckgabe_datum = @rueckgabe_datum
where leih_nr = @leih_nr
commit; 
end; 

exec rueckgabe '03.03.2021', 311

select * from ausleihe where rueckgabe_datum = '03.03.2021'


--4.	Buchreservierungen durchführen
--insert into reservierung ( titel_nr, reservierungs_datum, mitglied_nr, info_nachricht, abholung)
--values ( 123, '11.05.2020', 1035, 0) und speichert in View ab.


create view Buchreservierungen_durchfuehren
as
		select a.reservierungs_datum 'reservierungs datum',b.buch_name 'Buch name', a.reserv_nr 'reserve Nummer'
		from reservierung a
		inner join buch b
		on a.titel_nr = b.titel_nr
		where b.buch_name LIKE 'ha%' 
with check option

select * from Buchreservierungen_durchfuehren


--5.	Benachrichtigen der Mitglieder bezüglich vorbestellter Bücher

Create view vorbestellte_Buecher
as
	Select a.mitglied_nr, b.Nachname, a.reserv_nr, a.info_nachricht 
	from  reservierung a 
	inner join mitglied b
	on a.mitglied_nr=b.mitglied_nr 
	where reservierungs_datum='10.04.2020'

	select * from  vorbestellte_Buecher

--6.	Abfragen von Informationen bezüglich der Buchverfügbarkeit entweder nach Titel oder Autor

alter procedure Buch_Verf
@buch_name varchar(300)='',
@nachname varchar(30)='', 
@vorname varchar(30)=''

as
begin
   if exists (select a.buch_name, d.nachname, d.vorname,e.verfuegbarkeit 
      from buch a inner join exemplare b on a.titel_nr=b.titel_nr 
                  inner join autor_zu_buch c on b.titel_nr=c.titel_nr
				  inner join autor d on c.autor_nr=d.autor_nr
				  inner join ausleihe e on b.buch_nr=e.buch_nr
		where verfuegbarkeit=1 and buch_name=@buch_name or vorname=@vorname or nachname=@nachname)
    print 'das Buch '+@buch_name+''+@nachname+''+@vorname+' ist verfügbar'
    else print 'Das Buch: '+@buch_name+''+@nachname+''+@vorname+'  ist nicht verfügbar'
end;
go
execute  Buch_Verf 'Dracula','Stoker',''


--7.	erstellen einer Liste der nicht entliehenen Bücher

create procedure nicht_entliehene_buecher
as
begin
  select a.titel_nr, a.buch_name, b.buch_nr, a.sektion, a.genre
  from buch a 
  full outer join exemplare b on a.titel_nr = b.titel_nr
  full outer join ausleihe c on c.buch_nr = b.buch_nr 
  where c.leih_nr IS NULL
  group by a.titel_nr, a.buch_name, b.buch_nr, a.sektion, a.genre
end;
go

--- weitere lösungen
exec nicht_entliehene_buecher

create procedure nicht_entliehenen_Bucher2
as
begin
	  select a.buch_name 'nicht entliehenen Bьcher', b.buch_nr
	  from buch a
	  right join exemplare b
	  on a.titel_nr = b.titel_nr
	  right join ausleihe c
	  on b.buch_nr = c.buch_nr 
end

go
execute nicht_entliehenen_Bucher2


--8.	Erzeugung einer Bestseller-Liste (welche Bücher werden am häufigsten verliehen)
create procedure Bestseller
as
begin
  select count(d.titel_nr)  "Anzahl_Ausleihe", d.titel_nr, a.buch_name
  from buch a 
  inner join autor_zu_buch b on b.titel_nr=a.titel_nr 
  inner join autor c on c.autor_nr=b.autor_nr
  inner join exemplare d on d.titel_nr= a.titel_nr
  inner join ausleihe e on e.buch_nr=d.buch_nr
  group by d.titel_nr, a.buch_name
  order by count(d.titel_nr) desc
end; 
go

exec Bestseller

--9.	erstellen einer Liste aller überfälligen Bücher

create procedure ueberfaellige_buecher
as
begin
  select * from ausleihe where datediff(dd,faelligkeits_datum,getdate())>0
end;
go
exec ueberfaellige_buecher

create view ueberf_buecher
as
select * from ausleihe where datediff(dd,faelligkeits_datum,getdate())>0
with check option





