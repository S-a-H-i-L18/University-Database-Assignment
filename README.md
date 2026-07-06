# University Database Assignment

## Part 1 – Relational Database Design and SQL Querying

---

# Task 1.1 – Normalization

## Original Relation

The university currently stores all information in a single flat table:

```text
StudentRecords(
    student_id,
    student_name,
    department,
    advisor_name,
    advisor_email,
    course_code,
    course_name,
    instructor_name,
    instructor_email,
    enrollment_year,
    marks_obtained
)
```

### Composite Primary Key

```
(student_id, course_code)
```

### Given Functional Dependencies

```
student_id → student_name, department, advisor_name

advisor_name → advisor_email

course_code → course_name, instructor_name, instructor_email

instructor_name → instructor_email

(student_id, course_code) → enrollment_year, marks_obtained
```

---

# Task 1.1(a)

## Partial Dependencies

A partial dependency exists when a non-prime attribute depends on only part of the composite primary key.

Since the primary key is **(student_id, course_code)**, the following partial dependencies exist:

### Depending only on student_id

```
student_id → student_name
student_id → department
student_id → advisor_name
```

These attributes depend only on **student_id** and not on the complete composite key.

### Depending only on course_code

```
course_code → course_name
course_code → instructor_name
course_code → instructor_email
```

These attributes depend only on **course_code**.

These partial dependencies violate **Second Normal Form (2NF)** because attributes depend on only part of the composite key.

---

## Transitive Dependencies

A transitive dependency exists when a non-key attribute depends on another non-key attribute.

### Advisor

```
student_id → advisor_name
advisor_name → advisor_email
```

Therefore,

```
student_id → advisor_email
```

is a transitive dependency.

### Instructor

```
course_code → instructor_name
instructor_name → instructor_email
```

Therefore,

```
course_code → instructor_email
```

is also a transitive dependency.

These dependencies violate **Third Normal Form (3NF)** and therefore must be removed before achieving BCNF.

---

# Task 1.1(b)

## BCNF Decomposition

The original relation is decomposed into the following relations.

---

### 1. Advisors

```
Advisors(
    advisor_id,
    advisor_name,
    advisor_email
)
```

Primary Key

```
advisor_id
```

Purpose

* Stores advisor details only.
* Removes duplication of advisor information.
* Eliminates the transitive dependency:

```
advisor_name → advisor_email
```

* Prevents update anomalies when an advisor's email changes.

---

### 2. Instructors

```
Instructors(
    instructor_id,
    instructor_name,
    instructor_email
)
```

Primary Key

```
instructor_id
```

Purpose

* Stores instructor information separately.
* Removes repeated instructor records.
* Eliminates the dependency:

```
instructor_name → instructor_email
```

---

### 3. Students

```
Students(
    student_id,
    student_name,
    department,
    advisor_id
)
```

Primary Key

```
student_id
```

Foreign Key

```
advisor_id → Advisors(advisor_id)
```

Purpose

* Stores student information only.
* Removes partial dependencies on student_id.
* Eliminates repeated student information.

---

### 4. Courses

```
Courses(
    course_code,
    course_name,
    instructor_id
)
```

Primary Key

```
course_code
```

Foreign Key

```
instructor_id → Instructors(instructor_id)
```

Purpose

* Stores course information independently.
* Removes partial dependencies on course_code.
* Eliminates repeated course information.
* Prevents insertion anomalies by allowing courses to exist without enrolled students.

---

### 5. Enrollments

```
Enrollments(
    student_id,
    course_code,
    enrollment_year,
    marks_obtained
)
```

Primary Key

```
(student_id, course_code)
```

Foreign Keys

```
student_id → Students(student_id)

course_code → Courses(course_code)
```

Purpose

* Stores enrollment information only.
* Resolves deletion anomalies by separating enrollment data from student and course information.
* Stores marks and enrollment year for each student-course combination.

---

## Why the Final Design is in BCNF

Each relation satisfies Boyce-Codd Normal Form because every determinant is a candidate key.

| Relation    | Determinant               | Candidate Key |
| ----------- | ------------------------- | ------------- |
| Students    | student_id                | Yes           |
| Advisors    | advisor_id                | Yes           |
| Instructors | instructor_id             | Yes           |
| Courses     | course_code               | Yes           |
| Enrollments | (student_id, course_code) | Yes           |

Since every functional dependency has a determinant that is a candidate key, all relations satisfy BCNF.

---

# Task 1.1(c)

## Data Integrity Analysis

### 1. Entity Integrity

**Status:** Satisfied

Reason:

* Every table has a primary key.
* Primary key values are unique.
* Primary keys cannot contain NULL values.

---

### 2. Referential Integrity

**Status:** Satisfied

Reason:

Foreign key relationships ensure valid references.

* Students → Advisors
* Courses → Instructors
* Enrollments → Students
* Enrollments → Courses

These constraints prevent orphan records.

---

### 3. Domain Integrity

**Status:** Satisfied

Reason:

Each attribute uses an appropriate data type.

Examples:

* student_id → INT
* advisor_name → VARCHAR
* instructor_email → VARCHAR
* course_code → VARCHAR
* enrollment_year → INT
* marks_obtained → DECIMAL(5,2)

Additional constraints such as CHECK and NOT NULL ensure only valid values are stored.

---

### 4. User-defined Integrity

**Status:** Satisfied

Business rules enforced include:

* marks_obtained must be between 0 and 100.
* advisor_email should be unique.
* instructor_email should be unique.
* A student cannot have duplicate enrollment records for the same course because of the composite primary key.

These constraints preserve business-specific data consistency.

---

# Data Type Design Decisions

The following data types were selected for the schema.

| Attribute        | Data Type    | Reason                                             |
| ---------------- | ------------ | -------------------------------------------------- |
| student_id       | INT          | Numeric identifier                                 |
| advisor_id       | INT          | Numeric identifier                                 |
| instructor_id    | INT          | Numeric identifier                                 |
| student_name     | VARCHAR(100) | Stores names of varying lengths                    |
| advisor_name     | VARCHAR(100) | Stores advisor names                               |
| instructor_name  | VARCHAR(100) | Stores instructor names                            |
| department       | VARCHAR(100) | Stores department names                            |
| advisor_email    | VARCHAR(150) | Stores email addresses                             |
| instructor_email | VARCHAR(150) | Stores email addresses                             |
| course_code      | VARCHAR(10)  | Stores short course codes such as CS101            |
| course_name      | VARCHAR(100) | Stores course titles                               |
| enrollment_year  | INT          | Stores the year of enrollment                      |
| marks_obtained   | DECIMAL(5,2) | Supports decimal marks while maintaining precision |

---

# References

The following references were consulted while preparing this assignment:

* Silberschatz, Korth and Sudarshan, *Database System Concepts*.
* Elmasri and Navathe, *Fundamentals of Database Systems*.
* PostgreSQL Documentation (SQL Language Reference).
* MySQL Documentation (SQL Language Reference).

No external source code was copied. The SQL statements and explanations were written specifically for this assignment.
