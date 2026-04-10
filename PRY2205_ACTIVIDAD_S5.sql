--============================================--
/*        LIMPIEZA: Borrado de objetos        */
--============================================--
DROP TABLE CLIENTES_CUPO_COMPRA CASCADE CONSTRAINTS;

/*CASO 1: Listado de Clientes*/
SELECT
    REPLACE(TO_CHAR(c.numrun, '99,999,999'),',','.') || '-' || c.dvrun AS "RUT Cliente",
    INITCAP(c.pnombre || ' ' || c.appaterno) AS "Nombre Cliente",
    UPPER(po.nombre_prof_ofic) AS "Profesión Cliente",
    LPAD(TO_CHAR(c.fecha_inscripcion, 'DD-MM-YYYY'),20) AS "Fecha de Inscripción",
    c.direccion AS "Dirección Cliente"
FROM CLIENTE c
INNER JOIN PROFESION_OFICIO po
    ON c.COD_PROF_OFIC = po.COD_PROF_OFIC
WHERE cod_tipo_cliente = 10
    AND c.cod_prof_ofic IN (13,18)
    AND EXTRACT(YEAR FROM c.fecha_inscripcion) > ( SELECT 
                                                    ROUND(AVG(EXTRACT(YEAR FROM fecha_inscripcion)))
                                                  FROM CLIENTE )
ORDER BY "RUT Cliente" ASC;

/*CASO 2: Aumento de crédito*/

CREATE TABLE CLIENTES_CUPO_COMPRA AS
SELECT
    LPAD(c.numrun || '-' || UPPER(c.dvrun),15) AS "RUT_CLIENTE",
    CEIL(MONTHS_BETWEEN(SYSDATE, c.fecha_nacimiento) / 12) AS "EDAD",
    LPAD(NVL(REPLACE(TO_CHAR(tcl.cupo_disp_compra, '$99,999,999'),',','.'),0),16) AS "CUPO_DISPONIBLE_COMPRA",
    UPPER(tc.nombre_tipo_cliente) AS "TIPO_CLIENTE"
FROM CLIENTE c
INNER JOIN TIPO_CLIENTE tc
    ON c.COD_TIPO_CLIENTE = tc.COD_TIPO_CLIENTE 
LEFT JOIN TARJETA_CLIENTE tcl
    ON c.NUMRUN = tcl.NUMRUN
WHERE tcl.cupo_disp_compra >= ( SELECT
                                    MAX(cupo_disp_compra)
                                FROM TARJETA_CLIENTE
                                WHERE EXTRACT(YEAR FROM fecha_solic_tarjeta) = EXTRACT(YEAR FROM SYSDATE) -1)
ORDER BY "EDAD" ASC;


SELECT * FROM CLIENTES_CUPO_COMPRA;

