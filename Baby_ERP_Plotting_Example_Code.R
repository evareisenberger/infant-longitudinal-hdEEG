plot_event_related_lines <- function(xaxis, data, title, ylabel, colors, hline=NULL, 
                                     line_width=1.5, ribbon_alpha=0.2) {
  # Load necessary libraries
  library(ggplot2)
  library(dplyr)
  library(tidyr)
  library(R.matlab)
  install.packages("svglite")
  library(svglite)
  
  # Ensure xaxis is a numeric vector
  if (!is.numeric(xaxis)) {
    stop("Error: xaxis must be a numeric vector representing time points.")
  }
  
  # Ensure data is a named list of matrices
  if (!is.list(data) || !all(sapply(data, is.matrix))) {
    stop("Error: 'data' must be a named list of matrices (trials x timepoints).")
  }
  
  df_list <- list()  # Initialize list for storing transformed data
  
  for (i in seq_along(data)) {
    label <- names(data)[i]
    values <- data[[i]]
    
    # Check if number of columns matches x-axis length
    if (length(xaxis) != ncol(values)) {
      stop(paste("Error: Length of xaxis (", length(xaxis), ") does not match number of columns in", label, "(", ncol(values), ")"))
    }
    
    # Compute mean and standard error of the mean (SEM)
    mean_values <- colMeans(values, na.rm = TRUE)
    sem_values <- apply(values, 2, function(x) sd(x, na.rm = TRUE) / sqrt(sum(!is.na(x))))
    
    # Convert to long format for ggplot
    df_long <- data.frame(
      x = xaxis,
      y = mean_values,
      sem_upper = mean_values + sem_values,
      sem_lower = mean_values - sem_values,
      label = label
    )
    
    df_list[[i]] <- df_long
  }
  
  df <- bind_rows(df_list)  # Merge all data frames into one
  
  # Create plot
  p <- ggplot(df, aes(x = x, y = y, color = label)) +
    geom_line(linewidth = line_width) +  # Smooth line
    geom_ribbon(aes(ymin = sem_lower, ymax = sem_upper, fill = label), 
                alpha = ribbon_alpha, color = NA) +  # Transparent shaded region
    scale_color_manual(values = colors) + 
    scale_fill_manual(values = colors) +
    labs(title = title, 
         x = "Time (s)", 
         y = ylabel) +
    theme_bw(base_size = 18) +  # Professional clean theme
    theme(plot.title = element_text(hjust = 0.5),aspect.ratio = 1,
      panel.grid.major = element_blank(),  # Remove major grid lines
      panel.grid.minor = element_blank(),  # Remove minor grid lines
      panel.border = element_blank(),  # Remove top & right border
      axis.line.x = element_line(linewidth = 1.2, color = "black"),  # Keep bottom axis
      axis.line.y = element_line(linewidth = 1.2, color = "black"),  # Keep left axis
      axis.text = element_text(size = 16),  # Larger axis labels
      axis.title.x = element_text(size = 18, margin = margin(t = 10)),  # More space for x-label
      axis.title.y = element_text(size = 18, margin = margin(r = 10)),  # More space for y-label
      legend.position.inside = c(0.75, 0.75),  # Legend inside plot
      legend.background = element_blank(),  # Remove legend box
      legend.key = element_blank(),  # Remove key background
      legend.text = element_text(size = 14),  # Improve readability
      legend.title = element_blank()  # Remove legend title
    ) +
    coord_cartesian(ylim = c(min(df$sem_lower) * 1.05, max(df$sem_upper) * 1.05))  # Slight padding
  
  # Add optional horizontal reference line
  if (!is.null(hline)) {
    p <- p + geom_hline(yintercept = hline, linetype = "dashed", color = "red", linewidth = 1)
  }
  
  # Add vertical dashed line at time = 0
  p <- p + geom_vline(xintercept = 0, linetype = "dashed", color = "black", linewidth = 1)
  
  return(p)
}

####################################################################################################
# Example of running the function with data
cbbPalette <- c("#000000", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")

folder_path <- "xxx" # Change accordingly
mat_files <- list.files(path = folder_path, pattern = "\\.mat$", full.names = TRUE) # Do not change

library(R.matlab)

read_mat_file <- function(file_path) {
  mat_data <- readMat(file_path)
  mat_name <- names(mat_data)[1]
  return(mat_data[[mat_name]])
} #do not change

### 12M

data_list <- setNames(lapply(mat_files, read_mat_file), tools::file_path_sans_ext(basename(mat_files))) #do not change

time_vect <- as.vector(data_list$ERP_time)  # Extract and convert to vector

# These are the vectors to plot, change accordingly
y <- list(Beep = data_list$ERP_12Mall, NoStimulation = data_list$BL_12Mall)

# Change accordingly
p <- plot_event_related_lines(time_vect, y, title='12 Months', ylabel='Relative Amplitude Change', 
                              colors= c(cbbPalette[4], 'black'), line_width = 2)

# Define significant time window
start_time <- 0.344
end_time <- 0.616
y_line <- 1.7

# Define where to place to asterix
asterisk_x <- (start_time + end_time) / 2
asterisk_y <- y_line + 0.3

# Create plot
p2 = p + scale_x_continuous(limits = c(-0.2, 1.5), expand = c(0,0)) + coord_cartesian(ylim = c(-2.5, 3)) +
  geom_segment(aes(x = start_time, xend = end_time, y = y_line, yend = y_line), color = "black", size = 1) +
  theme(
    axis.text = element_text(color = "black"),
    axis.title = element_text(color = "black")
  )

p2 <- p2 + annotate("text", x = asterisk_x, y = asterisk_y, label = "*", size = 8)

# Print
print(p2)

# Save
ggsave(
  filename = "xxx.svg", # Change accordingly
  plot = p2,
  device = svglite::svglite,
  width = 180,
  height = 180,
  units = "mm",
  bg = "white"
)