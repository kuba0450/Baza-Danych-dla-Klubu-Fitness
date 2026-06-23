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
