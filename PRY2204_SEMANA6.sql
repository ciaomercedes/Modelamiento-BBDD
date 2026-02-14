---=====TABLAS BASE CON PK=====---

---TABLA REGION---
CREATE TABLE region (
    id_region NUMBER(2) PRIMARY KEY,
    nombre  VARCHAR2(50) NOT NULL
);

---TABLA ESPECIALIDAD (IDENTITY automático)---
CREATE TABLE especialidad (
    id_especialidad NUMBER GENERATED ALWAYS AS IDENTITY,
    nombre  VARCHAR2(50) NOT NULL,
    CONSTRAINT especialidad_pk PRIMARY KEY (id_especialidad)
);

---TABLA TIPO_RECETA---
CREATE TABLE tipo_receta (
    id_tipo_receta NUMBER(3) PRIMARY KEY,
    descripcion VARCHAR2(30) NOT NULL,
    ADD CONSTRAINT tipo_receta_chk
        CHECK (id_tipo_receta IN (1,2,3)) --1 = Simple, 2 = Retenida, 3 = Cheque---
);

---TABLA DIAGNOSTICO---
CREATE TABLE diagnostico (
    id_diagnostico NUMBER(4) PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL
);

---TABLA BANCO---
CREATE TABLE banco (
    id_banco NUMBER(3) PRIMARY KEY,
    nombre  VARCHAR(50) NOT NULL
);

---TABLA DIGITADOR---
CREATE TABLE digitador (
    rut_digitador NUMBER(8) PRIMARY KEY,
    dv_digitador CHAR(1) NOT NULL,
    pnombre VARCHAR(30) NOT NULL,
    papellido VARCHAR(30) NOT NULL,
    telefono NUMBER(11),
    
    CONSTRAINT dv_digitador_chk
        CHECK (dv_digitador IN ('0','1','2','3','4','5','6','7','8','9','K'))
);

---TABLA MEDICAMENTO---
CREATE TABLE medicamento (
    id_medicamento NUMBER(7) PRIMARY KEY,
    nombre  VARCHAR(100) NOT NULL,
    dosis_recomendada VARCHAR(100),
    stock   NUMBER(6) NOT NULL,
    id_tipo_med NUMBER(1) NOT NULL,
    precio_unitario NUMBER(10,2),
    
CONSTRAINT medicamento_tipo_chk
CHECK (id_tipo_med IN (1,2)) ---1 = GENERICO, 2 = MARCA---
);

---===TABLAS DEPENDIENTES===----
---TABLA COMUNA (IDENTITY inicia en1101)---
CREATE TABLE comuna (
    id_comuna NUMBER GENERATED ALWAYS AS IDENTITY
        (START WITH 1101 INCREMENT BY 1),
    nombre VARCHAR2(50) NOT NULL,
    id_region NUMBER(2) NOT NULL,
    CONSTRAINT comuna_pk PRIMARY KEY (id_comuna),
    CONSTRAINT comuna_region_fk
        FOREIGN KEY (id_region) REFERENCES region(id_region)
);

---TABLA CIUDAD---
CREATE TABLE ciudad (
    id_ciudad NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre VARCHAR2(50) NOT NULL,
    id_region NUMBER(2) NOT NULL,
    CONSTRAINT ciudad_region_fk
        FOREIGN KEY (id_region) REFERENCES region(id_region)
);

---TABLA PACIENTE---
CREATE TABLE paciente (
    rut_pac NUMBER(8) PRIMARY KEY,
    dv_pac CHAR(1) NOT NULL,
    pnombre   VARCHAR2(30) NOT NULL,
    snombre   VARCHAR2(30),
    ap_paterno VARCHAR2(30) NOT NULL,
    ap_materno VARCHAR2(30),
    calle     VARCHAR2(50),
    numero    NUMBER(5),
    id_comuna NUMBER NOT NULL,

    CONSTRAINT paciente_dv_chk 
        CHECK (dv_pac IN ('0','1','2','3','4','5','6','7','8','9','K')),

    CONSTRAINT paciente_comuna_fk 
        FOREIGN KEY (id_comuna) REFERENCES comuna(id_comuna)
);

---TABLA MEDICO---
CREATE TABLE medico (
    rut_med   NUMBER(8) PRIMARY KEY,
    dv_med    CHAR(1) NOT NULL,
    pnombre   VARCHAR2(30) NOT NULL,
    ap_paterno VARCHAR2(30) NOT NULL,
    telefono  NUMBER(11) NOT NULL,
    id_especialidad NUMBER NOT NULL,

    CONSTRAINT medico_dv_chk 
        CHECK (dv_med IN ('0','1','2','3','4','5','6','7','8','9','K')),

    CONSTRAINT medico_tel_unique UNIQUE (telefono),

    CONSTRAINT medico_especialidad_fk 
        FOREIGN KEY (id_especialidad) REFERENCES especialidad(id_especialidad)
);

---=====TABLAS DEPENDIENTES PRINCIPALES=====---
---TABLA RECETA---
CREATE TABLE receta (
    id_receta      NUMBER(7) PRIMARY KEY,
    fecha_emision  DATE NOT NULL,
    fecha_vencimiento DATE,
    observaciones  VARCHAR2(500),
    rut_pac        NUMBER(8) NOT NULL,
    rut_med        NUMBER(8) NOT NULL,
    rut_digitador  NUMBER(8) NOT NULL,
    id_diagnostico NUMBER(4) NOT NULL,
    id_tipo_receta NUMBER(3) NOT NULL,

    FOREIGN KEY (rut_pac) REFERENCES paciente(rut_pac),
    FOREIGN KEY (rut_med) REFERENCES medico(rut_med),
    FOREIGN KEY (rut_digitador) REFERENCES digitador(rut_digitador),
    FOREIGN KEY (id_diagnostico) REFERENCES diagnostico(id_diagnostico),
    FOREIGN KEY (id_tipo_receta) REFERENCES tipo_receta(id_tipo_receta)
);
---TABLA DOSIS---
CREATE TABLE dosis (
    id_receta      NUMBER(7),
    id_medicamento NUMBER(7),
    descripcion    VARCHAR2(200),

    CONSTRAINT dosis_pk PRIMARY KEY (id_receta, id_medicamento),

    FOREIGN KEY (id_receta) REFERENCES receta(id_receta),
    FOREIGN KEY (id_medicamento) REFERENCES medicamento(id_medicamento)
);

ALTER TABLE dosis
DROP COLUMN descripcion;

ALTER TABLE dosis
ADD (
    unidades_medicamento NUMBER(4) NOT NULL,
    frecuencia_dosis VARCHAR2(25) NOT NULL,
    dias_tratamiento NUMBER(3) NOT NULL
);

---TABLA PAGO---
CREATE TABLE pago (
    id_pago     NUMBER(6) PRIMARY KEY,
    id_receta   NUMBER(7) NOT NULL,
    fecha_pago  DATE NOT NULL,
    monto       NUMBER(10,2) NOT NULL,
    metodo_pago VARCHAR2(20),
    id_banco    NUMBER(3),

    FOREIGN KEY (id_receta) REFERENCES receta(id_receta),
    FOREIGN KEY (id_banco) REFERENCES banco(id_banco)
);

ALTER TABLE pago
ADD CONSTRAINT pago_monto_chk
CHECK (monto > 0);

---ALTER TABLE---
---==AGREGAR MEDICAMENTO ENTRE MIL Y 2MM==---
ALTER TABLE medicamento
ADD precio_unitario NUMBER(10,2);

ALTER TABLE medicamento
ADD CONSTRAINT  medicamento_precio_chk
CHECK (precio_unitario BETWEEN 1000 AND 2000000);

---==RESTRINGIR METODOS DE PAGO==---
ALTER TABLE pago
ADD CONSTRAINT pago_metodo_chk
CHECK (metodo_pago IN ('EFECTIVO', 'TARJETA', 'TRANSFERENCIA'));

ALTER TABLE pago
DROP CONSTRAINT pago_metodo_chk;

ALTER TABLE pago
DROP COLUMN metodo_pago;

ALTER TABLE pago
ADD id_metodo_pago NUMBER(1) NOT NULL
ADD CONSTRAINT pago_metodo_chk
CHECK (id_metodo_pago IN (1,2,3));

---==AGREGAR FECHA_NACIMIENTO==---
ALTER TABLE paciente
ADD fecha_nacimiento DATE;