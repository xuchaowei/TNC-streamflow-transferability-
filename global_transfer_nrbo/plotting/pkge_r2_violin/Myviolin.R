library(ggplot2)
library(patchwork)
library(grid)
library(ggtext)
library(ggsignif)
library(stringr)
library(readxl)  # readxlExcel
library(dplyr)   # dplyr

# Excel
# "your_file.xlsx"
excel_data <- read_excel("dataz.xlsx")

# ,
print(head(excel_data))
print(colnames(excel_data))

# Excel
# Excel:AgeGroup, Type1, Type2, Type3, Type4, Type5, Type6, Type7

# 1:Excel(AgeGroup, Type, Value)
# data <- excel_data %>% rename(Value = your_value_column_name)

# 2:Excel(Type)
data <- excel_data %>%
  pivot_longer(
    cols = -AgeGroup,  # AgeGroup
    names_to = "Type",
    values_to = "Value"
  )

# str_wrap
data$Type <- str_wrap(data$Type, width = 12)

print(head(data))
print(unique(data$Type))  # Type

create_violin_plot <- function(data, age_group, title, y_limits, y_breaks, p_position, fill_color, bg_colors) {

  # AgeGroup
  plot_data <- subset(data, AgeGroup == age_group)

  gradient_grob <- rasterGrob(colorRampPalette(bg_colors)(256), width = unit(1, "npc"), height = unit(1, "npc"), interpolate = TRUE)

  plot <- ggplot(plot_data, aes(x = Type, y = Value, fill = Type)) +
    annotation_custom(gradient_grob, xmin = -Inf, xmax = Inf, ymin = -Inf, ymax = Inf) +
    geom_violin(trim = FALSE) +
    stat_summary(fun.data = "mean_sdl", fun.args = list(mult = 1),
                 geom = "crossbar", width = 0.3, size = 0.3) +
    scale_fill_manual(values = fill_color) +
    scale_y_continuous(limits = y_limits, breaks = y_breaks, expand = c(0, 0)) +
    labs(title = title, x = NULL, y = "Fraction of total paralogs") +
    theme_classic(base_size = 12) +
    theme(plot.margin = margin(t = 20, r = 10, b = 10, l = 10),
          plot.title = element_textbox_simple(size = 11, color = "white", halign = 0.5,
                                              fill = fill_color[1],
                                              width = 1.2,
                                              padding = margin(3, 0, 3, 0),
                                              margin = margin(0, 0, 10, 0)),
          axis.text.x = element_text(angle = 45, hjust = 1, size = 11, color = "black"),
          axis.text.y = element_text(color = "black"),
          legend.position = "none")

  return(plot)
}

# 7Type,AgeGroup7
params <- list(
  list(age_group = "Very ancient",
       title = "Very ancient<br>(> 473 mya)",
       y_limits = c(0, 10),
       y_breaks = seq(0, 10, 2),
       p_position = 0.9,
       fill_color = c("#9C9C9C", "#0EACC9", "#A184BC", "#E57164", "#4DAF4A", "#FF7F00", "#984EA3"),  # 7
       bg_colors = c("white", "#EDF7F9", "#B1D8E7")),

  list(age_group = "Ancient",
       title = "Ancient<br>(111-473 mya)",
       y_limits = c(0, 10),
       y_breaks = seq(0, 10, 2),
       p_position = 0.9,
       fill_color = c("#9C9C9C", "#0EACC9", "#A184BC", "#E57164", "#4DAF4A", "#FF7F00", "#984EA3"),  # 7
       bg_colors = c("white", "#E8DFF0", "#BFA0CC")),

  list(age_group = "Recent/very recent",
       title = "Recent/very recent<br>(0-111 mya)",
       y_limits = c(0, 10),
       y_breaks = seq(0, 10, 2),
       p_position = 0.9,
       fill_color = c("#9C9C9C", "#0EACC9", "#A184BC", "#E57164", "#4DAF4A", "#FF7F00", "#984EA3"),  # 7
       bg_colors = c("white", "#FEEBDD", "#F7B78B"))
)

plots <- lapply(params, function(p) {
  plot <- create_violin_plot(data,
                             p$age_group,
                             p$title,
                             p$y_limits,
                             p$y_breaks,
                             p$p_position,
                             p$fill_color,
                             p$bg_colors)
})

#  patchwork
combined_plot <- wrap_plots(plots, ncol = 3)

print(combined_plot)

ggsave("gradient_grob_violin.png", width = 12, height = 6)  # 7
ggsave("gradient_grob_violin.pdf", width = 12, height = 6)
