generate_project_report <- function(project_name = "BrownTrout",  
                                    directory = ".",  
                                    output_file = NULL,  
                                    exclude_sections = c()) {
  # Ensure directory exists and resolve its full path
  project_dir <- file.path(directory, gsub(" ", "_", project_name))
  if (!dir.exists(project_dir)) {
    stop("The directory '", project_dir, "' does not exist.\nPlease ensure the project directory is created.")
  }
  
  # Check if the header file exists and read it
  header_file <- file.path(project_dir, paste0(project_name, "_header.Rmd"))
  if (!file.exists(header_file)) {
    stop("Header file not found: ", header_file)
  }
  rmd_header <- readLines(header_file)
  
  # List all files matching the daily file naming pattern (e.g., YYYY-MM-DD_*.Rmd)
  daily_files <- list.files(
    project_dir, 
    pattern = "^\\d{4}-\\d{2}-\\d{2}_.+\\.Rmd$", 
    full.names = TRUE
  )
  
  if (length(daily_files) == 0) {
    stop("No daily entry files matching the pattern found in the project directory: ", project_dir)
  }
  
  # Default output file
  if (is.null(output_file)) {
    output_file <- file.path(project_dir, paste0(project_name, "_Report.Rmd"))
  }
  
  # Placeholders from the daily template
  placeholders <- c(
    "- \\[Enter any observations, decisions, or meeting notes here.\\]",
    "- \\*\\*Task\\*\\*: \\[Another Task Title\\]",
    "- \\*\\*To\\*\\*: \\[Recipient Email\\]",
    "- \\[Enter any decisions made here.\\]",
    "- \\[List any problems or challenges to address.\\]",
    "- \\[Log completed work or milestones achieved.\\]",
    "- \\[Add references, links, or dataset information here.\\]",
    "- \\[Summarize completed work, pending tasks, or next steps.\\]"
  )
  
  # Create the content for including daily entries
  daily_content <- ""
  for (file in daily_files) {
    # Extract the date from the file name (assuming the date is the first part of the file name)
    file_date <- sub("^([0-9]{4}-[0-9]{2}-[0-9]{2})_.*\\.Rmd$", "\\1", basename(file))
    
    # Read the file content
    content <- readLines(file)
    
    # Process content to exclude empty sections
    processed_content <- c()
    section_start <- grep("^### ", content)
    section_end <- c(section_start[-1] - 1, length(content))
    
    for (i in seq_along(section_start)) {
      section <- content[section_start[i]:section_end[i]]
      section_title <- section[1]
      section_body <- section[-1]
      
      # Remove placeholders and blank lines
      section_body <- section_body[!grepl(paste(placeholders, collapse = "|"), section_body)]
      section_body <- section_body[nzchar(trimws(section_body))]
      
      # Adjust condition to check for meaningful content and not excluded sections
      if (length(section_body) > 0 && 
          (length(exclude_sections) == 0 || !any(grepl(paste0("^### ", exclude_sections), section_title)))) {
        processed_content <- c(processed_content, section_title, section_body, "")
      }
    }
    
    # Include the processed content if it has meaningful content
    if (length(processed_content) > 0) {
      # Add the date before the content
      daily_content <- paste0(daily_content, "\n\n", "## ", file_date, "\n\n", paste(processed_content, collapse = "\n"))
    }
  }
  
  # Combine header and content
  report_content <- paste0(paste(rmd_header, collapse = "\n"), "\n\n", daily_content)
  
  # Write the report file
  writeLines(report_content, con = output_file)
  
  # Render the Markdown file to HTML
  rmarkdown::render(
    input = output_file, 
    output_format = "html_document", 
    output_file = sub(".Rmd$", ".html", basename(output_file)),
    output_dir = dirname(output_file)  # Explicitly set the output directory
  )
  
  message("Project report generated: ", file.path(dirname(output_file), sub(".Rmd$", ".html", basename(output_file))))
}
