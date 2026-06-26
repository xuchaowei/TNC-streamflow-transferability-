library(tidyverse)
library(gghalves)
library(ggplot2)

df <- readxl::read_xlsx("datazyanzheng.xlsx")

my_color = c('#000000','#E21F26','#24B99A','#CCBE93','#A7CEE2','#FFFF00','#0000FF')

variable <-c('GB','AUS','YR','CL','CE','AR','USA')
my_sort <-factor(variable,levels = variable)


ggplot(df,aes(factor(Region,levels = my_sort),`Age average`))+
  coord_flip()+
  geom_half_violin(aes(fill=factor(Region,levels = my_sort),
                       color=factor(Region,levels = my_sort)),
                   side ='r',
                   position = position_nudge(x = .25, y = 0))+
  geom_boxplot(aes(fill=factor(Region,levels = my_sort)),
               width=0.12,cex=1.2,outliers = FALSE, alpha = 0.5,
               position = position_nudge(x = .1, y = 0))+
  geom_dotplot(binaxis = "y",binwidth = 0.05,stackdir = "up",dotsize = 0.01,
               fill = '#000000', color = "transparent") +
  scale_fill_manual(values = my_color, guide = 'none')+
  scale_color_manual(values = my_color, guide = 'none') +
  scale_y_reverse(expand=c(0,0),limits = c(max(df$`Age average`, na.rm = TRUE) * 1,
                                           min(df$`Age average`, na.rm = TRUE) * 1), breaks = seq(-1.5, 1.2, 0.2))+
  labs(x=NULL,y="NSE")+
  theme_classic(base_size = 20) +
  theme(axis.line.y = element_blank(),
        axis.ticks.y = element_blank(),
        axis.text.y = element_text(color = "black", size = 22,
                                   vjust = -2, hjust = 0,
                                   margin = margin(0,-1,0,0,'cm')),
        axis.text.x = element_text(color = "black", size = 22))

ggsave("raincloudyanzheng09z.tif", width = 10, height = 7, dpi = 300)
#ggsave("raincloudlvding.pdf", width = 10, height = 7)
