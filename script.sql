--DROP

--STERGEREA INDEXURILOR SUPLIMENTALE
DROP INDEX FACTURI_sed_elev_UQ;
DROP INDEX SEDINTE_link_ora_UQ;
DROP INDEX SEDINTE_sala_ora_UQ;

--STERGEREA TABELULUI FACTURI
DROP TABLE FACTURI;

--STERGEREA TABELULUI ELEVI
DROP TABLE ELEVI;

--STERGEREA TABELULUI SEDINTE
DROP TABLE SEDINTE;

--STERGEREA TABELULUI ANGAJATI
DROP TABLE ANGAJATI;

--STERGEREA TABELULUI JOBURI
DROP TABLE JOBURI;

--STERGEREA TABELULUI SALI
DROP TABLE SALI;

--STERGEREA TABELULUI LOCATII
DROP TABLE LOCATII;

--STERGEREA TABELULUI ORASE
DROP TABLE ORASE;

--CREAREA TABELELOR

-- CREARE TABEL ORASE
CREATE TABLE ORASE (
    oras_id NUMBER(5, 0) 
        CONSTRAINT ORASE_ORAS_ID_PK PRIMARY KEY,
    denumire_oras VARCHAR2(30 byte) 
        CONSTRAINT ORASE_denumire_NN NOT NULL,
    judet VARCHAR2(2 byte)
        CONSTRAINT ORASE_judet_NN NOT NULL
);

-- CREARE TABEL LOCATII
CREATE TABLE LOCATII (
    locatie_id NUMBER(5, 0)
        CONSTRAINT LOCATII_LOC_ID_PK PRIMARY KEY,
    strada VARCHAR2(30 byte)
        CONSTRAINT LOCATII_strada_NN NOT NULL,
    numar_locatie NUMBER(4, 0)
        CONSTRAINT LOCATII_numar_NN NOT NULL,
    bloc_numar VARCHAR2(5 byte),
    oras_id NUMBER(5, 0)
        CONSTRAINT LOCATII_oras_id_FK REFERENCES ORASE(oras_id) 
        ON DELETE CASCADE
        CONSTRAINT LOCATII_oras_id_NN NOT NULL
);

-- CREARE TABEL SALI
CREATE TABLE SALI (
    sala_id NUMBER(5, 0) 
        CONSTRAINT SALI_SALA_ID_PK PRIMARY KEY,
    etaj NUMBER(2, 0)
        CONSTRAINT SALI_etaj_NN NOT NULL,
    numar_sala NUMBER(3, 0)
        CONSTRAINT SALI_numar_NN NOT NULL,
    locatie_id NUMBER(5, 0)
        CONSTRAINT SALI_locatie_id_FK REFERENCES LOCATII(locatie_id)
        ON DELETE CASCADE
        CONSTRAINT SALI_locatie_id_NN NOT NULL,
    tip VARCHAR2(25 byte) 
        DEFAULT 'sala de clasa'
        CONSTRAINT SALI_tip_CK CHECK (tip in ('laborator informatica', 'laborator stiinte', 'sala de clasa'))

); 


-- CREARE TABEL JOBURI
CREATE TABLE JOBURI (
    job_id NUMBER(5, 0)
        CONSTRAINT JOBURI_JOB_ID_PK PRIMARY KEY,
    denumire_job VARCHAR2(15 BYTE)
        CONSTRAINT JOBURI_denumire_NN NOT NULL,
    materie_predata VARCHAR2(20 byte)
        CONSTRAINT JOBURI_materie_CK CHECK (materie_predata is null 
        or materie_predata in ('informatica', 'matematica', 'geografie', 'istorie', 'limba romana', 'limba engleza', 'limba franceza', 'fizica', 'chimie', 'biologie')),
    salariu_minim NUMBER(8, 2),
    salariu_maxim NUMBER(8, 2),
    CONSTRAINT JOBURI_den_mat_UQ UNIQUE(denumire_job, materie_predata)
);


-- CREARE TABEL ANGAJATI
CREATE TABLE ANGAJATI (
    CNP VARCHAR2(13 byte)
        CONSTRAINT ANGAJATI_CNP_PK PRIMARY KEY
        CONSTRAINT ANGAJATI_CNP_CK CHECK (
            length(CNP) = 13 
            and translate(CNP, 'x0123456789', 'x') is null
            --and to_date(substr(CNP, 2, 6), 'yymmdd') is not null
            and to_number(substr(CNP, 13, 1)) = 
                case
                    when mod(to_number(substr(CNP, 1, 1)) * 2 +
                             to_number(substr(CNP, 2, 1)) * 7 +
                             to_number(substr(CNP, 3, 1)) * 9 +
                             to_number(substr(CNP, 4, 1)) * 1 +
                             to_number(substr(CNP, 5, 1)) * 4 +
                             to_number(substr(CNP, 6, 1)) * 6 +
                             to_number(substr(CNP, 7, 1)) * 3 +
                             to_number(substr(CNP, 8, 1)) * 5 +
                             to_number(substr(CNP, 9, 1)) * 8 +
                             to_number(substr(CNP, 10, 1)) * 2 +
                             to_number(substr(CNP, 11, 1)) * 7 +
                             to_number(substr(CNP, 12, 1)) * 9, 
                             11
                             ) = 10  then 1
                    else mod(to_number(substr(CNP, 1, 1)) * 2 +
                             to_number(substr(CNP, 2, 1)) * 7 +
                             to_number(substr(CNP, 3, 1)) * 9 +
                             to_number(substr(CNP, 4, 1)) * 1 +
                             to_number(substr(CNP, 5, 1)) * 4 +
                             to_number(substr(CNP, 6, 1)) * 6 +
                             to_number(substr(CNP, 7, 1)) * 3 +
                             to_number(substr(CNP, 8, 1)) * 5 +
                             to_number(substr(CNP, 9, 1)) * 8 +
                             to_number(substr(CNP, 10, 1)) * 2 +
                             to_number(substr(CNP, 11, 1)) * 7 +
                             to_number(substr(CNP, 12, 1)) * 9, 
                             11
                             )
                end
            ),
        nume_angajat VARCHAR2(20 BYTE)
            CONSTRAINT ANGAJATI_nume_NN NOT NULL,
        prenume_angajat VARCHAR2(20 BYTE)
            CONSTRAINT ANGAJATI_prenume_NN NOT NULL,
        data_angajarii DATE
            CONSTRAINT ANGAJATI_date_NN NOT NULL,
        salariu NUMBER(8, 2),
        numar_telefon VARCHAR2(10 BYTE)
            CONSTRAINT ANGAJATI_telefon_NN NOT NULL
            CONSTRAINT ANGAJATI_telefon_UQ UNIQUE,
        job_id NUMBER(5, 0)
            CONSTRAINT ANGAJATI_job_id_FK REFERENCES JOBURI(job_id)
            ON DELETE CASCADE
            CONSTRAINT ANGAJATI_job_id_NN NOT NULL 
);

--CREAREA TABEL ELEVI
CREATE TABLE ELEVI (
    CNP VARCHAR2(13 byte)
        CONSTRAINT ELEVI_CNP_PK PRIMARY KEY
        CONSTRAINT ELEVI_CNP_CK CHECK (
            length(CNP) = 13 
            and translate(CNP, 'x0123456789', 'x') is null
            --and to_date(substr(CNP, 2, 6), 'yymmdd') is not null
            and to_number(substr(CNP, 13, 1)) = 
                case
                    when mod(to_number(substr(CNP, 1, 1)) * 2 +
                             to_number(substr(CNP, 2, 1)) * 7 +
                             to_number(substr(CNP, 3, 1)) * 9 +
                             to_number(substr(CNP, 4, 1)) * 1 +
                             to_number(substr(CNP, 5, 1)) * 4 +
                             to_number(substr(CNP, 6, 1)) * 6 +
                             to_number(substr(CNP, 7, 1)) * 3 +
                             to_number(substr(CNP, 8, 1)) * 5 +
                             to_number(substr(CNP, 9, 1)) * 8 +
                             to_number(substr(CNP, 10, 1)) * 2 +
                             to_number(substr(CNP, 11, 1)) * 7 +
                             to_number(substr(CNP, 12, 1)) * 9, 
                             11
                             ) = 10  then 1
                    else mod(to_number(substr(CNP, 1, 1)) * 2 +
                             to_number(substr(CNP, 2, 1)) * 7 +
                             to_number(substr(CNP, 3, 1)) * 9 +
                             to_number(substr(CNP, 4, 1)) * 1 +
                             to_number(substr(CNP, 5, 1)) * 4 +
                             to_number(substr(CNP, 6, 1)) * 6 +
                             to_number(substr(CNP, 7, 1)) * 3 +
                             to_number(substr(CNP, 8, 1)) * 5 +
                             to_number(substr(CNP, 9, 1)) * 8 +
                             to_number(substr(CNP, 10, 1)) * 2 +
                             to_number(substr(CNP, 11, 1)) * 7 +
                             to_number(substr(CNP, 12, 1)) * 9, 
                             11
                             )
                end
            ),
        nume_elev VARCHAR2(20 BYTE)
            CONSTRAINT ELEVI_nume_NN NOT NULL,
        prenume_elev VARCHAR2(20 BYTE)
            CONSTRAINT ELEVI_prenume_NN NOT NULL,
        anul_inscrierii DATE,
        numar_telefon_parinte VARCHAR2(10 BYTE)
            CONSTRAINT ELEVI_telefon_NN NOT NULL
);


--CREARE TABEL SEDINTE
CREATE TABLE SEDINTE (
    sedinta_id NUMBER(5, 0)
        CONSTRAINT SEDINTE_SED_ID_PK PRIMARY KEY,
    sed_online VARCHAR2(1 BYTE)
        CONSTRAINT SEDINTE_online_CK CHECK (sed_online in ('Y', 'N'))
        CONSTRAINT SEDINTE_online_NN NOT NULL,
    link_meet VARCHAR2(40 BYTE),
    data_ora DATE
        CONSTRAINT SEDINTE_ora_NN NOT NULL
        CONSTRAINT SEDINTE_ora_CK CHECK (
            to_number(to_char(data_ora, 'hh24')) between 8 and 20 
            and to_char(data_ora, 'mi:ss') = '00:00'
            ),
    pret NUMBER(5, 2)
        CONSTRAINT SEDINTE_pret_NN NOT NULL,
    sala_id NUMBER(5, 0)
        CONSTRAINT SEDINTE_sala_id_FK REFERENCES SALI(sala_id)
        ON DELETE SET NULL,
    profesor VARCHAR2(13 BYTE)
        CONSTRAINT SEDINTE_profesor_FK REFERENCES ANGAJATI(CNP)
        ON DELETE CASCADE
        CONSTRAINT SEDINTE_profesor_NN NOT NULL,
    
    CONSTRAINT SEDINTE_profesor_ora_UQ UNIQUE (profesor, data_ora)
);

--ADAUGAREA CONSTRANGERII DE UNIQUE PE COLOANELE (data_ora, sala_id) DOAR DACA
--SALA_ID NU E NULL
CREATE UNIQUE INDEX SEDINTE_sala_ora_UQ ON SEDINTE (
    case
        when sala_id is not null
        then sala_id
        else null
    end,
    case 
        when sala_id is not null
        then data_ora
        else null
    end
);

--ADAUGAREA CONSTRANGERII DE UNIQUE PE COLOANELE (data_ora, link_meet) DOAR DACA
--LINK_MEET NU E NULL
CREATE UNIQUE INDEX SEDINTE_link_ora_UQ ON SEDINTE (
    case 
        when link_meet is not null
        then link_meet
        else null
    end,
    case 
        when link_meet is not null
        then data_ora
        else null
    end
);

--CREARE TABEL FACTURI
CREATE TABLE FACTURI (
    factura_id NUMBER(5, 0)
        CONSTRAINT FACTURI_FAC_ID_PK PRIMARY KEY,
    sedinta_id NUMBER(5, 0)
        CONSTRAINT FACTURI_sed_id_FK REFERENCES SEDINTE(sedinta_id)
        ON DELETE SET NULL,
    elev VARCHAR2(13 BYTE)
        CONSTRAINT FACTURI_elev_FK REFERENCES ELEVI(CNP)
        ON DELETE SET NULL,
    data_incasarii DATE,
    metoda_plata VARCHAR2(15 BYTE)
        CONSTRAINT FACTURI_metoda_CK CHECK (metoda_plata in ('cash', 'card'))
);


--ADAUGAREA CONSTRANGERII DE UNIQUE PE COLOANELE (sedinta_id, elev) DOAR DACA
--AMBELE VALORI NU SUNT NULE
CREATE UNIQUE INDEX FACTURI_sed_elev_UQ ON FACTURI (
    case 
        when sedinta_id is null or elev is null
        then null
        else sedinta_id
    end,
    case
        when sedinta_id is null or elev is null
        then null
        else elev
    end
);


--POPULAREA BAZEI DE DATE

--TABELUL ORASE
insert into ORASE values (10, 'BUCURESTI', 'B');
insert into ORASE values (20, 'CLUJ-NAPOCA', 'CJ');
insert into ORASE values (30, 'TIMISOARA', 'TM');
insert into ORASE values (40, 'IASI', 'IS');
insert into ORASE values (50, 'GALATI', 'GL');
insert into ORASE values (60, 'CONSTANTA', 'CT');
insert into ORASE values (70, 'VASLUI', 'VS');
insert into ORASE values (80, 'TULCEA', 'TL');
insert into ORASE values (90, 'ARAD', 'AR');
insert into ORASE values (100, 'BISTRITA', 'BN');
insert into ORASE values (110, 'SUCEAVA', 'SV');
insert into ORASE values (120, 'BARLAD', 'VS');
insert into ORASE values (130, 'HUSI', 'VS');
insert into ORASE values (140, 'TECUCI', 'GL');

--TABELUL LOCATII
insert into LOCATII values (12, 'Viorele', 52, null, 10); 
insert into LOCATII values (22, 'Pacii', 1, null, 70);
insert into LOCATII values (32, 'Splaiul Independentei', 204, null, 10);
insert into LOCATII values (42, 'Turturelelor', 48, null, 10);
insert into LOCATII values (52, 'Teodor Mihali', 58, null, 20);
insert into LOCATII values (62, 'Universitatii', 16, null, 40);
insert into LOCATII values (72, 'Vasile Parvan', 4, null, 30);
insert into LOCATII values (82, 'Revolutiei', 94, null, 90);
insert into LOCATII values (92, 'Drum. Tarpiului', 21, null, 100);
insert into LOCATII values (102, 'Mamaia', 124, null, 60);
insert into LOCATII values (112, 'Domneasca', 47, null, 50);
insert into LOCATII values (122, 'Pacii', 10, null, 110);
insert into LOCATII values (132, 'Victoriei', 97, null, 80);
insert into LOCATII values (142, 'Decebal', 13, null, 40);
insert into LOCATII values (152, 'Gradinilor', 1, null, 20);

--TABELUL SALI
insert into SALI values (15, 0, 2, 12, 'sala de clasa');
insert into SALI values (25, 0, 1, 12, 'sala de clasa');
insert into SALI values (35, 0, 3, 12, 'sala de clasa');
insert into SALI values (45, 0, 4, 12, 'sala de clasa');
insert into SALI values (55, 2, 23, 42, 'laborator informatica');
insert into SALI values (65, 4, 42, 42, 'sala de clasa');
insert into SALI values (75, 1, 12, 92, 'sala de clasa');
insert into SALI values (85, 2, 2, 102, 'laborator stiinte');
insert into SALI values (95, 1, 4, 22, 'sala de clasa');
insert into SALI values (105, 2, 7, 22, 'laborator informatica');
insert into SALI values (115, 0, 17, 52, 'sala de clasa');
insert into SALI values (125, 3, 122, 142, 'laborator stiinte');
insert into SALI values (135, 4, 402, 72, 'laborator informatica');
insert into SALI values (145, 5, 52, 132, 'sala de clasa');
insert into SALI values (155, -1, 2, 32, 'sala de clasa');
insert into SALI values (165, 8, 324, 82, 'laborator stiinte');

--TABEL JOBURI
insert into JOBURI values (17, 'contabil', null, 2000, 10000);
insert into JOBURI values (27, 'profesor', 'informatica', 2000, 9000);
insert into JOBURI values (37, 'profesor', 'matematica', 2000, 9000);
insert into JOBURI values (47, 'profesor', 'geografie', 2000, 8000);
insert into JOBURI values (57, 'profesor', 'istorie', 2000, 8000);
insert into JOBURI values (67, 'profesor', 'limba romana', 2000, 9000);
insert into JOBURI values (77, 'profesor', 'limba franceza', 2000, 7000);
insert into JOBURI values (87, 'profesor', 'limba engleza', 2000, 7000);
insert into JOBURI values (97, 'profesor', 'fizica', 2000, 9000);
insert into JOBURI values (107, 'profesor', 'biologie', 2000, 8000);
insert into JOBURI values (117, 'profesor', 'chimie', 2000, 9000);
insert into JOBURI values (127, 'director', null, 5000, 15000);

--TABEL ANGAJATI
insert into ANGAJATI values ('1841122411733', 'Popescu', 'Vasile', '12-APR-2021', 6000, '0745232323', 17 );
insert into ANGAJATI values ('1830901416261', 'Bujor', 'Gheorghe', '10-APR-2021', 10000, '0740434178', 127);
insert into ANGAJATI values ('1910919412026', 'Munteanu', 'Vasile', '1-MAY-2022', 4500, '0720754743', 57);
insert into ANGAJATI values ('1751024416058', 'Sandu', 'Catalin', '3-JUN-2021', 4500, '0745035882', 47);
insert into ANGAJATI values ('1810711417513', 'Balan', 'Sorin', '21-SEP-2021', 5500, '0743044863', 97);
insert into ANGAJATI values ('1940131415026', 'Moldoveanu', 'Pavel', '15-OCT-2021', 6000, '0735401616', 27);
insert into ANGAJATI values ('1960714417703', 'Mita', 'Alexandru', '4-NOV-2022', 5000, '0766530642', 77);
insert into ANGAJATI values ('5010106415045', 'Spataru', 'Dan', '5-SEP-2023', 6500, '0742734510', 37);
insert into ANGAJATI values ('2890613280853', 'Sava', 'Lucia', '15-MAY-2021', 5500, '0771420110', 67);
insert into ANGAJATI values ('2921024331691', 'Vulpe', 'Irina', '6-JUN-2022', 6500, '0743847669', 27);
insert into ANGAJATI values ('2870906230977', 'Sima', 'Antonia', '12-DEC-2021', 5000, '0741669324', 87);
insert into ANGAJATI values ('2760924018506', 'Radu', 'Mihaela', '21-JAN-2022', 5250, '0764355422', 107);
insert into ANGAJATI values ('2960805527011', 'Ciobanu', 'Alina', '10-FEB-2023', 6500, '0743950351', 37);
insert into ANGAJATI values ('2771031152107', 'Mitache', 'Dorina', '12-SEP-2022', 4000, '0741455809', 67);
insert into ANGAJATI values ('2840930240988', 'Selaru', 'Valerica', '10-OCT-2023', 5000, '0799770448', 117);
insert into ANGAJATI values ('6000620090130', 'Necula', 'Ana', '11-NOV-2023', null, '0745886573', 107);


--TABEL ELELVI
insert into ELEVI values ('5100217419827', 'Popa', 'Andrei', '01-SEP-2016', '0740015893'); 
insert into ELEVI values ('5110523111179', 'Popa', 'Mihai', '01-SEP-2017', '0740015893');
insert into ELEVI values ('5150705035250', 'Onica', 'Victor', '01-SEP-2021', '0746019265');
insert into ELEVI values ('5091017137948', 'Ivan', 'David', '01-SEP-2015', '0742176201');
insert into ELEVI values ('5120131451255', 'Ursu', 'Filip', '01-SEP-2018', '0726190221');
insert into ELEVI values ('5130902228277', 'Lungu', 'Robert', '01-SEP-2019', '0743141321');
insert into ELEVI values ('6080902174948', 'Dima', 'Antonia', '01-SEP-2014', '0740200625');
insert into ELEVI values ('6121214351221', 'Curta', 'Anastasia', '01-SEP-2018', '0723557550');
insert into ELEVI values ('6140821339777', 'Burlacu', 'Maria', '01-SEP-2020', '0729841235');
insert into ELEVI values ('6100915027525', 'Mihalache', 'Cristina', '01-SEP-2016', '0747645884');
insert into ELEVI values ('6110302445586', 'Sandu', 'Alexia', '01-SEP-2017', '0743044863');
insert into ELEVI values ('6130409370399', 'Creanga', 'Elena', '01-SEP-2019', '0720042481');

--TABEL SEDINTE
insert into SEDINTE values (19, 'N', null, to_date('14-NOV-2023 9:00:00', 'dd-mon-yyyy hh24:mi:ss'), 100, 25, '5010106415045');
insert into SEDINTE values (29, 'Y', 'https://meet.google.com/ajn-agqy-zdr', to_date('15-NOV-2023 11:00:00', 'dd-mon-yyyy hh24:mi:ss'), 80, null, '1910919412026');
insert into SEDINTE values (39, 'N', null, to_date('15-NOV-2023 11:00:00', 'dd-mon-yyyy hh24:mi:ss'), 90, 85, '6000620090130');
insert into SEDINTE values (49, 'N', null, to_date('15-NOV-2023 11:00:00', 'dd-mon-yyyy hh24:mi:ss'), 70, 95, '1810711417513');
insert into SEDINTE values (59, 'N', null, to_date('17-NOV-2023 14:00:00', 'dd-mon-yyyy hh24:mi:ss'), 110, 55, '1940131415026');
insert into SEDINTE values (69, 'N', null, to_date('18-NOV-2023 15:00:00', 'dd-mon-yyyy hh24:mi:ss'), 100, 155, '2960805527011');
insert into SEDINTE values (79, 'N', null, to_date('13-APR-2023 12:00:00', 'dd-mon-yyyy hh24:mi:ss'), 90, 75, '2840930240988');
insert into SEDINTE values (89, 'N', null, to_date('21-NOV-2022 17:00:00', 'dd-mon-yyyy hh24:mi:ss'), 80, 145, '2870906230977');
insert into SEDINTE values (99, 'N', null, to_date('10-DEC-2023 12:00:00', 'dd-mon-yyyy hh24:mi:ss'), 100, 45, '1910919412026');
insert into SEDINTE values (109, 'N', null, to_date('22-NOV-2023 10:00:00', 'dd-mon-yyyy hh24:mi:ss'), 110, 105, '2921024331691');
insert into SEDINTE values (119, 'N', null, to_date('29-NOV-2023 19:00:00', 'dd-mon-yyyy hh24:mi:ss'), 90, 25, '2760924018506');
insert into SEDINTE values (129, 'Y', 'https://meet.google.com/zan-fzhm-cnm', to_date('5-DEC-2022 13:00:00', 'dd-mon-yyyy hh24:mi:ss'), 70, null, '2760924018506');
insert into SEDINTE values (139, 'Y', 'https://meet.google.com/zan-fzhm-cnm', to_date('7-SEP-2023 8:00:00', 'dd-mon-yyyy hh24:mi:ss'), 60, null, '1960714417703');
insert into SEDINTE values (149, 'Y', 'https://meet.google.com/sqm-hjhi-awv', to_date('4-OCT-2023 10:00:00', 'dd-mon-yyyy hh24:mi:ss'), 75, null, '2890613280853');
insert into SEDINTE values (159, 'Y', 'https://meet.google.com/iib-wpjw-asd', to_date('7-OCT-2022 11:00:00', 'dd-mon-yyyy hh24:mi:ss'), 80, null, '2771031152107');
insert into SEDINTE values (169, 'Y', 'https://meet.google.com/mvf-vtpy-ffm', to_date('5-NOV-2021 14:00:00', 'dd-mon-yyyy hh24:mi:ss'), 65, null, '2870906230977');
insert into SEDINTE values (179, 'Y', 'https://meet.google.com/yfx-danc-hkx', to_date('10-MAY-2023 15:00:00', 'dd-mon-yyyy hh24:mi:ss'), 70, null, '1940131415026');
insert into SEDINTE values (189, 'Y', 'https://meet.google.com/zej-wkzq-xyv', to_date('20-DEC-2023 10:00:00', 'dd-mon-yyyy hh24:mi:ss'), 80, null, '1751024416058');
insert into SEDINTE values (199, 'Y', 'https://meet.google.com/zej-wkzq-xyv', to_date('20-DEC-2023 11:00:00', 'dd-mon-yyyy hh24:mi:ss'), 80, null, '1751024416058');

--TABEL FACTURI
insert into FACTURI values (16, 19, '5150705035250', '14-NOV-2023', 'cash');
insert into FACTURI values (26, 19, '6140821339777', '15-NOV-2023', 'card');
insert into FACTURI values (36, 19, '6130409370399', '12-NOV-2023', 'card');
insert into FACTURI values (46, 19, '5130902228277', '10-NOV-2023', 'cash');
insert into FACTURI values (56, 189, '5091017137948', '21-DEC-2023', 'card');
insert into FACTURI values (66, 199, '5091017137948', '21-DEC-2023', 'card');
insert into FACTURI values (76, 89, '5130902228277', '20-NOV-2022', 'cash');
insert into FACTURI values (86, 89, '6130409370399', '21-NOV-2022', 'cash');
insert into FACTURI values (96, 109, '6100915027525', '30-NOV-2023', 'cash');
insert into FACTURI values (106, 109, '6080902174948', '20-NOV-2023', 'cash');
insert into FACTURI values (116, 109, '5091017137948', '22-NOV-2023', 'cash');
insert into FACTURI values (126, 29, '6121214351221', '15-NOV-2023', 'card');
insert into FACTURI values (136, 39, '5120131451255', '15-NOV-2023', 'card');
insert into FACTURI values (146, 39, '6121214351221', '15-NOV-2023', 'cash');
insert into FACTURI values (156, 49, '5100217419827', '10-NOV-2023', 'card');
insert into FACTURI values (166, 59, '5110523111179', '16-NOV-2023', 'card');
insert into FACTURI values (176, 59, '6110302445586', '18-NOV-2023', 'cash');
insert into FACTURI values (186, 79, '5091017137948', '1-MAY-2023', 'cash');
insert into FACTURI values (196, 99, '6080902174948', '21-NOV-2022', 'cash');
insert into FACTURI values (206, 119, '5100217419827', '29-NOV-2023', 'cash');
insert into FACTURI values (216, 129, '6100915027525', '5-DEC-2022', 'card');
insert into FACTURI values (226, 139, '6121214351221', '7-SEP-2023', 'card');
insert into FACTURI values (236, 139, '5120131451255', '8-SEP-2023', 'card');
insert into FACTURI values (246, 149, '5150705035250', '4-OCT-2023', 'card');
insert into FACTURI values (256, 149, '5130902228277', '4-OCT-2023', 'card');
insert into FACTURI values (266, 149, '6140821339777', '3-OCT-2023', 'cash');
insert into FACTURI values (276, 149, '6130409370399', '7-OCT-2023', 'cash');
insert into FACTURI values (286, 159, '5100217419827', '8-OCT-2022', 'cash');
insert into FACTURI values (296, 159, '5110523111179', '10-OCT-2022', 'cash');
insert into FACTURI values (306, 159, '6100915027525', '6-OCT-2022', 'card');
insert into FACTURI values (316, 159, '6110302445586', '5-OCT-2022', 'cash');
insert into FACTURI values (326, 169, '6110302445586', '4-NOV-2021', 'card');
insert into FACTURI values (336, 169, '5110523111179', '5-NOV-2021', 'card');
insert into FACTURI values (346, 179, '6080902174948', '10-MAY-2023', 'card');
insert into FACTURI values (356, 69, '5120131451255', '18-NOV-2023', 'cash');
insert into FACTURI values (366, 69, '6121214351221', '18-NOV-2023', 'cash');
insert into FACTURI values (376, 69, '5110523111179', '18-NOV-2023', 'cash');

commit;
