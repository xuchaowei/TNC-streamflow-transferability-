library(ggplot2)
library(patchwork)
library(grid)
library(ggtext)
library(ggsignif)
library(stringr)

data <- read.csv("data.csv")


long_data <- melt(data, id = c("AgeGroup", "Type")) %>%
  mutate(AgeGroup = factor(AgeGroup, levels = c("Genome-Wild", "Very ancient", "Ancient", "Recent/very recent")),
         Type = factor(Type, levels = c("Reference", "Specialized for diapause")))

# str_wrap
long_data$Type <- str_wrap(long_data$Type, width = 12)

create_violin_plot <- function(data, age_group, title, y_limits, y_breaks, p_position, fill_color, bg_colors) {
  gradient_grob <- rasterGrob(colorRampPalette(bg_colors)(256), width = unit(1, "npc"), height = unit(1, "npc"), interpolate = TRUE)
  plot <- ggplot(subset(data, AgeGroup == age_group),
                 aes(x = Type, y = Value, fill = Type)) +
    annotation_custom(gradient_grob,xmin = -Inf, xmax = Inf, ymin = -Inf, ymax = Inf) +
    geom_violin(trim = FALSE) +
    stat_summary(fun.data="mean_sdl", fun.args = list(mult=1),
                 geom="crossbar", width=0.3, size = 0.3) +
    geom_signif(comparisons = list(c("Reference","Specialized\nfor diapause")),
                map_signif_level = function(p) {paste("italic(P) == ", sprintf("%.2g", p))                },
                y_position = p_position,
                textsize = 4, tip_length = 0,
                parse = TRUE) +
    scale_fill_manual(values = c("#9C9C9C", fill_color)) +
    scale_y_continuous(limits = y_limits, breaks = y_breaks, expand = c(0, 0)) +
    labs(title = title, x = NULL, y = "Fraction of total paralogs") +
    theme_classic(base_size = 12) +
    theme(plot.margin = margin(t = 20, r = 10, b = 10, l = 10),
          plot.title = element_textbox_simple(size = 11, color = "white", halign = 0.5,
                                              fill = fill_color, width = 1.2,
                                              padding = margin(3, 0, 3, 0),
                                              margin = margin(0, 0, 10, 0)),
          axis.text.x = element_text(angle = 45, hjust = 1, size = 11, color = "black"),
          axis.text.y = element_text(color = "black"),
          legend.position = "none")
   }

params <- list(
  list(age_group = "Very ancient", title = "Very ancient<br>(> 473 mya)",
       y_limits = c(0.76, 0.88), y_breaks = seq(0.76, 0.88, 0.02), p_position = 0.865,
       fill_color = "#0EACC9", bg_colors = c("white", "#EDF7F9", "#B1D8E7")),
  list(age_group = "Ancient", title = "Ancient<br>(111-473 mya)",
       y_limits = c(0.10, 0.18), y_breaks = seq(0.10, 0.18, 0.02), p_position = 0.17,
       fill_color = "#A184BC", bg_colors = c("white", "#E8DFF0", "#BFA0CC")),
  list(age_group = "Recent/very recent", title = "Recent/very recent<br>(0-111 mya)",
       y_limits = c(0, 0.08), y_breaks = seq(0, 0.08, 0.02), p_position = 0.073,
       fill_color = "#E57164", bg_colors = c("white", "#FEEBDD", "#F7B78B"))
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

ggsave("gradient_grob_violinmy.png", width = 6, height = 4.5)
#ggsave("gradient_grob_violin.pdf", width = 6, height = 4.5)
