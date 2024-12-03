# Example dataset creation
create_project_notebook(project_name="Mastitis Challenge")
create_daily_template("huhu", date="2024-12-02")
create_project_notebook(project_name="test2")
create_daily_template("test2", date="2024-12-04")

generate_project_report("huhu")
generate_project_report("test2")

generate_todo_report("huhu")
generate_todo_report("test2")

# Example usage:
projects <- c("huhu", "test2")
generate_joint_todo_report(project_titles = projects)
