--
-- PostgreSQL database dump
--

-- Started on 2009-06-23 09:05:22 CEST

SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

SET search_path = public, pg_catalog;

--
-- TOC entry 1813 (class 0 OID 0)
-- Dependencies: 1493
-- Name: dokumenty_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('dokumenty_id_seq', 16, true);


--
-- TOC entry 1814 (class 0 OID 0)
-- Dependencies: 1501
-- Name: osoba_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('osoba_id_seq', 134, true);


--
-- TOC entry 1815 (class 0 OID 0)
-- Dependencies: 1495
-- Name: testament_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('testament_id_seq', 1, false);


--
-- TOC entry 1816 (class 0 OID 0)
-- Dependencies: 1492
-- Name: wydarzenie_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('wydarzenie_id_seq', 71, true);


--
-- TOC entry 1810 (class 0 OID 17796)
-- Dependencies: 1502
-- Data for Name: dane_osobowe; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY dane_osobowe (osoba_id, miejsce_urodzenia, data_urodzenia, plec, aktualny_wiek, aktualny_adres, powod_zgonu, data_smierci) FROM stdin;
1	Walbrzych	1989-02-02	m	\N	ul. Parkowa 11	\N	\N
17	Krakow	\N	k	\N	\N	\N	\N
4	Walbrzych	1997-11-11	k	\N	ul. Hallera 43	\N	\N
5	Krakow	1984-05-19	k	\N	plac Grunwaldzki 2	\N	\N
6	Glogow	1977-02-11	k	\N	ul. Ogrodowa 19	\N	\N
134	Krakow	1975-05-02	k	\N	Ul. Krakowska 11	\N	\N
3	Wroclaw	1944-01-01	m	\N	\N	Wylew	2004-04-02
2	Wroclawek	1944-01-01	k	\N	\N	Zawal serca	1999-11-12
23	Katowice	1925-03-03	m	\N	\N	Tragiczny wypadek	2002-11-11
10	Berlin	\N	k	\N	ul. Niepodleglosci 93	\N	\N
9	Berlin	\N	m	\N	\N	\N	\N
11	Warszawa	\N	m	\N	ul. Krzywa 11	\N	\N
12	Warszawa	\N	m	\N	\N	\N	\N
14	Wroclaw	\N	m	\N	ul. Andresa 5	\N	\N
8	Jelcz-Laskowice	\N	k	\N	\N	Samobojstwo	2007-01-02
20	Walbrzych	1982-07-08	m	\N	ul. Hallera 43	\N	\N
19	Kielce	\N	m	\N	\N	Zalamanie nerwowe	2009-06-06
7	Zielona Gora	\N	m	\N	ul. Joliot Curie	\N	\N
\.


--
-- TOC entry 1808 (class 0 OID 17748)
-- Dependencies: 1499
-- Data for Name: dokumenty; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY dokumenty (id, id_wydarzenia, opis, data_zrobienia, sciezka_do_zdjecia) FROM stdin;
15	70	testowy komentarz	2009-11-02 00:00:00	Akt.doc
16	66	UWAGA: Dokument nie zawiera jeszcze wszystkich waznych podpisow!	2001-10-10 00:00:00	Akt2.doc
\.


--
-- TOC entry 1804 (class 0 OID 17623)
-- Dependencies: 1490
-- Data for Name: osoba; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY osoba (id, imie, nazwisko, pesel, id_ojca, id_matki, testament) FROM stdin;
6	Maria	Kowalska	\N	\N	22	f
23	Rajmund	Malkowski	\N	\N	\N	f
134	Marta	Szczesniak	\N	12	\N	t
11	Edward	Kowalski	\N	3	134	f
25	Piotr	Walewski	\N	\N	\N	f
26	Pawel	Janikowski	\N	\N	\N	f
2	Marianna	Zeromska	69042001250	3	\N	f
14	Witold	Zaruga	\N	\N	\N	f
15	Anna	Zaruga	\N	\N	\N	f
3	Stefan	Zeromski	\N	\N	\N	t
1	Piotr	Walkowski	89020201330	2	10	t
16	Pawel	Walkowski	\N	2	10	f
10	Zdzislawa	Walkowska	\N	\N	\N	t
7	Jan	Kacprowicz	\N	9	\N	t
8	Ewa	Kacprowicz	\N	9	\N	f
20	Jaroslaw	Domanski	\N	2	\N	t
4	Anita	Jasinska	\N	20	5	f
19	Mariusz	Jasinski	\N	20	5	f
9	Mieczyslaw	Zaruga	\N	14	15	f
21	Marek	Zeromski	\N	2	\N	f
12	Marcin	Kaczmarek	\N	21	\N	f
13	Joanna	Kaczmarek	\N	21	\N	f
5	Elzbieta	Domanska	\N	2	6	f
17	Agnieszka	Kaczmarek	\N	14	15	t
22	Jan	Pawlak	\N	\N	\N	f
18	Janina	Kaczmarek	\N	14	22	f
\.


--
-- TOC entry 1807 (class 0 OID 17732)
-- Dependencies: 1498
-- Data for Name: osoba_wydarzenie; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY osoba_wydarzenie (id_osoby, id_wydarzenia, rola_priorytet, rola_pelna_nazwa) FROM stdin;
9	66	0	\N
8	67	0	\N
19	68	0	\N
22	70	0	\N
13	70	2	\N
3	70	1	\N
21	67	2	\N
10	68	1	\N
22	68	1	\N
2	69	0	\N
25	70	1	\N
23	70	1	\N
134	70	2	\N
4	71	0	\N
12	71	0	\N
20	70	1	\N
1	71	2	\N
\.


--
-- TOC entry 1806 (class 0 OID 17685)
-- Dependencies: 1494
-- Data for Name: testament; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY testament (id, id_osoba, wykonano, wysokosc_spadku, data_wykonania, sciezka_tresc) FROM stdin;
\.


--
-- TOC entry 1809 (class 0 OID 17762)
-- Dependencies: 1500
-- Data for Name: testament_spadek; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY testament_spadek (id_testamentu, id_osoby_otrzymujacej, wysokosc) FROM stdin;
\.


--
-- TOC entry 1805 (class 0 OID 17644)
-- Dependencies: 1491
-- Data for Name: wydarzenie; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY wydarzenie (id, miejsce, typ, data) FROM stdin;
66	Wroclawek	0	1999-11-12 00:00:00
67	Jelcz-Laskowice	0	2007-05-01 00:00:00
68	Kielce	0	2009-09-06 00:00:00
69	Berlin	2	2005-11-11 00:00:00
70	Wroclaw	1	1990-01-01 00:00:00
71	Krakow	1	2005-09-11 00:00:00
\.


-- Completed on 2009-06-23 09:05:22 CEST

--
-- PostgreSQL database dump complete
--

