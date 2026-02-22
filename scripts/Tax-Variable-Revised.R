library(tidyr)
library(dplyr)
library(countrycode)
library(wbstats)
library(WDI)
library(tidyverse)


TaxRev <- API_GC_TAX_TOTL_CN_DS2_en_excel_v2_1253 %>%
  filter(`Country Name` %in% countries_under_50_both_years)

TaxRev <- API_GC_TAX_TOTL_CN_DS2_en_excel_v2_1253 %>% pivot_longer(cols= starts_with("20"), names_to= "Year", values_to= "Value")
TaxRev

TaxRev <- TaxRev %>% pivot_wider(names_from= `Indicator Name`, values_from= Value)
TaxRev

View(TaxRev)


OtherRev <- API_GC_REV_GOTR_CN_DS2_en_excel_v2_1183 %>%
  filter(`Country Name` %in% countries_under_50_both_years)

OtherRev <- API_GC_REV_GOTR_CN_DS2_en_excel_v2_1183 %>% pivot_longer(cols= starts_with("20"), names_to= "Year", values_to="Value")
OtherRev

OtherRev <- OtherRev %>% pivot_wider(names_from= `Indicator Name`, values_from= Value)
OtherRev 

View(TaxRev)

View(OtherRev)

str(TaxRev)
str(OtherRev)

TaxRev$Year <- as.numeric(as.character(TaxRev$Year))
OtherRev$Year <- as.numeric(as.character(OtherRev$Year))

colnames(TaxRev)
colnames(OtherRev)

#Trying ChatGPT Merge Code

TaxRev$`Country Name` <- as.character(TaxRev$`Country Name`)
TaxRev$`Country Code` <- as.character(TaxRev$`Country Code`)
TaxRev$Year <- as.character(TaxRev$Year)

OtherRev$`Country Name` <- as.character(OtherRev$`Country Name`)
OtherRev$`Country Code` <- as.character(OtherRev$`Country Code`)
OtherRev$Year <- as.character(OtherRev$Year)


TotalRev <- merge(TaxRev, OtherRev, 
                     by = c("Country Name", "Country Code", "Year"))

View(TotalRev)

#############################################3


TotalRev <- TotalRev %>% 
  mutate(across(-c(`Country Name`, `Country Code`, Year), as.numeric))

TotalRev[] <- lapply(TotalRev, function(x) {
  if (is.numeric(x)) {
    x[is.na(x)] <- mean(x, na.rm = TRUE)
  }
  return(x)
})

#Creating GGE Variable

TotalRev$GGE <- TotalRev$`Tax revenue (current LCU)`+ TotalRev$`Grants and other revenue (current LCU)`

#Aggregate health expenditure as a % of GGE

gghe_percapita <- API_SH_XPD_GHED_PP_CD_DS2_en_excel_v2_17513 %>% pivot_longer(cols= starts_with("20"), names_to="Year", values_to="Value")
gghe_percapita

gghepercapita_final <- gghe_percapita %>% pivot_wider(names_from= `Indicator Name`, values_from= Value)
gghepercapita_final 

totalpop <- API_SP_POP_TOTL_DS2_en_excel_v2_76243 %>% pivot_longer(cols= starts_with("20"), names_to="Year", values_to="Value")
totalpop

totalpop_final <- totalpop %>% pivot_wider(names_from= `Indicator Name`, values_from= Value)
totalpop_final

#Merging health exp and population datasets

gghepercapita_final$`Country Name` <- as.character(gghepercapita_final$`Country Name`)
gghepercapita_final$`Country Code` <- as.character(gghepercapita_final$`Country Code`)
gghepercapita_final$Year <- as.character(gghepercapita_final$Year)

totalpop_final$`Country Name` <- as.character(totalpop_final$`Country Name`)
totalpop_final$`Country Code` <- as.character(totalpop_final$`Country Code`)
totalpop_final$Year <- as.character(totalpop_final$Year)


TotalExp <- merge(gghepercapita_final, totalpop_final,by = c("Country Name", "Country Code", "Year"))
TotalExp

View(TotalExp)

TotalExp$AggGGHE <- TotalExp$`Domestic general government health expenditure per capita, PPP (current international $)`* TotalExp$`Population, total`

TotalExp <- TotalExp %>% 
  mutate(across(-c(`Country Name`,`Country Code`, Year), as.numeric))


TotalExp[] <- lapply(TotalExp, function(x) {
  if (is.numeric(x)) {
    x[is.na(x)] <- mean(x, na.rm = TRUE)
  }
  return(x)
})

#MergingDatasets



TotalExp$taxhealth <- (TotalExp$AggGGHE*TotalRev$`Tax revenue (current LCU)`)/TotalRev$GGE


View(TotalExp)


#Math two datasets to run a regression on taxation

intersect(colnames(TotalExp), colnames(HealthBurden_final))

HealthBurden_final$`Country Name` <- as.character(HealthBurden_final$`Country Name`)
HealthBurden_final$Year <- as.character(HealthBurden_final$Year)

TotalExp$`Country Name` <- as.character(TotalExp$`Country Name`)
TotalExp$Year <- as.character(TotalExp$Year)

Final_Data <- merge(HealthBurden_final, TotalExp, 
                                  by = c("Country Name", "Year"), 
                                  all.x = TRUE)

view(Final_Data)
