--Indizes

create index idx_mitarbeiter_nr_mitarbeiter
on mitarbeiter(mitarbeiter_nr);

create index idx_ausleihe_nr_ausleihe
on ausleihe(leih_nr);

create index idx_buch_nr_buch
on buch(titel_nr);

create index idx_Mitglied_nr_mitglied
on mitglied(mitglied_nr);

Select*from Mitglied