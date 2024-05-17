### Import data
library(readxl)
library(ggplot2)

all_data <- read_excel("~/Documents/Projects/morphology_rice_validation/all_data.xlsx")



#############################################################################################################
### Make plot for comparing manually measured vs PCV measured LONGEST LEAF LENGTH 
longest_leaf_fit <- lm(m_longest_leaf~longest_leaf, all_data)
p_val = signif(summary(longest_leaf_fit)$coef[2,4], 5)
adjusted_r_square = signif(summary(longest_leaf_fit)$adj.r.squared, 5)

p <- ggplot(data=all_data, aes(longest_leaf, m_longest_leaf))+
  stat_smooth(method=lm) + geom_point()+ xlab("Longest Leaf (measured w PlantCV, in pixels)") +
  ylab("Manually measured longest leaf in cm") +
  stat_smooth(method = "lm", col = "red") +
  labs(title = "Longest Leaf") +
  labs(subtitle = bquote('Adjusted ' *R^2 == .(adjusted_r_square))) +
  labs(caption = paste("P-value: ", p_val))
p 
  

#############################################################################################################
### Curvature vs "leaf erectness angle" 
curve_erectness <- lm(m_avg_erectness~log(avg_curvature), all_data)

p_val = signif(summary(curve_erectness)$coef[2,4], 5)
adjusted_r_square = signif(summary(curve_erectness)$adj.r.squared, 5)

p <- ggplot(data=all_data, aes(log(avg_curvature), m_avg_erectness))+
  stat_smooth(method=lm) + geom_point()+ xlab("Leaf Curvature (log transformed, measured w PlantCV)") +
  ylab("Leaf Erectness Angle (degrees)") +
  stat_smooth(method = "lm", col = "red") +
  labs(title = "Curvature vs Leaf Erectness") +
  labs(subtitle = bquote('Adjusted ' *R^2 == .(adjusted_r_square))) +
  labs(caption = paste("P-value: ", p_val))
p 

#############################################################################################################
### Leaf Tangent Angle vs "leaf erectness angle" 
leaf_erectness <- lm(m_avg_erectness~avg_tan_angle, all_data)
p_val = signif(summary(leaf_erectness)$coef[2,4], 5)
adjusted_r_square = signif(summary(leaf_erectness)$adj.r.squared, 5)

p <- ggplot(data=all_data, aes(avg_tan_angle, m_avg_erectness))+
  stat_smooth(method=lm) + geom_point()+ xlab("Leaf Tangent Angle (measured w PlantCV, degrees)") +
  ylab("Leaf Erectness Angle (degrees)") +
  stat_smooth(method = "lm", col = "red") +
  labs(title = "Leaf Tangent Angle vs Leaf Erectness") +
  labs(subtitle = bquote('Adjusted ' *R^2 == .(adjusted_r_square))) +
  labs(caption = paste("P-value: ", p_val))
p 
 # size 80 instead, this one was actually worse though
leaf_erectness <- lm(m_avg_erectness~avg_tan_angle80, all_data)
p_val = signif(summary(leaf_erectness)$coef[2,4], 5)
adjusted_r_square = signif(summary(leaf_erectness)$adj.r.squared, 5)

p <- ggplot(data=all_data, aes(avg_tan_angle80, m_avg_erectness))+
  stat_smooth(method=lm) + geom_point()+ xlab("Leaf Tangent Angle (measured w PlantCV, degrees)") +
  ylab("Leaf Erectness Angle (degrees)") +
  stat_smooth(method = "lm", col = "red") +
  labs(title = "Leaf Tangent Angle vs Leaf Erectness") +
  labs(subtitle = bquote('Adjusted ' *R^2 == .(adjusted_r_square))) +
  labs(caption = paste("P-value: ", p_val))
p 

#############################################################################################################
### Leaf Angle vs "leaf Insertion angle" 
# leaf_angle <- lm(m_avg_leaf_angle~avg_leaf_angle, all_data)
# p_val = signif(summary(leaf_angle)$coef[2,4], 5)
# adjusted_r_square = signif(summary(leaf_angle)$adj.r.squared, 5)

leaf_angle <- lm(avg_leaf_angle_80~avg_leaf_angle, all_data)
p_val = signif(summary(leaf_angle)$coef[2,4], 5)
adjusted_r_square = signif(summary(leaf_angle)$adj.r.squared, 5)

p <- ggplot(data=all_data, aes(avg_leaf_angle_80, m_avg_leaf_angle))+
  stat_smooth(method=lm) + geom_point()+ xlab("Leaf Insertion Angle (measured w PlantCV, degrees)") +
  ylab("Leaf Angle (degrees)") +
  stat_smooth(method = "lm", col = "red") +
  labs(title = "Leaf Angle") +
  labs(subtitle = bquote('Adjusted ' *R^2 == .(adjusted_r_square))) +
  labs(caption = paste("P-value: ", p_val))
p 


#############################################################################################################
### Culm Height 
culm <- lm(m_culm_height~culm_height, all_data)
p_val = signif(summary(culm)$coef[2,4], 5)
adjusted_r_square = signif(summary(culm)$adj.r.squared, 5)

p <- ggplot(data=all_data, aes(culm_height, m_culm_height))+
  stat_smooth(method=lm) + geom_point()+ xlab("Culm Height (measured w PlantCV, pixels)") +
  ylab("Culm Height (cm)") +
  stat_smooth(method = "lm", col = "red") +
  labs(title = "Culm Height") +
  labs(subtitle = bquote('Adjusted ' *R^2 == .(adjusted_r_square))) +
  labs(caption = paste("P-value: ", p_val))
p 









####################################################################################
Old code that was inefficient 
# Make the timestamps numeric so that we can splice them 
all_sorghum_data_sv$date <- as.numeric(sapply(as.character(all_sorghum_data_sv$timestamp), function(i) strsplit(i,"-")[[1]][3])) 
all_sorghum_data_mv$date <- as.numeric(sapply(as.character(all_sorghum_data_mv$timestamp), function(i) strsplit(i,"-")[[1]][3])) 
unique(all_sorghum_data_sv$date)
unique(all_sorghum_data_mv$date)
# use timestamp to create days after planting column (first day is june 11th and first day of imaging=8DAP)
all_sorghum_data_sv$DAP <- as.numeric(sapply(as.character(all_sorghum_data_sv$timestamp), function(i) strsplit(i,"-")[[1]][3])) - 3
all_sorghum_data_mv$DAP <- as.numeric(sapply(as.character(all_sorghum_data_mv$timestamp), function(i) strsplit(i,"-")[[1]][3])) - 3
# Remove color card images  
all_sorghum_data_mv <- all_sorghum_data_mv[all_sorghum_data_mv$plantbarcode != "Cc00AA000000", ]
all_sorghum_data_sv <- all_sorghum_data_sv[all_sorghum_data_sv$plantbarcode != "Cc00AA000000", ]
########################
# Embedded in the barcode is what nitrogen treatment was applied to that
# specific plant. That embedding is “Fa###A*######” where * is the character of interest and # are just
# numbers. Using a function from the apply family, pull out this character, if it’s “A” it’s the 10
# treatment, if “B” it’s the 50 treatment, and if “C” it’s the 100 treatment. Make a new column indicating
# the treatment based on the barcode info and check to see if it matches the existing treatment column
all_sorghum_data_mv$barcode_treat_letter <- as.character(sapply(as.character(all_sorghum_data_mv$plantbarcode),function(i) strsplit(i,"")[[1]][7]))
all_sorghum_data_mv <- all_sorghum_data_mv[complete.cases(all_sorghum_data_mv[ , 20:20]), ]# Remove missing data 
all_sorghum_data_mv$nitrogen_treat <- as.character(sapply(all_sorghum_data_mv$barcode_treat_letter,function(i) if(i == "A")
{"10"}else if(i == "B"){"50"}else{"100"}))
all_sorghum_data_sv$barcode_treat_letter <- as.character(sapply(as.character(all_sorghum_data_sv$plantbarcode),function(i) strsplit(i,"")[[1]][7]))
all_sorghum_data_sv$nitrogen_treat <- as.character(sapply(all_sorghum_data_sv$barcode_treat_letter,function(i) if(i == "A")
{"10"}else if(i == "B"){"50"}else{"100"}))
########################
# Embedded in the barcode is the genotype of a
# specific plant. That embedding is “Fa***A#######” where * is the character of interest and # are just
# numbers. Using a function from the apply family, pull out this character, if it’s Genotypes 001 to 030 are:
# PI_329311, PI_213900, PI_505735, PI_329632, PI_35038, PI_585954, NTJ2, M81e, PI_229841, PI_297155, PI_506069
# PI_508366, PI_297130, Grassl, PI_152730, PI_195754, BTx623, CK60B, B.Az9504, San Chi San, ICSV700, Atlas
# Leoti, Chinese Amber, Della, Rio, PI_642998, China 17, PI_510757, PI_655972
# Make a new column indicating the genotype based on the barcode info
gl <- c("PI_329311", "PI_213900", "PI_505735", "PI_329632", "PI_35038", "PI_585954", "NTJ2", "M81e", "PI_229841", 
        "PI_297155", "PI_506069", "PI_508366", "PI_297130", "Grassl", "PI_152730", "PI_195754", "BTx623", 
        "CK60B", "B.Az9504", "SanChiSan", "ICSV700", "Atlas", "Leoti", "ChineseAmber", "Della", "Rio",
        "PI_642998", "China17", "PI_510757", "PI_655972")
all_sorghum_data_sv$genotype_num <- as.character(substr(as.character(all_sorghum_data_sv$plantbarcode), 3, 5))
all_sorghum_data_sv$genotype <- as.character(sapply(all_sorghum_data_sv$genotype_num,function(i) if(i == "001")
{gl[1]}else if(i == "002"){gl[2]}else if(i=="003"){gl[3]}else if(i=="004")
{gl[4]}else if(i=="005"){gl[5]}else if(i=="006"){gl[6]}else if(i=="007")
{gl[7]}else if(i=="008"){gl[8]}else if(i=="009"){gl[9]}else if(i=="010")
{gl[10]}else if(i=="011"){gl[11]}else if(i=="012"){gl[12]}else if(i=="013")
{gl[13]}else if(i=="014"){gl[14]}else if(i=="015"){gl[15]}else if(i=="016")
{gl[16]}else if(i=="017"){gl[17]}else if(i=="018"){gl[18]}else if(i=="019")
{gl[19]}else if(i=="020"){gl[20]}else if(i=="021"){gl[21]}else if(i=="022")
{gl[22]}else if(i=="023"){gl[23]}else if(i=="024"){gl[24]}else if(i=="025")
{gl[25]}else if(i=="026"){gl[26]}else if(i=="027"){gl[27]}else if(i=="028")
{gl[28]}else if(i=="029"){gl[29]}else if(i=="030"){gl[29]}else{"NA"}))
all_sorghum_data_mv$genotype_num <- as.character(substr(as.character(all_sorghum_data_mv$plantbarcode), 3, 5))
all_sorghum_data_mv$genotype <- as.character(sapply(all_sorghum_data_mv$genotype_num,function(i) if(i == "001")
{gl[1]}else if(i == "002"){gl[2]}else if(i=="003"){gl[3]}else if(i=="004")
{gl[4]}else if(i=="005"){gl[5]}else if(i=="006"){gl[6]}else if(i=="007")
{gl[7]}else if(i=="008"){gl[8]}else if(i=="009"){gl[9]}else if(i=="010")
{gl[10]}else if(i=="011"){gl[11]}else if(i=="012"){gl[12]}else if(i=="013")
{gl[13]}else if(i=="014"){gl[14]}else if(i=="015"){gl[15]}else if(i=="016")
{gl[16]}else if(i=="017"){gl[17]}else if(i=="018"){gl[18]}else if(i=="019")
{gl[19]}else if(i=="020"){gl[20]}else if(i=="021"){gl[21]}else if(i=="022")
{gl[22]}else if(i=="023"){gl[23]}else if(i=="024"){gl[24]}else if(i=="025")
{gl[25]}else if(i=="026"){gl[26]}else if(i=="027"){gl[27]}else if(i=="028")
{gl[28]}else if(i=="029"){gl[29]}else if(i=="030"){gl[29]}else{"NA"}))
