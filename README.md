# A Structured Expert Judgment Study on the Quantum Computing Boom

*Forecasting the next major technology wave*

**Autor:** Bruno Fernandez Carballo
**Instructor:** G. F. Nane
**Curso:** Decision Theory and Expert Judgment — TU Delft
**Fecha:** Junio 2026

---

## Sobre el proyecto

Este repositorio contiene un estudio de **Structured Expert Judgment (SEJ)**
sobre el futuro de la computación cuántica, realizado con el
[**Classical Model**](https://en.wikipedia.org/wiki/Expert_elicitation#Cooke's_Classical_Model)
de Roger Cooke.

La computación cuántica se describe con frecuencia como la próxima gran
revolución tecnológica, pero el **momento** y la **magnitud** de este
posible "quantum boom" siguen siendo altamente inciertos. Al no existir
apenas series históricas para construir un modelo puramente basado en
datos, el problema encaja de lleno en el escenario para el que se diseñó
el SEJ.

Un panel de **ocho expertos** dio los cuantiles 5 %, 50 % y 95 % para
**14 preguntas de calibración** (con respuesta conocida) y **5 preguntas
de interés** sobre el futuro del sector. Para comprobar si el
*background* de los evaluadores cambia las conclusiones, el panel se
analiza en tres configuraciones:

| Configuración          | Composición                                  |
| ---------------------- | -------------------------------------------- |
| **Full panel**         | los 8 expertos                               |
| **Quantum panel**      | 4 expertos con formación en física cuántica  |
| **Investment panel**   | 4 expertos con formación en finanzas / PE    |

### Principales resultados

- En las tres configuraciones el **decision maker (DM) con pesos por
  desempeño** supera al DM con pesos iguales en el score combinado
  calibración × información.
- El DM más fuerte se construye a partir del panel completo
  (calibración **0.399**, información **1.37**) y concentra el peso en
  los dos únicos evaluadores bien calibrados — uno de cada grupo.
- El *forecast* agregado proyecta que el mercado global de computación
  cuántica superará los **50 000 M USD hacia 2039** (intervalo 90 %
  2032 – 2050) y que la primera ruptura criptográficamente relevante
  de **RSA-2048 llegará alrededor de 2049** (intervalo 90 % 2035 – 2067).
- Los dos *background groups* discrepan sobre el llamado "Q-day", lo
  que puede indicar cierto exceso de confianza en los expertos de
  dominio.

Todos los detalles, tablas, figuras y discusión están en el informe
completo:
[`report/Report_DT_EJ.pdf`](report/Report_DT_EJ.pdf).

---

## Estructura del repositorio

```
.
├── report/
│   └── Report_DT_EJ.pdf          Informe completo (PDF, 19 páginas)
│
├── R code for CM/                Implementación en R del Classical Model
│   ├── R code/
│   │   ├── Classical Model main.R    Script principal a ejecutar
│   │   ├── calibrationScore.R        Score de calibración C(e)
│   │   ├── informationScore.R        Score de información I(e)
│   │   ├── constructDM.R             Construcción del Decision Maker
│   │   ├── globalWeights_opt.R       Pesos globales, alpha optimizado
│   │   ├── globalWeights_alpha.R     Pesos globales con alpha fijo
│   │   ├── itemWeights.R             Item weights (alpha = 0)
│   │   ├── itemWeights_opt.R         Item weights, alpha optimizado
│   │   └── itemWeights_alpha.R       Item weights con alpha fijo
│   │
│   └── Expert data/              Datos de ejemplo (formato de entrada)
│       ├── Exp1.csv … Exp5.csv       Cuantiles por experto
│       └── realizations.csv          Valores verdaderos de las seeds
│
├── .gitignore
└── README.md
```

> **Nota sobre los datos.** Los ficheros `Exp*.csv` y `realizations.csv`
> incluidos son los datos **de ejemplo** distribuidos junto con la
> implementación del curso (basados en el índice AEX). Sirven para
> mostrar el formato de entrada del código y para reproducir un caso
> ejecutable, pero **no son las respuestas del panel de expertos**
> usadas en el informe; esas respuestas se mantienen confidenciales
> tal y como establece el protocolo de elicitación (Sección 3.1 del
> informe).

---

## El Classical Model en dos líneas

Cada experto *e* recibe un peso proporcional a

$$w_e \;\propto\; C(e)\cdot I(e)\cdot \mathbf{1}_{\{C(e)\ge\alpha\}}$$

donde

- **C(e)** es el *calibration score*: el p-valor del test χ²ₙ₋₁ que
  compara la distribución empírica de las realizaciones sobre los
  bins inter-cuantílicos con el vector teórico (0.05, 0.45, 0.45, 0.05).
- **I(e)** es el *information score*: la divergencia de Kullback-Leibler
  de la densidad del experto respecto a una medida uniforme (o
  log-uniforme) sobre el intrinsic range con overshoot k = 0.1.
- **α** es un umbral opcional que anula el peso de los expertos con
  calibración por debajo del corte.

El *Performance Weights Decision Maker* (PWDM) agrega las densidades
individuales con estos pesos y produce los cuantiles 5 / 50 / 95 % del
grupo. Para más detalles ver Secciones 2.1 – 2.4 del informe.

---

## Cómo reproducir los resultados

### Requisitos

- **R** ≥ 4.0
- No requiere paquetes externos. Todo se implementa con `base` R.
  (Opcionalmente, `rstudioapi` para la detección automática del
  directorio de trabajo dentro de RStudio.)

### Pasos

1. Clona el repositorio:

   ```bash
   git clone https://github.com/brunoffernandez/structured-expert-judgment-on-the-quantum-computing-boom-.git
   cd structured-expert-judgment-on-the-quantum-computing-boom-/"R code for CM"
   ```

2. Abre `R code/Classical Model main.R` en RStudio (o R). El script
   intentará ubicar automáticamente la carpeta `R code for CM` como
   directorio de trabajo. Si lo ejecutas desde la línea de comandos,
   asegúrate de que `getwd()` devuelve esa carpeta.

3. Ejecuta el script entero. La consola imprimirá:

   - Scores de calibración e información por experto.
   - Pesos y soluciones (5 / 50 / 95 %) de los siguientes decision
     makers:
     - **EWDM** — Equal Weights DM
     - **PWDM** — Performance Weights DM (α = 0)
     - **PWDM opt** — global, α optimizado
     - **PWDM α = 0.05**
     - **IWDM opt** — item weights, α optimizado
   - Score combinado de calibración e información para PWDM y EWDM
     (comparación directa que se reporta en la Sección 4.3 del informe).

Para reproducir el análisis de los sub-paneles del informe (quantum
vs. investment), basta con ejecutar el script tres veces cambiando la
selección de ficheros `Exp*.csv` presentes en `Expert data/`
(o ajustando `csvFiles` en el script principal).

---

## Referencia rápida a las preguntas del estudio

**Preguntas de calibración (14).** Cubren los tres bloques que
recrean, a propósito, las tres fases de una ola tecnológica:

- *Mercado / boom histórico.* NASDAQ en el pico del dot-com (Q1),
  caída del NASDAQ 2000-2002 (Q2).
- *Adopción.* Usuarios de internet en 2000 (Q3), velocidad de adopción
  de ChatGPT (Q4), publicaciones AI en 2023 (Q5), organizaciones
  usando AI en 2024 (Q14).
- *Inversión e investigación.* Patentes AI 2023 (Q6), inversión privada
  en GenAI 2024 (Q7), ordenadores cuánticos operativos en 2025 (Q8),
  submissions a `quant-ph` en 2023 (Q9), patentes cuánticas 2024 (Q10),
  VC en quantum 2024 (Q11), inversión privada quantum en 9M 2025 (Q12),
  proyección McKinsey 2030 (Q13).

**Preguntas de interés (5).**

1. Año en que el mercado global de computación cuántica supera los
   50 000 M USD anuales.
2. Papers anuales en `quant-ph` en 2035.
3. Número de ordenadores cuánticos operativos en el mundo en 2035.
4. Año en que un ordenador cuántico rompa por primera vez RSA-2048
   en < 24 h (*Q-day*).
5. Porcentaje de Fortune 500 con uso operativo de quantum en 2035.

Las justificaciones, seeds y comentarios cualitativos por experto están
en la Sección 3 del informe.

---

## Créditos

- **Classical Model (teoría):** Roger M. Cooke (TU Delft).
- **Implementación en R:** T. Nane y T. Dong, distribuida para el curso
  *Decision Theory and Expert Judgment* de TU Delft. Este repositorio
  la usa **tal cual**; el único cambio propio es la lectura de los
  ficheros exportados por el cuestionario online (normalización de
  comas decimales y verificación de monotonicidad estricta de los
  cuantiles).
- **Estudio, elicitación, análisis y redacción del informe:**
  Bruno Fernandez Carballo (autor del proyecto).

---

## Licencia

Contenido académico. El código R conserva la autoría original de sus
autores; el informe y la documentación de este repositorio se comparten
con fines educativos y de reproducibilidad.
