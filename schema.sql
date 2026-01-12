-- =========================
-- Paw Hospital / VetCare DB
-- PostgreSQL DDL (schema)
-- =========================

-- Recomendado
-- CREATE DATABASE paw_hospital;
-- \c paw_hospital;

BEGIN;

-- =========================
-- 1) Catálogos de ubicación
-- =========================

CREATE TABLE codigo_postal (
  id_codigop  SERIAL PRIMARY KEY,
  codigoP     INTEGER NOT NULL,
  id_asent    INTEGER,
  id_muni     INTEGER,
  id_estado   INTEGER,
  Estado      VARCHAR(100),
  municipio   VARCHAR(100),
  Asentamiento VARCHAR(150),
  Tipo_asent  VARCHAR(80)
);

CREATE TABLE domicilio (
  id_domicilio  SERIAL PRIMARY KEY,
  calle         VARCHAR(120) NOT NULL,
  numInt        INTEGER,
  numExt        INTEGER NOT NULL,
  codigoP       INTEGER NOT NULL,
  id_asent      INTEGER,
  id_muni       INTEGER,
  id_estado     INTEGER
);

-- =========================
-- 2) Cliente / Dueño
-- =========================

CREATE TABLE cliente (
  id_cliente            SERIAL PRIMARY KEY,
  correo                VARCHAR(80) UNIQUE NOT NULL,
  contrasena_cliente    VARCHAR(120) NOT NULL,
  cant_mascotas         INTEGER DEFAULT 0,
  edad_cliente          INTEGER,
  nombre_cliente        VARCHAR(60) NOT NULL,
  apellidoP_cliente     VARCHAR(60) NOT NULL,
  apellidoM_cliente     VARCHAR(60),
  sexo_cliente          VARCHAR(12),
  fech_nac_cliente      TIMESTAMP,
  foto_perfil_cliente   BYTEA,
  id_domicilio          INTEGER,
  CONSTRAINT fk_cliente_domicilio
    FOREIGN KEY (id_domicilio) REFERENCES domicilio(id_domicilio)
    ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE telefono (
  id_telefono SERIAL PRIMARY KEY,
  telefono    VARCHAR(15) NOT NULL,
  id_cliente  INTEGER NOT NULL,
  CONSTRAINT fk_tel_cliente
    FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente)
    ON UPDATE CASCADE ON DELETE CASCADE
);

-- =========================
-- 3) Sucursales
-- =========================

CREATE TABLE sucursales (
  id_sucursal        SERIAL PRIMARY KEY,
  nombre_sucursal    VARCHAR(120) NOT NULL,
  estado_sucursal    VARCHAR(80),
  del_sucursal       VARCHAR(80),
  colonia_sucursal   VARCHAR(80),
  calle_sucursal     VARCHAR(120),
  numext_sucursal    INTEGER,
  codigopostal_sucursal INTEGER NOT NULL
);

CREATE TABLE telefono_sucursal (
  id_telsuc     SERIAL PRIMARY KEY,
  telefono_suc  VARCHAR(15) NOT NULL,
  id_sucursal   INTEGER NOT NULL,
  CONSTRAINT fk_tel_suc
    FOREIGN KEY (id_sucursal) REFERENCES sucursales(id_sucursal)
    ON UPDATE CASCADE ON DELETE CASCADE
);

-- =========================
-- 4) Mascota / Expediente
-- =========================

CREATE TABLE mascota (
  id_mascota      SERIAL PRIMARY KEY,
  nombre          VARCHAR(60) NOT NULL,
  alto            REAL,
  largo           REAL,
  ancho           REAL,
  peso            REAL,
  sexo            VARCHAR(10),
  fech_nac        TIMESTAMP,
  ruac            VARCHAR(30) UNIQUE,          -- en tu front lo pides como texto
  esterilizada    VARCHAR(10),                -- 'si', 'no', 'nose'
  largo_pelaje    VARCHAR(30),
  senas_parti     VARCHAR(255),
  imagen          BYTEA,
  id_cliente      INTEGER NOT NULL,
  CONSTRAINT fk_mascota_cliente
    FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente)
    ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE expediente (
  id_expediente SERIAL PRIMARY KEY,
  id_mascota    INTEGER UNIQUE NOT NULL,
  CONSTRAINT fk_exp_mascota
    FOREIGN KEY (id_mascota) REFERENCES mascota(id_mascota)
    ON UPDATE CASCADE ON DELETE CASCADE
);

-- =========================
-- 5) Vacunas / Enfermedades-Vacunas / Alergias
-- =========================

CREATE TABLE vacunas (
  id_vacunas          SERIAL PRIMARY KEY,
  nombre_vacunas      VARCHAR(80) UNIQUE NOT NULL,
  laboratorio_vacunas VARCHAR(80),
  importancia         VARCHAR(30)
);

CREATE TABLE enfermedades_vacunas (
  id_ev SERIAL PRIMARY KEY,
  ev    VARCHAR(80) NOT NULL
);

-- Tabla puente (en tu diagrama se llama "Alergia")
CREATE TABLE alergia (
  id_vacunas INTEGER NOT NULL,
  id_ev      INTEGER NOT NULL,
  PRIMARY KEY (id_vacunas, id_ev),
  CONSTRAINT fk_alergia_vac
    FOREIGN KEY (id_vacunas) REFERENCES vacunas(id_vacunas)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_alergia_ev
    FOREIGN KEY (id_ev) REFERENCES enfermedades_vacunas(id_ev)
    ON UPDATE CASCADE ON DELETE CASCADE
);

-- puente vacunas - expediente
CREATE TABLE vacunas_expediente (
  id_vacunas     INTEGER NOT NULL,
  id_expediente  INTEGER NOT NULL,
  PRIMARY KEY (id_vacunas, id_expediente),
  CONSTRAINT fk_vacexp_vac
    FOREIGN KEY (id_vacunas) REFERENCES vacunas(id_vacunas)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_vacexp_exp
    FOREIGN KEY (id_expediente) REFERENCES expediente(id_expediente)
    ON UPDATE CASCADE ON DELETE CASCADE
);

-- =========================
-- 6) Empleados / Horario / Asistencia
-- =========================

CREATE TABLE empleados (
  id_empleado       SERIAL PRIMARY KEY,
  tipo_empleado     VARCHAR(30) NOT NULL,  -- doctor / enfermero / recepcionista
  nombre_empleado   VARCHAR(60) NOT NULL,
  apellidoP_empleado VARCHAR(60) NOT NULL,
  apellidoM_empleado VARCHAR(60),
  id_sucursal       INTEGER NOT NULL,
  CONSTRAINT fk_emp_sucursal
    FOREIGN KEY (id_sucursal) REFERENCES sucursales(id_sucursal)
    ON UPDATE CASCADE ON DELETE RESTRICT
);

-- (en tu diagrama aparece “Fecha” como registro de día del empleado)
CREATE TABLE fecha_empleado (
  id_fecha     SERIAL PRIMARY KEY,
  fecha        DATE NOT NULL,
  id_empleado  INTEGER NOT NULL,
  CONSTRAINT fk_fecha_emp
    FOREIGN KEY (id_empleado) REFERENCES empleados(id_empleado)
    ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE hora_laboral (
  id_hora      SERIAL PRIMARY KEY,
  hora_inicio  TIME NOT NULL,
  hora_fin     TIME NOT NULL,
  id_fecha     INTEGER NOT NULL,
  CONSTRAINT fk_hora_fecha
    FOREIGN KEY (id_fecha) REFERENCES fecha_empleado(id_fecha)
    ON UPDATE CASCADE ON DELETE CASCADE
);

-- =========================
-- 7) Citas / Consultas / Diagnósticos / Recetas
-- =========================

CREATE TABLE citas (
  id_cita        SERIAL PRIMARY KEY,
  id_cliente     INTEGER NOT NULL,
  id_empleado    INTEGER NOT NULL,
  id_hora        INTEGER NOT NULL,
  id_expediente  INTEGER NOT NULL,
  CONSTRAINT fk_cita_cliente
    FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_cita_emp
    FOREIGN KEY (id_empleado) REFERENCES empleados(id_empleado)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_cita_hora
    FOREIGN KEY (id_hora) REFERENCES hora_laboral(id_hora)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_cita_exp
    FOREIGN KEY (id_expediente) REFERENCES expediente(id_expediente)
    ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE consultas (
  id_consulta    SERIAL PRIMARY KEY,
  id_expediente  INTEGER NOT NULL,
  id_hora        INTEGER NOT NULL,
  id_empleado    INTEGER NOT NULL,
  CONSTRAINT fk_cons_exp
    FOREIGN KEY (id_expediente) REFERENCES expediente(id_expediente)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_cons_hora
    FOREIGN KEY (id_hora) REFERENCES hora_laboral(id_hora)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_cons_emp
    FOREIGN KEY (id_empleado) REFERENCES empleados(id_empleado)
    ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE diagnostico_consultas (
  id_diagnosticocon SERIAL PRIMARY KEY,
  id_consulta       INTEGER UNIQUE NOT NULL,
  CONSTRAINT fk_diagcon_cons
    FOREIGN KEY (id_consulta) REFERENCES consultas(id_consulta)
    ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE diagnostico_citas (
  id_diagnosticocita SERIAL PRIMARY KEY,
  id_cita            INTEGER UNIQUE NOT NULL,
  CONSTRAINT fk_diagcita_cita
    FOREIGN KEY (id_cita) REFERENCES citas(id_cita)
    ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE receta_consulta (
  id_recetacon       SERIAL PRIMARY KEY,
  id_diagnosticocon  INTEGER UNIQUE NOT NULL,
  CONSTRAINT fk_reccon_diag
    FOREIGN KEY (id_diagnosticocon) REFERENCES diagnostico_consultas(id_diagnosticocon)
    ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE receta_cita (
  id_recetacita      SERIAL PRIMARY KEY,
  id_diagnosticocita INTEGER UNIQUE NOT NULL,
  CONSTRAINT fk_reccita_diag
    FOREIGN KEY (id_diagnosticocita) REFERENCES diagnostico_citas(id_diagnosticocita)
    ON UPDATE CASCADE ON DELETE CASCADE
);

-- =========================
-- 8) Catálogos (medicamentos)
-- =========================

CREATE TABLE pais_laboratorio (
  id_pais   SERIAL PRIMARY KEY,
  nom_pais  VARCHAR(100) NOT NULL
);

CREATE TABLE laboratorio (
  id_lab     SERIAL PRIMARY KEY,
  nom_lab    VARCHAR(120) NOT NULL,
  telefono   VARCHAR(20),
  email      VARCHAR(120),
  sitio_web  VARCHAR(200),
  id_pais    INTEGER,
  CONSTRAINT fk_lab_pais
    FOREIGN KEY (id_pais) REFERENCES pais_laboratorio(id_pais)
    ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE via (
  id_via        SERIAL PRIMARY KEY,
  nom_via       VARCHAR(80) NOT NULL,
  descripcion_via VARCHAR(250)
);

CREATE TABLE categoria (
  id_cat   SERIAL PRIMARY KEY,
  nom_cat  VARCHAR(80) NOT NULL
);

CREATE TABLE especie (
  id_especie  SERIAL PRIMARY KEY,
  nom_especie VARCHAR(80) UNIQUE NOT NULL
);

CREATE TABLE unidad_medida (
  id_um   SERIAL PRIMARY KEY,
  nom_um  VARCHAR(40) UNIQUE NOT NULL
);

CREATE TABLE presentaciones (
  id_pres   SERIAL PRIMARY KEY,
  nom_pres  VARCHAR(60) UNIQUE NOT NULL
);

CREATE TABLE forma_farmaceutica (
  id_form  SERIAL PRIMARY KEY,
  nom_form VARCHAR(60) UNIQUE NOT NULL
);

CREATE TABLE medicamento (
  id_med     SERIAL PRIMARY KEY,
  nom_med    VARCHAR(120) NOT NULL,
  id_via     INTEGER,
  id_cat     INTEGER,
  id_lab     INTEGER,
  id_especie INTEGER,
  CONSTRAINT fk_med_via
    FOREIGN KEY (id_via) REFERENCES via(id_via)
    ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT fk_med_cat
    FOREIGN KEY (id_cat) REFERENCES categoria(id_cat)
    ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT fk_med_lab
    FOREIGN KEY (id_lab) REFERENCES laboratorio(id_lab)
    ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT fk_med_especie
    FOREIGN KEY (id_especie) REFERENCES especie(id_especie)
    ON UPDATE CASCADE ON DELETE SET NULL
);

-- En el diagrama aparece “Presentaciones por medicamento”
CREATE TABLE presentaciones_por_medicamento (
  id_presxmed SERIAL PRIMARY KEY,
  id_med      INTEGER NOT NULL,
  id_um       INTEGER NOT NULL,
  id_pres     INTEGER NOT NULL,
  id_form     INTEGER NOT NULL,
  CONSTRAINT fk_pxm_med
    FOREIGN KEY (id_med) REFERENCES medicamento(id_med)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_pxm_um
    FOREIGN KEY (id_um) REFERENCES unidad_medida(id_um)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_pxm_pres
    FOREIGN KEY (id_pres) REFERENCES presentaciones(id_pres)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_pxm_form
    FOREIGN KEY (id_form) REFERENCES forma_farmaceutica(id_form)
    ON UPDATE CASCADE ON DELETE RESTRICT
);

-- Medicamentos por receta (consulta/cita)
CREATE TABLE medicamentos_x_receta_con (
  id_medreccon  SERIAL PRIMARY KEY,
  id_recetacon  INTEGER NOT NULL,
  id_med        INTEGER NOT NULL,
  dosis_con     VARCHAR(30),
  frecuencia_con VARCHAR(60),
  CONSTRAINT fk_mrc_rec
    FOREIGN KEY (id_recetacon) REFERENCES receta_consulta(id_recetacon)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_mrc_med
    FOREIGN KEY (id_med) REFERENCES medicamento(id_med)
    ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE medicamentos_x_receta_cita (
  id_medreccita   SERIAL PRIMARY KEY,
  id_recetacita   INTEGER NOT NULL,
  id_med          INTEGER NOT NULL,
  dosis_cita      VARCHAR(30),
  frecuencia_cita VARCHAR(60),
  CONSTRAINT fk_mrcita_rec
    FOREIGN KEY (id_recetacita) REFERENCES receta_cita(id_recetacita)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_mrcita_med
    FOREIGN KEY (id_med) REFERENCES medicamento(id_med)
    ON UPDATE CASCADE ON DELETE RESTRICT
);

-- =========================
-- 9) Hospitalización (base)
-- =========================

CREATE TABLE cama (
  id_cama     SERIAL PRIMARY KEY,
  id_sucursal INTEGER NOT NULL,
  CONSTRAINT fk_cama_suc
    FOREIGN KEY (id_sucursal) REFERENCES sucursales(id_sucursal)
    ON UPDATE CASCADE ON DELETE CASCADE
);

-- Tabla hospitalización/hospitalizado (en el diagrama se ven 2 parecidas; dejo una base)
CREATE TABLE hospitalizacion (
  id_hosp       SERIAL PRIMARY KEY,
  id_sucursal   INTEGER NOT NULL,
  id_cama       INTEGER NOT NULL,
  id_mascota    INTEGER NOT NULL,
  fecha_ingreso TIMESTAMP DEFAULT NOW(),
  fecha_alta    TIMESTAMP,
  diagnostico_inicial TEXT,
  CONSTRAINT fk_hosp_suc
    FOREIGN KEY (id_sucursal) REFERENCES sucursales(id_sucursal)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_hosp_cama
    FOREIGN KEY (id_cama) REFERENCES cama(id_cama)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_hosp_mascota
    FOREIGN KEY (id_mascota) REFERENCES mascota(id_mascota)
    ON UPDATE CASCADE ON DELETE RESTRICT
);

COMMIT;
