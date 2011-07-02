
1)
 a)
SELECT przedmiot.nazwa, grupa.rodzaj_zajec, sum(grupa.max_osoby) as "limit miejsc"
FROM przedmiot
JOIN przedmiot_semestr USING(kod_przed) JOIN semestr USING(semestr_id) JOIN grupa USING(kod_przed_sem)
WHERE semestr.nazwa = 'Semestr letni 2008/2009'
GROUP BY grupa.rodzaj_zajec, przedmiot.nazwa, grupa.max_osoby
ORDER BY przedmiot.nazwa, grupa.max_osoby DESC;

 b)
 
SELECT przedmiot.nazwa, grupa.rodzaj_zajec as "rodzaj", grupa.kod_grupy, COUNT(DISTINCT wybor.kod_uz) as "Liczba zapisanych"
FROM przedmiot 
JOIN przedmiot_semestr USING(kod_przed) JOIN semestr USING(semestr_id) JOIN grupa USING(kod_przed_sem) LEFT JOIN wybor USING(kod_grupy) LEFT JOIN uzytkownik ON (wybor.kod_uz = uzytkownik.kod_uz)
WHERE semestr.nazwa = 'Semestr letni 2008/2009' AND grupa.rodzaj_zajec = 'w'
GROUP BY przedmiot.nazwa, grupa.rodzaj_zajec, grupa.kod_grupy, grupa.max_osoby
ORDER BY COUNT(DISTINCT wybor.kod_uz) DESC;

-- left JOIN na wybor zeby byly pokazane puste grupy

2)
 a) INSERT INTO uzytkownik (kod_uz, imie, nazwisko, semestr) VALUES ((SELECT MAX(kod_uz) FROM uzytkownik)+1, '', 'SPNJO', 0)
 b) Korzystamy z ponizszego zapytania zwracajacego nam id grup lektoratow angielskich:
   SELECT grupa.kod_grupy from grupa
   JOIN przedmiot_semestr USING(kod_przed_sem) JOIN semestr USING(semestr_id) JOIN przedmiot USING(kod_przed)
   WHERE semestr.nazwa = 'Semestr letni 2008/2009' AND przedmiot.nazwa LIKE 'Jezyk angielski%';
   
   poza tym kod SPNJO: SELECT uzytkownik.kod_uz FROM uzytkownik WHERE imie = '' AND nazwisko = 'SPNJO' AND semestr = 0
   
   Zatem calosc to:
   
UPDATE FROM grupa SET grupa.kod_uz = (SELECT uzytkownik.kod_uz FROM uzytkownik WHERE imie = '' AND nazwisko = 'SPNJO' AND semestr = 0)
WHERE grupa.kod_grupy IN (
                           SELECT grupa.kod_grupy from grupa
                           JOIN przedmiot_semestr USING(kod_przed_sem) JOIN semestr USING(semestr_id) JOIN przedmiot USING(kod_przed)
                           WHERE semestr.nazwa = 'Semestr letni 2008/2009' AND przedmiot.nazwa LIKE 'Jezyk angielski%';
                         )
			
3)

  a) 
  
  CREATE VIEW plan_prac AS (
  SELECT 
   CASE semestr.nazwa WHEN ('Semestr letni 2008/2009') 
     THEN 'l' 
     ELSE 'z' END as "semestr", uzytkownik.imie, uzytkownik.nazwisko, przedmiot.nazwa, grupa.rodzaj_zajec as "rodzaj", grupa.termin, grupa.kod_grupy
  FROM przedmiot 
  JOIN przedmiot_semestr USING(kod_przed) JOIN semestr USING(semestr_id) JOIN grupa USING(kod_przed_sem) JOIN uzytkownik ON (grupa.kod_uz = uzytkownik.kod_uz)
  WHERE semestr.nazwa = 'Semestr letni 2008/2009' OR semestr.nazwa = 'Semestr zimowy 2008/2009'
  ORDER BY uzytkownik.nazwisko
  )

 b) // ;[
 c) 
    SELECT count(nazwisko) FROM plan_prac; -- (*)

    BEGIN;    
      DELETE FROM plan_prac WHERE nazwisko = 'Kanarek';
      DELETE FROM plan_prac WHERE nazwisko = 'Charatonik';

    ROLLBACK;

   SELECT count(nazwisko) FROM plan_prac;    -- tyle samo co (*)
 
4) 
   a)
      SELECT imie, nazwisko, COUNT(nazwisko) as "grup"
	  FROM plan_prac
	  WHERE semestr = 'l' AND imie IS NOT NULL AND imie != '' -- pomijam {nieznanych prowadzacych} lektoratow
      GROUP BY imie, nazwisko
      HAVING COUNT(nazwisko) > 3
      ORDER BY "grup" DESC;
   
   b) SELECT imie, nazwisko, SUM((SELECT count(DISTINCT kod_uz) FROM wybor WHERE wybor.kod_grupy = plan_prac.kod_grupy)) as "liczebnosc" -- podzapytanie do obliczania liczebnosci grupy
      FROM plan_prac
      WHERE imie IS NOT NULL AND imie != '' -- pomijam {nieznanych prowadzacych} lektoratow
      GROUP by imie, nazwisko
      HAVING SUM((SELECT count(DISTINCT kod_uz) FROM wybor WHERE wybor.kod_grupy = plan_prac.kod_grupy)) >= 200   -- konieczny warunek po grupowaniu
      ORDER BY liczebnosc DESC;
						 
5)
   SELECT przedmiot.nazwa, COUNT(grupa.rodzaj_zajec) as "najwiecej grup"
   FROM przedmiot
   JOIN przedmiot_semestr USING(kod_przed) JOIN semestr USING(semestr_id) JOIN grupa USING(kod_przed_sem)
   WHERE semestr.nazwa = 'Semestr letni 2008/2009' AND grupa.rodzaj_zajec IN ('c', 'C', 'p', 'P', 'r' ,'R')   -- interesuja nas tylko cwiczenia/cw-prac oraz prac bez wzgledu na poziom
   GROUP BY przedmiot.nazwa, grupa.rodzaj_zajec
   ORDER BY "najwiecej grup" DESC
   LIMIT 1;            -- zakladam blednie, ze to wylacznie jeden pierwszy, czyli ten z najwieksza iloscia [ilosc najlepszych mozna obliczyc podzapytaniem liczacym 'pierwszych' ale niestety czasu brak ;( ]
   
   
   
   
   
   
						 