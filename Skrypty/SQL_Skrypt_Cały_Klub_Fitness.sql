USE master;
GO

IF EXISTS (SELECT name FROM sys.databases WHERE name = 'FitnessManagementDB')
BEGIN
    ALTER DATABASE FitnessManagementDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE FitnessManagementDB;
END
GO

CREATE DATABASE FitnessManagementDB;
GO

ALTER DATABASE FitnessManagementDB SET MULTI_USER;
GO
USE FitnessManagementDB
GO
---------------------------------
-- Moduł 1 Tabele Słownikowe: ---
---------------------------------
CREATE TABLE TYP_KARNETU (
    id_typu_karnetu INT IDENTITY(1,1) PRIMARY KEY,
    nazwa VARCHAR(100) NOT NULL,
    cena_bazowa DECIMAL(10,2) NOT NULL,
    czas_trwania_dni INT NOT NULL
);

CREATE TABLE METODA_PLATNOSCI (
    id_metody INT IDENTITY(1,1) PRIMARY KEY,
    nazwa_metody VARCHAR(50) NOT NULL
);

CREATE TABLE STATUS_PLATNOSCI (
    id_statusu INT IDENTITY(1,1) PRIMARY KEY,
    nazwa_statusu VARCHAR(50) NOT NULL
);

CREATE TABLE ZRODLO_PUNKTOW (
    id_zrodla INT IDENTITY(1,1) PRIMARY KEY,
    opis_akcji VARCHAR(100) NOT NULL,
    wartosc_punktowa INT NOT NULL
);

CREATE TABLE KATEGORIA_NAGRODY (
    id_kategorii INT IDENTITY(1,1) PRIMARY KEY,
    nazwa_kategorii VARCHAR(100) NOT NULL
);

CREATE TABLE TYP_ZMIANY (
    id_typu_zmiany INT IDENTITY(1,1) PRIMARY KEY,
    nazwa_zmiany VARCHAR(50) NOT NULL,
    godzina_startu TIME NOT NULL,
    godzina_konca TIME NOT NULL
);

---------------------------------
-- Moduł 2 Tabele Słownikowe: ---
---------------------------------

CREATE TABLE ROLA_SYSTEMOWA (
    id_roli INT IDENTITY(1,1) PRIMARY KEY,
    nazwa VARCHAR(50) NOT NULL
);

CREATE TABLE SPECJALIZACJA (
    id_specjalizacji INT IDENTITY(1,1) PRIMARY KEY,
    nazwa VARCHAR(100) NOT NULL
);

CREATE TABLE PARTIA_CIALA (
    id_partii INT IDENTITY(1,1) PRIMARY KEY,
    nazwa_partii VARCHAR(100) NOT NULL
);

CREATE TABLE WYMAGANY_SPRZET (
    id_sprzetu INT IDENTITY(1,1) PRIMARY KEY,
    nazwa_sprzetu VARCHAR(100) NOT NULL,
    Row_2_Opis VARCHAR(255) NULL, 
    Row_3_Sprawny BIT NOT NULL DEFAULT 1
);

CREATE TABLE KATEGORIA_BADANIA (
    id_kategorii INT IDENTITY(1,1) PRIMARY KEY,
    nazwa_badania VARCHAR(100) NOT NULL,
    jednostka_miary VARCHAR(20) NOT NULL
);

-----------------------------------------
-- Moduł 1 Klient oraz konto (most): ---
-----------------------------------------
CREATE TABLE KONTO_UZYTKOWNIKA (
    id_konta INT IDENTITY(1,1) PRIMARY KEY,
    id_roli INT NOT NULL,
    login VARCHAR(100) NOT NULL UNIQUE,
    haslo VARCHAR(255) NOT NULL,
    FOREIGN KEY (id_roli) REFERENCES ROLA_SYSTEMOWA(id_roli)
);

CREATE TABLE KLIENT (
    Id_klient INT PRIMARY KEY, 
    Imie VARCHAR(100) NOT NULL,
    Nazwisko VARCHAR(100) NOT NULL,
    Telefon VARCHAR(20) NULL,
    FOREIGN KEY (Id_klient) REFERENCES KONTO_UZYTKOWNIKA(id_konta)
);

-----------------------------
-- Moduł 1 Tabele Zależne:---
-----------------------------
CREATE TABLE PROMOCJA (
    id_promocji INT IDENTITY(1,1) PRIMARY KEY,
    id_typu_karnetu INT NOT NULL,
    procent_znizki INT DEFAULT 0,
    data_do DATE,
    FOREIGN KEY (id_typu_karnetu) REFERENCES TYP_KARNETU(id_typu_karnetu)
);

CREATE TABLE ZAKUP_KARNETU (
    id_zakupu INT IDENTITY(1,1) PRIMARY KEY,
    id_klienta INT NOT NULL,
    id_typu_karnetu INT NOT NULL,
    data_zakupu DATETIME DEFAULT GETDATE(),
    data_wygasniecia DATE NOT NULL,
    czy_aktywny BIT DEFAULT 1,
    FOREIGN KEY (id_klienta) REFERENCES KLIENT(Id_klient),
    FOREIGN KEY (id_typu_karnetu) REFERENCES TYP_KARNETU(id_typu_karnetu)
);


CREATE TABLE KARTA_LOJALNOSCIOWA (
    id_karty INT IDENTITY(1,1) PRIMARY KEY,
    id_klienta INT NOT NULL UNIQUE,
    numer_karty VARCHAR(50) NOT NULL UNIQUE,
    suma_punktow INT DEFAULT 0,
    FOREIGN KEY (id_klienta) REFERENCES KLIENT(Id_klient)
);

CREATE TABLE LOG_PUNKTOW (
    id_logu INT IDENTITY(1,1) PRIMARY KEY,
    id_karty INT NOT NULL,
    id_zrodla INT NOT NULL,
    punkty_dodane INT NOT NULL,
    data_operacji DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (id_karty) REFERENCES KARTA_LOJALNOSCIOWA(id_karty),
    FOREIGN KEY (id_zrodla) REFERENCES ZRODLO_PUNKTOW(id_zrodla)
);

CREATE TABLE NAGRODA (
    id_nagrody INT IDENTITY(1,1) PRIMARY KEY,
    id_kategorii INT NOT NULL,
    nazwa_nagrody VARCHAR(150) NOT NULL,
    koszt_punktowy INT NOT NULL,
    stan_magazynowy INT DEFAULT 0,
    FOREIGN KEY (id_kategorii) REFERENCES KATEGORIA_NAGRODY(id_kategorii)
);

CREATE TABLE ODBIOR_NAGRODY (
    id_odbioru INT IDENTITY(1,1) PRIMARY KEY,
    id_klienta INT NOT NULL,
    id_nagrody INT NOT NULL,
    data_odbioru DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (id_klienta) REFERENCES KLIENT(Id_klient),
    FOREIGN KEY (id_nagrody) REFERENCES NAGRODA(id_nagrody)
);

CREATE TABLE LOG_WEJSCIA (
    id_logu_wejscia INT IDENTITY(1,1) PRIMARY KEY,
    id_klienta INT NOT NULL,
    czas_wejscia DATETIME DEFAULT GETDATE(),
    czas_wyjscia DATETIME,
    FOREIGN KEY (id_klienta) REFERENCES KLIENT(Id_klient)
);

CREATE TABLE PRACOWNIK (
    id_pracownika INT IDENTITY(1,1) PRIMARY KEY,
    id_konta INT NOT NULL UNIQUE,
    imie VARCHAR(100) NOT NULL,
    nazwisko VARCHAR(100) NOT NULL,
    stanowisko VARCHAR(100),
    FOREIGN KEY (id_konta) REFERENCES KONTO_UZYTKOWNIKA(id_konta)
);

CREATE TABLE GRAFIK_PRACY (
    id_grafiku INT IDENTITY(1,1) PRIMARY KEY,
    id_pracownika INT NOT NULL,
    id_typu_zmiany INT NOT NULL,
    data_pracy DATE NOT NULL,
    FOREIGN KEY (id_pracownika) REFERENCES PRACOWNIK(id_pracownika),
    FOREIGN KEY (id_typu_zmiany) REFERENCES TYP_ZMIANY(id_typu_zmiany)
);

CREATE TABLE TRANSAKCJA (
    id_transakcji INT IDENTITY(1,1) PRIMARY KEY,
    id_zakupu INT NOT NULL,
    id_metody INT NOT NULL,
    id_statusu INT NOT NULL,
    id_pracownika INT NOT NULL,
    kwota DECIMAL(10,2) NOT NULL,
    data_platnosci DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (id_zakupu) REFERENCES ZAKUP_KARNETU(id_zakupu),
    FOREIGN KEY (id_metody) REFERENCES METODA_PLATNOSCI(id_metody),
    FOREIGN KEY (id_statusu) REFERENCES STATUS_PLATNOSCI(id_statusu),
    FOREIGN KEY (id_pracownika) REFERENCES PRACOWNIK(id_pracownika)
);
-----------------------------
-- Moduł 2 Tabele Zależne:---
-----------------------------
CREATE TABLE TRENER (
    id_trenera INT IDENTITY(1,1) PRIMARY KEY,
    id_konta INT NOT NULL UNIQUE, 
    id_specjalizacji INT NOT NULL,
    imie VARCHAR(100) NOT NULL,
    nazwisko VARCHAR(100) NOT NULL,
    FOREIGN KEY (id_konta) REFERENCES KONTO_UZYTKOWNIKA(id_konta),
    FOREIGN KEY (id_specjalizacji) REFERENCES SPECJALIZACJA(id_specjalizacji)
);

CREATE TABLE CERTYFIKAT (
    id_certyfikatu INT IDENTITY(1,1) PRIMARY KEY,
    id_trenera INT NOT NULL,
    nazwa_kursu VARCHAR(150) NOT NULL,
    numer_certyfikatu VARCHAR(50) NOT NULL,
    data_wydania DATE NOT NULL,
    FOREIGN KEY (id_trenera) REFERENCES TRENER(id_trenera)
);

CREATE TABLE CWICZENIE (
    id_cwiczenia INT IDENTITY(1,1) PRIMARY KEY,
    id_partii INT NOT NULL,
    id_sprzetu INT NOT NULL,
    nazwa_cwiczenia VARCHAR(150) NOT NULL,
    FOREIGN KEY (id_partii) REFERENCES PARTIA_CIALA(id_partii),
    FOREIGN KEY (id_sprzetu) REFERENCES WYMAGANY_SPRZET(id_sprzetu)
);

CREATE TABLE WPIS_W_KARCIE_ZDROWIA (
    id_wpisu INT IDENTITY(1,1) PRIMARY KEY,
    id_klienta INT NOT NULL,
    id_kategorii INT NOT NULL,
    wartosc_pomiaru DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (id_klienta) REFERENCES KLIENT(Id_klient),
    FOREIGN KEY (id_kategorii) REFERENCES KATEGORIA_BADANIA(id_kategorii)
);

CREATE TABLE PLAN_TRENINGOWY (
    id_planu INT IDENTITY(1,1) PRIMARY KEY,
    id_klienta INT NOT NULL,
    id_trenera INT NOT NULL,
    nazwa_planu VARCHAR(150) NOT NULL,
    FOREIGN KEY (id_klienta) REFERENCES KLIENT(Id_klient),
    FOREIGN KEY (id_trenera) REFERENCES TRENER(id_trenera)
);

CREATE TABLE SESJA_TRENINGOWA (
    id_sesji INT IDENTITY(1,1) PRIMARY KEY,
    id_planu INT NOT NULL,
    nazwa_sesji VARCHAR(100) NOT NULL,
    FOREIGN KEY (id_planu) REFERENCES PLAN_TRENINGOWY(id_planu)
);

CREATE TABLE POZYCJA_W_SESJI (
    id_pozycji INT IDENTITY(1,1) PRIMARY KEY,
    id_sesji INT NOT NULL,
    id_cwiczenia INT NOT NULL,
    liczba_serii INT NOT NULL,
    liczba_powtorzen INT NOT NULL,
    FOREIGN KEY (id_sesji) REFERENCES SESJA_TRENINGOWA(id_sesji),
    FOREIGN KEY (id_cwiczenia) REFERENCES CWICZENIE(id_cwiczenia)
);

CREATE TABLE DZIENNIK_AKTYWNOSCI (
    id_dziennika INT IDENTITY(1,1) PRIMARY KEY,
    id_klienta INT NOT NULL,
    id_sesji INT NOT NULL, 
    data_treningu DATE NOT NULL,
    FOREIGN KEY (id_klienta) REFERENCES KLIENT(Id_klient),
    FOREIGN KEY (id_sesji) REFERENCES SESJA_TRENINGOWA(id_sesji)
);
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

---USUNIĘCIE UŻYTKOWNIKÓW ORAZ RÓL
USE FitnessManagementDB;
GO

-- Usuwanie użytkowników z bazy danych
IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'Uzytkownik_Jan_Kowalski')
    DROP USER [Uzytkownik_Jan_Kowalski];

IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'Uzytkownik_Anna_Nowak')
    DROP USER [Uzytkownik_Anna_Nowak];

IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'Uzytkownik_Marek_Pracownik')
    DROP USER [Uzytkownik_Marek_Pracownik];

IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'Uzytkownik_Tomasz_Trener')
    DROP USER [Uzytkownik_Tomasz_Trener];

IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'Uzytkownik_Administrator_Systemu')
    DROP USER [Uzytkownik_Administrator_Systemu];
GO

-- Usuwanie ról bazodanowych
IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'Role_Administrator' AND type = 'R')
    DROP ROLE Role_Administrator;

IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'Role_Pracownik' AND type = 'R')
    DROP ROLE Role_Pracownik;

IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'Role_Trener' AND type = 'R')
    DROP ROLE Role_Trener;

IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'Role_Klient' AND type = 'R')
    DROP ROLE Role_Klient;
GO

-- USUNIĘCIE LOGINÓW SERWEROWYCH z master
USE master;
GO

IF EXISTS (SELECT * FROM sys.server_principals WHERE name = 'j.kowalski')
    DROP LOGIN [j.kowalski];

IF EXISTS (SELECT * FROM sys.server_principals WHERE name = 'a.nowak')
    DROP LOGIN [a.nowak];

IF EXISTS (SELECT * FROM sys.server_principals WHERE name = 'm.pracownik')
    DROP LOGIN [m.pracownik];

IF EXISTS (SELECT * FROM sys.server_principals WHERE name = 't.trener')
    DROP LOGIN [t.trener];

IF EXISTS (SELECT * FROM sys.server_principals WHERE name = 'admin_fitness')
    DROP LOGIN [admin_fitness];
GO


USE FitnessManagementDB;
GO

-- Tworzenie ról bazodanowych
CREATE ROLE Role_Administrator;
CREATE ROLE Role_Pracownik;
CREATE ROLE Role_Trener;
CREATE ROLE Role_Klient;
GO

-- PRZYPISANIE UPRAWNIEŃ DLA ADMINISTRATORA (Pełny dostęp)
GRANT CONTROL TO Role_Administrator;

-- PRZYPISANIE UPRAWNIEŃ DLA PRACOWNIKA RECEPCJI
GRANT SELECT, INSERT, UPDATE ON KLIENT TO Role_Pracownik;
GRANT SELECT, INSERT, UPDATE ON ZAKUP_KARNETU TO Role_Pracownik;
GRANT SELECT, INSERT, UPDATE ON TRANSAKCJA TO Role_Pracownik;
GRANT SELECT, INSERT ON LOG_WEJSCIA TO Role_Pracownik;
GRANT SELECT ON TYP_KARNETU TO Role_Pracownik;
GRANT SELECT ON GRAFIK_PRACY TO Role_Pracownik;

-- PRZYPISANIE UPRAWNIEŃ DLA TRENERA
GRANT SELECT ON KLIENT TO Role_Trener;
GRANT SELECT, INSERT, UPDATE ON PLAN_TRENINGOWY TO Role_Trener;
GRANT SELECT, INSERT, UPDATE ON SESJA_TRENINGOWA TO Role_Trener;
GRANT SELECT, INSERT, UPDATE ON POZYCJA_W_SESJI TO Role_Trener;
GRANT SELECT, INSERT ON WPIS_W_KARCIE_ZDROWIA TO Role_Trener;
GRANT SELECT ON CWICZENIE TO Role_Trener;

-- PRZYPISANIE UPRAWNIEŃ DLA KLIENTA (Tylko odczyt własnych danych/ofert)
GRANT SELECT ON TYP_KARNETU TO Role_Klient;
GRANT SELECT ON PROMOCJA TO Role_Klient;
GRANT SELECT ON NAGRODA TO Role_Klient;
GO
USE master;
GO

-- 1. Jan Kowalski (Klient)
CREATE LOGIN [j.kowalski] WITH PASSWORD = 'haslo123', DEFAULT_DATABASE = FitnessManagementDB;
-- 2. Anna Nowak (Klient)
CREATE LOGIN [a.nowak] WITH PASSWORD = 'haslo456', DEFAULT_DATABASE = FitnessManagementDB;
-- 3. Marek Pracownik (Pracownik)
CREATE LOGIN [m.pracownik] WITH PASSWORD = 'pracownik!', DEFAULT_DATABASE = FitnessManagementDB;
-- 4. Tomasz Trener (Trener)
CREATE LOGIN [t.trener] WITH PASSWORD = 'trener2024', DEFAULT_DATABASE = FitnessManagementDB;
-- 5. Administrator Systemu
CREATE LOGIN [admin_fitness] WITH PASSWORD = 'AdminStrongPass123!', DEFAULT_DATABASE = FitnessManagementDB;
GO

USE FitnessManagementDB;
GO

CREATE USER [Uzytkownik_Jan_Kowalski] FOR LOGIN [j.kowalski];
CREATE USER [Uzytkownik_Anna_Nowak] FOR LOGIN [a.nowak];
CREATE USER [Uzytkownik_Marek_Pracownik] FOR LOGIN [m.pracownik];
CREATE USER [Uzytkownik_Tomasz_Trener] FOR LOGIN [t.trener];
CREATE USER [Uzytkownik_Administrator_Systemu] FOR LOGIN [admin_fitness];
GO

-- PRZYPISANIE UŻYTKOWNIKÓW DO RÓL
ALTER ROLE Role_Klient ADD MEMBER [Uzytkownik_Jan_Kowalski];
ALTER ROLE Role_Klient ADD MEMBER [Uzytkownik_Anna_Nowak];
ALTER ROLE Role_Pracownik ADD MEMBER [Uzytkownik_Marek_Pracownik];
ALTER ROLE Role_Trener ADD MEMBER [Uzytkownik_Tomasz_Trener];
ALTER ROLE Role_Administrator ADD MEMBER [Uzytkownik_Administrator_Systemu];
GO
