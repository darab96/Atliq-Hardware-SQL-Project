# AtliQ Hardware — SQL Challenge: Consumer Goods Insights

## 📋 Overview

| Field | Details |
|---|---|
| **Domain** | Consumer Goods |
| **Function** | Executive Management |
| **Tools Used** | MySQL, Python, Plotly |

## 🧩 Problem Statement

AtliQ Hardware (imaginary company) is one of the leading computer hardware producers in India, with a significant presence in other countries as well. However, the management noticed they were not receiving enough insights to make quick, smart, data-informed decisions.

To address this, the company decided to conduct an **SQL challenge** to better understand its data.

---

## 🎯 Task

- Review `ad-hoc-requests.pdf` — it contains **10 ad hoc business requests** that require data insights.
- Write SQL queries to answer each of those requests.
- Create a **presentation for top-level management** showcasing the insights.

---

## 🗄️ Data Model

> *(Insert Data Model image here)*

---

## ⚙️ Setup & Database Creation

### Step 1 — Connect to MySQL via Terminal

```bash
mysql -u root -p
```

Enter your password when prompted.

### Step 2 — Create the Database

Once connected successfully, run:

```bash
source RAW_Files/atliq_hardware_db.sql
```

This will generate AtliQ Hardware's database from the `atliq_hardware_db.sql` file.

> 📸 *(Insert screenshot: Steps to connect and create database in MySQL via terminal — Ubuntu)*

---

## 🔍 Running SQL Queries

### Method 1 — Using the SQL File

Run all queries using MySQL terminal or MySQL Workbench.

**Via terminal:**

```bash
source SQL_Query.sql
```

> 📸 *(Insert screenshot: How to run SQL_Query.sql using terminal)*

---

### Method 2 — Using Python

Use the MySQL Python library with Jupyter Notebook.

Open `SQL_Query.ipynb` to see how to:
- Connect to a MySQL database using Python
- Run all 10 queries programmatically

---

## 📊 Reports & Presentations

### Reports

- `SQL_Query_Solutions.pdf` — Contains all 10 questions along with their terminal outputs.
- `images/mysql_terminal_solutions/` — Folder containing all 10 individual query terminal output screenshots.

### Presentations

> 📸 *(Insert sample slide image here)*

The management presentation is available in two formats:

| Format | File |
|---|---|
| PDF | `Presentation.pdf` |
| PowerPoint | `Presentation.pptx` |

All charts and plots in the presentation were created using **Plotly**. The notebook used to generate them is `Presentation_plots.ipynb`.

> **⚠️ Note:** `Presentation_plots.ipynb` is an **unrendered** notebook. The rendered version was too large for GitHub's upload limit and was therefore excluded.

---

## 🔐 Credentials

`credentials.py` stores only the MySQL root password and is used to protect it from being hardcoded in the notebooks.

```python
# credentials.py
password = "your_mysql_root_password"
```

---

## 📎 Additional Resources

For full problem statement details and dataset information, visit:
👉 [codebasics.io](https://codebasics.io)
