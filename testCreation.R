# Example dataset creation
create_project_notebook(project_name="Mastitis Challenge")
create_project_notebook(project_name="Ruminomics")
create_project_notebook(project_name="Holoruminant")
create_project_notebook(project_name="DirExo")
create_project_notebook(project_name="Snakebite-VCFRescue")
create_project_notebook(project_name="Bioinformatics method support")
create_project_notebook(project_name="SOFASU")
create_project_notebook(project_name="Applications")
create_project_notebook(project_name="Siika_panel")
create_project_notebook(project_name="NOISE_thematic_call")
create_project_notebook(project_name="Manuscript ideas")


create_daily_template(project_name="Holoruminant")
create_daily_template(project_name="SOFASU")
create_daily_template(project_name="Ruminomics")
create_daily_template(project_name="Mastitis_Challenge")
create_daily_template(project_name="Siika_panel")
create_daily_template(project_name="Applications")

generate_project_report("Mastitis_Challenge")
generate_todo_report("Mastitis_Challenge")


create_project_notebook(project_name="test2")
create_daily_template("test2", date="2024-12-04")

generate_project_report("huhu")
generate_project_report("test2")

generate_todo_report("huhu")
generate_todo_report("test2")

# Example usage:
projects <- c("huhu", "test2")
generate_joint_todo_report(project_titles = projects)
