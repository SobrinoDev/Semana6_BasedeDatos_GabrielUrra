# Semana 6 - Base de Datos: Implementación DDL del Modelo Relacional (Consultorio Médico)

Actividad sumativa individual "Implementación del Modelo Relacional", desarrollada con Oracle SQL Developer Data Modeler, donde se valida un Modelo Relacional normalizado y se construyen las sentencias DDL (creación de tablas, restricciones y ajustes posteriores) para su implementación en Oracle Database.

## Contexto de negocio

La Municipalidad de Santa Gema decidió implementar una plataforma digital para apoyar la gestión del consultorio médico, con el fin de administrar de manera eficiente las recetas médicas, la entrega de medicamentos y sus pagos correspondientes. El equipo de TI había desarrollado previamente un Modelo Relacional, pero por limitaciones presupuestarias no se completó la implementación de la base de datos. A partir de ese modelo y de una serie de reglas de negocio, se construyó el script DDL correspondiente, cubriendo tanto la creación inicial de las tablas (Caso 1) como los ajustes posteriores detectados una vez implementado el sistema (Caso 2, resueltos mediante `ALTER TABLE`).

## Entidades identificadas

Se identificaron 12 entidades: `COMUNA`, `ESPECIALIDAD`, `BANCO`, `DIAGNOSTICO` y `TIPO_RECETA` como tablas catálogo que normalizan valores repetidos del modelo original; `DIGITADOR`, `MEDICO`, `PACIENTE` y `MEDICAMENTO` como entidades principales; `RECETA` como entidad central que relaciona paciente, médico, digitador, diagnóstico y tipo de receta; `DOSIS` como entidad asociativa que resuelve la relación N:M entre `RECETA` y `MEDICAMENTO`; y `PAGO` como entidad dependiente que registra los pagos asociados a cada receta (relación 1:N).

### COMUNA
| Atributo | Tipo | Clave |
|---|---|---|
| cod_comuna | NUMBER(5) IDENTITY (inicia en 1101, incrementa de 1 en 1) | PK |
| nombre_comuna | VARCHAR2(50) | Obligatorio |

### ESPECIALIDAD
| Atributo | Tipo | Clave |
|---|---|---|
| cod_especialidad | NUMBER(4) IDENTITY | PK |
| nombre_especialidad | VARCHAR2(50) | Obligatorio |

### BANCO
| Atributo | Tipo | Clave |
|---|---|---|
| cod_banco | NUMBER(3) | PK |
| nombre_banco | VARCHAR2(50) | Obligatorio |

### DIAGNOSTICO
| Atributo | Tipo | Clave |
|---|---|---|
| cod_diagnostico | NUMBER(4) | PK |
| nombre_diagnostico | VARCHAR2(100) | Obligatorio |

### TIPO_RECETA
| Atributo | Tipo | Clave |
|---|---|---|
| cod_tipo_receta | NUMBER(3) | PK |
| nombre_tipo_receta | VARCHAR2(20) — CHECK (DIGITAL, MAGISTRAL, RETENIDA, GENERAL, VETERINARIA) | Obligatorio |

### DIGITADOR
| Atributo | Tipo | Clave |
|---|---|---|
| id_digitador | NUMBER(8) | PK |
| dv_digitador | CHAR(1) — CHECK (0-9, K) | Obligatorio |
| nombre_digitador | VARCHAR2(50) | Obligatorio |
| apellido_digitador | VARCHAR2(50) | Obligatorio |

### MEDICO
| Atributo | Tipo | Clave |
|---|---|---|
| rut_med | NUMBER(8) | PK |
| dv_med | CHAR(1) — CHECK (0-9, K) | Obligatorio |
| nombre_med | VARCHAR2(50) | Obligatorio |
| snombre_med | VARCHAR2(50) | Opcional |
| apellido_med | VARCHAR2(50) | Obligatorio |
| apellido2_med | VARCHAR2(50) | Opcional |
| fono_med | VARCHAR2(15) | Obligatorio (único) |
| cod_especialidad | NUMBER(4) | FK → ESPECIALIDAD |

### PACIENTE
| Atributo | Tipo | Clave |
|---|---|---|
| rut_pac | NUMBER(8) | PK |
| dv_pac | CHAR(1) — CHECK (0-9, K) | Obligatorio |
| nombre_pac | VARCHAR2(50) | Obligatorio |
| snombre_pac | VARCHAR2(50) | Opcional |
| apellido_pac | VARCHAR2(50) | Obligatorio |
| apellido2_pac | VARCHAR2(50) | Opcional |
| fecha_nacimiento | DATE | Opcional (reemplaza a `edad`, ajuste Caso 2) |
| calle | VARCHAR2(60) | Obligatorio |
| numeracion | NUMBER(6) | Opcional |
| fono_pac | VARCHAR2(15) | Opcional |
| ciudad | VARCHAR2(50) | Opcional |
| region | VARCHAR2(50) | Opcional |
| cod_comuna | NUMBER(5) | FK → COMUNA |

### MEDICAMENTO
| Atributo | Tipo | Clave |
|---|---|---|
| cod_medicamento | VARCHAR2(10) | PK |
| nombre_medicamento | VARCHAR2(100) | Obligatorio |
| dosis_recomendada | VARCHAR2(50) | Opcional |
| stock | NUMBER(6) — CHECK (>= 0) | Obligatorio |
| via_administracion | VARCHAR2(30) | Opcional |
| tipo_medicamento | VARCHAR2(20) — CHECK (GENERICO, MARCA) | Opcional |
| precio_unitario | NUMBER(9) — CHECK (entre 1.000 y 2.000.000) | Obligatorio (agregado en Caso 2) |

### RECETA
| Atributo | Tipo | Clave |
|---|---|---|
| cod_receta | NUMBER(9) | PK |
| fecha_emision | DATE | Obligatorio |
| fecha_vencimiento | DATE | Opcional |
| observaciones | VARCHAR2(500) | Opcional |
| rut_pac | NUMBER(8) | FK → PACIENTE |
| rut_med | NUMBER(8) | FK → MEDICO |
| id_digitador | NUMBER(8) | FK → DIGITADOR |
| cod_diagnostico | NUMBER(4) | FK → DIAGNOSTICO |
| cod_tipo_receta | NUMBER(3) | FK → TIPO_RECETA |

### DOSIS (entidad asociativa)
| Atributo | Tipo | Clave |
|---|---|---|
| cod_receta | NUMBER(9) | PK / FK → RECETA |
| cod_medicamento | VARCHAR2(10) | PK / FK → MEDICAMENTO |
| unidades | NUMBER(4) — CHECK (> 0) | Obligatorio |
| indicacion_dosis | VARCHAR2(50) | Opcional |
| dias_tratamiento | NUMBER(4) | Opcional |

### PAGO
| Atributo | Tipo | Clave |
|---|---|---|
| id_pago | NUMBER(9) | PK |
| id_boleta | NUMBER(9) | Opcional |
| cod_receta | NUMBER(9) | FK → RECETA |
| monto_total | NUMBER(10) — CHECK (> 0) | Obligatorio |
| fecha_pago | DATE | Obligatorio |
| metodo_pago | VARCHAR2(20) — CHECK (EFECTIVO, TARJETA, TRANSFERENCIA, agregado en Caso 2) | Obligatorio |
| cod_banco | NUMBER(3) | FK → BANCO |

## Relaciones

- **COMUNA (0,1) — PACIENTE (0,N):** una comuna puede tener cero o muchos pacientes domiciliados en ella; un paciente puede tener registrada cero o una comuna.
- **ESPECIALIDAD (1,1) — MEDICO (0,N):** una especialidad puede tener cero o muchos médicos; todo médico pertenece exactamente a una especialidad.
- **PACIENTE (1,1) — RECETA (0,N):** un paciente puede tener cero o muchas recetas; toda receta pertenece exactamente a un paciente.
- **MEDICO (1,1) — RECETA (0,N):** un médico puede emitir cero o muchas recetas; toda receta es emitida por exactamente un médico.
- **DIGITADOR (1,1) — RECETA (0,N):** un digitador puede ingresar cero o muchas recetas; toda receta es ingresada al sistema por exactamente un digitador.
- **DIAGNOSTICO (1,1) — RECETA (0,N):** un diagnóstico puede estar asociado a cero o muchas recetas; toda receta tiene asociado exactamente un diagnóstico.
- **TIPO_RECETA (1,1) — RECETA (0,N):** un tipo de receta puede aplicar a cero o muchas recetas; toda receta tiene asociado exactamente un tipo.
- **RECETA (0,N) — MEDICAMENTO (0,N):** relación N:M resuelta mediante la entidad asociativa `DOSIS`; toda receta tiene al menos un medicamento asociado, y un medicamento puede aparecer en cero o muchas recetas.
- **RECETA (1,1) — PAGO (0,N):** una receta puede tener cero o muchos pagos asociados; todo pago pertenece exactamente a una receta.
- **BANCO (0,1) — PAGO (0,N):** un banco puede estar asociado a cero o muchos pagos; un pago puede tener registrado cero o un banco (campo opcional, tal como se observa en la boleta de ejemplo del enunciado, donde el campo Banco puede quedar en blanco).

A diferencia de otros modelos con entidades débiles, en este caso todas las tablas principales cuentan con su propia clave primaria natural (rut, código de catálogo o identificador numérico), por lo que la mayoría de las relaciones son no identificadoras. La única excepción es la entidad asociativa `DOSIS`, cuya clave primaria compuesta se forma íntegramente por las claves foráneas heredadas de `RECETA` y `MEDICAMENTO`, para resolver la relación N:M entre ambas.

## Contenido del repositorio

- [`Semana6_Basededatos_Scrip.sql`](./Semana6_Basededatos_Scrip.sql): script DDL completo, con instrucciones de borrado de objetos, creación de tablas (Caso 1) y ajustes mediante `ALTER TABLE` (Caso 2), en orden de ejecución secuencial.
