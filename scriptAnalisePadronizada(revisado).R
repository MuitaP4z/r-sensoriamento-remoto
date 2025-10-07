# Objetivo: Padronizar rasters (ex: EVI/LAI) segundo um modelo de referência e aplicar máscara antrópica
library(terra)

# Definir diretório de trabalho
setwd("E:/BD Geo")

# Caminhos
modelo_path  <- "L22.GEDI.HBfuel.nc"
mascara_path <- "mask_anthropic_only.tif"
input_dir    <- "data/"
output_dir   <- "padronizados_alt/"

# Criar pasta de saída se não existir
if (!dir.exists(output_dir)) dir.create(output_dir)

# Carregar modelo de referência e máscara
modelo  <- rast(modelo_path)
mascara <- rast(mascara_path)

# Função alternativa de padronização
padronizar_raster_alt <- function(entrada_path, saida_path, modelo, mascara) {
  r <- rast(entrada_path)
  
  # 1. Reprojetar raster de entrada para o CRS do modelo (se necessário)
  if (!compareGeom(r, modelo, crs = TRUE, stopOnError = FALSE)) {
    r <- project(r, modelo)
  }
  
  # 2. Recortar para extensão do modelo
  r <- crop(r, ext(modelo), snap = "out")
  
  # 3. Reamostrar para grade do modelo
  r <- resample(r, modelo, method = "bilinear")
  
  # 4. Alinhar e reprojetar a máscara para coincidir com raster r
  mascara_proj <- project(mascara, r)
  mascara_res  <- resample(mascara_proj, r, method = "near")
  
  # 5. Classificar: 1 (antrópico) → NA, outros mantêm
  regras <- matrix(c(1, 1, NA), ncol = 3, byrow = TRUE)
  mascara_binaria <- classify(mascara_res, regras)
  
  # 6. Aplicar máscara
  r <- mask(r, mascara_binaria)
  
  # 7. Preservar nome original da camada
  names(r) <- names(rast(entrada_path))
  
  # 8. Exportar
  writeRaster(r, filename = saida_path, overwrite = TRUE)
}

# Processar todos os arquivos
arquivos <- list.files(input_dir, pattern = "\\.tif$", full.names = TRUE)

for (arquivo in arquivos) {
  nome_base <- tools::file_path_sans_ext(basename(arquivo))
  saida     <- file.path(output_dir, paste0(nome_base, "_padronizado_alt.tif"))
  message("[ALT] Processando: ", basename(arquivo))
  padronizar_raster_alt(arquivo, saida, modelo, mascara)
}

message("[ALT] Processamento concluído. Arquivos salvos em: ", output_dir)
