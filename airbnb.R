library(spgwr)
library(car)
library(hexbin)
library(sf)
library(dplyr)
library(tidyverse)
library(knitr)
library(ggplot2)
library(plotly)
library(widgetframe)
library(maptools)
library(ggtext)
library(heatmaply)
library(lattice)
library(rgdal)
library(RColorBrewer)
library(gridExtra)
library(grid)
library(broom)
library(extrafont)
setwd("~/Desktop/Master/Stat")

airbnb <- read.csv("~/Desktop/Master/Stat/airbnb.txt")
#quantile(airbnb$price, c(.2, .4, .6,.8,.9,.95,.98))
airbnb<-airbnb %>%
  select(!c(id,url,found,revised,host.id))%>%
  mutate(room_type=factor(room_type))%>%
  mutate(price=as.numeric(price))%>%
  na.omit()


#heatmap with scale
bbt<-apply(airbnb[,4:8], 2, function(x) tapply(x, airbnb$room_type, mean))
hit <- heatmaply(bbt,dendrogram = "none",xlab = "", ylab = "", main = "",scale = "column",margins = c(60,100,40,20),
              grid_color = "white",grid_width = 0.00001,titleX = FALSE,hide_colorbar = FALSE,branches_lwd = 0.1,
              label_names = c("Room_type", "Feature:", "Value"),fontsize_row = 7, fontsize_col = 5,labCol = colnames(bbt),
              labRow = rownames(bbt),heatmap_layers = theme(axis.line=element_blank()))
hit

  
airbnb%>%
  sample_n(7000)%>%
  filter(price<400)%>%
  ggplot(aes(x=longitude, y=latitude, z = price)) + 
  stat_summary_hex(bins = 40) +
  scale_fill_viridis_c() +
  labs(
    fill = "mean",
    title = "Price"
  )+theme_minimal()

logairbnb<-airbnb%>%
  rename(x=longitude,y=latitude)%>%
  mutate_at(c("price","capacity"),log)%>%
  mutate(reviews=log(reviews+1))%>%
  na.omit()%>%
  sample_n(1000)
#To eliminate infinity values from the log
#logairbnb<-logairbnb%>%
#mutate_if(is.numeric, list(~na_if(., Inf))) %>% 
#mutate_if(is.numeric, list(~na_if(., -Inf)))

histogram(logairbnb$price)
histogram(logairbnb$price^(1/2))
qqPlot(logairbnb$price)
qqPlot(logairbnb$price^(1/2))
logairbnb$price<-logairbnb$price^(1/2)
hist(logairbnb$reviews)
histogram(logairbnb$capacity)
histogram(~logairbnb$price|logairbnb$room_type)

cor(subset(logairbnb,select = c(1,2,5,6,8)))#For NA values use = "complete.obs"
model1 <- lm(price~capacity+reviews+room_type,data = logairbnb)
summary(model1)
plot(model1)

center<-c(2.170047909347857,41.38698088293232)
center<-as.matrix(center)
center<-t(center)

cords<-subset(logairbnb,select=c(1,2))
cords<-as.matrix(cords)
cords<-rbind(center,cords)
cords<-as.matrix(cords)


dist_center<-dist(cords, method = "euclidean", diag = FALSE, upper = FALSE)
dist_center<-as.matrix(dist_center)
dist_center<-dist_center[-1,1]
dist_center<-as.matrix(dist_center)
logairbnb$dist_center<-dist_center
scatterplot(logairbnb$dist_center,logairbnb$price)

Barceloneta=c(2.1925032013629333, 41.37853679009465)
Barceloneta<-as.matrix(Barceloneta)
Barceloneta<-t(Barceloneta)
cords<-subset(logairbnb,select=c(1,2))
cords<-as.matrix(cords)
cords<-rbind(Barceloneta,cords)
cords<-as.matrix(cords)

dist_Bar<-dist(cords, method = "euclidean", diag = FALSE, upper = FALSE)
dist_Bar<-as.matrix(dist_Bar)
dist_Bar<-dist_Bar[-1,1]
logairbnb$dist_Bar<-dist_Bar
scatterplot(logairbnb$dist_Bar,logairbnb$price)



cor(subset(logairbnb,select = c(1,2,5,6,8,9,10)))
model2 <- lm(price~capacity+reviews+dist_center+dist_Bar+room_type,data = logairbnb)
summary(model2)
plot(model2)

#gwr
resids<-residuals(model2)
colours <- c("dark blue", "blue", "red", "dark red") 

spdf<-SpatialPointsDataFrame(coords =cbind(logairbnb$x,logairbnb$y),data = logairbnb, proj4string = CRS("+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0"))

#spplot(spdf,cuts = 5)

map.resids <- SpatialPointsDataFrame(data=data.frame(resids), coords=cbind(logairbnb$x,logairbnb$y)) 
spplot(map.resids, cuts=quantile(resids), col.regions=colours, cex=1) 

#calculate kernel bandwidth
GWRbandwidth <- gwr.sel(price~capacity+reviews+dist_center+dist_Bar+room_type,data = logairbnb, coords=cbind(logairbnb$x,logairbnb$y),adapt=T) 
#run the gwr model

gwr.model = gwr(price~capacity+reviews+dist_center+dist_Bar+room_type,data = logairbnb, coords=cbind(logairbnb$x,logairbnb$y), adapt=GWRbandwidth, hatmatrix=TRUE, se.fit=TRUE) 
#print the results of the model
gwr.model

results<-as.data.frame(gwr.model$SDF)
head(results)

#attach coefficients to original dataframe
logairbnb$coefcapacity<-results$capacity
logairbnb$coefreviews<-results$reviews
logairbnb$coefdist_center<-results$dist_center
logairbnb$coefdist_Bar<-results$dist_Bar


neighbourhood <- readOGR("BCN_UNITATS_ADM")
g<-as.data.frame(logairbnb$coefdist_center)
g<-cbind(logairbnb$coefdist_Bar,g)
g<-cbind(logairbnb$coefreviews,g)
g<-cbind(logairbnb$coefcapacity,g)
g<-cbind(logairbnb$y,g)
g<-cbind(logairbnb$x,g)

colnames(g)[1] <- "long"
colnames(g)[2] <- "lat"
colnames(g)[3] <- "coefcap"
colnames(g)[4] <- "coefrev"
colnames(g)[5] <- "coefdistBarceloneta"
colnames(g)[6] <- "coefdistCent"
g<-SpatialPointsDataFrame(coords =cbind(g$long,g$lat),data = g, proj4string = CRS("+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0"))
g<-spTransform(g,CRS("+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0"))
neighsp<-spTransform(neighbourhood,CRS("+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0"))
mapdata1 <- as.data.frame(g)
mapdata2<- fortify(neighsp, region ="NOM")
#BARCELONA MAP
ggplot(mapdata2, aes(long,lat,colour = factor(id))) +
  geom_polygon(fill = "white", colours = terrain.colors(10))+coord_quickmap()

#BARCELONA MAP with airbnb rooms
longac <- airbnb$longitude
latac <- airbnb$latitude
accomodations <- data.frame(longac,latac)

accomodations<-SpatialPointsDataFrame(coords =cbind(accomodations$longac,accomodations$latac),data = accomodations, proj4string = CRS("+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0"))
accomodations<-spTransform(accomodations,CRS("+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0"))
mapdata3<-as.data.frame(accomodations)

accom<-ggplot(mapdata3,aes(longac,latac))+
  geom_point(colour="blue",size=0.05)+
  geom_polygon(data=mapdata2, aes(long,lat,group=group),colour="grey",fill = "white",alpha = 1/3)

den_accom<-ggplot(mapdata3,aes(longac,latac))+
  stat_density2d(aes(fill = ..level..), alpha=10, geom="polygon")+
  geom_polygon(data=mapdata2, aes(long,lat,group=group),colour="grey",fill = "white",alpha = 1/3)+
  scale_fill_gradientn(colours=rev(brewer.pal(11,"Spectral")))

grid.arrange(accom,den_accom,nrow=1)

#map with only points selected from 1000 obs that are at a certain distance from center
mapdata1$dist<-logairbnb$dist_center
accom<-ggplot(subset(mapdata1, mapdata1$dist<0.01),aes(long,lat))+
  geom_point(colour="blue",size=0.05)+
  geom_polygon(data=mapdata2, aes(long,lat,group=group),colour="grey",fill = "white",alpha = 1/3)

den_accom<-ggplot(mapdata3,aes(longac,latac))+
  stat_density2d(aes(fill = ..level..), alpha=10, geom="polygon")+
  geom_polygon(data=mapdata2, aes(long,lat,group=group),colour="grey",fill = "white",alpha = 1/3)+
  scale_fill_gradientn(colours=rev(brewer.pal(11,"Spectral")))

grid.arrange(accom,den_accom,nrow=1)


#GWR coefficients                       
gwr.point1<-ggplot(logairbnb, aes(x=x,y=y))+
  geom_point(aes(colour=logairbnb$coefdist_center))+
  scale_colour_gradientn(colours = terrain.colors(10), guide_legend(title="Coefs"))
gwr.point1
#Maps
#distCent
gwr.point1<-ggplot(mapdata1, aes(x=long,y=lat))+
  geom_point(aes(colour=coefdistCent))+
  scale_colour_gradientn(colours = terrain.colors(100), guide_legend(title="coefdistCent"))+
  coord_quickmap()

a<-gwr.point1+geom_polygon(data=mapdata2, aes(group=group), colour="grey",fill = "white",alpha = 1/3)
#cap
gwr.point2<-ggplot(mapdata1, aes(x=long,y=lat))+
  geom_point(aes(colour=coefcap))+
  scale_colour_gradientn(colours = terrain.colors(100), guide_legend(title="Coefcap"))+
  coord_quickmap()

b<-gwr.point2+geom_polygon(data=mapdata2, aes(group=group), colour="grey",fill = "white",alpha = 1/3)
#rev
gwr.point3<-ggplot(mapdata1, aes(x=long,y=lat))+
  geom_point(aes(colour=coefrev))+
  scale_colour_gradientn(colours = terrain.colors(100), guide_legend(title="Coefrev"))+
  coord_quickmap()

c<-gwr.point3+geom_polygon(data=mapdata2, aes(group=group), colour="grey",fill = "white",alpha = 1/3)

ggplotly(c) %>%
  highlight(
    "plotly_hover",
    selected = attrs_selected(line = list(color = "black"))
  ) %>%
  widgetframe::frameWidget()
#distBar
gwr.point4<-ggplot(mapdata1, aes(x=long,y=lat))+
  geom_point(aes(colour=coefdistBarceloneta))+
  scale_colour_gradientn(colours = terrain.colors(100), guide_legend(title="CoefdistBar"))+
  coord_quickmap()

d<-gwr.point4+geom_polygon(data=mapdata2, aes(group=group), colour="grey",fill = "white",alpha = 1/3)

grid.arrange(a,b,c,d,nrow=2)

#center label

lab <- "<span style = 'color:red'>+</span> Center"
center<-as.data.frame(center)
center<-SpatialPointsDataFrame(coords =cbind(center$V1,center$V2),data = center, proj4string = CRS("+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0"))
center<-spTransform(center,CRS("+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0"))
center<-as.data.frame(center)
center<-fortify(center)

gwr.point3+geom_polygon(data=mapdata2, aes(group=group), colour="grey",fill = "white",alpha = 1/3)+
  geom_point(data = center, mapping = aes(x = V1, y = V2), colour = "red",shape="plus",size=4)+ 
  geom_richtext(aes(x = 2.06, y = 41.31,label = lab))


