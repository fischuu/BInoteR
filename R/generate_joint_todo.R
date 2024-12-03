generate_joint_todo_report <- function(project_titles, directory = ".", output_dir = ".") {
  # Generate individual ToDo reports first for each project
  for (project_title in project_titles) {
    project_folder <- file.path(directory, project_title)  # Define the folder for the project
    if (!dir.exists(project_folder)) {
      dir.create(project_folder, recursive = TRUE)  # Ensure project folder exists
    }
    
    # Define the output file path inside the project folder
    output_file <- file.path(project_folder, paste0(project_title, "_ToDo_Report.Rmd"))
    
    # Ensure the correct directory is passed to the report generation
    generate_todo_report(project_title = project_title, directory = project_folder)
  }
  
  # After generating individual reports, create the joint ToDo list
  # List all ToDo .Rmd files in the subdirectories sorted by date
  all_rmd_files <- list.files(directory, pattern = "_ToDo_Report.Rmd$", full.names = TRUE, recursive = TRUE)
  project_rmd_files <- all_rmd_files[grepl(paste(project_titles, collapse = "|"), all_rmd_files)]
  
  joint_todos <- data.frame(
    Task = character(),
    Due = character(),
    Priority = character(),
    Estimated_Duration = character(),
    Ready = character(),
    Tags = character(),
    Project = character(),
    stringsAsFactors = FALSE
  )
  
  # Extract ToDo data from all projects
  for (rmd_file in project_rmd_files) {
    todos <- extract_todo_from_rmd(rmd_file)  # Assuming this is your function to extract ToDos
    todos$Project <- gsub(".*/(.*)_ToDo_Report.Rmd", "\\1", rmd_file)  # Extract project name from file name
    
    # Append to joint_todos
    joint_todos <- rbind(joint_todos, todos)
  }
  
  # Now create the joint ToDo report (Markdown)
  joint_todos_for_kable <- data.frame(Task = character(), stringsAsFactors = FALSE)
  
  for (i in 1:nrow(joint_todos)) {
    # Add task row
    joint_todos_for_kable <- rbind(joint_todos_for_kable, data.frame(Task = joint_todos$Task[i]))
    
    # Concatenate all metadata into one row for each task
    metadata <- paste(
      "Project:", joint_todos$Project[i],
      "| Due:", joint_todos$Due[i],
      "| Priority:", joint_todos$Priority[i],
      "| Estimated Duration:", joint_todos$Estimated_Duration[i],
      "| Ready:", joint_todos$Ready[i],
      "| Tags:", joint_todos$Tags[i]
    )
    
    # Add metadata row
    joint_todos_for_kable <- rbind(joint_todos_for_kable, data.frame(Task = metadata))
  }
  
  # Create Markdown content for the joint report
  joint_markdown_content <- paste0(
    "---\n",
    "title: \"Joint ToDo Report\"\n",
    "output:\n",
    "  html_document:\n",
    "    toc: true\n",
    "    toc_depth: 2\n",
    "    toc_float:\n",
    "      toc_collapsed: true\n",
    "number_sections: false\n",
    "---\n\n",
    "## ToDo List for All Projects\n\n",
    "```{r, echo=FALSE}\n",
    "library(kableExtra)\n",
    "todos_display <- joint_todos_for_kable\n",
    "kable(todos_display, escape = FALSE, align = c('l')) %>% \n",  # Align the task column to the left
    "  kable_styling(full_width = TRUE, bootstrap_options = c('striped', 'hover')) %>% \n",  # Full width
    "  row_spec(1:nrow(todos_display), background = 'white') %>%\n",  # Default white for tasks
    "  row_spec(seq(2, nrow(todos_display), by = 2), background = '#D3D3D3') %>%\n",  # Gray background for metadata rows
    "  row_spec(seq(2, nrow(todos_display), by = 2), extra_css = 'border-bottom: 2px solid #000000')\n",  # Separator line after metadata rows
    "```\n"
  )
  
  # Write the joint ToDo report markdown file
  joint_output_file <- file.path(output_dir, "Joint_ToDo_Report.Rmd")
  writeLines(joint_markdown_content, joint_output_file)
  
  # Render the joint report to HTML
  render(joint_output_file, output_format = "html_document", output_file = sub(".Rmd$", ".html", joint_output_file))
  
  message("Joint ToDo report generated and rendered: ", joint_output_file)
}
