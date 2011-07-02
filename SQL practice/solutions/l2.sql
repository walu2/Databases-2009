#221135
Lista 2
Piotr Walkowski

zad1.

zad2.

SELECT DISTINCT uzytkownik.kod_uz as "id. pracownika", nazwisko, przedmiot.nazwa FROM uzytkownik
FULL OUTER JOIN grupa ON (uzytkownik.kod_uz = grupa.kod_uz)
NATURAL JOIN przedmiot_semestr NATURAL JOIN przedmiot
WHERE semestr = 0
ORDER BY nazwisko, przedmiot.nazwa;


zad3

// przedmioty z semestru 2008/2009

SELECT DISTINCT przedmiot.kod_przed, przedmiot.nazwa
FROM przedmiot
INNER JOIN przedmiot_semestr USING (kod_przed)
INNER JOIN semestr USING (semestr_id)
INNER JOIN grupa  USING (kod_przed_sem)
LEFT  JOIN wybor USING (kod_grupy)
WHERE semestr.nazwa = 'Semestr letni 2008/2009'

// analogicznie z 2007/2008

SELECT DISTINCT przedmiot.nazwa
FROM przedmiot
INNER JOIN przedmiot_semestr USING (kod_przed)
INNER JOIN semestr USING (semestr_id)
INNER JOIN grupa  USING (kod_przed_sem)
LEFT  JOIN wybor USING (kod_grupy)
WHERE semestr.nazwa = 'Semestr letni 2007/2008'

wersja a)
SELECT DISTINCT przedmiot.nazwa
FROM przedmiot
INNER JOIN przedmiot_semestr USING (kod_przed)
INNER JOIN semestr USING (semestr_id)
INNER JOIN grupa  USING (kod_przed_sem)
LEFT  JOIN wybor USING (kod_grupy)
WHERE semestr.nazwa = 'Semestr letni 2008/2009' 
AND przedmiot.nazwa NOT IN (SELECT DISTINCT przedmiot.nazwa
FROM przedmiot
INNER JOIN przedmiot_semestr USING (kod_przed)
INNER JOIN semestr USING (semestr_id)
INNER JOIN grupa  USING (kod_przed_sem)
LEFT  JOIN wybor USING (kod_grupy)
WHERE semestr.nazwa = 'Semestr letni 2007/2008')

wersja c)
(SELECT DISTINCT przedmiot.nazwa
FROM przedmiot
INNER JOIN przedmiot_semestr USING (kod_przed)
INNER JOIN semestr USING (semestr_id)
INNER JOIN grupa  USING (kod_przed_sem)
LEFT  JOIN wybor USING (kod_grupy)
WHERE semestr.nazwa = 'Semestr letni 2008/2009'
)
EXCEPT
(
SELECT DISTINCT przedmiot.nazwa
FROM przedmiot
INNER JOIN przedmiot_semestr USING (kod_przed)
INNER JOIN semestr USING (semestr_id)
INNER JOIN grupa  USING (kod_przed_sem)
LEFT  JOIN wybor USING (kod_grupy)
WHERE semestr.nazwa = 'Semestr letni 2007/2008'
)

zad4

(SELECT kod_grupy
FROM grupa
INNER JOIN przedmiot ON (grupa.kod_przed = przedmiot.kod_przed)
INNER JOIN przedmiot_semestr ON (grupa.kod_przed_sem = przedmiot_semestr.kod_przed_sem)
INNER JOIN wybor ON (grupa.kod_grupy = wybor.kod_grupy)
INNER JOIN uzytkownik ON (wybor.kod_uz = uzytkownik.kod_uz)
WHERE uzytkownik.imie = 'Piotr' AND uzytkownik.nazwisko = 'Walkowski' AND przedmiot.nazwa = 'Bazy danych' AND grupa.rodzaj_zajec = 'r') 

powyzsze zapytanie generuje kod mojej grupy

SELECT uzytkownik.nazwisko as "Nazwiska z mojej grupy"
FROM uzytkownik
INNER JOIN wybor ON (wybor.kod_uz = uzytkownik.kod_uz)
WHERE uzytkownik.semestr > 0 AND uzytkownik.nazwisko != 'Walkowski'			/* do mojej grupy nastepujace osoby (nie liczac juz mnie) */
AND wybor.kod_grupy 
=
(SELECT grupa.kod_grupy
FROM grupa
INNER JOIN przedmiot_semestr ON (grupa.kod_przed_sem = przedmiot_semestr.kod_przed_sem)
INNER JOIN przedmiot ON (przedmiot_semestr.kod_przed = przedmiot.kod_przed)
INNER JOIN wybor ON (grupa.kod_grupy = wybor.kod_grupy)
INNER JOIN uzytkownik ON (wybor.kod_uz = uzytkownik.kod_uz)
WHERE uzytkownik.imie = 'Piotr' AND uzytkownik.nazwisko = 'Walkowski' AND przedmiot.nazwa = 'Bazy danych' AND grupa.rodzaj_zajec = 'r')  
ORDER BY uzytkownik.nazwisko




zad5.

a)
 SELECT count(*) 
 FROM uzytkownik
 WHERE semestr = 3;
 
b)
kod semestru:

SELECT count(przedmiot.punkty) as "Lacznie"
FROM przedmiot
INNER JOIN przedmiot_semestr ON (przedmiot_semestr.kod_przed = przedmiot.kod_przed)
INNER JOIN grupa USING(kod_przed_sem)
WHERE przedmiot_semestr.semestr_id = (SELECT semestr_id FROM semestr 
								      WHERE nazwa = 'Semestr letni 2008/2009')	
AND grupa.rodzaj_zajec = 'w'				


c)

SELECT grupa.kod_grupy
FROM grupa
INNER JOIN przedmiot_semestr USING(kod_przed_sem)
INNER JOIN przedmiot USING(kod_przed)
WHERE przedmiot_semestr.semestr_id = (SELECT semestr_id FROM semestr 
								      WHERE nazwa = 'Semestr zimowy 2007/2008')	
					
powyzsze zap. zwraca wszystkie grupy z konkretnego semestru ...
					
SELECT Min(wybor.data) as "najwszesniejszy"
FROM wybor
WHERE kod_grupy IN (SELECT grupa.kod_grupy
FROM grupa
INNER JOIN przedmiot_semestr USING(kod_przed_sem)
INNER JOIN przedmiot USING(kod_przed)
WHERE przedmiot_semestr.semestr_id = (SELECT semestr_id FROM semestr 
								      WHERE nazwa = 'Semestr zimowy 2007/2008')	
					)
					
SELECT Max(wybor.data) as "najpozniejszy"
FROM wybor
WHERE kod_grupy IN (SELECT grupa.kod_grupy
FROM grupa
INNER JOIN przedmiot_semestr USING(kod_przed_sem)
INNER JOIN przedmiot USING(kod_przed)
WHERE przedmiot_semestr.semestr_id = (SELECT semestr_id FROM semestr 
								      WHERE nazwa = 'Semestr zimowy 2007/2008')
					)
	
	  
d)

ponizsze zapytanie wypisuje kody grup zeszlorocznych cwiczenio-pracowni

SELECT kod_grupy
FROM grupa
INNER JOIN przedmiot_semestr USING(kod_przed_sem)
INNER JOIN przedmiot USING(kod_przed)
WHERE 
	  przedmiot_semestr.semestr_id = (SELECT semestr_id FROM semestr 
								      WHERE nazwa = 'Semestr letni 2007/2008')	
      AND przedmiot.nazwa = 'Bazy danych'
	  AND grupa.rodzaj_zajec = 'r'
	  
	  
SELECT COUNT(DISTINCT kod_uz) 
FROM wybor
WHERE kod_grupy IN (SELECT kod_grupy
FROM grupa
INNER JOIN przedmiot_semestr USING(kod_przed_sem)
INNER JOIN przedmiot USING(kod_przed)
WHERE 
	  przedmiot_semestr.semestr_id = (SELECT semestr_id FROM semestr 
								      WHERE nazwa = 'Semestr letni 2007/2008')	
      AND przedmiot.nazwa = 'Bazy danych'
	  AND grupa.rodzaj_zajec = 'r')

	  
									  



