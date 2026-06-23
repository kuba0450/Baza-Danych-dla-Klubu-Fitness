USE FitnessManagementDB
GO
--------------------------------------------------------------------------------
-- MODUŁ 1: TABELE SŁOWNIKOWE
--------------------------------------------------------------------------------

INSERT INTO TYP_KARNETU (nazwa, cena_bazowa, czas_trwania_dni) VALUES 
('Miesięczny Open', 150.00, 30),
('Student 30 dni', 110.00, 30),
('Poranny (do 15:00)', 90.00, 30),
('Roczny VIP', 1400.00, 365);

INSERT INTO METODA_PLATNOSCI (nazwa_metody) VALUES 
('Karta Płatnicza'),
('Gotówka'),
('Przelew'),
('BLIK');

INSERT INTO STATUS_PLATNOSCI (nazwa_statusu) VALUES 
('Opłacona'),
('Oczekująca'),
('Anulowana'),
('Zwrócona');

INSERT INTO ZRODLO_PUNKTOW (opis_akcji, wartosc_punktowa) VALUES 
('Wejście na siłownię', 10),
('Zakup karnetu', 50),
('Urodziny klienta', 100),
('Polecenie nowego członka', 200);

INSERT INTO KATEGORIA_NAGRODY (nazwa_kategorii) VALUES 
('Napoje i Suplementy'),
('Odzież sportowa'),
('Akcesoria'),
('Darmowe Usługi');

INSERT INTO TYP_ZMIANY (nazwa_zmiany, godzina_startu, godzina_konca) VALUES 
('Poranna', '06:00:00', '14:00:00'),
('Popołudniowa', '14:00:00', '22:00:00'),
('Nocna', '22:00:00', '06:00:00');


--------------------------------------------------------------------------------
-- MODUŁ 2: TABELE SŁOWNIKOWE
--------------------------------------------------------------------------------

INSERT INTO ROLA_SYSTEMOWA (nazwa) VALUES 
('Administrator'),
('Pracownik Recepcji'),
('Trener'),
('Klient');

INSERT INTO SPECJALIZACJA (nazwa) VALUES 
('Trening Siłowy'),
('Kulturystyka'),
('Joga i Pilates'),
('Crossfit');

INSERT INTO PARTIA_CIALA (nazwa_partii) VALUES 
('Klatka Piersiowa'),
('Plecy'),
('Nogi'),
('Ramiona');

INSERT INTO WYMAGANY_SPRZET (nazwa_sprzetu, Row_2_Opis, Row_3_Sprawny) VALUES 
('Hantle', 'Zestaw hantli gumowanych', 1),
('Sztanga Olimpijska', 'Gryf 20kg', 1),
('Bieżnia', 'Model Matrix T5', 1),
('Maszyna Smitha', 'Prowadnica liniowa', 1);

INSERT INTO KATEGORIA_BADANIA (nazwa_badania, jednostka_miary) VALUES 
('Waga ciała', 'kg'),
('Poziom tkanki tłuszczowej', '%'),
('Obwód pasa', 'cm'),
('Tętno spoczynkowe', 'bpm');


--------------------------------------------------------------------------------
-- KONTA UŻYTKOWNIKÓW, KLIENCI I PRACOWNICY
--------------------------------------------------------------------------------

-- Zakładamy ID ról: 1-Admin, 2-Pracownik, 3-Trener, 4-Klient
INSERT INTO KONTO_UZYTKOWNIKA (id_roli, login, haslo) VALUES 
(4, 'j.kowalski', 'haslo123'), -- ID 1
(4, 'a.nowak', 'haslo456'),    -- ID 2
(2, 'm.pracownik', 'pracownik!'), -- ID 3
(3, 't.trener', 'trener2024'); -- ID 4

INSERT INTO KLIENT (Id_klient, Imie, Nazwisko, Telefon) VALUES 
(1, 'Jan', 'Kowalski', '500-600-700'),
(2, 'Anna', 'Nowak', '600-700-800');

INSERT INTO PRACOWNIK (id_konta, imie, nazwisko, stanowisko) VALUES 
(3, 'Marek', 'Recepcyjny', 'Recepcjonista'),
(4, 'Tomasz', 'Trenerowski', 'Trener Personalny Senior');


--------------------------------------------------------------------------------
-- MODUŁ 1: TABELE ZALEŻNE
--------------------------------------------------------------------------------

INSERT INTO PROMOCJA (id_typu_karnetu, procent_znizki, data_do) VALUES 
(2, 15, '2026-12-31'),
(4, 10, '2026-06-30');

INSERT INTO ZAKUP_KARNETU (id_klienta, id_typu_karnetu, data_zakupu, data_wygasniecia, czy_aktywny) VALUES 
(1, 1, GETDATE(), DATEADD(day, 30, GETDATE()), 1),
(2, 2, GETDATE(), DATEADD(day, 30, GETDATE()), 1);

INSERT INTO KARTA_LOJALNOSCIOWA (id_klienta, numer_karty, suma_punktow) VALUES 
(1, 'CARD-001', 50),
(2, 'CARD-002', 100);

INSERT INTO LOG_PUNKTOW (id_karty, id_zrodla, punkty_dodane, data_operacji) VALUES 
(1, 2, 50, GETDATE()),
(2, 3, 100, GETDATE());

INSERT INTO NAGRODA (id_kategorii, nazwa_nagrody, koszt_punktowy, stan_magazynowy) VALUES 
(1, 'Izotonik 0.5l', 30, 50),
(3, 'Ręcznik z logo', 150, 10),
(4, 'Trening wprowadzający', 0, 999);

INSERT INTO ODBIOR_NAGRODY (id_klienta, id_nagrody, data_odbioru) VALUES 
(1, 1, GETDATE());

INSERT INTO LOG_WEJSCIA (id_klienta, czas_wejscia, czas_wyjscia) VALUES 
(1, DATEADD(hour, -1, GETDATE()), GETDATE()),
(2, GETDATE(), NULL);

INSERT INTO GRAFIK_PRACY (id_pracownika, id_typu_zmiany, data_pracy) VALUES 
(1, 1, '2026-05-01'),
(1, 2, '2026-05-02');

INSERT INTO TRANSAKCJA (id_zakupu, id_metody, id_statusu, id_pracownika, kwota, data_platnosci) VALUES 
(1, 1, 1, 1, 150.00, GETDATE()),
(2, 4, 1, 1, 93.50, GETDATE());


--------------------------------------------------------------------------------
-- MODUŁ 2: TABELE ZALEŻNE
--------------------------------------------------------------------------------

INSERT INTO TRENER (id_konta, id_specjalizacji, imie, nazwisko) VALUES 
(4, 1, 'Tomasz', 'Trenerowski');

INSERT INTO CERTYFIKAT (id_trenera, nazwa_kursu, numer_certyfikatu, data_wydania) VALUES 
(1, 'Instruktor Kulturystyki PZKFiTS', 'CERT/2023/001', '2023-01-15'),
(1, 'Dietetyka Sportowa Level 1', 'DIET/99/A', '2024-05-20');

INSERT INTO CWICZENIE (id_partii, id_sprzetu, nazwa_cwiczenia) VALUES 
(1, 2, 'Wyciskanie sztangi na ławce poziomej'),
(3, 2, 'Przysiady ze sztangą'),
(2, 1, 'Wiosłowanie hantlem w opadzie');

INSERT INTO WPIS_W_KARCIE_ZDROWIA (id_klienta, id_kategorii, wartosc_pomiaru) VALUES 
(1, 1, 85.50),
(1, 2, 18.20),
(2, 1, 60.00);

INSERT INTO PLAN_TRENINGOWY (id_klienta, id_trenera, nazwa_planu) VALUES 
(1, 1, 'Budowa Masy - Jan K.'),
(2, 1, 'Redukcja i Kondycja');

INSERT INTO SESJA_TRENINGOWA (id_planu, nazwa_sesji) VALUES 
(1, 'Dzień A - Push'),
(1, 'Dzień B - Pull'),
(2, 'Full Body Workout');

INSERT INTO POZYCJA_W_SESJI (id_sesji, id_cwiczenia, liczba_serii, liczba_powtorzen) VALUES 
(1, 1, 4, 10),
(1, 2, 3, 12),
(2, 3, 4, 8);

INSERT INTO DZIENNIK_AKTYWNOSCI (id_klienta, id_sesji, data_treningu) VALUES 
(1, 1, '2026-04-28'),
(1, 2, '2026-04-30');
go
use master 
go