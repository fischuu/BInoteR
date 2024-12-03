create_project_notebook <- function(project_name = "BrownTrout", author = "Daniel Fischer") {
  # Create project directory
  project_dir <- gsub(" ", "_", project_name)
  if (!dir.exists(project_dir)) {
    dir.create(project_dir)
  }
  
  # Create the main RMarkdown file
  main_file <- file.path(project_dir, paste0(project_dir, "_header.Rmd"))
  rmd_header <- paste0(
    "---\n",
    "title: \"", project_name, "\"\n",
    "author: \"", author, "\"\n",
    "output:\n",
    "  html_document:\n",
    "    toc: true\n",
    "    toc_depth: 4\n",
    "    toc_float:\n",
    "      toc_collapsed: true\n",
    "  number_sections: false\n",
    "  theme: lumen\n",
    "  df_print: paged\n",
    "  code_folding: hide\n",
    "---\n\n"
  )
  
  main_skeleton <- paste0(
    "# Project: ", project_name, "\n\n",
    "## Project Metadata\n",
    "- **PI**: [Principal Investigator]\n",
    "- **Data Storage**: [Path/Location]\n",
    "- **Code Storage**: [Repository/Path]\n",
    "- **Backup Location**: [Backup Path/Service]\n",
    "- **Billing Code**: [Grant or Account Code]\n",
    "- **Created**: [YYYY-MM-DD]\n",
    "- **Updated**: [YYYY-MM-DD]\n\n",
    "```\n"
  )
  
  # Write main RMarkdown file
  writeLines(paste0(rmd_header, main_skeleton), con = main_file)

  
  # Example: Create today's file
  today <- Sys.Date()
  create_daily_template(date=today, project_name= project_dir)
  
  message("Project notebook initialized at: ", project_dir)
}
