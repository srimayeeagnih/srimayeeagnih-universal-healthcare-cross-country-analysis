library(tidyr)
library(dplyr)
library(countrycode)
library(wbstats)
library(WDI)
library(tidyverse)
library(ggplot2)

install.packages("frontier")
library(frontier)

view(HealthBurden_final)

countries_over_50_both_years <- HealthBurden_final %>%
  filter(Year %in% c(2021, 2022), Cost_Burden > 50) %>%
  group_by(`Country Name`) %>%
  summarise(n_years = n_distinct(Year)) %>%
  filter(n_years == 2) %>%
  pull(`Country Name`)

print(countries_over_50_both_years)

HealthBurden_final <- HealthBurden_final %>%
  filter(`Country Name` %in% countries_over_50_both_years)

view(HealthBurden_final)

HealthBurden_final$Year <- factor(HealthBurden_final$Year)

view(HealthBurden_final)

HealthBurden_final <- HealthBurden_final %>%
  mutate(
    Country_Code = countrycode(`Country Name`, "country.name", "iso2c")
  )

wb_data <- wbcountries()
View(wb_data)

unique(wb_data$income)

HealthBurden_final <- HealthBurden_final %>%
  mutate(
    Region = countrycode(Country_Code, "iso2c", "region"),
    Income = wb_data$income[match(Country_Code, wb_data$iso2c)]
  )
View(HealthBurden_final)

HealthBurden_final <- HealthBurden_final %>%
  mutate(
    Developed = ifelse(Income %in% c("High income", "Upper middle income"), 1, 0),
    Developing = ifelse(Income %in% c("Lower middle income", "Low income"), 1, 0)
  )


HealthBurden_final <- HealthBurden_final %>%
  mutate(
    Region = case_when(
      Country_Code %in% c("CN", "JP", "KR", "MN", "HK", "MO", "TW") ~ "East Asia",
      Country_Code %in% c("ID", "MY", "PH", "SG", "TH", "VN", "LA", "KH", "MM", "BN", "TL") ~ "Southeast Asia",
      Country_Code %in% c("AU", "NZ", "PG", "FJ", "SB", "VU", "WS", "TO", "TV") ~ "Oceania",
      TRUE ~ Region)  # Keep original classification for other regions
  )

HealthBurden_final <- HealthBurden_final %>%
  mutate(
    LatinAmerica = ifelse(Region == "Latin America & Caribbean", 1, 0),
    NorthAmerica = ifelse(Region == "North America", 1, 0),
    Africa = ifelse(Region == "Sub-Saharan Africa", 1, 0),
    Europe = ifelse(Region == "Europe & Central Asia", 1, 0),
    EastAsia = ifelse(Region == "East Asia & Pacific", 1, 0),
    SouthAsia = ifelse(Region == "South Africa", 1, 0),
    SouthEAsia = ifelse(Region == "Southeast Asia", 1, 0),
    Oceania = ifelse(Region == "Oceania", 1, 0),
    MiddleEast = ifelse(Region == "Middle East & North Africa", 1, 0),
  )


view(HealthBurden_final)

#Filling in NA Values

str(HealthBurden_final)

HealthBurden_final[] <- lapply(HealthBurden_final, function(x) {
  if (is.numeric(x)) {
    x[is.na(x)] <- mean(x, na.rm = TRUE)
  }
  return(x)
})


#SFA 


HealthBurden_final$lcostburden = log(HealthBurden_final$Cost_Burden, base=exp(1))
HealthBurden_final$lsocialhealth = log(HealthBurden_final$Social_Health, base= exp(1))

#Developed Countries

Developed_data <- HealthBurden_final %>%
  filter(Developed == 1) %>%
  mutate(
    log_cost = log(Cost_Burden),
    log_shi = log(Social_Health),
    log_ext = log(Ext_Health)
  )

View(Developed_data)

#Developing Countries


#SFA Regression


#SFA Taxation**

view(Merged_Developing)


Merged_Developing$log_cost <- ifelse(is.na(Merged_Developing$Cost_Burden) | Merged_Developing$Cost_Burden <= 0, NA, log(Merged_Developing$Cost_Burden))
Merged_Developing$log_tax <- ifelse(is.na(Merged_Developing$taxhealth) | Merged_Developing$taxhealth <= 0, NA, log(Merged_Developing$taxhealth))
Merged_Developing$log_shi <- ifelse(is.na(Merged_Developing$Social_Health.x) | Merged_Developing$Social_Health.x <= 0, NA, log(Merged_Developing$Social_Health.x))
Merged_Developing$log_ext <- ifelse(is.na(Merged_Developing$Ext_Health.x) | Merged_Developing$Ext_Health.x <= 0, NA, log(Merged_Developing$Ext_Health.x))

sfa_tax_developing <- sfa(log_cost ~ log_tax + log_ext + LatinAmerica + Africa + MiddleEast + Oceania + Year, data=Merged_Developing)
sfa_tax_developing

Merged_Developed$log_cost <- ifelse(is.na(Merged_Developed$Cost_Burden) | Merged_Developed$Cost_Burden <= 0, NA, log(Merged_Developed$Cost_Burden))
Merged_Developed$log_tax <- ifelse(is.na(Merged_Developed$taxhealth) | Merged_Developed$taxhealth <= 0, NA, log(Merged_Developed$taxhealth))
Merged_Developed$log_shi <- ifelse(is.na(Merged_Developed$Social_Health.x) | Merged_Developed$Social_Health.x <= 0, NA, log(Merged_Developed$Social_Health.x))
Merged_Developed$log_ext <- ifelse(is.na(Merged_Developed$Ext_Health.x) | Merged_Developed$Ext_Health.x <= 0, NA, log(Merged_Developed$Ext_Health.x))

sfa_tax_developed <- sfa(log_cost ~ log_tax + log_ext + Africa + Oceania + Year, data=Merged_Developed)
sfa_tax_developed

efficiency_scores2 <- efficiencies(sfa_tax_developed)
print(efficiency_scores2)

#SFA Social Health Insurance

sfa_shi_developing <- sfa(log_cost ~ log_shi + log_ext + LatinAmerica + Africa + MiddleEast + Oceania + Year, data= Merged_Developing)
sfa_shi_developing

efficiency_scores3 <- efficiencies(sfa_shi_developing)
print(efficiency_scores3)

sfa_shi_developed <- sfa(log_cost ~ log_shi + log_ext + Africa + Year, data= Merged_Developed)
sfa_shi_developed

efficiency_scores4 <- efficiencies(sfa_shi_developed)
print(efficiency_scores4)

Merged_Developing$efficiency_score <- NA


missing_indices <- c(1:24, 97:120, 145:155, 169:245, 289:306, 313:336, 361:367,
                     385:408, 457:470, 481:528, 553:572, 577:600, 673:678,
                     721:744, 769:771, 793:816, 841:864, 889:901, 913:960) + 1

valid_indices <- setdiff(1:nrow(HealthBurden_Developing), missing_indices)

length(valid_indices)
length(efficiency_scores)

HealthBurden_Developing$efficiency_score[valid_indices] <- efficiency_scores


#Developing and Social Health Insurance





#Plots!!

ggplot(HealthBurden_Developing, aes(x = efficiency_score)) +
  geom_histogram(fill = "steelblue", color = "white", bins = 30) +
  labs(title = "Efficiency Score Distribution of Social Health Insurance Programs Among Developing Countries",
       x = "Efficiency Score", y = "Count") +
  theme_minimal()


#Developed and Taxation

View(Final_Data)
str(Final_Data)

Developed_Tax_Data <- Final_Data %>%
  filter(Developed == 1) %>%
  mutate(
    log_cost= log(Cost_Burden),
    log_shi= log(Social_Health),
    log_ext= log(Ext_Health),
    log_tax= log(taxhealth)
  )
Developed_Tax_Data <- Developed_Tax_Data %>%
  drop_na(log_cost, log_shi, log_ext, log_tax)
  

#Always seems to be a multicollinearity problem with developed countries...

sfa_tax_developed <- sfa(log_cost ~ log_tax + log_ext + LatinAmerica + Europe + Africa + EastAsia + SouthEAsia + SouthAsia + MiddleEast + Oceania, data=Developed_Tax_Data)
sfa_tax_developed

Final_Data_Developing <- Final_Data_Developing %>%
  mutate(
    log_cost= log(Cost_Burden),
    log_shi= log(Social_Health),
    log_ext= log(Ext_Health),
    log_tax= log(taxhealth)
  )

view(Final_Data_Developing)

Developing_Tax_Data <- Developing_Tax_Data %>%
  drop_na(log_cost, log_shi, log_ext, log_tax)

sfa_tax_developing <- sfa(log_cost ~ log_tax + log_ext + LatinAmerica + Europe + Africa + EastAsia + SouthEAsia + SouthAsia + MiddleEast + Oceania, data=Developing_Tax_Data)
sfa_tax_developing 

#Build a Confidence Interval


