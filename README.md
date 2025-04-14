# Setup Instructions

## Python Setup
- Install `tkinter` and `mysql-connector-python`
- Create a `.env` file with your MySQL credentials in the following variables:
    - `MYSQL_USER`
    - `MYSQL_PASSWORD`
    - `MYSQL_HOST`
    - `MYSQL_DATABASE`
    
## MySQL Setup
- The project files include:
    - CreateTables.sql  : Creates the tables of the database
    - Queries.sql       : Implements queries for the deliverable, as well as helper functions and procedures
    - InsertData.sql    : Inserts dummy data into the database's tables

- Source these files after creating your local database