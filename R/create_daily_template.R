create_daily_template <- function(date = Sys.date(), project_name = "BrownTrout") {
  # Set project directory
  project_dir <- gsub(" ", "_", project_name)
  
  # Check if project directory exists
  if (!dir.exists(project_dir)) {
    stop("Project directory does not exist: ", project_dir, "\nPlease create the project first.")
  }
  
  # Create file for the date
  daily_file <- file.path(project_dir, paste0(date,"_", project_name ,".Rmd"))
  
  if (file.exists(daily_file)) {
    message("Daily file already exists: ", daily_file)
  } else {
    # Daily content template
    daily_content <- paste0(
      "## ", date, "\n\n",
      "### Notes\n",
      "- [Enter any observations, decisions, or meeting notes here.]\n\n",
      "### ToDos\n",
      "- **Task**: [Another Task Title]\n",
      "  - **Due**: [YYYY-MM-DD]\n",
      "  - **Priority**: [High/Normal/Low]\n",
      "  - **Estimated Duration**: [e.g., 2h]\n",
      "  - **Ready**: No\n",
      "  - **Tags**: [e.g., experiment, summary, #Priority]\n\n",
      "### Emails\n",
      "- **To**: [Recipient Email]\n",
      "  - **Subject**: [Subject Line]\n",
      "  - **Sent**: [YYYY-MM-DD]\n",
      "  - **Follow-up**: [YYYY-MM-DD]\n",
      "  - **Solved**: No\n\n",
      "### Decisions\n",
      "- [Enter any decisions made here.]\n\n",
      "### Issues\n",
      "- [List any problems or challenges to address.]\n\n",
      "### Progress\n",
      "- [Log completed work or milestones achieved.]\n\n",
      "### Resources\n",
      "- [Add references, links, or dataset information here.]\n\n",
      "### Summary\n",
      "- [Summarize completed work, pending tasks, or next steps.]\n"
    )
    
    # Write daily file
    writeLines(daily_content, con = daily_file)
    message("Created daily file for ", date, ": ", daily_file)
  }
}
