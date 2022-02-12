## Function for plotting graphs obtained by "GetGraphOperTime" from "GetGraph.r". 
## Author: N.N.Osipov
######################################################################################################


# The libraries ggplot2 and grid are needed.


PlotMuSgm <- function(gr, scale = 1000)
{
	yMin <- min(gr$qMns) - 0.005;
	yMax <- max(gr$qPls) + 0.005;

	grMu <- ggplot(data = gr) + geom_line(mapping = aes(x = time/scale, y = mu), color = "red", size = 0.7) + coord_cartesian(xlim=c(gr$time[1]/scale, gr$time[length(gr$time)]/scale), ylim=c(yMin,yMax)) + geom_line(mapping = aes(x = time/scale, y = qPls), color = "blue", size = 0.7) + geom_line(mapping = aes(x = time/scale, y = qMns), color = "blue", size = 0.7);

	grSgm <- ggplot(data = gr) + geom_line(mapping = aes(x = time/scale, y = sgm), color = "blue", size = 0.7) + coord_cartesian(xlim = c(gr$time[1]/scale, gr$time[length(gr$time)]/scale));

	g2 <- ggplotGrob(grMu);
	g3 <- ggplotGrob(grSgm);
	g <- rbind(g2, g3, size = "last");
	g$heights[7] <- 2 * g$heights[7];
	grid.draw(g)
}
