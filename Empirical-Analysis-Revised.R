library(tidyr)
library(dplyr)
library(countrycode)
library(wbstats)
library(WDI)
library(tidyverse)

#Data Cleaning

HealthBurden_long <-Health_Burden_Countries_2000_2023 %>% pivot_longer(cols = starts_with("20"), names_to = "Year", values_to = "Value")
HealthBurden_long

HealthBurden_final <- HealthBurden_long %>% pivot_wider(names_from= Indicators, values_from = Value)
HealthBurden_final

HealthBurden_final <- HealthBurden_final %>% select(-c('...3', 'NA'))

View(HealthBurden_final)

#Converting health spending variables into numeric variables

HealthBurden_final <- HealthBurden_final%>%
  mutate(across(-c(Countries), as.numeric))

HealthBurden_final <- HealthBurden_final[-c(1:24), ]

str(HealthBurden_final)

#Creating a composite variables to measure financial burden

HealthBurden_final$Cost_Burden = HealthBurden_final$`Out-of-pocket (OOPS) as % of Current Health Expenditure (CHE)` + HealthBurden_final$`Voluntary Health Insurance (VHI) as % of Current Health Expenditure (CHE)`

#Renaming some variables 


HealthBurden_final <- HealthBurden_final %>%
  rename(
    Social_Health = `Social Health Insurance (SHI) as % of Current Health Expenditure (CHE)`,
    Ext_Health = `External Health Expenditure (EXT) as % of Current Health Expenditure (CHE)`
  )

HealthBurden_final <- HealthBurden_final %>%
  rename (`Country Name`= Countries)

#Filtering countries!

str(HealthBurden_final)

countries_under_50_both_years <- HealthBurden_final %>%
  filter(Year %in% c(2021, 2022), Cost_Burden < 50) %>%
  group_by(Countries) %>%
  summarise(n_years = n_distinct(Year)) %>%
  filter(n_years == 2) %>%
  pull(Countries)

print(countries_under_50_both_years)

HealthBurden_final <- HealthBurden_final %>%
  filter(Countries %in% countries_under_50_both_years)

Final_Data <- Final_Data %>%
  filter(`Country Name` %in% countries_under_50_both_years)

#Add Income, Regional, and Year Fixed Effects

#Region

HealthBurden_final <- HealthBurden_final %>%
  mutate(
    Country_Code = countrycode(Countries, "country.name", "iso2c")
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

HealthBurden_final$Year <- factor(HealthBurden_final$Year)
Final_Data$Year <- factor(Final_Data$Year)

#Rerunning the regressionsss

#Making North America the Base Category

Socialhealth_Developed <- lm(Cost_Burden ~ Social_Health + Ext_Health + LatinAmerica + Europe + Africa + EastAsia + SouthEAsia + SouthAsia + MiddleEast + Oceania + Developed + Year, data=HealthBurden_final)
Socialhealth_Developed

summary(Socialhealth_Developed)

Socialhealth_Developing <- lm(Cost_Burden ~ Social_Health + Ext_Health + LatinAmerica + Europe + Africa + EastAsia + SouthEAsia + SouthAsia + MiddleEast + Oceania + Year,  data=HealthBurden_final)
Socialhealth_Developing

summary(Socialhealth_Developing)

nobs(Socialhealth_Developed)


Taxation_Developed <- lm(Cost_Burden ~ taxhealth + Ext_Health + LatinAmerica + Europe + Africa + EastAsia + SouthEAsia + SouthAsia + MiddleEast + Oceania + Developed, data=Final_Data)
Taxation_Developed

summary(Taxation_Developed)

Taxation_Developing <- lm(Cost_Burden ~ taxhealth + Ext_Health + LatinAmerica + Europe + Africa + EastAsia + SouthEAsia + SouthAsia + MiddleEast + Oceania, data= Final_Data)
Taxation_Developing

summary(Taxation_Developing)

nobs(Taxation_Developed)
summary(Socialhealth_Developing)




