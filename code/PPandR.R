library(tibble)
require(qqplotr)
library(car)
library("dplyr")
library(grid)

a = read.csv("./cancha.csv")

p1 = ggplot(a,aes(sample = x1)) +
  stat_pp_band(fill ="#E0CCE5") +
  stat_pp_line(colour= "#BAB1CE") +
  stat_pp_point(colour="#A02785") +
  facet_wrap(vars(x2),scales = "free",strip.position = "left")+
  labs(x = "Theoretical cumulative distribution", y = "Empirical cumulative distribution")+
  theme_bw()+
  theme(axis.title.x = element_text(size = 12,family = "Times",face = "plain"))+
  theme(axis.title.y = element_text(size = 12,family = "Times"))+
  theme(panel.grid = element_blank(),strip.background = element_rect(fill = "white"),plot.title = element_text(hjust = 0.5),strip.text = element_text(size = 10),)+
  theme(text = element_text(family = "Times"))+
  ggtitle("(b)")+
  theme(plot.title = element_text(size = 12, family = "Times"))
p1
dat = read.csv("./rap.csv")
head(dat)

dat$cor1 <- cut(abs(dat$x1),
                breaks = c(0.7,0.75,0.8,0.85,1),
                labels = c("0.70 - 0.75","0.75 - 0.80","0.80 - 0.85","> 0.85"),
                right=FALSE) 
dat$pvalue1 <- cut(dat$x2,
                   breaks = c(0,0.01,0.05),
                   labels = c("< 0.01","< 0.05"),
                   right=FALSE) 
dat = dat[order(dat$x1),]
dat$Cell = factor(dat$x3, levels = dat$x3)

p = ggplot(dat, aes(x = x1, y = Cell, color = cor1)) +
  scale_color_manual(name="cor",
                     values = c("#E0CCE5","#BAB1CE","#91589f","#A02785"))+
  geom_segment(aes(x = 0.5, y = Cell, xend = x1, yend = Cell),linewidth = 8) +
  theme_bw()+
  labs(x = "R", y = "City")+
  theme(axis.text.x = element_text(size = 10,))+
  theme(axis.text.y = element_text(size = 10,angle=0,))+
  theme(axis.title.x = element_text(size = 12, family = "Times"))+
  theme(axis.title.y = element_text(size = 12, family = "Times"))+
  theme(
    legend.position = c(1, 0),
    legend.justification = c(1, 0),panel.grid = element_blank(),plot.title = element_text(hjust = 0.5))+
  theme(text = element_text(family = "Times"))+
  ggtitle("(a)")+
  theme(plot.title = element_text(size = 12, family = "Times"))
p

library(grid)
grid.newpage()
pushViewport(viewport(layout = grid.layout(nrow = 4, ncol = 4)))
define_region <- function(row, col){
  viewport(layout.pos.row = row, layout.pos.col = col)
} 
print(p, vp = define_region(row = 1:4, col = 1))   # 跨两列
print(p1, vp = define_region(row = 1:4, col = 2:4))
ggsave("plot.png", plot = last_plot(), width = 10, height = 4, units = "in", dpi = 300)
