#' GA Monthly heatmap graphic - sessions
#'
#' Cleans all source inputs from GA API.
#' @param data a data frame from GA API. It must contain the column: ga:sourceMedium,
#' as the package works with this column to generate the ouputs.
#' @param language Choose a language for your sources column outputs.
#' Available languages: en, es, fr. More to add in the near future.
#' @importFrom tidyr separate
#' @import ggplot2
#' @import hrbrthemes
#' @import scales
#' @import viridis
#' @import ggthemes
#' @importFrom dplyr group_by summarise
#' @importFrom forcats fct_reorder
#' @importFrom magrittr %>%
#' @examples ga_clean_data(my_data, language="es")
#' @return The function returns the data frame with a new sources column with correct output ready to plot.
#' @export





ga_sessions_heatmap <- function(data, title = "Sesiones por día y hora de la semana", x_title = "hora", y_title = "",
                                    legend_title = "sesiones", source = 'all', label_size = 3) {



  allHours <- function(data) {
    data.frame(hour = 1:23,
               sessions = sapply(1:23, function(x) sum(data$sessions[data$hour == x])))
  }

  data$day <- weekdays(data$date, abbreviate = T)




  if (source != 'all') {


    data <- data %>%
            filter(sources == source)

    data <- data %>%
      mutate(hour = as.numeric(hour)) %>%
      group_by(day, hour, sources) %>%
      do(allHours(.)) %>%
      summarise(sessions = sum(sessions))

  } else {

    data <- data %>%
      mutate(hour = as.numeric(hour)) %>%
      group_by(day, hour) %>%
      do(allHours(.)) %>%
      summarise(sessions = sum(sessions))
  }

  all_sessions <- sum(data$sessions)
  min_sessions <- min(data$sessions)
  max_sessions <- max(data$sessions)

  subtitle <- paste("Total sesiones: ", comma(all_sessions), " | ",
                    "Máx sesiones: ", comma(max_sessions), " | ",
                    "Mín sesiones: ", comma(min_sessions))



  if (grepl("LC_CTYPE=es", Sys.getlocale())) {

      data$day <- factor(data$day, levels= c("dom", "sáb", "vie", "jue", "mié",
                                             "mar", "lun"))

  } else if (grepl("LC_CTYPE=en", Sys.getlocale())) {


      data$day <- factor(data$day, levels= c("Sun", "Sat", "Fri", "Thu", "Wed",
                                                     "Tue", "Mon"))

  }



  # data$month <- factor(data$month, levels = c("nov", "dec"), ordered = T)



  gg <- ggplot(data, aes(x=hour, y=day, fill=sessions))
  gg <- gg + geom_tile(color="white", size=0.1)
  gg <- gg + scale_fill_viridis(name= paste("#", legend_title), label=comma)
  gg <- gg + coord_equal()
  gg <- gg + labs(title=title, subtitle = subtitle, x=x_title, y=y_title)
  gg <- gg + theme_tufte(base_family="Helvetica")
  gg <- gg + theme(plot.title=element_text(hjust=0.1))
  gg <- gg + theme(axis.ticks=element_blank())
  gg <- gg + theme(axis.text=element_text(size=12))
  gg <- gg + theme(legend.title=element_text(size=10))
  gg <- gg + theme(plot.subtitle=element_text(size=10, hjust=0.5, face="italic", color="black"))
  gg <- gg + theme(legend.text=element_text(size=8))
  gg

  return(gg)
}
