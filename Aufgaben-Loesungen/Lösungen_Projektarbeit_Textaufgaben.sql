use Bibliothek_A
go

--I.) Mitglieder dürfen maximal 4 Bücher gleichzeitig ausleihen.

--die Tabelle Ausleihe wird mit Cursor reihenweise bearbeitet und geprüft, ob zum aktuellen Zeitpunkt Mitglieder mehr, 
--gleich oder weniger als 4 Bücher haben und je nach Ergebniss liefert die entsprechende Meldung,ob Mitglied noch Bücher 
--ausleihen darf

create procedure maximale_buchleihe
as
declare @mitglied_nr int
declare @anz int
declare Anz_cursor cursor local for
select mitglied_nr from ausleihe
begin
		open Anz_cursor
		fetch next from Anz_cursor into @mitglied_nr
		while @@fetch_status = 0
		begin
			set @anz= (select count(mitglied_nr) from ausleihe where mitglied_nr=@mitglied_nr
			                and datediff(dd,getdate(),rueckgabe_datum)>1)
			if @anz > 4
			print 'Mitglied mit nummer '+cast(@mitglied_nr as varchar)+ ' hat mehr als 4 Bьcher ausgeliehen'
			else if @anz = 4
			print 'Mitglied mit nummer '+cast(@mitglied_nr as varchar)+' darf keine Bьcher mehr ausleihen'
			else print 'Mitglied mit nummer '+cast(@mitglied_nr as varchar)+' darf noch Bьcher ausleihen'
        fetch next from Anz_cursor into @mitglied_nr
end;
close Anz_cursor;
deallocate Anz_cursor
end;


exec maximale_buchleihe



--II.) Die Bücher werden in der Regel innerhalb von 20 Tagen zurückgegeben. 

create procedure rueckgabefrist

	-- Ausgabe einer Liste, die alle Leihvorgänge mit Überschreitung des Fälligkeitsdatums (über 20 Tage nach Ausleihe) anzeigt
	-- Geordnet nach Fälligkeitsdatum
as 
begin
	select * 
	from ausleihe 
	where datediff(dd,ausleihe_datum,rueckgabe_datum) > 20 
	order by faelligkeits_datum desc
end;
go

exec rueckgabefrist

exec sp_helptext rueckgabefrist




--III) Die Mitglieder wissen,dass sie eine Gnadenfrist von einer Woche haben, bevor eine Benachrichtigung geschickt wird. 

-- Realisiert extern in der Tabelle Strafzahlungen: 
select * from strafzahlung; 

-- Alternativ über Prozedur (Mahndatum 27 Tage nach Ausleihedatum bzw. 7 Tage nach Fälligkeitsdatum)

create procedure mahnung_benachrichtigung

	-- Ausgabe einer Liste, die alle Leihvorgänge mit Überschreitung des Fälligkeitsdatums (über 20 Tage nach Ausleihe)
	-- sowie das Datum der Mahnung (27 Tage nach Ausleihe)  anzeigt
	-- Geordnet nach Fälligkeitsdatum
	-- bei Rückgabedatum NULL und Buch verloren gehen wir davon aus, dass sich das Mitglied meldet
as 
begin
    select leih_nr, buch_nr, mitglied_nr, ausleihe_datum, ausleihe_mitarbeiter, dateadd(dd, 20, ausleihe_datum) as faelligkeits_datum, 
	       rueckgabe_datum, rueckgabe_mitarbeiter, dateadd(dd, 27, ausleihe_datum) as mahnungs_datum
	from ausleihe 
	where datediff(dd,ausleihe_datum,rueckgabe_datum) >= 27 
	order by faelligkeits_datum desc
end;
go

exec mahnung_benachrichtigung

exec sp_helptext mahnung_benachrichtigung

--IV) Die Datenbank soll die Möglichkeit bieten, dass man Bücher nach ihrem Titel, aber auch 
--    nach Autoren oder Verlagen suchen kann.

create procedure Titelsuche
 (@buch_name varchar(200))
 as
 begin
	 select  c.buch_name, e.nachname, e.vorname, a.verlag 
	 from verlag a 
	 full outer join verlag_zu_buch b on a.verlag_nr = b.verlag_nr
	 full outer join buch c on b.titel_nr = c.titel_nr
	 full outer join  autor_zu_buch d on c.titel_nr = d.titel_nr
	 full outer join autor e on d.autor_nr = e.autor_nr 
	 where c.buch_name like @buch_name
 end; 

 exec Titelsuche  'P%';

create procedure Verlagsuche
 (@verlag_name varchar(100))
 as
 begin
	 select a.verlag, c.buch_name, e.nachname "autor_nachname", e.vorname "autor_vorname"
	 from verlag a 
	 full outer join verlag_zu_buch b on a.verlag_nr = b.verlag_nr
	 full outer join buch c on b.titel_nr = c.titel_nr
	 full outer join autor_zu_buch d on c.titel_nr = d.titel_nr
	 full outer join autor e on d.autor_nr = e.autor_nr 
	 where a.verlag like @verlag_name
 end; 

 exec Verlagsuche  'W%';

create procedure Autorsuche
 (@autor_name varchar(100))
 as
 begin
	 select  e.nachname "autor_nachname", e.vorname "autor_vorname",  c.buch_name, a.verlag
	 from verlag a 
	 full outer join verlag_zu_buch b on a.verlag_nr = b.verlag_nr
	 full outer join buch c on b.titel_nr = c.titel_nr
	 full outer join autor_zu_buch d on c.titel_nr = d.titel_nr
	 full outer join autor e on d.autor_nr = e.autor_nr 
	 where e.nachname like @autor_name
 end; 

 exec Autorsuche  'M%';

 --V) Der Mitarbeiter soll beim Verleihvorgang erfragen können ob ein Buch auf Lager ist.

alter procedure Verfuegbarkeit_buchname
 (@buch_name varchar(100))
 as
 begin
	select a.titel_nr, b.buch_nr, a.buch_name, a.sektion, a.altersfreigabe, b.sprache, b.formattyp,c.verfuegbarkeit
	from buch a
	full outer join exemplare b on a.titel_nr = b.titel_nr
	full outer join ausleihe c on c.buch_nr = b.buch_nr
	where verfuegbarkeit = 1 and a.buch_name like @buch_name 
	 
	group by  b.buch_nr , a.titel_nr,a.buch_name, a.sektion, a.altersfreigabe, b.sprache, b.formattyp,c.verfuegbarkeit
end; 
go


exec Verfuegbarkeit_buchname  'M%';

--VI) Bei der Rückgabe soll geprüft werden, ob die Verleihzeit überschritten wurde, wenn ja wie 
--lange – für jede überfдllige Woche wird eine Strafzahlung von 5 Ђ fällig.

-- bereits in Strafzahlungen geregelt
select * from strafzahlungen

-- prozedur:

create procedure mahngebuehr
(@leih_nr int)
as 
begin
	select leih_nr, datediff(ww, faelligkeits_datum, rueckgabe_datum)*5 "Gebühr"
	from ausleihe 
	where datediff(dd,ausleihe_datum,rueckgabe_datum) > 27 and @leih_nr = leih_nr
end;
go



select * from strafzahlung
exec mahngebuehr 313


--VII) --Montag 
--An Montagen ist Ruhetag – an diesen Tagen dürfen die Mitarbeiter keine Daten in die Datenbank eingeben, 
--an Samstagen ist nur bis 12:00 Uhr eine Anmeldung erlaubt – treffen Sie die hierfür erforderlichen Maßnahmen
-- und testen Sie diese.

create trigger ausleihe_table
on ausleihe
for insert, update, delete
as
begin
	if datename(weekday,getdate()) in ('Montag') 
	OR datename(weekday,getdate()) in ('Samstag') and datepart(hh, getdate()) not between 8 and 12
	or datepart(hh, getdate()) not between 8 and 18
	begin
		raiserror('Zu diesen Zeiten keine Änderungen erlaubt', 16,1)
		rollback;
	end;
end;
go


--Diese Datenzätze können zum Testen eingetragen werden( Tag auf 'Sonntag' umstellen und eine Fehlermeldung wird geliefert)

insert into ausleihe 
values (37,1035 ,'01.03.2021',532,'12.03.2021','12.03.2021',532,'E',0)

select * from ausleihe