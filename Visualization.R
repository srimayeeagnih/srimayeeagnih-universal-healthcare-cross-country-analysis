

view(Merged_data)
view(Merged_Developed)

ggplot(Merged_Developed_Standard, aes(x = Social_Health.x, y = taxhealth)) +
  geom_point(alpha = 0.6) +
  geom_smooth(method = "lm", se = FALSE) +
  labs(title = "Taxation vs Social Health Insurance, Developed Countries",
       x = "Social Health Insurance (Standardized)",
       y = "Taxation (Standardized)") +
  theme_minimal()

ggplot(Merged_Developing_Standard, aes(x = Social_Health.x, y = taxhealth)) +
  geom_point(alpha = 0.6) +
  geom_smooth(method = "lm", se = FALSE) +
  labs(title = "Taxation vs Social Health Insurance, Developing Countries",
       x = "Social Health Insurance (Standardized)",
       y = "Taxation (Standardized)") +
  theme_minimal()