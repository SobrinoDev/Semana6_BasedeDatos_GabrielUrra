--------------------------------------------------------------------------------
-- Consultorio Medico Municipalidad Santa Gema
-- Script DDL - Modelo Relacional Normalizado
--------------------------------------------------------------------------------

BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE DOSIS CASCADE CONSTRAINTS PURGE';
EXCEPTION
   WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF;
END;
/
BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE PAGO CASCADE CONSTRAINTS PURGE';
EXCEPTION
   WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF;
END;
/
BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE RECETA CASCADE CONSTRAINTS PURGE';
EXCEPTION
   WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF;
END;
/
BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE MEDICAMENTO CASCADE CONSTRAINTS PURGE';
EXCEPTION
   WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF;
END;
/
BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE PACIENTE CASCADE CONSTRAINTS PURGE';
EXCEPTION
   WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF;
END;
/
BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE MEDICO CASCADE CONSTRAINTS PURGE';
EXCEPTION
   WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF;
END;
/
BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE DIGITADOR CASCADE CONSTRAINTS PURGE';
EXCEPTION
   WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF;
END;
/
BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE TIPO_RECETA CASCADE CONSTRAINTS PURGE';
EXCEPTION
   WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF;
END;
/
BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE DIAGNOSTICO CASCADE CONSTRAINTS PURGE';
EXCEPTION
   WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF;
END;
/
BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE BANCO CASCADE CONSTRAINTS PURGE';
EXCEPTION
   WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF;
END;
/
BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE ESPECIALIDAD CASCADE CONSTRAINTS PURGE';
EXCEPTION
   WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF;
END;
/
BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE COMUNA CASCADE CONSTRAINTS PURGE';
EXCEPTION
   WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF;
END;
/


--------------------------------------------------------------------------------
-- CASO 1: Creacion de tablas
--------------------------------------------------------------------------------

CREATE TABLE COMUNA (
   cod_comuna     NUMBER(5)    GENERATED ALWAYS AS IDENTITY (START WITH 1101 INCREMENT BY 1),
   nombre_comuna  VARCHAR2(50) NOT NULL,
   CONSTRAINT pk_comuna PRIMARY KEY (cod_comuna)
);

CREATE TABLE ESPECIALIDAD (
   cod_especialidad    NUMBER(4)    GENERATED ALWAYS AS IDENTITY,
   nombre_especialidad VARCHAR2(50) NOT NULL,
   CONSTRAINT pk_especialidad PRIMARY KEY (cod_especialidad)
);

CREATE TABLE BANCO (
   cod_banco    NUMBER(3)    NOT NULL,
   nombre_banco VARCHAR2(50) NOT NULL,
   CONSTRAINT pk_banco PRIMARY KEY (cod_banco)
);

CREATE TABLE DIAGNOSTICO (
   cod_diagnostico    NUMBER(4)     NOT NULL,
   nombre_diagnostico VARCHAR2(100) NOT NULL,
   CONSTRAINT pk_diagnostico PRIMARY KEY (cod_diagnostico)
);

CREATE TABLE TIPO_RECETA (
   cod_tipo_receta    NUMBER(3)    NOT NULL,
   nombre_tipo_receta VARCHAR2(20) NOT NULL,
   CONSTRAINT pk_tipo_receta PRIMARY KEY (cod_tipo_receta),
   CONSTRAINT ck_tipo_receta_nombre CHECK (nombre_tipo_receta IN
      ('DIGITAL','MAGISTRAL','RETENIDA','GENERAL','VETERINARIA'))
);

CREATE TABLE DIGITADOR (
   id_digitador        NUMBER(8)    NOT NULL,
   dv_digitador        CHAR(1)      NOT NULL,
   nombre_digitador    VARCHAR2(50) NOT NULL,
   apellido_digitador  VARCHAR2(50) NOT NULL,
   CONSTRAINT pk_digitador PRIMARY KEY (id_digitador),
   CONSTRAINT ck_digitador_dv CHECK (dv_digitador IN
      ('0','1','2','3','4','5','6','7','8','9','K'))
);

CREATE TABLE MEDICO (
   rut_med          NUMBER(8)    NOT NULL,
   dv_med           CHAR(1)      NOT NULL,
   nombre_med       VARCHAR2(50) NOT NULL,
   snombre_med      VARCHAR2(50),
   apellido_med     VARCHAR2(50) NOT NULL,
   apellido2_med    VARCHAR2(50),
   fono_med         VARCHAR2(15) NOT NULL,
   cod_especialidad NUMBER(4)    NOT NULL,
   CONSTRAINT pk_medico PRIMARY KEY (rut_med),
   CONSTRAINT uq_medico_fono UNIQUE (fono_med),
   CONSTRAINT ck_medico_dv CHECK (dv_med IN
      ('0','1','2','3','4','5','6','7','8','9','K')),
   CONSTRAINT fk_medico_especialidad FOREIGN KEY (cod_especialidad)
      REFERENCES ESPECIALIDAD (cod_especialidad)
);

CREATE TABLE PACIENTE (
   rut_pac       NUMBER(8)    NOT NULL,
   dv_pac        CHAR(1)      NOT NULL,
   nombre_pac    VARCHAR2(50) NOT NULL,
   snombre_pac   VARCHAR2(50),
   apellido_pac  VARCHAR2(50) NOT NULL,
   apellido2_pac VARCHAR2(50),
   edad          NUMBER(3),
   calle         VARCHAR2(60) NOT NULL,
   numeracion    NUMBER(6),
   fono_pac      VARCHAR2(15),
   ciudad        VARCHAR2(50),
   region        VARCHAR2(50),
   cod_comuna    NUMBER(5),
   CONSTRAINT pk_paciente PRIMARY KEY (rut_pac),
   CONSTRAINT ck_paciente_dv CHECK (dv_pac IN
      ('0','1','2','3','4','5','6','7','8','9','K')),
   CONSTRAINT fk_paciente_comuna FOREIGN KEY (cod_comuna)
      REFERENCES COMUNA (cod_comuna)
);

CREATE TABLE MEDICAMENTO (
   cod_medicamento     VARCHAR2(10)  NOT NULL,
   nombre_medicamento  VARCHAR2(100) NOT NULL,
   dosis_recomendada   VARCHAR2(50),
   stock               NUMBER(6)     NOT NULL,
   via_administracion  VARCHAR2(30),
   tipo_medicamento    VARCHAR2(20),
   CONSTRAINT pk_medicamento PRIMARY KEY (cod_medicamento),
   CONSTRAINT ck_medicamento_stock CHECK (stock >= 0),
   CONSTRAINT ck_medicamento_tipo CHECK (tipo_medicamento IN ('GENERICO','MARCA'))
);

CREATE TABLE RECETA (
   cod_receta        NUMBER(9)     NOT NULL,
   fecha_emision     DATE          NOT NULL,
   fecha_vencimiento DATE,
   observaciones     VARCHAR2(500),
   rut_pac           NUMBER(8)     NOT NULL,
   rut_med           NUMBER(8)     NOT NULL,
   id_digitador      NUMBER(8)     NOT NULL,
   cod_diagnostico   NUMBER(4)     NOT NULL,
   cod_tipo_receta   NUMBER(3)     NOT NULL,
   CONSTRAINT pk_receta PRIMARY KEY (cod_receta),
   CONSTRAINT fk_receta_paciente FOREIGN KEY (rut_pac)
      REFERENCES PACIENTE (rut_pac),
   CONSTRAINT fk_receta_medico FOREIGN KEY (rut_med)
      REFERENCES MEDICO (rut_med),
   CONSTRAINT fk_receta_digitador FOREIGN KEY (id_digitador)
      REFERENCES DIGITADOR (id_digitador),
   CONSTRAINT fk_receta_diagnostico FOREIGN KEY (cod_diagnostico)
      REFERENCES DIAGNOSTICO (cod_diagnostico),
   CONSTRAINT fk_receta_tiporeceta FOREIGN KEY (cod_tipo_receta)
      REFERENCES TIPO_RECETA (cod_tipo_receta)
);

CREATE TABLE DOSIS (
   cod_receta        NUMBER(9)    NOT NULL,
   cod_medicamento   VARCHAR2(10) NOT NULL,
   unidades          NUMBER(4)    NOT NULL,
   indicacion_dosis  VARCHAR2(50),
   dias_tratamiento  NUMBER(4),
   CONSTRAINT pk_dosis PRIMARY KEY (cod_receta, cod_medicamento),
   CONSTRAINT ck_dosis_unidades CHECK (unidades > 0),
   CONSTRAINT fk_dosis_receta FOREIGN KEY (cod_receta)
      REFERENCES RECETA (cod_receta),
   CONSTRAINT fk_dosis_medicamento FOREIGN KEY (cod_medicamento)
      REFERENCES MEDICAMENTO (cod_medicamento)
);

CREATE TABLE PAGO (
   id_pago      NUMBER(9)    NOT NULL,
   id_boleta    NUMBER(9),
   cod_receta   NUMBER(9)    NOT NULL,
   monto_total  NUMBER(10)   NOT NULL,
   fecha_pago   DATE         NOT NULL,
   metodo_pago  VARCHAR2(20) NOT NULL,
   cod_banco    NUMBER(3),
   CONSTRAINT pk_pago PRIMARY KEY (id_pago),
   CONSTRAINT ck_pago_monto CHECK (monto_total > 0),
   CONSTRAINT fk_pago_receta FOREIGN KEY (cod_receta)
      REFERENCES RECETA (cod_receta),
   CONSTRAINT fk_pago_banco FOREIGN KEY (cod_banco)
      REFERENCES BANCO (cod_banco)
);


--------------------------------------------------------------------------------
-- CASO 2: Ajustes posteriores a la implementacion (ALTER TABLE)
--------------------------------------------------------------------------------

ALTER TABLE MEDICAMENTO ADD (precio_unitario NUMBER(9) NOT NULL);
ALTER TABLE MEDICAMENTO ADD CONSTRAINT ck_medicamento_precio
   CHECK (precio_unitario BETWEEN 1000 AND 2000000);

ALTER TABLE PAGO ADD CONSTRAINT ck_pago_metodo
   CHECK (metodo_pago IN ('EFECTIVO','TARJETA','TRANSFERENCIA'));

ALTER TABLE PACIENTE DROP COLUMN edad;
ALTER TABLE PACIENTE ADD (fecha_nacimiento DATE);
