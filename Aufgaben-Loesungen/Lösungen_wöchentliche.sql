--wöchentliche Analysen
--1.	welche Bücher am häufigsten verliehen wurden, hierzu wird die Anzahl Verleihungen nach Titeln, aber auch nach Jahren
--bzw. Monaten ermittelt

create view haeufigste_titel
as
select count(d.titel_nr) "Anzahl_Ausleihe", d.titel_nr, a.buch_name
from buch a 
inner join autor_zu_buch b on b.titel_nr=a.titel_nr 
inner join autor c on c.autor_nr=b.autor_nr
inner join exemplare d on d.titel_nr= a.titel_nr
inner join ausleihe e on e.buch_nr=d.buch_nr
group by d.titel_nr, a.buch_name
order by count(d.titel_nr) desc offset 0 rows

Select*from haeufigste_titel

--Nach Jahr
create view bestseller_jahr
as
select count(d.titel_nr) "Anzahl_Ausleihe", d.titel_nr, a.buch_name, year(e.ausleihe_datum) Jahr
from buch a 
inner join autor_zu_buch b on b.titel_nr=a.titel_nr 
inner join autor c on c.autor_nr=b.autor_nr
inner join exemplare d on d.titel_nr= a.titel_nr
inner join ausleihe e on e.buch_nr=d.buch_nr
group by d.titel_nr, a.buch_name,year(e.ausleihe_datum)
order by count(d.titel_nr) desc offset 0 rows

select * from bestseller_jahr

--Nach Jahr und Monat
create view bestseller_jahr_monat
as
select count(d.titel_nr) "Anzahl_Ausleihe", d.titel_nr, a.buch_name, year(e.ausleihe_datum) "Jahr", month(e.ausleihe_datum) "Monat"
from buch a 
inner join autor_zu_buch b on b.titel_nr=a.titel_nr 
inner join autor c on c.autor_nr=b.autor_nr
inner join exemplare d on d.titel_nr= a.titel_nr
inner join ausleihe e on e.buch_nr=d.buch_nr
group by d.titel_nr, a.buch_name,year(e.ausleihe_datum), month(e.ausleihe_datum)
order by count(d.titel_nr) desc offset 0 rows

select * from bestseller_jahr_monat


--2.	z.B. Wie oft wurden Bücher im Januar 2014 verliehen oder wie häufig in einem bestimmten Jahr – z.B. 2015

create procedure Ausleihe_Zeitraum
(
@startdate datetime,
@enddate datetime
)
as
begin	
		select count(c.buch_nr) "Anzahl_Leihe" ,a.buch_name
		from buch a
		inner join exemplare b
		on a.titel_nr = b.titel_nr
		inner join ausleihe c
		on b.buch_nr = c.buch_nr
		where c.ausleihe_datum between @startdate and @enddate
		group by(a.buch_name)
		order by count(c.buch_nr) desc
end
execute Ausleihe_Zeitraum '01.01.2020' , '31.12.2020'


--3.	wie viele Exemplare eines Buches sind in der Bibliothek vorhanden und wie viele sind ausgeliehen.
--Anzahl virhandener Bücher

create procedure Exemplare_eines_Buches
as
begin
		select a.titel_nr,a.buch_name,  count(a.titel_nr) "Exemplare"
		from buch a
		inner join exemplare b
		on a.titel_nr = b.titel_nr
        group by  a.titel_nr,  a.buch_name      
end
go
execute Exemplare_eines_Buches


--Anzahl ausgeliehene Bücher

create procedure Verliehene_Exemplare_eines_Buches
as
begin
		select a.titel_nr,a.buch_name,  c.buch_nr 
		from buch a
		inner join exemplare b
		on a.titel_nr = b.titel_nr
		inner join ausleihe c
		on b.buch_nr = c.buch_nr
		where c.verfuegbarkeit = 0
        group by  a.titel_nr,  a.buch_name, c.buch_nr    
end;
go

exec Verliehene_Exemplare_eines_Buches


--4.	Wie viele Bücher wurden im letzten Jahr ausgeliehen?

create procedure Buchverleih_2020
as
begin
	select count(distinct(buch_nr)) 'Bücher wurden im letzten Jahr ausgeliehen'
	from ausleihe 
	where year(ausleihe_datum) = '2020'
end
go
execute Buchverleih_2020
-----

create procedure Buchverleih_jährlich
(
@year varchar(4)
)
as
begin
	select count(distinct(buch_nr)) 'Bücher wurden im letzten Jahr ausgeliehen'
	from ausleihe 
	where year(ausleihe_datum) = @year
end
go
execute Buchverleih_jährlich '2020'


--5.	Wie viel Prozent der Mitglieder entliehen mindestens ein Buch?
--(Bei uns alle Mitglieder haben mind. 1 Buch ausgeliehen d.h.100%)

alter procedure Proz_mit 
as
begin

declare @mit numeric(3)
set @mit = (select count(mitglied_nr) from mitglied)
select (count(distinct(b.mitglied_nr))*100)/@mit
from mitglied a
inner join ausleihe b
on a.mitglied_nr = b.mitglied_nr
end
exec Proz_mit


--6.	Wie viele Bücher wurden von dem Mitglied entliehen, das die meisten Bücher entlieh?
alter procedure Mitglieder_Leihanzahl 
as
begin
	select count(b.mitglied_nr) 'entliehen',a.mitglied_nr 'Mitglied Nummer',a.nachname,a.vorname
	from mitglied a
	inner join ausleihe b
	on a.mitglied_nr = b.mitglied_nr
	group by a.mitglied_nr,a.nachname,a.vorname order by count(b.mitglied_nr) desc
end
go 
execute Mitglieder_Leihanzahl

select * from ausleihe

--7.	Wie viel Prozent der Bücher wurden im letzten Jahr mindestens einmal entliehen?
create procedure Proz_buch
as
begin
declare @buch numeric(3)
set @buch=(select count(titel_nr) from buch)
select (count(distinct(buch_nr))*100)/@buch
from ausleihe
where year(ausleihe_datum)='2020'
end;

exec Proz_buch


--8.	Wie viel Prozent aller ausgeliehenen Bücher werden überfällig?
create procedure Buch_ub
as
begin
declare @zahl numeric(3)
set @zahl =(select count(leih_nr) from ausleihe)

select (count(leih_nr)*100)/@zahl "Prozent"
from ausleihe where datediff(dd,faelligkeits_datum,rueckgabe_datum) > 0 

end
go
execute Buch_ub


--9.	Wie lange wird ein Buch durchschnittlich entliehen?

create procedure avg_leihe
@buch_name varchar(300)='',
@nachname varchar(30)='',
@vorname varchar(30)=''
as
declare @zeit int
begin

begin transaction
set @zeit=  (select (avg(datediff(dd,e.ausleihe_datum,e.rueckgabe_datum)))
from buch a inner join exemplare b on a.titel_nr=b.titel_nr 
            inner join autor_zu_buch c on b.titel_nr=c.titel_nr
		    inner join autor d on c.autor_nr=d.autor_nr
		    inner join ausleihe e on b.buch_nr=e.buch_nr
            where buch_name=@buch_name or vorname=@vorname or nachname=@nachname and
			      e.ausleihe_datum between '01.01.2020' and '31.12.2020');
		    print 'das Buch '+@buch_name+''+@nachname+''+@vorname+' wurde im Jahr 2020 '+cast((@zeit) as varchar)+ 
			         ' Tage durchschnittlich entliehen '
commit;
end;
go

execute avg_leihe 'Dracula','',''
