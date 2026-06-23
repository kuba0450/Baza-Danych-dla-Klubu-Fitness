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
