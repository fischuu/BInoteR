generate_todo_report <- function(project_title, directory = ".", output_file = NULL) {

  # Check if the project folder exists, if not, create it
  project_folder <- file.path(directory, project_title)
  
  todos <- data.frame(
    Task = character(),
    Due = character(),
    Priority = character(),
    Estimated_Duration = character(),
    Ready = character(),
    Tags = character(),
    stringsAsFactors = FALSE
  )
  
  # List all RMarkdown files within each subdirectory, filtered by date pattern
  # Assuming the date format in filenames is "YYYY-MM-DD" (or adjust the regex pattern accordingly)
  date_pattern <- "\\d{4}-\\d{2}-\\d{2}"  # Adjust this pattern based on your specific date format
  files <- list.files(project_folder, pattern = paste0(date_pattern, "_",project_title,".Rmd$"), full.names = TRUE)
  
    
    for (file in files) {
      content <- readLines(file)
      
      # Locate the ToDos section
      todo_start <- grep("^### ToDos", content)
      email_start <- grep("^### Emails", content)
      
      if (length(todo_start) > 0) {
        # Extract relevant content for ToDos (correct the range handling)
        for (start in todo_start) {
          # Find the end of the ToDo section (before the Emails section)
          end <- ifelse(length(email_start) > 0, min(email_start[email_start > start]) - 1, length(content))
          
          todo_section <- content[(start + 1):end]
          
          # Extract tasks from ToDos section
          task_lines <- grep("^- \\*\\*Task\\*\\*:", todo_section)
          for (i in seq_along(task_lines)) {
            task_start <- task_lines[i]
            task_end <- ifelse(i < length(task_lines), task_lines[i + 1] - 1, length(todo_section))
            task_details <- todo_section[task_start:task_end]
            
            # Parse task details
            task_data <- list(
              Task = gsub("^- \\*\\*Task\\*\\*: ", "", task_details[1]),
              Due = gsub(".*Due\\*\\*: (.*)", "\\1", task_details[grep("- \\*\\*Due\\*\\*:", task_details)]),
              Priority = gsub(".*Priority\\*\\*: (.*)", "\\1", task_details[grep("- \\*\\*Priority\\*\\*:", task_details)]),
              Estimated_Duration = gsub(".*Estimated Duration\\*\\*: (.*)", "\\1", task_details[grep("- \\*\\*Estimated Duration\\*\\*:", task_details)]),
              Ready = gsub(".*Ready\\*\\*: \\[(.*)\\]", "\\1", task_details[grep("- \\*\\*Ready\\*\\*:", task_details)]),
              Tags = gsub(".*Tags\\*\\*: (.*)", "\\1", task_details[grep("- \\*\\*Tags\\*\\*:", task_details)])
            )
            
            # Append to todos
            todos <- rbind(todos, task_data, stringsAsFactors = FALSE)
          }
        }
      }
    }
  
  # Check if todos is empty and return a message if it is
  if (nrow(todos) == 0) {
    stop("No ToDo items found in the specified project files.")
  }
  
  # Clean up Ready field (make it more readable)
  todos$Ready <- ifelse(todos$Ready == "x", "Yes", "No")
  
  # Create a new data frame with alternating task and metadata rows
  todos_for_kable <- data.frame(Task = character(), stringsAsFactors = FALSE)
  
  for (i in 1:nrow(todos)) {
    # Add task row
    todos_for_kable <- rbind(todos_for_kable, data.frame(Task = todos$Task[i]))
    
    # Concatenate all metadata into one row for each task
    metadata <- paste(
      "Due:", todos$Due[i],
      "| Priority:", todos$Priority[i],
      "| Estimated Duration:", todos$Estimated_Duration[i],
      "| Ready:", todos$Ready[i],
      "| Tags:", todos$Tags[i]
    )
    
    # Add metadata row
    todos_for_kable <- rbind(todos_for_kable, data.frame(Task = metadata))
  }
  
  # Ensure the output file is named based on the project title
  if (is.null(output_file)) {
    output_file <- file.path(project_folder, paste0(project_title, "_ToDo_Report.Rmd"))
  }
  
  # Create the R Markdown content with actual data (not just variables)
  markdown_content <- paste0(
    "---\n",
    "title: \"ToDo Report for ", project_title, "\"\n",
    "output:\n",
    "  html_document:\n",
    "    toc: true\n",
    "    toc_depth: 2\n",
    "    toc_float:\n",
    "      toc_collapsed: true\n",
    "number_sections: false\n",
    "---\n\n",
    "```{r, echo=FALSE}\n",
    "tmp <- ", dput(todos_for_kable), "\n",
    "todos_for_kable <- data.frame(Task=tmp)\n",
    "\n",
    "```\n\n",
    "## ToDo List\n\n",
    "```{r, echo=FALSE, results='asis'}\n",
    "library(kableExtra)\n",
    "kable(\n",
    "  todos_for_kable, escape = FALSE, align = c('l')) %>%\n",
    "  kable_styling(full_width = TRUE, bootstrap_options = c('striped', 'hover')) %>%\n",
    "  row_spec(1:nrow(todos_for_kable), background = 'white') %>%\n",
    "  row_spec(seq(2, nrow(todos_for_kable), by = 2), background = '#D3D3D3') %>%\n",
    "  row_spec(seq(2, nrow(todos_for_kable), by = 2), extra_css = 'border-bottom: 2px solid #000000')\n",
    "```\n"
  )
  
  # Write the .Rmd file with all content included
  writeLines(markdown_content, output_file)
  
  # Render the Markdown file to HTML (use absolute path)
  render(output_file, output_format = "html_document")
  
  message("ToDo report generated and rendered: ", output_file)
}
