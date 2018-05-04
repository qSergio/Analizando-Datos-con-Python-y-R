library(nycflights13)

flights
  
#int son enteros
#dbl doubles, números reales
#chr caracteres o strings
#dttm son date-times (date + time)
#lgl logical, TRUE o FALSE
#fctr son los factores, variables categóricas
#date fechas.

#Para hacer consultas se usa dplyr. Las funciones básicas son las siguientes:

#filter() elige entre observaciones (por renglón) de acuerdo a un valor
#arrange() reordena las variables
#select()
#mutate() crea nuevas variables como función de variables existentes
#summarise() proyecta variables a un solo valor
#group_by() cambia el dominio de una función para que opere por agrupaciones

#Estructura:
  
# 1) El primer argumento siempre es un data frame

# 2) Los siguientes argumentos describen las acciones sobre el data frame y sobre las variables

# 3) El resultado es un nuevo data frame

filter(flights, month == 1, day == 1)

filter(flights, month = 1)

1/77 * 77 == 1

near(1 / 77 * 77, 1)

filter(flights, month == 11 | month == 12)

nov_dic <- filter(flights, month %in% c(11, 12))

filter(flights, !(arr_delay > 120 | dep_delay > 120))
filter(flights, arr_delay <= 120, dep_delay <= 120)

arrange(flights, year, month, day)

# Selección de las columnas por nombres
select(flights, year, month, day)

select(flights, year:day)

# Selección por excepciones inclusiva
select(flights, -(year:day))

# el argumento *everithing()* tiene un uso especial
select(flights, time_hour, air_time, everything())

# Nuevas variables con mutate

flights_con_retraso <- select(flights, 
                      year:day, 
                      ends_with("delay"), 
                      distance, 
                      air_time
)

mutate(flights_con_retraso,
       ganancia = arr_delay - dep_delay,
       rapidez = distance / air_time * 60
)

#transmute es para mantener o mostrar únicamente las nuevas variables

transmute(flights,
          ganancia = arr_delay - dep_delay,
          tiempo_en_horas = air_time / 60,
          ganancia_por_hora = ganancia / tiempo_en_horas
)

#Las operaciones de módulo y residuo
transmute(flights,
          dep_time,
          hora = dep_time %/% 100,
          minuto = dep_time %% 100
)

# Uso de summarise

summarise(flights, delay = mean(dep_delay, na.rm = TRUE))

# usar en agrupaciones

agrupar_por_dia <- group_by(flights, year, month, day)
summarise(agrupar_por_dia, retraso = mean(dep_delay, na.rm = TRUE))


# Todo junto en un ejemplo:

# Agrupar los vuelos por destino

# Usamos Summarise para calcular la distancia, retraso promedio y el número de vuelos

# Se usa Filter para remover "posible" ruido y un destino aleatorio que se ve que está muy lejos, por qué?


por_destino <- group_by(flights, dest)

retrasos <- summarise(por_destino,
                   count = n(),
                   distancia = mean(distance, na.rm = TRUE),
                   retrasos = mean(arr_delay, na.rm = TRUE)
)

retrasos <- filter(retrasos, count > 20, dest != "HNL")

# ¿Qué conclusiones podemos sacar?
# ¿Qué sucede a una distancia promedio de ~750 mi? 

ggplot(data = retrasos, mapping = aes(x = distancia, y = retrasos)) +
  geom_point(aes(size = count), alpha = 1/3) +
  geom_smooth(se = FALSE)


# Ejercicio: Reescriba el ejemplo usando el "pipe" de dplyr:


# Referencias:

# Chester Ismay and Albert Y. Kim, "An Introduction to Statistical and Data Sciences via R", 2018, http://www.moderndive.org/

# De este libro han salido todos los ejemplos, así que lo mejor es usarlo de referencia directa.

















delays <- flights %>% 
  group_by(dest) %>% 
  summarise(
    count = n(),
    dist = mean(distance, na.rm = TRUE),
    delay = mean(arr_delay, na.rm = TRUE)
  ) %>% 
  filter(count > 20, dest != "HNL")
