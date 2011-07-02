Piotr Walkowski
#221135

zad3:
a)
-- oblicza liczba osob

CREATE OR REPLACE FUNCTION srednia(nazwa TEXT, grupa.rodzaj_zajec%TYPE, semestr.nazwa%TYPE) RETURNS double precision AS 
'
DECLARE
 lacznie_osob double precision;
 lacznie_grup INT;

BEGIN

lacznie_osob := (SELECT count(DISTINCT wybor.kod_uz) 
		FROM wybor
		JOIN grupa USING(kod_grupy) JOIN przedmiot_semestr USING (kod_przed_sem) JOIN przedmiot USING(kod_przed)
		JOIN semestr USING (semestr_id)
		WHERE przedmiot.nazwa = $1 AND grupa.rodzaj_zajec LIKE $2 AND semestr.nazwa = $3
		HAVING count(DISTINCT wybor.kod_uz) > 0)::INT;

lacznie_grup :=	(SELECT count(DISTINCT grupa.kod_grupy)
		FROM wybor
		JOIN grupa USING(kod_grupy) JOIN przedmiot_semestr USING (kod_przed_sem) JOIN przedmiot USING(kod_przed)
		JOIN semestr USING (semestr_id)
		WHERE przedmiot.nazwa = $1 AND grupa.rodzaj_zajec = $2 AND semestr.nazwa = $3
		HAVING count(DISTINCT wybor.kod_uz) > 0)::INT;

RETURN (lacznie_osob/lacznie_grup);
END;
' 
LANGUAGE plpgsql;

select srednia('Bazy danych', 'r', 'Semestr letni 2008/2009');


b)
SELECT przedmiot.nazwa, grupa.rodzaj_zajec, (count(DISTINCT wybor.kod_uz) / count(DISTINCT grupa.kod_grupy)::DOUBLE PRECISION) as srednia
		FROM wybor
		JOIN grupa USING(kod_grupy) JOIN przedmiot_semestr USING (kod_przed_sem) JOIN przedmiot USING(kod_przed)
		JOIN semestr USING (semestr_id)
		WHERE semestr.nazwa = 'Semestr letni 2008/2009'
		GROUP BY przedmiot.nazwa, grupa.rodzaj_zajec
		HAVING count(DISTINCT wybor.kod_uz) > 0
		ORDER BY srednia DESC ; 

zad4:
CREATE or REPLACE FUNCTION zmiana() RETURNS VOID AS '
DECLARE 
kursorek CURSOR FOR SELECT * FROM grupa ORDER BY kod_grupy DESC;
pomocnicza grupa%ROWTYPE;

BEGIN
  OPEN kursorek;
  
  LOOP 
   FETCH kursorek INTO pomocnicza;
 
   EXIT WHEN NOT FOUND;
   pomocnicza.kod_grupy := (pomocnicza.kod_grupy + 1);
  
   INSERT INTO grupa VALUES(pomocnicza.kod_grupy,
			    pomocnicza.kod_przed_sem,
			    pomocnicza.kod_uz,
			    pomocnicza.max_osoby,
			    pomocnicza.rodzaj_zajec,
			    pomocnicza.termin,
			    pomocnicza.sala);
   
   UPDATE wybor SET kod_grupy = pomocnicza.kod_grupy WHERE wybor.kod_grupy = (pomocnicza.kod_grupy-1);
   DELETE FROM grupa WHERE kod_grupy = (pomocnicza.kod_grupy-1);   
   
  END LOOP;
   
  CLOSE kursorek;
  
END;
'		
LANGUAGE plpgsql;

-- sprawdzalem przy uzyciu tranzakcji i jesli czegos nie przeoczylem dziala poprawnie ;)