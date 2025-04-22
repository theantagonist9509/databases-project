# What's in here?
- This repository is our submission for the _CS2202 Databases and Warehousing_ course group project, where we developed a toy _Railway Ticket Reservation System_ using MySQL and Tkinter.
- Also included are a documentation file (`documentation.pdf`), and a demo video (`demo.mp4`).

# Group Members
- 2301AI30
    - Tejas Tanmay Singh
- 2301AI04
    - Ayush Bansal
- 2301CS89
    - Suvrayan Bandyopadhyay

# Setup Instructions

## Python
- Install `tkinter` and `mysql-connector-python`.
- Create a `.env` file with your MySQL credentials in the following variables:
    - `MYSQL_USER`
    - `MYSQL_PASSWORD`
    - `MYSQL_HOST`
    - `MYSQL_DATABASE`

## MySQL
- The project files include:
    - CreateTables.sql
        - Creates the tables of the database
    - Queries.sql
        - Implements queries for the deliverable, as well as helper functions and procedures
    - InsertData.sql
        - Inserts dummy data into the database's tables

- Source these files after creating your local database.
