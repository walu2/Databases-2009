Autor: Piotr Walkowski index: [221135]

Zad.1:

a) 
SELECT imie, nazwisko, semestr
FROM uzytkownik 
WHERE semestr >= 1 AND semestr <= 3 AND imie = 'Piotr';

b)
SELECT nazwa, punkty
FROM przedmiot
WHERE egzamin != TRUE;

c)

	id bierzacego semestru: 28 (select semestr_if FROM SEMESTR where nazwa = ''Semestr letni 2008/2009')
	kod przedmiotu DB: 12 (select kod_przed from przedmiot where nazwa = 'Bazy danych')

ODPOWIEDZ:
 SELECT kod_przed_sem FROM przedmiot_semestr WHERE semestr_id = 28 AND kod_przed = 12;

generuje 2674

kod_przed: 12
semestr_id = 28
kod_przed_sem = 2674

d)  
SELECT nazwisko FROM uzytkownik
NATURAL JOIN grupa
WHERE grupa.kod_przed_sem = 2674;


Zad.2:

CREATE TABLE cwbd2009 
(
	prow_id integer, 
	prow_nazwisko character varying(30),
	stud_id integer NOT NULL, 
	stud_nazwisko character varying(30) NOT NULL, 
	grupa_kod integer NOT NULL,
	termin timestamp with time zone NOT NULL DEFAULT now(),
	CONSTRAINT fk_grupa FOREIGN KEY (grupa_kod)
        REFERENCES grupa (kod_grupy) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION DEFERRABLE INITIALLY IMMEDIATE,
	CONSTRAINT fk_prowadzacy FOREIGN KEY (prow_id)
        REFERENCES uzytkownik (kod_uz) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION DEFERRABLE INITIALLY IMMEDIATE,
	CONSTRAINT fk_student FOREIGN KEY (stud_id)
        REFERENCES uzytkownik (kod_uz) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION DEFERRABLE INITIALLY IMMEDIATE
);


Zad.3:

a) 
SELECT kod_grupy as "Kod grupy" 
FROM grupa
NATURAL JOIN przedmiot_semestr
WHERE przedmiot_semestr.kod_przed_sem = 2674 
AND kod_grupy != 4768;   // wykluczamy gdyz to kod wykladu... [sprawdzone po godzinie]


b)


Zapytanie zwracajace odpowiednie kolumny:

SELECT kod_uz as "Kod usera", nazwisko, kod_grupy as "Kod grupy", data
FROM wybor
NATURAL JOIN uzytkownik
WHERE kod_grupy IN (SELECT kod_grupy 
	         FROM grupa
		 NATURAL JOIN przedmiot_semestr
		 WHERE przedmiot_semestr.kod_przed_sem = 2674 AND kod_grupy != 4768) 

// uzyto zapytania z  zadania poptrzedmiego

ORDER BY 1


<<<<<<<<<

zapytanie wstawiajace:

INSERT INTO cwbd2009(stud_id, stud_nazwisko, grupa_kod, termin)
 (SELECT kod_uz as "Kod usera", nazwisko, kod_grupy as "Kod grupy", data
FROM wybor
NATURAL JOIN uzytkownik
WHERE kod_grupy IN (SELECT kod_grupy 
	         FROM grupa
		 NATURAL JOIN przedmiot_semestr
		 WHERE przedmiot_semestr.kod_przed_sem = 2674 AND kod_grupy != 4768) )



zad4.

// to zapytanie wyswietla id i nazwiska prowadzacych 

SELECT kod_grupy, kod_uz, nazwisko 
FROM grupa 
NATURAL JOIN uzytkownik
WHERE kod_grupy IN (SELECT kod_grupy
                    FROM grupa NATURAL JOIN przedmiot_semestr
 		    WHERE przedmiot_semestr.kod_przed_sem = 2674 AND kod_grupy != 4768
                   )

mamy nastepujacy wynik:

 kod_grupy | kod_uz |  nazwisko
-----------+--------+-------------
      4767 |   2330 | Otop
      4772 |   2160 | Demichowicz
      4867 |   2249 | Michaliszyn
      4771 |   3055 | Cichocki
      4770 |   1584 | Charatonik
      4769 |    187 | Kanarek


zatem robie szesc zapytan aktualizujacych:

UPDATE cwbd2009 SET prow_id = 2330, prow_nazwisko = 'Otop' WHERE grupa_kod = 4767;
UPDATE cwbd2009 SET prow_id = 2160, prow_nazwisko = 'Demichowicz' WHERE grupa_kod = 4772;
UPDATE cwbd2009 SET prow_id = 187, prow_nazwisko = 'Kanarek' WHERE grupa_kod = 4769;
UPDATE cwbd2009 SET prow_id = 3055, prow_nazwisko = 'Cichocki' WHERE grupa_kod = 4771;
UPDATE cwbd2009 SET prow_id = 1584, prow_nazwisko = 'Charatonik' WHERE grupa_kod = 4770;
UPDATE cwbd2009 SET prow_id = 2249, prow_nazwisko = 'Michaliszyn' WHERE grupa_kod = 4867;


Zad.5:

SELECT grupa_kod, stud_id, stud_nazwisko as "naz", termin
FROM cwbd2009
ORDER BY grupa_kod ASC, termin ASC;


Recznie przegladajac wynik mozna zauwazyc nastepujacych 'najszybszych':

4767 |    2909 | Dolecki      | 2009-02-18 08:31:31.225241+01
4769 |    3311 | Ledwon       | 2009-02-18 17:25:17.097442+01
4770 |    2561 | Pszona       | 2009-02-17 18:14:04.557255+01
4771 |    3404 | Milewski     | 2009-02-18 17:30:13.260136+01
4772 |    2480 | Benben       | 2009-02-18 10:42:36.498836+01
4867 |    2972 | Bober        | 2009-02-28 14:04:37.855164+01

Tworze wiec tabele najszybszybd2009, zapytaniem:

CREATE TABLE najszybszybd2009 (
   kod_grupy integer NOT NULL,
   stud_kod integer NOT NULL,
   stud_nazwisko character varying(30) NOT NULL,
   CONSTRAINT fk_grupa FOREIGN KEY (kod_grupy)
      REFERENCES grupa (kod_grupy) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION DEFERRABLE INITIALLY IMMEDIATE,
   CONSTRAINT fk_userID FOREIGN KEY (stud_kod)
      REFERENCES uzytkownik (kod_uz) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION DEFERRABLE INITIALLY IMMEDIATE
) 

i ostatecznie wypelniam ja tym co przed chwila uzyskalem:

INSERT INTO najszybszybd2009 VALUES(4767 ,    2909 , 'Dolecki');
INSERT INTO najszybszybd2009 VALUES(4769 ,    3311 , 'Ledwon');
INSERT INTO najszybszybd2009 VALUES(4770 ,    2561 , 'Pszona');
INSERT INTO najszybszybd2009 VALUES(4771 ,    3404 , 'Milewski');
INSERT INTO najszybszybd2009 VALUES(4772 ,    2480 , 'Benben');
INSERT INTO najszybszybd2009 VALUES(4867 ,    2972 , 'Bober');
