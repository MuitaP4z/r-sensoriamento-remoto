library(terra)

# Definir o diretório de trabalho
setwd("E:/BD Geo")
  
# Carregar o raster de classificação MapBiomas
x <- rast("mapbiomas_collection90_deforestation_secondary_vegetation_v1-classification_2023.tif")

# Carregar o shapefile do bioma Cerrado
shp <- vect("Cerrado SHP (Bruno)/cerrado.shp")

# Garantir que ambos têm o mesmo sistema de projeção
if (!crs(x) == crs(shp)) {
  shp <- project(shp, crs(x))
}

# Recortar o raster para a extensão do shapefile
x_crop <- crop(x, shp)

# Aplicar máscara para manter só o bioma Cerrado
x_mask <- mask(x_crop, shp)

# Filtrar para manter apenas classe 1 (Anthropic)
x_mask[x_mask != 1] <- NA

# Salvar o raster filtrado
writeRaster(x_mask, filename = "mask_anthropic_only.tif", overwrite = TRUE)

# (opcional) Agregar para reduzir resolução (se necessário)
# x_mask_agg <- aggregate(x_mask, fact = 18, fun = modal, na.rm = TRUE)

# Salvar raster agregado
# writeRaster(x_mask_agg, filename = "mask_anthropic_only_aggregated.tif", overwrite = TRUE)
