#!/bin/bash

# 1 Modificar el archivo eliminando columnas descirption y thumbnail_link
cut -d ',' -f 1-11,13-15 supervivents.csv > supervivents_modificat.csv

# 2 Eliminar las filas con errores donde vidoe_error_or removed es True
awk -F',' '$14 != "True"' supervivents_modificat.csv > supervivents_sense_errors.csv

# Decir cuantas filas se han eliminado
total_lineas=$(wc -l < supervivents_modificat.csv)
lineas_sin_errores=$(wc -l < supervivents_sense_errors.csv)

eliminados=$(( total_lineas - lineas_sin_errores ))
echo "Filas eliminadas $eliminados"

# 3 Anadir columna Ranking_Views segun el valor de views
awk -F"," 'NR == 1 {print $0 ",Ranking_Views"; next}
{
    if ($8 < 1000000) {
        Ranking_Views = "Bo"
    } else if ($8 >= 1000000 && $8 <= 10000000) {
        Ranking_Views = "Excellent"
    } else {
        Ranking_Views = "Estrella"
    }
    print $0 "," Ranking_Views
}' supervivents_sense_errors.csv > supervivents_nou.csv

# 4 Crear dos columnas nuevas que seran el porcentaje de likes (Rlikes) y dislikes (Rdislikes)

ficheroInput="supervivents_nou.csv"
ficheroOutput="salida.csv"

cabecera=$(head -n 1 "$ficheroInput")
echo "$cabecera,Rlikes,Rdislikes" > "$ficheroOutput"

while IFS=',' read -r video_id trending_date title channel_title category_id publish_time tags views likes dislikes comment_count comments_disabled ratings_disabled video_error_or_removed ranking_views; do

	if [ "$views" -gt 0 ]; then
        	rlikes=$(( likes * 100 / views))
        	rdislikes=$(( dislikes * 100 / views))
    	else
        	rlikes=0
        	rdislikes=0
    	fi
	echo "$video_id,$trending_date,$title,$channel_title,$category_id,$publish_time,$tags,$views,$likes,$dislikes,$comment_count,$comments_disabled,$ratings_disabled,$video_error_or_removed,$ranking_views,$rlikes,$rdislikes" >> "$ficheroOutput" 

done < <(tail -n +2 "$ficheroInput")

# 5 Comprobar si se ha pasado un parametro de entrada
if [ $# -gt 0 ]; then
    if [ -f "salida.csv" ]; then
        search_param="$1"

        match=$(grep -i "$search_param" "salida.csv")

        if [ -n "$match" ]; then
            echo "$match" | cut -d ',' -f 3,6,8,9,10,16,17
        else
            echo "No se han encontrado videos con ese parametro"
        fi
    else
        echo "El archivo salida.csv no existe"
    fi
    exit 0
fi
