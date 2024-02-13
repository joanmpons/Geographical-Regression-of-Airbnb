# Airbnb
*R, Geographical Regression*
<p align="justify"> 
La finalidad del proyecto es estudiar el impacto de la localización en el precio de los pisos ofertados en la plataforma Airbnb y algunos de sus predictores. Es decir, más allá de intentar determinar si los apartamentos céntricos presentan precios más elevados, se analiza cómo cambia la importancia de este y otros predictores, como la capacidad o el número de reseñas, para alojamientos en diferentes zonas de Barcelona. Esto se consigue gracias a la aplicación de un modelo de regresión ponderada geográficamente (GWR). 
</p>

## Objetivos 
- Estudiar la distribución de los alojamientos Airbnb en Barcelona
- Analizar el efecto de la localización en el precio y sus predictores
- Crear un modelo de predicción para el precio de los alojamientos

## Resultados 
- Los Airbnb se concentran en el centro y cerca del puerto
- La interacción entre precio y distancia varía espacialmente
- Modelo predictivo con un R2 casi global de 0.66

## Proyecto

### Mapa de densidad de los alojamientos
<p align="justify"> 
Como preámbulo, resulta interesante visualizar cómo se distribuye la oferta de Airbnb en Barcelona. Debido al elevado número de observaciones, se optó por un mapa de densidad.

Los alojamientos ofertados se concentran en los distritos de Ciutat Vella y Eixample, es decir, en las zonas céntricas y cercanas al paseo marítimo.
</p>

### Gráfico hexagonal del precio
<p align="justify"> 
Durante el análisis de los datos, los gráficos hexagonales permitieron analizar varias medidas estadísticas del precio con relación a la localización. Por su simplicidad y claridad resultan herramientas formidables para estudiar datos geográficos.

En este caso, puede intuirse la silueta de Barcelona, donde cada hexágono agrupa alojamientos cercanos. El color indica el precio medio para cada conjunto y revela zonas con precios significativamente más elevados en el frente marítimo y cerca del centro, así como algunos picos en el distrito de Sarrià-Sant Gervasi.
</p>

<p align="center">
<img src="Images/Graph_1" width="500">
</p>

### Porcentaje de Menciones en los Resultados
<p align="justify"> 
Aunque puede resultar muy útil conocer el total de menciones, saber el porcentaje que estas representan respecto al resto de resultados enriquece el análisis sobre la presencia online de la empresa.

Como puede observarse La Vanguardia esta en un 8,33% de los headers y en un 15,5% de los resultados para el conjunto de la búsqueda.
</p>

<p align="center">
<img src="Images/Graph_2" width="500">
</p>

### Ranking por Búsqueda
<p align="justify"> 
Otro indicador importante es saber cómo se distribuyen las menciones entre las distintas búsquedas tanto para los headers como para los resultados.

En este gráfico podemos cuáles han sido las búsquedas relacionadas sugeridas por Google así como el ranking de La Vanguardia en los distintos casos. De aquí podemos obtener dos conclusiones interesantes, la primera es que una de la búsquedas sugeridas ha sido la propia empresa, un muy buen indicador. La segunda es que La Vanguardia tiende a no incluir el nombre de la empresa en los headers.
</p>

<p align="center">
<img src="Images/Graph_3" width="500">
</p>

### Número de Menciones por Ranking
<p align="justify"> 
Finalmente, un buen medidor global del posicionamiento online de la empresa es el recuento de menciones en el entre el top tres de los resultados en Google.

En este caso el resultado es de una mención en el top uno tanto para headers como para resultados, una en el top dos para resultados y una para headers y resultados en el top 3.
</p>

<p align="center">
<img src="Images/Graph_4" width="500">
</p>

### Creación del Documento de Reporting
<p align="justify"> 
Si la aplicación tiene que ser usada por usuarios no técnicos, lo mas conveniente es crear un archivo ejecutable o un .bat a partir del script que genere un archivo con los gráficos presentados anteriormente. En este caso las visualizaciones se han realizado con la librería plotly, una de las ventajas de la cual es que cuenta con una función para extraer los gráficos en formato html e incrustarlos en un archivo.

<p align="center">
<img src="Images/HTML" width="500">
</p>
