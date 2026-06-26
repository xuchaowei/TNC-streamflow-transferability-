library(tidyverse)
library(patchwork)
library(grid)
library(ggtext)
library(ggsignif)
library(stringr)
library(reshape2)

data <- read.csv("data.csv")


long_data <- melt(data, id = c("AgeGroup", "Type")) %>%
  mutate(AgeGroup = factor(AgeGroup, levels = c("Genome-Wild", "Very ancient","Ancient", "Recent/very recent")),
         Type = factor(Type, levels = c("GB", "AUS","YR", "CL","CE","AR","USA")))

# str_wrap
long_data$Type <- str_wrap(long_data$Type, width = 12)

create_box_plot <- function(data, age_group, title, y_limits, y_breaks, p_position, fill_color, bg_colors) {
  gradient_grob <- rasterGrob(colorRampPalette(bg_colors)(256), width = unit(1, "npc"), height = unit(1, "npc"), interpolate = TRUE)
  # (77Type)
  type_colors <- c(
    "GB" = "#F0ECF7",
    "AUS" = "#CAADD8",
    "YR" = "#AF8FD0",
    "CL" ="#EFC0D2",
    "CE" = "#F6ECF6",
    "AR" = "#DA70D6",
    "USA" = "#DDA0DD"
  )
  plot <- ggplot(subset(data, AgeGroup == age_group),
                 aes(x = Type, y = value, fill = Type)) +
    annotation_custom(gradient_grob,xmin = -Inf, xmax = Inf, ymin = -Inf, ymax = Inf) +
    geom_violin(trim = FALSE) +
    stat_summary(fun.data="mean_sdl", fun.args = list(mult=1),
                 geom="crossbar", width=0.3, size = 0.3) +
    #geom_boxplot(width = 0.6) +
    # geom_signif(comparisons = list(c("Reference","Specialized\nfor diapause")),
    #             map_signif_level = function(p) {paste("italic(P) == ", sprintf("%.2g", p))                },
    #             y_position = p_position,
    #             textsize = 4, tip_length = 0,
    #             parse = TRUE) +
    scale_fill_manual(values = type_colors) +
    scale_y_continuous(limits = y_limits, breaks = y_breaks, expand = c(0, 0)) +
    labs(title = title, x = NULL, y = "R2") +
    theme_classic(base_size = 14) +
    theme(plot.margin = margin(t = 10, r = 5, b = 5, l = 5),
          plot.title = element_textbox_simple(size = 12, color = "white", halign = 0.5,
                                              fill = fill_color, width = 1.1,
                                              padding = margin(2, 0, 2, 0),
                                              margin = margin(0, 0, 5, 0)),
          axis.text.x = element_text(angle = 45, hjust = 1, size = 11, color = "black"),
          axis.text.y = element_text(color = "black"),
          legend.position = "none")
}

params <- list(
  list(age_group = "Genome-Wild", title = "R2-Training period",
       y_limits = c(0, 1), y_breaks = seq(0, 1, 0.2), p_position = 0.44,
       fill_color = "#878789", bg_colors = c("white", "#FBFBFB", "#BEBEBE")),
  list(age_group = "Very ancient", title = "R2-Testing period",
       y_limits = c(0, 1), y_breaks = seq(0, 1, 0.2), p_position = 0.35,
       fill_color = "#0EACC9", bg_colors = c("white", "#EDF7F9", "#B1D8E7")),
  list(age_group = "Ancient", title = "KGE-Training period",
       y_limits = c(0, 1), y_breaks = seq(0, 1, 0.2), p_position = 0.35,
       fill_color = "#A184BC", bg_colors = c("white", "#E8DFF0", "#BFA0CC")),
  list(age_group = "Recent/very recent", title = "KGE-Testing period",
       y_limits = c(0, 1), y_breaks = seq(-1, 1, 0.2), p_position = 1.35,
       fill_color = "#E57164", bg_colors = c("white", "#FEEBDD", "#F7B78B"))
)

plots <- lapply(params, function(p) {
  plot <- create_box_plot(long_data,
                          p$age_group,
                          p$title,
                          p$y_limits,
                          p$y_breaks,
                          p$p_position,
                          p$fill_color,
                          p$bg_colors)
})

#  patchwork
#combined_plot <- wrap_plots(plots, ncol = 4)

combined_plot <- wrap_plots(plots, ncol = 4) +
  plot_layout(ncol = 4, widths = c(1, 1, 1, 1)) &
  theme(plot.margin = margin(0, 0, 0, 0))

print(combined_plot)

ggsave("gradient_grob_boxmy10.png", width = 10, height = 4)
#ggsave("gradient_grob_box.pdf", width = 6.5, height = 4)
