#install.packages('tidyverse')
#install.packages('SAScii')

# Load Libaries
library(SAScii)
library(stringr)

# Settings
dict_folder <- '~/Downloads/'
data_folder <- '~/Downloads/'
output_folder <- '~/Downloads/'

# Construct a listing of the files in your directory
filenames <- dir(data_folder) %>% str_replace('-Data.txt', '') %>% str_replace('-Setup.sas', '') %>% unique()
filenames <- c("00001-0010")

# Iterate over all files in the directory
for (i in 1:length(filenames)){
  # Set filepaths
  data_path <- paste0(data_folder, filenames[i], '-Data.txt')
  dict_path <- paste0(dict_folder, filenames[i], '-Setup.sas')
  output_path <- paste0(dict_folder, 'PARSED-', filenames[i], '.tsv') 
  
  # Load in ASCII Data
  df <- read.SAScii(data_path, dict_path)
  
  # Parse the dictionary for variable names
  dict <- readChar(dict_path, file.info(dict_path)$size)
  raw_names <- regmatches(dict, regexpr('V1\\s=\\s.*?;', dict))
  raw_names_vector <- strsplit(raw_names, '\n')[[1]]
  col_names <- (
    raw_names_vector 
    %>% str_trim() 
    %>% str_extract('\".*\"') 
    %>% str_replace_all(fixed('"'), '')
  )
  
  colnames(df) <- col_names
  
  # Write to output
  write.table(df, output_path, quote=F, sep='\t')
  
}
